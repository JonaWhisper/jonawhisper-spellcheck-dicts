#!/usr/bin/env ruby
# frozen_string_literal: true

# Build SymSpell frequency dictionaries for JonaWhisper.
#
# FR: Lexique383 (125K words with frequencies) + DELA (641K inflected forms) + Google Books bigrams
# EN: SymSpell official frequency dictionary (wolfgarbe/SymSpell) + bigrams
#
# Output:
#   fr/freq.txt     — 645K+ French words (tab-separated: word<TAB>freq)
#   fr/bigram.txt   — French bigrams (space-separated: word1 word2 freq)
#   en/freq.txt     — 82K English words (space-separated: word freq)
#   en/bigram.txt   — 242K English bigrams (space-separated: word1 word2 freq)
#
# Usage:
#   bundle exec ruby build_dicts.rb          # build all (uses cache)
#   bundle exec ruby build_dicts.rb --fresh  # force re-download everything

require "csv"
require "faraday"
require "faraday/follow_redirects"
require "fileutils"
require "json"
require "tmpdir"
require "zip"

REPO_ROOT = File.dirname(File.realpath(__FILE__))
CACHE_DIR = File.join(Dir.tmpdir, "jonawhisper-spellcheck-build")

HTTP = Faraday.new do |f|
  f.response :follow_redirects, limit: 5
  f.options.timeout = 120
  f.options.open_timeout = 15
end

# --- Sources ---

SOURCES = {
  # Lexique383 — HTTP only, site does not support HTTPS
  lexique: "http://www.lexique.org/databases/Lexique383/Lexique383.tsv",
  # DELA — resolved dynamically from PyPI JSON API
  dela_pypi: "https://pypi.org/pypi/dict-fr-DELA/json",
  # Google Books Ngram Corpus v3 — curated French 2-grams
  fr_bigrams: "https://raw.githubusercontent.com/orgtre/google-books-ngram-frequency/main/ngrams/2grams_french.csv",
  # SymSpell official dictionaries
  en_freq: "https://raw.githubusercontent.com/wolfgarbe/SymSpell/master/SymSpell/frequency_dictionary_en_82_765.txt",
  en_bigrams: "https://raw.githubusercontent.com/wolfgarbe/SymSpell/master/SymSpell/frequency_bigramdictionary_en_243_342.txt",
}.freeze

LANG_DIRS = %w[fr en].freeze

# --- Helpers ---

def cache_path(name)
  File.join(CACHE_DIR, name)
end

def download(url, dest, fresh: false)
  if File.exist?(dest) && !fresh
    puts "  cached: #{dest}"
    return dest
  end
  puts "  downloading: #{url}"
  response = HTTP.get(url)
  raise "HTTP #{response.status} for #{url}" unless response.success?
  FileUtils.mkdir_p(File.dirname(dest))
  File.open(dest, "wb") { |f| f.write(response.body) }
  puts "  saved: #{(File.size(dest) / 1024.0).round(1)} KB"
  dest
end

def output_path(lang, filename)
  dir = File.join(REPO_ROOT, lang)
  FileUtils.mkdir_p(dir)
  File.join(dir, filename)
end

def count_lines(path)
  File.foreach(path).count
end

# --- DELA ---

def fetch_dela(fresh: false)
  dict_path = cache_path("dela-common-words.unicode")
  if File.exist?(dict_path) && !fresh
    puts "  DELA cached: #{dict_path}"
    return dict_path
  end

  puts "  Fetching DELA wheel URL from PyPI..."
  response = HTTP.get(SOURCES[:dela_pypi])
  raise "PyPI API error: HTTP #{response.status}" unless response.success?

  meta = JSON.parse(response.body)
  whl_info = meta["urls"]&.find { |u| u["filename"].end_with?(".whl") }
  unless whl_info
    warn "  WARNING: no .whl found on PyPI, skipping DELA"
    return nil
  end

  whl_path = cache_path("dict_fr_DELA.whl")
  download(whl_info["url"], whl_path, fresh: true)

  # A .whl is a zip — find and extract the common-words dict
  Zip::File.open(whl_path) do |zip|
    entry = zip.entries.find { |e| e.name.end_with?("dict-fr-DELA-common-words.unicode") }
    unless entry
      warn "  WARNING: dict file not found in wheel"
      return nil
    end
    File.open(dict_path, "wb") { |f| f.write(entry.get_input_stream.read) }
  end

  puts "  DELA extracted: #{(File.size(dict_path) / 1024.0).round(1)} KB"
  dict_path
