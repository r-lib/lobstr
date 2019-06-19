context("test-inspect")

test_that("retrieves truelength", {
  skip_if_not(getRversion() >= "3.4")

  # true length is only updated after assignment
  x <- runif(100)
  x[101] <- 1
  obj <- sxp(x)

  # weak test because R doesn't make any guarantees about what the object
  # will be
  expect_true(attr(obj, "truelength") > length(obj))
})

test_that("computes spanning tree", {
  x <- 1:10
  y <- list(x, x, x)
  obj <- sxp(y)

  expect_false(attr(obj[[1]], "has_seen"))
  expect_true(attr(obj[[2]], "has_seen"))
})

test_that("captures names of special environments", {
  x <- list(
    emptyenv(),
    baseenv(),
    globalenv()
  )
  obj <- sxp(x)
  expect_equal(attr(obj[[1]], "value"), "empty")
  expect_equal(attr(obj[[2]], "value"), "base")
  expect_equal(attr(obj[[3]], "value"), "global")
})

test_that("captures names of lists", {
  x <- list(a = 1, b = 2, c = 3)
  obj <- sxp(x)
  expect_named(obj, c(names(x), "_attrib"))
})

test_that("can expand lists", {
  x <- c("xxx", "xxx", "y")
  obj <- sxp(x, expand = "character")

  expect_length(obj, 3)
  expect_equal(attr(obj[[1]], "ref"), attr(obj[[2]], "ref"))
})

test_that("can inspect active bindings", {
  e <- new.env(hash = FALSE)
  env_bind_active(e, f = function() stop("!"))

  x <- sxp(e)
  expect_named(x, c("f", "_enclos"))
})

# Regression tests --------------------------------------------------------

test_that("can inspect all atomic vectors", {
  x <- list(
    TRUE,
    1L,
    1,
    "3",
    1i,
    raw(1)
  )
  expect_known_output(
    print(sxp(x)),
    test_path("test-sxp-atomic.txt"),
  )
})

test_that("can inspect functions", {
  f <- function(x, y = 1, ...) x + 1
  attr(f, "srcref") <- NULL
  environment(f) <- globalenv()

  expect_known_output(
    print(sxp(f)),
    test_path("test-sxp-function.txt"),
  )
})

test_that("can inspect environments", {
  e1 <- new.env(parent = emptyenv(), size = 5L)
  e1$x <- 10
  e1$y <- e1

  e2 <- new.env(parent = e1, size = 5L)

  expect_known_output(
    {
      print(sxp(e2))
      cat("\n\n")
      print(sxp(e2, expand = "environment", max_depth = 5L))
    },
    test_path("test-sxp-environment.txt"),
  )
})

test_that("can expand altrep", {
  skip_if_not(getRversion() >= "3.5")
  skip_if_not(.Machine$sizeof.pointer == 8) # _class RAWSXP has different size

  x <- 1:10
  expect_known_output(
    {
      print(sxp(x, expand = "altrep", max_depth = 4L))
    },
    test_path("test-sxp-altrep.txt")
  )
})
