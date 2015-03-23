#include <Rcpp.h>
#include "GList.h"
#include "utils.h"
using namespace Rcpp;

// [[Rcpp::export]]
RObject prim_children_(SEXP x) {
  GList out;

  switch(TYPEOF(x)) {

  // No children and can't have attributes
  case NILSXP:
  case BUILTINSXP:
  case SPECIALSXP:
  case SYMSXP:
  case CHARSXP:
  case WEAKREFSXP:
    break;

  // Atomic vectors
  case LGLSXP:
  case INTSXP:
  case REALSXP:
  case CPLXSXP:
  case RAWSXP:
  case STRSXP:
    if (hasAttrib(x))
      out.push_back("__attributes", ATTRIB(x));
    break;

  case CLOSXP:    // body + env + args
    out.push_back("__body", BODY(x));
    out.push_back("__formals", FORMALS(x));
    out.push_back("__enclosure", CLOENV(x));
    if (hasAttrib(x))
      out.push_back("__attributes", ATTRIB(x));
    break;

  default:
    warning("Unimplemented type %s", prim_type(x));

//   case CLOSXP:    // body + env + args
//   case PROMSXP:   // expr + env + value
//   case EXTPTRSXP: // pointer + prot + tag
//     return 3;
//
//   case VECSXP:
//     return Rf_length(x) + hasAttrib(x);
//
//   case LANGSXP:
//     return Rf_length(x) - 1;
//
//   case EXPRSXP:
//   case LISTSXP:
//   case BCODESXP:
//   case S4SXP:
//     return Rf_length(x);
//
//   case ENVSXP:
//     return envlength(x) + (ENCLOS(x) != R_EmptyEnv) + hasAttrib(x);
  }

  return out.list();
}
