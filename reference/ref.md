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
#> [1:0x55e355073db8] <int> 

y <- list(x, x, x)
ref(y)
#> █ [1:0x55e358c17af8] <list> 
#> ├─[2:0x55e355073db8] <int> 
#> ├─[2:0x55e355073db8] 
#> └─[2:0x55e355073db8] 
ref(x, y)
#> [1:0x55e355073db8] <int> 
#>  
#> █ [2:0x55e358c17af8] <list> 
#> ├─[1:0x55e355073db8] 
#> ├─[1:0x55e355073db8] 
#> └─[1:0x55e355073db8] 

e <- new.env()
e$e <- e
e$x <- x
e$y <- list(x, e)
ref(e)
#> █ [1:0x55e352d67940] <env> 
#> ├─x = [2:0x55e355073db8] <int> 
#> ├─y = █ [3:0x55e359393fb8] <list> 
#> │     ├─[2:0x55e355073db8] 
#> │     └─[1:0x55e352d67940] 
#> └─e = [1:0x55e352d67940] 

# Can also show references to global string pool if requested
ref(c("x", "x", "y"))
#> [1:0x55e35a70bcf8] <chr> 
ref(c("x", "x", "y"), character = TRUE)
#> █ [1:0x55e35a6fcde8] <chr> 
#> ├─[2:0x55e352b81f00] <string: "x"> 
#> ├─[2:0x55e352b81f00] 
#> └─[3:0x55e352cadac8] <string: "y"> 
```
