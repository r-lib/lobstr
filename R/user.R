#' @export
#' @rdname prim_type
user_type <- function(x, ...) {
  UseMethod("user_type")
}

#' @export
user_type.default <- function(x, ...) {
  prim_type(x)
}

#' @export
#' @rdname prim_desc
user_desc <- function(x, ...) {
  UseMethod("user_desc")
}

#' @export
user_desc.default <- function(x, ...) {
  prim_desc(x)
}

#' @export
#' @rdname prim_children
user_children <- function(x, ...) {
  UseMethod("user_children")
}

#' @export
user_children.default <- function(x, ...) {
  prim_children(x)
}
