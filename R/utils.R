box_chars <- function() {
  fancy <- getOption("pkgdepends.fancy.tree") %||% l10n_info()$`UTF-8`
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
      "n" = orange("X")
    )
  }
}

# string -----------------------------------------------------------------

str_dup <- function(x, n) {
  paste0(rep(x, n), collapse = "")
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

str_trunc <- function(x, max_width = getOption("width")) {
  width <- nchar(x)

  too_wide <- width > max_width
  x[too_wide] <- paste0(substr(x[too_wide], 1, width[too_wide] - 3), "...")

  x
}
