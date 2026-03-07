# JonaWhisper Spellcheck Dictionaries

SymSpell frequency dictionaries for [JonaWhisper](https://github.com/jplot/jona-whisper) spell-checking.

## Structure

```
fr/
  freq.txt      # 645K French words (Lexique383 + DELA)
  bigram.txt    # 5K French bigrams (Google Books Ngram)
en/
  freq.txt      # 82K English words (SymSpell official)
  bigram.txt    # 242K English bigrams (SymSpell official)
```

## Format

- `freq.txt`: one word per line, `word<separator>frequency`
  - FR: tab-separated
  - EN: space-separated
- `bigram.txt`: `word1 word2<separator>frequency`

## Regeneration

Dictionaries can be regenerated using `scripts/build_symspell_dicts.py` in the main JonaWhisper repo.

## License

Dictionary data sourced from:
- **Lexique383** (Boris New & Christophe Pallier) — CC BY-SA 4.0
- **DELA** (LADL, Paris 7) — public domain linguistic resource
- **Google Books Ngram Corpus v3** — CC BY 3.0
- **SymSpell EN dictionaries** — MIT License
