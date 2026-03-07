# frozen_string_literal: true

module Langs
  module FrCa
    # Quebec French — base FR + regional words from data/fr-ca.tsv

    module_function

    def label = "Fran\u00e7ais (Qu\u00e9bec)"
    def ram = 100_000_000

    def build_freq(http:, tmp_dir:)
      fr_tmp = File.join(tmp_dir, "fr_base")
      FileUtils.mkdir_p(fr_tmp)
      words = Langs::Fr.base_words(http: http, tmp_dir: fr_tmp)
      added = DictBuilder.merge_regional!(words, "fr-ca")
      puts "  Quebec FR: +#{added} regional words"
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
