context("tree")

test_that("quosures print same as expressions", {
  expect_equal(tree(quo(x)), tree(expr(x)))
})
