#include <Rcpp.h>

// A growable list
class GList {
  bool hasNames_;

  std::vector<Rcpp::RObject> contents_;
  std::vector<std::string> names_;

public:
  GList() : hasNames_(false){
  }

  void reserve(int n) {
    names_.reserve(n);
    contents_.reserve(n);
  }

  void push_back(std::string name, Rcpp::RObject x) {
    hasNames_ = true;
    names_.push_back(name);
    contents_.push_back(x);
  }

  void push_back(const char* name, Rcpp::RObject x) {
    push_back(std::string(name), x);
  }

  void push_back(Rcpp::RObject x) {
    names_.push_back("");
    contents_.push_back(x);
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
    Rcpp::List contents = Rcpp::wrap(contents_);
    if (hasNames_)
      contents.attr("names") = Rcpp::wrap(names_);

    return contents;
  }

};
