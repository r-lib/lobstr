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
#' prim_address(x) == prim_address(y)
#'
#' y[1] <- 2L
#' prim_address(x) == prim_address(y)
#'
#' # The address of an expression is different every time:
#' prim_address(1:10)
#' prim_address(1:10)
#' prim_address(1:10)
#'
#' # An expression has a ref count of 0 because it's never assigned
#' # a name
#' prim_refs(1:10)
#' prim_refs(x)
#'
#' # The RStudio environment pane takes a reference to objects.
#' # In the console, this will return 1, in RStudio 2.
#' x <- 1:10
#' prim_refs(x)
prim_address <- function(x) {
  prim_address_(quote(x), environment())
}

#' @export
#' @rdname prim_address
prim_refs <- function(x) {
  prim_refs_(quote(x), environment())
}
