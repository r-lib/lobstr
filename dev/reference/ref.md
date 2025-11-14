# Display tree of references

This tree display focusses on the distinction between names and values.
For each reference-type object (lists, environments, and optional
character vectors), it displays the location of each component. The
display shows the connection between shared references using a locally
unique id.

## Usage

``` r
ref(..., character = FALSE)
```

## Arguments

- ...:

  One or more objects

- character:

  If `TRUE`, show references from character vector in to global string
  pool

## See also

Other object inspectors:
[`ast()`](https://lobstr.r-lib.org/dev/reference/ast.md),
[`sxp()`](https://lobstr.r-lib.org/dev/reference/sxp.md)

## Examples

``` r
x <- 1:100
ref(x)
#> [1:0x55a94999ce50] <int> 

y <- list(x, x, x)
ref(y)
#> █ [1:0x55a94d264c38] <list> 
#> ├─[2:0x55a94999ce50] <int> 
#> ├─[2:0x55a94999ce50] 
#> └─[2:0x55a94999ce50] 
ref(x, y)
#> [1:0x55a94999ce50] <int> 
#>  
#> █ [2:0x55a94d264c38] <list> 
#> ├─[1:0x55a94999ce50] 
#> ├─[1:0x55a94999ce50] 
#> └─[1:0x55a94999ce50] 

e <- new.env()
e$e <- e
e$x <- x
e$y <- list(x, e)
ref(e)
#> █ [1:0x55a947b7a4e0] <env> 
#> ├─x = [2:0x55a94999ce50] <int> 
#> ├─y = █ [3:0x55a94c6a33b8] <list> 
#> │     ├─[2:0x55a94999ce50] 
#> │     └─[1:0x55a947b7a4e0] 
#> └─e = [1:0x55a947b7a4e0] 

# Can also show references to global string pool if requested
ref(c("x", "x", "y"))
#> [1:0x55a94ce80bf8] <chr> 
ref(c("x", "x", "y"), character = TRUE)
#> █ [1:0x55a94cf71778] <chr> 
#> ├─[2:0x55a946ab62a0] <string: "x"> 
#> ├─[2:0x55a946ab62a0] 
#> └─[3:0x55a946be05a8] <string: "y"> 
```
