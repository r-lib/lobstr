context("test-address.R")

test_that("address of expression varies", {
  a <- obj_addr(1:10)
  b <- obj_addr(1:10)
  expect_false(identical(a, b))
})

test_that("address of variable is constant", {
  x <- 1:10
  expect_equal(obj_addr(x), obj_addr(x))
})

test_that("address flows through function wrappers", {
  x <- 1:10
  f <- function(x) obj_addr(x)
  g <- function(y) f(y)
  h <- function(z) g(z)

  address <- obj_addr(x)
  expect_equal(f(x), address)
  expect_equal(g(x), address)
  expect_equal(h(x), address)
})


# addresses ---------------------------------------------------------------

test_that("can find addresses of list elements", {
  x <- 1:3
  y <- 1:3
  addr <- c(obj_addr(x), obj_addr(y))

  l <- list(x, y)
  expect_equal(obj_addrs(l), addr)
})

test_that("can find addresses of environment elements", {
  x <- 1:3
  y <- 1:3
  addr <- c(obj_addr(x), obj_addr(y))

  e1 <- new.env(hash = TRUE)
  e1$x <- x
  e1$y <- y
  expect_setequal(obj_addrs(e1), addr)

  e2 <- new.env(hash = FALSE)
  e2$x <- x
  e2$y <- y
  expect_setequal(obj_addrs(e2), addr)
})

test_that("address of character vectors points to global string pool", {
  addr <- obj_addrs(c("a", "a", "a"))
  expect_equal(addr[[1]], addr[[2]])
})

test_that("addresses of other elements throws errors", {
  expect_error(obj_addrs(1:10), "must be a list")
})
