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
#'   information. The list has components:
#'   - `type`: Type of input object
#'   - `name`: Name of object if applicable
#'   - `srcfile`: Source file information
#'   - `srcrefs`: List of source reference details
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
  # Initialize environment to track seen srcfiles for deduplication
  seen_srcfiles <- new.env(parent = emptyenv())

  # Detect input type and extract data
  result <- extract_src_data(
    x,
    max_lines_preview,
    seen_srcfiles = seen_srcfiles
  )

  if (is.null(result)) {
    return(invisible(NULL))
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
  max_depth <- max_depth(x) %||% 5L
  max_length <- max_length(x) %||% 100L
  max_vec_len <- max_vec_len(x) %||% 3L
  tree_args <- tree_args(x) %||% list()

  # Remove our attributes before printing but keep class for labelling
  attr(x, "max_depth") <- NULL
  attr(x, "max_length") <- NULL
  attr(x, "max_vec_len") <- NULL
  attr(x, "tree_args") <- NULL

  # Print using tree infrastructure
  inject(tree(
    x = x,
    max_depth = max_depth,
    max_length = max_length,
    max_vec_len = max_vec_len,
    !!!tree_args
  ))

  invisible(x)
}

extract_src_data <- function(
  x,
  max_lines_preview,
  seen_srcfiles
) {
  # srcref object
  if (inherits(x, "srcref")) {
    return(extract_single_srcref(
      x,
      max_lines_preview,
      seen_srcfiles
    ))
  }

  # List of srcrefs
  if (
    is.list(x) &&
      length(x) > 0 &&
      all(vapply(x, inherits, logical(1), "srcref"))
  ) {
    return(extract_srcref_list(
      x,
      max_lines_preview,
      seen_srcfiles
    ))
  }

  # Closure
  if (is_closure(x)) {
    return(extract_function_srcref(
      x,
      max_lines_preview,
      seen_srcfiles
    ))
  }

  # Handle expressions and language objects (quoted functions, blocks, etc.)
  if (is.expression(x) || is.language(x)) {
    srcref_attr <- attr(x, "srcref")
    whole_srcref <- attr(x, "wholeSrcref")
    srcfile_attr <- attr(x, "srcfile")

    if (has_srcref(x)) {
      result <- list()

      # Determine type
      type_label <- if (is.expression(x)) {
        "expression"
      } else if (
        is.call(x) && length(x) > 0 && identical(x[[1]], as.symbol("function"))
      ) {
        "quoted_function"
      } else if (is.call(x) && identical(x[[1]], as.symbol("{"))) {
        "block"
      } else {
        "language"
      }

      # Add srcref attribute (could be single or list)
      if (!is.null(srcref_attr)) {
        if (inherits(srcref_attr, "srcref")) {
          result$`attr("srcref")` <- extract_single_srcref(
            srcref_attr,
            max_lines_preview,
            seen_srcfiles
          )
        } else if (is.list(srcref_attr)) {
          srcref_list <- lapply(seq_along(srcref_attr), function(i) {
            extract_single_srcref(
              srcref_attr[[i]],
              max_lines_preview,
              seen_srcfiles
            )
          })
          # Add index names to show [[1]], [[2]], etc.
          names(srcref_list) <- paste0("[[", seq_along(srcref_list), "]]")
          # Always show as list to reveal true structure
          result$`attr("srcref")` <- new_lobstr_srcref(
            srcref_list,
            type = "list"
          )
        }
      }

      # Add wholeSrcref if present
      if (!is.null(whole_srcref)) {
        result$`attr("wholeSrcref")` <- extract_single_srcref(
          whole_srcref,
          max_lines_preview,
          seen_srcfiles
        )
      }

      # Add srcfile if present and not already included
      if (
        !is.null(srcfile_attr) && is.null(srcref_attr) && is.null(whole_srcref)
      ) {
        result$`attr("srcfile")` <- new_lobstr_srcref(
          extract_srcfile_info(
            srcfile_attr,
            NULL,
            max_lines_preview,
            seen_srcfiles
          )
        )
      }

      # For expressions and language objects, recursively extract nested srcrefs
      # Use deep traversal to skip intermediate nodes without srcrefs
      if ((is.expression(x) || is.call(x)) && length(x) > 0) {
        for (i in seq_along(x)) {
          nested_results <- extract_nested_srcrefs(
            x[[i]],
            max_lines_preview,
            seen_srcfiles,
            path_prefix = paste0("[[", i, "]]")
          )

          if (!is.null(nested_results) && length(nested_results) > 0) {
            # If the result is a simple srcref-bearing object, show it directly
            if (!is.null(attr(nested_results, "srcref_type"))) {
              result[[paste0("[[", i, "]]")]] <- nested_results
            } else {
              # It's a list of nested paths - merge them in
              for (path_name in names(nested_results)) {
                result[[path_name]] <- nested_results[[path_name]]
              }
            }
          }
        }
      }

      return(new_lobstr_srcref(result, type = type_label))
    }

    # No direct srcrefs - recursively search for nested srcref-bearing objects
    if (is.call(x) && length(x) > 0) {
      # Check if this is a quoted function - if so, look at the body
      if (identical(x[[1]], as.symbol("function")) && length(x) >= 3) {
        body_result <- extract_src_data(
          x[[3]],
          max_lines_preview,
          seen_srcfiles = seen_srcfiles
        )
        if (!is.null(body_result)) {
          result <- list()
          result$`[[3]]` <- body_result
          return(new_lobstr_srcref(result, type = "quoted_function"))
        }
      }

      # For other calls, recursively check all elements
      nested_results <- list()
      for (i in seq_along(x)) {
        elem_result <- extract_src_data(
          x[[i]],
          max_lines_preview,
          seen_srcfiles = seen_srcfiles
        )
        if (!is.null(elem_result)) {
          nested_results[[paste0("[[", i, "]]")]] <- elem_result
        }
      }

      if (length(nested_results) > 0) {
        type_label <- if (identical(x[[1]], as.symbol("{"))) {
          "block"
        } else {
          "language"
        }
        return(new_lobstr_srcref(nested_results, type = type_label))
      }
    }
  }

  NULL
}

