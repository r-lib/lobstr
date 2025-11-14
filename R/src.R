#' Display tree of source references
#'
#' Visualizes source reference metadata attached to R objects in a tree structure.
#' Shows source file information, line/column locations, and optionally the
#' actual source code.
#'
#' @param x An R object with source references. Can be:
#'   - A `srcref` object
#'   - A list of `srcref` objects
#'   - A function (closure) with source references
#'   - An expression with source references
#'   - A primitive/builtin function (will show informative message)
#' @param max_depth Maximum depth to traverse nested structures (default 5)
#' @param max_lines_preview Maximum lines of source to show per srcref (default 3)
#' @param max_length Maximum number of srcref nodes to display (default 100)
#' @param ... Additional arguments passed to [tree()]
#'
#' @return Invisibly returns a structured list containing the source reference
#'   information
#'
#' @export
#' @family object inspectors
#' @examples
#' # Create a function with source references
#' f <- function(x) {
#'   x + 1
#' }
#'
#' # Display source reference information
#' src(f)
#'
#' # Limit source preview
#' src(f, max_lines_preview = 1)
src <- function(
  x,
  max_depth = 5L,
  max_lines_preview = 3L,
  max_length = 100L,
  max_vec_len = 3L,
  ...
) {
  seen_srcfiles <- new.env(parent = emptyenv())
  seen_srcfiles$.counter <- 0L

  result <- src_extract(x, max_lines_preview, seen_srcfiles)
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
    max_vec_len = max_vec_len,
    tree_args = list(...),
    class = c("lobstr_srcref", class(result))
  )
}

