box_chars <- function() {
  fancy <- getOption("lobstr.fancy.tree") %||% l10n_info()$`UTF-8`
  orange <- crayon::make_style("orange")

  if (fancy) {
    list(
      "h" = "\u2500",          # ─ horizontal
      "v" = "\u2502",          # │ vertical
      "l" = "\u2514",          # └ leaf
      "j" = "\u251C",          # ├ junction
      "n" = orange("\u2588")   # █ node
    )
  } else {
    list(
      "h" = "-",
      "v" = "|",
      "l" = "\\",
      "j" = "+",
      "n" = orange("o")
    )
  }
}

# string -----------------------------------------------------------------

str_dup <- function(x, n) {
  vapply(n, function(i) paste0(rep(x, i), collapse = ""), character(1))
}

str_indent <- function(x, first, rest) {
  if (length(x) == 0) {
    character()
  } else if (length(x) == 1) {
    paste0(first, x)
  } else {
    c(
      paste0(first, x[[1]]),
      paste0(rest, x[-1L])
    )
  }

}
