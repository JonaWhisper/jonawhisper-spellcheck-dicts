# frozen_string_literal: true

require "csv"
require "json"
require "zip"

module Langs
  module Fr
    SOURCES = {
      # Lexique383 — HTTP only, site does not support HTTPS
      lexique: "http://www.lexique.org/databases/Lexique383/Lexique383.tsv",
      # DELA — resolved dynamically from PyPI JSON API
      dela_pypi: "https://pypi.org/pypi/dict-fr-DELA/json",
      # Google Books Ngram Corpus v3 — curated French 2-grams
      bigrams: "https://raw.githubusercontent.com/orgtre/google-books-ngram-frequency/main/ngrams/2grams_french.csv",
    }.freeze

    module_function

    def label = "Fran\u00e7ais"
    def ram = 100_000_000

    def base_words(http:, tmp_dir:)
      puts "Building FR frequency dictionary..."
      src = DictBuilder.download(SOURCES[:lexique], File.join(tmp_dir, "Lexique383.tsv"), http: http)

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

      dela_path = fetch_dela(http: http, tmp_dir: tmp_dir)
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

      words
    end

    def build_freq(http:, tmp_dir:)
      base_words(http: http, tmp_dir: tmp_dir).sort_by { |_, freq| -freq }
    end

    def build_bigrams(http:, tmp_dir:)
      puts "Building FR bigrams..."
      src = DictBuilder.download(SOURCES[:bigrams], File.join(tmp_dir, "fr_bigrams.csv"), http: http)

      bigrams = []
      CSV.foreach(src, headers: true) do |row|
        ngram = (row["ngram"] || "").strip
        freq = Integer(row["freq"] || "0", exception: false) || 0
        parts = ngram.split
        next unless parts.size == 2
        bigrams << [parts[0], parts[1], freq]
      end

      bigrams
    end

    def freq_separator
      "\t"
    end

    # --- DELA ---

    def fetch_dela(http:, tmp_dir:)
      puts "  Fetching DELA wheel URL from PyPI..."
      response = http.get(SOURCES[:dela_pypi])
      raise "PyPI API error: HTTP #{response.status}" unless response.success?

      meta = JSON.parse(response.body)
      whl_info = meta["urls"]&.find { |u| u["filename"].end_with?(".whl") }
      unless whl_info
        warn "  WARNING: no .whl found on PyPI, skipping DELA"
        return nil
      end

      whl_path = File.join(tmp_dir, "dict_fr_DELA.whl")
      DictBuilder.download(whl_info["url"], whl_path, http: http)

      dict_path = File.join(tmp_dir, "dela-common-words.unicode")
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
  end
end
