#' A brief description of an object.
#'
#' \code{prim_desc()} describes the primitive R object. \code{user_desc()}
#' is an S3 method that object creators can override to provide better
#' navigation
#'
#' @param x An object to describe
#' @export
#' @examples
#' prim_desc(1:100)
#' prim_desc(quote(a))
prim_desc <- function(x) {
  prim_desc_(quote(x), environment())
}

#' @export
#' @rdname prim_desc
#' @param ... Additional arguments pass to \code{user_desc} methods.
user_desc <- function(x, ...) {
  UseMethod("user_desc")
}

#' @export
user_desc.default <- function(x, ...) {
  prim_desc(x)
}

