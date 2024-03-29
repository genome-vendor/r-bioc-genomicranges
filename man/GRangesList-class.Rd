\name{GRangesList-class}
\docType{class}

% Class
\alias{class:GRangesList}
\alias{GRangesList-class}
\alias{GRangesList}

% Constructor-like function:
\alias{GRangesList}
\alias{makeGRangesListFromFeatureFragments}
\alias{updateObject,GRangesList-method}

% Coercion methods:
\alias{as.data.frame,GRangesList-method}
\alias{coerce,GRangesList,CompressedIRangesList-method}
\alias{coerce,GRangesList,IRangesList-method}
\alias{coerce,RangedDataList,GRangesList-method}

% Accessor methods:
\alias{seqnames,GRangesList-method}
\alias{seqnames<-,GRangesList-method}
\alias{ranges,GRangesList-method}
\alias{ranges<-,GRangesList-method}
\alias{strand,GRangesList-method}
\alias{strand<-,GRangesList-method}
\alias{elementMetadata,GRangesList-method}
\alias{elementMetadata<-,GRangesList-method}
\alias{seqinfo,GRangesList-method}
\alias{seqinfo<-,GRangesList-method}
\alias{score,GRangesList-method}

% RangesList methods:
\alias{start,GRangesList-method}
\alias{start<-,GRangesList-method}
\alias{end,GRangesList-method}
\alias{end<-,GRangesList-method}
\alias{width,GRangesList-method}
\alias{width<-,GRangesList-method}
\alias{shift,GRangesList-method}
\alias{isDisjoint,GRangesList-method}
\alias{disjoin,GRangesList-method}

