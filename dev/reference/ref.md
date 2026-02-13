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
#> [1:0x561df9d812a0] <int> 

y <- list(x, x, x)
ref(y)
#> █ [1:0x561dfda6ac48] <list> 
#> ├─[2:0x561df9d812a0] <int> 
#> ├─[2:0x561df9d812a0] 
#> └─[2:0x561df9d812a0] 
ref(x, y)
#> [1:0x561df9d812a0] <int> 
#>  
#> █ [2:0x561dfda6ac48] <list> 
#> ├─[1:0x561df9d812a0] 
#> ├─[1:0x561df9d812a0] 
#> └─[1:0x561df9d812a0] 

e <- new.env()
e$e <- e
e$x <- x
e$y <- list(x, e)
ref(e)
#> █ [1:0x561dfe4b7ff0] <env> 
#> ├─x = [2:0x561df9d812a0] <int> 
#> ├─y = █ [3:0x561dfe5b3b88] <list> 
#> │     ├─[2:0x561df9d812a0] 
#> │     └─[1:0x561dfe4b7ff0] 
#> └─e = [1:0x561dfe4b7ff0] 

# Can also show references to global string pool if requested
ref(c("x", "x", "y"))
#> [1:0x561dfe257928] <chr> 
ref(c("x", "x", "y"), character = TRUE)
#> █ [1:0x561dfe254588] <chr> 
#> ├─[2:0x561df7b47f00] <string: "x"> 
#> ├─[2:0x561df7b47f00] 
#> └─[3:0x561df7c72208] <string: "y"> 
```
