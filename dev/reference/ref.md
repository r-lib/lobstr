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
#> [1:0x565538196ce0] <int> 

y <- list(x, x, x)
ref(y)
#> █ [1:0x56553c433ec8] <list> 
#> ├─[2:0x565538196ce0] <int> 
#> ├─[2:0x565538196ce0] 
#> └─[2:0x565538196ce0] 
ref(x, y)
#> [1:0x565538196ce0] <int> 
#>  
#> █ [2:0x56553c433ec8] <list> 
#> ├─[1:0x565538196ce0] 
#> ├─[1:0x565538196ce0] 
#> └─[1:0x565538196ce0] 

e <- new.env()
e$e <- e
e$x <- x
e$y <- list(x, e)
ref(e)
#> █ [1:0x56553c05ba18] <env> 
#> ├─x = [2:0x565538196ce0] <int> 
#> ├─y = █ [3:0x56553c3b4fa8] <list> 
#> │     ├─[2:0x565538196ce0] 
#> │     └─[1:0x56553c05ba18] 
#> └─e = [1:0x56553c05ba18] 

# Can also show references to global string pool if requested
ref(c("x", "x", "y"))
#> [1:0x56553bba12f8] <chr> 
ref(c("x", "x", "y"), character = TRUE)
#> █ [1:0x56553bb9b908] <chr> 
#> ├─[2:0x565535e21f00] <string: "x"> 
#> ├─[2:0x565535e21f00] 
#> └─[3:0x565535f4c208] <string: "y"> 
```
