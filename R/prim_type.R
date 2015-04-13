#' The type of an object.
#'
#' \code{prim_type()} returns the type of the underlying R object.
#' \code{user_type()} is an S3 generic that can be optionally overridden
#' by class authors in order to provide better navigation.
#'
#' @param x An object to describe.
#' @export
#' @examples
#' prim_type("a")
#' prim_type(mtcars)
#' prim_type(sum)
#' prim_type(mean)
#' prim_type(formals(mean))
#' prim_type(formals(mean)[[1]])
prim_type <- function(x) {
  prim_type_(quote(x), environment)
}

#' @export
#' @rdname prim_type
#' @param ... Additional arguments pass to \code{user_type} methods.
user_type <- function(x, ...) {
  UseMethod("user_type")
}

#' @export
user_type.default <- function(x, ...) {
  prim_type(x)
}

