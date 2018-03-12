#include <Rcpp.h>
using namespace Rcpp;

// [[Rcpp::export]]
std::string obj_addr_(SEXP x) {
  return tfm::format("%p", x);
}

void frame_addresses(SEXP frame, std::vector<std::string>* refs) {
  for(SEXP cur = frame; cur != R_NilValue; cur = CDR(cur)) {
    SEXP obj = CAR(cur);
    if (obj != R_UnboundValue)
      refs->push_back(obj_addr_(obj));
  }
}
void hash_table_addresses(SEXP table, std::vector<std::string>* refs) {
  int n = Rf_length(table);
  for (int i = 0; i < n; ++i)
    frame_addresses(VECTOR_ELT(table, i), refs);
}

// [[Rcpp::export]]
std::vector<std::string> obj_addrs_(SEXP x) {
  int n = Rf_length(x);
  std::vector<std::string> out;

  switch(TYPEOF(x)) {
  case STRSXP:
    for (int i = 0; i < n; ++i) {
      out.push_back(obj_addr_(STRING_ELT(x, i)));
    }
    break;

  case VECSXP:
    for (int i = 0; i < n; ++i) {
      out.push_back(obj_addr_(VECTOR_ELT(x, i)));
    }
    break;

  case ENVSXP: {
    bool isHashed = HASHTAB(x) != R_NilValue;
    if (isHashed) {
      hash_table_addresses(HASHTAB(x), &out);
    } else {
      frame_addresses(FRAME(x), &out);
    }
    break;
  }

  default:
    Rcpp::stop(
      "`x` must be a list, environment, or character vector, not a %s.",
      Rf_type2char(TYPEOF(x))
    );
  }

  return out;
}
