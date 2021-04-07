

test_that("Array-like indices can be shown or hidden", {
  expect_snapshot({
    tree(list(a = "a", "b", "c"), index_unnamed = TRUE)
  })
  expect_snapshot({
    tree(list(a = "a", "b", "c"), index_unnamed = FALSE)
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

test_that("Max depth and length can be enforced", {

  expect_snapshot({
    deep_list <- list(
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
      list(id = "a", val = 2)
    )
    tree(deep_list, max_depth = 1)
    tree(deep_list, max_depth = 2)
    tree(deep_list, max_depth = 3)

    tree(deep_list, max_length = 0)
    tree(deep_list, max_length = 2)
    tree(deep_list, max_depth = 1, max_length = 4)
  })
})

test_that("Missing values are caught and printed properly", {
  expect_snapshot(
    tree(
      list(
        "null-element" = NULL,
        "NA-element" = NA
      )
    )
  )
})


test_that("non-named elements in named list",{
  expect_snapshot(
    tree(list("a" = 1, "el w/o id"))
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

test_that("Can optionally recurse into environments", {
  # Wrapped in a local to avoid different environment setup for code running in
  # test_that instead of interactively
  # Can't use snapshots here because environment address change on each run
  env_printing <- capture.output(
    local(
      {
        ea <- env(d = 4, e = 5)
        tree(env(ea, a = 1, b = 2, c = 3))
      },
      envir = rlang::global_env()
    )
  )

  # Seven total nodes should be printed
  expect_equal(
    length(env_printing),
    7
  )

  # Printed only the names we expected
  expect_equal(
    mean(
      grepl(
        pattern = "(environment|a|b|c|d|e):",
        env_printing
      )
    ),
    1
  )

  # Should only print two environment nodes (aka didn't escape past global env)
  expect_equal(
    sum(grepl(pattern = "<environment:", env_printing, fixed = TRUE)),
    2
  )

})
