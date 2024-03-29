### =========================================================================
### GappedAlignments objects
### -------------------------------------------------------------------------
###

setClass("GappedAlignments",
    contains="Vector",
    representation(
        NAMES="characterORNULL",      # R doesn't like @names !!
        seqnames="Rle",               # 'factor' Rle
        start="integer",              # POS field in SAM
        cigar="character",            # extended CIGAR (see SAM format specs)
        strand="Rle",                 # 'factor' Rle
        #mismatches="characterORNULL", # see MD optional field in SAM format specs
        elementMetadata="DataFrame",
        seqinfo="Seqinfo"
    ),
    prototype(
        seqnames=Rle(factor()),
        strand=Rle(strand())
    )
)

### Formal API:
###   names(x)    - NULL or character vector.
###   length(x)   - single integer. Nb of alignments in 'x'.
###   seqnames(x) - 'factor' Rle of the same length as 'x'.
###   rname(x)    - same as 'seqnames(x)'.
###   seqnames(x) <- value - replacement form of 'seqnames(x)'.
###   rname(x) <- value - same as 'seqnames(x) <- value'.
###   cigar(x)    - character vector of the same length as 'x'.
###   strand(x)   - 'factor' Rle of the same length as 'x' (levels: +, -, *).
###   qwidth(x)   - integer vector of the same length as 'x'.
###   start(x), end(x), width(x) - integer vectors of the same length as 'x'.
###   ngap(x)     - integer vector of the same length as 'x'.
###   grglist(x)  - GRangesList object of the same length as 'x'.
###   granges(x)  - GRanges object of the same length as 'x'.
###   introns(x)  - Extract the N gaps in a GRangesList object of the same
###                 length as 'x'.
###   rglist(x)   - CompressedIRangesList object of the same length as 'x'.
###   ranges(x)   - IRanges object of the same length as 'x'.
###   as.data.frame(x) - data.frame with 1 row per alignment in 'x'.
###   show(x)     - compact display in a data.frame-like fashion.
###   GappedAlignments(x) - constructor.
###   x[i]        - GappedAlignments object of the same class as 'x'
###                 (endomorphism).
###
###   updateCigarAndStart(x, cigar=NULL, start=NULL) - GappedAlignments
###                 object of the same length and class as 'x' (endomorphism).
###                 For internal use only (NOT EXPORTED).
###
###   qnarrow(x, start=NA, end=NA, width=NA) - GappedAlignments object of the
###                 same length and class as 'x' (endomorphism).
###
###   narrow(x, start=NA, end=NA, width=NA) - GappedAlignments object of the
###                 same length and class as 'x' (endomorphism).
###
###   findOverlaps(query, subject) - 'query' or 'subject' or both are
###                 GappedAlignments objects. Just a convenient wrapper for
###                 'findOverlaps(grglist(query), subject, ...)', etc...
###
###   countOverlaps(query, subject) - 'query' or 'subject' or both are
###                 GappedAlignments objects. Just a convenient wrapper for
###                 'countOverlaps(grglist(query), subject, ...)', etc...
###
###   subsetByOverlaps(query, subject) - 'query' or 'subject' or both are
###                 GappedAlignments objects.
###

setGeneric("rname", function(x) standardGeneric("rname"))
setGeneric("rname<-", function(x, value) standardGeneric("rname<-"))

setGeneric("cigar", function(x) standardGeneric("cigar"))

setGeneric("qwidth", function(x) standardGeneric("qwidth"))

setGeneric("updateCigarAndStart",
    function(x, cigar=NULL, start=NULL) standardGeneric("updateCigarAndStart")
)

setGeneric("qnarrow",
    function(x, start=NA, end=NA, width=NA) standardGeneric("qnarrow")
)


### - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
### Getters.
###

setMethod("length", "GappedAlignments", function(x) length(x@cigar))

setMethod("names", "GappedAlignments", function(x) x@NAMES)

setMethod("seqnames", "GappedAlignments", function(x) x@seqnames)
setMethod("rname", "GappedAlignments", function(x) seqnames(x))

