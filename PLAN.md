# PLAN — CTTIR/ressources

## Decisions taken

- **Accent color:** `#2a6f8a` (teal-blue). Distinct from boulingua's accent; reads in light + dark.
- **Language:** English only. Documented divergence from boulingua (which is tri-lingual because it teaches three languages; CTIR's audience is the international scientific community).
- **License model:** code MIT; content CC BY-SA 4.0 (mirrors boulingua).
- **Citation style:** APA (CSL fetched at first build / committed manually).
- **Quarto pinned:** `1.5.57` in `.quarto-version`.
- **Deploy:** GitHub Pages from `gh-pages` branch via `quarto-actions/publish@v2`. Not enabled until first PR review.
- **Engine:** `freeze: true`; `cttir-packages.qmd` uses an R chunk that reads `_data/cttir-repos.json` — no API calls at render time.

## Inventory snapshot

19 repos pulled from `gh api /orgs/CTTIR/repos`. Of those:

- 14 R packages: `songR`, `bambamR`, `hexmakR`, `reflowR`, `molpathR`, `scimagR`, `segmantR`, `hyperspectR`, `cellreportR`, `libscanR`, `pressR`, `dynasimR`, `qviewparsR`, plus `courses` and `tutorials` (R-flavored content repos).
- 5 non-package repos excluded from `cttir-packages.qmd`: `pwa-quest`, `ressources` (this repo), `website`, `.github`. `courses` and `tutorials` are surfaced separately in the Ressources index.
- License field is `NOASSERTION` for most R packages — likely missing SPDX-detected `LICENSE` files or non-standard layout. **Flagged for Raban:** decide on a single license per package and ensure GitHub auto-detects it (add `License:` field in `DESCRIPTION` plus a top-level `LICENSE` file with the standard SPDX text).
- Eight R packages have no `description` field on GitHub (`scimagR`, `segmantR`, `hyperspectR`, `cellreportR`, `libscanR`, `pressR`, `dynasimR`). The `cttir-packages.qmd` table renders these with a `—` and tags them with a build-time warning. **Flagged:** add GitHub repo descriptions.

## Deferred items requiring Raban's review

### Personal / legal metadata (block deploy)

These are marked `TODO_IMPRESSUM` or `TODO_FILL_BEFORE_DEPLOY` and the CI gate fails until filled:

- `impressum.qmd` — name, postal address, email, ORCID, affiliation
- `privacy.qmd` — contact email for data requests
- `about.qmd` — editor name + ORCID
- `acknowledgements.qmd` — funders, collaborators

### References sections (citation integrity gate)

The brief mandates DOI verification before commit. I have **not** populated `references.bib` beyond a small skeleton of book references that don't need DOI verification (Wickham *R Packages* 2nd ed., R Core Team manual). All other references are deferred and the topic pages carry `TODO_FILL_BEFORE_DEPLOY` markers:

- `references/dimensionality-reduction.qmd` — needs SONG paper, UMAP (McInnes 2018), t-SNE (van der Maaten 2008), PHATE (Moon 2019), PCA classics
- `references/rna-seq-and-bulk-omics.qmd` — STAR, salmon, DESeq2 (Love 2014), edgeR (Robinson 2010), limma-voom (Law 2014)
- `references/single-cell-and-cell-reports.qmd` — Seurat, scran, scater, SingleCellExperiment
- `references/molecular-pathology.qmd` — VCF spec, GATK best practices, ClinVar, OncoKB
- `references/r-package-development.qmd` — Wickham *R Packages*, pkgdown, roxygen2, testthat
- `references/reproducible-research.qmd` — Marwick et al. on research compendia, targets paper, Quarto
- `references/trauma-biomarkers.qmd` — domain-specific reading list (PubMed search needed)
- `references/tissue-injury.qmd` — domain-specific reading list

**Process for filling:** for each entry, resolve DOI via `https://doi.org/<doi>`, confirm authors/year, add to `references.bib`, drop the `TODO_FILL_BEFORE_DEPLOY` marker on the page. The CI `verify-dois` job re-runs on every push and will catch any unresolvable DOI.

### CTTIR package CITATION/DESCRIPTION mining

I did **not** clone each package and mine `inst/CITATION` / `DESCRIPTION` references — that requires per-repo cloning and would 10× the scope. Deferred to a follow-up pass. Recommended approach when Raban is ready:

```r
# scripts/mine-package-citations.R
for (repo in repos) {
  gh::gh("/repos/CTTIR/{repo}/contents/inst/CITATION", repo = repo) |>
    parse_citation() |> append_to_bib()
}
```

### Ressources content — verification status

Every entry in the `ressources/*.qmd` pages points to a canonical project URL (e.g. `https://bioconductor.org`, `https://www.tidyverse.org`). These are stable and well-known. The CI link checker will flag anything broken on first run. No `[unverified]` markers were needed.

## Divergences from boulingua

1. **Monolingual** (English) — see top of file.
2. **Accent color** — `#2a6f8a` instead of boulingua's accent.
3. **Section: cttir-packages** — boulingua has no analogue; this is a CTIR-specific page generated from the repo inventory.
4. **References section** — boulingua has none; CTIR's research-hub identity makes a curated bibliography load-bearing.

## Expected first-build state

Locally `quarto render` should succeed. CI will **fail intentionally** on:

- TODO-marker check (Impressum / Privacy / About / Acknowledgements / References)
- Possibly DOI check if any DOIs are added before verification — currently bib is minimal

This is the documented expected state until Raban fills placeholders.
