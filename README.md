
<!-- README.md is generated from README.Rmd. Please edit that file -->

# lobstr

[![Travis-CI Build
Status](https://travis-ci.org/r-lib/lobstr.svg?branch=master)](https://travis-ci.org/r-lib/lobstr)
[![Coverage
status](https://codecov.io/gh/r-lib/lobstr/branch/master/graph/badge.svg)](https://codecov.io/github/r-lib/lobstr?branch=master)

lobstr provides tool in the same vein as `str()`, tools that allow you
to dig into the detail of an object.

## Installation

You can install the development version with:

``` r
# install.packages("devtools")
devtools::install_github("r-lib/lobstr")
```

## Example

### Abstract syntax trees

`ast()` draws the abstract syntax tree of R expressions:

``` r
ast(a + b + c)
#> █─`+` 
#> ├─█─`+` 
#> │ ├─a 
#> │ └─b 
#> └─c

ast(function(x = 1) {
  if (x > 0) print("Hi!")
})
#> █─`function` 
#> ├─█─x = 1 
#> ├─█─`{` 
#> │ └─█─`if` 
#> │   ├─█─`>` 
#> │   │ ├─x 
#> │   │ └─0 
#> │   └─█─print 
#> │     └─"Hi!" 
#> └─<inline srcref>
```

### References

`ref()` shows hows objects can be shared across data structures by
digging into the underlying \_\_ref\_\_erences:

``` r
x <- 1:1e6
y <- list(x, x, x)
ref(y)
#> █ <1:0x7fe4c805e368> list 
#> ├─<2:0x10b4b0000> int 
#> ├─<2:0x10b4b0000> 
#> └─<2:0x10b4b0000>

e <- rlang::env()
e$self <- e
ref(e)
#> █ <1:0x7fe4c2348508> env 
#> └─self = <1:0x7fe4c2348508>
```

A related tool is `obj_size()`, which computes the size of an object
taking these shared references into account:

``` r
obj_size(x)
#> 4,000,040 B
obj_size(y)
#> 4,000,112 B
```

### Call stack trees

`cst()` shows how frames on the call stack are connected:

``` r
f <- function(x) g(x)
g <- function(x) h(x)
h <- function(x) x
f(cst())
#> ★
#> ├─rmarkdown::render(...)
#> │ └─knitr::knit(...)
#> │   └─process_file(text, output)
#> │     ├─withCallingHandlers(...)
#> │     ├─process_group(group)
#> │     └─process_group.block(group)
#> │       └─call_block(x)
#> │         └─block_exec(params)
#> │           ├─in_dir(...)
#> │           └─evaluate(...)
#> │             └─evaluate::evaluate(...)
#> │               └─evaluate_call(...)
#> │                 ├─timing_fn(...)
#> │                 ├─handle(...)
#> │                 ├─withCallingHandlers(...)
#> │                 ├─withVisible(eval(expr, envir, enclos))
#> │                 └─eval(expr, envir, enclos)
#> │                   └─eval(expr, envir, enclos)
#> ├─f(cst())
#> │ └─g(x)
#> │   └─h(x)
#> └─cst()
```
