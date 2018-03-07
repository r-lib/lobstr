#' The type of an object.
#'
#' `prim_type()` returns the type of the underlying R object.
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
  x <- enquo(x)
  prim_type_(quo_get_expr(x), quo_get_env(x))
}
