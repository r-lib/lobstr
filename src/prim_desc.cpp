#include <Rcpp.h>
using namespace Rcpp;

//' A brief description of an object.
//'
//' \code{prim_desc()} describes the primitive R object. \code{user_desc()}
//' is an S3 method that object creators can override to provide better
//' navigation
//'
//' @param x An object to describe
//' @export
//' @examples
//' prim_desc(1:100)
//' prim_desc(quote(a))
// [[Rcpp::export]]
std::string prim_desc(SEXP x) {

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

