prim_children <- function(x) {
  structure(prim_children_(x), class = "primlist")
}

#' @export
print.primlist <- function(x, ...) {
  if (length(x) == 0) {
    cat("<empty>\n")
    return()
  }

  types <- vapply(x, typeof, character(1))
  lengths <- vapply(x, prim_length, integer(1))

  if (is.null(names(x))) {
    labels <- rep("", length = x)
  } else {
    labels <- format(ifelse(names(x) == "", "", names(x)))
  }

  cat(paste0("* ", labels, " ", types, " [", lengths, "]", collapse = "\n"))
  cat("\n")
}

#' @export
`$.primlist` <- function(x, i, ...) {
  prim_children(x[[i]])
}
