# Snapshot tests for src() output
#
# These tests capture the current behavior before implementing Phase 1
# (srcfile deduplication) and Phase 2 (deep AST walking).

# Helper to scrub non-deterministic parts from src() output --------------------

#' Scrub src() output for deterministic snapshots
#'
#' Replaces filenames, directories, and timestamps with stable values
scrub_src <- function(x) {
  # Capture the output as text
  output <- capture.output(print(x))

  # Scrub filenames: replace with generic placeholder
  output <- gsub('filename: "[^"]+"', 'filename: "<scrubbed>"', output)

  # Scrub directories: replace with ...
  output <- gsub('directory: "[^"]+"', 'directory: "..."', output)

  # Scrub timestamps: replace with a fixed value
  output <- gsub('timestamp: "[^"]+"', 'timestamp: "<scrubbed>"', output)

  # Print the scrubbed output
  cat(output, sep = "\n")

  invisible(x)
}

# Test: Closures (evaluated functions) ------------------------------------------

test_that("src() shows closure with srcref and wholeSrcref", {
  expect_snapshot({
    f <- simple_function_with_srcref()
    scrub_src(src(f))
  })
})

test_that("src() shows multi-statement function", {
  expect_snapshot({
    f <- multi_statement_function_with_srcref()
    scrub_src(src(f))
  })
})

# Test: Quoted functions --------------------------------------------------------

test_that("src() shows quoted function with nested body", {
  expect_snapshot({
    with_srcref("x <- quote(function() {})")
    scrub_src(src(x))
  })
})

test_that("src() shows quoted function body directly", {
  expect_snapshot({
    with_srcref("x <- quote(function() {})")
    scrub_src(src(x[[3]]))
  })
})

test_that("src() shows quoted function with arguments", {
  expect_snapshot({
    with_srcref("x <- quote(function(a, b) {})")
    scrub_src(src(x))
  })
})

test_that("src() shows srcref with parsed field when positions differ", {
  expect_snapshot({
    # Create a synthetic 8-element srcref where parsed positions differ
    # Format: c(first_line, first_byte, last_line, last_byte,
    #           first_col, last_col, first_parsed, last_parsed)
    # This simulates a case where R's parser reports different positions
    # than the actual source locations (e.g., due to string continuations)
    srcfile <- srcfilecopy(
      "test.R",
      c(
        "x <- function() {",
        "  # A long comment that spans",
        "  # multiple lines",
        "  y <- 1",
        "}"
      )
    )

    synthetic_srcref <- structure(
      c(2L, 3L, 4L, 8L, 3L, 8L, 1L, 5L),
      class = "srcref",
      srcfile = srcfile
    )

    scrub_src(src(synthetic_srcref))
  })
})

# Test: Expression objects ------------------------------------------------------

test_that("src() shows expression with single element", {
  expect_snapshot({
    x <- parse(text = "x + 1", keep.source = TRUE)
    scrub_src(src(x))
  })
})

test_that("src() shows expression with multiple elements", {
  expect_snapshot({
    x <- parse(text = c("x + 1", "y + 2", "z + 3"), keep.source = TRUE)
    scrub_src(src(x))
  })
})

test_that("src() shows expression with nested block and wholeSrcref", {
  expect_snapshot({
    x <- parse(text = "{\n  1\n}", keep.source = TRUE)
    scrub_src(src(x))
  })
})

test_that("src() shows nested block element directly", {
  expect_snapshot({
    x <- parse(text = "{\n  1\n}", keep.source = TRUE)
    scrub_src(src(x[[1]]))
  })
})

# Test: Blocks with wholeSrcref -------------------------------------------------

test_that("src() shows block with srcref list and wholeSrcref", {
  expect_snapshot({
    x <- parse(text = "{\n  a <- 1\n  b <- 2\n}", keep.source = TRUE)
    scrub_src(src(x[[1]]))
  })
})

# Test: Single srcref objects ---------------------------------------------------

test_that("src() shows single srcref", {
  expect_snapshot({
    x <- parse(text = "x + 1", keep.source = TRUE)
    sr <- attr(x, "srcref")[[1]]
    scrub_src(src(sr))
  })
})

