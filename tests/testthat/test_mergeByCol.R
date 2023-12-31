sq <- Seqinfo("chr1", 100, FALSE, "test")
x <- GRanges(c("chr1:1-10", "chr1:6-15", "chr1:51-60"), seqinfo = sq)
df <- data.frame(logFC = rnorm(3), logCPM = rnorm(3,8), p = 10^-rexp(3))

test_that("Function behaves correctly for GRanges",{
  new_gr <- mergeByCol(x, df, col = "logCPM", pval = "p")
  expect_equal(length(new_gr), 2)
  expect_equal(seqinfo(new_gr$keyval_range), sq)
  mcols(x) <- df
  expect_equal(
    length(mergeByCol(x, col = "logCPM", pval = "p")), 2
  )
  expect_s4_class(
    mergeByCol(x, df, col = "logCPM", pval = "p")$keyval_range, "GRanges"
  )
  new_gr <- mergeByCol(x, df, col = "logCPM", pval = "p", min_win = 2)
  expect_equal(length(new_gr), 1)
})

test_that("Function errors as expected", {
  expect_error(mergeByCol(x, df[1,], col = "logCPM", pval = "p"))
  expect_error(mergeByCol(x, df))
  expect_error(
    mergeByCol(x, df, col = "logFC", pval = "p"),
    "Merging not implemented for logFC"
  )
  expect_error(mergeByCol(x, df, col = ""))
})

test_that("P-value adjustment columns are correct", {
  expect_true(
    "p_fdr" %in% colnames(
      mcols(mergeByCol(x, df, col = "logCPM", pval = "p"))
    )
  )
  expect_equal(
    ncol(
      mcols(mergeByCol(x, df, col = "logCPM", pval = "p", p_adj_method = "none"))
    ),
    7
  )
})

test_that("RangedSummarizedExperiment works", {
  mcols(x) <- DataFrame(df)
  x$id <- letters[seq_along(x)]
  rse <- SummarizedExperiment(
    assays = SimpleList(counts = matrix(runif(length(x)), ncol =1)),
    rowRanges = x
  )
  mbc <- mergeByCol(rse, col = "logCPM", pval = "p", inc_cols = "id")
  expect_equal(length(mbc), 2)
  expect_true("id" %in% colnames(mcols(mbc)))

})
