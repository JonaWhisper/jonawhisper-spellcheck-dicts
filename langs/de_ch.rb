# frozen_string_literal: true

module Langs
  module DeCh
    # Swiss German (written standard) — base DE + regional words from data/de-ch.tsv

    module_function

    def label = "Deutsch (Schweiz)"

    def build_freq(http:, tmp_dir:)
      de_tmp = File.join(tmp_dir, "de_base")
      FileUtils.mkdir_p(de_tmp)
      words = Langs::De.base_words(http: http, tmp_dir: de_tmp)
      added = DictBuilder.merge_regional!(words, "de-ch")
      puts "  Swiss DE: +#{added} regional words"
      words.sort_by { |_, freq| -freq }
    end

    def build_bigrams(http:, tmp_dir:)
      de_tmp = File.join(tmp_dir, "de_base")
      FileUtils.mkdir_p(de_tmp)
      Langs::De.build_bigrams(http: http, tmp_dir: de_tmp)
    end

    def freq_separator = " "
  end
end
