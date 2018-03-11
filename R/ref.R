#' Display tree of references
#'
#' @param x An object
#' @param character If `TRUE`, show references from character vector in to
#'   global string pool
#' @export
#' @examples
#' x <- 1:100
#' ref(list(x, x, x))
#'
#' e <- new.env()
#' e$e <- e
#' e$x <- x
#' e$y <- list(x, e)
#' ref(e)
#'
#' # Will show references into global string pool only if requested
#' ref(c("x", "x", "y"))
#' ref(c("x", "x", "y"), character = TRUE)
ref <- function(x, character = FALSE) {
  new_raw(mem_tree(x, character = character, seen = env(emptyenv())))
}

mem_tree <- function(x, character = FALSE, seen = env(emptyenv()), layout = box_chars()) {

  addr <- obj_addr(x)
  has_seen <- env_has(seen, addr)
  env_poke(seen, addr, NULL)
  type <- if (is.environment(x)) "env" else rlang:::rlang_type_sum(x)

  desc <- obj_desc(addr, type, has_seen)

  # Not recursive or already seen
  if (!has_references(x, character) || has_seen) {
    return(desc)
  }

  # recursive case
  if (is.list(x)) {
    subtrees <- lapply(x, mem_tree, layout = layout, seen = seen, character = character)
  } else if (is.environment(x)) {
    subtrees <- lapply(as.list(x), mem_tree, layout = layout, seen = seen, character = character)
  } else if (is.character(x)) {
    subtrees <- mem_tree_chr(x, layout = layout, seen = seen)
  }
  subtrees <- name_subtree(subtrees)

  self <- str_indent(desc, paste0(layout$n, " "), paste0(layout$v, " "))

  n <- length(subtrees)
  if (n == 0) {
    return(self)
  }
  c(
    self,
    unlist(lapply(subtrees[-n],
      str_indent,
      paste0(layout$j, layout$h),
      paste0(layout$v,  " ")
    )),
    str_indent(subtrees[[n]],
      paste0(layout$l, layout$h),
      "  "
    )
  )
}

obj_desc <- function(addr, type, has_seen) {
  if (has_seen) {
    paste0("<", grey(addr), ">")
  } else {
    paste0("<", addr, "> ", type)
  }
}

has_references <- function(x, character = FALSE) {
  is_list(x) || is_environment(x) || (character && is_character(x))
}

mem_tree_chr <- function(x, layout = box_chars(), seen = env(emptyenv())) {
  addrs <- obj_addrs(x)

  has_seen <- logical(length(x))
  for (i in seq_along(addrs)) {
    has_seen[[i]] <- env_has(seen, addrs[[i]])
    env_poke(seen, addrs[[i]], NULL)
  }

  type <- paste0("string: '", str_truncate(x, 10), "'")

  out <- Map(obj_desc, addrs, type, has_seen)
  names(out) <- names(x)
  out
}
