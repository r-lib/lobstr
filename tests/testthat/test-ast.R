test_that("quosures print same as expressions", {
  expect_equal(ast_tree(quo(x)), ast_tree(expr(x)))
})

test_that("can print complex expression", {
  skip_on_os("windows")

  x <- expr(function(x) if (x > 1) f(y$x, "x", g()))
  expect_snapshot({
    ast(!!x)
  })
})

test_that("can print complex expression without unicode", {
  old <- options(lobstr.fancy.tree = FALSE)
  on.exit(options(old))

  x <- expr(function(x) if (x > 1) f(y$x, "x", g()))
  expect_snapshot({
    ast(!!x)
  })
})

test_that("can print scalar expressions nicely", {
  old <- options(lobstr.fancy.tree = FALSE)
  on.exit(options(old))

  x <- expr(list(
    logical = c(FALSE, TRUE, NA),
    integer = 1L,
    double = 1,
    character = "a",
    complex = 1i
  ))
  expect_snapshot({
    ast(!!x)
  })
})

