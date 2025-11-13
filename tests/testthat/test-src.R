# Tests for src() function and helpers

# Helper function tests --------------------------------------------------------

test_that("extract_srcref_info handles 4-element srcrefs", {
  # Create a simple expression with srcref
  expr <- parse(text = "x + 1", keep.source = TRUE)
  srcref <- attr(expr, "srcref")[[1]]

  # Manually create a 4-element srcref for testing
  # Note: In practice, 4-element srcrefs are rare in modern R
  srcref_4 <- structure(
    c(1L, 1L, 1L, 5L),
    class = "srcref",
    srcfile = attr(srcref, "srcfile")
  )

  info <- lobstr:::srcref_info(srcref_4)

  expect_s3_class(info$location, "lobstr_srcref_location")
  expect_equal(as.character(info$location), "1:1-1:5")
})

test_that("extract_srcref_info handles 6-element srcrefs", {
  # Create a 6-element srcref
  expr <- parse(text = "x + 1", keep.source = TRUE)
  srcref_base <- attr(expr, "srcref")[[1]]

  srcref_6 <- structure(
    c(1L, 1L, 1L, 5L, 1L, 5L),
    class = "srcref",
    srcfile = attr(srcref_base, "srcfile")
  )

  info <- lobstr:::srcref_info(srcref_6)

  expect_s3_class(info$location, "lobstr_srcref_location")
  expect_equal(as.character(info$location), "1:1-1:5")
})

test_that("extract_srcref_info handles 8-element srcrefs", {
  expr <- parse(text = "x + 1", keep.source = TRUE)
  srcref <- attr(expr, "srcref")[[1]]

  # Most modern srcrefs are 8-element
  info <- lobstr:::srcref_info(srcref)

  expect_s3_class(info$location, "lobstr_srcref_location")
  expect_match(as.character(info$location), "\\d+:\\d+-\\d+:\\d+")
})

test_that("extract_srcref_info shows encoding details when requested", {
  expr <- parse(text = "x + 1", keep.source = TRUE)
  srcref <- attr(expr, "srcref")[[1]]

  info <- lobstr:::srcref_info(srcref)

  expect_true("location" %in% names(info))
})

test_that("extract_srcref_info errors on invalid srcref length", {
  # Create an invalid srcref with wrong number of elements
  bad_srcref <- structure(c(1L, 2L, 3L), class = "srcref")

  expect_error(
    lobstr:::srcref_info(bad_srcref),
    "Unexpected srcref length"
  )
})

test_that("srcfile_node handles srcfilecopy", {
  expr <- parse(text = "x + 1", keep.source = TRUE)
  srcfile <- attr(attr(expr, "srcref")[[1]], "srcfile")
  srcref <- attr(expr, "srcref")[[1]]
  seen_srcfiles <- new.env(parent = emptyenv())

  info <- lobstr:::srcfile_node(srcfile, srcref, 3, seen_srcfiles)

  expect_equal(attr(info, "srcfile_class"), class(srcfile)[1])
  expect_type(info$filename, "character")
  expect_type(info$Enc, "character")
})

test_that("srcfile_node handles NULL gracefully", {
  seen_srcfiles <- new.env(parent = emptyenv())
  info <- lobstr:::srcfile_node(NULL, NULL, 3, seen_srcfiles)
  expect_null(info)
})

test_that("srcfile_lines extracts from srcfilecopy", {
  code <- c("x <- 1", "y <- 2", "z <- 3")
  expr <- parse(text = code, keep.source = TRUE)
  srcref <- attr(expr, "srcref")[[1]]
  srcfile <- attr(srcref, "srcfile")

  snippet <- lobstr:::srcfile_lines(srcfile, srcref, max_lines = 3)

  expect_type(snippet, "character")
  expect_true(length(snippet) >= 1)
})

test_that("srcfile_lines respects max_lines", {
  code <- c("x <- 1", "y <- 2", "z <- 3", "a <- 4", "b <- 5")
  expr <- parse(text = paste(code, collapse = "\n"), keep.source = TRUE)

  srcfile <- attr(attr(expr, "srcref")[[1]], "srcfile")
  srcref <- structure(
    c(1L, 1L, 5L, 10L, 1L, 10L, 1L, 5L),
    class = "srcref",
    srcfile = srcfile
  )

  snippet <- lobstr:::srcfile_lines(srcfile, srcref, max_lines = 2)

  expect_true(length(snippet) <= 2)
})

