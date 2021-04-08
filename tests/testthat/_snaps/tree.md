# Array-like indices can be shown or hidden

    Code
      tree(list(a = "a", "b", "c"), index_unnamed = TRUE)
    Output
      <list>
      ├─a: "a"
      ├─2: "b"
      └─3: "c"

---

    Code
      tree(list(a = "a", "b", "c"), index_unnamed = FALSE)
    Output
      <list>
      ├─a: "a"
      ├─"b"
      └─"c"

# Atomic arrays have sensible defaults with truncation added for longer than 10-elements

    Code
      tree(list(name = "vectored list", num_vec = 1:10, char_vec = letters))
    Output
      <list>
      ├─name: "vectored list"
      ├─num_vec<int [10]>: 1, 2, 3, 4, 5, 6, 7, 8, 9, 10
      └─char_vec<chr [26]>: "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", ...

---

    Code
      tree(list(name = "vectored list", num_vec = 1:10, char_vec = letters),
      hide_scalar_types = FALSE)
    Output
      <list>
      ├─name<chr [1]>: "vectored list"
      ├─num_vec<int [10]>: 1, 2, 3, 4, 5, 6, 7, 8, 9, 10
      └─char_vec<chr [26]>: "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", ...

# Large and multiline strings are handled gracefully

    Code
      long_strings <- list(`normal string` = "first element", `really long string` = paste(
        rep(letters, 4), collapse = ""), `vec of long strings` = c(
        "a long\nand multi\nline string element", "a fine length",
        "another long\nand also multi\nline string element"))
      tree(long_strings)
    Output
      <list>
      ├─normal string: "first element"
      ├─really long string: "abcdefghijklmnopqrstuvwxyzabcdef..."
      └─vec of long strings<chr [3]>: "a long↵and m...", "a fine length", "another long..."
    Code
      tree(long_strings, remove_newlines = FALSE)
    Output
      <list>
      ├─normal string: "first element"
      ├─really long string: "abcdefghijklmnopqrstuvwxyzabcdef..."
      └─vec of long strings<chr [3]>: "a long
      and m...", "a fine length", "another long..."

# Works with HTML tag structures

    Code
      tree(shiny::sliderInput("test", "Input Label", 0, 1, 0.5))
    Output
      S3<shiny.tag>
      ├─name: "div"
      ├─attribs: <list>
      │ └─class: "form-group shiny-input-container"
      └─children: <list>
        ├─S3<shiny.tag>
        │ ├─name: "label"
        │ ├─attribs: <list>
        │ │ ├─class: "control-label"
        │ │ ├─id: "test-label"
        │ │ └─for: "test"
        │ └─children: <list>
        │   └─"Input Label"
        └─S3<shiny.tag>
          ├─name: "input"
          ├─attribs: <list>
          │ ├─class: "js-range-slider"
          │ ├─id: "test"
          │ ├─data-skin: "shiny"
          │ ├─data-min: "0"
          │ ├─data-max: "1"
          │ ├─data-from: "0.5"
          │ ├─data-step: "0.01"
          │ ├─data-grid: "true"
          │ ├─data-grid-num: 10
          │ ├─data-grid-snap: "false"
          │ ├─data-prettify-separator: ","
          │ ├─data-prettify-enabled: "true"
          │ ├─data-keyboard: "true"
          │ └─data-data-type: "number"
          └─children: <list>

# Max depth and length can be enforced

    Code
      deep_list <- list(list(id = "b", val = 1, children = list(list(id = "b1", val = 2.5),
      list(id = "b2", val = 8, children = list(list(id = "b21", val = 4))))), list(
        id = "a", val = 2))
      tree(deep_list, max_depth = 1)
    Output
      <list>
      ├─<list>...
      └─<list>...
    Code
      tree(deep_list, max_depth = 2)
    Output
      <list>
      ├─<list>
      │ ├─id: "b"
      │ ├─val: 1
      │ └─children: <list>...
      └─<list>
        ├─id: "a"
        └─val: 2
    Code
      tree(deep_list, max_depth = 3)
    Output
      <list>
      ├─<list>
      │ ├─id: "b"
      │ ├─val: 1
      │ └─children: <list>
      │   ├─<list>...
      │   └─<list>...
      └─<list>
        ├─id: "a"
        └─val: 2
    Code
      tree(deep_list, max_length = 0)
    Output
      ... 
    Code
      tree(deep_list, max_length = 2)
    Output
      <list>
      ├─<list>
      ... 
    Code
      tree(deep_list, max_depth = 1, max_length = 4)
    Output
      <list>
      ├─<list>...
      └─<list>...

# Missing values are caught and printed properly

    Code
      tree(list(`null-element` = NULL, `NA-element` = NA))
    Output
      <list>
      ├─null-element: <NULL>
      └─NA-element: NA

# non-named elements in named list

    Code
      tree(list(a = 1, "el w/o id"))
    Output
      <list>
      ├─a: 1
      └─"el w/o id"

# Attributes are properly displayed as special children nodes

    Code
      list_w_attrs <- structure(list(structure(list(id = "a", val = 2), level = 2,
      name = "first child"), structure(list(id = "b", val = 1, children = list(list(
        id = "b1", val = 2.5))), level = 2, name = "second child", class = "custom-class"),
      level = "1", name = "root"))
      tree(list_w_attrs, show_attributes = TRUE)
    Output
      <list>
      ├─<list>
      │ ├─id: "a"
      │ ├─val: 2
      │ ├┄attr(,"names")<chr [2]>: "id", "val"
      │ ├┄attr(,"level"): 2
      │ └┄attr(,"name"): "first child"
      ├─S3<custom-class>
      │ ├─id: "b"
      │ ├─val: 1
      │ ├─children: <list>
      │ ┊ └─<list>
      │ ┊   ├─id: "b1"
      │ ┊   ├─val: 2.5
      │ ┊   └┄attr(,"names")<chr [2]>: "id", "val"
      │ ├┄attr(,"names")<chr [3]>: "id", "val", "children"
      │ ├┄attr(,"level"): 2
      │ ├┄attr(,"name"): "second child"
      │ └┄attr(,"class"): "custom-class"
      ├─level: "1"
      ├─name: "root"
      └┄attr(,"names")<chr [4]>: "", "", "level", "name"
    Code
      tree(list_w_attrs, show_attributes = FALSE)
    Output
      <list>
      ├─<list>
      │ ├─id: "a"
      │ └─val: 2
      ├─S3<custom-class>
      │ ├─id: "b"
      │ ├─val: 1
      │ └─children: <list>
      │   └─<list>
      │     ├─id: "b1"
      │     └─val: 2.5
      ├─level: "1"
      └─name: "root"

# Function arguments get printed

    Code
      tree(list(no_args = function() {
        TRUE
      }, few_args = function(a, b, c) { }, lots_of_args = utils::strOptions))
    Output
      <list>
      ├─no_args: function()
      ├─few_args: function(a, b, c)
      └─lots_of_args: function(strict.width, digits.d, vec.len, list.len, deparse.lines, ...)

