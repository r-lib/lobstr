#include <Rcpp.h>
using namespace Rcpp;

static const int ptr_size = sizeof(void*);

// [[Rcpp::export]]
double v_size(double n, int size) {
  if (n == 0) return 8;

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

  return bytes +
    vec_size; // SEXPREC_ALIGN padding
}

bool is_namespace(Environment env) {
  return Rf_findVarInFrame3(env, Rf_install(".__NAMESPACE__."), FALSE) != R_UnboundValue;
}

double object_size_rec(SEXP x, Environment base_env, std::set<SEXP>& seen) {
  // NILSXP is a singleton, so occupies no space. Similarly SPECIAL and
  // BUILTIN are fixed and unchanging
  if (TYPEOF(x) == NILSXP ||
    TYPEOF(x) == SPECIALSXP ||
    TYPEOF(x) == BUILTINSXP) return 0;

  // If we've seen it before in this object, don't count it again
  if (!seen.insert(x).second) return 0;

  // As of R 3.1.0, all SEXPRECs start with sxpinfo (4 bytes, but aligned),
  // followed by three pointers: attribute pairlist, next object, prev object
  // (i.e. doubly linked list of all objects in memory)
  double size = 4 * ptr_size;

  switch (TYPEOF(x)) {
  // Simple vectors
  case LGLSXP:
  case INTSXP:
    size += v_size(XLENGTH(x), sizeof(int));
    size += object_size_rec(ATTRIB(x), base_env, seen);
    break;
  case REALSXP:
    size += v_size(XLENGTH(x), sizeof(double));
    size += object_size_rec(ATTRIB(x), base_env, seen);
    break;
  case CPLXSXP:
    size += v_size(XLENGTH(x), sizeof(Rcomplex));
    size += object_size_rec(ATTRIB(x), base_env, seen);
    break;
  case RAWSXP:
    size += v_size(XLENGTH(x), 1);
    size += object_size_rec(ATTRIB(x), base_env, seen);
    break;

    // Strings
  case STRSXP:
    size += v_size(XLENGTH(x), ptr_size);
    for (R_xlen_t i = 0; i < XLENGTH(x); i++) {
      size += object_size_rec(STRING_ELT(x, i), base_env, seen);
    }
    size += object_size_rec(ATTRIB(x), base_env, seen);
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
      size += object_size_rec(VECTOR_ELT(x, i), base_env, seen);
    }
    size += object_size_rec(ATTRIB(x), base_env, seen);
    break;

    // Linked lists
  case LISTSXP:
  case LANGSXP:
  case BCODESXP:
    size += 3 * sizeof(SEXP); // tag, car, cdr
    size += object_size_rec(TAG(x), base_env, seen); // name of first element
    size += object_size_rec(CAR(x), base_env, seen); // first element
    size += object_size_rec(CDR(x), base_env, seen); // pairlist (subsequent elements) or NILSXP
    size += object_size_rec(ATTRIB(x), base_env, seen);
    break;

    // Environments
  case ENVSXP:
    if (x == R_BaseEnv || x == R_GlobalEnv || x == R_EmptyEnv ||
      x == base_env || is_namespace(x)) return 0;

    size += 3 * sizeof(SEXP); // frame, enclos, hashtab
    size += object_size_rec(FRAME(x), base_env, seen);
    size += object_size_rec(ENCLOS(x), base_env, seen);
    size += object_size_rec(HASHTAB(x), base_env, seen);
    size += object_size_rec(ATTRIB(x), base_env, seen);
    break;

    // Functions
  case CLOSXP:
    size += 3 * sizeof(SEXP); // formals, body, env
    size += object_size_rec(FORMALS(x), base_env, seen);
    size += object_size_rec(BODY(x), base_env, seen);
    size += object_size_rec(CLOENV(x), base_env, seen);
    size += object_size_rec(ATTRIB(x), base_env, seen);
    break;

  case PROMSXP:
    size += 3 * sizeof(SEXP); // value, expr, env
    size += object_size_rec(PRVALUE(x), base_env, seen);
    size += object_size_rec(PRCODE(x), base_env, seen);
    size += object_size_rec(PRENV(x), base_env, seen);

  case EXTPTRSXP:
    size += sizeof(void *); // the actual pointer
    size += object_size_rec(EXTPTR_PROT(x), base_env, seen);
    size += object_size_rec(EXTPTR_TAG(x), base_env, seen);
    break;

  case S4SXP:
    // Only has TAG and ATTRIB
    size += object_size_rec(TAG(x), base_env, seen);
    size += object_size_rec(ATTRIB(x), base_env, seen);
    break;

  case SYMSXP:
    size += 3 * sizeof(SEXP); // pname, value, internal
    break;

  default:
    Rcout << "type: " << TYPEOF(x);
  stop("Unimplemented type");
  }

  // Rcout << "type: " << TYPEOF(x) << " size: " << size << "\n";
  return size;
}

// [[Rcpp::export]]
double prim_sizes(List objects, Environment base_env) {
  std::set<SEXP> seen;
  double size = 0;

  int n = objects.size();
  for (int i = 0; i < n; ++i) {
    size += object_size_rec(objects[i], base_env, seen);
  }

  return size;
}
