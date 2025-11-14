# Changelog

## lobstr 1.1.3

CRAN release: 2025-11-14

- Changes for compliance with R’s public API. The main consequence is
  that lobstr no longer reports the `truelength` property of vectors.

  We also changed the `named` indicator to `refs:n`, where `n` can take
  the values: `0` (corresponding to `NO_REFERENCES` returning 1), `1`
  (corresponding to both `NO_REFERENCES` `MAYBE_SHARED` returning 0),
  and `2+` (`MAYBE_SHARED` returning 1).

## lobstr 1.1.2

CRAN release: 2022-06-22

- Switched to cpp11 from Rcpp.

- Relicensed as MIT ([\#51](https://github.com/r-lib/lobstr/issues/51)).

- [`obj_size()`](https://lobstr.r-lib.org/reference/obj_size.md) and
  [`sxp()`](https://lobstr.r-lib.org/reference/sxp.md) now support
  non-nil terminated pairlists.

- [`obj_size()`](https://lobstr.r-lib.org/reference/obj_size.md) now
  displays large objects with KB, MB, etc
  ([\#57](https://github.com/r-lib/lobstr/issues/57),
  [\#60](https://github.com/r-lib/lobstr/issues/60)), and no longer
  returns NA for objects larger than 2^31 bytes
  ([\#45](https://github.com/r-lib/lobstr/issues/45)).

- [`obj_sizes()`](https://lobstr.r-lib.org/reference/obj_size.md) now
  computes relative sizes correctly (without meaningless floating point
  differences).

- [`ref()`](https://lobstr.r-lib.org/reference/ref.md) lists all
  contents of environments even those with names beginning with `.`
  ([@krlmlr](https://github.com/krlmlr),
  [\#53](https://github.com/r-lib/lobstr/issues/53)).

- New, experimental
  [`tree()`](https://lobstr.r-lib.org/reference/tree.md) function as
  alternative to [`str()`](https://rdrr.io/r/utils/str.html)
  ([\#56](https://github.com/r-lib/lobstr/issues/56)).

## lobstr 1.1.1

CRAN release: 2019-07-02

- Fix PROTECT error.

- Remove UTF-8 characters from comments

## lobstr 1.1.0

CRAN release: 2019-06-19

- [`ref()`](https://lobstr.r-lib.org/reference/ref.md) now handles
  custom classes properly
  ([@yutannihilation](https://github.com/yutannihilation),
  [\#36](https://github.com/r-lib/lobstr/issues/36))

- [`sxp()`](https://lobstr.r-lib.org/reference/sxp.md) is a new tool for
  displaying the underlying C representation of an object
  ([\#38](https://github.com/r-lib/lobstr/issues/38)).

- [`obj_size()`](https://lobstr.r-lib.org/reference/obj_size.md) now
  special cases the ALTREP “deferred string vectors” which previously
  crashed due to the way in which they abuse the pairlist type
  ([\#35](https://github.com/r-lib/lobstr/issues/35)).

## lobstr 1.0.1

CRAN release: 2018-12-21

- [`ast()`](https://lobstr.r-lib.org/reference/ast.md) prints scalar
  integer and complex more accurately
  ([\#24](https://github.com/r-lib/lobstr/issues/24))

- [`obj_addr()`](https://lobstr.r-lib.org/reference/obj_addr.md) no
  longer increments the reference count of its input
  ([\#25](https://github.com/r-lib/lobstr/issues/25))

- [`obj_size()`](https://lobstr.r-lib.org/reference/obj_size.md) now
  correctly computes size of ALTREP objects on R 3.5.0
  ([\#32](https://github.com/r-lib/lobstr/issues/32))
