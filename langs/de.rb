# frozen_string_literal: true

module Langs
  module De
    # German — SymSpell official dict (Google Ngrams + Hunspell validated)
    # + Leipzig Corpora for bigrams

    SOURCES = {
      freq: "https://raw.githubusercontent.com/wolfgarbe/SymSpell/master/SymSpell.FrequencyDictionary/de-100k.txt",
      bigram_corpora: [
        "https://downloads.wortschatz-leipzig.de/corpora/deu_newscrawl_2020_1M.tar.gz",
        "https://downloads.wortschatz-leipzig.de/corpora/deu_wikipedia_2021_1M.tar.gz",
        "https://downloads.wortschatz-leipzig.de/corpora/deu_news_2024_1M.tar.gz",
      ].freeze,
    }.freeze

    BIGRAM_LIMIT = 100_000
    # Latin + German-specific (umlauts, eszett)
    ALPHA_WORD_RE = /\A[a-zA-Z\u00C0-\u024F\u00DF]+\z/

    module_function

    def label = "Deutsch"

    def base_words(http:, tmp_dir:)
      puts "Building DE frequency dictionary..."
      src = DictBuilder.download(SOURCES[:freq], File.join(tmp_dir, "de_freq.txt"), http: http)

      words = {}
      File.foreach(src, encoding: "utf-8") do |line|
        parts = line.strip.split(" ", 2)
        next unless parts.size == 2
        word = parts[0]
        freq = Integer(parts[1], exception: false) || 0
        words[word] = freq if !words.key?(word) || words[word] < freq
      end

      puts "  #{words.size} words"
      words
    end

    def build_freq(http:, tmp_dir:)
      base_words(http: http, tmp_dir: tmp_dir).sort_by { |_, freq| -freq }
    end

    def build_bigrams(http:, tmp_dir:)
      puts "Building DE bigrams from Leipzig Corpora (target: #{BIGRAM_LIMIT})..."
      DictBuilder.build_leipzig_bigrams(
        SOURCES[:bigram_corpora],
        limit: BIGRAM_LIMIT, word_re: ALPHA_WORD_RE,
        http: http, tmp_dir: tmp_dir,
      )
    end

    def freq_separator = " "
  end
end