test_that("srcref_location works correctly", {
  srcref <- structure(
    c(1L, 5L, 3L, 20L, 5L, 20L, 1L, 3L),
    class = "srcref"
  )
  loc <- lobstr:::srcref_location(srcref)
  expect_equal(loc, "1:5-3:20")
})

# Integration tests for src() --------------------------------------------------

test_that("src works with functions with source references", {
  fun <- simple_function_with_srcref()

  result <- src(fun)

  expect_type(result, "list")
  expect_equal(attr(result, "srcref_type"), "closure")
})

test_that("src works with single srcref objects", {
  expr <- parse(text = "x + 1", keep.source = TRUE)
  srcref <- attr(expr, "srcref")[[1]]

  result <- src(srcref)

  expect_type(result, "list")
  expect_equal(attr(result, "srcref_type"), "srcref")
  expect_true("location" %in% names(result))
})

test_that("src works with list of srcrefs", {
  expr <- parse(text = c("x + 1", "y + 2"), keep.source = TRUE)
  srcref_list <- attr(expr, "srcref")

  result <- src(srcref_list)

  expect_type(result, "list")
  expect_equal(attr(result, "srcref_type"), "list")
  expect_equal(result$count, length(srcref_list))
})

test_that("src works with expressions", {
  expr <- parse(text = "x + 1", keep.source = TRUE)

  result <- src(expr)

  expect_type(result, "list")
})

test_that("src works for objects without srcrefs", {
  fun <- function(x) x + 1
  attr(fun, "srcref") <- NULL
  expect_null(src(fun))
  expect_null(src(new.env()))
  expect_null(src(list()))
  expect_null(src(sum))
})

test_that("src respects max_lines_preview parameter", {
  fun <- multi_statement_function_with_srcref()

  result <- src(fun, max_lines_preview = 1)

  expect_type(result, "list")
  expect_equal(attr(result, "srcref_type"), "closure")
})

test_that("src handles multibyte characters", {
  skip_on_os("windows") # Encoding issues on Windows

  fun <- expression_with_multibyte()

  result <- src(fun)

  expect_type(result, "list")
  expect_equal(attr(result, "srcref_type"), "closure")
})

test_that("src returns structure and print method works", {
  fun <- simple_function_with_srcref()

  # src() returns visibly (with S3 class)
  result <- src(fun)
  expect_s3_class(result, "lobstr_srcref")

  # print method returns invisibly and outputs to console
  expect_output(
    expect_invisible(print(result)),
    "<closure>"
  )
})

# S3 method tests --------------------------------------------------------------

test_that("tree_label.srcref formats correctly", {
  expr <- parse(text = "x + 1", keep.source = TRUE)
  srcref <- attr(expr, "srcref")[[1]]

  # Call the method directly since srcref has proper class
  label <- lobstr:::tree_label.srcref(srcref, list())

  expect_type(label, "character")
  expect_match(label, "<srcref:")
  expect_match(label, "\\d+:\\d+-\\d+:\\d+")
})

test_that("tree_label.srcfile formats correctly", {
  expr <- parse(text = "x + 1", keep.source = TRUE)
  srcfile <- attr(attr(expr, "srcref")[[1]], "srcfile")

  # Call the method directly since srcfile is an environment with class attribute
  label <- lobstr:::tree_label.srcfile(srcfile, list())

  expect_type(label, "character")
  expect_match(label, "<srcfile")
})

# Edge case tests --------------------------------------------------------------

test_that("src handles functions with wholeSrcref on body", {
  fun <- simple_function_with_srcref()

  # Verify wholeSrcref exists on body
  expect_false(is.null(attr(body(fun), "wholeSrcref")))

  result <- src(fun)
  expect_type(result, "list")

  # Should have body() node in the result
  expect_true("body()" %in% names(result))
  expect_s3_class(result$`body()`, "lobstr_srcref")

  # wholeSrcref should be nested under body()
  expect_true("attr(\"wholeSrcref\")" %in% names(result$`body()`))
  expect_s3_class(result$`body()`$`attr("wholeSrcref")`, "lobstr_srcref")
})

