# frozen_string_literal: true

module Langs
  module FrCh
    # Swiss French — base FR + regional words from data/fr-ch.tsv

    module_function

    def label = "Fran\u00e7ais (Suisse)"

    def build_freq(http:, tmp_dir:)
      fr_tmp = File.join(tmp_dir, "fr_base")
      FileUtils.mkdir_p(fr_tmp)
      words = Langs::Fr.base_words(http: http, tmp_dir: fr_tmp)
      added = DictBuilder.merge_regional!(words, "fr-ch")
      puts "  Swiss FR: +#{added} regional words"
      words.sort_by { |_, freq| -freq }
    end

    def build_bigrams(http:, tmp_dir:)
      fr_tmp = File.join(tmp_dir, "fr_base")
      FileUtils.mkdir_p(fr_tmp)
      Langs::Fr.build_bigrams(http: http, tmp_dir: fr_tmp)
    end

    def freq_separator = "\t"
  end
end
