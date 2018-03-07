#' A brief description of an object.
#'
#' `prim_desc()` describes the primitive R object.
#'
#' @param x An object to describe
#' @export
#' @examples
#' prim_desc(1:100)
#' prim_desc(quote(a))
prim_desc <- function(x) {
  x <- enquo(x)
  prim_desc_(quo_get_expr(x), quo_get_env(x))
}
