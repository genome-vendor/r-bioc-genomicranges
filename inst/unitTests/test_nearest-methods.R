test_GenomicRanges_findNearest0 <- function()
{
    .findNearest <- GenomicRanges:::.GenomicRanges_findNearest0
    sentinel <- c(0, 20) 
    subject <- c(5, 15) 

    hits <- .findNearest(10, subject, sentinel, TRUE)
    checkIdentical(2L, subjectHits(hits))
    hits <- .findNearest(10, subject, sentinel, FALSE)
    checkIdentical(1L, subjectHits(hits))

    hits <- .findNearest(5, subject, sentinel, TRUE)
    checkIdentical(2L, subjectHits(hits))
    hits <- .findNearest(15, subject, sentinel, FALSE)
    checkIdentical(1L, subjectHits(hits))
 
    hits <- .findNearest(5, subject, sentinel, FALSE)
    checkIdentical(integer(), subjectHits(hits))
    hits <- .findNearest(15, subject, sentinel, TRUE)
    checkIdentical(integer(), subjectHits(hits))

    subject <- c(15, 5)
    hits <- .findNearest(10, subject, sentinel, TRUE)
    checkIdentical(1L, subjectHits(hits))
    hits <- .findNearest(10, subject, sentinel, FALSE)
    checkIdentical(2L, subjectHits(hits))
}

test_GenomicRanges_precede_follow <- function()
{
    ## query on "+"
    query <- GRanges("A", IRanges(c(1, 5, 10, 15, 20), width=1), "+")
    subject <- GRanges("A", IRanges(c(5, 15), width=1), "+")
    hits <- precede(query, subject)
    checkIdentical(c(1L, 2L, 2L, NA_integer_, NA_integer_), hits)
    hits <- follow(query, subject)
    checkIdentical(c(NA_integer_, NA_integer_, 1L, 1L, 2L), hits)

    subject <- GRanges("A", IRanges(c(5, 15), width=1), "-")
    hits <- precede(query, subject)
    checkIdentical(rep(NA_integer_, length(query)), hits)
    hits <- follow(query, subject)
    checkIdentical(rep(NA_integer_, length(query)), hits)

    subject <- GRanges("A", IRanges(c(5, 15), width=1), "*")
    hits <- precede(query, subject)
    checkIdentical(c(1L, 2L, 2L, NA_integer_, NA_integer_), hits)
    hits <- follow(query, subject)
    checkIdentical(c(NA_integer_, NA_integer_, 1L, 1L, 2L), hits)

    ## query on "-"
    query <- GRanges("A", IRanges(c(1, 5, 10, 15, 20), width=1), "-")
    subject <- GRanges("A", IRanges(c(5, 15), width=1), "-")
    hits <- precede(query, subject)
    checkIdentical(c(NA_integer_, NA_integer_, 1L, 1L, 2L), hits)
    hits <- follow(query, subject)
    checkIdentical(c(1L, 2L, 2L, NA_integer_, NA_integer_), hits)

    subject <- GRanges("A", IRanges(c(5, 15), width=1), "+")
    hits <- precede(query, subject)
    checkIdentical(rep(NA_integer_, length(query)), hits)
    hits <- follow(query, subject)
    checkIdentical(rep(NA_integer_, length(query)), hits)

    subject <- GRanges("A", IRanges(c(5, 15), width=1), "*")
    hits <- precede(query, subject)
    checkIdentical(c(NA_integer_, NA_integer_, 1L, 1L, 2L), hits)
    hits <- follow(query, subject)
    checkIdentical(c(1L, 2L, 2L, NA_integer_, NA_integer_), hits)

    ## query on "*"
    query <- GRanges("A", IRanges(c(1, 5, 10, 15, 20), width=1), "*")
    subject <- GRanges("A", IRanges(c(5, 15), width=1), "+")
    hits <- precede(query, subject)
    checkIdentical(c(1L, 2L, 2L, NA_integer_, NA_integer_), hits)
    hits <- follow(query, subject)
    checkIdentical(c(NA_integer_, NA_integer_, 1L, 1L, 2L), hits)

    subject <- GRanges("A", IRanges(c(5, 15), width=1), "-")
    hits <- precede(query, subject)
    checkIdentical(c(NA_integer_, NA_integer_, 1L, 1L, 2L), hits)
    hits <- follow(query, subject)
    checkIdentical(c(1L, 2L, 2L, NA_integer_, NA_integer_), hits)

    subject <- GRanges("A", IRanges(c(5, 15), width=1), "*")
    hits <- precede(query, subject)
    checkIdentical(c(1L, 2L, 1L, 1L, 2L), hits)
    hits <- follow(query, subject)
    checkIdentical(c(1L, 2L, 1L, 1L, 2L), hits)
}

