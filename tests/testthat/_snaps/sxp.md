# snapshots environment binding types

    Code
      print(sxp(e))
    Output
      [1] <ENVSXP> ()
        active [2] <CLOSXP: active> ()
        forced [2] <PROMSXP> ()
        delayed [2] <PROMSXP> ()
        missing [2] <missing> ()
        value [2] <REALSXP[1]> ()
        _enclos [3] <ENVSXP: empty> ()
    Code
      print(sxp(e, expand = "environment", max_depth = 6L))
    Output
      [1] <ENVSXP> ()
        active [2] <CLOSXP: active> ()
        _fn [2] <CLOSXP> ()
          _formals [3] <NILSXP> ()
          _body [4] <REALSXP[1]> ()
          _env [5] <ENVSXP> ()
            e [1]
            _enclos [6] <ENVSXP> ()
              _enclos [7] <ENVSXP> ()
                _enclos [8] <ENVSXP> ()
                  ...
          _attrib [9] <LISTSXP> ()
            srcref [10] <INTSXP[8]> (object )
              _attrib [11] <LISTSXP> ()
                srcfile [12] <ENVSXP> (object )
                  ...
                class [13] <STRSXP[1]> ()
                  ...
        forced [14] <PROMSXP> ()
        _value [14] <REALSXP[1]> ()
        _code [15] <LANGSXP> ()
          ...
        delayed [16] <PROMSXP> ()
        _code [16] <LANGSXP> ()
          ...
        _env [5]
        missing [17] <missing> ()
        value [17] <REALSXP[1]> ()
        _enclos [18] <ENVSXP: empty> ()

# can inspect all atomic vectors

    Code
      sxp(x)
    Output
      [1] <VECSXP[6]> ()
        [2] <LGLSXP[1]> ()
        [3] <INTSXP[1]> ()
        [4] <REALSXP[1]> ()
        [5] <STRSXP[1]> ()
        [6] <CPLXSXP[1]> ()
        [7] <RAWSXP[1]> ()

# can inspect functions

    Code
      sxp(f)
    Output
      [1] <CLOSXP> ()
        _formals [2] <LISTSXP> ()
          x [3] <SYMSXP: > ()
          y [4] <REALSXP[1]> ()
          ... [3]
        _body [5] <LANGSXP> ()
          ...
        _env [6] <ENVSXP: global> ()

# can inspect environments

    Code
      print(sxp(e2))
    Output
      [1] <ENVSXP> ()
        _enclos [2] <ENVSXP> ()
          x [3] <REALSXP[1]> ()
          y [2]
          _enclos [4] <ENVSXP: empty> ()
    Code
      print(sxp(e2, expand = "environment", max_depth = 5L))
    Output
      [1] <ENVSXP> ()
        _enclos [2] <ENVSXP> ()
          x [3] <REALSXP[1]> ()
          y [2]
          _enclos [4] <ENVSXP: empty> ()

# can expand altrep

    Code
      x <- 1:10
      print(sxp(x, expand = "altrep", max_depth = 4L))
    Output
      [1] <INTSXP[10]> (altrep )
        _class [2] <RAWSXP[144]> ()
          _attrib [3] <LISTSXP> ()
            [4] <SYMSXP: compact_intseq> ()
            [5] <SYMSXP: base> ()
            [6] <INTSXP[1]> ()
        _data1 [7] <REALSXP[3]> ()
        _data2 [8] <NILSXP> ()

# can inspect cons cells

    Code
      cell <- new_node(1, 2)
      sxp(cell)
    Output
      [1] <LISTSXP> ()
        [2] <REALSXP[1]> ()
        _cdr [3] <REALSXP[1]> ()
    Code
      non_nil_terminated_list <- new_node(1, new_node(2, 3))
      sxp(non_nil_terminated_list)
    Output
      [1] <LISTSXP> ()
        [2] <REALSXP[1]> ()
        [3] <REALSXP[1]> ()
        _cdr [4] <REALSXP[1]> ()

# fix error message when `expand` argument contains invalid classes

    Code
      sxp(1, expand = "invalid_class")
    Condition
      Error in `sxp()`:
      ! `expand` must contain only values from: 'character', 'altrep', 'environment', 'call', 'bytecode'.

