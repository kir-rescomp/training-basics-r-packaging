# Building R Packages — A Modern Guide

Welcome to **Building R Packages**! This four-episode workshop teaches you how to turn a bioinformatics R script into a professional, documented, tested, and shareable package using modern R/4.5 tooling.

---

## 🧬 What You'll Build

Throughout this series you'll build **`kirgcdemo`** — a small but complete R package for DNA sequence analysis. The same two core functions from the companion Python series, implemented R-idiomatically:

```r
gc_content("ATGCATGCNN")   # → 50.0
reverse_complement("ATGC") # → "GCAT"
```

By the end you'll have a package with:

- ✅ Proper `DESCRIPTION` and `NAMESPACE`
- ✅ `roxygen2` documentation with a vignette
- ✅ `testthat` 3rd edition test suite with coverage
- ✅ A `pkgdown` website deployed via GitHub Actions

---

## 🗺️ Series Overview

| Episode | Title | Key Tools |
|---------|-------|-----------|
| [1](episodes/episode01.md) | From Script to Package | `usethis`, `devtools`, `renv` |
| [2](episodes/episode02.md) | Docs That Write Themselves | `roxygen2`, vignettes |
| [3](episodes/episode03.md) | Test-Driven Confidence | `testthat`, `covr` |
| [4](episodes/episode04.md) | Ship It | `pkgdown`, GitHub Actions, `pak` |

---

## 🔗 Companion Series

This workshop is a direct R counterpart to the **Python Packaging Basics** series (`kir-pydemo`). You don't need to have completed that series, but if you have, the concepts map closely:

| Python | R |
|--------|---|
| `pyproject.toml` | `DESCRIPTION` |
| `src/` layout | `R/` directory |
| `pytest` | `testthat` |
| `hatch build` + PyPI | `pkgdown` + GitHub |
| `pip install -e .` | `devtools::load_all()` |
| lockfile via `uv` | `renv` |

---

## ⚙️ Prerequisites

- R ≥ 4.1 (4.5 recommended — available on BMRC as `R/4.5.1-foss-2023a`)
- RStudio or VSCode with the R extension
- A GitHub account
- The following packages installed:

```r
install.packages(c("devtools", "usethis", "roxygen2",
                   "testthat", "covr", "pkgdown", "renv"))
```

Or with `pak` (faster):

```r
install.packages("pak")
pak::pak(c("devtools", "usethis", "roxygen2",
           "testthat", "covr", "pkgdown", "renv"))
```
