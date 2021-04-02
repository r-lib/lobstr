# Builds a regex that tests for the _lack_ of a substring
doesNotExistRegex <- function(substring){
  # Uses a negative look-behind to check for the absence of the substring
  # pattern.

  # The (?...) block controls how the perl regex parser works
  # s -> Makes a dot matches all characters
  # m -> Multiline mode
  paste0("(?sm)^(?!.*", substring, ").*$")
}


# These tests are disabled because they require snapshot testing which is not available until testthat 3
# test_that("Pure nested lists work", {
#   plain_list <- list(
#     list(id = "a",
#          val = 2),
#     list(id = "b",
#          val = 1,
#          children = list(
#            list(id = "b1",
#                 val = 2.5),
#            list(id = "b2",
#                 val = 8,
#                 children = list(
#                   list(id = "b21",
#                        val = 4)
#                 )))),
#     list(id = "c",
#          val = 8,
#          children = list(
#            list(),
#            list(id = "c1"),
#            list(id = "c2",
#                 val = 1))))
#
#   expect_snapshot(tree(plain_list))
#
#   # Also with array-likes without indices
#   expect_snapshot(tree(plain_list, index_arraylike = FALSE))
# })
#
#
# test_that("Atomic arrays have sensible defaults with truncation added for longer than 10-elements",{
#   list_w_vectors <- list(
#     name = "vectored list",
#     num_vec = 1:10,
#     char_vec = letters
#   )
#   expect_snapshot(
#     tree(list_w_vectors)
#   )
# })
#
# test_that("Works with HTML tag structures", {
#   # sliderInput is a pretty complex structure all in one line
#   expect_snapshot(
#     tree(shiny::sliderInput("test", "Input Label", 0,1,0.5))
#   )
# })

test_that("Max depth can be enforced", {
  plain_list <- list(
    list(id = "a",
         val = 2),
    list(id = "b",
         val = 1,
         children = list(
           list(id = "b1",
                val = 2.5),
           list(id = "b2",
                val = 8,
                children = list(
                  list(id = "b21",
                       val = 4)
                )))),
    list(id = "c",
         val = 8,
         children = list(
           list(),
           list(id = "c1"),
           list(id = "c2",
                val = 1))))

  expect_output(
    tree(plain_list, max_depth = 2),
    regexp = doesNotExistRegex("b21"),
    perl = TRUE
  )

  expect_output(
    tree(plain_list),
    regexp = "b21",
    fixed = TRUE
  )
})

test_that("Null printing", {

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
    tree(list(
      "a" = 1,
      "element without id"
    ),
    char_horizontal = "\u2500"),
    "\u2500\"element without id\"",
    fixed = TRUE
  )
})


test_that("Attributes are properly displayed as a special child node", {
  list_w_attrs <- structure(
    list(
      structure(
        list(id = "a",
             val = 2),
        level = 2,
        name = "first child"
      ),
      structure(
        list(id = "b",
             val = 1,
             children = list(
               list(id = "b1",
                    val = 2.5),
               list(id = "b2",
                    val = 8,
                    children = list(
                      list(id = "b21",
                           val = 4)
                    )))),
        level = 2,
        name = "second child",
        class = "custom-class"
      )),
    level = "1",
    name = "root"
  )

  # Disabled until testthat 3
  # expect_snapshot(tree(list_w_attrs, show_attributes = TRUE))

  expect_output(
    tree(list_w_attrs, show_attributes = FALSE),
    # Should _not_ contain text attr anywhere
    # The (?...) block controls how the perl regex parser works
    # s -> Makes a dot matches all characters
    # m -> Multiline mode
    regexp = doesNotExistRegex("attr"),
    perl = TRUE
  )

  expect_output(
    tree(list_w_attrs, show_attributes = TRUE),
    regexp = "attr",
    fixed = TRUE
  )
})

test_that("Handles elements with a single element and attributes well", {
  # The logic of handling single-element nodes with attributes is tricky
  # This test _should_ catch mistakes
  simple_string <- list(
    "first element",
    structure(
      "second element",
      purpose = "show bug"
    ))

  # Hard-code the last child symbol in-case the default changes
  last_child_symbol <- "\u2570"

  expect_output(
    tree(simple_string, show_attributes = TRUE, char_final_branch = last_child_symbol),
    regexp = doesNotExistRegex( paste0(last_child_symbol, ".*", last_child_symbol)),
    perl = TRUE
  )
})

test_that("Large and multiline strings are handled gracefully", {
  long_strings <- list(
    "normal string" = "first element",
    "really long string" = paste(rep(letters, 4), collapse = ""),
    "vec of long strings" = c(
      "a long\nand multi\nline string element",
      "a fine length",
      "another long\nand also multi\nline string element"
    ))

  # No truncation of first string
  expect_output(
    tree(long_strings),
    regexp = 'normal string:"first element"',
    fixed = TRUE
  )

  # Really long single string is truncated and elipsesed
  expect_output(
    tree(long_strings),
    regexp = 'really long string:"abcdefghijklmnopqrstuvwxyzabcdef..."',
    fixed = TRUE
  )

  # Short string inside vector with long strings is not truncated
  expect_output(
    tree(long_strings),
    regexp = ',"a fine length",',
    fixed = TRUE
  )

  # But it's long-siblings are
  expect_output(
    tree(long_strings),
    regexp = '"another long and also..."',
    fixed = TRUE
  )

  # Newline removal can be disabled
  expect_output(
    tree(long_strings, remove_newlines = FALSE),
    regexp = '"a long\n',
    fixed = TRUE
  )
})

