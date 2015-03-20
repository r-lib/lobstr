#include <Rcpp.h>
using namespace Rcpp;

std::string prim_type(SEXP x);
int envlength(SEXP x);

bool hasAttrib(RObject x) {
  return Rf_length(ATTRIB(x)) > 0;
}

// [[Rcpp::export]]
int prim_length(SEXP x) {
  switch(TYPEOF(x)) {

  // No children and can't have attributes
  case NILSXP:
  case BUILTINSXP:
  case SPECIALSXP:
  case SYMSXP:
    return 0;

  // Atomic vectors
  case LGLSXP:
  case INTSXP:
  case REALSXP:
  case CPLXSXP:
  case RAWSXP:
  case STRSXP:
    return hasAttrib(x);

  case CHARSXP:
  case WEAKREFSXP:
    return 1;

  case CLOSXP:    // body + env + args
  case PROMSXP:   // expr + env + value
  case EXTPTRSXP: // pointer + prot + tag
    return 3;

  case VECSXP:
  case EXPRSXP:
  case LISTSXP:
  case LANGSXP:
  case BCODESXP:
  case S4SXP:
    return Rf_length(x);

  case ENVSXP:
    return envlength(x) + (ENCLOS(x) != R_EmptyEnv); // elements + parent

  default:
    break;
  }

  stop("Unimplemented type %s", prim_type(x));
  return 0;
}

// Environment length helpers --------------------------------------------------

int FrameSize(SEXP frame) {
  int count = 0;

  for(SEXP cur = frame; frame != R_NilValue; cur = CDR(cur)) {
    if (CAR(frame) != R_UnboundValue)
      count++;
  }
  return count;
}

static int HashTableSize(SEXP table) {
  int count = 0;
  int n = Rf_length(table);
  for (int i = 0; i < n; ++i)
    count += FrameSize(VECTOR_ELT(table, i));
  return count;
}

int envlength(SEXP x) {
  bool isHashed = HASHTAB(x) != R_NilValue;
  return isHashed ? HashTableSize(HASHTAB(x)) : FrameSize(FRAME(x));
}
