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
#> [1:0x5653bcd05138] <int> 

y <- list(x, x, x)
ref(y)
#> █ [1:0x5653c107aea8] <list> 
#> ├─[2:0x5653bcd05138] <int> 
#> ├─[2:0x5653bcd05138] 
#> └─[2:0x5653bcd05138] 
ref(x, y)
#> [1:0x5653bcd05138] <int> 
#>  
#> █ [2:0x5653c107aea8] <list> 
#> ├─[1:0x5653bcd05138] 
#> ├─[1:0x5653bcd05138] 
#> └─[1:0x5653bcd05138] 

e <- new.env()
e$e <- e
e$x <- x
e$y <- list(x, e)
ref(e)
#> █ [1:0x5653c13f3040] <env> 
#> ├─x = [2:0x5653bcd05138] <int> 
#> ├─y = █ [3:0x5653c0cc8da8] <list> 
#> │     ├─[2:0x5653bcd05138] 
#> │     └─[1:0x5653c13f3040] 
#> └─e = [1:0x5653c13f3040] 

# Can also show references to global string pool if requested
ref(c("x", "x", "y"))
#> [1:0x5653c0695e18] <chr> 
ref(c("x", "x", "y"), character = TRUE)
#> █ [1:0x5653c07b7b18] <chr> 
#> ├─[2:0x5653baafbf00] <string: "x"> 
#> ├─[2:0x5653baafbf00] 
#> └─[3:0x5653bac26208] <string: "y"> 
```
