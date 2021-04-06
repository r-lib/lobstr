

test_that("Array-like indices can be shown or hidden", {
  expect_snapshot({
    nested_lists <- list(
      list(id = "a", val = 2),
      list(
        id = "b",
        val = 1,
        children = list(
          list(id = "b1",val = 2.5),
          list(
            id = "b2",
            val = 8,
            children = list(
              list(id = "b21", val = 4)
            )
          )
        )
      ),
      list(
        id = "c",
        val = 8,
        children = list(
          list(id = "c1"),
          list(id = "c2", val = 1)
        )
      )
    )

    tree(nested_lists, index_unnamed = TRUE)

    tree(nested_lists, index_unnamed = FALSE)
  })

})


test_that(
  "Atomic arrays have sensible defaults with truncation added for longer than 10-elements",
  {
    expect_snapshot(
      tree(
        list(
          name = "vectored list",
          num_vec = 1:10,
          char_vec = letters
        )
      )
    )

  })

test_that("Works with HTML tag structures", {
  # sliderInput is a pretty complex structure all in one line
  expect_snapshot(
    tree(shiny::sliderInput("test", "Input Label", 0,1,0.5))
  )
})


# Builds a regex that tests for the _lack_ of a substring
doesNotExistRegex <- function(substring){
  # Uses a negative look-behind to check for the absence of the substring
  # pattern.

  # The (?...) block controls how the perl regex parser works
  # s -> Makes a dot matches all characters
  # m -> Multiline mode
  paste0("(?sm)^(?!.*", substring, ").*$")
}

test_that("Max depth can be enforced", {

  expect_snapshot({
    deep_list <- list(
      list(id = "a", val = 2),
      list(
        id = "b",
        val = 1,
        children = list(
          list(id = "b1",val = 2.5),
          list(
            id = "b2",
            val = 8,
            children = list(
              list(id = "b21", val = 4)
            )
          )
        )
      )
    )
    tree(deep_list, max_depth = 1)
    tree(deep_list, max_depth = 2)
    tree(deep_list, max_depth = 3)
  })
})

test_that("Null values are caught and printed properly", {
  expect_output(
    tree(list("null-element" = NULL)),
    regexp = "null-element:<NULL>",
    fixed = TRUE
  )
})

test_that("NA printing", {
  expect_output(
    tree(list("NA-element" = NA)),
    regexp = "NA-element:NA",
    fixed = TRUE
  )
})

test_that("non-named elements in named list",{
  expect_output(
    tree(
      list(
        "a" = 1,
        "element without id"
      ),
      char_horizontal = "\u2500"),
    "\u2500\"element without id\"",
    fixed = TRUE
  )
})


test_that("Attributes are properly displayed as special children nodes", {

  expect_snapshot({
    list_w_attrs <- structure(
      list(
        structure(
          list(id = "a", val = 2),
          level = 2,
          name = "first child"
        ),
        structure(
          list(
            id = "b",
            val = 1,
            children = list(
              list(id = "b1", val = 2.5)
            )
          ),
          level = 2,
          name = "second child",
          class = "custom-class"
        ),
        level = "1",
        name = "root"
      )
    )

    # Shows attributes
    tree(list_w_attrs, show_attributes = TRUE)

    # Hides attributes (default)
    tree(list_w_attrs, show_attributes = FALSE)
  })
})

test_that("Handles elements with a single element and attributes well", {
  # The logic of handling single-element nodes with attributes is tricky
  # This test _should_ catch mistakes
  expect_snapshot({
    tree(
      list(
        "first element",
        structure(
          "second element",
          purpose = "show bug"
        )
      ),
      show_attributes = TRUE
    )
  })

})

test_that("Large and multiline strings are handled gracefully", {
  expect_snapshot({
    long_strings <- list(
      "normal string" = "first element",
      "really long string" = paste(rep(letters, 4), collapse = ""),
      "vec of long strings" = c(
        "a long\nand multi\nline string element",
        "a fine length",
        "another long\nand also multi\nline string element"
      )
    )

    # No truncation of first string
    # Really long single string is truncated and elipsesed
    # Short string inside vector with long strings is not truncated
    tree(long_strings)

    # Newline removal can be disabled
    tree(long_strings, remove_newlines = FALSE)
  })
})