end

# --- Builders ---

def build_fr_freq(fresh: false)
  puts "Building FR frequency dictionary..."
  src = download(SOURCES[:lexique], cache_path("Lexique383.tsv"), fresh: fresh)

  words = {}

  CSV.foreach(src, col_sep: "\t", headers: true, liberal_parsing: true) do |row|
    word = (row["ortho"] || "").strip.downcase
    next if word.empty? || word.length <= 1

    freq_livres = Float(row["freqlivres"] || "0", exception: false) || 0.0
    freq_films = Float(row["freqfilms2"] || "0", exception: false) || 0.0

    freq = [((freq_livres * 70 + freq_films * 30) * 100).to_i, 1].max
    words[word] = freq if !words.key?(word) || words[word] < freq
  end

  puts "  Lexique383: #{words.size} words"

  dela_path = fetch_dela(fresh: fresh)
  if dela_path
    dela_added = 0
    File.foreach(dela_path, encoding: "utf-8") do |line|
      word = line.strip.downcase
      next if word.empty? || word.length <= 1 || word.include?(" ")
      unless words.key?(word)
        words[word] = 1
        dela_added += 1
      end
    end
    puts "  DELA: +#{dela_added} new words (total: #{words.size})"
  else
    puts "  DELA: skipped (not available)"
  end

  out = output_path("fr", "freq.txt")
  sorted = words.sort_by { |_, freq| -freq }
  File.open(out, "w:utf-8") do |f|
    sorted.each { |word, freq| f.puts "#{word}\t#{freq}" }
  end

  puts "  wrote #{sorted.size} words to #{out}"
  sorted.size
end

def build_fr_bigrams(fresh: false)
  puts "Building FR bigrams..."
  src = download(SOURCES[:fr_bigrams], cache_path("fr_bigrams_google.csv"), fresh: fresh)

  out = output_path("fr", "bigram.txt")
  count = 0

  File.open(out, "w:utf-8") do |fout|
    CSV.foreach(src, headers: true) do |row|
      ngram = (row["ngram"] || "").strip
      freq = Integer(row["freq"] || "0", exception: false) || 0
      parts = ngram.split
      next unless parts.size == 2

      fout.puts "#{parts[0]} #{parts[1]} #{freq}"
      count += 1
    end
  end

  puts "  wrote #{count} bigrams to #{out}"
  count
end

def build_en_freq(fresh: false)
  puts "Building EN frequency dictionary..."
  out = output_path("en", "freq.txt")
  download(SOURCES[:en_freq], out, fresh: fresh)
  count = count_lines(out)
  puts "  #{count} words"
  count
end

def build_en_bigrams(fresh: false)
  puts "Building EN bigrams..."
  out = output_path("en", "bigram.txt")
  download(SOURCES[:en_bigrams], out, fresh: fresh)
  count = count_lines(out)
  puts "  #{count} bigrams"
  count
end

# --- Main ---

fresh = ARGV.include?("--fresh")
FileUtils.mkdir_p(CACHE_DIR)

results = {
  fr_words: build_fr_freq(fresh: fresh),
  fr_bigrams: build_fr_bigrams(fresh: fresh),
  en_words: build_en_freq(fresh: fresh),
  en_bigrams: build_en_bigrams(fresh: fresh),
}

puts
puts "Done!"
puts "  FR: #{results[:fr_words]} words, #{results[:fr_bigrams]} bigrams"
puts "  EN: #{results[:en_words]} words, #{results[:en_bigrams]} bigrams"
puts

LANG_DIRS.each do |lang|
  dir = File.join(REPO_ROOT, lang)
  next unless File.directory?(dir)
  Dir.glob(File.join(dir, "*.txt")).sort.each do |f|
    puts "  #{lang}/#{File.basename(f)}: #{(File.size(f) / 1024.0).round(1)} KB"
  end
end
