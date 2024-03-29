#' Create locales
#'
#' A locale object tries to capture all the defaults that can vary between
#' countries. You set the locale in once, and the details are automatically
#' passed on down to the columns parsers. The defaults have been chosen to
#' match R (i.e. US English) as closely as possible. See
#' `vignette("locales")` for more details.
#'
#' @param date_names Character representations of day and month names. Either
#'   the language code as string (passed on to [date_names_lang()])
#'   or an object created by [date_names()].
#' @param date_format,time_format Default date and time formats.
#' @param decimal_mark,grouping_mark Symbols used to indicate the decimal
#'   place, and to chunk larger numbers. Decimal mark can only be `,` or
#'   `.`.
#' @param tz Default tz. This is used both for input (if the time zone isn't
#'   present in individual strings), and for output (to control the default
#'   display). The default is to use "UTC", a time zone that does not use
#'   daylight savings time (DST) and hence is typically most useful for data.
#'   The absence of time zones makes it approximately 50x faster to generate
#'   UTC times than any other time zone.
#'
#'   Use `""` to use the system default time zone, but beware that this
#'   will not be reproducible across systems.
#'
#'   For a complete list of possible time zones, see [OlsonNames()].
#'   Americans, note that "EST" is a Canadian time zone that does not have
#'   DST. It is *not* Eastern Standard Time. It's better to use
#'   "US/Eastern", "US/Central" etc.
#' @param encoding Default encoding. This only affects how the file is
#'   read - readr always converts the output to UTF-8.
#' @param asciify Should diacritics be stripped from date names and converted to
#'   ASCII? This is useful if you're dealing with ASCII data where the correct
#'   spellings have been lost. Requires the \pkg{stringi} package.
#' @export
#' @examples
#' locale()
#' locale("fr")
#'
#' # South American locale
#' locale("es", decimal_mark = ",")
locale <- function(date_names = "en",
                   date_format = "%AD", time_format = "%AT",
                   decimal_mark = ".", grouping_mark = ",",
                   tz = "UTC", encoding = "UTF-8",
                   asciify = FALSE) {
  if (is.character(date_names)) {
    date_names <- date_names_lang(date_names)
  }
  stopifnot(is.date_names(date_names))
  if (asciify) {
    date_names[] <- lapply(date_names, stringi::stri_trans_general, id = "latin-ascii")
  }

  if (missing(grouping_mark) && !missing(decimal_mark)) {
    grouping_mark <- if (decimal_mark == ".") "," else "."
  } else if (missing(decimal_mark) && !missing(grouping_mark)) {
    decimal_mark <- if (grouping_mark == ".") "," else "."
  }

  stopifnot(decimal_mark %in% c(".", ","))
  check_string(grouping_mark)
  if (decimal_mark == grouping_mark) {
    stop("`decimal_mark` and `grouping_mark` must be different", call. = FALSE)
  }

  tz <- check_tz(tz)
  check_encoding(encoding)

  structure(
    list(
      date_names = date_names,
      date_format = date_format,
      time_format = time_format,
      decimal_mark = decimal_mark,
      grouping_mark = grouping_mark,
      tz = tz,
      encoding = encoding
    ),
    class = "locale"
  )
}

is.locale <- function(x) inherits(x, "locale")

#' @export
print.locale <- function(x, ...) {
  cat("<locale>\n")
  cat("Numbers:  ", prettyNum(123456.78,
    big.mark = x$grouping_mark,
    decimal.mark = x$decimal_mark, digits = 8
  ), "\n", sep = "")
  cat("Formats:  ", x$date_format, " / ", x$time_format, "\n", sep = "")
  cat("Timezone: ", x$tz, "\n", sep = "")
  cat("Encoding: ", x$encoding, "\n", sep = "")
  print(x$date_names)
}

#' @export
#' @rdname locale
default_locale <- function() {
  loc <- getOption("readr.default_locale")
  if (is.null(loc)) {
    loc <- locale()
    options("readr.default_locale" = loc)
  }

  loc
}

check_tz <- function(x) {
  check_string(x, nm = "tz")

  if (identical(x, "")) {
    x <- Sys.timezone()

    if (identical(x, "") || identical(x, NA_character_)) {
      x <- "UTC"
    }
  }

  if (x %in% tzdb::tzdb_names()) {
    x
  } else {
    stop("Unknown TZ ", x, call. = FALSE)
  }
}

check_encoding <- function(x) {
  check_string(x, nm = "encoding")

  if (tolower(x) %in% tolower(iconvlist())) {
    return(TRUE)
  }

  stop("Unknown encoding ", x, call. = FALSE)
}
