#include <Rcpp.h>
using namespace Rcpp;
#include <Rversion.h>

// sexpinfo increased in 3.5.0
// https://github.com/wch/r-source/commit/14db43282d12932dfa56eb480a5ef92d1d95b102
#if defined(R_VERSION) && R_VERSION >= R_Version(3, 5, 0)
  static const int sexpinfo_size = 64 / 8;
#else
  static const int sexpinfo_size = 32 / 8;
#endif

// [[Rcpp::export]]
double v_size(double n, int size) {
  if (n == 0)
    return 2 * sizeof(double);

  double vec_size = std::max(sizeof(SEXP), sizeof(double));
  double elements_per_byte = vec_size / size;
  double n_bytes = ceil(n / elements_per_byte);
  // Rcout << n << " elements, each of " << elements_per_byte << " = " <<
  //  n_bytes << "\n";

  double bytes = 0;
  // Big vectors always allocated in 8 byte chunks
  if      (n_bytes > 16) bytes = n_bytes * 8;
  // For small vectors, round to sizes allocated in small vector pool
  else if (n_bytes > 8)  bytes = 128;
  else if (n_bytes > 6)  bytes = 64;
  else if (n_bytes > 4)  bytes = 48;
  else if (n_bytes > 2)  bytes = 32;
  else if (n_bytes > 1)  bytes = 16;
  else if (n_bytes > 0)  bytes = 8;

  // Size is pointer to struct (two lengths) + struct size
  return 2 * sizeof(double) + bytes;
}

bool is_namespace(Environment env) {
  return Rf_findVarInFrame3(env, Rf_install(".__NAMESPACE__."), FALSE) != R_UnboundValue;
}

// R equivalent
// https://github.com/wch/r-source/blob/master/src/library/utils/src/size.c#L41

double obj_size_tree(SEXP x, Environment base_env, std::set<SEXP>& seen) {
  // NILSXP is a singleton, so occupies no space. Similarly SPECIAL and
  // BUILTIN are fixed and unchanging
  if (TYPEOF(x) == NILSXP ||
    TYPEOF(x) == SPECIALSXP ||
    TYPEOF(x) == BUILTINSXP) return 0;

  // Don't count objects that we've seen before
  if (!seen.insert(x).second) return 0;

  // All objects start with a standard header: SEXPREC_HEADER
  // https://github.com/wch/r-source/blob/master/src/include/Rinternals.h#L232-L235
  // This includes the sxpinfo_struct
  double size = sexpinfo_size;
  // And a pointer to attributes
  size += sizeof(SEXP);
  size += obj_size_tree(ATTRIB(x), base_env, seen);
  // Followed by two pointers used to create a doubly linked list used by GC
  size += 2 * sizeof(SEXP);

  switch (TYPEOF(x)) {
  // Vectors -------------------------------------------------------------------
  // See details in v_size()

  // Simple vectors
  case LGLSXP:
  case INTSXP:
    size += v_size(XLENGTH(x), sizeof(int));
    break;
  case REALSXP:
    size += v_size(XLENGTH(x), sizeof(double));
    break;
  case CPLXSXP:
    size += v_size(XLENGTH(x), sizeof(Rcomplex));
    break;
  case RAWSXP:
    size += v_size(XLENGTH(x), 1);
    break;

  // Strings
  case STRSXP:
    size += v_size(XLENGTH(x), sizeof(SEXP));
    for (R_xlen_t i = 0; i < XLENGTH(x); i++) {
      size += obj_size_tree(STRING_ELT(x, i), base_env, seen);
    }
    break;

  case CHARSXP:
    size += v_size(LENGTH(x) + 1, 1);
    break;

  // Generic vectors
  case VECSXP:
  case EXPRSXP:
  case WEAKREFSXP:
    size += v_size(XLENGTH(x), sizeof(SEXP));
    for (R_xlen_t i = 0; i < XLENGTH(x); ++i) {
      size += obj_size_tree(VECTOR_ELT(x, i), base_env, seen);
    }
    break;

  // Nodes ---------------------------------------------------------------------
  // https://github.com/wch/r-source/blob/master/src/include/Rinternals.h#L237-L249
  // All have enough space for three SEXP pointers

  // Linked lists
  case DOTSXP:
  case LISTSXP:
  case LANGSXP:
  case BCODESXP:
    size += 3 * sizeof(SEXP); // tag, car, cdr
    size += obj_size_tree(TAG(x), base_env, seen); // name of first element
    size += obj_size_tree(CAR(x), base_env, seen); // first element
    size += obj_size_tree(CDR(x), base_env, seen); // pairlist (subsequent elements) or NILSXP
    break;

  // Environments
  case ENVSXP:
    if (x == R_BaseEnv || x == R_GlobalEnv || x == R_EmptyEnv ||
      x == base_env || is_namespace(x)) return 0;

    size += 3 * sizeof(SEXP); // frame, enclos, hashtab
    size += obj_size_tree(FRAME(x), base_env, seen);
    size += obj_size_tree(ENCLOS(x), base_env, seen);
    size += obj_size_tree(HASHTAB(x), base_env, seen);
    break;

  // Functions
  case CLOSXP:
    size += 3 * sizeof(SEXP); // formals, body, env
    size += obj_size_tree(FORMALS(x), base_env, seen);
    size += obj_size_tree(BODY(x), base_env, seen);
    size += obj_size_tree(CLOENV(x), base_env, seen);
    break;

  case PROMSXP:
    size += 3 * sizeof(SEXP); // value, expr, env
    size += obj_size_tree(PRVALUE(x), base_env, seen);
    size += obj_size_tree(PRCODE(x), base_env, seen);
    size += obj_size_tree(PRENV(x), base_env, seen);
    break;

  case EXTPTRSXP:
    size += 3 * sizeof(SEXP);
    size += sizeof(void *); // the actual pointer
    size += obj_size_tree(EXTPTR_PROT(x), base_env, seen);
    size += obj_size_tree(EXTPTR_TAG(x), base_env, seen);
    break;

  case S4SXP:
    size += 3 * sizeof(SEXP);
    size += obj_size_tree(TAG(x), base_env, seen);
    break;

  case SYMSXP:
    size += 3 * sizeof(SEXP); // pname, value, internal
    break;

  default:
    stop("Can't compute size of %s", Rf_type2char(TYPEOF(x)));
  }

  // Rprintf("type: %-10s size: %6.0f\n", Rf_type2char(TYPEOF(x)), size);
  return size;
}

// [[Rcpp::export]]
double obj_size_(List objects, Environment base_env) {
  std::set<SEXP> seen;
  double size = 0;

  int n = objects.size();
  for (int i = 0; i < n; ++i) {
    size += obj_size_tree(objects[i], base_env, seen);
  }

  return size;
}

// [[Rcpp::export]]
IntegerVector obj_csize_(List objects, Environment base_env) {
  std::set<SEXP> seen;
  int n = objects.size();

  IntegerVector out(n);
  for (int i = 0; i < n; ++i) {
    out[i] += obj_size_tree(objects[i], base_env, seen);
  }

  return out;
}
