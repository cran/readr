#' @useDynLib readr, .registration = TRUE
NULL

#' Read a delimited file (including CSV and TSV) into a tibble
#'
#' `read_csv()` and `read_tsv()` are special cases of the more general
#' `read_delim()`. They're useful for reading the most common types of
#' flat file data, comma separated values and tab separated values,
#' respectively. `read_csv2()` uses `;` for the field separator and `,` for the
#' decimal point. This format is common in some European countries.
#' @inheritParams datasource
#' @inheritParams tokenizer_delim
#' @inheritParams vroom::vroom
#' @param col_names Either `TRUE`, `FALSE` or a character vector
#'   of column names.
#'
#'   If `TRUE`, the first row of the input will be used as the column
#'   names, and will not be included in the data frame. If `FALSE`, column
#'   names will be generated automatically: X1, X2, X3 etc.
#'
#'   If `col_names` is a character vector, the values will be used as the
#'   names of the columns, and the first row of the input will be read into
#'   the first row of the output data frame.
#'
#'   Missing (`NA`) column names will generate a warning, and be filled
#'   in with dummy names `...1`, `...2` etc. Duplicate column names
#'   will generate a warning and be made unique, see `name_repair` to control
#'   how this is done.
#' @param col_types One of `NULL`, a [cols()] specification, or
#'   a string. See `vignette("readr")` for more details.
#'
#'    If `NULL`, all column types will be inferred from `guess_max` rows of the
#'    input, interspersed throughout the file. This is convenient (and fast),
#'    but not robust. If the guessed types are wrong, you'll need to increase
#'    `guess_max` or supply the correct types yourself.
#'
#'    Column specifications created by [list()] or [cols()] must contain
#'    one column specification for each column. If you only want to read a
#'    subset of the columns, use [cols_only()].
#'
#'    Alternatively, you can use a compact string representation where each
#'    character represents one column:
#'    - c = character
#'    - i = integer
#'    - n = number
#'    - d = double
#'    - l = logical
#'    - f = factor
#'    - D = date
#'    - T = date time
#'    - t = time
#'    - ? = guess
#'    - _ or - = skip
#'
#'    By default, reading a file without a column specification will print a
#'    message showing what `readr` guessed they were. To remove this message,
#'    set `show_col_types = FALSE` or set `options(readr.show_col_types = FALSE)`.
#' @param id The name of a column in which to store the file path. This is
#'   useful when reading multiple input files and there is data in the file
#'   paths, such as the data collection date. If `NULL` (the default) no extra
#'   column is created.
#' @param show_col_types If `FALSE`, do not show the guessed column types. If
#'   `TRUE` always show the column types, even if they are supplied. If `NULL`
#'   (the default) only show the column types if they are not explicitly supplied
#'   by the `col_types` argument.
#' @param locale The locale controls defaults that vary from place to place.
#'   The default locale is US-centric (like R), but you can use
#'   [locale()] to create your own locale that controls things like
#'   the default time zone, encoding, decimal mark, big mark, and day/month
#'   names.
#' @param skip Number of lines to skip before reading data. If `comment` is
#'   supplied any commented lines are ignored _after_ skipping.
#' @param n_max Maximum number of lines to read.
#' @param guess_max Maximum number of lines to use for guessing column types.
#'   Will never use more than the number of lines read.
#'   See `vignette("column-types", package = "readr")` for more details.
#' @param progress Display a progress bar? By default it will only display
#'   in an interactive session and not while knitting a document. The automatic
#'   progress bar can be disabled by setting option `readr.show_progress` to
#'   `FALSE`.
#' @param lazy Read values lazily? By default, this is `FALSE`, because there
#'   are special considerations when reading a file lazily that have tripped up
#'   some users. Specifically, things get tricky when reading and then writing
#'   back into the same file. But, in general, lazy reading (`lazy = TRUE`) has
#'   many benefits, especially for interactive use and when your downstream work
#'   only involves a subset of the rows or columns.
#'
#'   Learn more in [should_read_lazy()] and in the documentation for the
#'   `altrep` argument of [vroom::vroom()].
#' @param num_threads The number of processing threads to use for initial
#'   parsing and lazy reading of data. If your data contains newlines within
#'   fields the parser should automatically detect this and fall back to using
#'   one thread only. However if you know your file has newlines within quoted
#'   fields it is safest to set `num_threads = 1` explicitly.
#' @param name_repair Handling of column names. The default behaviour is to
#'   ensure column names are `"unique"`. Various repair strategies are
#'   supported:
#'   * `"minimal"`: No name repair or checks, beyond basic existence of names.
#'   * `"unique"` (default value): Make sure names are unique and not empty.
#'   * `"check_unique"`: No name repair, but check they are `unique`.
#'   * `"unique_quiet"`: Repair with the `unique` strategy, quietly.
#'   * `"universal"`: Make the names `unique` and syntactic.
#'   * `"universal_quiet"`: Repair with the `universal` strategy, quietly.
#'   * A function: Apply custom name repair (e.g., `name_repair = make.names`
#'     for names in the style of base R).
#'   * A purrr-style anonymous function, see [rlang::as_function()].
#'
#'   This argument is passed on as `repair` to [vctrs::vec_as_names()].
#'   See there for more details on these terms and the strategies used
#'   to enforce them.
#'
#' @return A [tibble()]. If there are parsing problems, a warning will alert you.
#'   You can retrieve the full details by calling [problems()] on your dataset.
#' @export
#' @examples
#' # Input sources -------------------------------------------------------------
#' # Read from a path
#' read_csv(readr_example("mtcars.csv"))
#' read_csv(readr_example("mtcars.csv.zip"))
#' read_csv(readr_example("mtcars.csv.bz2"))
#' \dontrun{
#' # Including remote paths
#' read_csv("https://github.com/tidyverse/readr/raw/main/inst/extdata/mtcars.csv")
#' }
#'
#' # Read from multiple file paths at once
#' continents <- c("africa", "americas", "asia", "europe", "oceania")
#' filepaths <- vapply(
#'   paste0("mini-gapminder-", continents, ".csv"),
#'   FUN = readr_example,
#'   FUN.VALUE = character(1)
#' )
#' read_csv(filepaths, id = "file")
#'
#' # Or directly from a string with `I()`
#' read_csv(I("x,y\n1,2\n3,4"))
#'
#' # Column selection-----------------------------------------------------------
#' # Pass column names or indexes directly to select them
#' read_csv(readr_example("chickens.csv"), col_select = c(chicken, eggs_laid))
#' read_csv(readr_example("chickens.csv"), col_select = c(1, 3:4))
#'
#' # Or use the selection helpers
#' read_csv(
#'   readr_example("chickens.csv"),
#'   col_select = c(starts_with("c"), last_col())
#' )
#'
#' # You can also rename specific columns
#' read_csv(
#'   readr_example("chickens.csv"),
#'   col_select = c(egg_yield = eggs_laid, everything())
#' )
#'
#' # Column types --------------------------------------------------------------
#' # By default, readr guesses the columns types, looking at `guess_max` rows.
#' # You can override with a compact specification:
#' read_csv(I("x,y\n1,2\n3,4"), col_types = "dc")
#'
#' # Or with a list of column types:
#' read_csv(I("x,y\n1,2\n3,4"), col_types = list(col_double(), col_character()))
#'
#' # If there are parsing problems, you get a warning, and can extract
#' # more details with problems()
#' y <- read_csv(I("x\n1\n2\nb"), col_types = list(col_double()))
#' y
#' problems(y)
#'
#' # Column names --------------------------------------------------------------
#' # By default, readr duplicate name repair is noisy
#' read_csv(I("x,x\n1,2\n3,4"))
#'
#' # Same default repair strategy, but quiet
#' read_csv(I("x,x\n1,2\n3,4"), name_repair = "unique_quiet")
#'
#' # There's also a global option that controls verbosity of name repair
#' withr::with_options(
#'   list(rlib_name_repair_verbosity = "quiet"),
#'   read_csv(I("x,x\n1,2\n3,4"))
#' )
#'
#' # Or use "minimal" to turn off name repair
#' read_csv(I("x,x\n1,2\n3,4"), name_repair = "minimal")
#'
#' # File types ----------------------------------------------------------------
#' read_csv(I("a,b\n1.0,2.0"))
#' read_csv2(I("a;b\n1,0;2,0"))
#' read_tsv(I("a\tb\n1.0\t2.0"))
#' read_delim(I("a|b\n1.0|2.0"), delim = "|")
read_delim <- function(file, delim = NULL, quote = '"',
                       escape_backslash = FALSE, escape_double = TRUE,
                       col_names = TRUE, col_types = NULL,
                       col_select = NULL,
                       id = NULL,
                       locale = default_locale(),
                       na = c("", "NA"), quoted_na = TRUE,
                       comment = "", trim_ws = FALSE,
                       skip = 0, n_max = Inf, guess_max = min(1000, n_max),
                       name_repair = "unique",
                       num_threads = readr_threads(),
                       progress = show_progress(),
                       show_col_types = should_show_types(),
                       skip_empty_rows = TRUE, lazy = should_read_lazy()) {
  if (!is.null(delim) && !nzchar(delim)) {
    stop("`delim` must be at least one character, ",
      "use `read_table()` for whitespace delimited input.",
      call. = FALSE
    )
  }
  if (edition_first()) {
    tokenizer <- tokenizer_delim(delim,
      quote = quote,
      escape_backslash = escape_backslash, escape_double = escape_double,
      na = na, quoted_na = quoted_na, comment = comment, trim_ws = trim_ws,
      skip_empty_rows = skip_empty_rows
    )
    return(read_delimited(file, tokenizer,
      col_names = col_names, col_types = col_types,
      locale = locale, skip = skip, skip_empty_rows = skip_empty_rows,
      comment = comment, n_max = n_max, guess_max = guess_max, progress = progress,
      show_col_types = show_col_types
    ))
  }
  if (!missing(quoted_na)) {
    lifecycle::deprecate_soft("2.0.0", "readr::read_delim(quoted_na = )")
  }

  vroom::vroom(file,
    delim = delim, col_names = col_names, col_types = col_types,
    col_select = {{ col_select }},
    id = id,
    .name_repair = name_repair,
    skip = skip,
    n_max = n_max,
    na = na,
    quote = quote,
    comment = comment,
    skip_empty_rows = skip_empty_rows,
    trim_ws = trim_ws,
    escape_double = escape_double,
    escape_backslash = escape_backslash,
    locale = locale,
    guess_max = guess_max,
    progress = progress,
    altrep = lazy,
    show_col_types = show_col_types,
    num_threads = num_threads
  )
}

