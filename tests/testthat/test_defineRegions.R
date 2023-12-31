## Define two exons for two transcripts
sq <- Seqinfo(seqnames = "chr1", seqlengths = 50000)
e <- c("chr1:20001-21000", "chr1:29001-29950", "chr1:22001-23000", "chr1:29001-30000")
e <- GRanges(e, seqinfo = sq)
mcols(e) <- DataFrame(gene_id = "Gene1", transcript_id = c("Trans1", "Trans1", "Trans2", "Trans2"))

## Define the transcript ranges
t <- unlist(endoapply(split(e, e$transcript_id), range))
t$gene_id <- "Gene1"
t$transcript_id <- names(t)
names(t) <- NULL

## Summarise to gene level
g <- reduceMC(t)
g$transcript_id <- NA_character_


test_that("defineRegions works correctly", {

  regions <- defineRegions(genes = g, transcripts = t, exons = e)
  expect_true(is(regions, "GRangesList"))
  expect_equal(length(regions), 6)
  expect_equal(
    vapply(regions, length, integer(1)),
    c(promoter = 1L, upstream_promoter = 1L, exon = 2L, intron = 1L,
      proximal_intergenic = 2L, distal_intergenic = 2L)
  )
  mcol_df <- mcols(regions, level = "within")
  expect_true(is(mcol_df[, 1], "CompressedCharacterList"))
  expect_true(is(mcol_df[, 2], "SimpleList"))
  expect_true(is(mcol_df[, 3], "SimpleList"))

  ## Setting simplify = TRUE
  regions <- defineRegions(genes = g, transcripts = t, exons = e, simplify = TRUE)
  mcol_df <- mcols(regions, level = "within")
  expect_true(is(mcol_df[, 1], "CompressedCharacterList"))
  expect_true(is(mcol_df[, 2], "CompressedCharacterList"))
  expect_true(is(mcol_df[, 3], "SimpleList"))

  # Now merging gene bodies & intergenic
  regions <- defineRegions(genes = g, transcripts = t, exons = e, intron = FALSE, proximal = 0)
  expect_equal(length(regions), 4)
  expect_equal(
    vapply(regions, length, integer(1)),
    c(promoter = 1L, upstream_promoter = 1L, gene_body = 1L, intergenic = 2L)
  )


})

test_that("defineRegions errors correctly", {

  g1 <- granges(g)
  expect_error(
    defineRegions(genes = g1, transcripts = t, exons = e),
    "all\\(table\\(all_cols\\) == 3\\) is not TRUE"
  )


})
