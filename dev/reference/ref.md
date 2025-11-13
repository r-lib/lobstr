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
#> [1:0x5557532b37e8] <int> 

y <- list(x, x, x)
ref(y)
#> █ [1:0x5557569d2c68] <list> 
#> ├─[2:0x5557532b37e8] <int> 
#> ├─[2:0x5557532b37e8] 
#> └─[2:0x5557532b37e8] 
ref(x, y)
#> [1:0x5557532b37e8] <int> 
#>  
#> █ [2:0x5557569d2c68] <list> 
#> ├─[1:0x5557532b37e8] 
#> ├─[1:0x5557532b37e8] 
#> └─[1:0x5557532b37e8] 

e <- new.env()
e$e <- e
e$x <- x
e$y <- list(x, e)
ref(e)
#> █ [1:0x5557514e1ac0] <env> 
#> ├─x = [2:0x5557532b37e8] <int> 
#> ├─y = █ [3:0x5557553300f8] <list> 
#> │     ├─[2:0x5557532b37e8] 
#> │     └─[1:0x5557514e1ac0] 
#> └─e = [1:0x5557514e1ac0] 

# Can also show references to global string pool if requested
ref(c("x", "x", "y"))
#> [1:0x5557564dce68] <chr> 
ref(c("x", "x", "y"), character = TRUE)
#> █ [1:0x5557566f8548] <chr> 
#> ├─[2:0x5557504032a0] <string: "x"> 
#> ├─[2:0x5557504032a0] 
#> └─[3:0x55575052d5a8] <string: "y"> 
```
