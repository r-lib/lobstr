#' Display tree of source references
#'
#' View source reference metadata attached to R objects in a tree structure.
#' Shows source file information, line/column locations, and lines of source code.
#'
#' @param x An R object with source references. Can be:
#'   - A `srcref` object
#'   - A list of `srcref` objects
#'   - A expression vector with attached source references
#'   - An evaluated closure with attached source references
#'   - A quoted call with attached source references
#' @param max_depth Maximum depth to traverse nested structures (default 5)
#' @param max_length Maximum number of srcref nodes to display (default 100)
#' @param ... Additional arguments passed to [tree()]
#'
#' @return Returns a structured list containing the source reference
#'   information. Print it to view the formatted tree.
#'
#' @section Overview:
#'
#' Source references are made of two kinds of objects:
#' - `srcref` objects, which contain information about a specific
#'   location within the source file, such as the line and column numbers.
#' - `srcfile` objects, which contain metadata about the source file
#'   such as its name, path, and encoding.
#'
#'
#' ## `srcref` objects
#'
#' `srcref` objects are compact integer vectors describing a character range
#' in a source. It records start/end lines and byte/column positions and,
#' optionally, the parsed-line numbers if `#line` directives were used.
#'
#' Lengths of 4, 6, or 8 are allowed:
#' - 4: basic (first_line, first_byte, last_line, last_byte)
#' - 6: adds columns in Unicode codepoints (first_col, last_col)
#' - 8: adds parsed-line numbers (first_parsed, last_parsed)
#'
#' The "column" information does not represent grapheme clusters, but Unicode
#' codepoints. The column cursor is incremented at every UTF-8 lead byte and
#' there is no support for encodings other than UTF-8.
#'
#' They are attached as attributes (e.g. `attr(x, "srcref")` or `attr(x,
#' "wholeSrcref")`), possibly wrapped in a list, to the following objects:
#'
#' - Expression vectors returned by `parse()` (wrapped in a list)
#' - Quoted function calls (unwrapped)
#' - Quoted `{` calls (wrapped in a list)
#' - Evaluated closures (unwrapped)
#'
#' By default source references are not created but can be enabled by:
#'
#' - Passing `keep.source = TRUE` explicitly to `parse()`, `source()`, or
#'   `sys.source()`.
#' - Setting `options(keep.source = TRUE)`. This affects the default arguments
#'   of the aforementioned functions, as well as the console input parser.
#' - Setting `options(keep.source.pkgs = TRUE)`. This affects loading a package
#'   from source, and installing a package from source.
#'
#' They have a `srcfile` attribute that points to the source file.
#'
#' Methods:
#' - `as.character()`: Retrieves relevant source lines from the `srcfile`
#'   reference.
#'
#'
#' ### `wholeSrcref` attributes
#'
#' These are `srcref` objects stored in the `wholeSrcref` attributes of:
#'
#' - Expression vectors returned by `parse()`, which seems to be the intended
#'   usage.
#' - `{` calls, which seems unintended.
#'
#' For expression vectors, the `wholeSrcref` spans from the first position
#' to the last position and represents the entire document. For braces, they
#' span from the first position to the location of the closing brace. There is
#' no way to know the location of the opening brace without reparsing, which
#' seems odd. It's probably an overlook from `xxexprlist()` calling
#' `attachSrcrefs()` in
#' <https://github.com/r-devel/r-svn/blob/52affc16/src/main/gram.y#L1380>. That
#' function is also called at the end of parsing, where it's intended for the
#' `wholeSrcref` attribute to be attached.
#'
#'
#' ## `srcfile` objects
#'
#' `srcfile` objects are environments representing information about a
#' source file that a source reference points to. They typically refer to
#' a file on disk and store the filename, working directory, a timestamp,
#' and encoding information.
#'
#' While it is possible to create bare `srcfile` objects, specialized subclasses
#' are much more common.
#'
#'
#' ### `srcfile`
#'
#' A bare `srcfile` object does not contain any data apart from the file path.
#' It lazily loads lines from the file on disk, without any caching.
#'
#' Fields common to all `srcfile` objects:
#'
#' - `filename`: The filename of the source file. If relative, the path is
#'   resolved against `wd`.
#'
#' - `wd`: The working directory (`getwd()`) at the time the srcfile was created,
#'   generally at the time of parsing).
#'
#' - `timestamp`: The timestamp of the source file. Retrieved from `filename`
#'   with `file.mtime()`.
#'
#' - `encoding`: The encoding of the source file.
#'
#' - `Enc`: The encoding of output lines. Used by `getSrcLines()`, which
#'   calls `iconv()` when `Enc` does not match `encoding`.
#'
#' Implementations:
#' - `print()` and `summary()` to print information about the source file.
#' - `open()` and `close()` to access the underlying file as a connection.
#'
#' Helpers:
#' - `getSrcLines()`: Retrieves source lines from a `srcfile`.
#'
#'
#' ### `srcfilecopy`
#'
#' A `srcfilecopy` stores the actual source lines in memory in `$lines`.
#' `srcfilecopy` is useful when the original file may change or does not
#' exist, because it preserves the exact text used by the parser.
#'
#' This type of srcfile is the most common. It's created by:
#'
#' - The R-level `parse()` function when `text` is supplied:
#'
#'   ```r
#'   # Creates a `"<text>"` non-file `srcfilecopy`
#'   parse(text = "...", keep.source = TRUE)
#'   ```
#'
#' - The console's input parser when `getOption("keep.source")` is `TRUE`.
#'
#' - `sys.source()` when `keep.source = TRUE`:
#'
#'   ```r
#'   sys.source(file, keep.source = TRUE)
#'   ```
#'
#'    The `srcfilecopy` object is timestamped with the file's last modification time.
#'    <https://github.com/r-devel/r-svn/blob/52affc16/src/library/base/R/source.R#L273-L276>
#'
#' Fields:
#'
#' - `filename`: The filename of the source file. If `isFile` is `FALSE`,
#'   the field is non meaningful. For instance `parse(text = )` sets it to
#'   `"<text>"`, and the console input parser sets it to `""`.
#'
#' - `isFile`: A logical indicating whether the source file exists.
#'
#' - `fixedNewlines`: If `TRUE`, `lines` is a character vector of lines with
#'   no embedded `\n` characters. The `getSrcLines()` helper regularises `lines`
#'   in this way and sets `fixedNewlines` to `TRUE`.
#'
#'
#' ### `srcfilealias`
#'
#' This object wraps an existing `srcfile` object (stored in `original`).  It
#' allows exposing a different `filename` while delegating the open/close/get
#' lines operations to the `srcfile` stored in `original`.
#'
#' The typical way aliases are created is via `#line *line* *filename*`
#' directives where the optional `*filename*` argument is supplied. These
#' directives remap the srcref and srcfile of parsed code to a different
#' location, for example from a temporary file or generated file to the original
#' location on disk.
#'
#' Called by `install.packages()` when installing a _source_ package with `keep.source.pkgs` set to `TRUE` (see
#' <https://github.com/r-devel/r-svn/blob/52affc16/src/library/tools/R/install.R#L545>), but
#' [only when](https://github.com/r-devel/r-svn/blob/52affc16/src/library/tools/R/admin.R#L308):
#'
#' - `Encoding` was supplied in `DESCRIPTION`
#' - The system locale is not "C" or "POSIX".
#'
#' The source files are converted to the encoding of the system locale, then
#' collated in a single source file with `#line` directives mapping them to their
#' original file names (with full paths):
#' <https://github.com/r-devel/r-svn/blob/52affc16/src/library/tools/R/admin.R#L342>.
#'
#' Note that the `filename` of the `original` srcfile incorrectly points to the
#' package path in the install destination.
#'
#'
#' Fields:
#'
#' - `filename`: The virtual file name (or full path) of the parsed code.
#' - `original`: The actual `srcfile` the code was parsed from.
#'
#' @seealso
#' - [srcfile()]: Base documentation for `srcref` and `srcfile` objects.
#' - [getParseData()]: Parse information stored when `keep.source.data` is `TRUE`.
#'
#' @export
#' @family object inspectors
src <- function(
  x,
  max_depth = 5L,
  max_length = 100L,
  ...
) {
  seen_srcfiles <- new.env(parent = emptyenv())
  seen_srcfiles$.counter <- 0L

  result <- src_extract(x, seen_srcfiles)
  if (is.null(result)) {
    return(invisible(NULL))
  }

  # Ensure result has proper type for tree display
  if (is.null(attr(result, "srcref_type"))) {
    result <- as_srcref_tree(result, from = x)
  }

  structure(
    result,
    max_depth = max_depth,
    max_length = max_length,
    tree_args = list(...),
    class = c("lobstr_srcref", class(result))
  )
}