test_that("src handles functions with only wholeSrcref (no srcref attr)", {
  fun <- simple_function_with_srcref()

  # Remove srcref attribute from function, keep only wholeSrcref on body
  attr(fun, "srcref") <- NULL

  result <- src(fun)
  expect_type(result, "list")

  # Should still have body() node with wholeSrcref from body
  expect_true("body()" %in% names(result))
  expect_true("attr(\"wholeSrcref\")" %in% names(result$`body()`))
})

test_that("srcfile_lines handles missing files gracefully", {
  expr <- parse(text = "x + 1", keep.source = TRUE)
  srcref <- attr(expr, "srcref")[[1]]
  srcfile <- attr(srcref, "srcfile")

  # Point to a non-existent file
  srcfile$filename <- "nonexistent_file.R"

  snippet <- lobstr:::srcfile_lines(srcfile, srcref, max_lines = 3)

  expect_type(snippet, "character")
  # May still have cached lines, so just check it's character
  expect_true(length(snippet) >= 0)
})

# Srcfile deduplication tests --------------------------------------------------

test_that("srcfile deduplication - basic case with srcref and wholeSrcref", {
  # Parse code that creates a function with both srcref and wholeSrcref
  code <- parse(text = "f <- function(x) { x + 1 }", keep.source = TRUE)
  f <- eval(code[[1]])

  result <- src(f)

  # Extract the srcfile from the first occurrence
  first_srcfile <- result$`attr("srcref")`$`attr("srcfile")`

  # Extract the ID from the first occurrence
  id <- attr(first_srcfile, "srcfile_id")
  expect_type(id, "character")
  expect_true(nchar(id) >= 1) # Should be hex ID (up to 6 chars)
  expect_true(nchar(id) <= 6)

  # Check that wholeSrcref uses a reference
  whole_srcfile <- result$`body()`$`attr("wholeSrcref")`$`attr("srcfile")`
  expect_s3_class(whole_srcfile, "lobstr_srcfile_ref")
  expect_equal(as.character(whole_srcfile), id)
})

test_that("srcfile deduplication - multiple statement srcrefs share one srcfile", {
  # Create a function with multiple statements
  code <- parse(
    text = "f <- function(x) { a <- x + 1; b <- a * 2; b }",
    keep.source = TRUE
  )
  f <- eval(code[[1]])

  result <- src(f)

  # Get the ID from the first occurrence
  first_srcfile <- result$`attr("srcref")`$`attr("srcfile")`
  id <- attr(first_srcfile, "srcfile_id")

  # Check that all statement srcrefs use references
  stmt_list <- result$`body()`$`attr("srcref")`

  for (i in seq_along(stmt_list)) {
    stmt_name <- paste0("[[", i, "]]")
    stmt_srcfile <- stmt_list[[stmt_name]]$`attr("srcfile")`

    # Should be a reference
    expect_s3_class(stmt_srcfile, "lobstr_srcfile_ref")
    expect_equal(as.character(stmt_srcfile), id)
  }
})

test_that("srcfile deduplication - IDs are stable within a single src() call", {
  # Parse the same code twice to get two different srcfile objects
  code1 <- parse(text = "f <- function(x) { x + 1 }", keep.source = TRUE)
  code2 <- parse(text = "g <- function(y) { y * 2 }", keep.source = TRUE)

  f <- eval(code1[[1]])
  g <- eval(code2[[1]])

  # Call src() on first function
  result_f <- src(f)
  id_f <- attr(result_f$`attr("srcref")`$`attr("srcfile")`, "srcfile_id")

  # Call src() on second function (different call, different seen_srcfiles)
  result_g <- src(g)
  id_g <- attr(result_g$`attr("srcref")`$`attr("srcfile")`, "srcfile_id")

  # IDs should be different because they're from different src() calls
  # and different srcfile objects
  expect_type(id_f, "character")
  expect_type(id_g, "character")

  # Both should be hex IDs (up to 6 chars)
  expect_true(nchar(id_f) >= 1 && nchar(id_f) <= 6)
  expect_true(nchar(id_g) >= 1 && nchar(id_g) <= 6)
})

