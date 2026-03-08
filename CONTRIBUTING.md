# Contributing

## Commits

This project uses [Conventional Commits](https://www.conventionalcommits.org/).

Format: `type(scope): description`

### Types

- `feat` — New language, new data source, new feature
- `fix` — Bug fix
- `refactor` — Code restructuring
- `chore` — Dependencies, CI, maintenance
- `docs` — Documentation only

### Scopes

- `lang` — Language modules (`langs/*.rb`)
- `data` — Regional data files (`data/*.tsv`)
- `ci` — GitHub Actions workflows
- `build` — Build script (`build_dicts.rb`)

### Examples

```
feat(lang): add German spellcheck dictionary
feat(data): add Swiss French regional words
fix(build): handle encoding errors in Leipzig corpus
chore(ci): update Ruby version
docs: update README with new language
```

## Pull Requests

- One language/fix per PR
- PR title follows conventional commit format
- Test locally before opening: `ruby build_dicts.rb`

## Adding a New Base Language

1. Create `langs/xx.rb` implementing:
   - `label` — Display name
   - `base_words(http:, tmp_dir:)` — Returns `{word => freq}` hash
   - `build_freq(http:, tmp_dir:)` — Returns sorted `[[word, freq], ...]`
   - `build_bigrams(http:, tmp_dir:)` — Returns `[[w1, w2, freq], ...]`
   - `freq_separator` — Column separator (tab or space)
2. Test: `bundle exec ruby build_dicts.rb` (languages are auto-discovered from `langs/`)

## Adding a Regional Variant

1. Create `data/xx-yy.tsv` (word/frequency/definition columns)
2. Create `langs/xx_yy.rb` inheriting from the base language
3. Test: `ruby build_dicts.rb`

## Development

```bash
bundle install
ruby build_dicts.rb
```
