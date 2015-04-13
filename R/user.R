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

#' @export
#' @param ... Additional arguments pass to \code{user_children} methods.
#' @rdname prim_children
user_children <- function(x, ...) {
  UseMethod("user_children")
}

#' @export
user_children.default <- function(x, ...) {
  prim_children(x)
}
