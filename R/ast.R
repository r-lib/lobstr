#' Display the abstract syntax tree
#'
#' This is a useful alternative to `str()` for expression objects.
#'
#' @param x An expression to display. Input is automatically quoted,
#'   use `!!` to unquote if you have already captured an expression object.
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
#' # Displaying expression already stored in object
#' x <- quote(a + b + c)
#' ast(x)
#' ast(!!x)
#'
#' # All operations have this same structure
#' ast(if (TRUE) 3 else 4)
#' ast(y <- x * 10)
#' ast(function(x = 1, y = 2) { x + y } )
#'
#' # Operator precedence
#' ast(1 * 2 + 3)
#' ast(!1 + !1)
ast <- function(x) {
  expr <- enexpr(x)
  new_raw(ast_tree(expr))
}

ast_tree <- function(x, layout = box_chars()) {
  if (is_quosure(x)) {
    x <- quo_expr(x)
  }

  # base cases
  if (rlang::is_syntactic_literal(x)) {
    return(ast_leaf_constant(x))
  } else if (is_symbol(x)) {
    return(ast_leaf_symbol(x))
  } else if (!is.pairlist(x) && !is.call(x)) {
    return(paste0("<inline ", paste0(class(x), collapse = "/"), ">"))
  }

  # recursive case
  subtrees <- lapply(x, ast_tree, layout = layout)
  subtrees <- name_subtree(subtrees)

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

name_subtree <- function(x) {
  nm <- names(x)
  if (is.null(nm))
    return(x)

  has_name <- nm != ""
  label <- paste0(crayon::italic(grey(nm)), " = ")
  indent <- str_dup(" ", nchar(nm) + 3)

  x[has_name] <- Map(str_indent, x[has_name], label[has_name], indent[has_name])
  x
}

ast_leaf_symbol <- function(x) {
  x <- as.character(x)
  if (!is.syntactic(x)) {
    x <- encodeString(x, quote = "`")
  }

  crayon::bold(crayon::magenta(x))
}
ast_leaf_constant <- function(x) {
  if (is.complex(x)) {
    paste0(Im(x), "i")
  } else {
    deparse(x)
  }
}

is.syntactic <- function(x) make.names(x) == x
