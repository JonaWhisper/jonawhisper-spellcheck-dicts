# frozen_string_literal: true

module Langs
  module PtBr
    # Brazilian Portuguese — base PT + regional words from data/pt-br.tsv

    module_function

    def label = "Portugu\u00eas (Brasil)"

    def build_freq(http:, tmp_dir:)
      pt_tmp = File.join(tmp_dir, "pt_base")
      FileUtils.mkdir_p(pt_tmp)
      words = Langs::Pt.base_words(http: http, tmp_dir: pt_tmp)
      added = DictBuilder.merge_regional!(words, "pt-br")
      puts "  Brazilian PT: +#{added} regional words"
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