#' @rdname read_delim
#' @export
read_csv <- function(file,
                     col_names = TRUE,
                     col_types = NULL,
                     col_select = NULL,
                     id = NULL,
                     locale = default_locale(),
                     na = c("", "NA"),
                     quoted_na = TRUE,
                     quote = "\"",
                     comment = "",
                     trim_ws = TRUE,
                     skip = 0,
                     n_max = Inf,
                     guess_max = min(1000, n_max),
                     name_repair = "unique",
                     num_threads = readr_threads(),
                     progress = show_progress(),
                     show_col_types = should_show_types(),
                     skip_empty_rows = TRUE,
                     lazy = should_read_lazy()) {
  if (edition_first()) {
    tokenizer <- tokenizer_csv(
      na = na, quoted_na = quoted_na, quote = quote,
      comment = comment, trim_ws = trim_ws, skip_empty_rows = skip_empty_rows
    )
    return(
      read_delimited(file, tokenizer,
        col_names = col_names, col_types = col_types,
        locale = locale, skip = skip, skip_empty_rows = skip_empty_rows,
        comment = comment, n_max = n_max, guess_max = guess_max, progress = progress,
        show_col_types = show_col_types
      )
    )
  }

  if (!missing(quoted_na)) {
    lifecycle::deprecate_soft("2.0.0", "readr::read_csv(quoted_na = )")
  }
  vroom::vroom(
    file,
    delim = ",",
    col_names = col_names,
    col_types = col_types,
    col_select = {{ col_select }},
    id = id,
    .name_repair = name_repair,
    skip = skip,
    n_max = n_max,
    na = na,
    quote = quote,
    comment = comment,
    skip_empty_rows = skip_empty_rows,
    trim_ws = trim_ws,
    escape_double = TRUE,
    escape_backslash = FALSE,
    locale = locale,
    guess_max = guess_max,
    show_col_types = show_col_types,
    progress = progress,
    altrep = lazy,
    num_threads = num_threads
  )
}

