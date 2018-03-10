#' How much memory is currently used by R?
#'
#' `mem_used()` wraps around `gc()` and returns the exact number of bytes
#' currently used by R. Note that changes will not match up exactly to
#' [obj_size()] as session specific state (e.g. [.Last.value]) adds minor
#' variations.
#'
#' @export
#' @examples
#' prev_m <- 0; m <- mem_used(); m - prev_m
#'
#' x <- 1:1e6
#' prev_m <- m; m <- mem_used(); m - prev_m
#' obj_size(x)
#'
#' rm(x)
#' prev_m <- m; m <- mem_used(); m - prev_m
#'
#' prev_m <- m; m <- mem_used(); m - prev_m
mem_used <- function() {
  new_bytes(sum(gc()[, 1] * c(node_size(), 8)))
}

node_size <- function() {
  bit <- 8L * .Machine$sizeof.pointer
  if (!(bit == 32L || bit == 64L)) {
    stop("Unknown architecture", call. = FALSE)
  }

  if (bit == 32L) 28L else 56L
}
