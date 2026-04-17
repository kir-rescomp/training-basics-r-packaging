# Episode 3: Test-Driven Confidence

## Learning Objectives

By the end of this episode you will be able to:

- Set up `testthat` 3rd edition in your package
- Write unit tests covering expected behaviour, edge cases, and errors
- Run the full `R CMD check` suite with `devtools::check()`
- Measure test coverage with `covr`

---

## 3.1 Why Test?

Tests let you change code without fear. For an HPC package that researchers will run on thousands of samples, an untested edge case isn't a minor bug — it's a corrupted results file.

The question isn't *"should I test?"* but *"what should I test?"*

- ✅ Normal inputs and expected outputs
- ✅ Edge cases (empty string, all-N sequence, single base)
- ✅ Invalid inputs that should raise errors
- ✅ Numeric precision (floating-point comparisons)

!!! note "Compared to Python"
    `testthat` is the R equivalent of `pytest`. The structure maps directly:
    `tests/testthat/test-*.R` ↔ `tests/test_*.py`.

---

## 3.2 Setting Up testthat

```r
usethis::use_testthat(edition = 3)
```

This adds to `DESCRIPTION`:

```
Suggests:
    testthat (>= 3.0.0)
Config/testthat/edition: 3
```

And creates:

```
tests/
├── testthat/
│   └── (your test files go here)
└── testthat.R          # the test runner
```

!!! warning "Always use edition 3"
    testthat has three editions. Edition 3 (released 2021) has much better
    failure messages, snapshot testing, and parallelism. Always specify it
    explicitly — it won't activate automatically even on recent versions.

---

## 3.3 Writing Tests

Create `tests/testthat/test-gc_content.R`:

```r
# tests/testthat/test-gc_content.R

test_that("gc_content returns correct percentage for known sequences", {
  expect_equal(gc_content("ATGCATGC"), 50.0)
  expect_equal(gc_content("GCGCGCGC"), 100.0)
  expect_equal(gc_content("ATATATAT"),   0.0)
})

test_that("gc_content is case-insensitive", {
  expect_equal(gc_content("atgc"), gc_content("ATGC"))
  expect_equal(gc_content("GcGc"), 100.0)
})

test_that("gc_content handles ambiguous bases correctly", {
  # N bases dilute the percentage but don't count as GC
  expect_equal(gc_content("GCNN"), 50.0)
  expect_equal(gc_content("ATGCNN"), 33.33)
})

test_that("gc_content returns NA for empty string", {
  expect_true(is.na(gc_content("")))
})

test_that("gc_content rejects invalid input", {
  expect_error(gc_content(123),        "`sequence` must be a single")
  expect_error(gc_content(c("A","T")), "`sequence` must be a single")
  expect_error(gc_content(NULL),       "`sequence` must be a single")
})
```

Create `tests/testthat/test-reverse_complement.R`:

```r
# tests/testthat/test-reverse_complement.R

test_that("reverse_complement produces correct output", {
  expect_equal(reverse_complement("ATGC"), "GCAT")
  expect_equal(reverse_complement("AAAA"), "TTTT")
  expect_equal(reverse_complement("GCGC"), "GCGC")
})

test_that("reverse_complement is case-insensitive", {
  expect_equal(reverse_complement("atgc"), reverse_complement("ATGC"))
})

test_that("reverse_complement passes through ambiguous bases", {
  expect_equal(reverse_complement("ATGCN"), "NGCAT")
})

test_that("reverse_complement of reverse_complement is identity", {
  seqs <- c("ATGCATGC", "GCGCGCGC", "AAAAGGGG")
  for (s in seqs) {
    expect_equal(reverse_complement(reverse_complement(s)), s)
  }
})

test_that("reverse_complement rejects invalid input", {
  expect_error(reverse_complement(42),         "`sequence` must be a single")
  expect_error(reverse_complement(c("A","T")), "`sequence` must be a single")
})
```

---

## 3.4 Running Your Tests

```r
devtools::test()
```

Good output looks like:

```
ℹ Testing kirgcdemo
✔ | F W S  OK | Context
✔ |         7 | gc_content
✔ |         6 | reverse_complement
═══════════════════════════════════
[ FAIL 0 | WARN 0 | SKIP 0 | PASS 13 ]
```

If a test fails, testthat gives you a diff showing exactly what went wrong:

```
── Failure (test-gc_content.R:5): gc_content returns correct percentage ──
gc_content("ATATATAT") not equal to 0.0.
Actual value:   0
Expected value: 0.0
```

---

## 3.5 The Full `R CMD check`

`devtools::test()` only runs your test suite. `R CMD check` is the full gauntlet — it's what CRAN runs, and what your GitHub Actions will run. You should pass it locally before pushing.

```r
devtools::check()
```

This runs:

1. Package structure checks
2. `roxygen2` documentation rebuild
3. Example code in `@examples` blocks
4. Vignette builds
5. Your full test suite

Aim for:

```
── R CMD check results ────────────────────────
Duration: 12.4s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔
```

!!! tip "Common first-time issues"
    - **`no visible binding for global variable`** — you've used a variable name inside `dplyr`/`ggplot2` that R CMD check can't see at parse time. Fix: `utils::globalVariables("my_var")` or use `.data$my_var`.
    - **Example fails** — your `@examples` block has a bug or requires internet. Guard it with `@examplesIf interactive()`.
    - **Vignette timeout** — add `eval = FALSE` to slow chunks during development.

---

## 3.6 Snapshot Testing

For functions that return complex objects (data frames, plots, lists), snapshot tests capture the output once and then alert you if it changes unexpectedly — perfect for bioinformatics where output format matters.

```r
test_that("gc_content works on a named vector via vapply", {
  seqs <- c(promoter = "ATATATAT", exon = "GCGCGCGC")
  result <- vapply(seqs, gc_content, numeric(1))
  expect_snapshot(result)
})
```

First run: creates `tests/testthat/_snaps/gc_content.md`.  
Subsequent runs: compares against the snapshot.

To update snapshots after an intentional change:

```r
testthat::snapshot_update()
```

---

## 3.7 Coverage with `covr`

Coverage tells you which lines of your code are never reached by tests:

```r
covr::package_coverage()
```

```
kirgcdemo Coverage: 94.12%
R/sequences.R: 94.12%
```

Aim for > 80% on core functions. Getting to 100% is often diminishing returns — focus on the paths that matter.

For an HTML report:

```r
covr::report()
```

---

## ✅ Episode 3 Checkpoint

```r
devtools::test()   # 0 failures
devtools::check()  # 0 errors, 0 warnings
covr::package_coverage()  # > 80%
```

```
tests/
└── testthat/
    ├── test-gc_content.R
    ├── test-reverse_complement.R
    └── _snaps/
        └── gc_content.md
```

In [Episode 4](episode04.md) we'll give your package a public face — a `pkgdown` website and GitHub Actions CI.
