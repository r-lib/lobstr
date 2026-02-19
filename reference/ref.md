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
#> [1:0x55b19d01da10] <int> 

y <- list(x, x, x)
ref(y)
#> █ [1:0x55b1a08ca928] <list> 
#> ├─[2:0x55b19d01da10] <int> 
#> ├─[2:0x55b19d01da10] 
#> └─[2:0x55b19d01da10] 
ref(x, y)
#> [1:0x55b19d01da10] <int> 
#>  
#> █ [2:0x55b1a08ca928] <list> 
#> ├─[1:0x55b19d01da10] 
#> ├─[1:0x55b19d01da10] 
#> └─[1:0x55b19d01da10] 

e <- new.env()
e$e <- e
e$x <- x
e$y <- list(x, e)
ref(e)
#> █ [1:0x55b19adafda0] <env> 
#> ├─x = [2:0x55b19d01da10] <int> 
#> ├─y = █ [3:0x55b1a2614e78] <list> 
#> │     ├─[2:0x55b19d01da10] 
#> │     └─[1:0x55b19adafda0] 
#> └─e = [1:0x55b19adafda0] 

# Can also show references to global string pool if requested
ref(c("x", "x", "y"))
#> [1:0x55b1a2733048] <chr> 
ref(c("x", "x", "y"), character = TRUE)
#> █ [1:0x55b1a2675478] <chr> 
#> ├─[2:0x55b19ab06f00] <string: "x"> 
#> ├─[2:0x55b19ab06f00] 
#> └─[3:0x55b19ac31208] <string: "y"> 
```
