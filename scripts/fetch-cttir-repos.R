#!/usr/bin/env Rscript
# Refresh _data/cttir-repos.json from the live GitHub org inventory.
# Requires the `gh` CLI to be authenticated. Hard-fails on empty response.

out <- "_data/cttir-repos.json"
status <- system2(
  "gh",
  args = c("api", "/orgs/CTTIR/repos?per_page=100&type=public", "--paginate"),
  stdout = out,
  stderr = ""
)

if (status != 0L) {
  stop("gh api call failed (exit ", status, "). Refusing to overwrite ", out)
}

repos <- jsonlite::read_json(out, simplifyVector = FALSE)
if (!length(repos)) {
  stop("Inventory is empty — refusing to commit. Investigate gh auth and org visibility.")
}

cat(sprintf("Wrote %d repos to %s\n", length(repos), out))
