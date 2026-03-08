# frozen_string_literal: true

module Langs
  module Es
    # Spanish — SymSpell official dict (Google Ngrams + Hunspell validated)
    # + Leipzig Corpora for bigrams

    SOURCES = {
      # Note: filename on GitHub is "es-100l.txt" (not "100k")
      freq: "https://raw.githubusercontent.com/wolfgarbe/SymSpell/master/SymSpell.FrequencyDictionary/es-100l.txt",
      bigram_corpora: [
        "https://downloads.wortschatz-leipzig.de/corpora/spa_newscrawl_2018_1M.tar.gz",
        "https://downloads.wortschatz-leipzig.de/corpora/spa_wikipedia_2021_1M.tar.gz",
        "https://downloads.wortschatz-leipzig.de/corpora/spa_news_2024_1M.tar.gz",
      ].freeze,
    }.freeze

    BIGRAM_LIMIT = 100_000
    ALPHA_WORD_RE = /\A[a-zA-Z\u00C0-\u024F\u00F1\u00D1]+\z/

    module_function

    def label = "Espa\u00f1ol"

    def base_words(http:, tmp_dir:)
      puts "Building ES frequency dictionary..."
      src = DictBuilder.download(SOURCES[:freq], File.join(tmp_dir, "es_freq.txt"), http: http)

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
      puts "Building ES bigrams from Leipzig Corpora (target: #{BIGRAM_LIMIT})..."
      DictBuilder.build_leipzig_bigrams(
        SOURCES[:bigram_corpora],
        limit: BIGRAM_LIMIT, word_re: ALPHA_WORD_RE,
        http: http, tmp_dir: tmp_dir,
      )
    end

    def freq_separator = " "
  end
end
