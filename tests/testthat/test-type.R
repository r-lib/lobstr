context("test-type.R")

test_that("basic types are correct", {
  expect_equal(prim_type("a"), "character")
  expect_equal(prim_type(1), "double")
  expect_equal(prim_type(1L), "integer")
  expect_equal(prim_type(function() { 1; }), "function")
})

test_that("S3 types are reported", {
  expect_equal(prim_type(data.frame(a = 1)), "list (S3: data.frame)")
})
