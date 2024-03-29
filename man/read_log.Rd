% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/read_log.R
\name{read_log}
\alias{read_log}
\title{Read common/combined log file into a tibble}
\usage{
read_log(
  file,
  col_names = FALSE,
  col_types = NULL,
  trim_ws = TRUE,
  skip = 0,
  n_max = Inf,
  show_col_types = should_show_types(),
  progress = show_progress()
)
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

\item{col_names}{Either \code{TRUE}, \code{FALSE} or a character vector
of column names.

If \code{TRUE}, the first row of the input will be used as the column
names, and will not be included in the data frame. If \code{FALSE}, column
names will be generated automatically: X1, X2, X3 etc.

If \code{col_names} is a character vector, the values will be used as the
names of the columns, and the first row of the input will be read into
the first row of the output data frame.

Missing (\code{NA}) column names will generate a warning, and be filled
in with dummy names \code{...1}, \code{...2} etc. Duplicate column names
will generate a warning and be made unique, see \code{name_repair} to control
how this is done.}

\item{col_types}{One of \code{NULL}, a \code{\link[=cols]{cols()}} specification, or
a string. See \code{vignette("readr")} for more details.

If \code{NULL}, all column types will be inferred from \code{guess_max} rows of the
input, interspersed throughout the file. This is convenient (and fast),
but not robust. If the guessed types are wrong, you'll need to increase
\code{guess_max} or supply the correct types yourself.

Column specifications created by \code{\link[=list]{list()}} or \code{\link[=cols]{cols()}} must contain
one column specification for each column. If you only want to read a
subset of the columns, use \code{\link[=cols_only]{cols_only()}}.

Alternatively, you can use a compact string representation where each
character represents one column:
\itemize{
\item c = character
\item i = integer
\item n = number
\item d = double
\item l = logical
\item f = factor
\item D = date
\item T = date time
\item t = time
\item ? = guess
\item _ or - = skip
}

By default, reading a file without a column specification will print a
message showing what \code{readr} guessed they were. To remove this message,
set \code{show_col_types = FALSE} or set \code{options(readr.show_col_types = FALSE)}.}

\item{trim_ws}{Should leading and trailing whitespace (ASCII spaces and tabs) be trimmed from
each field before parsing it?}

\item{skip}{Number of lines to skip before reading data. If \code{comment} is
supplied any commented lines are ignored \emph{after} skipping.}

\item{n_max}{Maximum number of lines to read.}

\item{show_col_types}{If \code{FALSE}, do not show the guessed column types. If
\code{TRUE} always show the column types, even if they are supplied. If \code{NULL}
(the default) only show the column types if they are not explicitly supplied
by the \code{col_types} argument.}

\item{progress}{Display a progress bar? By default it will only display
in an interactive session and not while knitting a document. The automatic
progress bar can be disabled by setting option \code{readr.show_progress} to
\code{FALSE}.}
}
\description{
This is a fairly standard format for log files - it uses both quotes
and square brackets for quoting, and there may be literal quotes embedded
in a quoted string. The dash, "-", is used for missing values.
}
\examples{
read_log(readr_example("example.log"))
}