extract_nested_srcrefs <- function(
  x,
  max_lines_preview,
  seen_srcfiles,
  path_prefix = ""
) {
  if (has_srcref(x)) {
    return(extract_src_data(
      x,
      max_lines_preview,
      seen_srcfiles = seen_srcfiles
    ))
  }

  # No direct srcrefs - recurse into children to find nested srcref-bearing objects
  if (!is.call(x) && !is.pairlist(x)) {
    return(NULL)
  }

  # Collect results from children
  nested_results <- list()

  for (i in seq_along(x)) {
    child_result <- extract_nested_srcrefs(
      x[[i]],
      max_lines_preview,
      seen_srcfiles,
      path_prefix = paste0(path_prefix, "[[", i, "]]")
    )

    if (!is.null(child_result)) {
      # If child has a srcref_type, it's a complete srcref-bearing object
      if (!is.null(attr(child_result, "srcref_type"))) {
        # Add it with the accumulated path
        nested_results[[paste0(path_prefix, "[[", i, "]]")]] <- child_result
      } else {
        # Child returned a list of nested paths - merge them
        for (path_name in names(child_result)) {
          nested_results[[path_name]] <- child_result[[path_name]]
        }
      }
    }
  }

  if (length(nested_results) > 0) {
    return(nested_results)
  }

  return(NULL)
}

extract_single_srcref <- function(
  srcref,
  max_lines_preview,
  seen_srcfiles
) {
  info <- extract_srcref_info(srcref)
  srcfile <- attr(srcref, "srcfile")

  result <- new_lobstr_srcref(
    list(
      location = info$location
    ),
    type = "srcref"
  )

  if (!is.null(info$bytes)) {
    result$bytes <- info$bytes
  }

  if (!is.null(info$parsed)) {
    result$parsed <- info$parsed
  }

  if (!is.null(srcfile)) {
    srcfile_info <- extract_srcfile_info(
      srcfile,
      srcref,
      max_lines_preview,
      seen_srcfiles
    )
    # Don't wrap lobstr_srcfile_ref objects (they're already complete)
    if (inherits(srcfile_info, "lobstr_srcfile_ref")) {
      result$`attr("srcfile")` <- srcfile_info
    } else {
      result$`attr("srcfile")` <- new_lobstr_srcref(srcfile_info)
    }
  }

  new_lobstr_srcref(result)
}

extract_srcref_list <- function(
  srcref_list,
  max_lines_preview,
  seen_srcfiles
) {
  srcrefs <- lapply(srcref_list, function(sr) {
    extract_single_srcref(
      sr,
      max_lines_preview,
      seen_srcfiles
    )
  })

  result <- new_lobstr_srcref(
    list(
      count = length(srcref_list),
      srcrefs = new_lobstr_srcref(srcrefs, type = "list")
    ),
    type = "list"
  )

  result
}

