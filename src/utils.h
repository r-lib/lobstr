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
