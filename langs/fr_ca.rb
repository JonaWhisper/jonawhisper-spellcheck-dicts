# frozen_string_literal: true

module Langs
  module FrCa
    # Quebec French — base FR dictionary + regional vocabulary.
    #
    # Sources:
    # - Usito (Université de Sherbrooke) — québécismes index
    # - OQLF (Office québécois de la langue française)
    #
    # Words get high frequency so SymSpell won't "correct" them
    # into France-French equivalents.

    REGIONAL_WORDS = {
      # --- Transport ---
      "char" => 40_000,
      "chars" => 20_000,
      "bazou" => 5_000,
      "autobus" => 25_000,
      "stationnement" => 20_000,
      "parcomètre" => 5_000,
      "robeur" => 3_000,        # pneu

      # --- Commerce / vie quotidienne ---
      "magasiner" => 20_000,
      "magasinage" => 15_000,
      "dépanneur" => 15_000,
      "dépanneurs" => 8_000,
      "breuvage" => 10_000,
      "breuvages" => 5_000,
      "liqueur" => 12_000,      # boisson gazeuse
      "cégep" => 15_000,
      "cégeps" => 8_000,
      "cégépien" => 5_000,
      "cégépienne" => 5_000,
      "polyvalente" => 10_000,
      "tuque" => 10_000,
      "tuques" => 5_000,
      "mitaines" => 8_000,
      "espadrilles" => 8_000,   # baskets
      "bobettes" => 5_000,      # sous-vêtements
      "laveuse" => 8_000,       # machine à laver
      "sécheuse" => 8_000,      # sèche-linge
      "champlure" => 3_000,     # robinet
      "débarbouillette" => 5_000, # gant de toilette

      # --- Personnes / relations ---
      "blonde" => 25_000,       # copine
      "chum" => 20_000,         # copain
      "chums" => 10_000,

      # --- Météo / nature ---
      "poudrerie" => 8_000,
      "sloche" => 5_000,        # gadoue
      "frette" => 10_000,       # très froid
      "bordée" => 8_000,        # chute de neige
      "banc de neige" => 5_000,
      "caribou" => 10_000,
      "achigan" => 5_000,       # perche noire
      "ouananiche" => 5_000,    # saumon d'eau douce
      "orignal" => 10_000,
      "maringouins" => 8_000,   # moustiques
      "maringouin" => 8_000,

      # --- Alimentation ---
      "poutine" => 20_000,
      "poutines" => 8_000,
      "pogos" => 5_000,
      "tourtière" => 10_000,
      "cipaille" => 5_000,
      "cipâte" => 3_000,
      "pâté chinois" => 8_000,
      "binnes" => 5_000,        # fèves au lard
      "bleuets" => 10_000,      # myrtilles
      "bleuet" => 8_000,
      "atoca" => 3_000,         # canneberge
      "guédille" => 5_000,
      "croquignole" => 3_000,
      "tire" => 8_000,          # tire d'érable
      "cabane à sucre" => 8_000,
      "sirop d'érable" => 10_000,
      "pinottes" => 5_000,      # cacahuètes
      "pinotte" => 5_000,

      # --- Verbes / expressions courantes ---
      "achaler" => 8_000,       # embêter
      "achalant" => 5_000,
      "achalandé" => 8_000,     # fréquenté
      "achalandage" => 5_000,
      "pogner" => 8_000,
      "jaser" => 10_000,
      "gosser" => 5_000,
      "niaiser" => 8_000,
      "niaiseux" => 5_000,
      "niaiseuse" => 5_000,
      "niaiserie" => 5_000,
      "tannant" => 5_000,
      "tanné" => 8_000,
      "barrer" => 8_000,        # verrouiller
      "débarrer" => 5_000,
      "embarquer" => 10_000,
      "débarquer" => 8_000,
      "placoter" => 5_000,
      "placotage" => 3_000,
      "maganer" => 5_000,       # abîmer
      "maganage" => 3_000,
      "chialer" => 8_000,       # râler
      "chialage" => 3_000,
      "chialeux" => 3_000,
      "écœurant" => 8_000,      # extraordinaire ou dégoûtant
      "abrier" => 3_000,        # couvrir
      "caler" => 5_000,         # enfoncer
      "clairer" => 3_000,       # vider, congédier
      "décrisser" => 3_000,     # partir
      "enfirouaper" => 3_000,   # embobiner
      "enfarger" => 3_000,      # trébucher
      "garrocher" => 5_000,     # lancer
      "paqueter" => 3_000,      # emballer
      "pelleter" => 5_000,      # déneiger
      "chauffer" => 8_000,      # conduire

      # --- Habitation / bâtiment ---
      "appartement" => 15_000,
      "bloc appartements" => 3_000,
      "duplex" => 8_000,
      "triplex" => 5_000,
      "sous-sol" => 10_000,
      "perron" => 5_000,
      "galerie" => 10_000,      # balcon, véranda
      "cabanon" => 5_000,       # abri de jardin

      # --- Administration / société ---
      "arrondissement" => 15_000,
      "CLSC" => 5_000,
      "garderie" => 10_000,
      "CPE" => 8_000,
      "préposé" => 8_000,
      "préposée" => 8_000,
      "courriel" => 15_000,     # e-mail (terme officiel OQLF)
      "courriels" => 8_000,
      "clavardage" => 8_000,    # chat en ligne
      "clavarder" => 5_000,
      "pourriel" => 5_000,      # spam
      "baladodiffusion" => 3_000, # podcast
      "téléroman" => 5_000,

      # --- Jurons (fréquents à l'oral, importants pour la dictée) ---
      "tabarnak" => 10_000,
      "câlice" => 8_000,
      "crisse" => 8_000,
      "ostie" => 8_000,
      "tabarnouche" => 3_000,

      # --- Divers ---
      "vidanges" => 8_000,      # poubelles/ordures
      "foufounes" => 3_000,     # fesses
      "bécosses" => 3_000,      # toilettes
      "siffleux" => 3_000,      # marmotte
      "draveur" => 3_000,       # flotteur de bois
      "motoneige" => 8_000,
      "motoneiges" => 5_000,
      "raquettes" => 8_000,
      "cabane" => 8_000,
      "érablière" => 5_000,
      "acériculture" => 3_000,
      "acériculteur" => 3_000,
    }.freeze

    module_function

    def build_freq(http:, tmp_dir:)
      fr_tmp = File.join(tmp_dir, "fr_base")
      FileUtils.mkdir_p(fr_tmp)
      words = Langs::Fr.base_words(http: http, tmp_dir: fr_tmp)

      REGIONAL_WORDS.each do |word, freq|
        words[word] = [words.fetch(word, 0), freq].max
      end

      puts "  Quebec FR: +#{REGIONAL_WORDS.size} regional words"
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
