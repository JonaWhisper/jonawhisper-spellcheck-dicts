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
#   ruby build_dicts.rb          # build all (uses cache)
#   ruby build_dicts.rb --fresh  # force re-download everything

require "csv"
require "faraday"
require "faraday/follow_redirects"
require "fileutils"
require "json"
require "zip"

REPO_ROOT = File.dirname(File.realpath(__FILE__))

HTTP = Faraday.new do |f|
  f.response :follow_redirects, limit: 5
  f.options.timeout = 120
  f.options.open_timeout = 15
end

# --- Sources ---

LEXIQUE_URL    = "http://www.lexique.org/databases/Lexique383/Lexique383.tsv"
LEXIQUE_CACHE  = "/tmp/Lexique383.tsv"

# DELA French dictionary — 641K inflected forms from LADL (distributed as a PyPI wheel = zip)
DELA_PYPI_JSON = "https://pypi.org/pypi/dict-fr-DELA/json"
DELA_WHEEL_CACHE = "/tmp/dict_fr_DELA.whl"
DELA_DICT = "/tmp/dela_ruby/dict-fr-DELA-common-words.unicode"
DELA_DICT_PATTERN = "dict-fr-DELA-common-words.unicode"

# French bigrams from Google Books Ngram Corpus v3 (top 5K, 2010-2019 books)
FR_BIGRAM_URL   = "https://raw.githubusercontent.com/orgtre/google-books-ngram-frequency/main/ngrams/2grams_french.csv"
FR_BIGRAM_CACHE = "/tmp/fr_bigrams_google.csv"

# SymSpell official English frequency dict (82K words) + bigrams (242K)
EN_FREQ_URL   = "https://raw.githubusercontent.com/wolfgarbe/SymSpell/master/SymSpell/frequency_dictionary_en_82_765.txt"
EN_BIGRAM_URL = "https://raw.githubusercontent.com/wolfgarbe/SymSpell/master/SymSpell/frequency_bigramdictionary_en_243_342.txt"

def download(url, dest, fresh: false)
  if File.exist?(dest) && !fresh
    puts "  cached: #{dest}"
    return dest
  end
  puts "  downloading: #{url}"
  response = HTTP.get(url)
  raise "HTTP #{response.status} for #{url}" unless response.success?
  File.open(dest, "wb") { |f| f.write(response.body) }
  dest
end

def ensure_dela
  if File.exist?(DELA_DICT)
    puts "  DELA cached: #{DELA_DICT}"
    return
  end
  puts "  Fetching DELA wheel URL from PyPI..."
  response = HTTP.get(DELA_PYPI_JSON)
  raise "PyPI API error: HTTP #{response.status}" unless response.success?
  meta = JSON.parse(response.body)
  whl_url = meta["urls"]&.find { |u| u["filename"].end_with?(".whl") }&.dig("url")
  unless whl_url
    puts "  WARNING: no .whl found on PyPI, skipping DELA"
    return
  end
  download(whl_url, DELA_WHEEL_CACHE)
  # A .whl is a zip — extract the dict file with rubyzip
  FileUtils.mkdir_p(File.dirname(DELA_DICT))
  Zip::File.open(DELA_WHEEL_CACHE) do |zip|
    entry = zip.entries.find { |e| e.name.end_with?(DELA_DICT_PATTERN) }
    if entry
      File.open(DELA_DICT, "wb") { |f| f.write(entry.get_input_stream.read) }
    end
  end
  puts "  WARNING: DELA extraction failed, skipping DELA enrichment" unless File.exist?(DELA_DICT)
end

