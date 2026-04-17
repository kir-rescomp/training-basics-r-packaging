# Episode 2: Docs That Write Themselves

## Learning Objectives

By the end of this episode you will be able to:

- Write `roxygen2` documentation blocks that generate `man/` pages automatically
- Use `devtools::document()` to regenerate `NAMESPACE` and `man/`
- Write a vignette using R Markdown
- Use the native pipe `|>` idiomatically in examples

---

## 2.1 Why roxygen2?

In Episode 1 you may have noticed `#'` comments above your functions. Those aren't ordinary comments — they're **roxygen2 blocks**, and they power the entire R documentation system.

When you run `devtools::document()`, roxygen2:

1. Parses every `#'` block in `R/`
2. Generates `man/*.Rd` files (the raw documentation format)
3. Rewrites `NAMESPACE` based on `@export` tags

You **never manually edit** `man/` or `NAMESPACE`. roxygen2 owns them.

!!! note "Compared to Python"
    This is the R equivalent of docstrings + Sphinx + `__all__` combined — except roxygen2 is part of the standard toolchain, not a separate documentation framework.

---

## 2.2 Anatomy of a roxygen2 Block

```r
#' Title (one line, no full stop)                  ← @title (implicit)
#'
#' Longer description paragraph. Can use           ← @description (implicit)
#' **markdown** because we set `Roxygen: list(markdown = TRUE)`.
#'
#' @param name Description of the parameter.       ← @param
#' @param another Another parameter.
#'
#' @returns What the function returns.              ← @returns (preferred over @return in R ≥ 4.1)
#'
#' @examples                                        ← @examples
#' my_function("hello")
#'
#' @export                                          ← adds to NAMESPACE
my_function <- function(name, another) { ... }
```

### Key tags

| Tag | Purpose |
|-----|---------|
| `@param` | Document an argument |
| `@returns` | Document the return value (`@returns` preferred in R ≥ 4.1) |
| `@examples` | Runnable examples (executed during `R CMD check`) |
| `@export` | Make the function user-visible |
| `@importFrom` | Import a specific function from another package |
| `@seealso` | Cross-reference related functions |
| `@examplesIf` | Conditional examples (great for HPC where internet is unavailable) |

---

## 2.3 Upgrading Our Documentation

Let's enrich the blocks in `R/sequences.R`:

```r
#' Calculate GC content of a DNA sequence
#'
#' Computes the percentage of guanine (G) and cytosine (C) bases in a
#' DNA sequence. Ambiguous bases (e.g. `N`) are counted in the denominator
#' but not as GC, so they dilute the result.
#'
#' @param sequence A single character string of DNA bases (`A`, `T`, `G`, `C`).
#'   Case-insensitive. Must have length 1.
#'
#' @returns A single numeric value giving the GC percentage (0–100), rounded
#'   to two decimal places. Returns `NA_real_` for empty strings.
#'
#' @examples
#' gc_content("ATGCATGC")        # 50.0 — balanced
#' gc_content("GCGCGCGC")        # 100.0 — all GC
#' gc_content("ATGCNN")          # 33.33 — N bases dilute
#'
#' # Works naturally with the native pipe
#' c("ATGC", "GCGC", "ATAT") |> vapply(gc_content, numeric(1))
#'
#' @seealso [reverse_complement()] for the companion function.
#' @export
gc_content <- function(sequence) {
  # ... (same implementation as Episode 1)
}
```

!!! tip "Markdown in roxygen2"
    Because `DESCRIPTION` has `Roxygen: list(markdown = TRUE)`, you can use backticks, `**bold**`, and `[links](url)` in your documentation. No special syntax needed.

---

## 2.4 Running `devtools::document()`

```r
devtools::document()
#> ℹ Updating kirgcdemo documentation
#> ℹ Loading kirgcdemo
#> Writing NAMESPACE
#> Writing gc_content.Rd
#> Writing reverse_complement.Rd
```

Now preview your docs:

```r
?gc_content
?reverse_complement
```

You should see properly formatted help pages — the same format as any CRAN package.

---

## 2.5 Writing a Vignette

Vignettes are long-form narrative documents — the R equivalent of a Jupyter notebook. They're the right place to show *how* to use your package, not just *what* it does.

```r
usethis::use_vignette("gc-analysis")
```

This creates `vignettes/gc-analysis.Rmd`. Open it and write something like:

````markdown
---
title: "Analysing GC Content with kirgcdemo"
output: rmarkdown::html_vignette
vignette: >
  %\VignetteIndexEntry{Analysing GC Content with kirgcdemo}
  %\VignetteEngine{knitr::rmarkdown}
  %\VignetteEncoding{UTF-8}
---

```{r setup, include = FALSE}
knitr::opts_chunk$set(collapse = TRUE, comment = "#>")
```

## Introduction

The `kirgcdemo` package provides two core utilities for DNA sequence
analysis: `gc_content()` and `reverse_complement()`.

## GC Content Across a Set of Sequences

GC content varies widely across genomes and is biologically meaningful —
high-GC regions are associated with gene-dense areas and greater thermal
stability.

```{r gc-example}
library(kirgcdemo)

seqs <- c(
  promoter = "ATATATATATAT",
  exon     = "GCGCGCGCATGC",
  mixed    = "ATGCATGCATGC"
)

# Native pipe: apply gc_content to each sequence
gc_values <- seqs |> vapply(gc_content, numeric(1))
gc_values
```

```{r barplot}
barplot(gc_values,
        ylab = "GC content (%)",
        main = "GC content by region",
        col  = c("#4E9AF1", "#F1714E", "#6DBF67"))
```

## Reverse Complement

The reverse complement is fundamental to working with double-stranded DNA —
it gives you the sequence on the complementary strand, read 5'→3'.

```{r revcomp-example}
seq <- "ATGCTAGCTAGCT"
cat("Forward:            ", seq, "\n")
cat("Reverse complement: ", reverse_complement(seq), "\n")
```
````

Build and preview it:

```r
devtools::build_vignettes()
browseVignettes("kirgcdemo")
```

---

## 2.6 Guarding Examples with `@examplesIf`

On BMRC compute nodes, outbound internet access is restricted. If any of your examples download data, guard them:

```r
#' @examplesIf interactive()
#' # This example requires internet access — skip in R CMD check
#' fetch_sequence_from_ensembl("ENSG00000139618")
```

This is idiomatic R/4.1+ — far cleaner than the old `\dontrun{}` escape.

---

## ✅ Episode 2 Checkpoint

```r
devtools::document()   # regenerate docs
devtools::load_all()
?gc_content            # should show full help page
browseVignettes("kirgcdemo")  # should open vignette
```

Your directory now includes:

```
kirgcdemo/
├── man/
│   ├── gc_content.Rd
│   └── reverse_complement.Rd
├── vignettes/
│   └── gc-analysis.Rmd
└── NAMESPACE           # now auto-managed by roxygen2
```

In [Episode 3](episode03.md) we'll add a test suite so you can change your code with confidence.
