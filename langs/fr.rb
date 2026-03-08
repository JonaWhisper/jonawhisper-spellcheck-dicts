# frozen_string_literal: true

require "csv"
require "json"
require "zlib"
require "zip"

module Langs
  module Fr
    SOURCES = {
      # Lexique383 — HTTP only, site does not support HTTPS
      lexique: "http://www.lexique.org/databases/Lexique383/Lexique383.tsv",
      # DELA — resolved dynamically from PyPI JSON API
      dela_pypi: "https://pypi.org/pypi/dict-fr-DELA/json",
      # Leipzig Corpora — French sentence corpora for bigram extraction
      # Each tar.gz contains a sentences.txt with 1M sentences
      bigram_corpora: [
        "https://downloads.wortschatz-leipzig.de/corpora/fra_newscrawl_2020_1M.tar.gz",
        "https://downloads.wortschatz-leipzig.de/corpora/fra_wikipedia_2021_1M.tar.gz",
        "https://downloads.wortschatz-leipzig.de/corpora/fra_news_2020_1M.tar.gz",
      ].freeze,
    }.freeze

    BIGRAM_LIMIT = 100_000
    # Match purely alphabetic words (including accented Latin characters)
    ALPHA_WORD_RE = /\A[a-zA-Z\u00C0-\u024F]+\z/

    module_function

    def label = "Fran\u00e7ais"

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
      puts "Building FR bigrams from Leipzig Corpora (target: #{BIGRAM_LIMIT})..."
      DictBuilder.build_leipzig_bigrams(
        SOURCES[:bigram_corpora],
        limit: BIGRAM_LIMIT, word_re: ALPHA_WORD_RE,
        http: http, tmp_dir: tmp_dir,
      )
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
