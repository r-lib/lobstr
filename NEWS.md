# lobstr 1.2.1

* Fixes for CRAN checks.

# lobstr 1.2.0

* New `src()` function for exploring srcref and srcfile objects. We've
  documented all we know about srcrefs in `?src`.

* `obj_size()`, `obj_addrs()`, and `sxp()` no longer error with "bad binding
  access" when inspecting environments with non-standard bindings such as
  those created by `for` loops or immediate bindings (#48).

* `sxp(expand = "environment")` no longer shows the internal `_frame` and
  `_hashtab` structures. Instead, it now shows promise expressions without
  forcing them. This change was necessary to make lobstr compliant with R's
  public C API.

* General progress towards conformance to the public C API of R.

# lobstr 1.1.3

* Changes for compliance with R's public API. The main consequence is that lobstr no longer reports the `truelength` property of vectors.

  We also changed the `named` indicator to `refs:n`, where `n` can take the values: `0` (corresponding to `NO_REFERENCES` returning 1), `1` (corresponding to both `NO_REFERENCES` `MAYBE_SHARED` returning 0), and `2+` (`MAYBE_SHARED` returning 1).

# lobstr 1.1.2

* Switched to cpp11 from Rcpp.

* Relicensed as MIT (#51).

* `obj_size()` and `sxp()` now support non-nil terminated pairlists.

* `obj_size()` now displays large objects with KB, MB, etc (#57, #60),
  and no longer returns NA for objects larger than 2^31 bytes (#45).

* `obj_sizes()` now computes relative sizes correctly (without meaningless
  floating point differences).

* `ref()` lists all contents of environments even those with names beginning
  with `.` (@krlmlr, #53).

* New, experimental `tree()` function as alternative to `str()` (#56).

# lobstr 1.1.1

* Fix PROTECT error.

* Remove UTF-8 characters from comments

# lobstr 1.1.0

* `ref()` now handles custom classes properly (@yutannihilation, #36)

* `sxp()` is a new tool for displaying the underlying C representation
  of an object (#38).

* `obj_size()` now special cases the ALTREP "deferred string vectors" which
  previously crashed due to the way in which they abuse the pairlist type
  (#35).

# lobstr 1.0.1

* `ast()` prints scalar integer and complex more accurately (#24)

* `obj_addr()` no longer increments the reference count of its input (#25)

* `obj_size()` now correctly computes size of ALTREP objects on R 3.5.0 (#32)
