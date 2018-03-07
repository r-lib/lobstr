#include <Rcpp.h>

inline bool hasAttrib(SEXP x) {
  return Rf_length(ATTRIB(x)) > 0;
}

// -----------------------------------------------------------------------------
// Get the SEXP corresponding to an argument with adding an extra reference

inline SEXP promise_value(SEXP promise, Rcpp::Environment env) {
  // recurse until we find the top-level promise, not a promise of a promise etc
  while(TYPEOF(promise) == PROMSXP) {
    if (PRENV(promise) == R_NilValue) {
      return PRVALUE(promise);
    }

    env = PRENV(promise);
    promise = PREXPR(promise);

    // If the promise is threaded through multiple functions, we'll
    // get some symbols along the way. If the symbol is bound to a promise
    // keep going on up
    if (TYPEOF(promise) == SYMSXP) {
      SEXP obj = Rf_findVar(promise, env);
      if (TYPEOF(obj) == PROMSXP) {
        promise = obj;
      }
    }
  }

  return Rf_eval(promise, env);
}

inline SEXP find_var(SEXP name, Rcpp::Environment env) {
  SEXP promise = Rf_findVar(name, env);

  return promise_value(promise, env);
}
