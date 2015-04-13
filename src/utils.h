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


// Environment length helpers --------------------------------------------------

inline int FrameSize(SEXP frame) {
  int count = 0;

  for(SEXP cur = frame; cur != R_NilValue; cur = CDR(cur)) {
    if (CAR(cur) != R_UnboundValue)
      count++;
  }
  return count;
}

inline  int HashTableSize(SEXP table) {
  int count = 0;
  int n = Rf_length(table);
  for (int i = 0; i < n; ++i)
    count += FrameSize(VECTOR_ELT(table, i));
  return count;
}

inline int envlength(SEXP x) {
  bool isHashed = HASHTAB(x) != R_NilValue;
  return isHashed ? HashTableSize(HASHTAB(x)) : FrameSize(FRAME(x));
}
