#include <Rcpp.h>
using namespace Rcpp;

// [[Rcpp::export]]
std::string prim_type(SEXP x) {
  return std::string(Rf_type2char(TYPEOF(x)));
}
