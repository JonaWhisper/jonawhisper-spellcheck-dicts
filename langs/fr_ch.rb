# frozen_string_literal: true

module Langs
  module FrCh
    # Swiss French — base FR dictionary + regional vocabulary.
    #
    # Sources:
    # - Usito (Université de Sherbrooke) — helvétismes index
    # - BDLP (Base de données lexicographiques panfrancophone)
    # - Dictionnaire suisse romand (A. Thibault & P. Knecht, Zoé, 2004)
    #
    # Words get high frequency so SymSpell won't "correct" them
    # into France-French equivalents.

    REGIONAL_WORDS = {
      # --- Nombres ---
      "septante" => 50_000,
      "huitante" => 50_000,    # 80 (Vaud, Valais, Fribourg)
      "nonante" => 50_000,

      # --- Repas (décalage systématique, comme en Belgique) ---
      "déjeuner" => 40_000,    # petit-déjeuner
      "dîner" => 40_000,       # repas de midi
      "souper" => 30_000,      # repas du soir
      "dix-heures" => 5_000,   # collation du matin
      "quatre-heures" => 5_000, # goûter

      # --- Technologie / quotidien ---
      "natel" => 20_000,       # téléphone portable
      "natels" => 8_000,
      "bancomat" => 8_000,     # distributeur de billets
      "automate" => 10_000,    # distributeur automatique

      # --- Alimentation ---
      "bircher" => 10_000,     # müesli
      "rösti" => 12_000,
      "fondue" => 20_000,
      "raclette" => 15_000,
      "cervelas" => 8_000,     # saucisse
      "bricelet" => 3_000,     # gaufrette croustillante
      "damassine" => 3_000,    # prune / eau-de-vie
      "herbettes" => 5_000,    # fines herbes
      "bénichon" => 5_000,     # fête automnale fribourgeoise
      "bouteille" => 15_000,   # aussi: biberon

      # --- Ménage / maison ---
      "panosse" => 8_000,      # serpillère
      "panosser" => 3_000,
      "lavette" => 5_000,      # carré de tissu
      "fourre" => 5_000,       # housse, étui
      "fourres" => 3_000,
      "cornet" => 8_000,       # sac plastique
      "cornets" => 5_000,
      "galetas" => 5_000,      # grenier
      "cheni" => 5_000,        # désordre, poussière
      "tablar" => 3_000,       # étagère
      "fourneau" => 8_000,     # cuisinière
      "potager" => 5_000,      # cuisinière (aussi)

      # --- Transport ---
      "pendulaire" => 8_000,   # navetteur
      "pendulaires" => 5_000,
      "giratoire" => 8_000,    # rond-point
      "berme" => 3_000,        # terre-plein d'autoroute
      "case postale" => 5_000, # boîte postale

      # --- Administration / politique ---
      "votation" => 15_000,    # vote populaire
      "votations" => 10_000,
      "initiative" => 20_000,  # initiative populaire
      "canton" => 25_000,
      "cantons" => 15_000,
      "cantonal" => 10_000,
      "cantonaux" => 8_000,
      "cantonale" => 8_000,
      "cantonales" => 5_000,
      "cantonaliser" => 3_000,
      "intercantonal" => 5_000,
      "communal" => 10_000,
      "communaux" => 5_000,
      "communale" => 8_000,
      "syndic" => 8_000,       # maire (Vaud)
      "municipal" => 10_000,
      "municipale" => 8_000,
      "district" => 10_000,
      "préfet" => 8_000,
      "assermentation" => 3_000, # prestation de serment

      # --- Éducation ---
      "maturité" => 12_000,    # baccalauréat
      "gymnase" => 10_000,     # lycée
      "gymnasien" => 5_000,
      "gymnasienne" => 5_000,
      "gymnasial" => 3_000,
      "apprenti" => 10_000,
      "apprentie" => 8_000,
      "apprentissage" => 15_000,
      "école enfantine" => 5_000, # maternelle
      "logopédiste" => 3_000,  # orthophoniste
      "doubler" => 5_000,      # redoubler

      # --- Nature / géographie ---
      "armailli" => 3_000,     # vacher d'alpage
      "inalpe" => 3_000,       # montée en alpage
      "désalpe" => 5_000,      # descente des alpages
      "bisse" => 5_000,        # canal d'irrigation (Valais)
      "gouille" => 3_000,      # flaque d'eau
      "châble" => 3_000,       # pente boisée
      "foyard" => 3_000,       # hêtre
      "mayens" => 3_000,       # pâturages de mi-saison

      # --- Expressions / divers ---
      "action" => 20_000,      # promotion (commerce)
      "direct" => 15_000,      # directement
      "cru" => 8_000,          # humide et froid (temps)
      "boquer" => 3_000,       # bouder
      "encoubler" => 3_000,    # embarrasser, trébucher
      "costume de bain" => 3_000, # maillot de bain
      "peser" => 8_000,        # appuyer (sur un bouton)
      "duvet" => 8_000,        # couette
      "imperdable" => 3_000,   # épingle de sûreté
      "carrousel" => 5_000,    # manège
      "fion" => 3_000,         # raillerie
      "gonfle" => 3_000,       # congère / embarras
    }.freeze

    module_function

    def build_freq(http:, tmp_dir:)
      fr_tmp = File.join(tmp_dir, "fr_base")
      FileUtils.mkdir_p(fr_tmp)
      words = Langs::Fr.base_words(http: http, tmp_dir: fr_tmp)

      REGIONAL_WORDS.each do |word, freq|
        words[word] = [words.fetch(word, 0), freq].max
      end

      puts "  Swiss FR: +#{REGIONAL_WORDS.size} regional words"
      words.sort_by { |_, freq| -freq }
    end

    def build_bigrams(http:, tmp_dir:)
      fr_tmp = File.join(tmp_dir, "fr_base")
      FileUtils.mkdir_p(fr_tmp)
      Langs::Fr.build_bigrams(http: http, tmp_dir: fr_tmp)
    end

    def freq_separator
      "\t"
    end
  end
end