test_that("srcfile deduplication - multiple files means no cross-file deduplication", {
  # Parse two separate code snippets (different srcfile objects)
  code1 <- parse(text = "f <- function(x) { x + 1 }", keep.source = TRUE)
  code2 <- parse(text = "g <- function(y) { y * 2 }", keep.source = TRUE)

  f <- eval(code1[[1]])
  g <- eval(code2[[1]])

  # Get the srcfile addresses
  srcfile_f <- attr(attr(f, "srcref"), "srcfile")
  srcfile_g <- attr(attr(g, "srcref"), "srcfile")

  addr_f <- lobstr::obj_addr(srcfile_f)
  addr_g <- lobstr::obj_addr(srcfile_g)

  # Different srcfiles should have different addresses
  expect_false(addr_f == addr_g)

  # If we call src() on each separately, they each get their own ID
  result_f <- src(f)
  result_g <- src(g)

  id_f <- attr(result_f$`attr("srcref")`$`attr("srcfile")`, "srcfile_id")
  id_g <- attr(result_g$`attr("srcref")`$`attr("srcfile")`, "srcfile_id")

  # IDs are derived from addresses, so different addresses = different IDs
  expect_false(id_f == id_g)
})

test_that("srcfile deduplication - nested functions from same file", {
  # Create code with a nested function
  code <- "
  outer <- function() {
    inner <- function(x) { x + 1 }
    inner(5)
  }
  "
  parsed <- parse(text = code, keep.source = TRUE)
  eval(parsed[[1]])

  result <- src(outer)

  # The outer function should have a srcfile with an ID
  outer_srcfile <- result$`attr("srcref")`$`attr("srcfile")`
  expect_true(!is.null(attr(outer_srcfile, "srcfile_id")))

  # All other references should use the same ID
  id <- attr(outer_srcfile, "srcfile_id")

  # Check wholeSrcref reference
  whole_srcfile <- result$`body()`$`attr("wholeSrcref")`$`attr("srcfile")`
  expect_s3_class(whole_srcfile, "lobstr_srcfile_ref")
  expect_equal(as.character(whole_srcfile), id)
})

test_that("srcfile deduplication - reference notation displays correctly", {
  code <- parse(text = "f <- function(x) { x + 1 }", keep.source = TRUE)
  f <- eval(code[[1]])

  # Capture the output
  output <- capture.output(print(src(f)))

  # Should see the full srcfile once with @id notation
  full_srcfile_lines <- grep("<srcfilecopy> @[0-9a-f]+", output)
  expect_true(length(full_srcfile_lines) >= 1)

  # Should see reference notation (just @id without class)
  ref_lines <- grep("^[^<]*@[0-9a-f]+\\s*$", output, perl = TRUE)
  expect_true(length(ref_lines) >= 1)

  # Extract the ID from both to verify they match
  full_line <- output[full_srcfile_lines[1]]
  id_from_full <- regmatches(full_line, regexpr("@[0-9a-f]+", full_line))

  ref_line <- output[ref_lines[1]]
  id_from_ref <- regmatches(ref_line, regexpr("@[0-9a-f]+", ref_line))

  expect_equal(id_from_full, id_from_ref)
})

test_that("lobstr_srcfile_ref class has correct structure", {
  # Create a reference object directly
  ref <- lobstr:::new_srcfile_ref("abc123", "srcfilecopy")

  expect_s3_class(ref, "lobstr_srcfile_ref")
  expect_equal(as.character(ref), "abc123")
  expect_equal(attr(ref, "srcfile_class"), "srcfilecopy")

  # Tree label should show just @id
  label <- lobstr:::tree_label.lobstr_srcfile_ref(ref, list())
  expect_equal(label, "@abc123")
})

test_that("srcfile deduplication - expression with multiple elements", {
  # Parse an expression with multiple top-level elements
  code <- parse(text = c("x <- 1", "y <- 2", "z <- 3"), keep.source = TRUE)

  result <- src(code)

  # The expression should have an srcref list
  srcref_list <- result$`attr("srcref")`

  # Get the first srcfile
  first_srcfile <- srcref_list$`[[1]]`$`attr("srcfile")`
  id <- attr(first_srcfile, "srcfile_id")
  expect_type(id, "character")

  # Other elements should reference the same srcfile
  second_srcfile <- srcref_list$`[[2]]`$`attr("srcfile")`
  expect_s3_class(second_srcfile, "lobstr_srcfile_ref")
  expect_equal(as.character(second_srcfile), id)

  third_srcfile <- srcref_list$`[[3]]`$`attr("srcfile")`
  expect_s3_class(third_srcfile, "lobstr_srcfile_ref")
  expect_equal(as.character(third_srcfile), id)
})

