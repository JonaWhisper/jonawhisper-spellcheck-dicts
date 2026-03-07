# Regional word lists

TSV files with regional vocabulary that gets merged into the base language dictionary.

## Format

```
word<TAB>frequency<TAB>definition
```

- **word**: the regional word (lowercase)
- **frequency**: relative frequency weight (see scale below)
- **definition**: short definition explaining the word

### Frequency scale

| Value | Meaning | Example |
|-------|---------|---------|
| 50000 | Very common, daily use | septante, nonante |
| 20000 | Common, known by all speakers | natel, poutine |
| 10000 | Regular use | chicon, achaler |
| 5000  | Frequent in certain contexts | guindaille, cipaille |
| 3000  | Known by most speakers | babelute, armailli |

Words already present in the base dictionary get their frequency boosted to this value if it's higher. New words are added directly.

## Contributing

To add a word: edit the TSV file, add a row with `word<TAB>frequency<TAB>definition`.

To add a new regional variant: create a new `<lang-code>.tsv` file (e.g. `fr-af.tsv` for African French), then create the corresponding `langs/<lang_code>.rb` module.

## Sources

### fr-be (Belgian French)
- Dictionnaire des belgicismes (Michel Francard, De Boeck, 2010)
- Base de données lexicographiques panfrancophone (BDLP)
- Académie royale de langue et de littérature françaises de Belgique

### fr-ca (Quebec French)
- Usito, dictionnaire en ligne (Université de Sherbrooke)
- Office québécois de la langue française (OQLF)
- Base de données lexicographiques panfrancophone (BDLP)

### fr-ch (Swiss French)
- Usito, dictionnaire en ligne (Université de Sherbrooke) — index des helvétismes
- Dictionnaire suisse romand (André Thibault & Pierre Knecht, Éditions Zoé, 2004)
- Base de données lexicographiques panfrancophone (BDLP)

### en-gb (British English)
- Oxford English Dictionary — systematic spelling patterns (-our/-or, -ise/-ize, -re/-er, -ence/-ense, etc.)
- Cambridge Dictionary — British vs American usage
