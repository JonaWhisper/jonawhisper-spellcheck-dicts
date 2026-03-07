# JonaWhisper Spellcheck Dictionaries

SymSpell frequency dictionaries for [JonaWhisper](https://github.com/jplot/jona-whisper) spell-checking.

Published as **GitHub Release assets** — the repo contains only the build tooling.

## Download

Latest dictionaries are always available at:

```
https://github.com/JonaWhisper/jonawhisper-spellcheck-dicts/releases/latest/download/fr-freq.txt
https://github.com/JonaWhisper/jonawhisper-spellcheck-dicts/releases/latest/download/fr-bigram.txt
https://github.com/JonaWhisper/jonawhisper-spellcheck-dicts/releases/latest/download/en-freq.txt
https://github.com/JonaWhisper/jonawhisper-spellcheck-dicts/releases/latest/download/en-bigram.txt
https://github.com/JonaWhisper/jonawhisper-spellcheck-dicts/releases/latest/download/manifest.json
```

## File format

- `<lang>-freq.txt`: one word per line, `word<separator>frequency`
  - FR: tab-separated
  - EN: space-separated
- `<lang>-bigram.txt`: `word1 word2 frequency` (space-separated)
- `manifest.json`: checksums, sizes, and entry counts per file

## Building locally

```bash
bundle install
bundle exec ruby build_dicts.rb
# Output in output/
```

## Adding a language

1. Create `langs/<code>.rb` implementing `build_freq`, `build_bigrams`, `freq_separator`
2. Run `bundle exec ruby build_dicts.rb`
3. Add the model entry in `jona-engine-spellcheck` (Rust crate in the main repo)

## CI

A GitHub Actions workflow runs monthly and on manual dispatch.
It rebuilds all dictionaries, compares with the latest release, and publishes a new versioned release if anything changed.

## Sources

- **Lexique383** (Boris New & Christophe Pallier) — CC BY-SA 4.0
- **DELA** (LADL, Paris 7) — public domain linguistic resource
- **Google Books Ngram Corpus v3** — CC BY 3.0
- **SymSpell EN dictionaries** — MIT License