#' @export
print.lobstr_srcref <- function(x, ...) {
  max_depth <- attr(x, "max_depth") %||% 5L
  max_length <- attr(x, "max_length") %||% 100L
  tree_args <- attr(x, "tree_args") %||% list()

  # Strip attributes before printing
  attr(x, "max_depth") <- NULL
  attr(x, "max_length") <- NULL
  attr(x, "tree_args") <- NULL

  # Defaults for `tree()` arguments that are not directly exposed by `src()`
  tree_args$max_vec_len <- tree_args$max_vec_len %||% 3L

  inject(tree(
    x = x,
    max_depth = max_depth,
    max_length = max_length,
    !!!tree_args
  ))

  invisible(x)
}

#' @export
tree_label.lobstr_srcref <- function(x, opts) {
  type <- attr(x, "srcref_type")

  switch(
    type,
    body = "",
    block = "<{>",
    srcfile = srcfile_label(x),
    paste0("<", type, ">")
  )
}

#' @export
tree_label.lobstr_srcref_location <- function(x, opts) {
  as.character(x)
}

#' @export
tree_label.srcref <- function(x, opts) {
  loc <- srcref_location(x)
  paste0("<srcref: ", loc, ">")
}

#' @export
tree_label.srcfile <- function(x, opts) {
  paste0("<", class(x)[1], ": ", utils::getSrcFilename(x), ">")
}

