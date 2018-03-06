#' Find memory location of objects and their children.
#'
#' `obj_address()` gives the address of the value that `x` points to;
#' `obj_addresses()` gives the address of the components the list,
#' environment, and character vector `x` point to
#'
#' @param x An object
#' @export
#' @examples
#' # R creates copies lazily
#' x <- 1:10
#' y <- x
#' obj_address(x) == obj_address(y)
#'
#' y[1] <- 2L
#' obj_address(x) == obj_address(y)
#'
#' y <- runif(10)
#' obj_address(y)
#' z <- list(y, y)
#' obj_addresses(z)
#'
#' y[2] <- 1.0
#' obj_addresses(z)
#' obj_address(y)
#'
#' # The address of an object is different every time you create it:
#' obj_address(1:10)
#' obj_address(1:10)
#' obj_address(1:10)
obj_address <- function(x) {
  prim_address_(quote(x), environment())
}

#' @export
#' @rdname obj_address
obj_addresses <- function(x) {
  prim_addresses_(quote(x), environment())
}

