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
#> [1:0x55602df7def8] <int> 

y <- list(x, x, x)
ref(y)
#> █ [1:0x55603168b738] <list> 
#> ├─[2:0x55602df7def8] <int> 
#> ├─[2:0x55602df7def8] 
#> └─[2:0x55602df7def8] 
ref(x, y)
#> [1:0x55602df7def8] <int> 
#>  
#> █ [2:0x55603168b738] <list> 
#> ├─[1:0x55602df7def8] 
#> ├─[1:0x55602df7def8] 
#> └─[1:0x55602df7def8] 

e <- new.env()
e$e <- e
e$x <- x
e$y <- list(x, e)
ref(e)
#> █ [1:0x55602c173fa8] <env> 
#> ├─x = [2:0x55602df7def8] <int> 
#> ├─y = █ [3:0x55602ffe0ab8] <list> 
#> │     ├─[2:0x55602df7def8] 
#> │     └─[1:0x55602c173fa8] 
#> └─e = [1:0x55602c173fa8] 

# Can also show references to global string pool if requested
ref(c("x", "x", "y"))
#> [1:0x5560317fa658] <chr> 
ref(c("x", "x", "y"), character = TRUE)
#> █ [1:0x5560314cb6c8] <chr> 
#> ├─[2:0x55602b0b32a0] <string: "x"> 
#> ├─[2:0x55602b0b32a0] 
#> └─[3:0x55602b1dd5a8] <string: "y"> 
```
