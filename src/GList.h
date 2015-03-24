#include <Rcpp.h>

// A growable list
class GList {
  Rcpp::List contents_;
  Rcpp::CharacterVector names_;
  int i_, n_;

public:
  GList(int n = 10): i_(0), n_(n) {
    contents_ = Rcpp::List(n);
    names_ = Rcpp::CharacterVector(n, "");
  }

  void resize(int n) {
    n_ = n;
    contents_ = Rf_lengthgets(contents_, n_);
    names_ = Rf_lengthgets(names_, n_);
  }

  void grow() {
    resize(3 / 2 * n_ + 1);
  }

  void push_back(std::string name, Rcpp::RObject x) {
    if (i_ >= n_)
      grow();

    names_[i_] = name;
    contents_[i_] = x;
    ++i_;
  }

  void push_back(const char* name, Rcpp::RObject x) {
    push_back(std::string(name), x);
  }

  void push_back(Rcpp::RObject x) {
    if (i_ >= n_)
      grow();

    contents_[i_] = x;
    ++i_;
  }

  void push_back(Rcpp::RObject name, Rcpp::RObject x) {
    if (name == R_NilValue) {
      push_back(x);
      return;
    }

    if (TYPEOF(name) != SYMSXP)
      Rcpp::stop("Expecting SYMSXP, got %s", Rf_type2char(TYPEOF(name)));

    SEXP printname = PRINTNAME(name);
    push_back((printname == R_NilValue) ? "" : CHAR(printname), x);
  }

  Rcpp::List list() {
    Rcpp::List contents = Rf_lengthgets(contents_, i_);
    contents.attr("names") = Rf_lengthgets(names_, i_);

    return contents;
  }

};