setMethod("cigar", "GappedAlignments", function(x) x@cigar)

setMethod("width", "GappedAlignments", function(x) cigarToWidth(x@cigar))
setMethod("start", "GappedAlignments", function(x, ...) x@start)
setMethod("end", "GappedAlignments", function(x, ...) {x@start + width(x) - 1L})

setMethod("strand", "GappedAlignments", function(x) x@strand)

setMethod("qwidth", "GappedAlignments", function(x) cigarToQWidth(x@cigar))

setMethod("ngap", "GappedAlignments",
    function(x) {unname(elementLengths(rglist(x))) - 1L}
)

setMethod("seqinfo", "GappedAlignments", function(x) x@seqinfo)


### - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
### Setters.
###

setReplaceMethod("names", "GappedAlignments",
    function(x, value)
    {
        if (!is.null(value))
            value <- as.character(value)
        x@NAMES <- value
        validObject(x)
        x
    }
)

.normargSeqnamesReplaceValue <- function(x, value, ans.type=c("factor", "Rle"))
{
    ans.type <- match.arg(ans.type)
    if (!is.factor(value)
     && !is.character(value)
     && (!is(value, "Rle") || !is.character(runValue(value))
                              && !is.factor(runValue(value))))
        stop("'seqnames' value must be a character factor/vector, ",
             "or a 'character' Rle, or a 'factor' Rle")
    if (ans.type == "factor") {
        if (!is.factor(value))
            value <- as.factor(value)
    } else if (ans.type == "Rle") {
        ## We want to return a 'factor' Rle.
        if (!is(value, "Rle")) {
            if (!is.factor(value))
                value <- as.factor(value)
            value <- Rle(value)
        } else if (!is.factor(runValue(value))) {
            runValue(value) <- as.factor(runValue(value))
        }
    }
    if (length(value) != length(x))
        stop("'seqnames' value must be the same length as the object")
    value
}

### 'old_seqnames' and 'new_seqnames' must be 'factor' Rle.
.getSeqnamesTranslationTable <- function(old_seqnames, new_seqnames)
{
    old <- runValue(old_seqnames)
    new <- runValue(new_seqnames)
    tmp <- unique(data.frame(old=old, new=new))
    if (!identical(runLength(old_seqnames), runLength(new_seqnames)) ||
        anyDuplicated(tmp$old) || anyDuplicated(tmp$new))
        stop("mapping between old an new 'seqnames' values is not one-to-one")
    if (isTRUE(all.equal(as.integer(tmp$old), as.integer(tmp$new)))) {
        tr_table <- levels(new)
        names(tr_table) <- levels(old)
    } else {
        tr_table <- tmp$new
        names(tr_table) <- tmp$old
    }
    tr_table
}

setReplaceMethod("seqnames", "GappedAlignments",
    function(x, value)
    {
        value <- .normargSeqnamesReplaceValue(x, value, ans.type="Rle")
        tr_table <- .getSeqnamesTranslationTable(seqnames(x), value)
        x@seqnames <- value
        seqnames(x@seqinfo) <- tr_table[seqlevels(x)]
        x
    }
)

setReplaceMethod("rname", "GappedAlignments",
    function(x, value) `seqnames<-`(x, value)
)

setReplaceMethod("strand", "GappedAlignments",
    function(x, value) 
    {
        x@strand <- normargGenomicRangesStrand(value, length(x))
        x
    }
)

setReplaceMethod("elementMetadata", "GappedAlignments",
    function(x, ..., value)
    {
        x@elementMetadata <- mk_elementMetadataReplacementValue(x, value)
        x
    }
)