extract_function_srcref <- function(
  fun,
  max_lines_preview,
  seen_srcfiles
) {
  srcref_attr <- attr(fun, "srcref")
  whole_srcref <- attr(body(fun), "wholeSrcref")
  srcfile_attr <- attr(fun, "srcfile")

  if (is.null(srcref_attr) && is.null(whole_srcref) && is.null(srcfile_attr)) {
    return(NULL)
  }

  result <- list()

  # Add srcref attribute from function
  if (!is.null(srcref_attr)) {
    if (inherits(srcref_attr, "srcref")) {
      # Single srcref for whole function
      result$`attr("srcref")` <- extract_single_srcref(
        srcref_attr,
        max_lines_preview,
        seen_srcfiles
      )
    } else if (is.list(srcref_attr)) {
      # List of statement srcrefs
      block <- lapply(srcref_attr, function(sr) {
        extract_single_srcref(
          sr,
          max_lines_preview,
          seen_srcfiles
        )
      })
      result$`attr("srcref")` <- new_lobstr_srcref(block, type = "block")
    }
  }

  # Add whole function srcref from body
  if (!is.null(whole_srcref)) {
    body_node <- list(
      `attr("wholeSrcref")` = extract_single_srcref(
        whole_srcref,
        max_lines_preview,
        seen_srcfiles
      )
    )
    result$`body()` <- new_lobstr_srcref(body_node, type = "body")
  }

  # Recursively extract nested srcrefs from the function body
  body_content <- body(fun)
  if (!is.null(body_content)) {
    body_result <- extract_src_data(
      body_content,
      max_lines_preview,
      seen_srcfiles = seen_srcfiles
    )

    # If we found nested srcrefs in the body, add them
    if (!is.null(body_result)) {
      # If we already have a body() node from wholeSrcref, merge the nested results into it
      if ("body()" %in% names(result)) {
        # Add the nested structure to the existing body node
        body_names <- names(body_result)
        for (name in body_names) {
          result$`body()`[[name]] <- body_result[[name]]
        }
      } else {
        # No wholeSrcref, so create a body() node with just the nested results
        result$`body()` <- body_result
      }
    }
  }

  # Add srcfile if available and not already included
  if (!is.null(srcfile_attr) && is.null(whole_srcref) && is.null(srcref_attr)) {
    result$`attr("srcfile")` <- new_lobstr_srcref(
      extract_srcfile_info(
        srcfile_attr,
        NULL,
        max_lines_preview,
        seen_srcfiles
      )
    )
  }

  new_lobstr_srcref(result, type = "closure")
}

extract_srcref_info <- function(srcref) {
  if (!inherits(srcref, "srcref")) {
    abort("Expected a srcref object")
  }

  len <- length(srcref)

  if (!len %in% c(4, 6, 8)) {
    abort(
      sprintf("Unexpected srcref length: %d (expected 4, 6, or 8)", len),
      srcref = srcref
    )
  }

  first_line <- srcref_first_line(srcref)
  first_byte <- srcref_first_byte(srcref)
  last_line <- srcref_last_line(srcref)
  last_byte <- srcref_last_byte(srcref)
  first_col <- srcref_first_col(srcref)
  last_col <- srcref_last_col(srcref)
  first_parsed <- srcref_first_parsed(srcref)
  last_parsed <- srcref_last_parsed(srcref)

  info <- list(
    first_line = first_line,
    first_byte = first_byte,
    last_line = last_line,
    last_byte = last_byte,
    first_col = first_col,
    last_col = last_col,
    first_parsed = first_parsed,
    last_parsed = last_parsed,
    location = new_lobstr_srcref_location(
      format_location(first_line, first_col, last_line, last_col)
    )
  )

  # Add byte info if different from columns
  if (first_byte != first_col || last_byte != last_col) {
    info$bytes <- format_bytes(first_byte, last_byte)
  }

  # Add parsed info if different from actual lines
  if (first_parsed != first_line || last_parsed != last_line) {
    info$parsed <- format_parsed(first_parsed, first_col, last_parsed, last_col)
  }

  info
}

extract_srcfile_info <- function(
  srcfile,
  srcref = NULL,
  max_lines_preview = 3L,
  seen_srcfiles
) {
  if (is.null(srcfile)) {
    return(NULL)
  }

  addr <- obj_addr(srcfile)
  srcfile_class <- class(srcfile)[[1]]

  # Check for deduplication
  id <- seen_srcfiles[[addr]]
  if (!is_null(id)) {
    return(new_lobstr_srcfile_ref(id, srcfile_class))
  }

  # First occurrence - assign ID (first 6 chars of hex address without 0x)
  id <- substr(addr, 3, 8)
  seen_srcfiles[[addr]] <- id

  # Convert srcfile environment to list showing all fields as-is
  info <- as.list.environment(srcfile, all.names = TRUE, sorted = TRUE)

  # Format timestamp if present for more ergonomic display
  if (!is.null(info$timestamp)) {
    info$timestamp <- format(info$timestamp)
  }

  # For plain srcfile (not srcfilecopy), show source lines preview
  if (!inherits(srcfile, "srcfilecopy") && !is.null(srcref)) {
    snippet <- extract_lines_from_srcfile(
      srcfile,
      srcref,
      max_lines_preview,
      embedded = FALSE
    )
    if (length(snippet) > 0) {
      info$`lines (from file)` <- snippet
    }
  }

  new_lobstr_srcref(
    info,
    type = "srcfile",
    srcfile_class = srcfile_class %||% "srcfile",
    srcfile_id = id
  )
}

