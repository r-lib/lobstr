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
#> [1] "0x55a94b952348"
z <- list(y, y)
obj_addrs(z)
#> [1] "0x55a94b952348" "0x55a94b952348"

y[2] <- 1.0
obj_addrs(z)
#> [1] "0x55a94b952348" "0x55a94b952348"
obj_addr(y)
#> [1] "0x55a94ca404d8"

# The address of an object is different every time you create it:
obj_addr(1:10)
#> [1] "0x55a94f1ffca8"
obj_addr(1:10)
#> [1] "0x55a94f257398"
obj_addr(1:10)
#> [1] "0x55a94f2b28b8"
```
