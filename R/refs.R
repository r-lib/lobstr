#' Access reference count
#'
#' This is a R wrapper to the C-level `NAMED()` macro, which estimates how
#' many references (names) a value has.
#'
#' @param x An object
#' @examples
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
#'
#' x <- 1:10
#' y <- x
#' obj_refs(x)
#' z <- x
#' # R can count references to a maximum of 2
#' # which also means that a count of two can never be decremented
#' rm(x, y)
#' obj_refs(z)
#' @export
obj_refs <- function(x) {
  x <- enquo(x)
  prim_refs_(quo_get_expr(x), quo_get_env(x))
}
