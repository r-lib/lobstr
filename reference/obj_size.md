# Calculate the size of an object.

`obj_size()` computes the size of an object or set of objects;
`obj_sizes()` breaks down the individual contribution of multiple
objects to the total size.

## Usage

``` r
obj_size(..., env = parent.frame())

obj_sizes(..., env = parent.frame())
```

## Arguments

- ...:

  Set of objects to compute size.

- env:

  Environment in which to terminate search. This defaults to the current
  environment so that you don't include the size of objects that are
  already stored elsewhere.

  Regardless of the value here, `obj_size()` never looks past the global
  or base environments.

## Value

An estimate of the size of the object, in bytes.

## Compared to [`object.size()`](https://rdrr.io/r/utils/object.size.html)

Compared to [`object.size()`](https://rdrr.io/r/utils/object.size.html),
`obj_size()`:

- Accounts for all types of shared values, not just strings in the
  global string pool.

- Includes the size of environments (up to `env`)

- Accurately measures the size of ALTREP objects.

## Environments

`obj_size()` attempts to take into account the size of the environments
associated with an object. This is particularly important for closures
and formulas, since otherwise you may not realise that you've
accidentally captured a large object. However, it's easy to over count:
you don't want to include the size of every object in every environment
leading back to the
[`emptyenv()`](https://rdrr.io/r/base/environment.html). `obj_size()`
takes a heuristic approach: it never counts the size of the global
environment, the base environment, the empty environment, or any
namespace.

Additionally, the `env` argument allows you to specify another
environment at which to stop. This defaults to the environment from
which `obj_size()` is called to prevent double-counting of objects
created elsewhere.

## Examples

``` r
# obj_size correctly accounts for shared references
x <- runif(1e4)
obj_size(x)
#> 80.05 kB

z <- list(a = x, b = x, c = x)
obj_size(z)
#> 80.49 kB

# this means that object size is not transitive
obj_size(x)
#> 80.05 kB
obj_size(z)
#> 80.49 kB
obj_size(x, z)
#> 80.49 kB

# use obj_size() to see the unique contribution of each component
obj_sizes(x, z)
#> * 80.05 kB
#> *    440 B
obj_sizes(z, x)
#> * 80.49 kB
#> *      0 B
obj_sizes(!!!z)
#> a: 80.05 kB
#> b:      0 B
#> c:      0 B

# obj_size() also includes the size of environments
f <- function() {
  x <- 1:1e4
  a ~ b
}
obj_size(f())
#> 1.52 kB

#' # In R 3.5 and greater, `:` creates a special "ALTREP" object that only
# stores the first and last elements. This will make some vectors much
# smaller than you'd otherwise expect
obj_size(1:1e6)
#> 680 B
```
