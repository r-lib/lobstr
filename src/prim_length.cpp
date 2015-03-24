#include <Rcpp.h>
#include "utils.h"
using namespace Rcpp;

// [[Rcpp::export]]
int prim_length(SEXP x) {
  int n = 0;

  switch(TYPEOF(x)) {

  case NILSXP:
  case BUILTINSXP:
  case SPECIALSXP:
  case SYMSXP:
  case CHARSXP:
  case WEAKREFSXP:
  case S4SXP:
  case LGLSXP:
  case INTSXP:
  case REALSXP:
  case CPLXSXP:
  case RAWSXP:
  case STRSXP:
    break;

  case EXTPTRSXP: // prot + tag
    n = 2;
    break;

  case CLOSXP:    // body + env + args
  case PROMSXP:   // expr + env + value
    n = 3;
    break;

  case VECSXP:
  case LANGSXP:
  case EXPRSXP:
  case LISTSXP:
  case BCODESXP:
    n = Rf_length(x);
    break;

  case ENVSXP:
    n = envlength(x) + (ENCLOS(x) != R_EmptyEnv);
    break;

  default:
    warning("Unimplemented type %s", Rf_type2char(TYPEOF(x)));
    break;
  }

  n += hasAttrib(x);
  return n;
}
