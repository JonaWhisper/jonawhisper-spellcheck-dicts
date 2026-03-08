# frozen_string_literal: true

module Langs
  module Ru
    # Russian — SymSpell official dict (Google Ngrams + Hunspell validated)
    # + Leipzig Corpora for bigrams

    SOURCES = {
      freq: "https://raw.githubusercontent.com/wolfgarbe/SymSpell/master/SymSpell.FrequencyDictionary/ru-100k.txt",
      bigram_corpora: [
        "https://downloads.wortschatz-leipzig.de/corpora/rus_newscrawl-public_2018_1M.tar.gz",
        "https://downloads.wortschatz-leipzig.de/corpora/rus_wikipedia_2021_1M.tar.gz",
        "https://downloads.wortschatz-leipzig.de/corpora/rus_news_2024_1M.tar.gz",
      ].freeze,
    }.freeze

    BIGRAM_LIMIT = 100_000
    # Cyrillic alphabet range
    ALPHA_WORD_RE = /\A[\u0400-\u04FF]+\z/

    module_function

    def label = "\u0420\u0443\u0441\u0441\u043a\u0438\u0439"

    def build_freq(http:, tmp_dir:)
      puts "Building RU frequency dictionary..."
      src = DictBuilder.download(SOURCES[:freq], File.join(tmp_dir, "ru_freq.txt"), http: http)

      words = {}
      File.foreach(src, encoding: "utf-8") do |line|
        parts = line.strip.split(" ", 2)
        next unless parts.size == 2
        word = parts[0]
        freq = Integer(parts[1], exception: false) || 0
        words[word] = freq if !words.key?(word) || words[word] < freq
      end

      puts "  #{words.size} words"
      words.sort_by { |_, freq| -freq }
    end

    def build_bigrams(http:, tmp_dir:)
      puts "Building RU bigrams from Leipzig Corpora (target: #{BIGRAM_LIMIT})..."
      DictBuilder.build_leipzig_bigrams(
        SOURCES[:bigram_corpora],
        limit: BIGRAM_LIMIT, word_re: ALPHA_WORD_RE,
        http: http, tmp_dir: tmp_dir,
      )
    end

    def freq_separator = " "
  end
end