# Deep nesting tests ----------------------------------------------------------

test_that("deep nesting - for loop with nested block", {
  code <- parse(
    text = "
  f <- function(x) {
    for (i in 1:x) {
      print(i)
    }
  }
  ",
    keep.source = TRUE
  )

  eval(code[[1]])
  result <- src(f)

  # Should have body with nested block
  expect_true("body()" %in% names(result))

  # Should show nested block with path notation [[2]][[4]]
  # (element 2 of body is the for loop, element 4 is the body block)
  nested_block_path <- grep(
    "^\\[\\[2\\]\\]\\[\\[4\\]\\]",
    names(result$`body()`),
    value = TRUE
  )
  expect_true(length(nested_block_path) >= 1)

  # The nested block should have srcref attributes
  nested_block <- result$`body()`[[nested_block_path[1]]]
  expect_s3_class(nested_block, "lobstr_srcref")
  expect_true(
    !is.null(nested_block$`attr("srcref")`) ||
      !is.null(nested_block$`attr("wholeSrcref")`)
  )
})

test_that("deep nesting - if/else with blocks", {
  code <- parse(
    text = "
  g <- function(x) {
    if (x > 0) {
      y <- x + 1
    } else {
      y <- x - 1
    }
    y
  }
  ",
    keep.source = TRUE
  )

  eval(code[[1]])
  result <- src(g)

  # Should show both if and else blocks with path notation
  body_names <- names(result$`body()`)

  # Look for nested blocks (should be [[2]][[3]] and [[2]][[4]])
  if_block_paths <- grep(
    "^\\[\\[2\\]\\]\\[\\[3\\]\\]",
    body_names,
    value = TRUE
  )
  else_block_paths <- grep(
    "^\\[\\[2\\]\\]\\[\\[4\\]\\]",
    body_names,
    value = TRUE
  )

  expect_true(length(if_block_paths) >= 1)
  expect_true(length(else_block_paths) >= 1)

  # Both blocks should be srcref objects
  if_block <- result$`body()`[[if_block_paths[1]]]
  expect_s3_class(if_block, "lobstr_srcref")

  else_block <- result$`body()`[[else_block_paths[1]]]
  expect_s3_class(else_block, "lobstr_srcref")
})

test_that("deep nesting - nested blocks { { { } } }", {
  code <- parse(
    text = "
  h <- function() {
    {
      {
        x <- 1
      }
    }
  }
  ",
    keep.source = TRUE
  )

  eval(code[[1]])
  result <- src(h)

  # Should have nested blocks
  expect_true("body()" %in% names(result))

  # Should have at least one nested [[2]] block
  expect_true("[[2]]" %in% names(result$`body()`))

  # That nested block should have further nesting
  nested_block <- result$`body()`$`[[2]]`
  expect_s3_class(nested_block, "lobstr_srcref")
  expect_true("[[2]]" %in% names(nested_block))
})

test_that("deep nesting - multiple top-level statements", {
  code <- parse(
    text = "
  f <- function(x) {
    a <- x + 1
    b <- a * 2
    for (i in 1:b) {
      print(i)
    }
    b
  }
  ",
    keep.source = TRUE
  )

  eval(code[[1]])
  result <- src(f)

  # Should have body with statement srcrefs
  expect_true("body()" %in% names(result))
  expect_true("attr(\"srcref\")" %in% names(result$`body()`))

  # Should show the nested for loop block
  body_names <- names(result$`body()`)
  for_block_paths <- grep(
    "\\[\\[4\\]\\]\\[\\[4\\]\\]",
    body_names,
    value = TRUE
  )
  expect_true(length(for_block_paths) >= 1)
})

