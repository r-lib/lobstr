# How much memory is currently used by R?

`mem_used()` wraps around [`gc()`](https://rdrr.io/r/base/gc.html) and
returns the exact number of bytes currently used by R. Note that changes
will not match up exactly to
[`obj_size()`](https://lobstr.r-lib.org/dev/reference/obj_size.md) as
session specific state (e.g.
[.Last.value](https://rdrr.io/r/base/Last.value.html)) adds minor
variations.

## Usage

``` r
mem_used()
```

## Examples

``` r
prev_m <- 0; m <- mem_used(); m - prev_m
#> 69.75 MB

x <- 1:1e6
prev_m <- m; m <- mem_used(); m - prev_m
#> 84.11 kB
obj_size(x)
#> 680 B

rm(x)
prev_m <- m; m <- mem_used(); m - prev_m
#> 37.32 kB

prev_m <- m; m <- mem_used(); m - prev_m
#> 616 B
```
