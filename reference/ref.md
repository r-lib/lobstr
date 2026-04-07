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
[`src()`](https://lobstr.r-lib.org/reference/src.md),
[`sxp()`](https://lobstr.r-lib.org/reference/sxp.md)

## Examples

``` r
x <- 1:100
ref(x)
#> [1:0x55ef5625cd88] <int> 

y <- list(x, x, x)
ref(y)
#> █ [1:0x55ef5a7b4df8] <list> 
#> ├─[2:0x55ef5625cd88] <int> 
#> ├─[2:0x55ef5625cd88] 
#> └─[2:0x55ef5625cd88] 
ref(x, y)
#> [1:0x55ef5625cd88] <int> 
#>  
#> █ [2:0x55ef5a7b4df8] <list> 
#> ├─[1:0x55ef5625cd88] 
#> ├─[1:0x55ef5625cd88] 
#> └─[1:0x55ef5625cd88] 

e <- new.env()
e$e <- e
e$x <- x
e$y <- list(x, e)
ref(e)
#> █ [1:0x55ef53f536d0] <env> 
#> ├─x = [2:0x55ef5625cd88] <int> 
#> ├─y = █ [3:0x55ef59e94b58] <list> 
#> │     ├─[2:0x55ef5625cd88] 
#> │     └─[1:0x55ef53f536d0] 
#> └─e = [1:0x55ef53f536d0] 

# Can also show references to global string pool if requested
ref(c("x", "x", "y"))
#> [1:0x55ef5b8f6638] <chr> 
ref(c("x", "x", "y"), character = TRUE)
#> █ [1:0x55ef5b8d48b8] <chr> 
#> ├─[2:0x55ef53d6cf00] <string: "x"> 
#> ├─[2:0x55ef53d6cf00] 
#> └─[3:0x55ef53e97208] <string: "y"> 
```
