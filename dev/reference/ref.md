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
#> [1:0x5618ef2d9038] <int> 

y <- list(x, x, x)
ref(y)
#> █ [1:0x5618f1618a78] <list> 
#> ├─[2:0x5618ef2d9038] <int> 
#> ├─[2:0x5618ef2d9038] 
#> └─[2:0x5618ef2d9038] 
ref(x, y)
#> [1:0x5618ef2d9038] <int> 
#>  
#> █ [2:0x5618f1618a78] <list> 
#> ├─[1:0x5618ef2d9038] 
#> ├─[1:0x5618ef2d9038] 
#> └─[1:0x5618ef2d9038] 

e <- new.env()
e$e <- e
e$x <- x
e$y <- list(x, e)
ref(e)
#> █ [1:0x5618eed4ba20] <env> 
#> ├─x = [2:0x5618ef2d9038] <int> 
#> ├─y = █ [3:0x5618f14e8198] <list> 
#> │     ├─[2:0x5618ef2d9038] 
#> │     └─[1:0x5618eed4ba20] 
#> └─e = [1:0x5618eed4ba20] 

# Can also show references to global string pool if requested
ref(c("x", "x", "y"))
#> [1:0x5618f0b10838] <chr> 
ref(c("x", "x", "y"), character = TRUE)
#> █ [1:0x5618f1519928] <chr> 
#> ├─[2:0x5618eaf086c0] <string: "x"> 
#> ├─[2:0x5618eaf086c0] 
#> └─[3:0x5618eb018370] <string: "y"> 
```
