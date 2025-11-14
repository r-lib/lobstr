# Display the abstract syntax tree

This is a useful alternative to
[`str()`](https://rdrr.io/r/utils/str.html) for expression objects.

## Usage

``` r
ast(x)
```

## Arguments

- x:

  An expression to display. Input is automatically quoted, use `!!` to
  unquote if you have already captured an expression object.

## See also

Other object inspectors:
[`ref()`](https://lobstr.r-lib.org/reference/ref.md),
[`sxp()`](https://lobstr.r-lib.org/reference/sxp.md)

## Examples

``` r
# Leaves
ast(1)
#> 1 
ast(x)
#> x 

# Simple calls
ast(f())
#> █─f 
ast(f(x, 1, g(), h(i())))
#> █─f 
#> ├─x 
#> ├─1 
#> ├─█─g 
#> └─█─h 
#>   └─█─i 
ast(f()())
#> █─█─f 
ast(f(x)(y))
#> █─█─f 
#> │ └─x 
#> └─y 

ast((x + 1))
#> █─`(` 
#> └─█─`+` 
#>   ├─x 
#>   └─1 

# Displaying expression already stored in object
x <- quote(a + b + c)
ast(x)
#> x 
ast(!!x)
#> █─`+` 
#> ├─█─`+` 
#> │ ├─a 
#> │ └─b 
#> └─c 

# All operations have this same structure
ast(if (TRUE) 3 else 4)
#> █─`if` 
#> ├─TRUE 
#> ├─3 
#> └─4 
ast(y <- x * 10)
#> █─`<-` 
#> ├─y 
#> └─█─`*` 
#>   ├─x 
#>   └─10 
ast(function(x = 1, y = 2) { x + y } )
#> █─`function` 
#> ├─█─x = 1 
#> │ └─y = 2 
#> ├─█─`{` 
#> │ └─█─`+` 
#> │   ├─x 
#> │   └─y 
#> └─NULL 

# Operator precedence
ast(1 * 2 + 3)
#> █─`+` 
#> ├─█─`*` 
#> │ ├─1 
#> │ └─2 
#> └─3 
ast(!1 + !1)
#> █─`!` 
#> └─█─`+` 
#>   ├─1 
#>   └─█─`!` 
#>     └─1 
```