extract_lines_from_srcfile <- function(
  srcfile,
  srcref,
  max_lines = 3L,
  embedded = TRUE
) {
  if (is.null(srcfile) || is.null(srcref)) {
    return(character(0))
  }

  first_line <- srcref_first_line(srcref)
  last_line <- srcref_last_line(srcref)

  # Truncate if too many lines
  if (last_line - first_line + 1 > max_lines) {
    last_line <- first_line + max_lines - 1
  }

  # First check for lines in srcfile (srcfilecopy stores source)
  lines <- srcfile$lines
  if (!is.null(lines) && length(lines) >= last_line) {
    return(lines[first_line:last_line])
  }

  # Now try reading from file
  # For srcfilecopy with  isFile = TRUE`, or plain srcfile pointing to a real file
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

  # We tried
  character(0)
}

has_srcref <- function(x) {
  !is.null(attr(x, "srcref")) ||
    !is.null(attr(x, "wholeSrcref")) ||
    !is.null(attr(x, "srcfile"))
}


# Formatting ---

format_location <- function(first_line, first_col, last_line, last_col) {
  sprintf("%d:%d-%d:%d", first_line, first_col, last_line, last_col)
}

format_bytes <- function(first_byte, last_byte) {
  sprintf("%d-%d", first_byte, last_byte)
}

format_parsed <- function(first_parsed, first_col, last_parsed, last_col) {
  sprintf("%d:%d-%d:%d", first_parsed, first_col, last_parsed, last_col)
}

#' @export
tree_label.lobstr_srcref_location <- function(x, opts) {
  as.character(x)
}

#' @export
tree_label.srcref <- function(x, opts) {
  location <- format_location(x[1], x[5] %||% x[2], x[3], x[6] %||% x[4])
  paste0("<srcref: ", location, ">")
}

#' @export
tree_label.srcfile <- function(x, opts) {
  paste0("<", class(x)[1], ": ", getSrcFilename(x), ">")
}

#' @export
tree_label.lobstr_srcfile_ref <- function(x, opts) {
  # Show reference ID
  paste0("@", as.character(x))
}

#' @export
tree_label.lobstr_srcref <- function(x, opts) {
  type <- srcref_type(x)

  label <- switch(
    type,
    "body" = "",
    "block" = "<{>",
    "srcfile" = tree_label_srcfile(x),
    paste0("<", type, ">")
  )

  label
}

tree_label_srcfile <- function(x) {
  class <- srcfile_class(x)
  label <- paste0("<", class, ">")

  id <- srcfile_id(x)
  if (!is.null(id)) {
    label <- paste0(label, " @", id)
  }

  label
}


# Helper classes ---

new_lobstr_srcref <- function(x, type = NULL, ..., class = NULL) {
  type <- type %||% srcref_type(x)
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

srcref_type <- function(x) {
  attr(x, "srcref_type")
}
srcfile_class <- function(x) {
  attr(x, "srcfile_class")
}
srcfile_id <- function(x) {
  attr(x, "srcfile_id")
}
max_depth <- function(x) {
  attr(x, "max_depth")
}
max_length <- function(x) {
  attr(x, "max_length")
}
max_vec_len <- function(x) {
  attr(x, "max_vec_len")
}
tree_args <- function(x) {
  attr(x, "tree_args")
}

# The goal of this class is to provide a custom `tree_label()` method that shows
# unquoted locations. This way we don't make it seem the location string is
# literally stored in the srcref object.
new_lobstr_srcref_location <- function(x) {
  structure(x, class = c("lobstr_srcref_location", "character"))
}

new_lobstr_srcfile_ref <- function(id, srcfile_class = "srcfile") {
  structure(
    id,
    srcfile_class = srcfile_class,
    class = "lobstr_srcfile_ref"
  )
}


# srcref accessors ---

srcref_first_line <- function(x) {
  x[[1]]
}
srcref_first_byte <- function(x) {
  x[[2]]
}
srcref_last_line <- function(x) {
  x[[3]]
}
srcref_last_byte <- function(x) {
  x[[4]]
}
srcref_first_col <- function(x) {
  if (length(x) >= 6) x[[5]] else x[[2]]
}
srcref_last_col <- function(x) {
  if (length(x) >= 6) x[[6]] else x[[4]]
}
srcref_first_parsed <- function(x) {
  if (length(x) == 8) x[[7]] else x[[1]]
}
srcref_last_parsed <- function(x) {
  if (length(x) == 8) x[[8]] else x[[3]]
}
