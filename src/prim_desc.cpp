#include <Rcpp.h>
using namespace Rcpp;

// [[Rcpp::export]]
std::string prim_desc_(RObject x) {

  switch(TYPEOF(x)) {

  // Vectors
  case LGLSXP:
  case INTSXP:
  case REALSXP:
  case CPLXSXP:
  case RAWSXP:
  case STRSXP:
  case VECSXP: {
    RObject dim = x.attr("dim");
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

  case SYMSXP:
    return tfm::format("`%s`", CHAR(PRINTNAME(x)));

  default:
    break;

  }

  return "";
}

