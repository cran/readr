% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/tokenizer.R
\name{tokenize}
\alias{tokenize}
\title{Tokenize a file/string.}
\usage{
tokenize(file, tokenizer = tokenizer_csv(), skip = 0, n_max = -1L)
}
\arguments{
\item{file}{Either a path to a file, a connection, or literal data
(either a single string or a raw vector).

Files ending in \code{.gz}, \code{.bz2}, \code{.xz}, or \code{.zip} will
be automatically uncompressed. Files starting with \verb{http://},
\verb{https://}, \verb{ftp://}, or \verb{ftps://} will be automatically
downloaded. Remote gz files can also be automatically downloaded and
decompressed.

Literal data is most useful for examples and tests. To be recognised as
literal data, the input must be either wrapped with \code{I()}, be a string
containing at least one new line, or be a vector containing at least one
string with a new line.

Using a value of \code{\link[=clipboard]{clipboard()}} will read from the system clipboard.}

\item{tokenizer}{A tokenizer specification.}

\item{skip}{Number of lines to skip before reading data.}

\item{n_max}{Optionally, maximum number of rows to tokenize.}
}
\description{
Turns input into a character vector. Usually the tokenization is done purely
in C++, and never exposed to R (because that requires a copy). This function
is useful for testing, or when a file doesn't parse correctly and you want
to see the underlying tokens.
}
\examples{
tokenize("1,2\n3,4,5\n\n6")

# Only tokenize first two lines
tokenize("1,2\n3,4,5\n\n6", n = 2)
}
\keyword{internal}
