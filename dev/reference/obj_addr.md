# Find memory location of objects and their children.

`obj_addr()` gives the address of the value that `x` points to;
`obj_addrs()` gives the address of the components the list, environment,
and character vector `x` point to.

## Usage

``` r
obj_addr(x)

obj_addrs(x)
```

## Arguments

- x:

  An object

## Details

`obj_addr()` has been written in such away that it avoids taking
references to an object.

## Examples

``` r
# R creates copies lazily
x <- 1:10
y <- x
obj_addr(x) == obj_addr(y)
#> [1] TRUE

y[1] <- 2L
obj_addr(x) == obj_addr(y)
#> [1] FALSE

y <- runif(10)
obj_addr(y)
#> [1] "0x5618f0efb168"
z <- list(y, y)
obj_addrs(z)
#> [1] "0x5618f0efb168" "0x5618f0efb168"

y[2] <- 1.0
obj_addrs(z)
#> [1] "0x5618f0efb168" "0x5618f0efb168"
obj_addr(y)
#> [1] "0x5618f1aaf458"

# The address of an object is different every time you create it:
obj_addr(1:10)
#> [1] "0x5618f386cb38"
obj_addr(1:10)
#> [1] "0x5618f38c4148"
obj_addr(1:10)
#> [1] "0x5618f391f588"
```
