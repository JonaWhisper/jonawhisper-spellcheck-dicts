# JonaWhisper Spellcheck Dictionaries

SymSpell frequency dictionaries for [JonaWhisper](https://github.com/jplot/jona-whisper) spell-checking.

## Structure

```
fr/
  freq.txt        # 645K French words (Lexique383 + DELA)
  bigram.txt      # 5K French bigrams (Google Books Ngram)
en/
  freq.txt        # 82K English words (SymSpell official)
  bigram.txt      # 242K English bigrams (SymSpell official)
langs/
  fr.rb           # French sources and build logic
  en.rb           # English sources and build logic
build_dicts.rb    # Orchestrator — auto-discovers langs/*.rb
Gemfile           # Ruby dependencies (Faraday, rubyzip, csv)
```

## Format

- `freq.txt`: one word per line, `word<separator>frequency`
  - FR: tab-separated
  - EN: space-separated
- `bigram.txt`: `word1 word2 frequency` (space-separated)

## Building

```bash
bundle install
bundle exec ruby build_dicts.rb
```

Set `DICT_CACHE_DIR` to persist downloaded sources between runs:

```bash
DICT_CACHE_DIR=/tmp/dict-cache bundle exec ruby build_dicts.rb
```

## Adding a language

1. Create `langs/<code>.rb` implementing `build_freq`, `build_bigrams`, `freq_separator`
2. Create the `<code>/` output directory (auto-created on build)
3. Run `bundle exec ruby build_dicts.rb`
4. Add the model entry in `jona-engine-spellcheck` (Rust crate)

## CI

A GitHub Actions workflow runs monthly (first Monday) and on manual dispatch.
It rebuilds all dictionaries and commits if anything changed.

## License

Dictionary data sourced from:
- **Lexique383** (Boris New & Christophe Pallier) \u2014 CC BY-SA 4.0
- **DELA** (LADL, Paris 7) \u2014 public domain linguistic resource
- **Google Books Ngram Corpus v3** \u2014 CC BY 3.0
- **SymSpell EN dictionaries** \u2014 MIT License
