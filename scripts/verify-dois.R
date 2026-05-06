#!/usr/bin/env Rscript
# Verify that every DOI in references.bib resolves via https://doi.org/<doi>.
# Hard-fails the CI job on any unresolvable DOI. Mirrors the citation-integrity
# rule documented in About.

bib_file <- "references.bib"
if (!file.exists(bib_file)) {
  cat("No references.bib found — nothing to verify.\n")
  quit(status = 0L)
}

bib <- readLines(bib_file, warn = FALSE)
dois <- regmatches(bib, regexpr("doi\\s*=\\s*[{\"]([^}\"]+)", bib, ignore.case = TRUE))
dois <- sub("doi\\s*=\\s*[{\"]", "", dois, ignore.case = TRUE)
dois <- unique(dois[nzchar(dois)])

if (!length(dois)) {
  cat("No DOIs in references.bib — nothing to verify.\n")
  quit(status = 0L)
}

failed <- character()
for (doi in dois) {
  url <- paste0("https://doi.org/", doi)
  res <- tryCatch(
    {
      con <- url(url, open = "rb", method = "libcurl")
      close(con)
      TRUE
    },
    error = function(e) FALSE,
    warning = function(w) FALSE
  )
  if (!isTRUE(res)) {
    # Try a HEAD via curl as fallback
    code <- suppressWarnings(system2(
      "curl",
      args = c("-sIL", "-o", "/dev/null", "-w", "%{http_code}", url),
      stdout = TRUE
    ))
    if (length(code) && grepl("^(2|3)", code[length(code)])) {
      next
    }
    failed <- c(failed, doi)
  }
}

if (length(failed)) {
  cat("DOI verification FAILED for:\n")
  for (d in failed) cat("  -", d, "\n")
  quit(status = 1L)
}

cat(sprintf("Verified %d DOI(s).\n", length(dois)))
