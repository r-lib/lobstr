#include <Rcpp.h>
#include "utils.h"
using namespace Rcpp;

// [[Rcpp::export]]
int prim_length(SEXP x) {
  switch(TYPEOF(x)) {

  // No children and can't have attributes
  case NILSXP:
  case BUILTINSXP:
  case SPECIALSXP:
  case SYMSXP:
  case CHARSXP:
  case WEAKREFSXP:
    return 0;

  // Atomic vectors
  case LGLSXP:
  case INTSXP:
  case REALSXP:
  case CPLXSXP:
  case RAWSXP:
  case STRSXP:
    return hasAttrib(x);

  case CLOSXP:    // body + env + args
  case PROMSXP:   // expr + env + value
  case EXTPTRSXP: // pointer + prot + tag
    return 3;

  case VECSXP:
    return Rf_length(x) + hasAttrib(x);

  case LANGSXP:
    return Rf_length(x) - 1;

  case EXPRSXP:
  case LISTSXP:
  case BCODESXP:
  case S4SXP:
    return Rf_length(x);

  case ENVSXP:
    return envlength(x) + (ENCLOS(x) != R_EmptyEnv) + hasAttrib(x);

  default:
    break;
  }

  stop("Unimplemented type %s", prim_type(x));
  return 0;
}
