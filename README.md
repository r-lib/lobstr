# lobstr

A better `str()`. Designed to be used iteratively, so you can explore a complicated data structure one item at a time.

There are four key functions:

* `prim_children()`: a list with one element for each child.

* `prim_length()`: the number of children.

* `prim_type()`: type of element (similar to `typeof()` but with better names).
  If S3 or S4, includes those in parentheses.

* `prim_desc()`: a brief description of the element.
