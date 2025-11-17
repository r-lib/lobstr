# src() shows closure with srcref and wholeSrcref

    Code
      f <- simple_function_with_srcref()
      scrub_src(src(f))
    Output
      <closure>
      ├─attr("srcref"): <srcref>
      │ ├─location: 1:14 - 3:1
      │ └─attr("srcfile"): <srcfilecopy> @001
      │   ├─Enc: "unknown"
      │   ├─filename: "<scrubbed>"
      │   ├─fixedNewlines: TRUE
      │   ├─isFile: TRUE
      │   ├─lines<chr [3]>: "test_func <-...", "  x + y", "}"
      │   ├─parseData<int [160]>: 1, 1, 1, ...
      │   ├─timestamp: "<scrubbed>"
      │   └─wd: "<scrubbed>"
      └─body(): <{>
        ├─attr("srcref"): <list>
        │ ├─[[1]]: <srcref>
        │ │ ├─location: 1:29 - 1:29
        │ │ └─attr("srcfile"): @001
        │ └─[[2]]: <srcref>
        │   ├─location: 2:3 - 2:7
        │   └─attr("srcfile"): @001
        ├─attr("srcfile"): @001
        └─attr("wholeSrcref"): <srcref>
          ├─location: 1:0 - 3:1
          └─attr("srcfile"): @001

# src() shows multi-statement function

    Code
      f <- multi_statement_function_with_srcref()
      scrub_src(src(f))
    Output
      <closure>
      ├─attr("srcref"): <srcref>
      │ ├─location: 1:15 - 6:1
      │ └─attr("srcfile"): <srcfilecopy> @001
      │   ├─Enc: "unknown"
      │   ├─filename: "<scrubbed>"
      │   ├─fixedNewlines: TRUE
      │   ├─isFile: TRUE
      │   ├─lines<chr [6]>: "multi_func <...", "  a <- x + 1", "  b <- a * 2", ...
      │   ├─parseData<int [352]>: 1, 1, 1, ...
      │   ├─timestamp: "<scrubbed>"
      │   └─wd: "<scrubbed>"
      └─body(): <{>
        ├─attr("srcref"): <list>
        │ ├─[[1]]: <srcref>
        │ │ ├─location: 1:27 - 1:27
        │ │ └─attr("srcfile"): @001
        │ ├─[[2]]: <srcref>
        │ │ ├─location: 2:3 - 2:12
        │ │ └─attr("srcfile"): @001
        │ ├─[[3]]: <srcref>
        │ │ ├─location: 3:3 - 3:12
        │ │ └─attr("srcfile"): @001
        │ ├─[[4]]: <srcref>
        │ │ ├─location: 4:3 - 4:12
        │ │ └─attr("srcfile"): @001
        │ └─[[5]]: <srcref>
        │   ├─location: 5:3 - 5:3
        │   └─attr("srcfile"): @001
        ├─attr("srcfile"): @001
        └─attr("wholeSrcref"): <srcref>
          ├─location: 1:0 - 6:1
          └─attr("srcfile"): @001

# src() shows quoted function with nested body

    Code
      with_srcref("x <- quote(function() {})")
      scrub_src(src(x))
    Output
      <quoted_function>
      ├─[[3]]: <{>
      │ ├─attr("srcref"): <list>
      │ │ └─[[1]]: <srcref>
      │ │   ├─location: 1:23 - 1:23
      │ │   └─attr("srcfile"): <srcfilecopy> @001
      │ │     ├─Enc: "unknown"
      │ │     ├─filename: "<scrubbed>"
      │ │     ├─fixedNewlines: TRUE
      │ │     ├─isFile: TRUE
      │ │     ├─lines: "x <- quote(function() {})"
      │ │     ├─parseData<int [128]>: 1, 1, 1, ......
      │ │     ├─timestamp: "<scrubbed>"
      │ │     └─wd: "<scrubbed>"
      │ ├─attr("srcfile"): @001
      │ └─attr("wholeSrcref"): <srcref>
      │   ├─location: 1:0 - 1:24
      │   └─attr("srcfile"): @001
      └─[[4]]: <srcref>
        ├─location: 1:12 - 1:24
        └─attr("srcfile"): @001

# src() shows quoted function body directly

    Code
      with_srcref("x <- quote(function() {})")
      scrub_src(src(x[[3]]))
    Output
      <{>
      ├─attr("srcref"): <list>
      │ └─[[1]]: <srcref>
      │   ├─location: 1:23 - 1:23
      │   └─attr("srcfile"): <srcfilecopy> @001
      │     ├─Enc: "unknown"
      │     ├─filename: "<scrubbed>"
      │     ├─fixedNewlines: TRUE
      │     ├─isFile: TRUE
      │     ├─lines: "x <- quote(function() {})"
      │     ├─parseData<int [128]>: 1, 1, 1, ...
      │     ├─timestamp: "<scrubbed>"
      │     └─wd: "<scrubbed>"
      ├─attr("srcfile"): @001
      └─attr("wholeSrcref"): <srcref>
        ├─location: 1:0 - 1:24
        └─attr("srcfile"): @001

# src() shows quoted function with arguments

    Code
      with_srcref("x <- quote(function(a, b) {})")
      scrub_src(src(x))
    Output
      <quoted_function>
      ├─[[3]]: <{>
      │ ├─attr("srcref"): <list>
      │ │ └─[[1]]: <srcref>
      │ │   ├─location: 1:27 - 1:27
      │ │   └─attr("srcfile"): <srcfilecopy> @001
      │ │     ├─Enc: "unknown"
      │ │     ├─filename: "<scrubbed>"
      │ │     ├─fixedNewlines: TRUE
      │ │     ├─isFile: TRUE
      │ │     ├─lines: "x <- quote(function(a, b) {})"
      │ │     ├─parseData<int [152]>: 1, 1, 1, ......
      │ │     ├─timestamp: "<scrubbed>"
      │ │     └─wd: "<scrubbed>"
      │ ├─attr("srcfile"): @001
      │ └─attr("wholeSrcref"): <srcref>
      │   ├─location: 1:0 - 1:28
      │   └─attr("srcfile"): @001
      └─[[4]]: <srcref>
        ├─location: 1:12 - 1:28
        └─attr("srcfile"): @001

# src() shows srcref with parsed field when positions differ

    Code
      srcfile <- srcfilecopy("test.R", c("x <- function() {",
        "  # A long comment that spans", "  # multiple lines", "  y <- 1", "}"))
      synthetic_srcref <- structure(c(2L, 3L, 4L, 8L, 3L, 8L, 1L, 5L), class = "srcref",
      srcfile = srcfile)
      scrub_src(src(synthetic_srcref))
    Output
      <srcref>
      ├─location: 2:3 - 4:8
      ├─parsed: 1:3 - 5:8
      └─attr("srcfile"): <srcfilecopy> @001
        ├─Enc: "unknown"
        ├─filename: "<scrubbed>"
        ├─fixedNewlines: TRUE
        ├─isFile: FALSE
        ├─lines<chr [5]>: "x <- functio...", "  # A long c...", "  # multiple...", ...
        ├─timestamp: "<scrubbed>"
        └─wd: "<scrubbed>"

# src() shows expression with single element

    Code
      x <- parse(text = "x + 1", keep.source = TRUE)
      scrub_src(src(x))
    Output
      <expression>
      ├─attr("srcref"): <list>
      │ └─[[1]]: <srcref>
      │   ├─location: 1:1 - 1:5
      │   └─attr("srcfile"): <srcfilecopy> @001
      │     ├─Enc: "unknown"
      │     ├─filename: "<scrubbed>"
      │     ├─fixedNewlines: TRUE
      │     ├─isFile: FALSE
      │     ├─lines: "x + 1"
      │     ├─parseData<int [48]>: 1, 1, 1, ...
      │     ├─timestamp: "<scrubbed>"
      │     └─wd: "<scrubbed>"
      ├─attr("srcfile"): @001
      └─attr("wholeSrcref"): <srcref>
        ├─location: 1:0 - 2:0
        └─attr("srcfile"): @001

# src() shows expression with multiple elements

    Code
      x <- parse(text = c("x + 1", "y + 2", "z + 3"), keep.source = TRUE)
      scrub_src(src(x))
    Output
      <expression>
      ├─attr("srcref"): <list>
      │ ├─[[1]]: <srcref>
      │ │ ├─location: 1:1 - 1:5
      │ │ └─attr("srcfile"): <srcfilecopy> @001
      │ │   ├─Enc: "unknown"
      │ │   ├─filename: "<scrubbed>"
      │ │   ├─fixedNewlines: TRUE
      │ │   ├─isFile: FALSE
      │ │   ├─lines<chr [3]>: "x + 1", "y + 2", "z + 3"
      │ │   ├─parseData<int [144]>: 1, 1, 1, ...
      │ │   ├─timestamp: "<scrubbed>"
      │ │   └─wd: "<scrubbed>"
      │ ├─[[2]]: <srcref>
      │ │ ├─location: 2:1 - 2:5
      │ │ └─attr("srcfile"): @001
      │ └─[[3]]: <srcref>
      │   ├─location: 3:1 - 3:5
      │   └─attr("srcfile"): @001
      ├─attr("srcfile"): @001
      └─attr("wholeSrcref"): <srcref>
        ├─location: 1:0 - 4:0
        └─attr("srcfile"): @001

# src() shows expression with nested block and wholeSrcref

    Code
      x <- parse(text = "{\n  1\n}", keep.source = TRUE)
      scrub_src(src(x))
    Output
      <expression>
      ├─attr("srcref"): <list>
      │ └─[[1]]: <srcref>
      │   ├─location: 1:1 - 3:1
      │   └─attr("srcfile"): <srcfilecopy> @001
      │     ├─Enc: "unknown"
      │     ├─filename: "<scrubbed>"
      │     ├─fixedNewlines: TRUE
      │     ├─isFile: FALSE
      │     ├─lines<chr [3]>: "{", "  1", "}"
      │     ├─parseData<int [40]>: 1, 1, 1, ...
      │     ├─timestamp: "<scrubbed>"
      │     └─wd: "<scrubbed>"
      ├─attr("srcfile"): @001
      ├─attr("wholeSrcref"): <srcref>
      │ ├─location: 1:0 - 4:0
      │ └─attr("srcfile"): @001
      └─[[1]]: <{>
        ├─attr("srcref"): <list>
        │ ├─[[1]]: <srcref>
        │ │ ├─location: 1:1 - 1:1
        │ │ └─attr("srcfile"): @001
        │ └─[[2]]: <srcref>
        │   ├─location: 2:3 - 2:3
        │   └─attr("srcfile"): @001
        ├─attr("srcfile"): @001
        └─attr("wholeSrcref"): <srcref>
          ├─location: 1:0 - 3:1
          └─attr("srcfile"): @001

# src() shows nested block element directly

    Code
      x <- parse(text = "{\n  1\n}", keep.source = TRUE)
      scrub_src(src(x[[1]]))
    Output
      <{>
      ├─attr("srcref"): <list>
      │ ├─[[1]]: <srcref>
      │ │ ├─location: 1:1 - 1:1
      │ │ └─attr("srcfile"): <srcfilecopy> @001
      │ │   ├─Enc: "unknown"
      │ │   ├─filename: "<scrubbed>"
      │ │   ├─fixedNewlines: TRUE
      │ │   ├─isFile: FALSE
      │ │   ├─lines<chr [3]>: "{", "  1", "}"
      │ │   ├─parseData<int [40]>: 1, 1, 1, ...
      │ │   ├─timestamp: "<scrubbed>"
      │ │   └─wd: "<scrubbed>"
      │ └─[[2]]: <srcref>
      │   ├─location: 2:3 - 2:3
      │   └─attr("srcfile"): @001
      ├─attr("srcfile"): @001
      └─attr("wholeSrcref"): <srcref>
        ├─location: 1:0 - 3:1
        └─attr("srcfile"): @001

# src() shows block with srcref list and wholeSrcref

    Code
      x <- parse(text = "{\n  a <- 1\n  b <- 2\n}", keep.source = TRUE)
      scrub_src(src(x[[1]]))
    Output
      <{>
      ├─attr("srcref"): <list>
      │ ├─[[1]]: <srcref>
      │ │ ├─location: 1:1 - 1:1
      │ │ └─attr("srcfile"): <srcfilecopy> @001
      │ │   ├─Enc: "unknown"
      │ │   ├─filename: "<scrubbed>"
      │ │   ├─fixedNewlines: TRUE
      │ │   ├─isFile: FALSE
      │ │   ├─lines<chr [4]>: "{", "  a <- 1", "  b <- 2", ...
      │ │   ├─parseData<int [120]>: 1, 1, 1, ...
      │ │   ├─timestamp: "<scrubbed>"
      │ │   └─wd: "<scrubbed>"
      │ ├─[[2]]: <srcref>
      │ │ ├─location: 2:3 - 2:8
      │ │ └─attr("srcfile"): @001
      │ └─[[3]]: <srcref>
      │   ├─location: 3:3 - 3:8
      │   └─attr("srcfile"): @001
      ├─attr("srcfile"): @001
      └─attr("wholeSrcref"): <srcref>
        ├─location: 1:0 - 4:1
        └─attr("srcfile"): @001

# src() shows single srcref

    Code
      x <- parse(text = "x + 1", keep.source = TRUE)
      sr <- attr(x, "srcref")[[1]]
      scrub_src(src(sr))
    Output
      <srcref>
      ├─location: 1:1 - 1:5
      └─attr("srcfile"): <srcfilecopy> @001
        ├─Enc: "unknown"
        ├─filename: "<scrubbed>"
        ├─fixedNewlines: TRUE
        ├─isFile: FALSE
        ├─lines: "x + 1"
        ├─parseData<int [48]>: 1, 1, 1, ...
        ├─timestamp: "<scrubbed>"
        └─wd: "<scrubbed>"

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
        │ ├─location: 1:1 - 1:5
        │ └─attr("srcfile"): <srcfilecopy> @001
        │   ├─Enc: "unknown"
        │   ├─filename: "<scrubbed>"
        │   ├─fixedNewlines: TRUE
        │   ├─isFile: FALSE
        │   ├─lines<chr [2]>: "x + 1", "y + 2"
        │   ├─parseData<int [96]>: 1, 1, 1, ...
        │   ├─timestamp: "<scrubbed>"
        │   └─wd: "<scrubbed>"
        └─<srcref>
          ├─location: 2:1 - 2:5
          └─attr("srcfile"): @001

# src() reveals srcref list structure with index notation

    Code
      with_srcref("x <- quote(function() { 1 })")
      scrub_src(src(x[[3]]))
    Output
      <{>
      ├─attr("srcref"): <list>
      │ ├─[[1]]: <srcref>
      │ │ ├─location: 1:23 - 1:23
      │ │ └─attr("srcfile"): <srcfilecopy> @001
      │ │   ├─Enc: "unknown"
      │ │   ├─filename: "<scrubbed>"
      │ │   ├─fixedNewlines: TRUE
      │ │   ├─isFile: TRUE
      │ │   ├─lines: "x <- quote(function() { 1 })"
      │ │   ├─parseData<int [144]>: 1, 1, 1, ...
      │ │   ├─timestamp: "<scrubbed>"
      │ │   └─wd: "<scrubbed>"
      │ └─[[2]]: <srcref>
      │   ├─location: 1:25 - 1:25
      │   └─attr("srcfile"): @001
      ├─attr("srcfile"): @001
      └─attr("wholeSrcref"): <srcref>
        ├─location: 1:0 - 1:27
        └─attr("srcfile"): @001

# src() handles srcrefs nested in language calls

    Code
      x <- parse(text = "foo({ if (1) bar({ 2 }) })", keep.source = TRUE)
      scrub_src(src(x, max_depth = 10))
    Output
      <expression>
      ├─attr("srcref"): <list>
      │ └─[[1]]: <srcref>
      │   ├─location: 1:1 - 1:26
      │   └─attr("srcfile"): <srcfilecopy> @001
      │     ├─Enc: "unknown"
      │     ├─filename: "<scrubbed>"
      │     ├─fixedNewlines: TRUE
      │     ├─isFile: FALSE
      │     ├─lines: "foo({ if (1) bar({ 2 }) })"
      │     ├─parseData<int [192]>: 1, 1, 1, ...
      │     ├─timestamp: "<scrubbed>"
      │     └─wd: "<scrubbed>"
      ├─attr("srcfile"): @001
      ├─attr("wholeSrcref"): <srcref>
      │ ├─location: 1:0 - 2:0
      │ └─attr("srcfile"): @001
      └─[[1]][[2]]: <{>
        ├─attr("srcref"): <list>
        │ ├─[[1]]: <srcref>
        │ │ ├─location: 1:5 - 1:5
        │ │ └─attr("srcfile"): @001
        │ └─[[2]]: <srcref>
        │   ├─location: 1:7 - 1:23
        │   └─attr("srcfile"): @001
        ├─attr("srcfile"): @001
        ├─attr("wholeSrcref"): <srcref>
        │ ├─location: 1:0 - 1:25
        │ └─attr("srcfile"): @001
        └─[[2]][[3]][[2]]: <{>
          ├─attr("srcref"): <list>
          │ ├─[[1]]: <srcref>
          │ │ ├─location: 1:18 - 1:18
          │ │ └─attr("srcfile"): @001
          │ └─[[2]]: <srcref>
          │   ├─location: 1:20 - 1:20
          │   └─attr("srcfile"): @001
          ├─attr("srcfile"): @001
          └─attr("wholeSrcref"): <srcref>
            ├─location: 1:0 - 1:22
            └─attr("srcfile"): @001

# src() handles srcrefs nested in function bodies

    Code
      with_srcref("f <- function() foo({ if (1) bar({ 2 }) })")
      scrub_src(src(f, max_depth = 10))
    Output
      <closure>
      ├─attr("srcref"): <srcref>
      │ ├─location: 1:6 - 1:42
      │ └─attr("srcfile"): <srcfilecopy> @001
      │   ├─Enc: "unknown"
      │   ├─filename: "<scrubbed>"
      │   ├─fixedNewlines: TRUE
      │   ├─isFile: TRUE
      │   ├─lines: "f <- function() foo({ if (1) bar..."
      │   ├─parseData<int [256]>: 1, 1, 1, ...
      │   ├─timestamp: "<scrubbed>"
      │   └─wd: "<scrubbed>"
      └─body(): <language>
        └─[[2]]: <{>
          ├─attr("srcref"): <list>
          │ ├─[[1]]: <srcref>
          │ │ ├─location: 1:21 - 1:21
          │ │ └─attr("srcfile"): @001
          │ └─[[2]]: <srcref>
          │   ├─location: 1:23 - 1:39
          │   └─attr("srcfile"): @001
          ├─attr("srcfile"): @001
          ├─attr("wholeSrcref"): <srcref>
          │ ├─location: 1:0 - 1:41
          │ └─attr("srcfile"): @001
          └─[[2]][[3]][[2]]: <{>
            ├─attr("srcref"): <list>
            │ ├─[[1]]: <srcref>
            │ │ ├─location: 1:34 - 1:34
            │ │ └─attr("srcfile"): @001
            │ └─[[2]]: <srcref>
            │   ├─location: 1:36 - 1:36
            │   └─attr("srcfile"): @001
            ├─attr("srcfile"): @001
            └─attr("wholeSrcref"): <srcref>
              ├─location: 1:0 - 1:38
              └─attr("srcfile"): @001

# src() currently shows duplicate srcfile objects

    Code
      f <- simple_function_with_srcref()
      scrub_src(src(f))
    Output
      <closure>
      ├─attr("srcref"): <srcref>
      │ ├─location: 1:14 - 3:1
      │ └─attr("srcfile"): <srcfilecopy> @001
      │   ├─Enc: "unknown"
      │   ├─filename: "<scrubbed>"
      │   ├─fixedNewlines: TRUE
      │   ├─isFile: TRUE
      │   ├─lines<chr [3]>: "test_func <-...", "  x + y", "}"
      │   ├─parseData<int [160]>: 1, 1, 1, ...
      │   ├─timestamp: "<scrubbed>"
      │   └─wd: "<scrubbed>"
      └─body(): <{>
        ├─attr("srcref"): <list>
        │ ├─[[1]]: <srcref>
        │ │ ├─location: 1:29 - 1:29
        │ │ └─attr("srcfile"): @001
        │ └─[[2]]: <srcref>
        │   ├─location: 2:3 - 2:7
        │   └─attr("srcfile"): @001
        ├─attr("srcfile"): @001
        └─attr("wholeSrcref"): <srcref>
          ├─location: 1:0 - 3:1
          └─attr("srcfile"): @001

# src() shows many duplicate srcfiles in nested expression

    Code
      x <- parse(text = "{\n  1\n  2\n}", keep.source = TRUE)
      scrub_src(src(x))
    Output
      <expression>
      ├─attr("srcref"): <list>
      │ └─[[1]]: <srcref>
      │   ├─location: 1:1 - 4:1
      │   └─attr("srcfile"): <srcfilecopy> @001
      │     ├─Enc: "unknown"
      │     ├─filename: "<scrubbed>"
      │     ├─fixedNewlines: TRUE
      │     ├─isFile: FALSE
      │     ├─lines<chr [4]>: "{", "  1", "  2", ...
      │     ├─parseData<int [56]>: 1, 1, 1, ...
      │     ├─timestamp: "<scrubbed>"
      │     └─wd: "<scrubbed>"
      ├─attr("srcfile"): @001
      ├─attr("wholeSrcref"): <srcref>
      │ ├─location: 1:0 - 5:0
      │ └─attr("srcfile"): @001
      └─[[1]]: <{>
        ├─attr("srcref"): <list>
        │ ├─[[1]]: <srcref>
        │ │ ├─location: 1:1 - 1:1
        │ │ └─attr("srcfile"): @001
        │ ├─[[2]]: <srcref>
        │ │ ├─location: 2:3 - 2:3
        │ │ └─attr("srcfile"): @001
        │ └─[[3]]: <srcref>
        │   ├─location: 3:3 - 3:3
        │   └─attr("srcfile"): @001
        ├─attr("srcfile"): @001
        └─attr("wholeSrcref"): <srcref>
          ├─location: 1:0 - 4:1
          └─attr("srcfile"): @001

# src() handles empty block

    Code
      x <- parse(text = "{}", keep.source = TRUE)
      scrub_src(src(x[[1]]))
    Output
      <{>
      ├─attr("srcref"): <list>
      │ └─[[1]]: <srcref>
      │   ├─location: 1:1 - 1:1
      │   └─attr("srcfile"): <srcfilecopy> @001
      │     ├─Enc: "unknown"
      │     ├─filename: "<scrubbed>"
      │     ├─fixedNewlines: TRUE
      │     ├─isFile: FALSE
      │     ├─lines: "{}"
      │     ├─parseData<int [24]>: 1, 1, 1, ...
      │     ├─timestamp: "<scrubbed>"
      │     └─wd: "<scrubbed>"
      ├─attr("srcfile"): @001
      └─attr("wholeSrcref"): <srcref>
        ├─location: 1:0 - 1:2
        └─attr("srcfile"): @001

# src() handles function without arguments

    Code
      with_srcref("f <- function() { NULL }")
      scrub_src(src(f))
    Output
      <closure>
      ├─attr("srcref"): <srcref>
      │ ├─location: 1:6 - 1:24
      │ └─attr("srcfile"): <srcfilecopy> @001
      │   ├─Enc: "unknown"
      │   ├─filename: "<scrubbed>"
      │   ├─fixedNewlines: TRUE
      │   ├─isFile: TRUE
      │   ├─lines: "f <- function() { NULL }"
      │   ├─parseData<int [104]>: 1, 1, 1, ...
      │   ├─timestamp: "<scrubbed>"
      │   └─wd: "<scrubbed>"
      └─body(): <{>
        ├─attr("srcref"): <list>
        │ ├─[[1]]: <srcref>
        │ │ ├─location: 1:17 - 1:17
        │ │ └─attr("srcfile"): @001
        │ └─[[2]]: <srcref>
        │   ├─location: 1:19 - 1:22
        │   └─attr("srcfile"): @001
        ├─attr("srcfile"): @001
        └─attr("wholeSrcref"): <srcref>
          ├─location: 1:0 - 1:24
          └─attr("srcfile"): @001

# src() handles if statement with blocks

    Code
      x <- parse(text = "if (TRUE) { 1 } else { 2 }", keep.source = TRUE)
      scrub_src(src(x))
    Output
      <expression>
      ├─attr("srcref"): <list>
      │ └─[[1]]: <srcref>
      │   ├─location: 1:1 - 1:26
      │   └─attr("srcfile"): <srcfilecopy> @001
      │     ├─Enc: "unknown"
      │     ├─filename: "<scrubbed>"
      │     ├─fixedNewlines: TRUE
      │     ├─isFile: FALSE
      │     ├─lines: "if (TRUE) { 1 } else { 2 }"
      │     ├─parseData<int [136]>: 1, 1, 1, ...
      │     ├─timestamp: "<scrubbed>"
      │     └─wd: "<scrubbed>"
      ├─attr("srcfile"): @001
      ├─attr("wholeSrcref"): <srcref>
      │ ├─location: 1:0 - 2:0
      │ └─attr("srcfile"): @001
      ├─[[1]][[3]]: <{>
      │ ├─attr("srcref"): <list>
      │ │ ├─[[1]]: <srcref>
      │ │ │ ├─location: 1:11 - 1:11
      │ │ │ └─attr("srcfile"): @001
      │ │ └─[[2]]: <srcref>
      │ │   ├─location: 1:13 - 1:13
      │ │   └─attr("srcfile"): @001
      │ ├─attr("srcfile"): @001
      │ └─attr("wholeSrcref"): <srcref>
      │   ├─location: 1:0 - 1:15
      │   └─attr("srcfile"): @001
      └─[[1]][[4]]: <{>
        ├─attr("srcref"): <list>
        │ ├─[[1]]: <srcref>
        │ │ ├─location: 1:22 - 1:22
        │ │ └─attr("srcfile"): @001
        │ └─[[2]]: <srcref>
        │   ├─location: 1:24 - 1:24
        │   └─attr("srcfile"): @001
        ├─attr("srcfile"): @001
        └─attr("wholeSrcref"): <srcref>
          ├─location: 1:0 - 1:26
          └─attr("srcfile"): @001

# src() respects show_source_lines parameter

    Code
      f <- simple_function_with_srcref()
      scrub_src(src(f))
    Output
      <closure>
      ├─attr("srcref"): <srcref>
      │ ├─location: 1:14 - 3:1
      │ └─attr("srcfile"): <srcfilecopy> @001
      │   ├─Enc: "unknown"
      │   ├─filename: "<scrubbed>"
      │   ├─fixedNewlines: TRUE
      │   ├─isFile: TRUE
      │   ├─lines<chr [3]>: "test_func <-...", "  x + y", "}"
      │   ├─parseData<int [160]>: 1, 1, 1, ...
      │   ├─timestamp: "<scrubbed>"
      │   └─wd: "<scrubbed>"
      └─body(): <{>
        ├─attr("srcref"): <list>
        │ ├─[[1]]: <srcref>
        │ │ ├─location: 1:29 - 1:29
        │ │ └─attr("srcfile"): @001
        │ └─[[2]]: <srcref>
        │   ├─location: 2:3 - 2:7
        │   └─attr("srcfile"): @001
        ├─attr("srcfile"): @001
        └─attr("wholeSrcref"): <srcref>
          ├─location: 1:0 - 3:1
          └─attr("srcfile"): @001

# src() shows expression with multiple nested blocks

    Code
      x <- parse(text = "{\n  {\n    1\n  }\n  {\n    2\n  }\n}", keep.source = TRUE)
      scrub_src(src(x))
    Output
      <expression>
      ├─attr("srcref"): <list>
      │ └─[[1]]: <srcref>
      │   ├─location: 1:1 - 8:1
      │   └─attr("srcfile"): <srcfilecopy> @001
      │     ├─Enc: "unknown"
      │     ├─filename: "<scrubbed>"
      │     ├─fixedNewlines: TRUE
      │     ├─isFile: FALSE
      │     ├─lines<chr [8]>: "{", "  {", "    1", ...
      │     ├─parseData<int [104]>: 1, 1, 1, ...
      │     ├─timestamp: "<scrubbed>"
      │     └─wd: "<scrubbed>"
      ├─attr("srcfile"): @001
      ├─attr("wholeSrcref"): <srcref>
      │ ├─location: 1:0 - 9:0
      │ └─attr("srcfile"): @001
      └─[[1]]: <{>
        ├─attr("srcref"): <list>
        │ ├─[[1]]: <srcref>
        │ │ ├─location: 1:1 - 1:1
        │ │ └─attr("srcfile"): @001
        │ ├─[[2]]: <srcref>
        │ │ ├─location: 2:3 - 4:3
        │ │ └─attr("srcfile"): @001
        │ └─[[3]]: <srcref>
        │   ├─location: 5:3 - 7:3
        │   └─attr("srcfile"): @001
        ├─attr("srcfile"): @001
        ├─attr("wholeSrcref"): <srcref>
        │ ├─location: 1:0 - 8:1
        │ └─attr("srcfile"): @001
        ├─[[2]]: <{>
        │ ├─attr("srcref"): <list>
        │ │ ├─[[1]]: <srcref>
        │ │ │ ├─location: 2:3 - 2:3
        │ │ │ └─attr("srcfile"): @001
        │ │ └─[[2]]: <srcref>
        │ │   ├─location: 3:5 - 3:5
        │ │   └─attr("srcfile"): @001
        │ ├─attr("srcfile"): @001
        │ └─attr("wholeSrcref"): <srcref>
        │   ├─location: 1:0 - 4:3
        │   └─attr("srcfile"): @001
        └─[[3]]: <{>
          ├─attr("srcref"): <list>
          │ ├─[[1]]: <srcref>
          │ │ ├─location: 5:3 - 5:3
          │ │ └─attr("srcfile"): @001
          │ └─[[2]]: <srcref>
          │   ├─location: 6:5 - 6:5
          │   └─attr("srcfile"): @001
          ├─attr("srcfile"): @001
          └─attr("wholeSrcref"): <srcref>
            ├─location: 1:0 - 7:3
            └─attr("srcfile"): @001

# src() shows function with nested block in body

    Code
      with_srcref("f <- function(x) {\n  if (x) {\n    1\n  }\n}")
      scrub_src(src(f))
    Output
      <closure>
      ├─attr("srcref"): <srcref>
      │ ├─location: 1:6 - 5:1
      │ └─attr("srcfile"): <srcfilecopy> @001
      │   ├─Enc: "unknown"
      │   ├─filename: "<scrubbed>"
      │   ├─fixedNewlines: TRUE
      │   ├─isFile: TRUE
      │   ├─lines<chr [5]>: "f <- functio...", "  if (x) {", "    1", ...
      │   ├─parseData<int [184]>: 1, 1, 1, ...
      │   ├─timestamp: "<scrubbed>"
      │   └─wd: "<scrubbed>"
      └─body(): <{>
        ├─attr("srcref"): <list>
        │ ├─[[1]]: <srcref>
        │ │ ├─location: 1:18 - 1:18
        │ │ └─attr("srcfile"): @001
        │ └─[[2]]: <srcref>
        │   ├─location: 2:3 - 4:3
        │   └─attr("srcfile"): @001
        ├─attr("srcfile"): @001
        ├─attr("wholeSrcref"): <srcref>
        │ ├─location: 1:0 - 5:1
        │ └─attr("srcfile"): @001
        └─[[2]][[3]]: <{>
          ├─attr("srcref"): <list>
          │ ├─[[1]]: <srcref>
          │ │ ├─location: 2:10 - 2:10
          │ │ └─attr("srcfile"): @001
          │ └─[[2]]: <srcref>
          │   ├─location: 3:5 - 3:5
          │   └─attr("srcfile"): @001
          ├─attr("srcfile"): @001
          └─attr("wholeSrcref"): <srcref>
            ├─location: 1:0 - 4:3
            └─attr("srcfile"): @001