#' @export
tree_label.lobstr_srcfile_ref <- function(x, opts) {
  paste0("@", as.character(x))
}


# Main extraction logic --------------------------------------------------------

src_extract <- function(x, seen_srcfiles) {
  # Srcref object
  if (inherits(x, "srcref")) {
    return(srcref_node(x, seen_srcfiles))
  }

  # List of srcrefs
  if (
    is.list(x) &&
      length(x) > 0 &&
      all(vapply(x, inherits, logical(1), "srcref"))
  ) {
    return(srcref_list_node(x, seen_srcfiles))
  }

  # Evaluated closures
  if (is_closure(x)) {
    return(function_node(x, seen_srcfiles))
  }

  # Expressions and language objects
  if (is.expression(x) || is.language(x)) {
    return(expr_node(x, seen_srcfiles))
  }

  NULL
}

# Extract standard srcref-related attributes from any object
extract_srcref_attrs <- function(x, seen_srcfiles) {
  attrs <- list()

  if (!is.null(srcref <- attr(x, "srcref"))) {
    attrs$`attr("srcref")` <- srcref_attr_node(
      srcref,
      seen_srcfiles
    )
  }

  if (!is.null(srcfile <- attr(x, "srcfile"))) {
    attrs$`attr("srcfile")` <- srcfile_node(srcfile, seen_srcfiles)
  }

  if (!is.null(whole <- attr(x, "wholeSrcref"))) {
    attrs$`attr("wholeSrcref")` <- srcref_attr_node(whole, seen_srcfiles)
  }

  attrs
}

# A srcref attribute may be a srcref object or a list of srcref objects
srcref_attr_node <- function(srcref, seen_srcfiles) {
  if (inherits(srcref, "srcref")) {
    return(srcref_node(srcref, seen_srcfiles))
  }

  if (is.list(srcref)) {
    return(srcref_list_node(srcref, seen_srcfiles))
  }

  NULL
}

srcref_node <- function(srcref, seen_srcfiles) {
  info <- srcref_info(srcref)
  node <- list(location = info$location)

  if (!is.null(info$bytes)) {
    node$bytes <- info$bytes
  }
  if (!is.null(info$parsed)) {
    node$parsed <- info$parsed
  }

  # Just for completeness but we really don't expect srcref attributes on srcrefs
  attrs <- extract_srcref_attrs(srcref, seen_srcfiles)
  node <- c(node, attrs)

  new_srcref_tree(node, type = "srcref")
}

