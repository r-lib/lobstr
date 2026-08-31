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
#> [1:0x5575e9e7db20] <int> 

y <- list(x, x, x)
ref(y)
#> █ [1:0x5575eb8440b8] <list> 
#> ├─[2:0x5575e9e7db20] <int> 
#> ├─[2:0x5575e9e7db20] 
#> └─[2:0x5575e9e7db20] 
ref(x, y)
#> [1:0x5575e9e7db20] <int> 
#>  
#> █ [2:0x5575eb8440b8] <list> 
#> ├─[1:0x5575e9e7db20] 
#> ├─[1:0x5575e9e7db20] 
#> └─[1:0x5575e9e7db20] 

e <- new.env()
e$e <- e
e$x <- x
e$y <- list(x, e)
ref(e)
#> █ [1:0x5575e98f4060] <env> 
#> ├─x = [2:0x5575e9e7db20] <int> 
#> ├─y = █ [3:0x5575eba28f98] <list> 
#> │     ├─[2:0x5575e9e7db20] 
#> │     └─[1:0x5575e98f4060] 
#> └─e = [1:0x5575e98f4060] 

# Can also show references to global string pool if requested
ref(c("x", "x", "y"))
#> [1:0x5575ebde2108] <chr> 
ref(c("x", "x", "y"), character = TRUE)
#> █ [1:0x5575ec142728] <chr> 
#> ├─[2:0x5575e5a8d6c0] <string: "x"> 
#> ├─[2:0x5575e5a8d6c0] 
#> └─[3:0x5575e5bb7a20] <string: "y"> 
```
