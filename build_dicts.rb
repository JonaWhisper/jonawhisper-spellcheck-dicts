#!/usr/bin/env ruby
# frozen_string_literal: true

# Build SymSpell frequency dictionaries for JonaWhisper.
#
# Each language is defined in langs/<code>.rb and must expose:
#   - build_freq(http:, tmp_dir:)    → array of [word, freq] pairs
#   - build_bigrams(http:, tmp_dir:) → array of [word1, word2, freq] triples
#   - freq_separator                  → separator for freq.txt (tab or space)
#
# Environment:
#   DICT_CACHE_DIR — persistent directory for downloaded sources (optional).
#                    When set, downloaded files are kept across runs to avoid
#                    re-downloading unchanged sources. When unset, a temporary
#                    directory is used and cleaned up automatically.
#
# Usage:
#   bundle exec ruby build_dicts.rb

require "faraday"
require "faraday/follow_redirects"
require "fileutils"
require "tmpdir"

# --- Shared infrastructure ---

module DictBuilder
  HTTP = Faraday.new do |f|
    f.response :follow_redirects, limit: 5
    f.options.timeout = 120
    f.options.open_timeout = 15
  end

  module_function

  def download(url, dest, http: HTTP)
    if File.exist?(dest)
      puts "  cached: #{File.basename(dest)}"
      return dest
    end
    puts "  downloading: #{url}"
    response = http.get(url)
    raise "HTTP #{response.status} for #{url}" unless response.success?
    FileUtils.mkdir_p(File.dirname(dest))
    File.open(dest, "wb") { |f| f.write(response.body) }
    puts "  saved: #{(File.size(dest) / 1024.0).round(1)} KB"
    dest
  end
end

# --- Discover and load language modules ---

REPO_ROOT = File.dirname(File.realpath(__FILE__))
LANGS_DIR = File.join(REPO_ROOT, "langs")

Dir.glob(File.join(LANGS_DIR, "*.rb")).sort.each { |f| require f }

def available_langs
  Langs.constants
    .select { |c| Langs.const_get(c).is_a?(Module) }
    .map { |c| [c.to_s.downcase, Langs.const_get(c)] }
    .sort_by(&:first)
end

# --- Build pipeline ---

def build_lang(code, lang_mod, tmp_dir:)
  lang_tmp = File.join(tmp_dir, code)
  FileUtils.mkdir_p(lang_tmp)
  out_dir = File.join(REPO_ROOT, code)
  FileUtils.mkdir_p(out_dir)

  sep = lang_mod.freq_separator

  words = lang_mod.build_freq(http: DictBuilder::HTTP, tmp_dir: lang_tmp)
  freq_path = File.join(out_dir, "freq.txt")
  File.open(freq_path, "w:utf-8") do |f|
    words.each { |word, freq| f.puts "#{word}#{sep}#{freq}" }
  end
  puts "  -> #{code}/freq.txt: #{words.size} entries (#{(File.size(freq_path) / 1024.0).round(1)} KB)"

  bigrams = lang_mod.build_bigrams(http: DictBuilder::HTTP, tmp_dir: lang_tmp)
  bigram_path = File.join(out_dir, "bigram.txt")
  File.open(bigram_path, "w:utf-8") do |f|
    bigrams.each { |w1, w2, freq| f.puts "#{w1} #{w2} #{freq}" }
  end
  puts "  -> #{code}/bigram.txt: #{bigrams.size} entries (#{(File.size(bigram_path) / 1024.0).round(1)} KB)"

  { words: words.size, bigrams: bigrams.size }
end

def run(tmp_dir)
  langs = available_langs
  puts "Languages: #{langs.map(&:first).join(", ")}"
  puts

  results = {}
  langs.each do |code, lang_mod|
    results[code] = build_lang(code, lang_mod, tmp_dir: tmp_dir)
    puts
  end

  puts "Summary:"
  results.each do |code, r|
    puts "  #{code.upcase}: #{r[:words]} words, #{r[:bigrams]} bigrams"
  end
end

# --- Main ---

cache_dir = ENV["DICT_CACHE_DIR"]

if cache_dir
  FileUtils.mkdir_p(cache_dir)
  run(cache_dir)
else
  Dir.mktmpdir("jonawhisper-spellcheck") { |tmp_dir| run(tmp_dir) }
end
