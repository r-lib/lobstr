# Pretty tree-like object printing

A cleaner and easier to read replacement for `str` for nested list-like
objects

## Usage

``` r
tree(
  x,
  ...,
  index_unnamed = FALSE,
  max_depth = 10L,
  max_length = 1000L,
  show_environments = TRUE,
  hide_scalar_types = TRUE,
  val_printer = crayon::blue,
  class_printer = crayon::silver,
  show_attributes = FALSE,
  remove_newlines = TRUE,
  tree_chars = box_chars()
)
```

## Arguments

- x:

  A tree like object (list, etc.)

- ...:

  Ignored (used to force use of names)

- index_unnamed:

  Should children of containers without names have indices used as
  stand-in?

- max_depth:

  How far down the tree structure should be printed. E.g. `1` means only
  direct children of the root element will be shown. Useful for very
  deep lists.

- max_length:

  How many elements should be printed? This is useful in case you try
  and print an object with 100,000 items in it.

- show_environments:

  Should environments be treated like normal lists and recursed into?

- hide_scalar_types:

  Should atomic scalars be printed with type and length like vectors?
  E.g. `x <- "a"` would be shown as `x<char [1]>: "a"` instead of
  `x: "a"`.

- val_printer:

  Function that values get passed to before being drawn to screen. Can
  be used to color or generally style output.

- class_printer:

  Same as `val_printer` but for the the class types of non-atomic tree
  elements.

- show_attributes:

  Should attributes be printed as a child of the list or avoided?

- remove_newlines:

  Should character strings with newlines in them have the newlines
  removed? Not doing so will mess up the vertical flow of the tree but
  may be desired for some use-cases if newline structure is important to
  understanding object state.

- tree_chars:

  List of box characters used to construct tree. Needs elements `$h` for
  horizontal bar, `$hd` for dotted horizontal bar, `$v` for vertical
  bar, `$vd` for dotted vertical bar, `$l` for l-bend, and `$j` for
  junction (or middle child).

## Value

console output of structure

## Examples

``` r
x <- list(
  list(id = "a", val = 2),
  list(
    id = "b",
    val = 1,
    children = list(
      list(id = "b1", val = 2.5),
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

# Basic usage
tree(x)
#> <list>
#> ├─<list>
#> │ ├─id: "a"
#> │ └─val: 2
#> ├─<list>
#> │ ├─id: "b"
#> │ ├─val: 1
#> │ └─children: <list>
#> │   ├─<list>
#> │   │ ├─id: "b1"
#> │   │ └─val: 2.5
#> │   └─<list>
#> │     ├─id: "b2"
#> │     ├─val: 8
#> │     └─children: <list>
#> │       └─<list>
#> │         ├─id: "b21"
#> │         └─val: 4
#> └─<list>
#>   ├─id: "c"
#>   ├─val: 8
#>   └─children: <list>
#>     ├─<list>
#>     │ └─id: "c1"
#>     └─<list>
#>       ├─id: "c2"
#>       └─val: 1

# Even cleaner output can be achieved by not printing indices
tree(x, index_unnamed = FALSE)
#> <list>
#> ├─<list>
#> │ ├─id: "a"
#> │ └─val: 2
#> ├─<list>
#> │ ├─id: "b"
#> │ ├─val: 1
#> │ └─children: <list>
#> │   ├─<list>
#> │   │ ├─id: "b1"
#> │   │ └─val: 2.5
#> │   └─<list>
#> │     ├─id: "b2"
#> │     ├─val: 8
#> │     └─children: <list>
#> │       └─<list>
#> │         ├─id: "b21"
#> │         └─val: 4
#> └─<list>
#>   ├─id: "c"
#>   ├─val: 8
#>   └─children: <list>
#>     ├─<list>
#>     │ └─id: "c1"
#>     └─<list>
#>       ├─id: "c2"
#>       └─val: 1

# Limit depth if object is potentially very large
tree(x, max_depth = 2)
#> <list>
#> ├─<list>
#> │ ├─id: "a"
#> │ └─val: 2
#> ├─<list>
#> │ ├─id: "b"
#> │ ├─val: 1
#> │ └─children: <list>...
#> └─<list>
#>   ├─id: "c"
#>   ├─val: 8
#>   └─children: <list>...

# You can customize how the values and classes are printed if desired
tree(x, val_printer = function(x) {
  paste0("_", x, "_")
})
#> <list>
#> ├─<list>
#> │ ├─id: _"a"_
#> │ └─val: _2_
#> ├─<list>
#> │ ├─id: _"b"_
#> │ ├─val: _1_
#> │ └─children: <list>
#> │   ├─<list>
#> │   │ ├─id: _"b1"_
#> │   │ └─val: _2.5_
#> │   └─<list>
#> │     ├─id: _"b2"_
#> │     ├─val: _8_
#> │     └─children: <list>
#> │       └─<list>
#> │         ├─id: _"b21"_
#> │         └─val: _4_
#> └─<list>
#>   ├─id: _"c"_
#>   ├─val: _8_
#>   └─children: <list>
#>     ├─<list>
#>     │ └─id: _"c1"_
#>     └─<list>
#>       ├─id: _"c2"_
#>       └─val: _1_
```
