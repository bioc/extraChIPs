% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/mergeByHMP.R
\name{.ec_HMP}
\alias{.ec_HMP}
\title{This is a modified version of harmonicmeanp::p.hmp developed by Prof Daniel
Wilson, and hardwired to simply return a combined asymptotically exact HMP.
Hardwiring like this gives a 10-fold speed-up. Further modifications may be
possible, but this seems enough for now}
\usage{
.ec_HMP(p, w)
}
\arguments{
\item{p}{vector of p-values}

\item{w}{vector of weights}
}
\description{
This is a modified version of harmonicmeanp::p.hmp developed by Prof Daniel
Wilson, and hardwired to simply return a combined asymptotically exact HMP.
Hardwiring like this gives a 10-fold speed-up. Further modifications may be
possible, but this seems enough for now
}
\keyword{internal}
