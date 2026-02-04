#include <cpp11.hpp>

extern "C" {
#include <rlang.h>
}

[[cpp11::register]]
void init_library(SEXP env) {
  r_init_library(env);
}
