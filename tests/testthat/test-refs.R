context("prim_refs")

test_that("expression has no refs", {
  expect_equal(obj_refs(1:10), 0L)
})

test_that("local variable has one ref", {
  x <- 1:10
  expect_equal(obj_refs(x), 1L)
})

test_that("local variable with ref has two refs", {
  x <- 1:10
  y <- x
  expect_equal(obj_refs(x), 2L)
})

test_that("prim_children doesn't increment refs", {
  x <- list(1:10)
  y <- prim_children(x)

  expect_equal(obj_refs(x), 1L)
})
