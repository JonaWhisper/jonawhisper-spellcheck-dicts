# frozen_string_literal: true

module Langs
  module FrBe
    # Belgian French — base FR dictionary + regional vocabulary.
    #
    # Sources:
    # - Académie royale de langue et de littérature françaises de Belgique
    # - Dictionnaire des belgicismes (M. Francard, 2010, De Boeck)
    # - BDLP (Base de données lexicographiques panfrancophone)
    #
    # Words get high frequency so SymSpell won't "correct" them
    # into France-French equivalents.

    REGIONAL_WORDS = {
      # --- Nombres ---
      "septante" => 50_000,
      "nonante" => 50_000,

      # --- Repas (décalage systématique) ---
      "déjeuner" => 40_000,    # petit-déjeuner
      "dîner" => 40_000,       # repas de midi
      "souper" => 30_000,      # repas du soir

      # --- Alimentation ---
      "couque" => 8_000,       # viennoiserie
      "praline" => 15_000,     # chocolat (bonbon en France)
      "pralines" => 10_000,
      "spéculoos" => 12_000,
      "babelute" => 3_000,     # caramel
      "crotte" => 8_000,       # truffe en chocolat
      "pistolet" => 10_000,    # petit pain rond
      "pistolets" => 5_000,
      "chicon" => 8_000,       # endive
      "chicons" => 5_000,
      "caricole" => 3_000,     # escargot de mer
      "filet américain" => 5_000, # steak tartare
      "stoemp" => 5_000,       # purée avec légumes
      "waterzooi" => 5_000,
      "fricadelle" => 5_000,
      "boulet" => 8_000,       # boulette de viande liégeoise
      "jatte" => 5_000,        # bol, tasse
      "rawette" => 3_000,      # petite portion en plus

      # --- Ménage / maison ---
      "drache" => 10_000,      # forte pluie
      "dracher" => 5_000,
      "essuie" => 10_000,      # serviette
      "essuies" => 5_000,
      "torchon" => 8_000,      # serpillère
      "lavette" => 5_000,      # carré de tissu humide
      "loque" => 5_000,        # serpillère
      "loquer" => 3_000,
      "wassingue" => 3_000,    # serpillère (nord)
      "ramassette" => 3_000,   # pelle à poussière
      "balayette" => 5_000,
      "frigolite" => 5_000,    # polystyrène
      "clenche" => 3_000,      # poignée de porte

      # --- Vie étudiante ---
      "kot" => 15_000,         # chambre d'étudiant
      "koter" => 5_000,
      "koteur" => 3_000,
      "koteuse" => 3_000,
      "guindaille" => 5_000,   # fête étudiante
      "guindailler" => 3_000,
      "blocus" => 8_000,       # période de révisions
      "bloquer" => 8_000,      # réviser intensivement
      "buser" => 5_000,        # rater un examen
      "bisser" => 5_000,       # redoubler

      # --- Administration / politique ---
      "bourgmestre" => 15_000, # maire
      "échevin" => 10_000,     # adjoint au maire
      "échevine" => 5_000,
      "échevinal" => 3_000,
      "échevinat" => 5_000,
      "athénée" => 10_000,     # lycée
      "communal" => 10_000,
      "communale" => 8_000,
      "province" => 15_000,
      "provincial" => 10_000,

      # --- Transport ---
      "aubette" => 5_000,      # abribus
      "ring" => 10_000,        # périphérique
      "navetteur" => 5_000,    # pendulaire
      "navetteurs" => 5_000,
      "navette" => 10_000,
      "bande de circulation" => 3_000, # voie

      # --- Vêtements / corps ---
      "tirette" => 5_000,      # fermeture éclair
      "brayette" => 3_000,     # braguette
      "slaches" => 3_000,      # tongs
      "cloche" => 5_000,       # ampoule (peau)

      # --- Papeterie / école ---
      "farde" => 8_000,        # classeur
      "fardes" => 5_000,
      "bic" => 10_000,         # stylo à bille
      "bics" => 5_000,
      "papier-collant" => 3_000, # scotch
      "plasticine" => 3_000,   # pâte à modeler
      "plumier" => 5_000,      # trousse
      "rhétorique" => 5_000,   # terminale

      # --- Argent / commerce ---
      "dringuelle" => 3_000,   # pourboire
      "souche" => 5_000,       # ticket de caisse

      # --- Divers ---
      "sacoche" => 10_000,     # sac à main
      "tantôt" => 15_000,      # cet après-midi / tout à l'heure
      "carabistouille" => 3_000, # bêtise
      "carabistouilles" => 3_000,
      "cumulet" => 3_000,      # galipette
      "ducasse" => 5_000,      # fête foraine
      "kermesse" => 8_000,
      "barakî" => 3_000,       # personne rustre
      "craboutchas" => 3_000,  # gribouillage
    }.freeze

    module_function

    def build_freq(http:, tmp_dir:)
      fr_tmp = File.join(tmp_dir, "fr_base")
      FileUtils.mkdir_p(fr_tmp)
      words = Langs::Fr.base_words(http: http, tmp_dir: fr_tmp)

      REGIONAL_WORDS.each do |word, freq|
        words[word] = [words.fetch(word, 0), freq].max
      end

      puts "  Belgian FR: +#{REGIONAL_WORDS.size} regional words"
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
