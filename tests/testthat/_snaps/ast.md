# can print complex expression

    Code
      ast(function(x) if (x > 1) f(y$x, "x", g()))
    Output
      █─`function` 
      ├─█─x = `` 
      ├─█─`if` 
      │ ├─█─`>` 
      │ │ ├─x 
      │ │ └─1 
      │ └─█─f 
      │   ├─█─`$` 
      │   │ ├─y 
      │   │ └─x 
      │   ├─"x" 
      │   └─█─g 
      └─<inline srcref> 

# can print complex expression without unicode

    Code
      ast(function(x) if (x > 1) f(y$x, "x", g()))
    Output
      o-`function` 
      +-o-x = `` 
      +-o-`if` 
      | +-o-`>` 
      | | +-x 
      | | \-1 
      | \-o-f 
      |   +-o-`$` 
      |   | +-y 
      |   | \-x 
      |   +-"x" 
      |   \-o-g 
      \-<inline srcref> 

# can print scalar expressions nicely

    Code
      ast(list(logical = c(FALSE, TRUE, NA), integer = 1L, double = 1, character = "a",
      complex = 0+1i))
    Output
      o-list 
      +-logical = o-c 
      |           +-FALSE 
      |           +-TRUE 
      |           \-NA 
      +-integer = 1L 
      +-double = 1 
      +-character = "a" 
      \-complex = o-`+` 
                  +-0 
                  \-1i 

