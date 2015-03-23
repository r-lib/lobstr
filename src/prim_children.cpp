#include <Rcpp.h>
#include "GList.h"
#include "utils.h"
using namespace Rcpp;

void collectEnv(SEXP x, GList& out);

// [[Rcpp::export]]
RObject prim_children_(SEXP x) {
  GList out;

  switch(TYPEOF(x)) {

  // No children and can't have attributes
  case NILSXP:
  case BUILTINSXP:
  case SPECIALSXP:
  case SYMSXP:
  case CHARSXP:
  case WEAKREFSXP:
  case LGLSXP:
  case INTSXP:
  case REALSXP:
  case CPLXSXP:
  case RAWSXP:
  case STRSXP:
  case S4SXP: // slots = attributes
    break;

  case CLOSXP:    // body + env + args
    out.push_back("__body", BODY(x));
    out.push_back("__formals", FORMALS(x));
    out.push_back("__enclosure", CLOENV(x));
    break;

  case LISTSXP: // pair list
  case LANGSXP: // quoted call
    for(SEXP cur = x; cur != R_NilValue; cur = CDR(cur)) {
      if (CAR(cur) != R_UnboundValue)
        out.push_back(TAG(cur), CAR(cur));
    }
    break;

  case EXPRSXP:
  case VECSXP: {
    SEXP names = Rf_getAttrib(x, Rf_install("names"));
    int n = Rf_length(x);
    out.resize(n);

    if (names == R_NilValue) {
      for (int i = 0; i < n; ++i)
        out.push_back(VECTOR_ELT(x, i));
    } else {
      for (int i = 0; i < n; ++i)
        out.push_back(CHAR(STRING_ELT(names, i)), VECTOR_ELT(x, i));
    }
    break;
  }

  case BCODESXP:
    out.push_back("__code", BCODE_CODE(x));
    out.push_back("__consts", BCODE_CONSTS(x));
    out.push_back("__tag", BCODE_EXPR(x));
    break;

  case PROMSXP:
    out.push_back("__value", PRVALUE(x));
    out.push_back("__code", PRCODE(x));
    out.push_back("__env", PRENV(x));
    break;

  case EXTPTRSXP:
    out.push_back("__prot", EXTPTR_PROT(x));
    out.push_back("__tag", EXTPTR_TAG(x));
    break;

  case ENVSXP:
    collectEnv(x, out);
    if (ENCLOS(x) != R_EmptyEnv)
      out.push_back("__enclosure", ENCLOS(x));
    break;

  default:
    warning("Unimplemented type %s", Rf_type2char(TYPEOF(x)));

  }
  if (IS_S4_OBJECT(x)) {
    out.push_back("__slots", ATTRIB(x));
  } else {
    if (hasAttrib(x))
      out.push_back("__attributes", ATTRIB(x));
  }

  return out.list();
}


void collectFrame(SEXP frame, GList& out) {
  for(SEXP cur = frame; cur != R_NilValue; cur = CDR(cur)) {
    if (CAR(cur) != R_UnboundValue)
      out.push_back(TAG(cur), CAR(cur));
  }
}

void collectHashtable(SEXP table, GList& out) {
  int n = Rf_length(table);
  for (int i = 0; i < n; ++i)
    collectFrame(VECTOR_ELT(table, i), out);
}

void collectEnv(SEXP x, GList& out) {
  bool isHashed = HASHTAB(x) != R_NilValue;
  if (isHashed) {
    collectHashtable(HASHTAB(x), out);
  } else {
    collectFrame(FRAME(x), out);
  }
}
