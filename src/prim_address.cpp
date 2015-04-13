#include <Rcpp.h>
#include "utils.h"
using namespace Rcpp;

// [[Rcpp::export]]
std::string prim_address_(SEXP name, Environment env) {
  SEXP x = find_var(name, env);

  std::ostringstream s;
  s << x;
  return s.str();
}

// [[Rcpp::export]]
int prim_refs_(SEXP name, Environment env) {
  SEXP x = find_var(name, env);

  return NAMED(x);
}
