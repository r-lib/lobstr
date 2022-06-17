# basic list display

    Code
      x <- 1:10
      y <- list(x, x)
      ref(x, list(), list(x, x, x), list(a = x, b = x), letters)
    Output
      [1:0x001] <int> 
       
      █ [2:0x002] <list> 
       
      █ [3:0x003] <list> 
      ├─[1:0x001] 
      ├─[1:0x001] 
      └─[1:0x001] 
       
      █ [4:0x004] <named list> 
      ├─a = [1:0x001] 
      └─b = [1:0x001] 
       
      [5:0x005] <chr> 

# basic environment display

    Code
      e <- env(a = 1:10)
      e$b <- e$a
      e$c <- e
      ref(e)
    Output
      █ [1:0x001] <env> 
      ├─a = [2:0x002] <int> 
      ├─b = [2:0x002] 
      └─c = [1:0x001] 

# environment shows objects beginning with .

    Code
      e <- env(. = 1:10)
      ref(e)
    Output
      █ [1:0x001] <env> 
      └─. = [2:0x002] <int> 

# can display ref to global string pool on request

    Code
      ref(c("string", "string", "new string"), character = TRUE)
    Output
      █ [1:0x001] <chr> 
      ├─[2:0x002] <string: "string"> 
      ├─[2:0x002] 
      └─[3:0x003] <string: "new string"> 