srcref_list_node <- function(srcref_list, seen_srcfiles) {
  srcrefs <- lapply(srcref_list, srcref_node, seen_srcfiles)
  names(srcrefs) <- paste0("[[", seq_along(srcrefs), "]]")

  attrs <- extract_srcref_attrs(srcref_list, seen_srcfiles)
  node <- c(srcrefs, attrs)

  new_srcref_tree(node, type = "list")
}

function_node <- function(fun, seen_srcfiles) {
  node <- extract_srcref_attrs(fun, seen_srcfiles)
  body <- src_extract(body(fun), seen_srcfiles)

  if (!is.null(body)) {
    node$`body()` <- as_srcref_tree(body, from = body(fun))
  }

  if (length(node) == 0) {
    return(NULL)
  }

  new_srcref_tree(node, type = "closure")
}

expr_node <- function(x, seen_srcfiles) {
  attrs <- extract_srcref_attrs(x, seen_srcfiles)
  nested <- extract_nested_srcrefs(x, seen_srcfiles)

  if (length(attrs) > 0) {
    # Node has attributes: wrap with proper type
    node <- c(attrs, nested)
    return(new_srcref_tree(node, type = node_type(x)))
  }

  # No attributes: return bare list for path collapsing, or NULL if empty
  if (length(nested) > 0) {
    nested
  } else {
    NULL
  }
}

extract_nested_srcrefs <- function(x, seen_srcfiles) {
  if (!is_traversable(x)) {
    return(list())
  }

  nested <- list()
  for (i in seq_along(x)) {
    child <- src_extract(x[[i]], seen_srcfiles)

    if (!is.null(child)) {
      nested <- merge_child_result(nested, child, i)
    }
  }

  nested
}

merge_child_result <- function(nested, child, index) {
  path <- paste0("[[", index, "]]")

  if (is_wrapped_node(child)) {
    nested[[path]] <- child
  } else {
    # Collapse paths for bare lists
    for (name in names(child)) {
      nested[[paste0(path, name)]] <- child[[name]]
    }
  }

  nested
}

is_traversable <- function(x) {
  (is.expression(x) || is.call(x)) && length(x) > 0
}

is_wrapped_node <- function(x) {
  !is.null(attr(x, "srcref_type"))
}

node_type <- function(x) {
  if (is.expression(x)) {
    "expression"
  } else if (is.call(x) && length(x) > 0) {
    if (identical(x[[1]], as.symbol("function"))) {
      "quoted_function"
    } else if (identical(x[[1]], as.symbol("{"))) {
      "block"
    } else {
      "language"
    }
  } else {
    "language"
  }
}

as_srcref_tree <- function(data, ..., from) {
  if (is_wrapped_node(data)) {
    data
  } else {
    new_srcref_tree(data, type = node_type(from))
  }
}


# Srcfile handling -------------------------------------------------------------

srcfile_node <- function(srcfile, seen_srcfiles) {
  if (is.null(srcfile)) {
    return(NULL)
  }

  addr <- obj_addr(srcfile)
  srcfile_class <- class(srcfile)[[1]]

  # Check if already seen
  id <- seen_srcfiles[[addr]]
  if (!is_null(id)) {
    return(new_srcfile_ref(id, srcfile_class))
  }

  # First occurrence - assign sequential ID
  seen_srcfiles$.counter <- seen_srcfiles$.counter + 1L
  id <- sprintf("%03d", seen_srcfiles$.counter)
  seen_srcfiles[[addr]] <- id

  info <- as.list.environment(srcfile, all.names = TRUE, sorted = TRUE)

  # Format timestamp for readability
  if (!is.null(info$timestamp)) {
    info$timestamp <- format(info$timestamp)
  }

  # Process nested srcfile objects (e.g., 'original' in srcfilealias)
  if (!is.null(info$original) && inherits(info$original, "srcfile")) {
    info$original <- srcfile_node(info$original, seen_srcfiles)
  }

  # Add source preview for plain srcfiles
  if (!inherits(srcfile, "srcfilecopy") && !is.null(srcref)) {
    snippet <- srcfile_lines(srcfile, srcref)
    if (length(snippet) > 0) {
      info$`lines (from file)` <- snippet
    }
  }

  # Check for srcref attributes even on srcfile objects
  attrs <- extract_srcref_attrs(srcfile, seen_srcfiles)
  info <- c(info, attrs)

  new_srcref_tree(
    info,
    type = "srcfile",
    srcfile_class = srcfile_class %||% "srcfile",
    srcfile_id = id
  )
}

