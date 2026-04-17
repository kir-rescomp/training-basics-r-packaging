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
  expect_equal(gc_content("GCNN"),   50.00)
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
