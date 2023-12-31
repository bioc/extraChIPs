sq <- Seqinfo("chr1", 100, FALSE, "test")
x <- GRanges(c("chr1:1-10", "chr1:6-15", "chr1:51-60"), seqinfo = sq)
set.seed(1001)
df <- DataFrame(logFC = rnorm(3), logCPM = rnorm(3,8), p = rexp(3, 10))
mcols(x) <- df

test_that("mergedByHMP behaves correctly for GRanges",{
  new_gr <- mergeByHMP(x, df, pval = "p")
  expect_equal(length(new_gr), 2)
  expect_equal(new_gr$keyval_range, granges(x)[2:3])
  # expect_equal(sum(new_gr$p %in% df$p), 2)
  expect_equal(seqinfo(new_gr$keyval_range), sq)
  expect_equal(length(mergeBySig(x, pval = "p")), 2)
  expect_s4_class(mergeBySig(x, df, pval = "p")$keyval_range, "GRanges")
  expect_equal(as.character(new_gr$keyval_range), as.character(x)[-1])
  expect_true(all(c("hmp", "hmp_fdr") %in% colnames(mcols(new_gr))))
  expect_equal(
    new_gr$hmp[[1]],
    as.numeric(harmonicmeanp::p.hmp(x$p[1:2], L = 2, multilevel = FALSE))
  )
  new_gr <- mergeByHMP(x, df, pval = "p", min_win = 2)
  expect_equal(length(new_gr), 1)
})

test_that("Merging keyval ranges works", {
  df$p[1] <- 0.014
  new_gr <- mergeByHMP(x, df, pval = "p", keyval = "merged")
  expect_equal(new_gr$keyval_range[1], GenomicRanges::reduce(x[1:2]))
})


test_that("Errors appear where expected", {
  expect_error(mergeByHMP(x, df[-1,], pval = "p"))
  expect_error(mergeByHMP(x, df, min.sig.n = 3))
})

test_that(".ec_HMP returns correct values",{
  # Doesn't matter if these are random every time. It's probs better actually
  p <- runif(10)
  w <- runif(10)
  w <- w / sum(w)
  expect_equal(
    as.numeric(harmonicmeanp::p.hmp(p, w = w, L = 10, multilevel = FALSE)),
    extraChIPs:::.ec_HMP(p, w)
  )
})

test_that(".ec_HMP_adj returns correct values",{
  # Doesn't matter if these are random every time. It's probs better actually
  p <- runif(10)
  w <- runif(10)
  w <- w / sum(w)
  expect_equal(
    as.numeric(harmonicmeanp::p.hmp(p, w = w, L = 100)) / sum(w),
    extraChIPs:::.ec_HMP_adj(p, w, 100)
  )
})
