\name{coverage-methods}
\alias{coverage-methods}

\alias{coverage,GenomicRanges-method}
\alias{coverage,GRangesList-method}
\alias{coverage,GappedAlignments-method}
\alias{coverage,GappedAlignmentPairs-method}


\title{Coverage of a GRanges, GRangesList, GappedAlignments, or
       GappedAlignmentPairs object}

\description{
  \code{\link[IRanges]{coverage}} methods for \link{GRanges},
  \link{GRangesList}, \link{GappedAlignments}, and \link{GappedAlignmentPairs}
  objects.
}

\usage{
\S4method{coverage}{GenomicRanges}(x, shift=0L, width=NULL, weight=1L, ...)
\S4method{coverage}{GappedAlignments}(x, shift=0L, width=NULL,
         weight=1L, drop.D.ranges=FALSE, ...)
\S4method{coverage}{GappedAlignmentPairs}(x, shift=0L, width=NULL,
         weight=1L, drop.D.ranges=FALSE, ...)
}

\arguments{
  \item{x}{
    A \link{GRanges}, \link{GRangesList}, \link{GappedAlignments},
    or \link{GappedAlignmentPairs} object.
  }
  \item{shift, width, weight, ...}{
    See \code{\link[IRanges]{coverage}} in the IRanges package for
    a description of these optional arguments.
  }
  \item{drop.D.ranges}{
    Whether the coverage calculation should ignore ranges corresponding
    to D (deletion) in the CIGAR string.
  }
}

\details{
  Here is how optional arguments \code{shift}, \code{width} and
  \code{weight} are handled when \code{x} is a \link{GRanges} object:
  \itemize{
  \item \code{shift}, \code{weight}: can be either a numeric vector
        (integers) or a list. If a list, then it should be named by the
        sequence levels in \code{x} (i.e. by the names of the underlying
        sequences), and its elements are passed into the \code{coverage}
        method for \link[IRanges]{IRanges} objects. If a numeric vector,
        then it is first recycled to the length of \code{x}, then turned
        into a list with \code{split(shift, as.factor(seqnames(x)))},
        and finally the elements of this list are passed into the
        \code{coverage} method for \link[IRanges]{IRanges} objects.
        Finally, if \code{x} is a \link{GRanges} object, then \code{weight}
        can also be a single string naming a metadata column to be used
        as the weights.

  \item \code{width}: can be either \code{NULL} or a numeric vector.
        If a numeric vector, then it should be named by the sequence
        levels in \code{x}. If \code{NULL} (the default), then it is
        replaced with \code{seqlengths(x)}. Like for \code{shift} and
        \code{weight}, its elements are passed into the \code{coverage}
        method for \link[IRanges]{IRanges} objects (if the element is
        \code{NA} then \code{NULL} is passed instead).
  }

  When \code{x} is a \link{GRangesList} object, \code{coverage(x, ...)}
  is equivalent to \code{coverage(unlist(x), ...)}.

  When \code{x} is a \link{GappedAlignments} or \link{GappedAlignmentPairs}
  object, \code{coverage(x, ...)} is equivalent to
  \code{coverage(as(x, "GRangesList"), ...)}.
}

\value{
  Returns a named \link[IRanges]{RleList} object with one element
  ('integer' Rle) per underlying sequence in \code{x} representing how
  many times each position in the sequence is covered by the intervals in
  \code{x}.
}

\author{P. Aboyoun and H. Pages}

\seealso{
  \itemize{
    \item \code{\link[IRanges]{coverage}}.
    \item \link[IRanges]{RleList-class}.
    \item \link{GRanges-class}.
    \item \link{GRangesList-class}.
    \item \link{GappedAlignments-class}.
    \item \link{GappedAlignmentPairs-class}.
  }
}

\examples{
## Coverage of a GRanges object:
gr <- GRanges(
        seqnames=Rle(c("chr1", "chr2", "chr1", "chr3"), c(1, 3, 2, 4)),
        ranges=IRanges(1:10, end=10),
        strand=Rle(strand(c("-", "+", "*", "+", "-")), c(1, 2, 2, 3, 2)),
        seqlengths=c(chr1=11, chr2=12, chr3=13))
cvg <- coverage(gr)
pcvg <- coverage(gr[strand(gr) == "+"])
mcvg <- coverage(gr[strand(gr) == "-"])
scvg <- coverage(gr[strand(gr) == "*"])
stopifnot(identical(pcvg + mcvg + scvg, cvg))

## Coverage of a GRangesList object:
gr1 <- GRanges(seqnames="chr2",
               ranges=IRanges(3, 6),
               strand = "+")
gr2 <- GRanges(seqnames=c("chr1", "chr1"),
               ranges=IRanges(c(7,13), width=3),
               strand=c("+", "-"))
gr3 <- GRanges(seqnames=c("chr1", "chr2"),
               ranges=IRanges(c(1, 4), c(3, 9)),
               strand=c("-", "-"))
grl <- GRangesList(gr1=gr1, gr2=gr2, gr3=gr3)
stopifnot(identical(coverage(grl), coverage(unlist(grl))))

## Coverage of a GappedAlignments or GappedAlignmentPairs object:
library(Rsamtools)  # because file ex1.bam is in this package
ex1_file <- system.file("extdata", "ex1.bam", package="Rsamtools")
galn <- readGappedAlignments(ex1_file)
stopifnot(identical(coverage(galn), coverage(as(galn, "GRangesList"))))
galp <- readGappedAlignmentPairs(ex1_file)
stopifnot(identical(coverage(galp), coverage(as(galp, "GRangesList"))))
}

\keyword{methods}
\keyword{utilities}
