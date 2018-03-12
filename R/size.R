#' Calculate the size of an object.
#'
#' `obj_size` works similarly to [object.size()], but correctly
#' takes into account shared values, and includes the size of environments.
#'
#' @section Environments:
#' `obj_size` attempts to take into account the size of the
#' environments associated with an object. This is particularly important
#' for closures and formulas, since otherwise you may not realise that you've
#' accidentally captured a large object. However, it's easy to over count:
#' you don't want to include the size of every object in every environment
#' leading back to the [emptyenv()]. `obj_size` takes
#' a heuristic approach: it never counts the size of the global env,
#' the base env, the empty env, or any namespace.
#'
#' Additionally, the `env` argument allows you to specify another
#' environment at which to stop. This defaults to the environment from which
#' `obj_size` is called to prevent double-counting of objects created
#' elsewhere.
#'
#' @export
#' @param ... Set of objects to compute size.
#' @param env Environment in which to terminate search. This defaults to the
#'   current environment so that you don't include the size of objects that
#'   are already stored elsewhere.
#' @return An estimate of the size of the object, in bytes.
#' @examples
#' # obj_size correctly accounts for shared references
#' x <- 1:1e4
#' obj_size(x)
#'
#' z <- list(x, x, x)
#' obj_size(z)
#'
#' # this means that object size is not transitive
#' obj_size(x)
#' obj_size(z)
#' obj_size(x, z)
#'
#' # obj_size() also includes the size of environments
#' f <- function() {
#'   x <- 1:1e4
#'   a ~ b
#' }
#' obj_size(f())
obj_size <- function(..., env = parent.frame()) {
  size <- obj_size_(list(...), env)
  new_bytes(size)
}

new_bytes <- function(x) {
  structure(x, class = "lobstr_bytes")
}

#' @export
print.lobstr_bytes <- function(x, digits = 3, ...) {
  fx <- format(x, big.mark = ",", scientific = FALSE)
  cat(paste0(fx, " B", "\n", collapse = ""))
}

#' @export
c.lobstr_bytes <- function(...) {
  new_bytes(NextMethod())
}
