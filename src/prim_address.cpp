#include <Rcpp.h>
#include "utils.h"
using namespace Rcpp;

std::string prim_address_(SEXP x) {
  return tfm::format("%p", x);
}

// [[Rcpp::export]]
std::string prim_address_(SEXP name, Environment env) {
  return prim_address_(find_var(name, env));
}

int prim_refs_(SEXP x) {
  return NAMED(x);
}

// [[Rcpp::export]]
int prim_refs_(SEXP name, Environment env) {
  return prim_refs_(find_var(name, env));
}
