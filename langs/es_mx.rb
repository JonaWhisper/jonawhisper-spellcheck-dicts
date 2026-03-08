# frozen_string_literal: true

module Langs
  module EsMx
    # Mexican Spanish — base ES + regional words from data/es-mx.tsv

    module_function

    def label = "Espa\u00f1ol (M\u00e9xico)"

    def build_freq(http:, tmp_dir:)
      es_tmp = File.join(tmp_dir, "es_base")
      FileUtils.mkdir_p(es_tmp)
      words = Langs::Es.base_words(http: http, tmp_dir: es_tmp)
      added = DictBuilder.merge_regional!(words, "es-mx")
      puts "  Mexican ES: +#{added} regional words"
      words.sort_by { |_, freq| -freq }
    end

    def build_bigrams(http:, tmp_dir:)
      es_tmp = File.join(tmp_dir, "es_base")
      FileUtils.mkdir_p(es_tmp)
      Langs::Es.build_bigrams(http: http, tmp_dir: es_tmp)
    end

    def freq_separator = " "
  end
end
