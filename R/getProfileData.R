#' @title Get Profile Data Surrounding Ranges
#'
#' @description Get Coverage Profile Data Surrounding Ranges
#'
#' @details
#' This will take all provided ranges and set as identical width ranges,
#' extending by the specified amount both up and downstream of the centre of the
#' provided ranges. By default, the ranges extensions are symmetrical and only
#' the upstream range needs to be specified, however this parameterisation
#' allows for non-symmetrical ranges to be generated.
#'
#' These uniform width ranges will then be used to extract the value contained
#' in the score field from one or more BigWigFiles. Uniform width ranges are
#' then broken into bins of equal width and the average score found within each
#' bin.
#'
#' The binned profiles are returned as a DataFrameList called `profile_data` as
#' a column within the resized GRanges object.
#' Column names in each DataFrame are `score`, `position` and `bp`.
#'
#' @param x A BigWigFile or BigWiFileList
#' @param gr A GRanges object
#' @param upstream The distance to extend upstream from the centre of each
#' range within `gr`
#' @param downstream The distance to extend downstream from the centre of each
#' range within `gr`
#' @param bins The total number of bins to break the extended ranges into
#' @param mean_mode The method used for calculating the score for each bin.
#' See \link[EnrichedHeatmap]{normalizeToMatrix} for details
#' @param ... Passed to \link[EnrichedHeatmap]{normalizeToMatrix}
#'
#' @return
#' GRanges or GrangesList with column profile_data, as described above
#'
#' @examples
#' bw <- system.file("tests", "test.bw", package = "rtracklayer")
#' gr <- GRanges("chr2:500")
#' getProfileData(bw, gr, upstream = 100, bins = 10)
#'
#' @name getProfileData
#' @rdname getProfileData-methods
#' @export
setGeneric(
  "getProfileData",
  function(x, gr, ...) standardGeneric("getProfileData")
)
#' @importFrom GenomicRanges resize promoters
#' @importFrom rtracklayer import.bw
#' @importFrom rtracklayer BigWigFile BigWigFileList
#' @importFrom EnrichedHeatmap normalizeToMatrix
#' @importFrom tibble as_tibble
#' @importFrom tidyr pivot_longer nest
#' @importFrom tidyselect all_of
#' @importFrom S4Vectors DataFrame
#' @importFrom IRanges SplitDataFrameList
#' @importFrom dplyr left_join
#' @rdname getProfileData-methods
#' @export
setMethod(
  "getProfileData",
  signature = signature(x = "BigWigFile", gr = "GenomicRanges"),
  function(
    x, gr, upstream = 2500, downstream = upstream, bins = 100,
    mean_mode = "w0", ...
  ) {

    stopifnot(upstream > 0 & downstream > 0 & bins > 0)
    ids <- as.character(gr)
    bin_width <- as.integer((upstream + downstream) / bins)
    gr_resize <- resize(gr, width = 1, fix = "center")
    gr_resize <- promoters(gr_resize, upstream, downstream)
    vals <- import.bw(x, which = gr_resize)

    mat <- normalizeToMatrix(
      signal = vals,
      target = resize(gr_resize, width = 1, fix = "center"),
      extend = (upstream + downstream)/ 2,
      w = bin_width,
      mean_mode = mean_mode,
      value_column = "score",
      ...
    )
    mat <- as.matrix(mat)
    rownames(mat) <- ids

    tbl <- as_tibble(mat, rownames = "range")
    tbl <- pivot_longer(
      tbl, cols = all_of(colnames(mat)),
      names_to = "position", values_to = "score"
    )
    tbl[["position"]] <- factor(tbl[["position"]], levels = colnames(mat))
    tbl[["bp"]] <- seq(
      -upstream + bin_width / 2, downstream - bin_width / 2, by = bin_width
    )[as.integer(tbl[["position"]])]
    tbl <- nest(tbl, profile_data = all_of(c("score", "position", "bp")))
    gr_tbl <- left_join(as_tibble(gr), tbl, by = "range")
    gr_resize$profile_data <- SplitDataFrameList(
      lapply(gr_tbl$profile_data, DataFrame), compress = TRUE
    )
    gr_resize
  }
)
#' @rdname getProfileData-methods
#' @export
setMethod(
  "getProfileData",
  signature = signature(x = "BigWigFileList", gr = "GenomicRanges"),
  function(
    x, gr, upstream = 2500, downstream = upstream, bins = 100, mean_mode = "w0",
    ...
  ) {
    out <- lapply(
      x,
      getProfileData,
      gr = gr, upstream = upstream, downstream = downstream, bins = bins,
      mean_mode = mean_mode, ...
    )
    as(out, "GRangesList")
  }
)
#' @rdname getProfileData-methods
#' @export
setMethod(
  "getProfileData",
  signature = signature(x = "character", gr = "GenomicRanges"),
  function(
    x, gr, upstream = 2500, downstream = upstream, bins = 100, mean_mode = "w0",
    ...
  ) {
    stopifnot(all(file.exists(x)))
    if (length(x) == 1) {
      x <- BigWigFile(x)
    } else {
      x <- BigWigFileList(x)
    }
    getProfileData(x, gr, upstream, downstream, bins, mean_mode, ...)
  }
)