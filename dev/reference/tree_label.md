# Build element or node label in tree

These methods control how the value of a given node is printed. New
methods can be added if support is needed for a novel class

## Usage

``` r
tree_label(x, opts)
```

## Arguments

- x:

  A tree like object (list, etc.)

- opts:

  A list of options that directly mirrors the named arguments of
  [tree](https://lobstr.r-lib.org/dev/reference/tree.md). E.g.
  `list(val_printer = crayon::red)` is equivalent to
  `tree(..., val_printer = crayon::red)`.
