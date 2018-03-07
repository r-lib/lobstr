#' Find memory location of objects and their children.
#'
#' `obj_addr()` gives the address of the value that `x` points to;
#' `obj_addrs()` gives the address of the components the list,
#' environment, and character vector `x` point to
#'
#' @param x An object
#' @export
#' @examples
#' # R creates copies lazily
#' x <- 1:10
#' y <- x
#' obj_addr(x) == obj_addr(y)
#'
#' y[1] <- 2L
#' obj_addr(x) == obj_addr(y)
#'
#' y <- runif(10)
#' obj_addr(y)
#' z <- list(y, y)
#' obj_addrs(z)
#'
#' y[2] <- 1.0
#' obj_addrs(z)
#' obj_addr(y)
#'
#' # The address of an object is different every time you create it:
#' obj_addr(1:10)
#' obj_addr(1:10)
#' obj_addr(1:10)
obj_addr <- function(x) {
  x <- enquo(x)
  prim_address_(quo_get_expr(x), quo_get_env(x))
}

#' @export
#' @rdname obj_addr
obj_addrs <- function(x) {
  x <- enquo(x)
  prim_addresses_(quo_get_expr(x), quo_get_env(x))
}

