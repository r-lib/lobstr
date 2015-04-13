context("prim_address")

test_that("address of expression varies", {
  a <- prim_address(1:10)
  b <- prim_address(1:10)
  expect_false(identical(a, b))
})

test_that("address of variable is constant", {
  x <- 1:10
  expect_equal(prim_address(x), prim_address(x))
})

test_that("address flows through function wrappers", {
  x <- 1:10
  f <- function(x) prim_address(x)
  g <- function(y) f(y)
  h <- function(z) g(z)

  address <- prim_address(x)
  expect_equal(f(x), address)
  expect_equal(g(x), address)
  expect_equal(h(x), address)
})
