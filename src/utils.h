inline bool hasAttrib(SEXP x) {
  return Rf_length(ATTRIB(x)) > 0;
}

// Environment length helpers --------------------------------------------------

inline int FrameSize(SEXP frame) {
  int count = 0;

  for(SEXP cur = frame; cur != R_NilValue; cur = CDR(cur)) {
    if (CAR(cur) != R_UnboundValue)
      count++;
  }
  return count;
}

inline  int HashTableSize(SEXP table) {
  int count = 0;
  int n = Rf_length(table);
  for (int i = 0; i < n; ++i)
    count += FrameSize(VECTOR_ELT(table, i));
  return count;
}

inline int envlength(SEXP x) {
  bool isHashed = HASHTAB(x) != R_NilValue;
  return isHashed ? HashTableSize(HASHTAB(x)) : FrameSize(FRAME(x));
}
