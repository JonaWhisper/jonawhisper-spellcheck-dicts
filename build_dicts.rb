#!/usr/bin/env ruby
# frozen_string_literal: true

# Build SymSpell frequency dictionaries for JonaWhisper.
#
# Each language is defined in langs/<code>.rb and must expose:
#   - build_freq(http:, tmp_dir:)    → array of [word, freq] pairs
#   - build_bigrams(http:, tmp_dir:) → array of [word1, word2, freq] triples
#   - freq_separator                  → separator for freq.txt (tab or space)
#
# Output goes to output/ with release-ready filenames:
#   output/fr-freq.txt, output/fr-bigram.txt, output/en-freq.txt, ...
#   output/manifest.json (checksums + metadata for update detection)
#
# Environment:
#   DICT_CACHE_DIR — persistent directory for downloaded sources (optional).
#
# Usage:
#   bundle exec ruby build_dicts.rb

require "digest"
require "faraday"
require "faraday/follow_redirects"
require "fileutils"
require "json"
require "tmpdir"

# --- Shared infrastructure ---

module DictBuilder
  HTTP = Faraday.new do |f|
    f.response :follow_redirects, limit: 5
    f.options.timeout = 120
    f.options.open_timeout = 15
  end

  DATA_DIR = File.join(File.dirname(File.realpath(__FILE__)), "data")

  module_function

  # Merge regional words from data/<code>.tsv into a base word hash.
  # TSV with headers: word, frequency, definition. Comments (#) are skipped.
  # Returns the number of words added/boosted.
  def merge_regional!(words, code)
    path = File.join(DATA_DIR, "#{code}.tsv")
    unless File.exist?(path)
      warn "  WARNING: #{path} not found, skipping regional words"
      return 0
    end

    count = 0
    CSV.foreach(path, col_sep: "\t", headers: true, skip_lines: /\A\s*#/) do |row|
      word = (row["word"] || "").strip.downcase
      freq = Integer(row["frequency"] || "0", exception: false) || 0
      next if word.empty? || freq <= 0
      words[word] = [words.fetch(word, 0), freq].max
      count += 1
    end
    count
  end

  def download(url, dest, http: HTTP)
    if File.exist?(dest)
      puts "  cached: #{File.basename(dest)}"
      return dest
    end
    puts "  downloading: #{url}"
    FileUtils.mkdir_p(File.dirname(dest))
    File.open(dest, "wb") do |file|
      http.get(url) do |req|
        req.options.on_data = proc do |chunk, _size, env|
          raise "HTTP #{env.status} for #{url}" if env.status >= 400
          file.write(chunk)
        end
      end
    end
    puts "  saved: #{(File.size(dest) / 1024.0).round(1)} KB"
    dest
  end
end

# --- Discover and load language modules ---

REPO_ROOT = File.dirname(File.realpath(__FILE__))
LANGS_DIR = File.join(REPO_ROOT, "langs")
OUTPUT_DIR = File.join(REPO_ROOT, "output")

Dir.glob(File.join(LANGS_DIR, "*.rb")).sort.each { |f| require f }

def available_langs
  Dir.glob(File.join(LANGS_DIR, "*.rb")).sort.filter_map do |f|
    code = File.basename(f, ".rb").tr("_", "-")
    mod_name = code.split("-").map(&:capitalize).join
    mod = Langs.const_get(mod_name, false) rescue nil
    [code, mod] if mod&.respond_to?(:build_freq)
  end
end

# --- Build pipeline ---

def build_lang(code, lang_mod, tmp_dir:)
  lang_tmp = File.join(tmp_dir, code)
  FileUtils.mkdir_p(lang_tmp)

  sep = lang_mod.freq_separator
  files = {}

  # Freq
  words = lang_mod.build_freq(http: DictBuilder::HTTP, tmp_dir: lang_tmp)
  freq_path = File.join(OUTPUT_DIR, "#{code}-freq.txt")
  File.open(freq_path, "w:utf-8") do |f|
    words.each { |word, freq| f.puts "#{word}#{sep}#{freq}" }
  end
  files["freq.txt"] = { path: freq_path, entries: words.size }
  puts "  -> #{code}-freq.txt: #{words.size} entries (#{(File.size(freq_path) / 1024.0).round(1)} KB)"

  # Bigrams
  bigrams = lang_mod.build_bigrams(http: DictBuilder::HTTP, tmp_dir: lang_tmp)
  bigram_path = File.join(OUTPUT_DIR, "#{code}-bigram.txt")
  File.open(bigram_path, "w:utf-8") do |f|
    bigrams.each { |w1, w2, freq| f.puts "#{w1} #{w2} #{freq}" }
  end
  files["bigram.txt"] = { path: bigram_path, entries: bigrams.size }
  puts "  -> #{code}-bigram.txt: #{bigrams.size} entries (#{(File.size(bigram_path) / 1024.0).round(1)} KB)"

  files
end

def build_manifest(all_files, lang_modules)
  manifest = { generated_at: Time.now.utc.iso8601, languages: {} }

  all_files.each do |code, files|
    lang_mod = lang_modules[code]
    lang_data = {
      label: lang_mod&.respond_to?(:label) ? lang_mod.label : code,
      ram: lang_mod&.respond_to?(:ram) ? lang_mod.ram : 0,
      files: {},
    }
    files.each do |name, info|
      size = File.size(info[:path])
      sha256 = Digest::SHA256.file(info[:path]).hexdigest
      lang_data[:files][name] = {
        filename: File.basename(info[:path]),
        size: size,
        sha256: sha256,
        entries: info[:entries],
      }
    end
    manifest[:languages][code] = lang_data
  end

  manifest_path = File.join(OUTPUT_DIR, "manifest.json")
  File.write(manifest_path, JSON.pretty_generate(manifest))
  puts "  -> manifest.json"
  manifest_path
end

def run(tmp_dir)
  langs = available_langs
  puts "Languages: #{langs.map(&:first).join(", ")}"
  puts

  FileUtils.rm_rf(OUTPUT_DIR)
  FileUtils.mkdir_p(OUTPUT_DIR)

  all_files = {}
  lang_modules = {}
  langs.each do |code, lang_mod|
    all_files[code] = build_lang(code, lang_mod, tmp_dir: tmp_dir)
    lang_modules[code] = lang_mod
    puts
  end

  build_manifest(all_files, lang_modules)

  puts
  puts "Summary:"
  all_files.each do |code, files|
    words = files["freq.txt"][:entries]
    bigrams = files["bigram.txt"][:entries]
    puts "  #{code.upcase}: #{words} words, #{bigrams} bigrams"
  end
  puts
  puts "Output: #{OUTPUT_DIR}/"
  Dir.glob(File.join(OUTPUT_DIR, "*")).sort.each do |f|
    puts "  #{File.basename(f)}: #{(File.size(f) / 1024.0).round(1)} KB"
  end
end

# --- Main ---

if __FILE__ == $PROGRAM_NAME
  cache_dir = ENV["DICT_CACHE_DIR"]

  if cache_dir
    FileUtils.mkdir_p(cache_dir)
    run(cache_dir)
  else
    Dir.mktmpdir("jonawhisper-spellcheck") { |tmp_dir| run(tmp_dir) }
  end
end
