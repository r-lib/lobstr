
<!-- README.md is generated from README.Rmd. Please edit that file -->

# lobstr <a href="https://lobstr.r-lib.org"><img src="man/figures/logo.png" align="right" height="138" alt="lobstr website" /></a>

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/lobstr)](https://cran.r-project.org/package=lobstr)
[![R-CMD-check](https://github.com/r-lib/lobstr/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/r-lib/lobstr/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/r-lib/lobstr/graph/badge.svg)](https://app.codecov.io/gh/r-lib/lobstr)
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
# install.packages("pak")
pak::pak("r-lib/lobstr")
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
#> └─NULL
```

### References

`ref()` shows hows objects can be shared across data structures by
digging into the underlying \_\_ref\_\_erences:

``` r
x <- 1:1e6
y <- list(x, x, x)
ref(y)
#> █ [1:0x126225d88] <list> 
#> ├─[2:0x1114afb90] <int> 
#> ├─[2:0x1114afb90] 
#> └─[2:0x1114afb90]

e <- rlang::env()
e$self <- e
ref(e)
#> █ [1:0x126563548] <env> 
#> └─self = [1:0x126563548]
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
#>  1. ├─f(cst())
#>  2. │ └─g(x)
#>  3. │   └─h(x)
#>  4. └─lobstr::cst()
```