srcfile_lines <- function(srcfile, srcref) {
  if (is.null(srcfile) || is.null(srcref)) {
    return(character(0))
  }

  max_lines <- 3L

  first_line <- srcref[[1]]
  last_line <- min(srcref[[3]], first_line + max_lines - 1L)

  # Try embedded lines first
  lines <- srcfile$lines
  if (!is.null(lines) && length(lines) >= last_line) {
    return(lines[first_line:last_line])
  }

  # Try reading from file
  filename <- srcfile$filename
  directory <- srcfile$wd

  if (!is.null(filename) && !is.null(directory)) {
    filepath <- file.path(directory, filename)

    if (file.exists(filepath)) {
      all_lines <- tryCatch(
        readLines(filepath, warn = FALSE),
        error = function(e) NULL
      )

      if (!is.null(all_lines) && length(all_lines) >= last_line) {
        return(all_lines[first_line:last_line])
      }
    }
  }

  character(0)
}

srcfile_label <- function(x) {
  class <- attr(x, "srcfile_class")
  label <- paste0("<", class, ">")

  id <- attr(x, "srcfile_id")
  if (!is.null(id)) {
    label <- paste0(label, " @", id)
  }

  label
}


# Srcref information extraction ------------------------------------------------

srcref_info <- function(srcref) {
  if (!inherits(srcref, "srcref")) {
    abort("Expected a srcref object")
  }

  len <- length(srcref)
  if (!len %in% c(4, 6, 8)) {
    abort(sprintf("Unexpected srcref length: %d", len))
  }

  first_line <- srcref[[1]]
  first_byte <- srcref[[2]]
  last_line <- srcref[[3]]
  last_byte <- srcref[[4]]
  first_col <- if (len >= 6) srcref[[5]] else first_byte
  last_col <- if (len >= 6) srcref[[6]] else last_byte
  first_parsed <- if (len == 8) srcref[[7]] else first_line
  last_parsed <- if (len == 8) srcref[[8]] else last_line

  info <- list(
    location = new_srcref_location(srcref_location(srcref))
  )

  # Add byte info if different from columns
  if (first_byte != first_col || last_byte != last_col) {
    info$bytes <- sprintf("%d - %d", first_byte, last_byte)
  }

  # Add parsed info if different from actual lines
  if (first_parsed != first_line || last_parsed != last_line) {
    info$parsed <- new_srcref_location(sprintf(
      "%d:%d - %d:%d",
      first_parsed,
      first_col,
      last_parsed,
      last_col
    ))
  }

  info
}

srcref_location <- function(x) {
  first_line <- x[[1]]
  last_line <- x[[3]]
  first_col <- if (length(x) >= 6) x[[5]] else x[[2]]
  last_col <- if (length(x) >= 6) x[[6]] else x[[4]]

  sprintf("%d:%d - %d:%d", first_line, first_col, last_line, last_col)
}


# Helper functions -------------------------------------------------------------

has_srcref <- function(x) {
  !is.null(attr(x, "srcref")) ||
    !is.null(attr(x, "wholeSrcref")) ||
    !is.null(attr(x, "srcfile"))
}

new_srcref_tree <- function(x, type = NULL, ..., class = NULL) {
  type <- type %||% attr(x, "srcref_type")
  type <- arg_match(
    type,
    c(
      "block",
      "body",
      "closure",
      "expression",
      "language",
      "list",
      "quoted_function",
      "srcfile",
      "srcref"
    )
  )

  structure(
    x,
    srcref_type = type,
    ...,
    class = c(class, "lobstr_srcref")
  )
}

new_srcref_location <- function(x) {
  structure(x, class = c("lobstr_srcref_location", "character"))
}

new_srcfile_ref <- function(id, srcfile_class = "srcfile") {
  structure(
    id,
    srcfile_class = srcfile_class,
    class = "lobstr_srcfile_ref"
  )
}
