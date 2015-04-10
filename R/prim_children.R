#' Primitive children.
#'
#' Extract all the low-level children of an element. This works at a low-level:
#' all dispatch is done in C on the SEXPTYPE. No S3 dispatch is performed. The
#' result has an \code{$} method defined so you can interactively drill down.
#'
#' @param x An object.
#' @export
#' @return A list of children with class "primlist". This list should be
#'   considered read-only. DO NOT modify any elements returned by this
#'   function.
#' @examples
#' prim_children(mtcars)
#' prim_children(mtcars)$`__attributes`
#' prim_children(list(1:10, runif(1e3)))
prim_children <- function(x) {
  structure(prim_children_(x), class = "primlist")
}

#' @export
print.primlist <- function(x, ...) {
  if (length(x) == 0) {
    cat("<empty>\n")
    return()
  }

  types <- vapply(x, prim_type, character(1))
  descs <- vapply(x, prim_desc, character(1))

  if (is.null(names(x))) {
    labels <- rep("", length = x)
  } else {
    labels <- format(ifelse(names(x) == "", "", names(x)))
  }

  cat(paste0("* ", labels, " ", types, " ", descs, collapse = "\n"))
  cat("\n")
}

#' @export
`$.primlist` <- function(x, i, ...) {
  prim_children(x[[i]])
}