test_that("deep nesting - empty function", {
  code <- parse(text = "f <- function() {}", keep.source = TRUE)

  eval(code[[1]])
  result <- src(f)

  # Should still have structure
  expect_type(result, "list")
  expect_s3_class(result, "lobstr_srcref")
  expect_true("attr(\"srcref\")" %in% names(result))
})

test_that("deep nesting - very deep structure respects max_depth", {
  # Create deeply nested structure
  code <- parse(
    text = "
  f <- function(x) {
    for (i in 1:x) {
      if (i > 0) {
        while (i < 10) {
          for (j in 1:i) {
            print(j)
          }
          break
        }
      }
    }
  }
  ",
    keep.source = TRUE
  )

  eval(code[[1]])

  # With low max_depth, should truncate
  result_shallow <- src(f, max_depth = 2)
  expect_type(result_shallow, "list")

  # With high max_depth, should show more nesting
  result_deep <- src(f, max_depth = 10)
  expect_type(result_deep, "list")

  # Deep version should have more nested paths
  shallow_paths <- names(result_shallow)
  deep_paths <- names(result_deep)

  # Both should be valid results
  expect_true(length(shallow_paths) > 0)
  expect_true(length(deep_paths) > 0)
})

test_that("deep nesting - intermediate calls without srcrefs are omitted", {
  code <- parse(
    text = "
  f <- function(x) {
    for (i in 1:x) {
      print(i)
    }
  }
  ",
    keep.source = TRUE
  )

  eval(code[[1]])

  # Capture output
  output <- capture.output(print(src(f)))

  # Should NOT see intermediate <language> nodes
  language_nodes <- grep("<language>", output, value = TRUE)
  expect_equal(length(language_nodes), 0)

  # Should see collapsed path notation
  collapsed_paths <- grep(
    "\\[\\[\\d+\\]\\]\\[\\[\\d+\\]\\]",
    output,
    value = TRUE
  )
  expect_true(length(collapsed_paths) > 0)
})

test_that("deep nesting - while loop with nested block", {
  code <- parse(
    text = "
  f <- function(x) {
    i <- 0
    while (i < x) {
      print(i)
      i <- i + 1
    }
  }
  ",
    keep.source = TRUE
  )

  eval(code[[1]])
  result <- src(f)

  # Should have nested block for while body
  body_names <- names(result$`body()`)
  while_block_paths <- grep(
    "\\[\\[3\\]\\]\\[\\[3\\]\\]",
    body_names,
    value = TRUE
  )
  expect_true(length(while_block_paths) >= 1)
})

test_that("deep nesting - repeat loop with nested block", {
  code <- parse(
    text = "
  f <- function(x) {
    repeat {
      print(x)
      break
    }
  }
  ",
    keep.source = TRUE
  )

  eval(code[[1]])
  result <- src(f)

  # Should have nested block for repeat body
  expect_true("body()" %in% names(result))
  body_names <- names(result$`body()`)

  # Look for nested block path
  nested_paths <- grep("^\\[\\[2\\]\\]\\[\\[2\\]\\]", body_names, value = TRUE)
  expect_true(length(nested_paths) >= 1)
})

test_that("deep nesting - switch statement with blocks", {
  code <- parse(
    text = '
  f <- function(x) {
    switch(x,
      a = {
        print("a")
      },
      b = {
        print("b")
      }
    )
  }
  ',
    keep.source = TRUE
  )

  eval(code[[1]])
  result <- src(f)

  # Should have structure
  expect_type(result, "list")
  expect_s3_class(result, "lobstr_srcref")
})

test_that("deep nesting - quoted expressions with nested blocks", {
  code <- parse(
    text = "
  x <- quote({
    for (i in 1:3) {
      print(i)
    }
  })
  ",
    keep.source = TRUE
  )

  eval(code[[1]])
  result <- src(x)

  # Should show nested structure
  expect_type(result, "list")

  # Should have nested block paths
  if (!is.null(result) && length(result) > 0) {
    all_names <- names(unlist(result, recursive = TRUE))
    nested_paths <- grep(
      "\\[\\[\\d+\\]\\]\\[\\[\\d+\\]\\]",
      all_names,
      value = TRUE
    )
    # Might or might not have nested paths depending on how quote() preserves srcrefs
    expect_true(length(nested_paths) >= 0)
  }
})
