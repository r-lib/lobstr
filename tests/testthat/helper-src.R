# Helper functions for testing source reference functionality

#' Create a function or expression with source references
#'
#' This helper writes code to a temporary file, sources it, and returns
#' the result with source references attached. Useful for testing srcref
#' functionality.
#'
#' @param code Character vector of R code
#' @param env Environment to source into (default: caller environment)
#' @param file Optional file path (default: creates temp file)
#' @return The result of sourcing the code with keep.source = TRUE
#' @noRd
with_srcref <- function(code, env = parent.frame(), file = NULL) {
  if (is.null(file)) {
    file <- tempfile("test_srcref", fileext = ".R")
    on.exit(unlink(file), add = TRUE)
  }

  writeLines(code, file)
  source(file, local = env, keep.source = TRUE)
}

#' Parse code with source references
#'
#' Creates a parsed expression with source references attached, useful for
#' testing srcref extraction from expressions.
#'
#' @param code Character string of R code
#' @return Parsed expression with srcref attributes
#' @noRd
parse_with_srcref <- function(code) {
  parse(text = code, keep.source = TRUE)
}

#' Create a function with known source references
#'
#' Creates a simple test function with predictable source references.
#'
#' @return A function with source references
#' @noRd
simple_function_with_srcref <- function() {
  code <- c(
    "test_func <- function(x, y) {",
    "  x + y",
    "}"
  )

  env <- new.env(parent = baseenv())
  with_srcref(code, env = env)
  env$test_func
}

#' Create a multi-statement function with source references
#'
#' Creates a function with multiple statements for testing statement-level
#' srcref handling.
#'
#' @return A function with multiple statements and source references
#' @noRd
multi_statement_function_with_srcref <- function() {
  code <- c(
    "multi_func <- function(x) {",
    "  a <- x + 1",
    "  b <- a * 2",
    "  c <- b - 3",
    "  c",
    "}"
  )

  env <- new.env(parent = baseenv())
  with_srcref(code, env = env)
  env$multi_func
}

#' Create expression with multibyte characters
#'
#' Creates source code with multibyte characters (e.g., "é") to test
#' byte vs column handling.
#'
#' @return Parsed expression with multibyte characters
#' @noRd
expression_with_multibyte <- function() {
  code <- c(
    "# Créer une fonction",
    "café <- function() {",
    "  'résumé'",
    "}"
  )

  env <- new.env(parent = baseenv())
  with_srcref(code, env = env)
  env$café
}
