# frozen_string_literal: true

module Langs
  module NlBe
    # Belgian Dutch (Flemish) — base NL + regional words from data/nl-be.tsv

    module_function

    def label = "Nederlands (Belgi\u00eb)"

    def build_freq(http:, tmp_dir:)
      nl_tmp = File.join(tmp_dir, "nl_base")
      FileUtils.mkdir_p(nl_tmp)
      words = Langs::Nl.base_words(http: http, tmp_dir: nl_tmp)
      added = DictBuilder.merge_regional!(words, "nl-be")
      puts "  Belgian NL: +#{added} regional words"
      words.sort_by { |_, freq| -freq }
    end

    def build_bigrams(http:, tmp_dir:)
      nl_tmp = File.join(tmp_dir, "nl_base")
      FileUtils.mkdir_p(nl_tmp)
      Langs::Nl.build_bigrams(http: http, tmp_dir: nl_tmp)
    end

    def freq_separator = " "
  end
end