setReplaceMethod("seqinfo", "GappedAlignments",
    function(x, new2old=NULL, force=FALSE, value)
    {
        if (!is(value, "Seqinfo"))
            stop("the supplied 'seqinfo' must be a Seqinfo object")
        dangling_seqlevels <- getDanglingSeqlevels(x,
                                  new2old=new2old, force=force,
                                  seqlevels(value))
        if (length(dangling_seqlevels) != 0L)
            x <- x[!(seqnames(x) %in% dangling_seqlevels)]
        x@seqnames <- makeNewSeqnames(x, new2old, seqlevels(value))
        x@seqinfo <- value
        validObject(x)
        x
    }
)


### - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
### Validity.
###

.valid.GappedAlignments.names <- function(x)
{
    x_names <- names(x)
    if (is.null(x_names))
        return(NULL)
    if (!is.character(x_names) || !is.null(attributes(x_names))) {
        msg <- c("'names(x)' must be NULL or a character vector ",
                 "with no attributes")
        return(paste(msg, collapse=""))
    }
    if (length(x_names) != length(x))
        return("'names(x)' and 'x' must have the same length")
    NULL
}

.valid.GappedAlignments.seqnames <- function(x)
{
    x_seqnames <- seqnames(x)
    if (!is(x_seqnames, "Rle") || !is.factor(runValue(x_seqnames))
     || !is.null(names(x_seqnames)) || any(is.na(x_seqnames)))
        return("'seqnames(x)' must be an unnamed 'factor' Rle with no NAs")
    if (length(x_seqnames) != length(cigar(x)))
        return("'seqnames(x)' and 'cigar(x)' must have the same length")
    NULL
}

.valid.GappedAlignments.start <- function(x)
{
    x_start <- start(x)
    if (!is.integer(x_start) || !is.null(names(x_start)) || IRanges:::anyMissing(x_start))
        return("'start(x)' must be an unnamed integer vector with no NAs")
    if (length(x_start) != length(cigar(x)))
        return("'start(x)' and 'cigar(x)' must have the same length")
    NULL
}

.valid.GappedAlignments.cigar <- function(x)
{
    x_cigar <- cigar(x)
    if (!is.character(x_cigar) || !is.null(names(x_cigar)) || any(is.na(x_cigar)))
        return("'cigar(x)' must be an unnamed character vector with no NAs")
    tmp <- validCigar(x_cigar)
    if (!is.null(tmp))
        return(paste("in 'cigar(x)':", tmp))
    NULL
}

.valid.GappedAlignments.strand <- function(x)
{
    x_strand <- strand(x)
    if (!is(x_strand, "Rle") || !is.factor(runValue(x_strand))
     || !identical(levels(runValue(x_strand)), levels(strand()))
     || !is.null(names(x_strand)) || any(is.na(x_strand)))
        return("'strand(x)' must be an unnamed 'factor' Rle with no NAs (and with levels +, - and *)")
    if (length(x_strand) != length(cigar(x)))
        return("'strand(x)' and 'cigar(x)' must have the same length")
    NULL
}

.valid.GappedAlignments <- function(x)
{
    c(.valid.GappedAlignments.names(x),
      .valid.GappedAlignments.seqnames(x),
      .valid.GappedAlignments.start(x),
      .valid.GappedAlignments.cigar(x),
      .valid.GappedAlignments.strand(x),
      valid.GenomicRanges.seqinfo(x))
}

setValidity2("GappedAlignments", .valid.GappedAlignments,
             where=asNamespace("GenomicRanges"))


### - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
### Constructors.
###

.asFactorRle <- function(x)
{
    if (is.character(x)) {
        x <- Rle(as.factor(x))
    } else if (is.factor(x)) {
        x <- Rle(x)
    } else if (is(x, "Rle") && is.character(runValue(x))) {
        runValue(x) <- as.factor(runValue(x))
    } else if (!is(x, "Rle") || !is.factor(runValue(x))) {
        stop("'x' must be a character vector, a factor, ",
             "a 'character' Rle, or a 'factor' Rle")
    }
    x
}

