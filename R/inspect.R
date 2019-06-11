#' Inspect an object
#'
#' `obj_inspect(x)` is similar to `.Internal(inspect(x))`. The main difference
#' is the output is a little more compact, it recurses fully, and avoids
#' getting stuck in infinite loops by using a depth-first search. It also
#' returns a list that you can compute with, and carefully uses colour to
#' highlight the most important details.
#'
#' @param x Object to inspect
#' @param expand Optionally, expand "character" vectors (to see the underlying
#'   entries in the global string pool), "environments" (to see the underlying
#'   hashtables), and/or "altrep" objects (to see the underlying data).
#' @export
#' @examples
#' x <- list(
#'   TRUE,
#'   1L,
#'   runif(100),
#'   "3"
#' )
#' obj_inspect(x)
#'
#' # Expand "character" to see underlying CHARSXP entries in the global
#' # string pool
#' x <- c("banana", "banana", "apple", "banana")
#' obj_inspect(x)
#' obj_inspect(x, expand = "character")
#'
#' # Expand altrep to see underlying data
#' x <- 1:10
#' obj_inspect(x)
#' obj_inspect(x, expand = "altrep")
#'
#' # Expand environmnets to see the underlying implementation details
#' e1 <- new.env(hash = FALSE, parent = emptyenv(), size = 3L)
#' e2 <- new.env(hash = TRUE, parent = emptyenv(), size = 3L)
#' e1$x <- e2$x <- 1:10
#'
#' obj_inspect(e1)
#' obj_inspect(e1, expand = "environment")
#' obj_inspect(e2, expand = "environment")
obj_inspect <- function(x, expand = character()) {

  opts <- c("character", "altrep", "environment")
  if (any(!expand %in% opts)) {
    abort("`expand` must contain only values from ", paste("'", opts, "'", collapse = ","))
  }

  obj_inspect_(x,
    opts[[1]] %in% expand,
    opts[[2]] %in% expand,
    opts[[3]] %in% expand
  )
}



#' @export
format.lobstr_inspector <- function(x, ..., depth = 0, name = NA) {
  indent <- paste0(rep("  ", depth), collapse = "")

  if (!is_testing()) {
    addr <- paste0(":", crayon::silver(attr(x, "addr")))
  } else {
    addr <- ""
  }

  if (attr(x, "type") == 0) {
    desc <- crayon::silver("<NILSXP>")
  } else if (attr(x, "has_seen")) {
    desc <- paste0("[", attr(x, "id"), addr, "]")
  } else {
    type <- sexp_type(attr(x, "type"))
    if (sexp_is_vector(type)) {
      if (!is.null(attr(x, "truelength"))) {
        length <- paste0("[", attr(x, "length"), "/", attr(x, "truelength"), "]")
      } else {
        length <- paste0("[", attr(x, "length"), "]")
      }
    } else {
      length <- NULL
    }

    if (!is.null(attr(x, "value"))) {
      value <- paste0(": ", attr(x, "value"))
    } else {
      value <- NULL
    }
    # show altrep, object, named etc
    sxpinfo <- paste0(
      if (attr(x, "altrep")) "altrep ",
      if (attr(x, "object")) "object ",
      if (!is_testing()) paste0("named:", attr(x, "named"))
    )

    desc <- paste0(
      "[", crayon::bold(attr(x, "id")), addr, "] ",
      "<", crayon::cyan(type), length, value, "> ",
      "(", sxpinfo, ")"
    )
  }

  name <- if (!is.na(name)) paste0(crayon::italic(crayon::silver(name)), " ")

  paste0(indent, name, desc)
}

#' @export
print.lobstr_inspector <- function(x, ..., depth = 0, name = NA) {
  cat_line(format(x, depth = depth, name = name))
  for (i in seq_along(x)) {
    print(x[[i]], depth = depth + 1, name = names(x)[[i]])
  }
}

# helpers -----------------------------------------------------------------

sexp_type <- function(x) {
  unname(SEXPTYPE[as.character(x)])
}

sexp_is_vector <- function(x) {
  x %in% c("LGLSXP", "INTSXP", "REALSXP", "STRSXP", "RAWSXP", "CPLXSXP", "VECSXP", "EXPRSXP")
}

SEXPTYPE <- c(
  "0" = "NILSXP",
  "1" = "SYMSXP",
  "2" = "LISTSXP",
  "3" = "CLOSXP",
  "4" = "ENVSXP",
  "5" = "PROMSXP",
  "6" = "LANGSXP",
  "7" = "SPECIALSXP",
  "8" = "BUILTINSXP",
  "9" = "CHARSXP",
  "10" = "LGLSXP",
  "13" = "INTSXP",
  "14" = "REALSXP",
  "15" = "CPLXSXP",
  "16" = "STRSXP",
  "17" = "DOTSXP",
  "18" = "ANYSXP",
  "19" = "VECSXP",
  "20" = "EXPRSXP",
  "21" = "BCODESXP",
  "22" = "EXTPTRSXP",
  "23" = "WEAKREFSXP",
  "24" = "RAWSXP",
  "25" = "S4SXP",
  "30" = "NEWSXP",
  "31" = "FREESXP",
  "99" = "FUNSXP"
)

