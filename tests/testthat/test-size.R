context("test-size.R")

expect_same <- function(x, ...) {
  lab <- as.character(expr_text(enexpr(x)))
  act <- as.vector(obj_size(x))
  exp <- as.vector(object.size(x))

  msg <- sprintf("`obj_size(%s)` is %s, not %s (\u0394%+i)", lab, act, exp, act - exp)
  expect(identical(act, exp), msg)
  invisible(act)
}

# S3 methods --------------------------------------------------------------

test_that("combined bytes are aligned", {
  x <- new_bytes(c(400, 400000))
  expect_known_output(print(x), "size-aligned.txt")
})

# Compatibility with base ---------------------------------------------------

test_that("size correct for length one vectors", {
  expect_same(1)
  expect_same(1L)
  expect_same("abc")
  expect_same(paste(rep("banana", 100), collapse = ""))
  expect_same(charToRaw("a"))
  expect_same(5 + 1i)
})

test_that("size scales correctly with length (accounting for vector pool)", {
  expect_same(numeric())
  expect_same(1)
  expect_same(2)
  expect_same(c(1:10))
  expect_same(c(1:1000))
})

test_that("size of list computed recursively", {
  expect_same(list())
  expect_same(as.list(1))
  expect_same(as.list(1:2))
  expect_same(as.list(1:3))

  expect_same(list(list(list(list(list())))))
})

test_that("size of symbols same as base", {
  expect_same(quote(x))
  expect_same(quote(asfsadfasdfasdfds))
})

test_that("size of pairlists same as base", {
  expect_same(pairlist())
  expect_same(pairlist(1))
  expect_same(pairlist(1, 2))
  expect_same(pairlist(1, 2, 3))
  expect_same(pairlist(1, 2, 3, 4))
})

test_that("don't crash with large pairlists", {
  n <- 1e5
  x <- pairlist(1)
  xn <- as.pairlist(rep(1, n))
  expect_equal(obj_size(xn), n * obj_size(x))
})

test_that("size of S4 objects same as base", {
  Z <- methods::setClass("Z", slots = c(x = "integer"))
  z <- Z(x = 1L)

  expect_same(z)
})

test_that("size of attributes included in object size", {
  expect_same(c(x = 1))
  expect_same(list(x = 1))
  expect_same(c(x = "y"))
})

test_that("duplicated CHARSXPS only counted once", {
  expect_same("x")
  expect_same(c("x", "y", "x"))
  expect_same(c("banana", "banana", "banana"))
})

# Improved behaviour for shared components ------------------------------------
test_that("shared components only counted once", {
  x <- 1:1e3
  z <- list(x, x, x)

  expect_equal(obj_size(z), obj_size(x) + obj_size(vector("list", 3)))
})

test_that("size of closures same as base", {
  f <- function() NULL
  attributes(f) <- NULL # zap srcrefs
  environment(f) <- emptyenv()
  expect_same(f)
})

# Improved behaviour for ALTREP objects -----------------------------------

test_that("altrep size measured correctly", {
  skip_if_not(getRversion() > "3.5.0")

  # Currently reported size is 640 B
  # If regular vector would be 4,000,040 B
  # This test is conservative so shouldn't fail in case representation
  # changes in the future
  expect_true(obj_size(1:1e6) < 10000)
})

test_that("can compute size of deferred string vectors", {
  x <- 1:10
  names(x) <- 10:1
  y <- names(x)
  obj_size(y)

  # Just assert that it doesn't crash
  succeed("Didn't crash")
})

# Environment sizes -----------------------------------------------------------
test_that("terminal environments have size zero", {
  expect_equal(obj_size(globalenv()), new_bytes(0))
  expect_equal(obj_size(baseenv()), new_bytes(0))
  expect_equal(obj_size(emptyenv()), new_bytes(0))

  expect_equal(obj_size(asNamespace("stats")), new_bytes(0))
})

test_that("environment size computed recursively", {
  e <- new.env(parent = emptyenv())
  e_size <- obj_size(e)

  f <- new.env(parent = e)
  obj_size(f)
  expect_equal(obj_size(f), 2 * obj_size(e))
})

test_that("size of function includes environment", {
  f <- function() {
    y <- 1:1e3
    a ~ b
  }
  g <- function() {
    y <- 1:1e3
    function() 10
  }

  expect_true(obj_size(f()) > obj_size(1:1e3))
  expect_true(obj_size(g()) > obj_size(1:1e3))
})

test_that("size doesn't include parents of current environment", {
  x <- c(1:1e4)
  embedded <- (function() {
    g <- function() {
      x <- c(1:1e3)
      a ~ b
    }
    obj_size(g())
  })()

  expect_true(embedded < obj_size(x))
})

test_that("support dots in closure environments", {
  fn <- (function(...) function() NULL)(foo)
  expect_error(obj_size(fn), NA)
})

