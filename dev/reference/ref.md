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
[`src()`](https://lobstr.r-lib.org/dev/reference/src.md),
[`sxp()`](https://lobstr.r-lib.org/dev/reference/sxp.md)

## Examples

``` r
x <- 1:100
ref(x)
#> [1:0x55f99d8a6c70] <int> 

y <- list(x, x, x)
ref(y)
#> █ [1:0x55f9a137f1e8] <list> 
#> ├─[2:0x55f99d8a6c70] <int> 
#> ├─[2:0x55f99d8a6c70] 
#> └─[2:0x55f99d8a6c70] 
ref(x, y)
#> [1:0x55f99d8a6c70] <int> 
#>  
#> █ [2:0x55f9a137f1e8] <list> 
#> ├─[1:0x55f99d8a6c70] 
#> ├─[1:0x55f99d8a6c70] 
#> └─[1:0x55f99d8a6c70] 

e <- new.env()
e$e <- e
e$x <- x
e$y <- list(x, e)
ref(e)
#> █ [1:0x55f99b5f6af8] <env> 
#> ├─x = [2:0x55f99d8a6c70] <int> 
#> ├─y = █ [3:0x55f9a1534758] <list> 
#> │     ├─[2:0x55f99d8a6c70] 
#> │     └─[1:0x55f99b5f6af8] 
#> └─e = [1:0x55f99b5f6af8] 

# Can also show references to global string pool if requested
ref(c("x", "x", "y"))
#> [1:0x55f9a303e348] <chr> 
ref(c("x", "x", "y"), character = TRUE)
#> █ [1:0x55f9a2f96f18] <chr> 
#> ├─[2:0x55f99b434f00] <string: "x"> 
#> ├─[2:0x55f99b434f00] 
#> └─[3:0x55f99b55f208] <string: "y"> 
```
