#include <Rcpp.h>
using namespace Rcpp;

int prim_refs_(SEXP x) {
  return NAMED(x);
}

// [[Rcpp::export]]
int prim_refs_(SEXP name, Environment env) {
  return prim_refs_(Rf_eval(name, env));
}
