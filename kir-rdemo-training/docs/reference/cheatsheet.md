# R Package Development Cheatsheet

A one-page reference for the commands introduced across all four episodes.

---

## Scaffold

```r
usethis::create_package("mypkg")   # create package skeleton
usethis::use_mit_license()         # add MIT licence
usethis::use_readme_md()           # add README.md
usethis::use_git()                 # initialise git
renv::init()                       # lock the environment
```

---

## Development Loop

```r
devtools::load_all()       # re-load from source  (Ctrl+Shift+L)
devtools::document()       # regenerate man/ and NAMESPACE
devtools::test()           # run test suite
devtools::check()          # full R CMD check
```

---

## Documentation (`roxygen2`)

```r
#' Title
#'
#' @param x  Description of x
#' @returns  What is returned
#' @examples
#' my_fn("hello")
#' @examplesIf interactive()   # guard internet-requiring examples
#' fetch_remote_data()
#' @export
```

---

## Vignettes

```r
usethis::use_vignette("my-vignette")   # scaffold vignette
devtools::build_vignettes()            # build locally
browseVignettes("mypkg")               # open in browser
```

---

## Testing (`testthat` edition 3)

```r
usethis::use_testthat(edition = 3)          # set up

# In tests/testthat/test-myfn.R:
test_that("description", {
  expect_equal(my_fn("x"), "expected")
  expect_error(my_fn(NULL), "must be")
  expect_snapshot(my_fn_df_output())
})

testthat::snapshot_update()   # accept new snapshots
covr::package_coverage()      # coverage report
covr::report()                # HTML coverage report
```

---

## Shipping (`pkgdown` + GitHub Actions)

```r
usethis::use_pkgdown()                          # scaffold pkgdown
pkgdown::build_site()                           # build locally
usethis::use_github()                           # create GitHub repo
usethis::use_github_action("check-standard")    # R-CMD-check CI
usethis::use_github_action("pkgdown")           # auto-deploy site
usethis::use_github_actions_badge("R-CMD-check") # README badge
```

---

## Installation

```r
# From GitHub (fastest)
pak::pak("org/mypkg")

# From source tarball (BMRC offline nodes)
install.packages("mypkg_0.1.0.tar.gz", repos = NULL, type = "source")

# Build tarball
devtools::build()
```

---

## Versioning

```r
usethis::use_version("patch")   # 0.1.0 → 0.1.1
usethis::use_version("minor")   # 0.1.0 → 0.2.0
usethis::use_version("major")   # 0.1.0 → 1.0.0
```

---

## Python ↔ R Equivalence

| Python | R |
|--------|---|
| `pyproject.toml` | `DESCRIPTION` |
| `src/pkg/` | `R/` |
| `pip install -e .` | `devtools::load_all()` |
| `pytest` | `testthat` |
| `hatch build` | `devtools::build()` |
| PyPI | GitHub + `pak` |
| `uv.lock` | `renv.lock` |
| Sphinx / MkDocs | `pkgdown` |
