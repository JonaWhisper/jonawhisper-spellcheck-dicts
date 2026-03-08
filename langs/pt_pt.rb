# frozen_string_literal: true

module Langs
  module PtPt
    # European Portuguese — base PT + regional words from data/pt-pt.tsv

    module_function

    def label = "Portugu\u00eas (Portugal)"

    def build_freq(http:, tmp_dir:)
      pt_tmp = File.join(tmp_dir, "pt_base")
      FileUtils.mkdir_p(pt_tmp)
      words = Langs::Pt.base_words(http: http, tmp_dir: pt_tmp)
      added = DictBuilder.merge_regional!(words, "pt-pt")
      puts "  European PT: +#{added} regional words"
      words.sort_by { |_, freq| -freq }
    end

    def build_bigrams(http:, tmp_dir:)
      pt_tmp = File.join(tmp_dir, "pt_base")
      FileUtils.mkdir_p(pt_tmp)
      Langs::Pt.build_bigrams(http: http, tmp_dir: pt_tmp)
    end

    def freq_separator = " "
  end
end
