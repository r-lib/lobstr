#' A brief description of an object.
#'
#' \code{prim_desc()} describes the primitive R object.
#'
#' @param x An object to describe
#' @export
#' @examples
#' prim_desc(1:100)
#' prim_desc(quote(a))
prim_desc <- function(x) {
  prim_desc_(quote(x), environment())
}
