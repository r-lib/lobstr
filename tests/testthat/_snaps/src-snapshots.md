# src() shows closure with srcref and wholeSrcref

    Code
      f <- simple_function_with_srcref()
      scrub_src(src(f))
    Output
      <closure>
      ├─attr("srcref"): <srcref>
      │ ├─location: 1:14-3:1
      │ └─attr("srcfile"): <srcfilecopy> @008
      │   ├─Enc: "unknown"
      │   ├─filename: "<scrubbed>"
      │   ├─fixedNewlines: TRUE
      │   ├─isFile: TRUE
      │   ├─lines<chr [3]>: "test_func <-...", "  x + y", "}"
      │   ├─parseData<int [160]>: 1, 1, 1, ...
      │   ├─timestamp: "<scrubbed>"
      │   └─wd: "/Users/lionel/Sync/Projects/R/r-..."
      └─body(): <{>
        ├─attr("srcref"): <list>
        │ ├─[[1]]: <srcref>
        │ │ ├─location: 1:29-1:29
        │ │ └─attr("srcfile"): @008
        │ └─[[2]]: <srcref>
        │   ├─location: 2:3-2:7
        │   └─attr("srcfile"): @008
        ├─attr("srcfile"): @008
        └─attr("wholeSrcref"): <srcref>
          ├─location: 1:0-3:1
          └─attr("srcfile"): @008

# src() shows multi-statement function

    Code
      f <- multi_statement_function_with_srcref()
      scrub_src(src(f))
    Output
      <closure>
      ├─attr("srcref"): <srcref>
      │ ├─location: 1:15-6:1
      │ └─attr("srcfile"): <srcfilecopy> @009
      │   ├─Enc: "unknown"
      │   ├─filename: "<scrubbed>"
      │   ├─fixedNewlines: TRUE
      │   ├─isFile: TRUE
      │   ├─lines<chr [6]>: "multi_func <...", "  a <- x + 1", "  b <- a * 2", ...
      │   ├─parseData<int [352]>: 1, 1, 1, ...
      │   ├─timestamp: "<scrubbed>"
      │   └─wd: "/Users/lionel/Sync/Projects/R/r-..."
      └─body(): <{>
        ├─attr("srcref"): <list>
        │ ├─[[1]]: <srcref>
        │ │ ├─location: 1:27-1:27
        │ │ └─attr("srcfile"): @009
        │ ├─[[2]]: <srcref>
        │ │ ├─location: 2:3-2:12
        │ │ └─attr("srcfile"): @009
        │ ├─[[3]]: <srcref>
        │ │ ├─location: 3:3-3:12
        │ │ └─attr("srcfile"): @009
        │ ├─[[4]]: <srcref>
        │ │ ├─location: 4:3-4:12
        │ │ └─attr("srcfile"): @009
        │ └─[[5]]: <srcref>
        │   ├─location: 5:3-5:3
        │   └─attr("srcfile"): @009
        ├─attr("srcfile"): @009
        └─attr("wholeSrcref"): <srcref>
          ├─location: 1:0-6:1
          └─attr("srcfile"): @009

# src() shows quoted function with nested body

    Code
      with_srcref("x <- quote(function() {})")
      scrub_src(src(x))
    Output
      <quoted_function>
      ├─[[3]]: <{>
      │ ├─attr("srcref"): <list>
      │ │ └─[[1]]: <srcref>
      │ │   ├─location: 1:23-1:23
      │ │   └─attr("srcfile"): <srcfilecopy> @010
      │ │     ├─Enc: "unknown"
      │ │     ├─filename: "<scrubbed>"
      │ │     ├─fixedNewlines: TRUE
      │ │     ├─isFile: TRUE
      │ │     ├─lines: "x <- quote(function() {})"
      │ │     ├─parseData<int [128]>: 1, 1, 1, ......
      │ │     ├─timestamp: "<scrubbed>"
      │ │     └─wd: "/Users/lionel/Sync/Projects/R/r-..."
      │ ├─attr("srcfile"): @010
      │ └─attr("wholeSrcref"): <srcref>
      │   ├─location: 1:0-1:24
      │   └─attr("srcfile"): @010
      └─[[4]]: <srcref>
        ├─location: 1:12-1:24
        └─attr("srcfile"): @010

# src() shows quoted function body directly

    Code
      with_srcref("x <- quote(function() {})")
      scrub_src(src(x[[3]]))
    Output
      <{>
      ├─attr("srcref"): <list>
      │ └─[[1]]: <srcref>
      │   ├─location: 1:23-1:23
      │   └─attr("srcfile"): <srcfilecopy> @011
      │     ├─Enc: "unknown"
      │     ├─filename: "<scrubbed>"
      │     ├─fixedNewlines: TRUE
      │     ├─isFile: TRUE
      │     ├─lines: "x <- quote(function() {})"
      │     ├─parseData<int [128]>: 1, 1, 1, ...
      │     ├─timestamp: "<scrubbed>"
      │     └─wd: "/Users/lionel/Sync/Projects/R/r-..."
      ├─attr("srcfile"): @011
      └─attr("wholeSrcref"): <srcref>
        ├─location: 1:0-1:24
        └─attr("srcfile"): @011

# src() shows quoted function with arguments

    Code
      with_srcref("x <- quote(function(a, b) { a + b })")
      scrub_src(src(x))
    Output
      <quoted_function>
      ├─[[3]]: <{>
      │ ├─attr("srcref"): <list>
      │ │ ├─[[1]]: <srcref>
      │ │ │ ├─location: 1:27-1:27
      │ │ │ └─attr("srcfile"): <srcfilecopy> @012
      │ │ │   ├─Enc: "unknown"
      │ │ │   ├─filename: "<scrubbed>"
      │ │ │   ├─fixedNewlines: TRUE
      │ │ │   ├─isFile: TRUE
      │ │ │   ├─lines: "x <- quote(function(a, b) { a +..."
      │ │ │   ├─parseData<int [200]>: 1, 1, 1, ......
      │ │ │   ├─timestamp: "<scrubbed>"
      │ │ │   └─wd: "/Users/lionel/Sync/Projects/R/r-..."
      │ │ └─[[2]]: <srcref>
      │ │   ├─location: 1:29-1:33
      │ │   └─attr("srcfile"): @012
      │ ├─attr("srcfile"): @012
      │ └─attr("wholeSrcref"): <srcref>
      │   ├─location: 1:0-1:35
      │   └─attr("srcfile"): @012
      └─[[4]]: <srcref>
        ├─location: 1:12-1:35
        └─attr("srcfile"): @012

# src() shows expression with single element

    Code
      x <- parse(text = "x + 1", keep.source = TRUE)
      scrub_src(src(x))
    Output
      <expression>
      ├─attr("srcref"): <list>
      │ └─[[1]]: <srcref>
      │   ├─location: 1:1-1:5
      │   └─attr("srcfile"): <srcfilecopy> @013
      │     ├─Enc: "unknown"
      │     ├─filename: "<scrubbed>"
      │     ├─fixedNewlines: TRUE
      │     ├─isFile: FALSE
      │     ├─lines: "x + 1"
      │     ├─parseData<int [48]>: 1, 1, 1, ...
      │     ├─timestamp: "<scrubbed>"
      │     └─wd: "/Users/lionel/Sync/Projects/R/r-..."
      ├─attr("srcfile"): @013
      └─attr("wholeSrcref"): <srcref>
        ├─location: 1:0-2:0
        └─attr("srcfile"): @013

# src() shows expression with multiple elements

    Code
      x <- parse(text = c("x + 1", "y + 2", "z + 3"), keep.source = TRUE)
      scrub_src(src(x))
    Output
      <expression>
      ├─attr("srcref"): <list>
      │ ├─[[1]]: <srcref>
      │ │ ├─location: 1:1-1:5
      │ │ └─attr("srcfile"): <srcfilecopy> @014
      │ │   ├─Enc: "unknown"
      │ │   ├─filename: "<scrubbed>"
      │ │   ├─fixedNewlines: TRUE
      │ │   ├─isFile: FALSE
      │ │   ├─lines<chr [3]>: "x + 1", "y + 2", "z + 3"
      │ │   ├─parseData<int [144]>: 1, 1, 1, ...
      │ │   ├─timestamp: "<scrubbed>"
      │ │   └─wd: "/Users/lionel/Sync/Projects/R/r-..."
      │ ├─[[2]]: <srcref>
      │ │ ├─location: 2:1-2:5
      │ │ └─attr("srcfile"): @014
      │ └─[[3]]: <srcref>
      │   ├─location: 3:1-3:5
      │   └─attr("srcfile"): @014
      ├─attr("srcfile"): @014
      └─attr("wholeSrcref"): <srcref>
        ├─location: 1:0-4:0
        └─attr("srcfile"): @014

# src() shows expression with nested block and wholeSrcref

    Code
      x <- parse(text = "{\n  1\n}", keep.source = TRUE)
      scrub_src(src(x))
    Output
      <expression>
      ├─attr("srcref"): <list>
      │ └─[[1]]: <srcref>
      │   ├─location: 1:1-3:1
      │   └─attr("srcfile"): <srcfilecopy> @015
      │     ├─Enc: "unknown"
      │     ├─filename: "<scrubbed>"
      │     ├─fixedNewlines: TRUE
      │     ├─isFile: FALSE
      │     ├─lines<chr [3]>: "{", "  1", "}"
      │     ├─parseData<int [40]>: 1, 1, 1, ...
      │     ├─timestamp: "<scrubbed>"
      │     └─wd: "/Users/lionel/Sync/Projects/R/r-..."
      ├─attr("srcfile"): @015
      ├─attr("wholeSrcref"): <srcref>
      │ ├─location: 1:0-4:0
      │ └─attr("srcfile"): @015
      └─[[1]]: <{>
        ├─attr("srcref"): <list>
        │ ├─[[1]]: <srcref>
        │ │ ├─location: 1:1-1:1
        │ │ └─attr("srcfile"): @015
        │ └─[[2]]: <srcref>
        │   ├─location: 2:3-2:3
        │   └─attr("srcfile"): @015
        ├─attr("srcfile"): @015
        └─attr("wholeSrcref"): <srcref>
          ├─location: 1:0-3:1
          └─attr("srcfile"): @015

# src() shows nested block element directly

    Code
      x <- parse(text = "{\n  1\n}", keep.source = TRUE)
      scrub_src(src(x[[1]]))
    Output
      <{>
      ├─attr("srcref"): <list>
      │ ├─[[1]]: <srcref>
      │ │ ├─location: 1:1-1:1
      │ │ └─attr("srcfile"): <srcfilecopy> @016
      │ │   ├─Enc: "unknown"
      │ │   ├─filename: "<scrubbed>"
      │ │   ├─fixedNewlines: TRUE
      │ │   ├─isFile: FALSE
      │ │   ├─lines<chr [3]>: "{", "  1", "}"
      │ │   ├─parseData<int [40]>: 1, 1, 1, ...
      │ │   ├─timestamp: "<scrubbed>"
      │ │   └─wd: "/Users/lionel/Sync/Projects/R/r-..."
      │ └─[[2]]: <srcref>
      │   ├─location: 2:3-2:3
      │   └─attr("srcfile"): @016
      ├─attr("srcfile"): @016
      └─attr("wholeSrcref"): <srcref>
        ├─location: 1:0-3:1
        └─attr("srcfile"): @016

# src() shows block with srcref list and wholeSrcref

    Code
      x <- parse(text = "{\n  a <- 1\n  b <- 2\n}", keep.source = TRUE)
      scrub_src(src(x[[1]]))
    Output
      <{>
      ├─attr("srcref"): <list>
      │ ├─[[1]]: <srcref>
      │ │ ├─location: 1:1-1:1
      │ │ └─attr("srcfile"): <srcfilecopy> @017
      │ │   ├─Enc: "unknown"
      │ │   ├─filename: "<scrubbed>"
      │ │   ├─fixedNewlines: TRUE
      │ │   ├─isFile: FALSE
      │ │   ├─lines<chr [4]>: "{", "  a <- 1", "  b <- 2", ...
      │ │   ├─parseData<int [120]>: 1, 1, 1, ...
      │ │   ├─timestamp: "<scrubbed>"
      │ │   └─wd: "/Users/lionel/Sync/Projects/R/r-..."
      │ ├─[[2]]: <srcref>
      │ │ ├─location: 2:3-2:8
      │ │ └─attr("srcfile"): @017
      │ └─[[3]]: <srcref>
      │   ├─location: 3:3-3:8
      │   └─attr("srcfile"): @017
      ├─attr("srcfile"): @017
      └─attr("wholeSrcref"): <srcref>
        ├─location: 1:0-4:1
        └─attr("srcfile"): @017

# src() shows single srcref

    Code
      x <- parse(text = "x + 1", keep.source = TRUE)
      sr <- attr(x, "srcref")[[1]]
      scrub_src(src(sr))
    Output
      <srcref>
      ├─location: 1:1-1:5
      └─attr("srcfile"): <srcfilecopy> @018
        ├─Enc: "unknown"
        ├─filename: "<scrubbed>"
        ├─fixedNewlines: TRUE
        ├─isFile: FALSE
        ├─lines: "x + 1"
        ├─parseData<int [48]>: 1, 1, 1, ...
        ├─timestamp: "<scrubbed>"
        └─wd: "/Users/lionel/Sync/Projects/R/r-..."

# src() shows list of srcrefs with count

    Code
      x <- parse(text = c("x + 1", "y + 2"), keep.source = TRUE)
      sr_list <- attr(x, "srcref")
      scrub_src(src(sr_list))
    Output
      <list>
      ├─count: 2
      └─srcrefs: <list>
        ├─<srcref>
        │ ├─location: 1:1-1:5
        │ └─attr("srcfile"): <srcfilecopy> @019
        │   ├─Enc: "unknown"
        │   ├─filename: "<scrubbed>"
        │   ├─fixedNewlines: TRUE
        │   ├─isFile: FALSE
        │   ├─lines<chr [2]>: "x + 1", "y + 2"
        │   ├─parseData<int [96]>: 1, 1, 1, ...
        │   ├─timestamp: "<scrubbed>"
        │   └─wd: "/Users/lionel/Sync/Projects/R/r-..."
        └─<srcref>
          ├─location: 2:1-2:5
          └─attr("srcfile"): @019

# src() reveals srcref list structure with index notation

    Code
      with_srcref("x <- quote(function() { 1 })")
      scrub_src(src(x[[3]]))
    Output
      <{>
      ├─attr("srcref"): <list>
      │ ├─[[1]]: <srcref>
      │ │ ├─location: 1:23-1:23
      │ │ └─attr("srcfile"): <srcfilecopy> @020
      │ │   ├─Enc: "unknown"
      │ │   ├─filename: "<scrubbed>"
      │ │   ├─fixedNewlines: TRUE
      │ │   ├─isFile: TRUE
      │ │   ├─lines: "x <- quote(function() { 1 })"
      │ │   ├─parseData<int [144]>: 1, 1, 1, ...
      │ │   ├─timestamp: "<scrubbed>"
      │ │   └─wd: "/Users/lionel/Sync/Projects/R/r-..."
      │ └─[[2]]: <srcref>
      │   ├─location: 1:25-1:25
      │   └─attr("srcfile"): @020
      ├─attr("srcfile"): @020
      └─attr("wholeSrcref"): <srcref>
        ├─location: 1:0-1:27
        └─attr("srcfile"): @020

# src() handles srcrefs nested in language calls

    Code
      x <- parse(text = "foo({ if (1) bar({ 2 }) })", keep.source = TRUE)
      scrub_src(src(x, max_depth = 10))
    Output
      <expression>
      ├─attr("srcref"): <list>
      │ └─[[1]]: <srcref>
      │   ├─location: 1:1-1:26
      │   └─attr("srcfile"): <srcfilecopy> @021
      │     ├─Enc: "unknown"
      │     ├─filename: "<scrubbed>"
      │     ├─fixedNewlines: TRUE
      │     ├─isFile: FALSE
      │     ├─lines: "foo({ if (1) bar({ 2 }) })"
      │     ├─parseData<int [192]>: 1, 1, 1, ...
      │     ├─timestamp: "<scrubbed>"
      │     └─wd: "/Users/lionel/Sync/Projects/R/r-..."
      ├─attr("srcfile"): @021
      ├─attr("wholeSrcref"): <srcref>
      │ ├─location: 1:0-2:0
      │ └─attr("srcfile"): @021
      └─[[1]][[2]]: <{>
        ├─attr("srcref"): <list>
        │ ├─[[1]]: <srcref>
        │ │ ├─location: 1:5-1:5
        │ │ └─attr("srcfile"): @021
        │ └─[[2]]: <srcref>
        │   ├─location: 1:7-1:23
        │   └─attr("srcfile"): @021
        ├─attr("srcfile"): @021
        ├─attr("wholeSrcref"): <srcref>
        │ ├─location: 1:0-1:25
        │ └─attr("srcfile"): @021
        └─[[2]][[3]][[2]]: <{>
          ├─attr("srcref"): <list>
          │ ├─[[1]]: <srcref>
          │ │ ├─location: 1:18-1:18
          │ │ └─attr("srcfile"): @021
          │ └─[[2]]: <srcref>
          │   ├─location: 1:20-1:20
          │   └─attr("srcfile"): @021
          ├─attr("srcfile"): @021
          └─attr("wholeSrcref"): <srcref>
            ├─location: 1:0-1:22
            └─attr("srcfile"): @021

# src() handles srcrefs nested in function bodies

    Code
      with_srcref("f <- function() foo({ if (1) bar({ 2 }) })")
      scrub_src(src(f, max_depth = 10))
    Output
      <closure>
      ├─attr("srcref"): <srcref>
      │ ├─location: 1:6-1:42
      │ └─attr("srcfile"): <srcfilecopy> @022
      │   ├─Enc: "unknown"
      │   ├─filename: "<scrubbed>"
      │   ├─fixedNewlines: TRUE
      │   ├─isFile: TRUE
      │   ├─lines: "f <- function() foo({ if (1) bar..."
      │   ├─parseData<int [256]>: 1, 1, 1, ...
      │   ├─timestamp: "<scrubbed>"
      │   └─wd: "/Users/lionel/Sync/Projects/R/r-..."
      └─body(): <language>
        └─[[2]]: <{>
          ├─attr("srcref"): <list>
          │ ├─[[1]]: <srcref>
          │ │ ├─location: 1:21-1:21
          │ │ └─attr("srcfile"): @022
          │ └─[[2]]: <srcref>
          │   ├─location: 1:23-1:39
          │   └─attr("srcfile"): @022
          ├─attr("srcfile"): @022
          ├─attr("wholeSrcref"): <srcref>
          │ ├─location: 1:0-1:41
          │ └─attr("srcfile"): @022
          └─[[2]][[3]][[2]]: <{>
            ├─attr("srcref"): <list>
            │ ├─[[1]]: <srcref>
            │ │ ├─location: 1:34-1:34
            │ │ └─attr("srcfile"): @022
            │ └─[[2]]: <srcref>
            │   ├─location: 1:36-1:36
            │   └─attr("srcfile"): @022
            ├─attr("srcfile"): @022
            └─attr("wholeSrcref"): <srcref>
              ├─location: 1:0-1:38
              └─attr("srcfile"): @022

# src() currently shows duplicate srcfile objects

    Code
      f <- simple_function_with_srcref()
      scrub_src(src(f))
    Output
      <closure>
      ├─attr("srcref"): <srcref>
      │ ├─location: 1:14-3:1
      │ └─attr("srcfile"): <srcfilecopy> @027
      │   ├─Enc: "unknown"
      │   ├─filename: "<scrubbed>"
      │   ├─fixedNewlines: TRUE
      │   ├─isFile: TRUE
      │   ├─lines<chr [3]>: "test_func <-...", "  x + y", "}"
      │   ├─parseData<int [160]>: 1, 1, 1, ...
      │   ├─timestamp: "<scrubbed>"
      │   └─wd: "/Users/lionel/Sync/Projects/R/r-..."
      └─body(): <{>
        ├─attr("srcref"): <list>
        │ ├─[[1]]: <srcref>
        │ │ ├─location: 1:29-1:29
        │ │ └─attr("srcfile"): @027
        │ └─[[2]]: <srcref>
        │   ├─location: 2:3-2:7
        │   └─attr("srcfile"): @027
        ├─attr("srcfile"): @027
        └─attr("wholeSrcref"): <srcref>
          ├─location: 1:0-3:1
          └─attr("srcfile"): @027

# src() shows many duplicate srcfiles in nested expression

    Code
      x <- parse(text = "{\n  1\n  2\n}", keep.source = TRUE)
      scrub_src(src(x))
    Output
      <expression>
      ├─attr("srcref"): <list>
      │ └─[[1]]: <srcref>
      │   ├─location: 1:1-4:1
      │   └─attr("srcfile"): <srcfilecopy> @028
      │     ├─Enc: "unknown"
      │     ├─filename: "<scrubbed>"
      │     ├─fixedNewlines: TRUE
      │     ├─isFile: FALSE
      │     ├─lines<chr [4]>: "{", "  1", "  2", ...
      │     ├─parseData<int [56]>: 1, 1, 1, ...
      │     ├─timestamp: "<scrubbed>"
      │     └─wd: "/Users/lionel/Sync/Projects/R/r-..."
      ├─attr("srcfile"): @028
      ├─attr("wholeSrcref"): <srcref>
      │ ├─location: 1:0-5:0
      │ └─attr("srcfile"): @028
      └─[[1]]: <{>
        ├─attr("srcref"): <list>
        │ ├─[[1]]: <srcref>
        │ │ ├─location: 1:1-1:1
        │ │ └─attr("srcfile"): @028
        │ ├─[[2]]: <srcref>
        │ │ ├─location: 2:3-2:3
        │ │ └─attr("srcfile"): @028
        │ └─[[3]]: <srcref>
        │   ├─location: 3:3-3:3
        │   └─attr("srcfile"): @028
        ├─attr("srcfile"): @028
        └─attr("wholeSrcref"): <srcref>
          ├─location: 1:0-4:1
          └─attr("srcfile"): @028

# src() handles empty block

    Code
      x <- parse(text = "{}", keep.source = TRUE)
      scrub_src(src(x[[1]]))
    Output
      <{>
      ├─attr("srcref"): <list>
      │ └─[[1]]: <srcref>
      │   ├─location: 1:1-1:1
      │   └─attr("srcfile"): <srcfilecopy> @029
      │     ├─Enc: "unknown"
      │     ├─filename: "<scrubbed>"
      │     ├─fixedNewlines: TRUE
      │     ├─isFile: FALSE
      │     ├─lines: "{}"
      │     ├─parseData<int [24]>: 1, 1, 1, ...
      │     ├─timestamp: "<scrubbed>"
      │     └─wd: "/Users/lionel/Sync/Projects/R/r-..."
      ├─attr("srcfile"): @029
      └─attr("wholeSrcref"): <srcref>
        ├─location: 1:0-1:2
        └─attr("srcfile"): @029

# src() handles function without arguments

    Code
      with_srcref("f <- function() { NULL }")
      scrub_src(src(f))
    Output
      <closure>
      ├─attr("srcref"): <srcref>
      │ ├─location: 1:6-1:24
      │ └─attr("srcfile"): <srcfilecopy> @030
      │   ├─Enc: "unknown"
      │   ├─filename: "<scrubbed>"
      │   ├─fixedNewlines: TRUE
      │   ├─isFile: TRUE
      │   ├─lines: "f <- function() { NULL }"
      │   ├─parseData<int [104]>: 1, 1, 1, ...
      │   ├─timestamp: "<scrubbed>"
      │   └─wd: "/Users/lionel/Sync/Projects/R/r-..."
      └─body(): <{>
        ├─attr("srcref"): <list>
        │ ├─[[1]]: <srcref>
        │ │ ├─location: 1:17-1:17
        │ │ └─attr("srcfile"): @030
        │ └─[[2]]: <srcref>
        │   ├─location: 1:19-1:22
        │   └─attr("srcfile"): @030
        ├─attr("srcfile"): @030
        └─attr("wholeSrcref"): <srcref>
          ├─location: 1:0-1:24
          └─attr("srcfile"): @030

# src() handles if statement with blocks

    Code
      x <- parse(text = "if (TRUE) { 1 } else { 2 }", keep.source = TRUE)
      scrub_src(src(x))
    Output
      <expression>
      ├─attr("srcref"): <list>
      │ └─[[1]]: <srcref>
      │   ├─location: 1:1-1:26
      │   └─attr("srcfile"): <srcfilecopy> @031
      │     ├─Enc: "unknown"
      │     ├─filename: "<scrubbed>"
      │     ├─fixedNewlines: TRUE
      │     ├─isFile: FALSE
      │     ├─lines: "if (TRUE) { 1 } else { 2 }"
      │     ├─parseData<int [136]>: 1, 1, 1, ...
      │     ├─timestamp: "<scrubbed>"
      │     └─wd: "/Users/lionel/Sync/Projects/R/r-..."
      ├─attr("srcfile"): @031
      ├─attr("wholeSrcref"): <srcref>
      │ ├─location: 1:0-2:0
      │ └─attr("srcfile"): @031
      ├─[[1]][[3]]: <{>
      │ ├─attr("srcref"): <list>
      │ │ ├─[[1]]: <srcref>
      │ │ │ ├─location: 1:11-1:11
      │ │ │ └─attr("srcfile"): @031
      │ │ └─[[2]]: <srcref>
      │ │   ├─location: 1:13-1:13
      │ │   └─attr("srcfile"): @031
      │ ├─attr("srcfile"): @031
      │ └─attr("wholeSrcref"): <srcref>
      │   ├─location: 1:0-1:15
      │   └─attr("srcfile"): @031
      └─[[1]][[4]]: <{>
        ├─attr("srcref"): <list>
        │ ├─[[1]]: <srcref>
        │ │ ├─location: 1:22-1:22
        │ │ └─attr("srcfile"): @031
        │ └─[[2]]: <srcref>
        │   ├─location: 1:24-1:24
        │   └─attr("srcfile"): @031
        ├─attr("srcfile"): @031
        └─attr("wholeSrcref"): <srcref>
          ├─location: 1:0-1:26
          └─attr("srcfile"): @031

# src() respects max_vec_len parameter

    Code
      x <- parse(text = paste(rep("1", 10), collapse = "\n"), keep.source = TRUE)
      scrub_src(src(x, max_vec_len = 2))
    Output
      <expression>
      ├─attr("srcref"): <list>
      │ ├─[[1]]: <srcref>
      │ │ ├─location: 1:1-1:1
      │ │ └─attr("srcfile"): <srcfilecopy> @032
      │ │   ├─Enc: "unknown"
      │ │   ├─filename: "<scrubbed>"
      │ │   ├─fixedNewlines: TRUE
      │ │   ├─isFile: FALSE
      │ │   ├─lines<chr [10]>: "1", "1", ...
      │ │   ├─parseData<int [160]>: 1, 1, ...
      │ │   ├─timestamp: "<scrubbed>"
      │ │   └─wd: "/Users/lionel/Sync/Projects/R/r-..."
      │ ├─[[2]]: <srcref>
      │ │ ├─location: 2:1-2:1
      │ │ └─attr("srcfile"): @032
      │ ├─[[3]]: <srcref>
      │ │ ├─location: 3:1-3:1
      │ │ └─attr("srcfile"): @032
      │ ├─[[4]]: <srcref>
      │ │ ├─location: 4:1-4:1
      │ │ └─attr("srcfile"): @032
      │ ├─[[5]]: <srcref>
      │ │ ├─location: 5:1-5:1
      │ │ └─attr("srcfile"): @032
      │ ├─[[6]]: <srcref>
      │ │ ├─location: 6:1-6:1
      │ │ └─attr("srcfile"): @032
      │ ├─[[7]]: <srcref>
      │ │ ├─location: 7:1-7:1
      │ │ └─attr("srcfile"): @032
      │ ├─[[8]]: <srcref>
      │ │ ├─location: 8:1-8:1
      │ │ └─attr("srcfile"): @032
      │ ├─[[9]]: <srcref>
      │ │ ├─location: 9:1-9:1
      │ │ └─attr("srcfile"): @032
      │ └─[[10]]: <srcref>
      │   ├─location: 10:1-10:1
      │   └─attr("srcfile"): @032
      ├─attr("srcfile"): @032
      └─attr("wholeSrcref"): <srcref>
        ├─location: 1:0-11:0
        └─attr("srcfile"): @032

# src() respects show_source_lines parameter

    Code
      f <- simple_function_with_srcref()
      scrub_src(src(f))
    Output
      <closure>
      ├─attr("srcref"): <srcref>
      │ ├─location: 1:14-3:1
      │ └─attr("srcfile"): <srcfilecopy> @033
      │   ├─Enc: "unknown"
      │   ├─filename: "<scrubbed>"
      │   ├─fixedNewlines: TRUE
      │   ├─isFile: TRUE
      │   ├─lines<chr [3]>: "test_func <-...", "  x + y", "}"
      │   ├─parseData<int [160]>: 1, 1, 1, ...
      │   ├─timestamp: "<scrubbed>"
      │   └─wd: "/Users/lionel/Sync/Projects/R/r-..."
      └─body(): <{>
        ├─attr("srcref"): <list>
        │ ├─[[1]]: <srcref>
        │ │ ├─location: 1:29-1:29
        │ │ └─attr("srcfile"): @033
        │ └─[[2]]: <srcref>
        │   ├─location: 2:3-2:7
        │   └─attr("srcfile"): @033
        ├─attr("srcfile"): @033
        └─attr("wholeSrcref"): <srcref>
          ├─location: 1:0-3:1
          └─attr("srcfile"): @033

# src() shows expression with multiple nested blocks

    Code
      x <- parse(text = "{\n  {\n    1\n  }\n  {\n    2\n  }\n}", keep.source = TRUE)
      scrub_src(src(x))
    Output
      <expression>
      ├─attr("srcref"): <list>
      │ └─[[1]]: <srcref>
      │   ├─location: 1:1-8:1
      │   └─attr("srcfile"): <srcfilecopy> @034
      │     ├─Enc: "unknown"
      │     ├─filename: "<scrubbed>"
      │     ├─fixedNewlines: TRUE
      │     ├─isFile: FALSE
      │     ├─lines<chr [8]>: "{", "  {", "    1", ...
      │     ├─parseData<int [104]>: 1, 1, 1, ...
      │     ├─timestamp: "<scrubbed>"
      │     └─wd: "/Users/lionel/Sync/Projects/R/r-..."
      ├─attr("srcfile"): @034
      ├─attr("wholeSrcref"): <srcref>
      │ ├─location: 1:0-9:0
      │ └─attr("srcfile"): @034
      └─[[1]]: <{>
        ├─attr("srcref"): <list>
        │ ├─[[1]]: <srcref>
        │ │ ├─location: 1:1-1:1
        │ │ └─attr("srcfile"): @034
        │ ├─[[2]]: <srcref>
        │ │ ├─location: 2:3-4:3
        │ │ └─attr("srcfile"): @034
        │ └─[[3]]: <srcref>
        │   ├─location: 5:3-7:3
        │   └─attr("srcfile"): @034
        ├─attr("srcfile"): @034
        ├─attr("wholeSrcref"): <srcref>
        │ ├─location: 1:0-8:1
        │ └─attr("srcfile"): @034
        ├─[[2]]: <{>
        │ ├─attr("srcref"): <list>
        │ │ ├─[[1]]: <srcref>
        │ │ │ ├─location: 2:3-2:3
        │ │ │ └─attr("srcfile"): @034
        │ │ └─[[2]]: <srcref>
        │ │   ├─location: 3:5-3:5
        │ │   └─attr("srcfile"): @034
        │ ├─attr("srcfile"): @034
        │ └─attr("wholeSrcref"): <srcref>
        │   ├─location: 1:0-4:3
        │   └─attr("srcfile"): @034
        └─[[3]]: <{>
          ├─attr("srcref"): <list>
          │ ├─[[1]]: <srcref>
          │ │ ├─location: 5:3-5:3
          │ │ └─attr("srcfile"): @034
          │ └─[[2]]: <srcref>
          │   ├─location: 6:5-6:5
          │   └─attr("srcfile"): @034
          ├─attr("srcfile"): @034
          └─attr("wholeSrcref"): <srcref>
            ├─location: 1:0-7:3
            └─attr("srcfile"): @034

# src() shows function with nested block in body

    Code
      with_srcref("f <- function(x) {\n  if (x) {\n    1\n  }\n}")
      scrub_src(src(f))
    Output
      <closure>
      ├─attr("srcref"): <srcref>
      │ ├─location: 1:6-5:1
      │ └─attr("srcfile"): <srcfilecopy> @035
      │   ├─Enc: "unknown"
      │   ├─filename: "<scrubbed>"
      │   ├─fixedNewlines: TRUE
      │   ├─isFile: TRUE
      │   ├─lines<chr [5]>: "f <- functio...", "  if (x) {", "    1", ...
      │   ├─parseData<int [184]>: 1, 1, 1, ...
      │   ├─timestamp: "<scrubbed>"
      │   └─wd: "/Users/lionel/Sync/Projects/R/r-..."
      └─body(): <{>
        ├─attr("srcref"): <list>
        │ ├─[[1]]: <srcref>
        │ │ ├─location: 1:18-1:18
        │ │ └─attr("srcfile"): @035
        │ └─[[2]]: <srcref>
        │   ├─location: 2:3-4:3
        │   └─attr("srcfile"): @035
        ├─attr("srcfile"): @035
        ├─attr("wholeSrcref"): <srcref>
        │ ├─location: 1:0-5:1
        │ └─attr("srcfile"): @035
        └─[[2]][[3]]: <{>
          ├─attr("srcref"): <list>
          │ ├─[[1]]: <srcref>
          │ │ ├─location: 2:10-2:10
          │ │ └─attr("srcfile"): @035
          │ └─[[2]]: <srcref>
          │   ├─location: 3:5-3:5
          │   └─attr("srcfile"): @035
          ├─attr("srcfile"): @035
          └─attr("wholeSrcref"): <srcref>
            ├─location: 1:0-4:3
            └─attr("srcfile"): @035

