#include <cpp11/environment.hpp>
#include <cpp11/list.hpp>
#include <cpp11/sexp.hpp>
#include <cpp11/strings.hpp>
#include <Rversion.h>
#include <map>
#include "utils.h"

extern "C" {
#include <rlang.h>
}

struct Expand {
  bool alrep;
  bool charsxp;
  bool env;
  bool call;
  bool bytecode;
};

class GrowableList {
  cpp11::writable::list data_;
  cpp11::writable::strings names_;
  R_xlen_t n_;

public:
  GrowableList(R_xlen_t size = 10) : data_(size), names_(size), n_(0) {
  }

  void push_back(const char* string, SEXP x) {
    int n_protected = 0;

    if (Rf_xlength(data_) == n_) {
      data_ = PROTECT(Rf_xlengthgets(data_, n_ * 2)); n_protected++;
      names_ = PROTECT(Rf_xlengthgets(names_, n_ * 2)); n_protected++;
    }
    SEXP string_ = PROTECT(Rf_mkChar(string)); n_protected++;
    SET_STRING_ELT(names_, n_, string_);
    SET_VECTOR_ELT(data_, n_, x);
    n_++;
    UNPROTECT(n_protected);
  }

  cpp11::list vector() {
    if (Rf_xlength(data_) != n_) {
      data_ = Rf_xlengthgets(data_, n_);
      names_ = Rf_xlengthgets(names_, n_);
    }
    Rf_setAttrib(data_, R_NamesSymbol, names_);

    return data_;
  }
};

SEXP collect_attribs(SEXP x);
bool is_namespace(cpp11::environment env);
SEXP obj_children_(SEXP x, std::map<SEXP, int>& seen, double max_depth, Expand expand);

// Create a placeholder inspector node for synthetic entries (e.g. promise bindings)
SEXP new_placeholder_inspector(int type, std::map<SEXP, int>& seen) {
  SEXP out = PROTECT(Rf_allocVector(VECSXP, 0));

  int id = seen.size() + 1;

  // Placeholder address. Causes a more bare bones display in the tree.
  Rf_setAttrib(out, Rf_install("addr"), PROTECT(Rf_mkString("")));

  // Placeholder properties
  Rf_setAttrib(out, Rf_install("has_seen"), PROTECT(Rf_ScalarLogical(false)));
  Rf_setAttrib(out, Rf_install("id"), PROTECT(Rf_ScalarInteger(id)));
  Rf_setAttrib(out, Rf_install("type"), PROTECT(Rf_ScalarInteger(type)));
  Rf_setAttrib(out, Rf_install("length"), PROTECT(Rf_ScalarReal(0)));
  Rf_setAttrib(out, Rf_install("altrep"), PROTECT(Rf_ScalarLogical(false)));
  Rf_setAttrib(out, Rf_install("maybe_shared"), PROTECT(Rf_ScalarInteger(0)));
  Rf_setAttrib(out, Rf_install("no_references"), PROTECT(Rf_ScalarInteger(0)));
  Rf_setAttrib(out, Rf_install("object"), PROTECT(Rf_ScalarInteger(0)));
  Rf_setAttrib(out, Rf_install("class"), PROTECT(Rf_mkString("lobstr_inspector")));

  UNPROTECT(11);
  return out;
}

bool is_altrep(SEXP x) {
#if defined(R_VERSION) && R_VERSION >= R_Version(3, 5, 0)
  return ALTREP(x);
#else
  return false;
#endif
}

