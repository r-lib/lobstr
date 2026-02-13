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
#> [1:0x55d6070f4e30] <int> 

y <- list(x, x, x)
ref(y)
#> █ [1:0x55d60ab76588] <list> 
#> ├─[2:0x55d6070f4e30] <int> 
#> ├─[2:0x55d6070f4e30] 
#> └─[2:0x55d6070f4e30] 
ref(x, y)
#> [1:0x55d6070f4e30] <int> 
#>  
#> █ [2:0x55d60ab76588] <list> 
#> ├─[1:0x55d6070f4e30] 
#> ├─[1:0x55d6070f4e30] 
#> └─[1:0x55d6070f4e30] 

e <- new.env()
e$e <- e
e$x <- x
e$y <- list(x, e)
ref(e)
#> █ [1:0x55d604e44a50] <env> 
#> ├─x = [2:0x55d6070f4e30] <int> 
#> ├─y = █ [3:0x55d60c70e4b8] <list> 
#> │     ├─[2:0x55d6070f4e30] 
#> │     └─[1:0x55d604e44a50] 
#> └─e = [1:0x55d604e44a50] 

# Can also show references to global string pool if requested
ref(c("x", "x", "y"))
#> [1:0x55d60c808fe8] <chr> 
ref(c("x", "x", "y"), character = TRUE)
#> █ [1:0x55d60c7d5548] <chr> 
#> ├─[2:0x55d604c82f00] <string: "x"> 
#> ├─[2:0x55d604c82f00] 
#> └─[3:0x55d604dad208] <string: "y"> 
```
