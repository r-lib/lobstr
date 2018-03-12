#' Find memory location of objects and their children.
#'
#' `obj_addr()` gives the address of the value that `x` points to;
#' `obj_addrs()` gives the address of the components the list,
#' environment, and character vector `x` point to
#'
#' @param x An object
#' @export
#' @examples
#' # R creates copies lazily
#' x <- 1:10
#' y <- x
#' obj_addr(x) == obj_addr(y)
#'
#' y[1] <- 2L
#' obj_addr(x) == obj_addr(y)
#'
#' y <- runif(10)
#' obj_addr(y)
#' z <- list(y, y)
#' obj_addrs(z)
#'
#' y[2] <- 1.0
#' obj_addrs(z)
#' obj_addr(y)
#'
#' # The address of an object is different every time you create it:
#' obj_addr(1:10)
#' obj_addr(1:10)
#' obj_addr(1:10)
obj_addr <- function(x) {
  addr <- obj_addr_(x)

  if (is_testing()) {
    test_addr_get(addr)
  } else {
    addr
  }
}

#' @export
#' @rdname obj_addr
obj_addrs <- function(x) {
  addrs <- obj_addrs_(x)

  if (is_testing()) {
    vapply(addrs, test_addr_get, character(1), USE.NAMES = FALSE)
  } else {
    addrs
  }
}


test_addr <- child_env(emptyenv(), "__next_id" = 1)

test_addr_get <- function(addr) {
  if (env_has(test_addr, addr)) {
    addr <- env_get(test_addr, addr)
  } else {
    addr <- obj_id(test_addr, addr)
  }
  sprintf("0x%03i", addr)
}

test_addr_reset <- function() {
  env_poke(test_addr, "__next_id", 1)
}