SEXP obj_inspect_(SEXP x,
                 std::map<SEXP, int>& seen,
                 double max_depth,
                 Expand& expand) {

  int id;
  SEXP children;
  bool has_seen;
  if (seen.count(x)) {
    has_seen = true;
    id = seen[x];
    children = PROTECT(Rf_allocVector(VECSXP, 0));
  } else {
    has_seen = false;
    id = seen.size() + 1;
    seen[x] = id;
    children = PROTECT(obj_children_(x, seen, max_depth, expand));
  }

  // don't store object directly to avoid increasing refcount
  Rf_setAttrib(children, Rf_install("addr"), PROTECT(Rf_mkString(obj_addr_(x).c_str())));
  Rf_setAttrib(children, Rf_install("has_seen"), PROTECT(Rf_ScalarLogical(has_seen)));
  Rf_setAttrib(children, Rf_install("id"), PROTECT(Rf_ScalarInteger(id)));
  Rf_setAttrib(children, Rf_install("type"), PROTECT(Rf_ScalarInteger(TYPEOF(x))));
  Rf_setAttrib(children, Rf_install("length"), PROTECT(Rf_ScalarReal(sxp_length(x))));
  Rf_setAttrib(children, Rf_install("altrep"), PROTECT(Rf_ScalarLogical(is_altrep(x))));
  Rf_setAttrib(children, Rf_install("maybe_shared"), PROTECT(Rf_ScalarInteger(MAYBE_SHARED(x))));
  Rf_setAttrib(children, Rf_install("no_references"), PROTECT(Rf_ScalarInteger(NO_REFERENCES(x))));
  Rf_setAttrib(children, Rf_install("object"), PROTECT(Rf_ScalarInteger(Rf_isObject(x))));
  UNPROTECT(9);

  const char* value = NULL;
  if (TYPEOF(x) == SYMSXP && PRINTNAME(x) != R_NilValue) {
    value = CHAR(PRINTNAME(x));
  } else if (TYPEOF(x) == ENVSXP) {
    if (x == R_GlobalEnv) {
      value = "global";
    } else if (x == R_EmptyEnv) {
      value = "empty";
    } else if (x == R_BaseEnv) {
      value = "base";
    } else {
      if (R_PackageEnvName(x) != R_NilValue)
        value = CHAR(STRING_ELT(R_PackageEnvName(x), 0));
    }
  }
  if (value != NULL) {
    Rf_setAttrib(children, Rf_install("value"), PROTECT(Rf_mkString(value)));
    UNPROTECT(1);
  }

  Rf_setAttrib(children, Rf_install("class"), PROTECT(Rf_mkString("lobstr_inspector")));
  UNPROTECT(1);

  UNPROTECT(1);
  return children;
}

inline void recurse(
                    GrowableList* children,
                    std::map<SEXP, int>& seen,
                    const char* name,
                    SEXP child,
                    double max_depth,
                    Expand& expand) {

  SEXP descendents = PROTECT(obj_inspect_(child, seen, max_depth - 1, expand));
  children->push_back(name, descendents);
  UNPROTECT(1);
}

