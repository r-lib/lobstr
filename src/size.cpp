#include <cpp11/environment.hpp>
#include <cpp11/doubles.hpp>
#include <cpp11/list.hpp>
#include <Rversion.h>
#include <set>
#include "utils.h"

[[cpp11::register]]
double v_size(double n, int element_size) {
  if (n == 0)
    return 0;

  double vec_size = std::max(sizeof(SEXP), sizeof(double));
  double elements_per_byte = vec_size / element_size;
  double n_bytes = ceil(n / elements_per_byte);
  // Rcout << n << " elements, each of " << elements_per_byte << " = " <<
  //  n_bytes << "\n";

  double size = 0;
  // Big vectors always allocated in 8 byte chunks
  if      (n_bytes > 16) size = n_bytes * 8;
  // For small vectors, round to sizes allocated in small vector pool
  else if (n_bytes > 8)  size = 128;
  else if (n_bytes > 6)  size = 64;
  else if (n_bytes > 4)  size = 48;
  else if (n_bytes > 2)  size = 32;
  else if (n_bytes > 1)  size = 16;
  else if (n_bytes > 0)  size = 8;

  // Size is pointer to struct  + struct size
  return size;
}

bool is_namespace(cpp11::environment env) {
  return Rf_findVarInFrame3(env, Rf_install(".__NAMESPACE__."), FALSE) != R_UnboundValue;
}


// R equivalent
// https://github.com/wch/r-source/blob/master/src/library/utils/src/size.c#L41

