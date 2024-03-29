### =========================================================================
### GappedAlignmentPairs objects
### -------------------------------------------------------------------------
###

### TODO: Implement a GappedAlignmentList class (CompressedList subclass)
### and derive GappedAlignmentPairs from it.

### "first" and "last" GappedAlignments must have identical seqinfo.
setClass("GappedAlignmentPairs",
    contains="List",
    representation(
        NAMES="characterORNULL",      # R doesn't like @names !!
        first="GappedAlignments",     # of length N, no names, no elt metadata
        last="GappedAlignments",      # of length N, no names, no elt metadata
        isProperPair="logical",       # of length N
        elementMetadata="DataFrame"   # N rows
    ),
    prototype(
        elementType="GappedAlignments"
    )
)

### Formal API:
###   length(x)   - single integer N. Nb of pairs in 'x'.
###   names(x)    - NULL or character vector.
###   first(x)    - returns "first" slot.
###   last(x)     - returns "last" slot.
###   left(x)     - GappedAlignments made of the "left alignments" (if first
###                 alignment is on + strand then it's considered to be the
###                 "left alignment", otherwise, it's considered the "right
###                 alignment").
###   right(x)    - GappedAlignments made of the "right alignments".
###                 The strand of the last alignments is inverted before they
###                 are stored in the GappedAlignments returned by left(x) or
###                 right(x).
###   seqnames(x) - same as 'seqnames(first(x))' or 'seqnames(last(x))'.
###   strand(x)   - same as 'strand(first(x))' (opposite of 'strand(last(x))').
###   ngap(x)     - same as 'ngap(first(x)) + ngap(last(x))'.
###   isProperPair(x) - returns "isProperPair" slot.
###   seqinfo(x)  - returns 'seqinfo(first(x))' (same as 'seqinfo(last(x))').
###   grglist(x)  - GRangesList object of the same length as 'x'.
###   introns(x)  - Extract the N gaps in a GRangesList object of the same
###                 length as 'x'.
###   show(x)     - compact display in a data.frame-like fashion.
###   GappedAlignmentPairs(x) - constructor.
###   x[i]        - GappedAlignmentPairs object of the same class as 'x'
###                 (endomorphism).
###

setGeneric("first", function(x, ...) standardGeneric("first"))
setGeneric("last", function(x, ...) standardGeneric("last"))
setGeneric("left", function(x, ...) standardGeneric("left"))
setGeneric("right", function(x, ...) standardGeneric("right"))
setGeneric("isProperPair", function(x) standardGeneric("isProperPair"))


### - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
### Getters.
###

setMethod("length", "GappedAlignmentPairs",
    function(x) length(x@first)
)

setMethod("names", "GappedAlignmentPairs",
    function(x) x@NAMES
)

setMethod("first", "GappedAlignmentPairs",
    function(x, invert.strand=FALSE)
    {
        if (!isTRUEorFALSE(invert.strand))
            stop("'invert.strand' must be TRUE or FALSE")
        ans <- setNames(x@first, names(x))
        if (invert.strand)
            ans <- invertRleStrand(ans)
        ans
    }
)

setMethod("last", "GappedAlignmentPairs",
    function(x, invert.strand=FALSE)
    {
        if (!isTRUEorFALSE(invert.strand))
            stop("'invert.strand' must be TRUE or FALSE")
        ans <- setNames(x@last, names(x))
        if (invert.strand)
            ans <- invertRleStrand(ans)
        ans
    }
)

setMethod("left", "GappedAlignmentPairs",
    function(x, ...)
    {
        x_first <- x@first
        x_last <- invertRleStrand(x@last)

        left_is_last <- which(strand(x_first) == "-")
        idx <- seq_len(length(x))
        idx[left_is_last] <- idx[left_is_last] + length(x)

        ans <- c(x_first, x_last)[idx]
        setNames(ans, names(x))
    }
)

setMethod("right", "GappedAlignmentPairs",
    function(x, ...)
    {
        x_first <- x@first
        x_last <- invertRleStrand(x@last)

        right_is_first <- which(strand(x_first) == "-")
        idx <- seq_len(length(x))
        idx[right_is_first] <- idx[right_is_first] + length(x)

        ans <- c(x_last, x_first)[idx]
        setNames(ans, names(x))
    }
)

