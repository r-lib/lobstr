#include <Rcpp.h>
#include "utils.h"
using namespace Rcpp;

std::string prim_desc_(SEXP x) {

  switch(TYPEOF(x)) {

  // Vectors
  case LGLSXP:
  case INTSXP:
  case REALSXP:
  case CPLXSXP:
  case RAWSXP:
  case STRSXP:
  case VECSXP: {
    SEXP dim = Rf_getAttrib(x, Rf_install("dim"));
    if (dim == R_NilValue) {
      return tfm::format("[%i]", Rf_length(x));
    } else {
      std::stringstream out;
      int n = Rf_length(dim);
      out << "[";
      for (int i = 0; i < n; ++i) {
        out << INTEGER(dim)[i];
        if (i != n - 1)
          out << " x ";
      }
      out << "]";
      return out.str();
    }

    break;
  }

  case EXTPTRSXP:
    return tfm::format("<%s>", x);

  case SYMSXP:
    return tfm::format("`%s`", CHAR(PRINTNAME(x)));

  default:
    break;

  }

  return "";
}


// [[Rcpp::export]]
std::string prim_desc_(SEXP name, Environment env) {
  return prim_desc_(find_var(name, env));
}
