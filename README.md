# lobstr

[![Travis-CI Build Status](https://travis-ci.org/hadley/lobstr.svg?branch=master)](https://travis-ci.org/hadley/lobstr)
[![Coverage status](https://codecov.io/gh/hadley/lobstr/branch/master/graph/badge.svg)](https://codecov.io/github/hadley/lobstr?branch=master)
 
A better `str()`. Designed to be used iteratively, so you can explore a complicated data structure one level at a time. 

`prim_*()` functions are pure C functions and do no S3/S4 dispatch. They have been carefully written to not evaluate input in R, so don't increment the ref count. This makes them most useful for developers who want to dig into the precise structure of an object.

There are three key functions:

* `prim_children()`: a list with one element for each child.

* `prim_type()`: type of element (similar to `typeof()` but with better names).
  If S3 or S4, includes those in parentheses.

* `prim_desc()`: a brief description of the element.

Three functions help understand the memory usage of an object:

* `object_size()`: the memory usage of an object.
* `prim_address()`: the memory location of an object
* `prim_ref()`: the ref count of an object.
