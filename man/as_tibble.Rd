% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/asTibble.R
\name{as_tibble}
\alias{as_tibble}
\alias{as_tibble.DataFrame}
\alias{as_tibble.GenomicRanges}
\alias{as_tibble.Seqinfo}
\alias{as_tibble.GInteractions}
\alias{as_tibble.SummarizedExperiment}
\alias{as_tibble.TopTags}
\title{Convert to a tibble}
\usage{
\method{as_tibble}{DataFrame}(x, rangeAsChar = TRUE, ...)

\method{as_tibble}{GenomicRanges}(x, rangeAsChar = TRUE, name = "range", ...)

\method{as_tibble}{Seqinfo}(x, ...)

\method{as_tibble}{GInteractions}(x, rangeAsChar = TRUE, suffix = c(".x", ".y"), ...)

\method{as_tibble}{SummarizedExperiment}(x, rangeAsChar = TRUE, ...)

\method{as_tibble}{TopTags}(x, ...)
}
\arguments{
\item{x}{A Genomic Ranges or DataFrame object}

\item{rangeAsChar}{Convert any GRanges element to a character vector}

\item{...}{Passed to \code{\link[tibble:as_tibble]{tibble::as_tibble()}}}

\item{name}{Name of column to use for ranges. Ignored if rangeAsChar =
\code{FALSE}}

\item{suffix}{Suffix appended to column names for anchor1 and anchor2 of a
GInteractions object. Only used if specifying rangeAsChar = FALSE}
}
\value{
A \link[tibble]{tibble}
}
\description{
Convert multiple Genomic objects to tibbles
}
\details{
Quick and dirty conversion into a tibble.

By default, GenomicRanges will be returned with the range as a character
column called \code{range} and all mcols parsed as the remaining columns.
Seqinfo information will be lost during coercion.

Given that names for ranges are considered as rownames in the mcols element,
these can be simply parsed by setting \code{rownames = "id"} in the call to
\code{as_tibble()}

When coercing a DataFrame, any Compressed/SimpleList columns will be coerced
to S3 list columns.
Any GRanges columns will be returned as a character column, losing any
additional mcols from these secondary ranges

Coercion of SummarizedExperiment objects will be performed on the
\code{rowRanges()} element, whilst for a \link[InteractionSet]{GInteractions}
object, both anchors will returned with the default suffixes \code{.x} and \code{.y}

Defined as an S3 method for consistency with existing tidy methods
}
\examples{
gr <- GRanges("chr1:1-10")
gr$p_value <- runif(1)
names(gr) <- "range1"
gr
as_tibble(gr)
as_tibble(gr, rownames = "id")
as_tibble(mcols(gr))
as_tibble(seqinfo(gr))

hic <- InteractionSet::GInteractions(gr, GRanges("chr1:201-210"))
hic$id <- "interaction1"
as_tibble(hic)

}
