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
#'
#' # An expression has a ref count of 0 because it's never assigned
#' # a name
#' obj_refs(1:10)
#'
#' # The RStudio environment pane takes a reference to objects.
#' # In the console, this will return 1, in RStudio 2.
#' x <- 1:10
#' obj_refs(x)
#'
#' f <- function() {
#'   x <- 1:10
#'   obj_refs(x)
#' }
#' f()
obj_address <- function(x) {
  prim_address_(quote(x), environment())
}

#' @export
#' @rdname obj_address
obj_refs <- function(x) {
  prim_refs_(quote(x), environment())
}

#' @export
#' @rdname obj_address
obj_addresses <- function(x) {
  prim_addresses_(quote(x), environment())
}

