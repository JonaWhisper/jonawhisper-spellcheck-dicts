# frozen_string_literal: true

module Langs
  module En
    SOURCES = {
      freq: "https://raw.githubusercontent.com/wolfgarbe/SymSpell/master/SymSpell/frequency_dictionary_en_82_765.txt",
      bigrams: "https://raw.githubusercontent.com/wolfgarbe/SymSpell/master/SymSpell/frequency_bigramdictionary_en_243_342.txt",
    }.freeze

    module_function

    def build_freq(http:, tmp_dir:)
      puts "Building EN frequency dictionary..."
      src = DictBuilder.download(SOURCES[:freq], File.join(tmp_dir, "en_freq.txt"), http: http)

      words = []
      File.foreach(src, encoding: "utf-8") do |line|
        parts = line.strip.split(" ", 2)
        next unless parts.size == 2
        words << [parts[0], Integer(parts[1], exception: false) || 0]
      end

      puts "  #{words.size} words"
      words
    end

    def build_bigrams(http:, tmp_dir:)
      puts "Building EN bigrams..."
      src = DictBuilder.download(SOURCES[:bigrams], File.join(tmp_dir, "en_bigrams.txt"), http: http)

      bigrams = []
      File.foreach(src, encoding: "utf-8") do |line|
        parts = line.strip.split(" ", 3)
        next unless parts.size == 3
        bigrams << [parts[0], parts[1], Integer(parts[2], exception: false) || 0]
      end

      puts "  #{bigrams.size} bigrams"
      bigrams
    end

    def freq_separator
      " "
    end
  end
end
