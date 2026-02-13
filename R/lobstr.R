#' @import rlang
#' @useDynLib lobstr, .registration = TRUE
NULL

.onLoad <- function(libname, pkgname) {
  init_library(rlang::ns_env(pkgname))
}
