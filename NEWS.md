# lobstr 1.0.0.9000

* `ast()` prints scalar integer and complex more accurately (#24)

* `obj_addr()` no longer increments the reference count of its input (#25)

* `obj_size()` now correctly computes size of ALTREP objects on R 3.5.0 (#32)
