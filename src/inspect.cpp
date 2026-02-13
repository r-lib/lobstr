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

// Convert SEXPTYPE to uppercase name (e.g. REALSXP, ENVSXP)
const char* sexptype_name(SEXPTYPE type) {
  switch (type) {
    case NILSXP:     return "NILSXP";
    case SYMSXP:     return "SYMSXP";
    case LISTSXP:    return "LISTSXP";
    case CLOSXP:     return "CLOSXP";
    case ENVSXP:     return "ENVSXP";
    case PROMSXP:    return "PROMSXP";
    case LANGSXP:    return "LANGSXP";
    case SPECIALSXP: return "SPECIALSXP";
    case BUILTINSXP: return "BUILTINSXP";
    case CHARSXP:    return "CHARSXP";
    case LGLSXP:     return "LGLSXP";
    case INTSXP:     return "INTSXP";
    case REALSXP:    return "REALSXP";
    case CPLXSXP:    return "CPLXSXP";
    case STRSXP:     return "STRSXP";
    case DOTSXP:     return "DOTSXP";
    case ANYSXP:     return "ANYSXP";
    case VECSXP:     return "VECSXP";
    case EXPRSXP:    return "EXPRSXP";
    case BCODESXP:   return "BCODESXP";
    case EXTPTRSXP:  return "EXTPTRSXP";
    case WEAKREFSXP: return "WEAKREFSXP";
    case RAWSXP:     return "RAWSXP";
#if R_VERSION >= R_Version(4, 5, 0)
    case OBJSXP:     return "OBJSXP";
#else
    case S4SXP:      return "S4SXP";
#endif
    default:         return "UNKNOWN";
  }
}

struct InspectorParams {
  // Empty string indicates a placeholder node (synthetic entry, not a real R object).
  // The R formatter uses this to skip address and refs display.
  const char* addr = "";
  int id = 0;
  bool has_seen = false;
  // Type string (e.g. "ENVSXP", "missing"). Use Rf_type2char() for real objects.
  const char* type = "NILSXP";
  double length = 0;
  bool altrep = false;
  int maybe_shared = 0;
  int no_references = 0;
  bool object = false;
  // Shown as `<TYPE: value>` (e.g. symbol name, env name)
  const char* value = NULL;
};

SEXP new_inspector_node(SEXP children, const InspectorParams& params) {
  Rf_setAttrib(children, Rf_install("addr"), PROTECT(Rf_mkString(params.addr)));
  Rf_setAttrib(children, Rf_install("has_seen"), PROTECT(Rf_ScalarLogical(params.has_seen)));
  Rf_setAttrib(children, Rf_install("id"), PROTECT(Rf_ScalarInteger(params.id)));
  Rf_setAttrib(children, Rf_install("type"), PROTECT(Rf_mkString(params.type)));
  Rf_setAttrib(children, Rf_install("length"), PROTECT(Rf_ScalarReal(params.length)));
  Rf_setAttrib(children, Rf_install("altrep"), PROTECT(Rf_ScalarLogical(params.altrep)));
  Rf_setAttrib(children, Rf_install("maybe_shared"), PROTECT(Rf_ScalarInteger(params.maybe_shared)));
  Rf_setAttrib(children, Rf_install("no_references"), PROTECT(Rf_ScalarInteger(params.no_references)));
  Rf_setAttrib(children, Rf_install("object"), PROTECT(Rf_ScalarInteger(params.object)));
  Rf_setAttrib(children, Rf_install("class"), PROTECT(Rf_mkString("lobstr_inspector")));
  UNPROTECT(10);

  if (params.value != NULL) {
    Rf_setAttrib(children, Rf_install("value"), PROTECT(Rf_mkString(params.value)));
    UNPROTECT(1);
  }

  return children;
}

// Create a placeholder inspector node for synthetic entries (e.g. promise bindings)
SEXP new_placeholder_inspector(
    const char* type,
    std::map<SEXP, int>& seen,
    const char* value = NULL) {
  SEXP out = PROTECT(Rf_allocVector(VECSXP, 0));

  InspectorParams params;
  params.id = seen.size() + 1;
  params.type = type;
  params.value = value;
  new_inspector_node(out, params);

  UNPROTECT(1);
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

  // Compute optional value for display
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

  std::string addr = obj_addr_(x);

  InspectorParams params;
  params.addr = addr.c_str();
  params.id = id;
  params.has_seen = has_seen;
  params.type = sexptype_name(TYPEOF(x));
  params.length = sxp_length(x);
  params.altrep = is_altrep(x);
  params.maybe_shared = MAYBE_SHARED(x);
  params.no_references = NO_REFERENCES(x);
  params.object = Rf_isObject(x);
  params.value = value;
  new_inspector_node(children, params);

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
          SEXP missing = PROTECT(new_placeholder_inspector("missing", seen));
          children.push_back(name, missing);
          UNPROTECT(1);
          break;
        }

        case R_ENV_BINDING_TYPE_delayed: {
          SEXP promise = PROTECT(new_placeholder_inspector("PROMSXP", seen));
          children.push_back(name, promise);
          UNPROTECT(1);

          if (expand.env) {
            recurse(&children, seen, "_code", r_env_binding_delayed_expr(x, sym), max_depth, expand);
            recurse(&children, seen, "_env", r_env_binding_delayed_env(x, sym), max_depth, expand);
          }
          break;
        }

        case R_ENV_BINDING_TYPE_forced: {
          SEXP promise = PROTECT(new_placeholder_inspector("PROMSXP", seen));
          children.push_back(name, promise);
          UNPROTECT(1);

          if (expand.env) {
            recurse(&children, seen, "_value", r_env_binding_forced_value(x, sym), max_depth, expand);
            recurse(&children, seen, "_code", r_env_binding_forced_expr(x, sym), max_depth, expand);
          }
          break;
        }

        case R_ENV_BINDING_TYPE_active: {
          SEXP active = PROTECT(new_placeholder_inspector("CLOSXP", seen, "active"));
          children.push_back(name, active);
          UNPROTECT(1);

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
