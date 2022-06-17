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
        _frame <NILSXP>
        _hashtab [3] <VECSXP[5]> ()
          <NILSXP>
          <NILSXP>
          <NILSXP>
          <NILSXP>
          <NILSXP>
        _enclos [4] <ENVSXP> ()
          _frame <NILSXP>
          _hashtab [5] <VECSXP[5/2]> ()
            [6] <LISTSXP> ()
              x [7] <REALSXP[1]> ()
            [8] <LISTSXP> ()
              y [4]
            <NILSXP>
            <NILSXP>
            <NILSXP>
          _enclos [9] <ENVSXP: empty> ()

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
        _data2 <NILSXP>

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