setMethod("seqnames", "GappedAlignmentPairs",
    function(x) seqnames(x@first)
)

setMethod("strand", "GappedAlignmentPairs",
    function(x) strand(x@first)
)

setMethod("ngap", "GappedAlignmentPairs",
    function(x) {ngap(x@first) + ngap(x@last)}
)

setMethod("isProperPair", "GappedAlignmentPairs",
    function(x) x@isProperPair
)

setMethod("seqinfo", "GappedAlignmentPairs",
    function(x) seqinfo(x@first)
)


### - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
### Setters.
###

setReplaceMethod("names", "GappedAlignmentPairs",
    function(x, value)
    {
        if (!is.null(value))
            value <- as.character(value)
        x@NAMES <- value
        validObject(x)
        x
    }
)

setReplaceMethod("elementMetadata", "GappedAlignmentPairs",
    function(x, ..., value)
    {
        x@elementMetadata <- mk_elementMetadataReplacementValue(x, value)
        x
    }
)

setReplaceMethod("seqinfo", "GappedAlignmentPairs",
    function(x, new2old=NULL, force=FALSE, value)
    {
        if (!is(value, "Seqinfo"))
            stop("the supplied 'seqinfo' must be a Seqinfo object")
        first <- x@first
        last <- x@last
        dangling_seqlevels_in_first <- getDanglingSeqlevels(first,
                                           new2old=new2old, force=force,
                                           seqlevels(value))
        dangling_seqlevels_in_last <- getDanglingSeqlevels(last,
                                           new2old=new2old, force=force,
                                           seqlevels(value))
        dangling_seqlevels <- union(dangling_seqlevels_in_first,
                                    dangling_seqlevels_in_last)
        if (length(dangling_seqlevels) != 0L) {
            dropme_in_first <- seqnames(first) %in% dangling_seqlevels_in_first
            dropme_in_last <- seqnames(last) %in% dangling_seqlevels_in_last
            dropme <- dropme_in_first | dropme_in_last
            x <- x[!dropme]
        }
        seqinfo(x@first, new2old=new2old) <- value
        seqinfo(x@last, new2old=new2old) <- value
        x
    }
)


### - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
### Validity.
###

.valid.GappedAlignmentPairs.names <- function(x)
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

.valid.GappedAlignmentPairs.first <- function(x)
{
    x_first <- x@first
    if (class(x_first) != "GappedAlignments")
        return("'x@first' must be a GappedAlignments instance")
    NULL
}

.valid.GappedAlignmentPairs.last <- function(x)
{
    x_last <- x@last
    if (class(x_last) != "GappedAlignments")
        return("'x@last' must be a GappedAlignments instance")
    x_first <- x@first
    if (length(x_last) != length(x_first))
        return("'x@last' and 'x@first' must have the same length")
    if (!identical(seqinfo(x_last), seqinfo(x_first)))
        return("'seqinfo(x@last)' and 'seqinfo(x@first)' must be identical")
    NULL
}

.valid.GappedAlignmentPairs.isProperPair <- function(x)
{
    x_isProperPair <- x@isProperPair
    if (!is.logical(x_isProperPair) || !is.null(attributes(x_isProperPair))) {
        msg <- c("'x@isProperPair' must be a logical vector ",
                 "with no attributes")
        return(paste(msg, collapse=""))
    }
    if (length(x_isProperPair) != length(x))
        return("'x@isProperPair' and 'x' must have the same length")
    if (IRanges:::anyMissing(x_isProperPair))
        return("'x@isProperPair' cannot contain NAs")
    NULL
}

.valid.GappedAlignmentPairs <- function(x)
{
    c(.valid.GappedAlignmentPairs.names(x),
      .valid.GappedAlignmentPairs.first(x),
      .valid.GappedAlignmentPairs.last(x),
      .valid.GappedAlignmentPairs.isProperPair(x))
}

setValidity2("GappedAlignmentPairs", .valid.GappedAlignmentPairs,
             where=asNamespace("GenomicRanges"))


### - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
### Constructors.
###

GappedAlignmentPairs <- function(first, last, isProperPair, names=NULL)
{
    new2("GappedAlignmentPairs",
         NAMES=names,
         first=first, last=last,
         isProperPair=isProperPair,
         elementMetadata=new("DataFrame", nrows=length(first)),
         check=TRUE)
}

readGappedAlignmentPairs <- function(file, format="BAM", use.names=FALSE, ...)
{
    if (!isSingleString(file))
        stop("'file' must be a single string")
    if (!isSingleString(format))
        stop("'format' must be a single string")
    if (!isTRUEorFALSE(use.names))
        stop("'use.names' must be TRUE or FALSE")
    if (format == "BAM") {
        suppressMessages(library("Rsamtools"))
        ans <- readBamGappedAlignmentPairs(file=file, use.names=use.names, ...)
        return(ans)
    }
    stop("only BAM format is supported at the moment")
}


### - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
### Vector methods.
###

setMethod("[", "GappedAlignmentPairs",
    function(x, i, j, ... , drop=TRUE)
    {
        if (!missing(j) || length(list(...)) > 0L)
            stop("invalid subsetting")
        if (missing(i))
            return(x)
        i <- IRanges:::normalizeSingleBracketSubscript(i, x)
        x@NAMES <- x@NAMES[i]
        x@first <- x@first[i]
        x@last <- x@last[i]
        x@isProperPair <- x@isProperPair[i]
        x@elementMetadata <- x@elementMetadata[i, , drop=FALSE]
        x
    }
)


### - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
### List methods.
###

### TODO: Remove the "[[" method below after the definition of the
### GappedAlignmentPairs class is changed to derive from CompressedList.
### (The "[[" method for CompressedList objects should do just fine i.e. it
### should do something like x@unlistData[x@partitioning[[i]]] and that
### should be optimal.)
.GappedAlignmentPairs.getElement <- function(x, i)
{
    c(x@first[i], x@last[i])
}

setMethod("[[", "GappedAlignmentPairs",
    function(x, i, j, ... , drop=TRUE)
    {
        if (missing(i) || !missing(j) || length(list(...)) > 0L)
            stop("invalid subsetting")
        i <- IRanges:::checkAndTranslateDbleBracketSubscript(x, i)
        .GappedAlignmentPairs.getElement(x, i)
    }
)

.makePickupIndex <- function(N)
{
    ans <- rep(seq_len(N), each=2L)
    if (length(ans) != 0L)
        ans[c(FALSE, TRUE)] <- ans[c(FALSE, TRUE)] + N
    ans
}

### TODO: Remove this method after the definition of the GappedAlignmentPairs
### class is changed to derive from CompressedList.
setMethod("unlist", "GappedAlignmentPairs",
    function(x, recursive=TRUE, use.names=TRUE)
    {
        if (!isTRUEorFALSE(use.names))
            stop("'use.names' must be TRUE or FALSE")
        x_first <- x@first
        x_last <- x@last
        ans <- c(x_first, x_last)[.makePickupIndex(length(x))]
        if (use.names)
            names(ans) <- rep(names(x), each=2L)
        ans
    }
)


### - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
### Coercion.
###

### Shrink CompressedList 'x' (typically a GRangesList) by half by combining
### pairs of consecutive top-level elements.
.shrinkByHalf <- function(x)
{
    if (length(x) %% 2L != 0L)
        stop("'x' must have an even length")
    x_elt_lens <- elementLengths(x)
    if (length(x_elt_lens) == 0L) {
        ans_nelt1 <- ans_nelt2 <- integer(0)
    } else {
        ans_nelt1 <- x_elt_lens[c(TRUE, FALSE)]
        ans_nelt2 <- x_elt_lens[c(FALSE, TRUE)]
    }
    ans_elt_lens <- ans_nelt1 + ans_nelt2
    ans_partitioning <- PartitioningByEnd(cumsum(ans_elt_lens))
    ans <- relist(x@unlistData, ans_partitioning)
    mcols(ans) <- DataFrame(nelt1=ans_nelt1, nelt2=ans_nelt2)
    ans
}

