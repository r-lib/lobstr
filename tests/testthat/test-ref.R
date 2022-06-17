test_that("basic list display", {
  skip_on_os("windows")

  test_addr_reset()
  expect_snapshot({
    x <- 1:10
    y <- list(x, x)

    ref(
      x,
      list(),
      list(x, x, x),
      list(a = x, b = x),
      letters
    )
  })
})

test_that("basic environment display", {
  skip_on_os("windows")

  test_addr_reset()
  expect_snapshot({
    e <- env(a = 1:10)
    e$b <- e$a
    e$c <- e
    ref(e)
  })
})

test_that("environment shows objects beginning with .", {
  skip_on_os("windows")

  test_addr_reset()
  expect_snapshot({
    e <- env(. = 1:10)
    ref(e)
  })
})


test_that("can display ref to global string pool on request", {
  skip_on_os("windows")

  test_addr_reset()
  expect_snapshot({
    ref(c("string", "string", "new string"), character = TRUE)
  })
})

test_that("custom methods are never called (#30)", {
  # `[[.numeric_number` causes infinite recursion
  expect_error(ref(package_version("1.1.1")), NA)

  e <- env(a = 1:10)
  e$b <- e$a
  e$c <- e

  # `as.list.data.frame`(<environemnt>, ...) fails
  class(e) <- "data.frame"

  expect_error(ref(e), NA)
})
