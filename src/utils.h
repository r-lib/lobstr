#include <cpp11/R.hpp>
#include <sstream>

inline std::string obj_addr_(SEXP x) {
  std::stringstream ss;
  ss << static_cast<void *>(x);
  return ss.str();
}

static inline
bool is_linked_list(SEXP x) {
  switch (TYPEOF(x)) {
  case DOTSXP:
  case LISTSXP:
  case LANGSXP:
    return true;
  default:
    return false;
  }
}

// Rf_length() crashes on flexible cells
static inline
R_xlen_t sxp_length(SEXP x) {
  if (TYPEOF(x) == LISTSXP) {
    R_xlen_t i = 0;
    while (is_linked_list(x)) {
      ++i;
      x = CDR(x);
    }
    return i;
  } else {
    return Rf_length(x);
  }
}