GappedAlignments <- function(seqnames=Rle(factor()), pos=integer(0),
                             cigar=character(0), strand=NULL,
                             names=NULL, seqlengths=NULL, ...)
{
    ## Prepare the 'seqnames' slot.
    seqnames <- .asFactorRle(seqnames)
    if (any(is.na(seqnames)))
        stop("'seqnames' cannot have NAs")
    ## Prepare the 'pos' slot.
    if (!is.integer(pos) || any(is.na(pos)))
        stop("'pos' must be an integer vector with no NAs")
    ## Prepare the 'cigar' slot.
    if (!is.character(cigar) || any(is.na(cigar)))
        stop("'cigar' must be a character vector with no NAs")
    ## Prepare the 'strand' slot.
    if (is.null(strand)) {
        if (length(seqnames) != 0L)
            stop("'strand' must be specified when 'seqnames' is not empty")
        strand <- Rle(strand())
    } else if (is.factor(strand)) {
        strand <- Rle(strand)
    }
    ## Prepare the 'elementMetadata' slot.
    varlist <- list(...)
    elementMetadata <- 
        if (0L == length(varlist))
            new("DataFrame", nrows=length(seqnames))
        else
            do.call(DataFrame, varlist)
    ## Prepare the 'seqinfo' slot.
    if (is.null(seqlengths)) {
        seqlengths <- rep(NA_integer_, length(levels(seqnames)))
        names(seqlengths) <- levels(seqnames)
    } else if (!is.numeric(seqlengths)
            || is.null(names(seqlengths))
            || any(duplicated(names(seqlengths)))) {
        stop("'seqlengths' must be an integer vector with unique names")
    } else if (!setequal(names(seqlengths), levels(seqnames))) {
        stop("'names(seqlengths)' incompatible with 'levels(seqnames)'")
    } else if (!is.integer(seqlengths)) { 
        storage.mode(seqlengths) <- "integer"
    }
    seqinfo <- Seqinfo(seqnames=names(seqlengths), seqlengths=seqlengths)
    ## Create and return the GappedAlignments instance.
    new("GappedAlignments", NAMES=names,
                            seqnames=seqnames, start=pos, cigar=cigar,
                            strand=strand,
                            elementMetadata=elementMetadata,
                            seqinfo=seqinfo)
}

setMethod("updateObject", "GappedAlignments",
    function(object, ..., verbose=FALSE)
    {
        if (verbose)
            message("updateObject(object = 'GappedAlignments')")
        if (is(try(object@NAMES, silent=TRUE), "try-error")) {
            object@NAMES <- NULL
            return(object)
        }
        if (is(try(validObject(object@seqinfo, complete=TRUE), silent=TRUE),
               "try-error")) {
            object@seqinfo <- updateObject(object@seqinfo)
            return(object)
        }
        object
    }
)

readGappedAlignments <- function(file, format="BAM", use.names=FALSE, ...)
{
    if (!isSingleString(file))
        stop("'file' must be a single string")
    if (!isSingleString(format))
        stop("'format' must be a single string")
    if (!isTRUEorFALSE(use.names))
        stop("'use.names' must be TRUE or FALSE")
    if (format == "BAM") {
        suppressMessages(library("Rsamtools"))
        ans <- readBamGappedAlignments(file=file, use.names=use.names, ...)
        return(ans)
    }
    stop("only BAM format is supported at the moment")
}


### - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
### Three helper functions used by higher level coercion functions.
###
### Note that their arguments are the different components of a
### GappedAlignments object instead of just the GappedAlignments object
### itself (arg 'x'). This allows them to be used in many different contexts
### e.g. when 'x' doesn't exist yet but is in the process of being constructed.
###

.GappedAlignmentsToGRanges <- function(seqnames, start, width, strand, seqinfo,
                                       names=NULL)
{
    ranges <- IRanges(start=start, width=width, names=names)
    ans <- GRanges(seqnames=seqnames, ranges=ranges, strand=strand)
    seqinfo(ans) <- seqinfo
    ans
}

