#' Calculate the size of an object.
#'
#' `obj_size()` computes the size of an object or set of objects;
#' `obj_sizes()` breaks down the individual contribution of multiple objects
#' to the total size.
#'
#' @section Compared to `object.size()`:
#' Compared to [object.size()], `obj_size()`:
#'
#' * Accounts for all types of shared values, not just strings in
#'   the global string pool.
#'
#' * Includes the size of environments (up to `env`)
#'
#' * Accurately measures the size of ALTREP objects.
#'
#' @section Environments:
#' `obj_size()` attempts to take into account the size of the
#' environments associated with an object. This is particularly important
#' for closures and formulas, since otherwise you may not realise that you've
#' accidentally captured a large object. However, it's easy to over count:
#' you don't want to include the size of every object in every environment
#' leading back to the [emptyenv()]. `obj_size()` takes
#' a heuristic approach: it never counts the size of the global environment,
#' the base environment, the empty environment, or any namespace.
#'
#' Additionally, the `env` argument allows you to specify another
#' environment at which to stop. This defaults to the environment from which
#' `obj_size()` is called to prevent double-counting of objects created
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
#' x <- runif(1e4)
#' obj_size(x)
#'
#' z <- list(a = x, b = x, c = x)
#' obj_size(z)
#'
#' # this means that object size is not transitive
#' obj_size(x)
#' obj_size(z)
#' obj_size(x, z)
#'
#' # use obj_size() to see the unique contribution of each component
#' obj_sizes(x, z)
#' obj_sizes(z, x)
#' obj_sizes(!!!z)
#'
#' # obj_size() also includes the size of environments
#' f <- function() {
#'   x <- 1:1e4
#'   a ~ b
#' }
#' obj_size(f())
#'
#' #' # In R 3.5 and greater, `:` creates a special "ALTREP" object that only
#' # stores the first and last elements. This will make some vectors much
#' # smaller than you'd otherwise expect
#' obj_size(1:1e6)
obj_size <- function(..., env = parent.frame()) {
  dots <- list2(...)
  size <- obj_size_(dots, env, size_node(), size_vector())
  new_bytes(size)
}

#' @rdname obj_size
#' @export
obj_sizes <- function(..., env = parent.frame()) {
  dots <- list2(...)
  size <- obj_csize_(dots, env, size_node(), size_vector())
  names(size) <- names(dots)
  new_bytes(size)
}

size_node <- function(x) as.vector(utils::object.size(quote(expr = )))
size_vector <- function(x) as.vector(utils::object.size(logical()))

new_bytes <- function(x) {
  structure(x, class = "lobstr_bytes")
}

#' @export
print.lobstr_bytes <- function(x, digits = 3, ...) {
  fx <- format(x, big.mark = ",", scientific = FALSE)

  if (length(x) == 1) {
    cat_line(fx, " B")
  } else {
    if (!is.null(names(x))) {
      cat_line(format(names(x)), ": ", fx, " B")
    } else {
      cat_line("* ", fx, " B")
    }
  }
}

#' @export
c.lobstr_bytes <- function(...) {
  new_bytes(NextMethod())
}

#' @export
`[.lobstr_bytes` <- function(...) {
  new_bytes(NextMethod())
}
