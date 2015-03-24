#include <Rcpp.h>
#include "utils.h"
using namespace Rcpp;

// [[Rcpp::export]]
std::string prim_address_(SEXP x) {
  std::ostringstream s;
  s << x;
  return s.str();
}