#' @export
print.lobstr_srcref <- function(x, ...) {
  max_depth <- attr(x, "max_depth") %||% 5L
  max_length <- attr(x, "max_length") %||% 100L
  max_vec_len <- attr(x, "max_vec_len") %||% 3L
  tree_args <- attr(x, "tree_args") %||% list()

  # Strip attributes before printing
  attr(x, "max_depth") <- NULL
  attr(x, "max_length") <- NULL
  attr(x, "max_vec_len") <- NULL
  attr(x, "tree_args") <- NULL

  inject(tree(
    x = x,
    max_depth = max_depth,
    max_length = max_length,
    max_vec_len = max_vec_len,
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
  paste0("<", class(x)[1], ": ", getSrcFilename(x), ">")
}

#' @export
tree_label.lobstr_srcfile_ref <- function(x, opts) {
  paste0("@", as.character(x))
}


# Main extraction logic --------------------------------------------------------

src_extract <- function(x, max_lines, seen_srcfiles) {
  # Srcref object
  if (inherits(x, "srcref")) {
    return(srcref_node(x, max_lines, seen_srcfiles))
  }

  # List of srcrefs
  if (
    is.list(x) &&
      length(x) > 0 &&
      all(vapply(x, inherits, logical(1), "srcref"))
  ) {
    return(srcref_list_node(x, max_lines, seen_srcfiles))
  }

  # Evaluated closures
  if (is_closure(x)) {
    return(function_node(x, max_lines, seen_srcfiles))
  }

  # Expressions and language objects
  if (is.expression(x) || is.language(x)) {
    return(expr_node(x, max_lines, seen_srcfiles))
  }

  NULL
}

# Extract standard srcref-related attributes from any object
extract_srcref_attrs <- function(x, max_lines, seen_srcfiles) {
  attrs <- list()

  if (!is.null(srcref <- attr(x, "srcref"))) {
    attrs$`attr("srcref")` <- process_srcref_attr(
      srcref,
      max_lines,
      seen_srcfiles
    )
  }

  if (!is.null(srcfile <- attr(x, "srcfile"))) {
    attrs$`attr("srcfile")` <- srcfile_node(
      srcfile,
      NULL,
      max_lines,
      seen_srcfiles
    )
  }

  if (!is.null(whole <- attr(x, "wholeSrcref"))) {
    attrs$`attr("wholeSrcref")` <- srcref_node(whole, max_lines, seen_srcfiles)
  }

  attrs
}

process_srcref_attr <- function(srcref_attr, max_lines, seen_srcfiles) {
  if (inherits(srcref_attr, "srcref")) {
    return(srcref_node(srcref_attr, max_lines, seen_srcfiles))
  }

  if (is.list(srcref_attr)) {
    srcrefs <- lapply(seq_along(srcref_attr), function(i) {
      srcref_node(srcref_attr[[i]], max_lines, seen_srcfiles)
    })
    names(srcrefs) <- paste0("[[", seq_along(srcrefs), "]]")
    return(new_srcref_tree(srcrefs, type = "list"))
  }

  stop("unreachable")
}

srcref_node <- function(srcref, max_lines, seen_srcfiles) {
  info <- srcref_info(srcref)
  node <- list(location = info$location)

  if (!is.null(info$bytes)) {
    node$bytes <- info$bytes
  }
  if (!is.null(info$parsed)) {
    node$parsed <- info$parsed
  }

  # Just for completeness but we really don't expect srcref attributes on srcrefs
  attrs <- extract_srcref_attrs(srcref, max_lines, seen_srcfiles)
  node <- c(node, attrs)

  new_srcref_tree(node, type = "srcref")
}

srcref_list_node <- function(srcref_list, max_lines, seen_srcfiles) {
  srcrefs <- lapply(srcref_list, srcref_node, max_lines, seen_srcfiles)

  node <- list(
    count = length(srcref_list),
    srcrefs = new_srcref_tree(srcrefs, type = "list")
  )

  attrs <- extract_srcref_attrs(srcref_list, max_lines, seen_srcfiles)
  node <- c(node, attrs)

  new_srcref_tree(node, type = "list")
}

function_node <- function(fun, max_lines, seen_srcfiles) {
  node <- extract_srcref_attrs(fun, max_lines, seen_srcfiles)
  body <- src_extract(body(fun), max_lines, seen_srcfiles)

  if (!is.null(body)) {
    node$`body()` <- as_srcref_tree(body, from = body(fun))
  }

  if (length(node) == 0) {
    return(NULL)
  }

  new_srcref_tree(node, type = "closure")
}

expr_node <- function(x, max_lines, seen_srcfiles) {
  attrs <- extract_srcref_attrs(x, max_lines, seen_srcfiles)
  nested <- extract_nested_srcrefs(x, max_lines, seen_srcfiles)

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

extract_nested_srcrefs <- function(x, max_lines, seen_srcfiles) {
  if (!is_traversable(x)) {
    return(list())
  }

  nested <- list()
  for (i in seq_along(x)) {
    child <- src_extract(x[[i]], max_lines, seen_srcfiles)

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

srcfile_node <- function(srcfile, srcref, max_lines, seen_srcfiles) {
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

  # Add source preview for plain srcfiles
  if (!inherits(srcfile, "srcfilecopy") && !is.null(srcref)) {
    snippet <- srcfile_lines(srcfile, srcref, max_lines)
    if (length(snippet) > 0) {
      info$`lines (from file)` <- snippet
    }
  }

  # Check for srcref attributes even on srcfile objects
  attrs <- extract_srcref_attrs(srcfile, max_lines, seen_srcfiles)
  info <- c(info, attrs)

  new_srcref_tree(
    info,
    type = "srcfile",
    srcfile_class = srcfile_class %||% "srcfile",
    srcfile_id = id
  )
}

srcfile_lines <- function(srcfile, srcref, max_lines) {
  if (is.null(srcfile) || is.null(srcref)) {
    return(character(0))
  }

  first_line <- srcref[[1]]
  last_line <- min(srcref[[3]], first_line + max_lines - 1)

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
      encoding <- srcfile$Enc %||% "unknown"
      all_lines <- tryCatch(
        readLines(filepath, encoding = encoding, warn = FALSE),
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
