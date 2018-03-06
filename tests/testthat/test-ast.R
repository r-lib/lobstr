context("test-ast.R")

test_that("quosures print same as expressions", {
  expect_equal(ast_tree(quo(x)), ast_tree(expr(x)))
})
