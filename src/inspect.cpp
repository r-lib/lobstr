#include <Rcpp.h>
using namespace Rcpp;
#include <Rversion.h>

// [[Rcpp::export]]
Rcpp::List altrep(SEXP x) {
#if defined(R_VERSION) && R_VERSION >= R_Version(3, 5, 0)
    Rcpp::List out(3);
    out.names() = Rcpp::CharacterVector::create("class", "data1", "data2");

    if (ALTREP(x)) {
      out[0] = ALTREP_CLASS(x);
      out[1] = R_altrep_data1(x);
      out[2] = R_altrep_data2(x);
    } else {
      Rcpp::stop("Not an ALTREP");
    }

    return out;
#else
  Rcpp::stop("ALTREP not supported in this version of R");

#endif

}