setMethod("grglist", "GappedAlignmentPairs",
    function(x, order.as.in.query=FALSE, drop.D.ranges=FALSE)
    {
        if (!isTRUEorFALSE(order.as.in.query))
            stop("'order.as.in.query' must be TRUE or FALSE")
        x_mcols <- mcols(x)
        if ("query.break" %in% colnames(x_mcols))
            stop("'mcols(x)' cannot have reserved column \"query.break\"")
        x_first <- x@first
        x_last <- invertRleStrand(x@last)
        ## Not the same as doing 'unlist(x, use.names=FALSE)'.
        x_unlisted <- c(x_first, x_last)[.makePickupIndex(length(x))]
        grl <- grglist(x_unlisted,
                       order.as.in.query=TRUE,
                       drop.D.ranges=drop.D.ranges)
        ans <- .shrinkByHalf(grl)
        ans_nelt1 <- mcols(ans)$nelt1
        if (!order.as.in.query) {
            ans_nelt2 <- mcols(ans)$nelt2
            ## Yes, we reorder *again* when 'order.as.in.query' is FALSE.
            i <- which(strand(x) == "-")
            ans <- revElements(ans, i)
            ans_nelt1[i] <- ans_nelt2[i]
        }
        names(ans) <- names(x)
        x_mcols$query.break <- ans_nelt1
        mcols(ans) <- x_mcols
        ans
    }
)

setMethod("introns", "GappedAlignmentPairs",
    function(x)
    {
        first_introns <- introns(x@first)
        last_introns <- introns(invertRleStrand(x@last))
        ## Fast way of doing mendoapply(c, first_introns, last_introns)
        ## on 2 CompressedList objects.
        ans <- c(first_introns, last_introns)
        ans <- ans[.makePickupIndex(length(x))]
        ans <- .shrinkByHalf(ans)
        mcols(ans) <- NULL
        ans
    }
)

setAs("GappedAlignmentPairs", "GRangesList", function(from) grglist(from))


### - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
### "show" method.
###

.makeNakedMatFromGappedAlignmentPairs <- function(x)
{
    lx <- length(x)
    nc <- ncol(mcols(x))
    pair_cols <- cbind(seqnames=as.character(seqnames(x)),
                       strand=as.character(strand(x)))
    x_first <- x@first
    first_cols <- cbind(ranges=IRanges:::showAsCell(ranges(x_first)))
    x_last <- x@last
    last_cols <- cbind(ranges=IRanges:::showAsCell(ranges(x_last)))
    ans <- cbind(pair_cols,
                 `:`=rep.int(":", lx),
                 first_cols,
                 `--`=rep.int("--", lx),
                 last_cols)
    if (nc > 0L) {
        tmp <- do.call(data.frame, lapply(mcols(x),
                                          IRanges:::showAsCell))
        ans <- cbind(ans, `|`=rep.int("|", lx), as.matrix(tmp))
    }
    ans
}

showGappedAlignmentPairs <- function(x, margin="",
                                        with.classinfo=FALSE,
                                        print.seqlengths=FALSE)
{
    lx <- length(x)
    nc <- ncol(mcols(x))
    cat(class(x), " with ",
        lx, " alignment ", ifelse(lx == 1L, "pair", "pairs"),
        " and ",
        nc, " metadata ", ifelse(nc == 1L, "column", "columns"),
        ":\n", sep="")
    out <- makePrettyMatrixForCompactPrinting(x,
               .makeNakedMatFromGappedAlignmentPairs)
    if (with.classinfo) {
        .PAIR_COL2CLASS <- c(
            seqnames="Rle",
            strand="Rle"
        )
        .HALVES_COL2CLASS <- c(
            ranges="IRanges"
        )
        .COL2CLASS <- c(.PAIR_COL2CLASS,
                        ":",
                        .HALVES_COL2CLASS,
                        "--",
                        .HALVES_COL2CLASS)
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

setMethod("show", "GappedAlignmentPairs",
    function(object)
        showGappedAlignmentPairs(object,
                                 with.classinfo=TRUE, print.seqlengths=TRUE)
)

