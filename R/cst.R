#' Call stack tree
#'
#' Shows the relationship between calls on the stack. This function
#' combines the results of [sys.calls()] and [sys.parents()] yielding a display
#' that shows how frames on the call stack are related.
#'
#' @export
#' @examples
#' # If all evaluation is eager, you get a single tree
#' f <- function() g()
#' g <- function() h()
#' h <- function() cst()
#' f()
#'
#' # You get multiple trees with delayed evaluation
#' try(f())
#'
#' # Pay attention to the first element of each subtree: each
#' # evaluates the outermost call
#' f <- function(x) g(x)
#' g <- function(x) h(x)
#' h <- function(x) x
#' try(f(cst()))
#'
#' # With a little ingenuity you can use it to see how NSE
#' # functions work in base R
#' with(mtcars, {cst(); invisible()})
#' invisible(subset(mtcars, {cst(); cyl == 0}))
#'
#' # You can also get unusual trees by evaluating in frames
#' # higher up the call stack
#' f <- function() g()
#' g <- function() h()
#' h <- function() eval(quote(cst()), parent.frame(2))
#' f()
cst <- function() {
  x <- rlang::trace_back()
  print(x, simplify = "none")
  invisible()
}