#' @rdname read_delim
#' @export
read_csv2 <- function(file,
                      col_names = TRUE,
                      col_types = NULL,
                      col_select = NULL,
                      id = NULL,
                      locale = default_locale(),
                      na = c("", "NA"),
                      quoted_na = TRUE,
                      quote = "\"",
                      comment = "",
                      trim_ws = TRUE,
                      skip = 0,
                      n_max = Inf,
                      guess_max = min(1000, n_max),
                      progress = show_progress(),
                      name_repair = "unique",
                      num_threads = readr_threads(),
                      show_col_types = should_show_types(),
                      skip_empty_rows = TRUE,
                      lazy = should_read_lazy()) {
  if (locale$decimal_mark == ".") {
    cli::cli_alert_info("Using {.val ','} as decimal and {.val '.'} as grouping mark. Use {.fn read_delim} for more control.")
    locale$decimal_mark <- ","
    locale$grouping_mark <- "."
  }
  if (edition_first()) {
    tokenizer <- tokenizer_delim(
      delim = ";", na = na, quoted_na = quoted_na,
      quote = quote, comment = comment, trim_ws = trim_ws,
      skip_empty_rows = skip_empty_rows
    )
    return(read_delimited(file, tokenizer,
      col_names = col_names, col_types = col_types,
      locale = locale, skip = skip, skip_empty_rows = skip_empty_rows,
      comment = comment, n_max = n_max, guess_max = guess_max, progress = progress,
      show_col_types = show_col_types
    ))
  }
  vroom::vroom(file,
    delim = ";",
    col_names = col_names,
    col_types = col_types,
    col_select = {{ col_select }},
    id = id,
    .name_repair = name_repair,
    skip = skip,
    n_max = n_max,
    na = na,
    quote = quote,
    comment = comment,
    skip_empty_rows = skip_empty_rows,
    trim_ws = trim_ws,
    escape_double = TRUE,
    escape_backslash = FALSE,
    locale = locale,
    guess_max = guess_max,
    show_col_types = show_col_types,
    progress = progress,
    altrep = lazy,
    num_threads = num_threads
  )
}

