
<!-- README.md is generated from README.Rmd. Please edit that file -->

# lobstr <img src="man/figures/logo.png" align="right" height="139" />

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/lobstr)](https://cran.r-project.org/package=lobstr)
[![R-CMD-check](https://github.com/r-lib/lobstr/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/r-lib/lobstr/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/r-lib/lobstr/branch/main/graph/badge.svg)](https://app.codecov.io/gh/r-lib/lobstr?branch=main)
<!-- badges: end -->

lobstr provides tools in the same vein as `str()`, which allow you to
dig into the detail of an object.

## Installation

Install the released version of lobstr from CRAN:

``` r
install.packages("lobstr")
```

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
#> █ [1:0x7fed114eaea8] <list> 
#> ├─[2:0x7fed21f373b8] <int> 
#> ├─[2:0x7fed21f373b8] 
#> └─[2:0x7fed21f373b8]

e <- rlang::env()
e$self <- e
ref(e)
#> █ [1:0x7fecf1856f00] <env> 
#> └─self = [1:0x7fecf1856f00]
```

A related tool is `obj_size()`, which computes the size of an object
taking these shared references into account:

``` r
obj_size(x)
#> 680 B
obj_size(y)
#> 760 B
```

### Call stack trees

`cst()` shows how frames on the call stack are connected:

``` r
f <- function(x) g(x)
g <- function(x) h(x)
h <- function(x) x
f(cst())
#>     ▆
#>  1. ├─global f(cst())
#>  2. │ └─global g(x)
#>  3. │   └─global h(x)
#>  4. └─lobstr::cst()
```