SEXP obj_children_(
                  SEXP x,
                  std::map<SEXP, int>& seen,
                  double max_depth,
                  Expand expand) {

  GrowableList children;
  bool skip = false;

  // Handle ALTREP objects
  if (expand.alrep && is_altrep(x)) {
#if defined(R_VERSION) && R_VERSION >= R_Version(3, 5, 0)
    SEXP klass = ALTREP_CLASS(x);

    recurse(&children, seen, "_class", klass, max_depth, expand);
    recurse(&children, seen, "_data1", R_altrep_data1(x), max_depth, expand);
    recurse(&children, seen, "_data2", R_altrep_data2(x), max_depth, expand);
#endif
  } else if (max_depth <= 0) {
    switch (TYPEOF(x)) {
    // Non-recursive types
    case NILSXP:
    case SPECIALSXP:
    case BUILTINSXP:
    case LGLSXP:
    case INTSXP:
    case REALSXP:
    case CPLXSXP:
    case RAWSXP:
    case CHARSXP:
    case SYMSXP:
      skip = false;
      break;

    default:
      skip = true;
    };
  } else {
    switch (TYPEOF(x)) {
    // Non-recursive types
    case NILSXP:
    case SPECIALSXP:
    case BUILTINSXP:
    case LGLSXP:
    case INTSXP:
    case REALSXP:
    case CPLXSXP:
    case RAWSXP:
    case CHARSXP:
    case SYMSXP:
      break;

    // Strings
    case STRSXP:
      if (expand.charsxp) {
        for (R_xlen_t i = 0; i < XLENGTH(x); i++) {
          recurse(&children, seen, "", STRING_ELT(x, i), max_depth, expand);
        }
      }
      break;

    // Recursive vectors
    case VECSXP:
    case EXPRSXP:
    case WEAKREFSXP: {
      SEXP names = PROTECT(Rf_getAttrib(x, R_NamesSymbol));
      if (TYPEOF(names) == STRSXP) {
        for (R_xlen_t i = 0; i < XLENGTH(x); ++i) {
          recurse(&children, seen, CHAR(STRING_ELT(names, i)), VECTOR_ELT(x, i), max_depth, expand);
        }
      } else {
        for (R_xlen_t i = 0; i < XLENGTH(x); ++i) {
          recurse(&children, seen, "", VECTOR_ELT(x, i), max_depth, expand);
        }
      }
      UNPROTECT(1);
      break;
    }

    // Linked lists
    case LANGSXP:
      if (!expand.call) {
        skip = true;
        break;
      }
    case DOTSXP:
    case LISTSXP: {
      if (x == R_MissingArg) { // Needed for DOTSXP
        break;
      }

      SEXP cons = x;
      for (; is_linked_list(cons); cons = CDR(cons)) {
        SEXP tag = TAG(cons);
        if (TYPEOF(tag) == NILSXP) {
          recurse(&children, seen, "", CAR(cons), max_depth, expand);
        } else if (TYPEOF(tag) == SYMSXP) {
          recurse(&children, seen, CHAR(PRINTNAME(tag)), CAR(cons), max_depth, expand);
        } else {
          // TODO: add index? needs to be a list?
          recurse(&children, seen, "_tag", tag, max_depth, expand);
          recurse(&children, seen, "_car", CAR(cons), max_depth, expand);
        }
      }
      if (cons != R_NilValue) {
        recurse(&children, seen, "_cdr", cons, max_depth, expand);
      }

      break;
    }

    case BCODESXP:
      if (!expand.bytecode) {
        skip = true;
        break;
      }
      recurse(&children, seen, "_tag", TAG(x), max_depth, expand);
      recurse(&children, seen, "_car", CAR(x), max_depth, expand);
      recurse(&children, seen, "_cdr", CDR(x), max_depth, expand);
      break;

    // Environments
    case ENVSXP: {
      if (x == R_BaseEnv || x == R_GlobalEnv || x == R_EmptyEnv || is_namespace(x))
        break;

      cpp11::sexp syms(r_env_syms(x));
      R_xlen_t n_bindings = Rf_xlength(syms);

      for (R_xlen_t i = 0; i < n_bindings; ++i) {
        SEXP sym = VECTOR_ELT(syms, i);
        const char* name = CHAR(PRINTNAME(sym));
        enum r_env_binding_type type = r_env_binding_type(x, sym);

        switch (type) {
        case R_ENV_BINDING_TYPE_value:
          recurse(&children, seen, name, r_env_get(x, sym), max_depth, expand);
          break;

        case R_ENV_BINDING_TYPE_missing: {
          SEXP missing = PROTECT(new_placeholder_inspector(SYMSXP, seen));
          Rf_setAttrib(missing, Rf_install("value"), PROTECT(Rf_mkString("<missing>")));
          children.push_back(name, missing);
          UNPROTECT(2);
          break;
        }

        case R_ENV_BINDING_TYPE_delayed: {
          SEXP promise = PROTECT(new_placeholder_inspector(PROMSXP, seen));
          children.push_back(name, promise);
          UNPROTECT(1);

          if (expand.env) {
            recurse(&children, seen, "_code", r_env_binding_delayed_expr(x, sym), max_depth, expand);
            recurse(&children, seen, "_env", r_env_binding_delayed_env(x, sym), max_depth, expand);
          }
          break;
        }

        case R_ENV_BINDING_TYPE_forced: {
          SEXP promise = PROTECT(new_placeholder_inspector(PROMSXP, seen));
          children.push_back(name, promise);
          UNPROTECT(1);

          if (expand.env) {
            recurse(&children, seen, "_value", r_env_binding_forced_value(x, sym), max_depth, expand);
            recurse(&children, seen, "_code", r_env_binding_forced_expr(x, sym), max_depth, expand);
          }
          break;
        }

        case R_ENV_BINDING_TYPE_active: {
          SEXP active = PROTECT(new_placeholder_inspector(CLOSXP, seen));
          Rf_setAttrib(active, Rf_install("value"), PROTECT(Rf_mkString("active")));
          children.push_back(name, active);
          UNPROTECT(2);

          if (expand.env) {
            recurse(&children, seen, "_fn", r_env_binding_active_fn(x, sym), max_depth, expand);
          }
          break;
        }

        case R_ENV_BINDING_TYPE_unbound:
          break;
        }
      }

      recurse(&children, seen, "_enclos", r_env_parent(x), max_depth, expand);
      break;
    }

    // Functions
    case CLOSXP:
#if (R_VERSION >= R_Version(4, 5, 0))
      recurse(&children, seen, "_formals", R_ClosureFormals(x), max_depth, expand);
      recurse(&children, seen, "_body", R_ClosureBody(x), max_depth, expand);
      recurse(&children, seen, "_env", R_ClosureEnv(x), max_depth, expand);
#else
      recurse(&children, seen, "_formals", FORMALS(x), max_depth, expand);
      recurse(&children, seen, "_body", BODY(x), max_depth, expand);
      recurse(&children, seen, "_env", CLOENV(x), max_depth, expand);
#endif
      break;

    case PROMSXP:
      // Using node-based object accessors: CAR for PRVALUE, CDR for PRCODE, and
      // TAG for PRENV. TODO: Iterate manually over the environment using
      // environment accessors.
      recurse(&children, seen, "_value", CAR(x), max_depth, expand);
      recurse(&children, seen, "_code", CDR(x), max_depth, expand);
      recurse(&children, seen, "_env", TAG(x), max_depth, expand);
      break;

    case EXTPTRSXP:
      recurse(&children, seen, "_prot", R_ExternalPtrProtected(x), max_depth, expand);
      recurse(&children, seen, "_tag", R_ExternalPtrTag(x), max_depth, expand);
      break;

    case S4SXP:
      recurse(&children, seen, "_tag", TAG(x), max_depth, expand);
      break;

    default:
      cpp11::stop("Don't know how to handle type %s", Rf_type2char(TYPEOF(x)));
    }
  }

  // CHARSXPs have fake attributes so don't inspecct them
  if (max_depth > 0 && TYPEOF(x) != CHARSXP && ANY_ATTRIB(x)) {
    recurse(&children, seen, "_attrib", PROTECT(collect_attribs(x)), max_depth, expand);
    UNPROTECT(1);
  }

  SEXP out = PROTECT(children.vector());
  if (skip) {
    Rf_setAttrib(out, Rf_install("skip"), PROTECT(Rf_ScalarLogical(skip)));
    UNPROTECT(1);
  }
  UNPROTECT(1);

  return out;
}

// Collect attributes into a pairlist
SEXP collect_attribs(SEXP x) {
  SEXP sentinel = PROTECT(Rf_cons(R_NilValue, R_NilValue));
  SEXP tail = sentinel;

  R_mapAttrib(x, [](SEXP tag, SEXP val, void* data) -> SEXP {
    SEXP* tail = (SEXP*)data;

    SEXP node = Rf_cons(val, R_NilValue);
    SETCDR(*tail, node);
    SET_TAG(node, tag);

    *tail = node;
    return NULL;
  }, &tail);

  UNPROTECT(1);
  return CDR(sentinel);
}


[[cpp11::register]]
cpp11::list obj_inspect_(SEXP x,
                        double max_depth,
                        bool expand_char = false,
                        bool expand_altrep = false,
                        bool expand_env = false,
                        bool expand_call = false,
                        bool expand_bytecode = false) {
  std::map<SEXP, int> seen;
  Expand expand = {expand_altrep, expand_char, expand_env, expand_call};

  return obj_inspect_(x, seen, max_depth, expand);
}
