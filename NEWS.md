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
