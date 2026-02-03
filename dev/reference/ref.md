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
#> [1:0x5561cc4df070] <int> 

y <- list(x, x, x)
ref(y)
#> █ [1:0x5561d0d41fc8] <list> 
#> ├─[2:0x5561cc4df070] <int> 
#> ├─[2:0x5561cc4df070] 
#> └─[2:0x5561cc4df070] 
ref(x, y)
#> [1:0x5561cc4df070] <int> 
#>  
#> █ [2:0x5561d0d41fc8] <list> 
#> ├─[1:0x5561cc4df070] 
#> ├─[1:0x5561cc4df070] 
#> └─[1:0x5561cc4df070] 

e <- new.env()
e$e <- e
e$x <- x
e$y <- list(x, e)
ref(e)
#> █ [1:0x5561cfc5a3e8] <env> 
#> ├─x = [2:0x5561cc4df070] <int> 
#> ├─y = █ [3:0x5561d04a93c8] <list> 
#> │     ├─[2:0x5561cc4df070] 
#> │     └─[1:0x5561cfc5a3e8] 
#> └─e = [1:0x5561cfc5a3e8] 

# Can also show references to global string pool if requested
ref(c("x", "x", "y"))
#> [1:0x5561d0840f18] <chr> 
ref(c("x", "x", "y"), character = TRUE)
#> █ [1:0x5561d083b528] <chr> 
#> ├─[2:0x5561ca2d5ee0] <string: "x"> 
#> ├─[2:0x5561ca2d5ee0] 
#> └─[3:0x5561ca4001e8] <string: "y"> 
```
