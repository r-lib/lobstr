# lobstr

lobstr provides tools in the same vein as
[`str()`](https://rdrr.io/r/utils/str.html), which allow you to dig into
the detail of an object.

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

[`ast()`](https://lobstr.r-lib.org/dev/reference/ast.md) draws the
abstract syntax tree of R expressions:

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

[`ref()`](https://lobstr.r-lib.org/dev/reference/ref.md) shows hows
objects can be shared across data structures by digging into the
underlying \_\_ref\_\_erences:

``` r
x <- 1:1e6
y <- list(x, x, x)
ref(y)
#> █ [1:0x15746ab48] <list> 
#> ├─[2:0x157222590] <int> 
#> ├─[2:0x157222590] 
#> └─[2:0x157222590]

e <- rlang::env()
e$self <- e
ref(e)
#> █ [1:0x157561e78] <env> 
#> └─self = [1:0x157561e78]
```

A related tool is
[`obj_size()`](https://lobstr.r-lib.org/dev/reference/obj_size.md),
which computes the size of an object taking these shared references into
account:

``` r
obj_size(x)
#> 680 B
obj_size(y)
#> 760 B
```

### Call stack trees

[`cst()`](https://lobstr.r-lib.org/dev/reference/cst.md) shows how
frames on the call stack are connected:

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
