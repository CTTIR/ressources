# CTIR / ressources

A curated, hand-picked hub of computational biomedical research resources for **CTIR — Computational Trauma and Tissue Injury Research** (GitHub org: `CTTIR`). Built with Quarto, deployed at <https://cttir.github.io/ressources/>.

## What this is

- A single source of truth for "where do I find a good R package / dataset / paper for X" within the CTIR scope.
- Editorially reviewed, not auto-aggregated. Every entry was selected on purpose.
- Static site: no analytics, no cookies, no tracking.

## Building locally

Prerequisites:

- [Quarto](https://quarto.org/) `1.5.57` (pinned in `.quarto-version`)
- R `4.4+` with `jsonlite`, `knitr`, `rmarkdown`

```sh
quarto render
quarto preview
```

## Refreshing the CTIR package inventory

The list on `ressources/cttir-packages.qmd` is generated from `_data/cttir-repos.json`, which is fetched from the live GitHub API. To refresh it (CI also enforces a 30-day freshness limit):

```sh
Rscript scripts/fetch-cttir-repos.R
git add _data/cttir-repos.json
git commit -m "refresh CTIR package inventory"
```

## CI gates

Every PR runs:

1. **render-check** — `quarto render` must succeed; warnings fail the job.
2. **todo-marker-check** — fails if any `TODO_IMPRESSUM` or `TODO_FILL_BEFORE_DEPLOY` marker remains. This is intentional: the site cannot deploy with placeholder legal metadata or unverified citations.
3. **link-check** — every external link must resolve. Allowlist exceptions go in `.lycheeignore` with a comment explaining why.
4. **doi-verify** — every DOI in `references.bib` must resolve via `https://doi.org/<doi>`.
5. **blocklist-check** — commercial / paywalled URLs forbidden in `ressources/*.qmd` (see `_data/blocklist.txt`).
6. **inventory-freshness** — `_data/cttir-repos.json` must be ≤ 30 days old in git history.

## Deployment

Pages serves from the `gh-pages` branch, populated by `quarto-actions/publish@v2` on push to `main`. Configure once, in repo Settings → Pages → Source: `Deploy from a branch` → `gh-pages` → `/ (root)`.

Custom domain is unconfigured. To add one later: drop a `CNAME` file at the repo root containing the domain, configure DNS, and Pages will pick it up.

## Repository layout

See `PLAN.md` for the directory tour, deferred-items list, and design decisions.

## License

- Code (scripts, configuration, the build itself) — [MIT](LICENSE).
- Editorial content (text in `*.qmd` files) — [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/).
