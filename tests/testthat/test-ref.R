context("test-ref.R")

test_that("basic list display", {
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
  test_addr_reset()
  expect_known_output(
    ref(c("string", "string", "new string"), character = TRUE),
    "test-ref-character.txt",
    print = TRUE
  )
})
