# lobstr

A better `str()`. Designed to be used iteratively, so you can explore a complicated data structure one level at a time. 

Lobstr provides two families of functions: `prim_` and `user_`. The `prim_*()` functions are pure C functions and do no S3/S4 dispatch. They have been carefully written to not touch evaluate in input in R, so don't increment the ref count. This makes them most useful for developers who want to dig into the precise structure of an object. The `user_*()` functions are S3 generics, making it easy to override the behaviour for specific cases. These are designed more for the R user, who just needs a solid idea of what the components are, not the precise details.

There are three key functions:

* `user_children()`/`prim_children()`: a list with one element for each child.

* `user_type()/`prim_type()`: type of element (similar to `typeof()` but with better names).
  If S3 or S4, includes those in parentheses.

* `user_desc()`/`prim_desc()`: a brief description of the element.

Two functions help understand the memory usage of an object:

* `prim_address()`: the memory location of an object
* `prim_ref()`: the ref count of an object.

# Types

* `S4SXP`: either simple type, or S4SXP. In either case, the S4 bit is set
  (test with `IS_S4_OBJECT`) and the class attribute is set to a length 1 
  character vector. The class attribute has a "package" attribute 
  (also a length 1 string).
