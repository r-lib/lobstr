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
#> [1:0x5622ff6fb810] <int> 

y <- list(x, x, x)
ref(y)
#> █ [1:0x56230317c2a8] <list> 
#> ├─[2:0x5622ff6fb810] <int> 
#> ├─[2:0x5622ff6fb810] 
#> └─[2:0x5622ff6fb810] 
ref(x, y)
#> [1:0x5622ff6fb810] <int> 
#>  
#> █ [2:0x56230317c2a8] <list> 
#> ├─[1:0x5622ff6fb810] 
#> ├─[1:0x5622ff6fb810] 
#> └─[1:0x5622ff6fb810] 

e <- new.env()
e$e <- e
e$x <- x
e$y <- list(x, e)
ref(e)
#> █ [1:0x5622fd44b4a0] <env> 
#> ├─x = [2:0x5622ff6fb810] <int> 
#> ├─y = █ [3:0x562303376e48] <list> 
#> │     ├─[2:0x5622ff6fb810] 
#> │     └─[1:0x5622fd44b4a0] 
#> └─e = [1:0x5622fd44b4a0] 

# Can also show references to global string pool if requested
ref(c("x", "x", "y"))
#> [1:0x562304e94c58] <chr> 
ref(c("x", "x", "y"), character = TRUE)
#> █ [1:0x562304de9f68] <chr> 
#> ├─[2:0x5622fd289f00] <string: "x"> 
#> ├─[2:0x5622fd289f00] 
#> └─[3:0x5622fd3b4208] <string: "y"> 
```