test_GenomicRanges_precede_follow_ties <- function()
{
    query <- GRanges("A", IRanges(10, width=1), c("+", "-", "*"))
    subject <- GRanges("A", IRanges(c(5, 5, 5, 15, 15, 15), width=1),
                       rep(c("+", "-", "*"), 2))
    checkIdentical(c(4L, 2L, 2L), precede(query, subject))
    checkIdentical(c(1L, 4L, 1L), precede(query, rev(subject)))
}

test_GenomicRanges_precede_follow_0width <- function()
{
    a <- GRanges("A", IRanges(100, width=0), "*")
    b <- GRanges("A", IRanges(20, 25), "+")
    checkIdentical(NA_integer_, precede(a, b))
    checkIdentical(1L, precede(b, a))
    checkIdentical(1L, follow(a, b))
    checkIdentical(NA_integer_, follow(b, a))
    checkIdentical(1L, nearest(a, b))
    checkIdentical(1L, nearest(b, a))
}

test_GenomicRanges_ignore_strand <- function()
{
    query <- GRanges("A", IRanges(10, width=1), c("+", "-", "*"))
    subject <- GRanges("A", IRanges(c(5, 5, 5, 15, 15, 15), width=1),
                       rep(c("+", "-", "*"), 2))
    checkIdentical(c(4L, 4L, 4L),
                   precede(query, subject, ignore.strand=TRUE))
    checkIdentical(c(1L, 1L, 1L), 
                   precede(query, rev(subject),ignore.strand=TRUE))
}

