#include <cpp11/R.hpp>
#include <sstream>

inline std::string obj_addr_(SEXP x) {
  std::stringstream ss;
  ss << static_cast<void *>(x);
  return ss.str();
}
