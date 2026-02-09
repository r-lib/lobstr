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

#if R_VERSION < R_Version(4, 5, 0)
static inline
SEXP R_ParentEnv(SEXP x) {
  return ENCLOS(x);
}

static inline
int ANY_ATTRIB(SEXP x) {
  return ATTRIB(x) != R_NilValue;
}
#endif

#if R_VERSION < R_Version(4, 6, 0)
// Polyfill for R_mapAttrib(), available in R >= 4.6.0.
// Pulled exactly as-is from R:
// https://github.com/r-devel/r-svn/blob/a39f4a28848fd02a1310b455353a871f2bb1965b/src/main/attrib.c#L2014
// https://github.com/r-devel/r-svn/blob/a39f4a28848fd02a1310b455353a871f2bb1965b/doc/manual/R-exts.texi#L17920
static inline
SEXP R_mapAttrib(SEXP x, SEXP (*FUN)(SEXP, SEXP, void *), void *data) {
  PROTECT_INDEX api;
  SEXP a = ATTRIB(x);
  SEXP val = NULL;

  PROTECT_WITH_INDEX(a, &api);
  while (a != R_NilValue) {
    SEXP tag = PROTECT(TAG(a));
    SEXP attr = PROTECT(CAR(a));
    val = FUN(tag, attr, data);
    UNPROTECT(2);
    if (val != NULL)
      break;
    REPROTECT(a = CDR(a), api);
  }
  UNPROTECT(1);
  return val;
}
#endif

SEXP collect_attribs(SEXP x);