test_GenomicRanges_nearest <- function()
{
    ## adjacent 
    r <- IRanges(c(1,6), c(5,10))
    g <- GRanges("chr1", r, "+")
    checkEquals(follow(r), follow(g))
    checkEquals(precede(r), precede(g))
    checkEquals(nearest(r), nearest(g))
    checkEquals(follow(r,r), follow(g,g))
    checkEquals(precede(r,r), precede(g,g))
    checkEquals(nearest(r,r), nearest(g,g))
    g <- GRanges("chr1", r, "-")
    checkEquals(follow(r), precede(g))
    checkEquals(precede(r), follow(g))
    checkEquals(nearest(r), nearest(g))
    checkEquals(follow(r,r), precede(g,g))
    checkEquals(precede(r,r), follow(g,g))
    checkEquals(nearest(r,r), nearest(g,g))
    g <- GRanges("chr1", r, "*")
    checkEquals(follow(g), precede(g))
    checkEquals(nearest(r), nearest(g))
    checkEquals(follow(g,g), precede(g,g))
    checkEquals(nearest(r,r), nearest(g,g))

    ## separated by 1
    r <- IRanges(c(1,7), c(5,11))
    g <- GRanges("chr1", r, "+")
    checkEquals(follow(r), follow(g))
    checkEquals(precede(r), precede(g))
    checkEquals(nearest(r), nearest(g))
    checkEquals(nearest(r,r), nearest(g,g))
    g <- GRanges("chr1", r, "-")
    checkEquals(follow(r), precede(g))
    checkEquals(precede(r), follow(g))
    checkEquals(nearest(r), nearest(g))
    checkEquals(nearest(r,r), nearest(g,g))
    g <- GRanges("chr1", r, "*")
    checkEquals(follow(g), precede(g))
    checkEquals(nearest(r), nearest(g))
    checkEquals(nearest(r,r), nearest(g,g))

    ## separated by > 1
    r <- IRanges(c(1,5,10), c(2,7,12))
    g <- GRanges("chr1", r, "+")
    checkEquals(precede(r), precede(g))
    checkEquals(follow(r), follow(g))
    checkEquals(nearest(r), nearest(g))
    g <- GRanges("chr1", r, "-")
    checkEquals(follow(r), precede(g))
    checkEquals(precede(r), follow(g))
    checkEquals(nearest(r), nearest(g))
    g <- GRanges("chr1", r, "*")
    checkEquals(follow(g), precede(g))
    checkEquals(nearest(r), follow(g))
    checkEquals(follow(g), nearest(g))

    ## overlapping
    r <- IRanges(c(1,4,8), c(6,10,12))
    g <- GRanges("chr1", r, "+")
    checkEquals(nearest(r), nearest(g))
    checkEquals(c(2, 3, 3), nearest(g, g))
    checkEquals(c(3, 3, 2), nearest(g, rev(g)))
    g <- GRanges("chr1", r, "-")
    checkEquals(nearest(r), nearest(g))
    checkEquals(c(2, 3, 3), nearest(g, g))
    checkEquals(c(3, 3, 2), nearest(g, rev(g)))
    g <- GRanges("chr1", r, "*")
    checkEquals(nearest(r), nearest(g))
    checkEquals(c(2, 3, 3), nearest(g, g))
    checkEquals(c(3, 3, 2), nearest(g, rev(g)))

    q <- GRanges("chr1", IRanges(1, 15), "+")
    s <- GRanges("chr1", IRanges(c(1, 1, 10), c(5, 15, 15)), "+")
    target <- nearest(q, s, select="arbitrary")
    checkEquals(3, target)
    strand(q) <- "-"
    strand(s) <- "-"
    target <- nearest(q, s, select="arbitrary")
    checkEquals(3, target)
    target1 <- nearest(ranges(q), ranges(s), select="all")
    target2 <- nearest(q, s, select="all")
    checkEquals(target1, target2)

    ## ignore.strand
    q <- GRanges("chr1", IRanges(5, width=1), "+")
    s <- GRanges("chr1", IRanges(c(10, 8), width=1), "-")
    res <- nearest(q, s, ignore.strand=FALSE)
    checkEquals(res, NA_integer_)
    res <- nearest(q, s, ignore.strand=TRUE)
    checkEquals(res, 2L)

    q <- GRanges("chr1", IRanges(5, 5))
    s <- GRanges("chr1", IRanges(c(6,7), c(6,7)), c("+", "-"))
    checkEquals(nearest(q, s), 1L) 
}

test_GenomicRanges_distance <- function()
{
    g1 <- GRanges(seqnames = c(rep("chr1", 3), rep("chr2", 2)),
        ranges = IRanges(rep(1, 5),  width=3),
        strand = c("+", "-", "*", "*", "*"))

    g2 <- GRanges(seqnames = c(rep("chr1", 3), rep("chr2", 2)),
        ranges = IRanges(rep(5, 5),  width=3),
        strand = c("+", "-", "*", "-", "+"))

    current <- distance(g1, g2)
    target <- c(2L, 2L, 2L, 2L, 2L)
    checkIdentical(current, target)

    strand(g2[1]) <- "-"
    current <- distance(g1[1], g2[1])
    checkTrue(is.na(current))

    seqnames(g2[4]) <- factor("chr1", levels=c("chr1", "chr2")) 
    current <- distance(g1[4], g2[4])
    checkTrue(is.na(current))
}

test_GenomicRanges_distanceToNearest <- function()
{
    x <- GRanges("chr1", IRanges(c(1, 5, 10), width=1))
    subject <- GRanges("chr1", IRanges(c(3, 12), width=1))
    current <- distanceToNearest(x, subject)
    target <- c(1L, 1L, 2L) 
    checkIdentical(target, current$subjectHits)

    strand(x) <- "+"
    strand(subject) <- c("+", "-")
    current <- distanceToNearest(x, subject)
    target <- c(1L, 1L, 1L) 
    checkIdentical(target, current$subjectHits)
    current <- distanceToNearest(x, subject, ignore.strand=TRUE)
    target <- c(1L, 1L, 2L) 
    checkIdentical(target, current$subjectHits)

    ## no self-hits
    current <- distanceToNearest(x)
    target <- c(2L, 1L, 2L) 
    checkIdentical(target, current$subjectHits)

    ## self-hits
    current <- distanceToNearest(x, x)
    target <- c(1L, 2L, 3L) 
    checkIdentical(target, current$subjectHits)
}
