# frozen_string_literal: true

module Langs
  module EnGb
    # British English — base EN + British spellings from data/en-gb.tsv

    module_function

    def build_freq(http:, tmp_dir:)
      en_tmp = File.join(tmp_dir, "en_base")
      FileUtils.mkdir_p(en_tmp)
      words = Langs::En.base_words(http: http, tmp_dir: en_tmp)
      added = DictBuilder.merge_regional!(words, "en-gb")
      puts "  British EN: +#{added} regional spellings"
      words.sort_by { |_, freq| -freq }
    end

    def build_bigrams(http:, tmp_dir:)
      en_tmp = File.join(tmp_dir, "en_base")
      FileUtils.mkdir_p(en_tmp)
      Langs::En.build_bigrams(http: http, tmp_dir: en_tmp)
    end

    def freq_separator = " "
  end
end