% Vector methods:
\alias{[,GRangesList-method}
\alias{[<-,GRangesList,ANY,ANY,ANY-method}
\alias{[[<-,GRangesList-method}
\alias{[[<-,GRangesList,ANY,ANY-method}

% show method:
\alias{show,GRangesList-method}

% isomorphisms:
\alias{range,GRangesList-method}
\alias{reduce,GRangesList-method}
\alias{restrict,GRangesList-method}
\alias{flank,GRangesList-method}
\title{GRangesList objects}

\description{
  The GRangesList class is a container for storing a collection of
  GRanges objects. It is derived from GenomicRangesList.
}

\section{Constructors}{
  \describe{
    \item{}{
      \code{GRangesList(...)}:
      Creates a GRangesList object using GRanges objects
      supplied in \code{\ldots}.
    }
    \item{}{
      \code{makeGRangesListFromFeatureFragments(seqnames=Rle(factor()),
            fragmentStarts=list(), fragmentEnds=list(), fragmentWidths=list(),
            strand=character(0), sep=",")}:
      Constructs a GRangesList object from a list of fragmented features.
      See the Examples section below.
    }
  }
}

\section{Coercion}{
  In the code snippets below, \code{x} is a GRangesList object.

  \describe{
    \item{}{
      \code{as.data.frame(x, row.names = NULL, optional = FALSE)}:
      Creates a data.frame with columns \code{element} (character),
      \code{seqnames} (factor), \code{start} (integer),
      \code{end} (integer), \code{width} (integer), \code{strand} (factor),
      as well as the additional metadata columns (accessed with
      \code{mcols(unlist(x))}).
    }
    \item{}{\code{as.list(x, use.names = TRUE)}:
      Creates a list containing the elements of \code{x}.
    }
    \item{}{\code{as(x, "IRangesList")}:
      Turns \code{x} into an \link[IRanges]{IRangesList} object.
    }
    \item{}{
      \code{as(from, "GRangesList")}:
      Creates a GRangesList object from a \link[IRanges]{RangedDataList}
      object.
    }
  }
}

\section{Accessors}{
  In the following code snippets, \code{x} is a GRanges object.
  
  \describe{
    \item{}{
      \code{seqnames(x)}, \code{seqnames(x) <- value}:
      Get or set the sequence names in the form of an RleList. \code{value}
      can be an RleList or CharacterList.
    }
    \item{}{
      \code{ranges(x)}, \code{ranges(x) <- value}:
      Get or set the ranges in the form of a CompressedIRangesList.
      \code{value} can be a RangesList object.
    }
    \item{}{
      \code{strand(x)}, \code{strand(x) <- value}:
      Get or set the strand in the form of an RleList. \code{value} can be
      an RleList or CharacterList object.
    }
    \item{}{
      \code{mcols(x, use.names=FALSE)}, \code{mcols(x) <- value}:
      Get or set the metadata columns.
      \code{value} can be \code{NULL}, or a data.frame-like object (i.e.
      \link{DataFrame} or data.frame) holding element-wise metadata.
    }
    \item{}{
       \code{elementMetadata(x)}, \code{elementMetadata(x) <- value},
       \code{values(x)}, \code{values(x) <- value}:
       Alternatives to \code{mcols} functions. Their use is discouraged.
    }
    \item{}{
      \code{seqinfo(x)}, \code{seqinfo(x) <- value}:
      Get or set the information about the underlying sequences.
      \code{value} must be a \link{Seqinfo} object.
    }
    \item{}{
      \code{seqlevels(x)}, \code{seqlevels(x, force=FALSE) <- value}:
      Get or set the sequence levels.
      \code{seqlevels(x)} is equivalent to \code{seqlevels(seqinfo(x))}
      or to \code{levels(seqnames(x))}, those 2 expressions being
      guaranteed to return identical character vectors on a GRangesList
      object. \code{value} must be a character vector with no NAs.
      See \code{?\link{seqlevels}} for more information.
    }
    \item{}{
      \code{seqlengths(x)}, \code{seqlengths(x) <- value}:
      Get or set the sequence lengths.
      \code{seqlengths(x)} is equivalent to \code{seqlengths(seqinfo(x))}.
      \code{value} can be a named non-negative integer or numeric vector
      eventually with NAs.
    }
    \item{}{
      \code{isCircular(x)}, \code{isCircular(x) <- value}:
      Get or set the circularity flags.
      \code{isCircular(x)} is equivalent to \code{isCircular(seqinfo(x))}.
      \code{value} must be a named logical vector eventually with NAs.
    }
    \item{}{
      \code{genome(x)}, \code{genome(x) <- value}:
      Get or set the genome identifier or assembly name for each sequence.
      \code{genome(x)} is equivalent to \code{genome(seqinfo(x))}.
      \code{value} must be a named character vector eventually with NAs.
    }
    \item{}{
      \code{seqnameStyle(x)}:
      List the matching seqname styles for \code{x}.
      \code{seqnameStyle(x)} is equivalent to \code{seqnameStyle(seqinfo(x))}.
      Note that this information is not stored in \code{x} but inferred
      by looking up \code{seqlevels(x)} against a seqname style database
      stored in the seqnames.db metadata package (required).
    }
    \item{}{
      \code{score(x)}: Get the \dQuote{score} column from the element
      metadata, if any.
    }
  }
}

\section{List methods}{
  In the following code snippets, \code{x} is a GRangesList object.

  \describe{
    \item{}{
      \code{length(x)}:
      Get the number of elements.
    }
    \item{}{
      \code{names(x)}, \code{names(x) <- value}:
      Get or set the names of the elements.
    }
    \item{}{
      \code{elementLengths(x)}:
      Get the \code{length} of each of the elements.
    }
    \item{}{
      \code{isEmpty(x)}:
      Returns a logical indicating either if the GRangesList has no
      elements or if all its elements are empty.
    }
  }
}

\section{RangesList methods}{
  In the following code snippets, \code{x} is a GRangesList object.

  \describe{
    \item{}{
      \code{start(x)}, \code{start(x) <- value}:
      Get or set \code{start(ranges(x))}.
    }
    \item{}{
      \code{end(x)}, \code{end(x) <- value}:
      Get or set \code{end(ranges(x))}.
    }
    \item{}{
      \code{width(x)}, \code{width(x) <- value}:
      Get or set \code{width(ranges(x))}.
    }
    \item{}{
      \code{shift(x, shift, use.names=TRUE)}:
      Returns a new GRangesList object containing intervals with start and
      end values that have been shifted by integer vector \code{shift}.
      The \code{use.names} argument determines whether or not to
      keep the names on the ranges.
    }
    \item{}{
      \code{isDisjoint(x)} Return a vector of logical values indicating
      whether the ranges of each element of \code{x} are disjoint
      (i.e. non-overlapping). 
    }
    \item{}{
      \code{disjoin(x, ...)} Returns an object of the same type as
      \code{x} containing disjoint ranges calculated on each element of
      \code{x}.
    }
  }
}

\section{Combining}{
  In the code snippets below, \code{x} is a GRangesList object.

  \describe{
    \item{}{\code{append(x, values, after = length(x))}:
      Inserts the \code{values} into \code{x} at the position given by
      \code{after}, where \code{x} and \code{values} are of the same
      class.
    }
    \item{}{
      \code{c(x, ...)}:
      Combines \code{x} and the GRangesList objects in \code{...}
      together. Any object in \code{...} must belong to the same class
      as \code{x}, or to one of its subclasses, or must be \code{NULL}.
      The result is an object of the same class as \code{x}.
    }
    \item{}{\code{unlist(x, recursive = TRUE, use.names = TRUE)}:
      Concatenates the elements of \code{x} into a single GRanges
      object.
    }
  }
}

\section{Subsetting}{
  In the following code snippets, \code{x} is a GRangesList object.

  \describe{
    \item{}{
      \code{x[i, j]}, \code{x[i, j] <- value}:
      Get or set elements \code{i} with optional metadata columns
      \code{mcols(x)[,j]}, where \code{i} can be missing; an NA-free
      logical, numeric, or character vector; a 'logical' Rle object, or
      an AtomicList object.
    }
    \item{}{
      \code{x[[i]]}, \code{x[[i]] <- value}:
      Get or set element \code{i}, where \code{i} is a numeric or character
      vector of length 1.
    }
    \item{}{
      \code{x$name}, \code{x$name <- value}:
      Get or set element \code{name}, where \code{name} is a name or character
      vector of length 1.
    }
    \item{}{
      \code{head(x, n = 6L)}:
      If \code{n} is non-negative, returns the first n elements of the
      GRangesList object.
      If \code{n} is negative, returns all but the last \code{abs(n)} elements
      of the GRangesList object.
    }
    \item{}{
      \code{rep(x, times, length.out, each)}:
      Repeats the values in \code{x} through one of the following conventions:
      \describe{
        \item{\code{times}}{Vector giving the number of times to repeat each
          element if of length \code{length(x)}, or to repeat the whole vector
          if of length 1.}
        \item{\code{length.out}}{Non-negative integer. The desired length of
          the output vector.}
        \item{\code{each}}{Non-negative integer.  Each element of \code{x} is
          repeated \code{each} times.}
      }
    }
    \item{}{
      \code{seqselect(x, start=NULL, end=NULL, width=NULL)}:
      Similar to \code{window}, except that multiple consecutive subsequences
      can be requested for concatenation. As such two of the three \code{start},
      \code{end}, and \code{width} arguments can be used to specify the
      consecutive subsequences. Alternatively, \code{start} can take a Ranges
      object or something that can be converted to a Ranges object like an
      integer vector, logical vector or logical Rle. If the concatenation of
      the consecutive subsequences is undesirable, consider using
      \code{\link{Views}}.
    }
    \item{}{
      \code{seqselect(x, start=NULL, end=NULL, width=NULL) <- value}:
      Similar to \code{window<-}, except that multiple consecutive subsequences
      can be replaced by a \code{value} whose length is a divisor of the number
      of elements it is replacing. As such two of the three \code{start},
      \code{end}, and \code{width} arguments can be used to specify the
      consecutive subsequences. Alternatively, \code{start} can take a Ranges
      object or something that can be converted to a Ranges object like an
      integer vector, logical vector or logical Rle.
    }
    \item{}{
      \code{subset(x, subset)}:
      Returns a new object of the same class as \code{x} made of the subset
      using logical vector \code{subset}, where missing values are taken as
      \code{FALSE}.
    }
    \item{}{
      \code{tail(x, n = 6L)}:
      If \code{n} is non-negative, returns the last n elements of the
      GRanges object.
      If \code{n} is negative, returns all but the first \code{abs(n)} elements
      of the GRanges object.
    }
    \item{}{
      \code{window(x, start = NA, end = NA, width = NA, frequency = NULL, delta = NULL, ...)}:
      Extracts the subsequence window from the GRanges object using:
      \describe{
        \item{\code{start}, \code{end}, \code{width}}{The start, end, or width
          of the window. Two of the three are required.}
        \item{\code{frequency}, \code{delta}}{Optional arguments that specify
          the sampling frequency and increment within the window.}
      }
      In general, this is more efficient than using \code{"["} operator.
    }
    \item{}{
      \code{window(x, start = NA, end = NA, width = NA, keepLength = TRUE) <- value}:
      Replaces the subsequence window specified on the left (i.e. the subsequence
      in \code{x} specified by \code{start}, \code{end} and \code{width})
      by \code{value}.
      \code{value} must either be of class \code{class(x)}, belong to a subclass
      of \code{class(x)}, be coercible to \code{class(x)}, or be \code{NULL}.
      If \code{keepLength} is \code{TRUE}, the elements of \code{value} are
      repeated to create a GRanges object with the same number of elements
      as the width of the subsequence window it is replacing.
      If \code{keepLength} is \code{FALSE}, this replacement method can modify
      the length of \code{x}, depending on how the length of the left
      subsequence window compares to the length of \code{value}.
    }
  }
}

\section{Looping}{
  In the code snippets below, \code{x} is a GRangesList object.

  \describe{
    \item{}{
      \code{endoapply(X, FUN, ...)}:
      Similar to \code{\link[base]{lapply}}, but performs an endomorphism,
      i.e. returns an object of \code{class(X)}.
    }
    \item{}{
      \code{lapply(X, FUN, ...)}:
      Like the standard \code{\link[base]{lapply}} function defined in the
      base package, the \code{lapply} method for GRangesList objects
      returns a list of the same length as \code{X}, with each element being
      the result of applying \code{FUN} to the corresponding element of
      \code{X}.
    }
    \item{}{
      \code{Map(f, ...)}:
      Applies a function to the corresponding elements of given
      GRangesList objects.
    }
    \item{}{
      \code{mapply(FUN, ..., MoreArgs = NULL, SIMPLIFY = TRUE, USE.NAMES = TRUE)}:
      Like the standard \code{\link[base]{mapply}} function defined in the
      base package, the \code{mapply} method for GRangesList objects is a
      multivariate version of \code{sapply}.
    }
    \item{}{
      \code{mendoapply(FUN, ..., MoreArgs = NULL)}:
      Similar to \code{\link[base]{mapply}}, but performs an endomorphism
      across multiple objects, i.e. returns an object of
      \code{class(list(...)[[1]])}.
    }
    \item{}{
      \code{Reduce(f, x, init, right = FALSE, accumulate = FALSE)}:
      Uses a binary function to successively combine the elements of \code{x}
      and a possibly given initial value.
      \describe{
        \item{f}{A binary argument function.}
        \item{init}{An R object of the same kind as the elements of \code{x}.}
        \item{right}{A logical indicating whether to proceed from left to right
          (default) or from right to left.}
        \item{nomatch}{The value to be returned in the case when "no match" (no
          element satisfying the predicate) is found.}
      }
    }
    \item{}{
      \code{sapply(X, FUN, ..., simplify=TRUE, USE.NAMES=TRUE)}:
      Like the standard \code{\link[base:lapply]{sapply}} function defined in
      the base package, the \code{sapply} method for GRangesList objects
      is a user-friendly version of \code{lapply} by default returning a vector
      or matrix if appropriate.
    }
  }
}

\section{The "range", "reduce" and "restrict" methods}{
  In the code snippets below, \code{x} is a GRangesList object.
  The methods in this section are isomorphisms, that is, they are endomorphisms
  (i.e. they preserve the class of \code{x}) who also preserve the length &
  names & metadata columns of \code{x}. In addition, the seqinfo is preserved
  too.

  \describe{
    \item{}{
      \code{range(x)}:
      Applies \code{range} to each element in \code{x}.
      More precisely, it is equivalent to \code{endoapply(x, range)}.
    }
    \item{}{
      \code{reduce(x, drop.empty.ranges=FALSE, min.gapwidth=1L)}:
      Applies \code{reduce} to each element in \code{x}.
      More precisely, it is equivalent to
      \code{endoapply(x, reduce, drop.empty.ranges=drop.empty.ranges,
                      min.gapwidth=min.gapwidth)}.
    }
    \item{}{
      \code{restrict(x, start = NA, end = NA, keep.all.ranges = FALSE, 
          use.names = TRUE)}:
      Applies \code{restrict} to each element in \code{x}.
    }
    \item{}{
      \code{flank(x, width, start = TRUE, end = NA, keep.all.ranges = FALSE,
          use.names = TRUE, ignore.strand = FALSE)}:
      Applies \code{flank} to each element in \code{x}.
    }
  }
}

\author{P. Aboyoun & H. Pages}

\seealso{
  \link{GRanges-class},
  \code{\link{seqinfo}},
  \link[IRanges]{Vector-class},
  \link[IRanges]{RangesList-class},
  \link[IRanges]{RleList-class},
  \link[IRanges]{DataFrameList-class},
  \link{coverage-methods},
  \link{setops-methods},
  \link{findOverlaps-methods}
}

\examples{
## Construction with GRangesList():
gr1 <-
  GRanges(seqnames = "chr2", ranges = IRanges(3, 6),
          strand = "+", score = 5L, GC = 0.45)
gr2 <-
  GRanges(seqnames = c("chr1", "chr1"),
          ranges = IRanges(c(7,13), width = 3),
          strand = c("+", "-"), score = 3:4, GC = c(0.3, 0.5))
gr3 <-
  GRanges(seqnames = c("chr1", "chr2"),
          ranges = IRanges(c(1, 4), c(3, 9)),
          strand = c("-", "-"), score = c(6L, 2L), GC = c(0.4, 0.1))
grl <- GRangesList("gr1" = gr1, "gr2" = gr2, "gr3" = gr3)
grl

## Summarizing elements:
elementLengths(grl)
table(seqnames(grl))

## Extracting subsets:
grl[seqnames(grl) == "chr1", ]
grl[seqnames(grl) == "chr1" & strand(grl) == "+", ]

## Renaming the underlying sequences:
seqlevels(grl)
seqlevels(grl) <- sub("chr", "Chrom", seqlevels(grl))
grl

## range() and reduce():
range(grl)
reduce(grl)  # Doesn't really reduce anything but note the reordering
             # of the inner elements in the 3rd top-level element: the
             # ranges are reordered by sequence name first (the order of
             # the sequence names is dictated by the sequence levels),
             # and then by strand.
restrict(grl, start=3)
### flank
flank(grl, width =20)

## Coerce to IRangesList (seqnames and strand information is lost):
as(grl, "IRangesList")

## isDisjoint():
isDisjoint(grl)

## disjoin():
disjoin(grl)  # metadata columns and order NOT preserved

## Construction with makeGRangesListFromFeatureFragments():
filepath <- system.file("extdata", "feature_frags.txt",
                        package="GenomicRanges")
featfrags <- read.table(filepath, header=TRUE, stringsAsFactors=FALSE) 
grl2 <- with(featfrags,
             makeGRangesListFromFeatureFragments(seqnames=targetName,
                                                 fragmentStarts=targetStart,
                                                 fragmentWidths=blockSizes,
                                                 strand=strand))
names(grl2) <- featfrags$RefSeqID
grl2
}