def build_fr_dict(fresh: false)
  puts "Building FR dictionary from Lexique383 + DELA..."
  src = download(LEXIQUE_URL, LEXIQUE_CACHE, fresh: fresh)

  words = {}

  # Step 1: Load Lexique383 (with frequencies)
  CSV.foreach(src, col_sep: "\t", headers: true, liberal_parsing: true) do |row|
    word = (row["ortho"] || "").strip.downcase
    next if word.empty? || word.length <= 1

    freq_livres = (row["freqlivres"] || "0").to_f
    freq_films  = (row["freqfilms2"] || "0").to_f

    # Combine both corpora with books weighted higher (more relevant for dictation)
    freq = ((freq_livres * 70 + freq_films * 30) * 100).to_i
    freq = [freq, 1].max

    words[word] = freq if !words.key?(word) || words[word] < freq
  end

  lexique_count = words.size
  puts "  Lexique383: #{lexique_count} words"

  # Step 2: Enrich with DELA (641K inflected forms, no frequency data)
  ensure_dela
  dela_added = 0
  if File.exist?(DELA_DICT)
    File.foreach(DELA_DICT, encoding: "utf-8") do |line|
      word = line.strip.downcase
      next if word.empty? || word.length <= 1
      next if word.include?(" ")
      unless words.key?(word)
        words[word] = 1
        dela_added += 1
      end
    end
    puts "  DELA: +#{dela_added} new words (total: #{words.size})"
  else
    puts "  DELA: skipped (not available)"
  end

  # Sort by frequency descending
  sorted_words = words.sort_by { |_, freq| -freq }

  out_dir = File.join(REPO_ROOT, "fr")
  FileUtils.mkdir_p(out_dir)
  out = File.join(out_dir, "freq.txt")
  File.open(out, "w:utf-8") do |f|
    sorted_words.each { |word, freq| f.puts "#{word}\t#{freq}" }
  end

  puts "  wrote #{sorted_words.size} words to #{out}"
  sorted_words.size
end

def build_fr_bigrams(fresh: false)
  puts "Building FR bigrams from Google Books Ngram..."
  src = download(FR_BIGRAM_URL, FR_BIGRAM_CACHE, fresh: fresh)

  out_dir = File.join(REPO_ROOT, "fr")
  FileUtils.mkdir_p(out_dir)
  out = File.join(out_dir, "bigram.txt")
  count = 0

  File.open(out, "w:utf-8") do |fout|
    CSV.foreach(src, headers: true) do |row|
      ngram = (row["ngram"] || "").strip
      freq = row["freq"].to_i
      parts = ngram.split
      # Only keep clean 2-word bigrams (skip tokenization artifacts like "d' un")
      if parts.size == 2
        fout.puts "#{parts[0]} #{parts[1]} #{freq}"
        count += 1
      end
    end
  end

  puts "  wrote #{count} bigrams to #{out}"
  count
end

def build_en_dict(fresh: false)
  puts "Building EN dictionary from SymSpell official..."
  out_dir = File.join(REPO_ROOT, "en")
  FileUtils.mkdir_p(out_dir)
  dest = File.join(out_dir, "freq.txt")
  download(EN_FREQ_URL, dest, fresh: fresh)

  count = File.foreach(dest).count
  puts "  #{count} words in #{dest}"
  count
end

def build_en_bigrams(fresh: false)
  puts "Downloading EN bigram dictionary..."
  out_dir = File.join(REPO_ROOT, "en")
  FileUtils.mkdir_p(out_dir)
  dest = File.join(out_dir, "bigram.txt")
  download(EN_BIGRAM_URL, dest, fresh: fresh)

  count = File.foreach(dest).count
  puts "  #{count} bigrams in #{dest}"
  count
end

# --- Main ---

fresh = ARGV.include?("--fresh")

fr_count = build_fr_dict(fresh: fresh)
fr_bi    = build_fr_bigrams(fresh: fresh)
en_count = build_en_dict(fresh: fresh)
en_bi    = build_en_bigrams(fresh: fresh)

puts
puts "Done!"
puts "  FR: #{fr_count} words, #{fr_bi} bigrams"
puts "  EN: #{en_count} words, #{en_bi} bigrams"

Dir.glob(File.join(REPO_ROOT, "*/")).sort.each do |lang_dir|
  next if File.basename(lang_dir).start_with?(".")
  Dir.glob(File.join(lang_dir, "*.txt")).sort.each do |f|
    size = File.size(f)
    puts "  #{File.basename(lang_dir)}/#{File.basename(f)}: #{size / 1024} KB"
  end
end
