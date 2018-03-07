#include <Rcpp.h>
using namespace Rcpp;

int prim_refs_(SEXP x) {
  return NAMED(x);
}

// [[Rcpp::export]]
int prim_refs_(SEXP name, Environment env) {
  return prim_refs_(Rf_eval(name, env));
}

void frame_refs(SEXP frame, std::vector<int>* refs) {
  for(SEXP cur = frame; cur != R_NilValue; cur = CDR(cur)) {
    SEXP obj = CAR(cur);
    if (obj != R_UnboundValue)
      refs->push_back(prim_refs_(obj));
  }
}
void hash_table_refs(SEXP table, std::vector<int>* refs) {
  int n = Rf_length(table);
  for (int i = 0; i < n; ++i)
    frame_refs(VECTOR_ELT(table, i), refs);
}

std::vector<int> prim_refss_(SEXP x) {
  int n = Rf_length(x);
  std::vector<int> out;

  switch(TYPEOF(x)) {
  case STRSXP:
    for (int i = 0; i < n; ++i) {
      out.push_back(prim_refs_(STRING_ELT(x, i)));
    }
    break;

  case VECSXP:
    for (int i = 0; i < n; ++i) {
      out.push_back(prim_refs_(VECTOR_ELT(x, i)));
    }
    break;

  case ENVSXP: {
    bool isHashed = HASHTAB(x) != R_NilValue;
    if (isHashed) {
      hash_table_refs(HASHTAB(x), &out);
    } else {
      frame_refs(FRAME(x), &out);
    }
    break;
  }

  default:
    Rcpp::stop("type not supported");
  }

  return out;
}

// [[Rcpp::export]]
std::vector<int> prim_refss_(SEXP name, Environment env) {
  return prim_refss_(Rf_eval(name, env));
}