# Test: List of srcrefs ---------------------------------------------------------

test_that("src() shows list of srcrefs with count", {
  expect_snapshot({
    x <- parse(text = c("x + 1", "y + 2"), keep.source = TRUE)
    sr_list <- attr(x, "srcref")
    scrub_src(src(sr_list))
  })
})

# Test: Srcref lists shown as <list> with [[1]], [[2]] notation ----------------

test_that("src() reveals srcref list structure with index notation", {
  expect_snapshot({
    with_srcref("x <- quote(function() { 1 })")
    scrub_src(src(x[[3]]))
  })
})

test_that("src() handles srcrefs nested in language calls", {
  expect_snapshot({
    x <- parse(text = "foo({ if (1) bar({ 2 }) })", keep.source = TRUE)
    scrub_src(src(x, max_depth = 10))
  })
})

test_that("src() handles srcrefs nested in function bodies", {
  expect_snapshot({
    with_srcref("f <- function() foo({ if (1) bar({ 2 }) })")
    scrub_src(src(f, max_depth = 10))
  })
})

# Test: Type labels -------------------------------------------------------------

test_that("src() uses correct type labels", {
  # Closure
  f <- simple_function_with_srcref()
  result_closure <- src(f)
  expect_equal(attr(result_closure, "srcref_type"), "closure")

  # Quoted function
  with_srcref("x <- quote(function() {})")
  result_quoted <- src(x)
  expect_equal(attr(result_quoted, "srcref_type"), "quoted_function")

  # Expression
  expr <- parse(text = "1 + 1", keep.source = TRUE)
  result_expr <- src(expr)
  expect_equal(attr(result_expr, "srcref_type"), "expression")

  # Block
  block <- parse(text = "{1}", keep.source = TRUE)[[1]]
  result_block <- src(block)
  expect_equal(attr(result_block, "srcref_type"), "block")
})

# Test: Srcfile duplication (current behavior - will change in Phase 1) --------

test_that("src() currently shows duplicate srcfile objects", {
  expect_snapshot({
    # Current behavior: srcfile appears twice (in srcref and wholeSrcref)
    # After Phase 1: should use reference notation like @abc123
    f <- simple_function_with_srcref()
    scrub_src(src(f))
  })
})

test_that("src() shows many duplicate srcfiles in nested expression", {
  expect_snapshot({
    # Current behavior: same srcfile appears many times
    # After Phase 1: these should be deduplicated
    x <- parse(text = "{\n  1\n  2\n}", keep.source = TRUE)
    scrub_src(src(x))
  })
})

# Test: Edge cases --------------------------------------------------------------

test_that("src() handles empty block", {
  expect_snapshot({
    x <- parse(text = "{}", keep.source = TRUE)
    scrub_src(src(x[[1]]))
  })
})

test_that("src() handles function without arguments", {
  expect_snapshot({
    with_srcref("f <- function() { NULL }")
    scrub_src(src(f))
  })
})

test_that("src() handles if statement with blocks", {
  expect_snapshot({
    x <- parse(text = "if (TRUE) { 1 } else { 2 }", keep.source = TRUE)
    scrub_src(src(x))
  })
})

# Test: Parameters --------------------------------------------------------------

test_that("src() respects max_vec_len parameter", {
  expect_snapshot({
    x <- parse(text = paste(rep("1", 10), collapse = "\n"), keep.source = TRUE)
    scrub_src(src(x, max_vec_len = 2))
  })
})

test_that("src() respects show_source_lines parameter", {
  expect_snapshot({
    f <- simple_function_with_srcref()
    scrub_src(src(f))
  })
})

# Test: Complex nested structures -----------------------------------------------

test_that("src() shows expression with multiple nested blocks", {
  expect_snapshot({
    x <- parse(
      text = "{\n  {\n    1\n  }\n  {\n    2\n  }\n}",
      keep.source = TRUE
    )
    scrub_src(src(x))
  })
})

test_that("src() shows function with nested block in body", {
  expect_snapshot({
    with_srcref("f <- function(x) {\n  if (x) {\n    1\n  }\n}")
    scrub_src(src(f))
  })
})
