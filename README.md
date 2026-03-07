# JonaWhisper Spellcheck Dictionaries

SymSpell frequency dictionaries for [JonaWhisper](https://github.com/jplot/jona-whisper) spell-checking.

Published as **GitHub Release assets** — the repo contains only the build tooling and regional word lists.

## Available dictionaries

| Code | Language | Base source | Regional words |
|------|----------|-------------|----------------|
| `fr` | Français | Lexique383 + DELA | — |
| `fr-be` | Français (Belgique) | Lexique383 + DELA | ~80 belgicismes |
| `fr-ca` | Français (Québec) | Lexique383 + DELA | ~120 québécismes |
| `fr-ch` | Français (Suisse) | Lexique383 + DELA | ~90 helvétismes |
| `en` | English | SymSpell corpus | — |
| `en-gb` | English (British) | SymSpell corpus | ~230 British spellings |

Regional dictionaries inherit all words from their base language and boost regional vocabulary so that SymSpell doesn't "correct" local words into another variant (e.g. _colour_ → _color_, _septante_ → _soixante-dix_).

## Download

Latest dictionaries are always available at:

```
https://github.com/JonaWhisper/jonawhisper-spellcheck-dicts/releases/latest/download/<code>-freq.txt
https://github.com/JonaWhisper/jonawhisper-spellcheck-dicts/releases/latest/download/<code>-bigram.txt
https://github.com/JonaWhisper/jonawhisper-spellcheck-dicts/releases/latest/download/manifest.json
```

## File format

- `<code>-freq.txt`: one word per line, `word<separator>frequency`
  - FR variants: tab-separated
  - EN variants: space-separated
- `<code>-bigram.txt`: `word1 word2 frequency` (space-separated)
- `manifest.json`: SHA256 checksums, sizes, and entry counts per file

## Project structure

```
langs/          Ruby modules — one per dictionary (build logic)
data/           TSV files — regional word lists (word + frequency + definition)
output/         Generated dictionaries (not tracked, published as releases)
build_dicts.rb  Orchestrator script
```

## Building locally

```bash
bundle install
bundle exec ruby build_dicts.rb
# Output in output/
```

## Adding a regional variant

1. Create `data/<code>.tsv` with regional words (see [`data/README.md`](data/README.md) for format)
2. Create `langs/<code>.rb` inheriting from the base language (see existing variants for examples)
3. Run `bundle exec ruby build_dicts.rb`
4. Add a `spellcheck:<code>` model in `jona-engine-spellcheck` (Rust crate in the main repo)

## Adding a new base language

1. Create `langs/<code>.rb` implementing `build_freq`, `build_bigrams`, `freq_separator`
2. Expose a `base_words` method if regional variants are expected
3. Run `bundle exec ruby build_dicts.rb`
4. Add a `spellcheck:<code>` model in `jona-engine-spellcheck`

## CI

A GitHub Actions workflow runs monthly and on manual dispatch.
It rebuilds all dictionaries, compares the manifest with the latest release, and publishes a new versioned release if anything changed.

## Sources

### Base dictionaries
- **Lexique383** (Boris New & Christophe Pallier) — CC BY-SA 4.0
- **DELA** (LADL, Paris 7) — public domain linguistic resource
- **Google Books Ngram Corpus v3** — CC BY 3.0
- **SymSpell EN dictionaries** (Wolf Garbe) — MIT License

### Regional word lists
- **Usito** (Université de Sherbrooke) — québécismes and helvétismes indexes
- **OQLF** (Office québécois de la langue française)
- **BDLP** (Base de données lexicographiques panfrancophone)
- **Dictionnaire des belgicismes** (Michel Francard, De Boeck, 2010)
- **Dictionnaire suisse romand** (André Thibault & Pierre Knecht, Éditions Zoé, 2004)
- **Académie royale de langue et de littérature françaises de Belgique**
- **Oxford English Dictionary** — British vs American spelling patterns
