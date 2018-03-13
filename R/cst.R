#' Call stack tree
#'
#' Shows the relationship between calls on the stack
#'
#' @export
#' @examples
#' f1 <- function() g1()
#' g1 <- function() h1()
#' h1 <- function() cst()
#'
#' f1()
#' try(f1())
#'
#' f <- function(x) g(x)
#' g <- function(x) h(x)
#' h <- function(x) x
#'
#' f(cst())
#' try(f(cst()))
cst <- function() {
  calls <- sys.calls()
  parents <- sys.parents()

  x <- tree_view(calls, parents)
  print(x)
  invisible(x)
}

tree_view <- function(calls, parents) {
  nodes <- c(0, seq_along(calls))
  children <- lapply(nodes, function(id) seq_along(parents)[parents == id])
  call_text <- vapply(as.list(calls), expr_name, character(1))

  tree <- data.frame(id = as.character(nodes), stringsAsFactors = FALSE)
  tree$children = lapply(children, as.character)
  tree$call = c(cli::symbol$star, call_text)

  cli::tree(tree)
}
