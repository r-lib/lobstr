#' Calculate the size of an object.
#'
#' \code{prim_size} works similarly to \code{\link{object.size}}, but counts
#' more accurately and includes the size of environments. \code{compare_size}
#' makes it easy to compare the output of \code{prim_size} and
#' \code{object.size}.
#'
#' @section Environments:
#'
#' \code{prim_size} attempts to take into account the size of the
#' environments associated with an object. This is particularly important
#' for closures and formulas, since otherwise you may not realise that you've
#' accidentally captured a large object. However, it's easy to over count:
#' you don't want to include the size of every object in every environment
#' leading back to the \code{\link{emptyenv}()}. \code{prim_size} takes
#' a heuristic approach: it never counts the size of the global env,
#' the base env, the empty env or any namespace.
#'
#' Additionally, the \code{env} argument allows you to specify another
#' environment at which to stop. This defaults to the environment from which
#' \code{prim_size} is called to prevent double-counting of objects created
#' elsewhere.
#'
#' @export
#' @examples
#' # object.size doesn't keep track of shared elements in an object
#' # prim_size does
#' x <- 1:1e4
#' z <- list(x, x, x)
#' compare_size(z)
#'
#' # this means that prim_size is not transitive
#' prim_size(x)
#' prim_size(z)
#' prim_size(x, z)
#'
#' # object.size doesn't include the size of environments, which makes
#' # it easy to miss objects that are carrying around large environments
#' f <- function() {
#'   x <- 1:1e4
#'   a ~ b
#' }
#' compare_size(f())
#' @param x,... Set of objects to compute total size.
#' @param env Environment in which to terminate search. This defaults to the
#'   current environment so that you don't include the size of objects that
#'   are already stored elsewhere.
#' @return An estimate of the size of the object, in bytes.
prim_size <- function(..., env = parent.frame()) {
  show_bytes(prim_sizes(list(...), env))
}

#' @export
#' @rdname prim_size
compare_size <- function(x) {
  c(base = object.size(x), pryr = prim_size(x))
}


show_bytes <- function(x) {
  structure(x, class = "bytes")
}

#' @export
print.bytes <- function(x, digits = 3, ...) {
  power <- min(floor(log(abs(x), 1000)), 4)
  if (power < 1) {
    unit <- "B"
  } else {
    unit <- c("kB", "MB", "GB", "TB")[[power]]
    x <- x / (1000 ^ power)
  }

  formatted <- format(signif(x, digits = digits), big.mark = ",",
    scientific = FALSE)

  cat(formatted, " ", unit, "\n", sep = "")
}
