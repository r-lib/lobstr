context("test-address.R")

test_that("address of expression varies", {
  a <- obj_address(1:10)
  b <- obj_address(1:10)
  expect_false(identical(a, b))
})

test_that("address of variable is constant", {
  x <- 1:10
  expect_equal(obj_address(x), obj_address(x))
})

test_that("address flows through function wrappers", {
  x <- 1:10
  f <- function(x) obj_address(x)
  g <- function(y) f(y)
  h <- function(z) g(z)

  address <- obj_address(x)
  expect_equal(f(x), address)
  expect_equal(g(x), address)
  expect_equal(h(x), address)
})


# addresses ---------------------------------------------------------------

test_that("can find addresses of list elements", {
  x <- 1:3
  y <- 1:3
  addr <- c(obj_address(x), obj_address(y))

  l <- list(x, y)
  expect_equal(obj_addresses(l), addr)
})

test_that("can find addresses of environment elements", {
  x <- 1:3
  y <- 1:3
  addr <- c(obj_address(x), obj_address(y))

  e1 <- new.env(hash = TRUE)
  e1$x <- x
  e1$y <- y
  expect_setequal(obj_addresses(e1), addr)

  e2 <- new.env(hash = FALSE)
  e2$x <- x
  e2$y <- y
  expect_setequal(obj_addresses(e2), addr)
})

