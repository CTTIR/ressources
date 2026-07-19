#!/usr/bin/env Rscript
# Refresh _data/cttir-repos.json from the live GitHub org inventory.
# Requires the `gh` CLI to be authenticated. Hard-fails on empty response.

out <- "_data/cttir-repos.json"

# shQuote the endpoint: system2() evaluates the command line via /bin/sh, so the
# '&' in the query string must not reach the shell unescaped. Capture the
# response in R and only write it out after validation, so a failed or empty
# call never truncates the existing inventory.
res <- system2(
  "gh",
  args = c("api", shQuote("/orgs/CTTIR/repos?per_page=100&type=public"), "--paginate"),
  stdout = TRUE,
  stderr = ""
)

status <- attr(res, "status")
if (!is.null(status) && status != 0L) {
  stop("gh api call failed (exit ", status, "). Refusing to overwrite ", out)
}

repos <- jsonlite::fromJSON(paste(res, collapse = "\n"), simplifyVector = FALSE)
if (!length(repos)) {
  stop("Inventory is empty — refusing to commit. Investigate gh auth and org visibility.")
}

cat(res, file = out, sep = "\n")
cat(sprintf("Wrote %d repos to %s\n", length(repos), out))
