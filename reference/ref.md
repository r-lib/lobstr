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
[`ast()`](https://lobstr.r-lib.org/reference/ast.md),
[`sxp()`](https://lobstr.r-lib.org/reference/sxp.md)

## Examples

``` r
x <- 1:100
ref(x)
#> [1:0x561b66d64b68] <int> 

y <- list(x, x, x)
ref(y)
#> █ [1:0x561b69d27fe8] <list> 
#> ├─[2:0x561b66d64b68] <int> 
#> ├─[2:0x561b66d64b68] 
#> └─[2:0x561b66d64b68] 
ref(x, y)
#> [1:0x561b66d64b68] <int> 
#>  
#> █ [2:0x561b69d27fe8] <list> 
#> ├─[1:0x561b66d64b68] 
#> ├─[1:0x561b66d64b68] 
#> └─[1:0x561b66d64b68] 

e <- new.env()
e$e <- e
e$x <- x
e$y <- list(x, e)
ref(e)
#> █ [1:0x561b64c8b0f8] <env> 
#> ├─x = [2:0x561b66d64b68] <int> 
#> ├─y = █ [3:0x561b6a024bb8] <list> 
#> │     ├─[2:0x561b66d64b68] 
#> │     └─[1:0x561b64c8b0f8] 
#> └─e = [1:0x561b64c8b0f8] 

# Can also show references to global string pool if requested
ref(c("x", "x", "y"))
#> [1:0x561b69da56f8] <chr> 
ref(c("x", "x", "y"), character = TRUE)
#> █ [1:0x561b69934eb8] <chr> 
#> ├─[2:0x561b63deb2a0] <string: "x"> 
#> ├─[2:0x561b63deb2a0] 
#> └─[3:0x561b63f155a8] <string: "y"> 
```
