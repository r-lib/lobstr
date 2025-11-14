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
#> [1:0x55a78f6c9278] <int> 

y <- list(x, x, x)
ref(y)
#> █ [1:0x55a7927a0788] <list> 
#> ├─[2:0x55a78f6c9278] <int> 
#> ├─[2:0x55a78f6c9278] 
#> └─[2:0x55a78f6c9278] 
ref(x, y)
#> [1:0x55a78f6c9278] <int> 
#>  
#> █ [2:0x55a7927a0788] <list> 
#> ├─[1:0x55a78f6c9278] 
#> ├─[1:0x55a78f6c9278] 
#> └─[1:0x55a78f6c9278] 

e <- new.env()
e$e <- e
e$x <- x
e$y <- list(x, e)
ref(e)
#> █ [1:0x55a78d887e68] <env> 
#> ├─x = [2:0x55a78f6c9278] <int> 
#> ├─y = █ [3:0x55a791cc4458] <list> 
#> │     ├─[2:0x55a78f6c9278] 
#> │     └─[1:0x55a78d887e68] 
#> └─e = [1:0x55a78d887e68] 

# Can also show references to global string pool if requested
ref(c("x", "x", "y"))
#> [1:0x55a792ba62b8] <chr> 
ref(c("x", "x", "y"), character = TRUE)
#> █ [1:0x55a7927faa28] <chr> 
#> ├─[2:0x55a78c7dc2a0] <string: "x"> 
#> ├─[2:0x55a78c7dc2a0] 
#> └─[3:0x55a78c9065a8] <string: "y"> 
```
