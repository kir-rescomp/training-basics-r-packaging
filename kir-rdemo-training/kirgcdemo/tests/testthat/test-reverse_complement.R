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
