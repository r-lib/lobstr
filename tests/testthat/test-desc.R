context("prim_desc")

test_that("basic type descriptions are correct", {
  expect_equal(prim_desc(c(1,2,3)), "[3]")
})
