# can print complex expression

    Code
      ast(!!x)
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
      ast(!!x)
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
      ast(!!x)
    Output
      o-list 
      +-logical = o-c 
      |           +-FALSE 
      |           +-TRUE 
      |           \-NA 
      +-integer = 1L 
      +-double = 1 
      +-character = "a" 
      \-complex = 1i 