### Names are propagated via 'x@partitioning' ('x' is a CompressedIRangesList).
.CompressedIRangesListToGRangesList <- function(x, seqnames, strand, seqinfo)
{
    elt_lens <- elementLengths(x)
    seqnames <- rep.int(seqnames, elt_lens)
    strand <- rep.int(strand, elt_lens)
    unlistData <- GRanges(seqnames=seqnames,
                          ranges=x@unlistData,
                          strand=strand)
    seqinfo(unlistData) <- seqinfo
    new("GRangesList",
        unlistData=unlistData,
        partitioning=x@partitioning,
        elementMetadata=x@elementMetadata)
}


### - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
### Coercion.
###

setGeneric("grglist", function(x, ...) standardGeneric("grglist"))
setGeneric("granges", function(x, ...) standardGeneric("granges"))
setGeneric("introns", function(x, ...) standardGeneric("introns"))
setGeneric("rglist", function(x, ...) standardGeneric("rglist"))

setMethod("grglist", "GappedAlignments",
    function(x, order.as.in.query=FALSE, drop.D.ranges=FALSE)
    {
        rgl <- rglist(x,
                   order.as.in.query=order.as.in.query,
                   drop.D.ranges=drop.D.ranges)
        .CompressedIRangesListToGRangesList(rgl, seqnames(x), strand(x),
                                            seqinfo(x))
    }
)

setMethod("granges", "GappedAlignments",
    function(x)
        .GappedAlignmentsToGRanges(seqnames(x), start(x), width(x),
                                   strand(x), seqinfo(x), names(x))
)

setMethod("introns", "GappedAlignments",
    function(x)
    {
        grl <- grglist(x, order.as.in.query=TRUE)
        psetdiff(granges(x), grl)
    }
)

setMethod("rglist", "GappedAlignments",
    function(x, order.as.in.query=FALSE, drop.D.ranges=FALSE)
    {
        if (!isTRUEorFALSE(order.as.in.query))
            stop("'reorder.ranges.from5to3' must be TRUE or FALSE")
        ans <- cigarToIRangesListByAlignment(x@cigar, x@start,
                                             drop.D.ranges=drop.D.ranges)
        if (order.as.in.query)
            ans <- revElements(ans, strand(x) == "-")
        names(ans) <- names(x)
        mcols(ans) <- mcols(x)
        ans
    }
)

setMethod("ranges", "GappedAlignments",
    function(x) IRanges(start=start(x), width=width(x), names=names(x))
)

setAs("GappedAlignments", "GRangesList", function(from) grglist(from))
setAs("GappedAlignments", "GRanges", function(from) granges(from))
setAs("GappedAlignments", "RangesList", function(from) rglist(from))
setAs("GappedAlignments", "Ranges", function(from) ranges(from))

setMethod("as.data.frame", "GappedAlignments",
    function(x, row.names=NULL, optional=FALSE, ...)
    {
        if (is.null(row.names))
            row.names <- names(x)
        else if (!is.character(row.names))
            stop("'row.names' must be NULL or a character vector")
        ans <- data.frame(seqnames=as.character(seqnames(x)),
                          strand=as.character(strand(x)),
                          cigar=cigar(x),
                          qwidth=qwidth(x),
                          start=start(x),
                          end=end(x),
                          width=width(x),
                          ngap=ngap(x),
                          row.names=row.names,
                          check.rows=TRUE,
                          check.names=FALSE,
                          stringsAsFactors=FALSE)
        if (ncol(mcols(x)))
            ans <- cbind(ans, as.data.frame(mcols(x)))
        return(ans)
    }
)

setAs("GenomicRanges", "GappedAlignments",
      function(from) {
        ga <-
          GappedAlignments(seqnames(from), start(from),
                           if (!is.null(mcols(from)[["cigar"]]))
                             mcols(from)[["cigar"]]
                           else paste0(width(from), "M"),
                           strand(from),
                           if (!is.null(names(from))) names(from)
                           else mcols(from)$name,
                           seqlengths(from),
                           mcols(from)[setdiff(colnames(mcols(from)),
                                               c("cigar", "name"))])
        metadata(ga) <- metadata(from)
        seqinfo(ga) <- seqinfo(from)
        ga
      })


### - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
### Subsetting.
###

### Supported 'i' types: numeric vector, logical vector, NULL and missing.
### TODO: Support subsetting by names.
setMethod("[", "GappedAlignments",
    function(x, i, j, ... , drop=TRUE)
    {
        if (!missing(j) || length(list(...)) > 0L)
            stop("invalid subsetting")
        if (missing(i))
            return(x)
        if (is(i, "Rle"))
            i <- as.vector(i)
        if (!is.atomic(i))
            stop("invalid subscript type")
        lx <- length(x)
        if (length(i) == 0L) {
            i <- integer(0)
        } else if (is.numeric(i)) {
            if (min(i) < 0L)
                i <- seq_len(lx)[i]
            else if (!is.integer(i))
                i <- as.integer(i)
        } else if (is.logical(i)) {
            if (length(i) > lx)
                stop("subscript out of bounds")
            i <- seq_len(lx)[i]
        } else {
            stop("invalid subscript type")
        }
        x@NAMES <- x@NAMES[i]
        x@seqnames <- x@seqnames[i]
        x@start <- x@start[i]
        x@cigar <- x@cigar[i]
        x@strand <- x@strand[i]
        x@elementMetadata <- x@elementMetadata[i,,drop=FALSE]
        x
    }
)


### - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
### "show" method.
###

.makeNakedMatFromGappedAlignments <- function(x)
{
    lx <- length(x)
    nc <- ncol(mcols(x))
    ans <- cbind(seqnames=as.character(seqnames(x)),
                 strand=as.character(strand(x)),
                 cigar=cigar(x),
                 qwidth=qwidth(x),
                 start=start(x),
                 end=end(x),
                 width=width(x),
                 ngap=ngap(x))
    if (nc > 0L) {
        tmp <- do.call(data.frame, lapply(mcols(x),
                                          IRanges:::showAsCell))
        ans <- cbind(ans, `|`=rep.int("|", lx), as.matrix(tmp))
    }
    ans
}

showGappedAlignments <- function(x, margin="",
                                 with.classinfo=FALSE, print.seqlengths=FALSE)
{
    lx <- length(x)
    nc <- ncol(mcols(x))
    cat(class(x), " with ",
        lx, " ", ifelse(lx == 1L, "alignment", "alignments"),
        " and ",
        nc, " metadata ", ifelse(nc == 1L, "column", "columns"),
        ":\n", sep="")
    out <- makePrettyMatrixForCompactPrinting(x,
               .makeNakedMatFromGappedAlignments)
    if (with.classinfo) {
        .COL2CLASS <- c(
            seqnames="Rle",
            strand="Rle",
            cigar="character",
            qwidth="integer",
            start="integer",
            end="integer",
            width="integer",
            ngap="integer"
        )
        classinfo <- makeClassinfoRowForCompactPrinting(x, .COL2CLASS)
        ## A sanity check, but this should never happen!
        stopifnot(identical(colnames(classinfo), colnames(out)))
        out <- rbind(classinfo, out)
    }
    if (nrow(out) != 0L)
        rownames(out) <- paste0(margin, rownames(out))
    print(out, quote=FALSE, right=TRUE)
    if (print.seqlengths) {
        cat(margin, "---\n", sep="")
        showSeqlengths(x, margin=margin)
    }
}

setMethod("show", "GappedAlignments",
    function(object)
        showGappedAlignments(object, margin="  ",
                             with.classinfo=TRUE, print.seqlengths=TRUE)
)


### - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
### Combining and concatenation.
###

