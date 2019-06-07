context("test-ref.R")

test_that("basic list display", {
  skip_on_os("windows")
  skip_on_cran()

  x <- 1:10
  y <- list(x, x)

  test_addr_reset()
  expect_known_output(
    ref(
      x,
      list(),
      list(x, x, x),
      list(a = x, b = x),
      letters
    ),
    "test-ref-list.txt",
    print = TRUE
  )
})

test_that("basic environment display", {
  skip_on_os("windows")
  skip_on_cran()

  e <- env(a = 1:10)
  e$b <- e$a
  e$c <- e

  test_addr_reset()
  expect_known_output(
    ref(e),
    "test-ref-env.txt",
    print = TRUE
  )
})

test_that("can display ref to global string pool on request", {
  skip_on_os("windows")
  skip_on_cran()

  test_addr_reset()
  expect_known_output(
    ref(c("string", "string", "new string"), character = TRUE),
    "test-ref-character.txt",
    print = TRUE
  )
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
