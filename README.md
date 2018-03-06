# lobstr

[![Travis-CI Build Status](https://travis-ci.org/r-lib/lobstr.svg?branch=master)](https://travis-ci.org/r-lib/lobstr)
[![Coverage status](https://codecov.io/gh/r-lib/lobstr/branch/master/graph/badge.svg)](https://codecov.io/github/r-lib/lobstr?branch=master)
 
A better `str()`. Designed to be used iteratively, so you can explore a complicated data structure one level at a time. 

`prim_*()` functions are pure C functions and do no S3/S4 dispatch. They have been carefully written to not evaluate input in R, so don't increment the ref count. This makes them most useful for developers who want to dig into the precise structure of an object.

There are three key functions:

* `prim_type()`: type of element (similar to `typeof()` but with better names).
  If S3 or S4, includes those in parentheses.

* `prim_desc()`: a brief description of the element.

Three functions help understand the memory usage of an object:

* `obj_size()`: the memory usage of an object.
* `obj_address()`: the memory location of an object
* `obj_ref()`: the ref count of an object.
