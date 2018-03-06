#' Information about low-level memory usage.
#'
#' These functions are careful not to take an R-level reference to the
#' underlying object, hence distorting the ref count.
#'
#' @param x An object to inspect
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
#' lapply(prim_children(z), obj_address)
#'
#' y[2] <- 1.0
#' lapply(prim_children(z), obj_address)
#' obj_address(y)
#' obj_refs(y)
#'
#' # The address of an expression is different every time:
#' obj_address(1:10)
#' obj_address(1:10)
#' obj_address(1:10)
#'
#' # An expression has a ref count of 0 because it's never assigned
#' # a name
#' obj_refs(1:10)
#' obj_refs(x)
#'
#' # The RStudio environment pane takes a reference to objects.
#' # In the console, this will return 1, in RStudio 2.
#' x <- 1:10
#' obj_refs(x)
obj_address <- function(x) {
  prim_address_(quote(x), environment())
}

#' @export
#' @rdname obj_address
obj_refs <- function(x) {
  prim_refs_(quote(x), environment())
}

obj_addresses <- function(x) {
  prim_addresses_(quote(x), environment())
}

