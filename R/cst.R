#' Call stack tree
#'
#' Shows the relationship between calls on the stack
#'
#' @export
#' @examples
#' # If all evaluation is eager, you get a single tree
#' f <- function() g()
#' g <- function() h()
#' h <- function() cst()
#' f()
#'
#' # You get multiple trees with delayed evaluation enters
#' try(f())
#'
#' # Pay attention to the first element of each subtree: each
#' # evaluates the outermost call
#' f <- function(x) g(x)
#' g <- function(x) h(x)
#' h <- function(x) x
#' try(f(cst()))
#'
#' # You can also get unusual trees by evaluating in frames
#' # higher up the call stack
#' f <- function() g()
#' g <- function() h()
#' h <- function() eval(quote(cst()), parent.frame(2))
#' f()
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