#' @rdname read_delim
#' @export
read_tsv <- function(file, col_names = TRUE, col_types = NULL,
                     col_select = NULL,
                     id = NULL,
                     locale = default_locale(),
                     na = c("", "NA"), quoted_na = TRUE, quote = "\"",
                     comment = "", trim_ws = TRUE, skip = 0, n_max = Inf,
                     guess_max = min(1000, n_max), progress = show_progress(),
                     name_repair = "unique",
                     num_threads = readr_threads(),
                     show_col_types = should_show_types(),
                     skip_empty_rows = TRUE, lazy = should_read_lazy()) {
  tokenizer <- tokenizer_tsv(
    na = na, quoted_na = quoted_na, quote = quote,
    comment = comment, trim_ws = trim_ws, skip_empty_rows = skip_empty_rows
  )
  if (edition_first()) {
    return(read_delimited(file, tokenizer,
      col_names = col_names, col_types = col_types,
      locale = locale, skip = skip, skip_empty_rows = skip_empty_rows,
      comment = comment, n_max = n_max, guess_max = guess_max, progress = progress,
      show_col_types = show_col_types
    ))
  }

  vroom::vroom(file,
    delim = "\t",
    col_names = col_names,
    col_types = col_types,
    col_select = {{ col_select }},
    id = id,
    .name_repair = name_repair,
    skip = skip,
    n_max = n_max,
    na = na,
    quote = quote,
    comment = comment,
    skip_empty_rows = skip_empty_rows,
    trim_ws = trim_ws,
    escape_double = TRUE,
    escape_backslash = FALSE,
    locale = locale,
    guess_max = guess_max,
    show_col_types = show_col_types,
    progress = progress,
    altrep = lazy,
    num_threads = num_threads
  )
}

