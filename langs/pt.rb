# frozen_string_literal: true

module Langs
  module Pt
    # Portuguese — FrequencyWords (OpenSubtitles) for word frequencies
    # + Leipzig Corpora for bigrams
    # Base Portuguese — regional variants (pt_br, pt_pt) can extend this.

    SOURCES = {
      freq: "https://raw.githubusercontent.com/hermitdave/FrequencyWords/master/content/2018/pt/pt_50k.txt",
      bigram_corpora: [
        "https://downloads.wortschatz-leipzig.de/corpora/por_newscrawl_2020_1M.tar.gz",
        "https://downloads.wortschatz-leipzig.de/corpora/por_wikipedia_2021_1M.tar.gz",
        "https://downloads.wortschatz-leipzig.de/corpora/por_news_2024_1M.tar.gz",
      ].freeze,
    }.freeze

    BIGRAM_LIMIT = 100_000
    ALPHA_WORD_RE = /\A[a-zA-Z\u00C0-\u024F]+\z/

    module_function

    def label = "Portugu\u00eas"

    def base_words(http:, tmp_dir:)
      puts "Building PT frequency dictionary..."
      src = DictBuilder.download(SOURCES[:freq], File.join(tmp_dir, "pt_freq.txt"), http: http)

      words = {}
      File.foreach(src, encoding: "utf-8") do |line|
        parts = line.strip.split(" ", 2)
        next unless parts.size == 2
        word = parts[0].downcase
        next if word.length <= 1
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
      puts "Building PT bigrams from Leipzig Corpora (target: #{BIGRAM_LIMIT})..."
      DictBuilder.build_leipzig_bigrams(
        SOURCES[:bigram_corpora],
        limit: BIGRAM_LIMIT, word_re: ALPHA_WORD_RE,
        http: http, tmp_dir: tmp_dir,
      )
    end

    def freq_separator = " "
  end
end