setMethod("c", "GappedAlignments", function (x, ..., recursive=FALSE) {
  if (!identical(recursive, FALSE))
    stop("'recursive' argument not supported")
  if (missing(x)) {
    args <- unname(list(...))
    x <- args[[1L]]
  }
  else {
    args <- unname(list(x, ...))
  }
  
  if (length(args) == 1L)
    return(x)
  
  arg_is_null <- sapply(args, is.null)
  if (any(arg_is_null))
    args[arg_is_null] <- NULL
  if (!all(sapply(args, is, class(x))))
    stop("all arguments in '...' must be ", class(x), " objects (or NULLs)")
 
  new_NAMES <- unlist(lapply(args, function(i) i@NAMES), use.names=FALSE)
  new_seqnames <- do.call(c, lapply(args, seqnames))
  new_start <- unlist(lapply(args, function(i) i@start), use.names=FALSE)
  new_cigar <- unlist(lapply(args, function(i) i@cigar), use.names=FALSE)
  new_strand <- do.call(c, lapply(args, function(i) i@strand))
  new_seqinfo <- do.call(merge, lapply(args, seqinfo))
  new_elementMetadata <- do.call(rbind, lapply(args, elementMetadata))
  
  initialize(x,
             NAMES=new_NAMES,
             start=new_start,
             seqnames=new_seqnames,
             strand=new_strand,
             cigar=new_cigar,
             seqinfo=new_seqinfo,
             elementMetadata=new_elementMetadata)
})


### - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
### The "updateCigarAndStart" method.
###
### Performs atomic update of the cigar/start information.
### For internal use only (not exported).
###

setMethod("updateCigarAndStart", "GappedAlignments",
    function(x, cigar=NULL, start=NULL)
    {
        if (is.null(cigar)) {
            cigar <- cigar(x)
        } else {
            if (!is.character(cigar) || length(cigar) != length(x))
                stop("when not NULL, 'cigar' must be a character vector ",
                     "of the same length as 'x'")
            ## There might be an "rshift" attribute on 'cigar', typically.
            ## We want to get rid of it as well as any other potential
            ## attribute like names, dim, dimnames etc...
            attributes(cigar) <- NULL
        }
        if (is.null(start))
            start <- start(x)
        else if (!is.integer(start) || length(start) != length(x))
            stop("when not NULL, 'start' must be an integer vector ",
                 "of the same length as 'x'")
        x@cigar <- cigar
        x@start <- start
        x
    }
)


### - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
### The "qnarrow" and "narrow" methods.
###

setMethod("qnarrow", "GappedAlignments",
    function(x, start=NA, end=NA, width=NA)
    {
        ans_cigar <- cigarQNarrow(cigar(x),
                                  start=start, end=end, width=width)
        ans_start <- start(x) + attr(ans_cigar, "rshift")
        updateCigarAndStart(x, cigar=ans_cigar, start=ans_start)
    }
)

setMethod("narrow", "GappedAlignments",
    function(x, start=NA, end=NA, width=NA, use.names=TRUE)
    {
        ans_cigar <- cigarNarrow(cigar(x),
                                 start=start, end=end, width=width)
        ans_start <- start(x) + attr(ans_cigar, "rshift")
        updateCigarAndStart(x, cigar=ans_cigar, start=ans_start)
    }
)

### - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
### Mapping
###

setMethod("map", c("GenomicRanges", "GappedAlignments"), function(from, to) {
  to_grl <- grglist(to, drop.D.ranges=TRUE)
  from_ol <- findOverlaps(from, to_grl, ignore.strand=TRUE, type="within")
  to_hits <- to[subjectHits(from_ol)]
  starts <- .Call("ref_locs_to_query_locs", start(from)[queryHits(from_ol)],
                  cigar(to_hits), start(to_hits), PACKAGE="GenomicRanges")
  ends <- .Call("ref_locs_to_query_locs", end(from)[queryHits(from_ol)],
                cigar(to_hits), start(to_hits), PACKAGE="GenomicRanges")
  space <- names(to_hits)
  if (is.null(space))
    space <- as.character(seq_len(length(to))[subjectHits(from_ol)])
  new("RangesMapping", hits=from_ol, space=Rle(space),
      ranges=IRanges(starts, ends))
})

### - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
### Old stuff (deprecated or defunct).
###

grg <- function(x, ...)
{
    .Defunct("granges")
}