# Helper functions for reading from delimited files ----------------------------
read_tokens <- function(data, tokenizer, col_specs, col_names, locale_, n_max, progress) {
  if (n_max == Inf) {
    n_max <- -1
  }
  read_tokens_(data, tokenizer, col_specs, col_names, locale_, n_max, progress)
}

read_delimited <- function(file, tokenizer, col_names = TRUE, col_types = NULL,
                           locale = default_locale(), skip = 0, skip_empty_rows = TRUE, skip_quote = TRUE,
                           comment = "", n_max = Inf, guess_max = min(1000, n_max), progress = show_progress(),
                           show_col_types = should_show_types()) {
  name <- source_name(file)
  # If connection needed, read once.
  file <- standardise_path(file)
  if (is.connection(file)) {
    data <- datasource_connection(file, skip, skip_empty_rows, comment)
    if (empty_file(data[[1]])) {
      return(tibble::tibble())
    }
  } else {
    if (!isTRUE(grepl("\n", file)[[1]]) && empty_file(file)) {
      return(tibble::tibble())
    }
    if (is.character(file) && identical(locale$encoding, "UTF-8")) {
      # When locale is not set, file is probably marked as its correct encoding.
      # As default_locale() assumes file is UTF-8, file should be encoded as UTF-8 for non-UTF-8 MBCS locales.
      data <- enc2utf8(file)
    } else {
      data <- file
    }
  }

  spec <- col_spec_standardise(
    data,
    skip = skip, skip_empty_rows = skip_empty_rows,
    skip_quote = skip_quote,
    comment = comment, guess_max = guess_max, col_names = col_names,
    col_types = col_types, tokenizer = tokenizer, locale = locale
  )

  ds <- datasource(data, skip = spec$skip, skip_empty_rows = skip_empty_rows, comment = comment, skip_quote = skip_quote)

  has_col_types <- !is.null(col_types)

  if (
    ((is.null(show_col_types) && !has_col_types) || isTRUE(show_col_types)) &&
      !inherits(ds, "source_string")
  ) {
    show_cols_spec(spec)
  }

  out <- read_tokens(ds, tokenizer, spec$cols, names(spec$cols),
    locale_ = locale,
    n_max = n_max, progress = progress
  )

  out <- name_problems(out, names(spec$cols), name)
  attr(out, "spec") <- spec
  warn_problems(out)
}

generate_spec_fun <- function(f) {
  formals(f)$n_max <- 0
  formals(f)$guess_max <- 1000
  formals(f)$col_types <- list()

  old_body <- body(f)
  body(f) <- rlang::inject(quote(spec(with_edition(1, (function() !!old_body)()))))
  f
}

#' Generate a column specification
#'
#' When printed, only the first 20 columns are printed by default. To override,
#' set `options(readr.num_columns)` can be used to modify this (a value of 0
#' turns off printing).
#'
#' @return The `col_spec` generated for the file.
#' @inheritParams read_delim
#' @export
#' @examples
#' # Input sources -------------------------------------------------------------
#' # Retrieve specs from a path
#' spec_csv(system.file("extdata/mtcars.csv", package = "readr"))
#' spec_csv(system.file("extdata/mtcars.csv.zip", package = "readr"))
#'
#' # Or directly from a string (must contain a newline)
#' spec_csv(I("x,y\n1,2\n3,4"))
#'
#' # Column types --------------------------------------------------------------
#' # By default, readr guesses the columns types, looking at 1000 rows
#' # throughout the file.
#' # You can specify the number of rows used with guess_max.
#' spec_csv(system.file("extdata/mtcars.csv", package = "readr"), guess_max = 20)
spec_delim <- generate_spec_fun(read_delim)

#' @rdname spec_delim
#' @export
spec_csv <- generate_spec_fun(read_csv)

#' @rdname spec_delim
#' @export
spec_csv2 <- generate_spec_fun(read_csv2)

#' @rdname spec_delim
#' @export
spec_tsv <- generate_spec_fun(read_tsv)
