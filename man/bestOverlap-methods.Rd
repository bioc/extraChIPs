% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/AllGenerics.R, R/bestOverlap.R
\name{bestOverlap}
\alias{bestOverlap}
\alias{bestOverlap,GRanges,GRanges-method}
\alias{bestOverlap,GRanges,GRangesList-method}
\title{Find the best overlap between GRanges}
\usage{
bestOverlap(x, y, ...)

\S4method{bestOverlap}{GRanges,GRanges}(
  x,
  y,
  var = NULL,
  ignore.strand = FALSE,
  missing = NA_character_,
  min_prop = 0.01,
  ...
)

\S4method{bestOverlap}{GRanges,GRangesList}(
  x,
  y,
  ignore.strand = FALSE,
  missing = NA_character_,
  min_prop = 0.01,
  ...
)
}
\arguments{
\item{x}{a GRanges object}

\item{y}{a named GRangesList or GRanges object with mcol as reference
category}

\item{...}{Not used}

\item{var}{The variable to use as the category. Not required if \code{y} is a
GRangesList}

\item{ignore.strand}{logical(1) Passed to \link[GenomicRanges]{findOverlaps}}

\item{missing}{Value to assign to ranges with no overlap}

\item{min_prop}{Threshold below which overlaps are discarded}
}
\value{
Character vector the same length as the supplied GRanges object
}
\description{
Find the best overlap between ranges
}
\details{
This finds the category in the subject GRanges (y) which has the best overlap
with the query GRanges (x).
The aim is to produce a character vector for best classifying the query
GRanges using an external set of features (e.g. promoters, enhancers etc).
If the subject (y) is a GRanges object, the values in the specified column
will be used as the category.
If the subject (y) is a GRangesList, the names of the list will be used to
provide the best match
}
\examples{
gr <- GRanges("chr1:1-10")
gr_cat <- GRanges(c("chr1:2-10", "chr1:5-10"))
gr_cat$category <- c("a", "b")
propOverlap(gr, gr_cat)
bestOverlap(gr, gr_cat, var = "category")

grl <- splitAsList(gr_cat, gr_cat$category)
lapply(grl, function(x) propOverlap(gr, x))
bestOverlap(gr, grl)

}
