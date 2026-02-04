#include "utils.h"
#include <cpp11/environment.hpp>
#include <cpp11/sexp.hpp>
#include <vector>

extern "C" {
#include <rlang.h>
}

[[cpp11::register]]
std::string obj_addr_(SEXP name, cpp11::environment env) {
  return obj_addr_(Rf_eval(name, env));
}



[[cpp11::register]]
std::vector<std::string> obj_addrs_(SEXP x) {
  int n = Rf_length(x);
  std::vector<std::string> out;

  switch(TYPEOF(x)) {
  case STRSXP:
    for (int i = 0; i < n; ++i) {
      out.push_back(obj_addr_(STRING_ELT(x, i)));
    }
    break;

  case VECSXP:
    for (int i = 0; i < n; ++i) {
      out.push_back(obj_addr_(VECTOR_ELT(x, i)));
    }
    break;

  case ENVSXP: {
    cpp11::sexp syms(r_env_syms(x));
    R_xlen_t n_bindings = Rf_xlength(syms);

    for (R_xlen_t i = 0; i < n_bindings; ++i) {
      SEXP sym = VECTOR_ELT(syms, i);
      enum r_env_binding_type type = r_env_binding_type(x, sym);

      switch (type) {
      case R_ENV_BINDING_TYPE_missing:
        break;

      case R_ENV_BINDING_TYPE_value:
        out.push_back(obj_addr_(r_env_get(x, sym)));
        break;

      case R_ENV_BINDING_TYPE_delayed:
        out.push_back(obj_addr_(r_env_binding_delayed_expr(x, sym)));
        break;

      case R_ENV_BINDING_TYPE_forced:
        out.push_back(obj_addr_(r_env_binding_forced_value(x, sym)));
        break;

      case R_ENV_BINDING_TYPE_active:
        out.push_back(obj_addr_(r_env_binding_active_fn(x, sym)));
        break;

      case R_ENV_BINDING_TYPE_unbound:
        break;
      }
    }
    break;
  }

  default:
    cpp11::stop(
      "`x` must be a list, environment, or character vector, not a %s.",
      Rf_type2char(TYPEOF(x))
    );
  }

  return out;
}
