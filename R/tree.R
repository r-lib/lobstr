#' Display the abstract syntax tree
#'
#' This is a useful alterantive to \code{str()} for expression objects.
#'
#' @param x A language object to display.
#' @export
#' @examples
#' # Leaves
#' ast(1)
#' ast(x)
#'
#' # Simple calls
#' ast(f())
#' ast(f(x, 1, g(), h(i())))
#' ast(f()())
#' ast(f(x)(y))
#'
#' ast((x + 1))
#'
#' # All operations have this same structure
#' ast(if (TRUE) 3 else 4)
#' ast(y <- x * 10)
#' # ast(function(x = 1, y = 2) { x + y } )
#'
#' # Operator precedence
#' ast(1 * 2 + 3)
#' ast(!1 + !1)
ast <- function(x) {
  expr <- enexpr(x)
  out <- tree(expr)

  structure(out, class = "lobstr_ast")
}

#' @export
print.lobstr_ast <- function(x, ...) {
  cat(paste(x, "\n", collapse = ""), sep = "")
  invisible(x)
}

tree <- function(x, layout = box_chars()) {
  # base cases
  if (rlang::is_syntactic_literal(x)) {
    return(leaf_constant(x))
  } else if (is_symbol(x)) {
    return(leaf_symbol(x))
  } else if (!is.pairlist(x) && !is.call(x)) {
    return(paste0("<inline ", paste0(class(x), collapse = "/"), ">"))
  }

  # recursive case
  subtrees <- lapply(x, tree, layout = layout)

  n <- length(x)
  if (n == 0) {
    character()
  } else if (n == 1) {
    str_indent(subtrees[[1]],
      paste0(layout$n, layout$h),
      "  "
    )
  } else {
    c(
      str_indent(subtrees[[1]],
        paste0(layout$n, layout$h),
        paste0(layout$v,  " ")
      ),
      unlist(lapply(subtrees[-c(1, n)],
        str_indent,
        paste0(layout$j, layout$h),
        paste0(layout$v,  " ")
      )),
      str_indent(subtrees[[n]],
        paste0(layout$l, layout$h),
        "  "
      )
    )
  }
}

box_chars <- function() {
  fancy <- getOption("pkgdepends.fancy.tree") %||% l10n_info()$`UTF-8`
  orange <- crayon::make_style("orange")

  if (fancy) {
    list(
      "h" = "\u2500",          # ─ horizontal
      "v" = "\u2502",          # │ vertical
      "l" = "\u2514",          # └ leaf
      "j" = "\u251C",          # ├ junction
      "n" = orange("\u2588")   # █ node
    )
  } else {
    list(
      "h" = "-",
      "v" = "|",
      "l" = "\\",
      "j" = "+",
      "n" = orange("X")
    )
  }
}

leaf_symbol <- function(x) {
  x <- as.character(x)
  if (!is.syntactic(x)) {
    x <- encodeString(x, quote = "`")
  }

  crayon::bold(crayon::magenta(x))
}
leaf_constant <- function(x) {
  if (is.character(x)) {
    encodeString(x, quote = '"')
  } else {
    as.character(x)
  }
}

is.syntactic <- function(x) make.names(x) == x


# string utils ------------------------------------------------------------

str_indent <- function(x, first, rest) {
  if (length(x) == 1) {
    paste0(first, x)
  } else {
    c(
      paste0(first, x[[1]]),
      paste0(rest, x[-1L])
    )
  }

}

str_trunc <- function(x, max_width = getOption("width")) {
  width <- nchar(x)

  too_wide <- width > max_width
  x[too_wide] <- paste0(substr(x[too_wide], 1, width[too_wide] - 3), "...")

  x
}

str_dup <- function(x, n) {
  paste0(rep(x, n), collapse = "")
}


