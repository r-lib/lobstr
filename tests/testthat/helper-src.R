# Snapshot transformer to scrub src() output for deterministic snapshots
scrub_src_transform <- function(lines) {
  lines <- gsub('filename: "[^"]+"', 'filename: "<scrubbed>"', lines)
  lines <- gsub('directory: "[^"]+"', 'directory: "<scrubbed>"', lines)
  lines <- gsub('timestamp: "[^"]+"', 'timestamp: "<scrubbed>"', lines)
  lines <- gsub('wd: "[^"]+"', 'wd: "<scrubbed>"', lines)
  lines
}

with_srcref <- function(code, env = parent.frame(), file = NULL) {
  if (is.null(file)) {
    file <- tempfile("test_srcref", fileext = ".R")
    on.exit(unlink(file), add = TRUE)
  }

  writeLines(code, file)
  source(file, local = env, keep.source = TRUE)
}

parse_with_srcref <- function(code) {
  parse(text = code, keep.source = TRUE)
}

simple_function_with_srcref <- function() {
  code <- c(
    "test_func <- function(x, y) {",
    "  x + y",
    "}"
  )

  env <- new.env(parent = baseenv())
  with_srcref(code, env = env)
  env$test_func
}

multi_statement_function_with_srcref <- function() {
  code <- c(
    "multi_func <- function(x) {",
    "  a <- x + 1",
    "  b <- a * 2",
    "  c <- b - 3",
    "  c",
    "}"
  )

  env <- new.env(parent = baseenv())
  with_srcref(code, env = env)
  env$multi_func
}
