context("primt_length")

test_that("NULL, symbol and builtin have no children", {
  expect_equal(prim_length(NULL), 0)
  expect_equal(prim_length(sum), 0)
  expect_equal(prim_length(quote(a)), 0)
})

test_that("primitive vector has children only if has attributes", {
  x <- 1:10
  y <- structure(x, a = 1)

  expect_equal(prim_length(x), 0)
  expect_equal(prim_length(y), 1)
})

test_that("length of list is length of children + attributes", {
  x <- as.list(1:10)
  y <- structure(x, a = 1)

  expect_equal(prim_length(x), 10)
  expect_equal(prim_length(y), 11)
})

test_that("length of call is number of arguments + 1", {
  expect_equal(prim_length(quote(f())), 0 + 1)
  expect_equal(prim_length(quote(f(1, 2, 3))), 3 + 1)
})

test_that("length of env is length of elements", {
  e1 <- new.env(parent = emptyenv(), hash = TRUE)
  e2 <- new.env(parent = emptyenv(), hash = TRUE)
  e1$x <- 1
  e2$x <- 1

  expect_equal(prim_length(e1), 1)
  expect_equal(prim_length(e2), 1)
})

test_that("env with parent has extra length", {
  e1 <- new.env(parent = emptyenv())
  e2 <- new.env()

  expect_equal(prim_length(e1), 0)
  expect_equal(prim_length(e2), 1)
})