double obj_size_tree(SEXP x,
                     cpp11::environment base_env,
                     int sizeof_node,
                     int sizeof_vector,
                     std::set<SEXP>& seen,
                     int depth) {
  // NILSXP is a singleton, so occupies no space. Similarly SPECIAL and
  // BUILTIN are fixed and unchanging
  if (TYPEOF(x) == NILSXP ||
    TYPEOF(x) == SPECIALSXP ||
    TYPEOF(x) == BUILTINSXP) return 0;

  // Don't count objects that we've seen before
  if (!seen.insert(x).second) return 0;

  // Rcout << "\n" << std::string(depth * 2, ' ');
  // Rprintf("type: %s", Rf_type2char(TYPEOF(x)));

  // Use sizeof(SEXPREC) and sizeof(VECTOR_SEXPREC) computed in R.
  // CHARSXP are treated as vectors for this purpose
  double size = (Rf_isVector(x) || TYPEOF(x) == CHARSXP) ? sizeof_vector : sizeof_node;

#if defined(R_VERSION) && R_VERSION >= R_Version(3, 5, 0)
  // Handle ALTREP objects
  if (ALTREP(x)) {
    SEXP klass = ALTREP_CLASS(x);

    size += 3 * sizeof(SEXP);
    size += obj_size_tree(klass, base_env, sizeof_node, sizeof_vector, seen, depth + 1);
    size += obj_size_tree(R_altrep_data1(x), base_env, sizeof_node, sizeof_vector, seen, depth + 1);
    size += obj_size_tree(R_altrep_data2(x), base_env, sizeof_node, sizeof_vector, seen, depth + 1);
    return size;
  }
#endif

  // CHARSXPs have fake attributes
  if (TYPEOF(x) != CHARSXP )
    size += obj_size_tree(ATTRIB(x), base_env, sizeof_node, sizeof_vector, seen, depth + 1);

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
      size += obj_size_tree(STRING_ELT(x, i), base_env, sizeof_node, sizeof_vector, seen, depth + 1);
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
      size += obj_size_tree(VECTOR_ELT(x, i), base_env, sizeof_node, sizeof_vector, seen, depth + 1);
    }
    break;

  // Nodes ---------------------------------------------------------------------
  // https://github.com/wch/r-source/blob/master/src/include/Rinternals.h#L237-L249
  // All have enough space for three SEXP pointers

  // Linked lists
  case DOTSXP:
  case LISTSXP:
  case LANGSXP: {
    if (x == R_MissingArg) { // Needed for DOTSXP
      break;
    }

    SEXP cons = x;
    for (; is_linked_list(cons); cons = CDR(cons)) {
      if (cons != x) {
        size += sizeof_node;
      }
      size += obj_size_tree(TAG(cons), base_env, sizeof_node, sizeof_vector, seen, depth + 1);
      size += obj_size_tree(CAR(cons), base_env, sizeof_node, sizeof_vector, seen, depth + 1);
    }
    // Handle non-nil CDRs
    size += obj_size_tree(cons, base_env, sizeof_node, sizeof_vector, seen, depth + 1);

    break;
  }

  case BCODESXP:
    size += obj_size_tree(TAG(x), base_env, sizeof_node, sizeof_vector, seen, depth + 1);
    size += obj_size_tree(CAR(x), base_env, sizeof_node, sizeof_vector, seen, depth + 1);
    size += obj_size_tree(CDR(x), base_env, sizeof_node, sizeof_vector, seen, depth + 1);
    break;

  // Environments
  case ENVSXP:
    if (x == R_BaseEnv || x == R_GlobalEnv || x == R_EmptyEnv ||
      x == base_env || is_namespace(x)) return 0;

    size += obj_size_tree(FRAME(x), base_env, sizeof_node, sizeof_vector, seen, depth + 1);
    size += obj_size_tree(ENCLOS(x), base_env, sizeof_node, sizeof_vector, seen, depth + 1);
    size += obj_size_tree(HASHTAB(x), base_env, sizeof_node, sizeof_vector, seen, depth + 1);
    break;

  // Functions
  case CLOSXP:
    size += obj_size_tree(FORMALS(x), base_env, sizeof_node, sizeof_vector, seen, depth + 1);
    // BODY is either an expression or byte code
    size += obj_size_tree(BODY(x), base_env, sizeof_node, sizeof_vector, seen, depth + 1);
    size += obj_size_tree(CLOENV(x), base_env, sizeof_node, sizeof_vector, seen, depth + 1);
    break;

  case PROMSXP:
    size += obj_size_tree(PRVALUE(x), base_env, sizeof_node, sizeof_vector, seen, depth + 1);
    size += obj_size_tree(PRCODE(x), base_env, sizeof_node, sizeof_vector, seen, depth + 1);
    size += obj_size_tree(PRENV(x), base_env, sizeof_node, sizeof_vector, seen, depth + 1);
    break;

  case EXTPTRSXP:
    size += sizeof(void *); // the actual pointer
    size += obj_size_tree(EXTPTR_PROT(x), base_env, sizeof_node, sizeof_vector, seen, depth + 1);
    size += obj_size_tree(EXTPTR_TAG(x), base_env, sizeof_node, sizeof_vector, seen, depth + 1);
    break;

  case S4SXP:
    size += obj_size_tree(TAG(x), base_env, sizeof_node, sizeof_vector, seen, depth + 1);
    break;

  case SYMSXP:
    break;

  default:
    cpp11::stop("Can't compute size of %s", Rf_type2char(TYPEOF(x)));
  }

  // Rprintf("type: %-10s size: %6.0f\n", Rf_type2char(TYPEOF(x)), size);
  return size;
}

[[cpp11::register]]
double obj_size_(cpp11::list objects, cpp11::environment base_env, int sizeof_node, int sizeof_vector) {
  std::set<SEXP> seen;
  double size = 0;

  int n = objects.size();
  for (int i = 0; i < n; ++i) {
    size += obj_size_tree(objects[i], base_env, sizeof_node, sizeof_vector, seen, 0);
  }

  return size;
}

[[cpp11::register]]
cpp11::doubles obj_csize_(cpp11::list objects, cpp11::environment base_env, int sizeof_node, int sizeof_vector) {
  std::set<SEXP> seen;
  int n = objects.size();

  cpp11::writable::doubles out(n);
  for (int i = 0; i < n; ++i) {
    out[i] = out[i] + obj_size_tree(objects[i], base_env, sizeof_node, sizeof_vector, seen, 0);
  }

  return out;
}
