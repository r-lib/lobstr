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
#> [1:0x55cfc823ca08] <int> 

y <- list(x, x, x)
ref(y)
#> █ [1:0x55cfcbce2578] <list> 
#> ├─[2:0x55cfc823ca08] <int> 
#> ├─[2:0x55cfc823ca08] 
#> └─[2:0x55cfc823ca08] 
ref(x, y)
#> [1:0x55cfc823ca08] <int> 
#>  
#> █ [2:0x55cfcbce2578] <list> 
#> ├─[1:0x55cfc823ca08] 
#> ├─[1:0x55cfc823ca08] 
#> └─[1:0x55cfc823ca08] 

e <- new.env()
e$e <- e
e$x <- x
e$y <- list(x, e)
ref(e)
#> █ [1:0x55cfc5f8c7e8] <env> 
#> ├─x = [2:0x55cfc823ca08] <int> 
#> ├─y = █ [3:0x55cfcbeb8008] <list> 
#> │     ├─[2:0x55cfc823ca08] 
#> │     └─[1:0x55cfc5f8c7e8] 
#> └─e = [1:0x55cfc5f8c7e8] 

# Can also show references to global string pool if requested
ref(c("x", "x", "y"))
#> [1:0x55cfcd9d63d8] <chr> 
ref(c("x", "x", "y"), character = TRUE)
#> █ [1:0x55cfcd92d9b8] <chr> 
#> ├─[2:0x55cfc5dcaf00] <string: "x"> 
#> ├─[2:0x55cfc5dcaf00] 
#> └─[3:0x55cfc5ef5208] <string: "y"> 
```
