#' Pretty tree-like object printing
#'
#' A cleaner and easier to read replacement for `str` for nested list-like
#' objects
#'
#' @param x A tree like object (list, etc.)
#' @param index_unnamed Should children of containers without names have indices
#'   used as stand-in?
#' @param max_depth How far down the tree structure should be printed. E.g. `1`
#'   means only direct children of the root element will be shown. Useful for
#'   very deep lists.
#' @param show_environments Should environments be treated like normal lists and
#'   recursed into?
#' @param hide_scalar_types Should atomic scalars be printed with type and
#'   length like vectors? E.g. `x <- "a"` would be shown as `x<char [1]>: "a"`
#'   instead of `x: "a"`.
#' @param max_length How many elements should be printed? This is useful in case
#'   you try and print an object with 100,000 items in it.
#' @param val_printer Function that values get passed to before being drawn to
#'   screen. Can be used to color or generally style output.
#' @param class_printer Same as `val_printer` but for the the class types of
#'   non-atomic tree elements.
#' @param show_attributes Should attributes be printed as a child of the list or
#'   avoided?
#' @param remove_newlines Should character strings with newlines in them have
#'   the newlines removed? Not doing so will mess up the vertical flow of the
#'   tree but may be desired for some use-cases if newline structure is
#'   important to understanding object state.
#' @param tree_chars List of box characters used to construct tree. Needs
#'   elements `$h` for horizontal bar, `$hd` for dotted horizontal bar, `$v` for
#'   vertical bar, `$vd` for dotted vertical bar, `$l` for l-bend, and `$j` for
#'   junction (or middle child).
#' @param ... Ignored (used to force use of names)
#'
#' @return console output of structure
#'
#' @examples
#'
#' x <- list(
#'   list(id = "a", val = 2),
#'   list(
#'     id = "b",
#'     val = 1,
#'     children = list(
#'       list(id = "b1", val = 2.5),
#'       list(
#'         id = "b2",
#'         val = 8,
#'         children = list(
#'           list(id = "b21", val = 4)
#'         )
#'       )
#'     )
#'   ),
#'   list(
#'     id = "c",
#'     val = 8,
#'     children = list(
#'       list(id = "c1"),
#'       list(id = "c2", val = 1)
#'     )
#'   )
#' )
#'
#' # Basic usage
#' tree(x)
#'
#' # Even cleaner output can be achieved by not printing indices
#' tree(x, index_unnamed = FALSE)
#'
#' # Limit depth if object is potentially very large
#' tree(x, max_depth = 2)
#'
#' # You can customize how the values and classes are printed if desired
#' tree(x, val_printer = function(x) {
#'   paste0("_", x, "_")
#' })
#' @export
tree <- function(x,
                 ...,
                 index_unnamed = FALSE,
                 max_depth = 10L,
                 max_length = 1000L,
                 show_environments = TRUE,
                 hide_scalar_types = TRUE,
                 val_printer = crayon::blue,
                 class_printer = crayon::silver,
                 show_attributes = FALSE,
                 remove_newlines = TRUE,
                 tree_chars = box_chars()) {
  rlang::check_dots_empty()

  # Pack up the unchanging arguments into a list and send to tree_internal
  termination_type <- tree_internal(
    x,
    opts = list(
      index_unnamed = index_unnamed,
      max_depth = max_depth,
      max_length = max_length,
      show_envs = show_environments,
      hide_scalar_types = hide_scalar_types,
      val_printer = val_printer,
      class_printer = class_printer,
      show_attributes = show_attributes,
      remove_newlines = remove_newlines,
      tree_chars = tree_chars
    )
  )
  if (termination_type == "early") {
    cat("...", "\n")
  }

  invisible(x)
}

# Tree printing internal function
#
# This is the internal function for the main tree printing code. It wraps the
# static options arguments from the user-facing `tree()` into a single opts
# list to make recursive calls cleaner. It also has arguments that as it is
# called successively but the end-user shouldn't see or use.
tree_internal <- function(x,
                          x_id = NULL,
                          branch_hist = character(0),
                          opts,
                          attr_mode = FALSE,
                          counter_env = rlang::new_environment(
                            data = list(n_printed = 0, envs_seen = c())
                          )) {
  counter_env$n_printed <- counter_env$n_printed + 1
  # Stop if we've reached the max number of times printed desired
  if (counter_env$n_printed > opts$max_length) {
    return("early")
  }
  # Since self-loops can occur in environments check to see if we've seen any
  # environments before
  already_seen <- FALSE
  if (rlang::is_environment(x)) {
    already_seen <- any(vapply(counter_env$envs_seen, identical, x, FUN.VALUE = logical(1)))
    if (!already_seen) {
      # If this environment is new, add it to the seen
      counter_env$envs_seen[[length(counter_env$envs_seen) + 1]] <- x
    }
  }

  depth <- length(branch_hist)

  # Build branch string from branch history
  # Start with empty spaces
  branch_chars <- rep_len("  ", depth)

  branch_chars[branch_hist == "child"] <- paste0(opts$tree_chars$v, " ")
  branch_chars[grepl("attr", branch_hist, fixed = TRUE)] <- paste0(opts$tree_chars$vd, " ")

  # Next update the final element (aka the current step) with the correct branch type
  last_step <- branch_hist[depth]
  root_node <- length(branch_hist) == 0

  branch_chars[depth] <- if (root_node) {
    ""
  } else {
    paste0(
      if (grepl("last", last_step)) opts$tree_chars$l else opts$tree_chars$j,
      if (grepl("attribute", last_step)) opts$tree_chars$hd else opts$tree_chars$h
    )
  }
  # Build label
  label <- paste0(
    x_id,
    make_type_abrev(x, opts$hide_scalar_types),
    if (!rlang::is_null(x_id) && x_id != "") ": ",
    tree_label(x, opts),
    if (already_seen) " (Already seen)"
  )

  # Figure out how many children we have (plus attributes if they are being
  # printed) so we can setup how to proceed
  x_attributes <- attributes(x)
  if (attr_mode) {
    # Filter out "names" attribute as this is already shown by tree
    x_attributes <- x_attributes[names(x_attributes) != "names"]
  }
  has_attributes <- length(x_attributes) > 0 && opts$show_attributes

  has_children <- has_attributes || length(x) > 1
  max_depth_reached <- depth >= opts$max_depth && has_children

  # Do the actual printing to the console with an optional ellipses to indicate
  # we've reached the max depth and won't recurse more
  cat(
    paste(branch_chars, collapse = ""),
    label,
    if (max_depth_reached) "...",
    "\n",
    sep = ""
  )

  # ===== Start recursion logic
  if (already_seen || max_depth_reached) {
    return("Normal finish")
  }

  if (rlang::is_list(x) || is_printable_env(x)) {
    # Coerce current object to a plain list. This is necessary as some s3
    # classes override `[[` and return funky stuff like themselves (see s3 class
    # "package_version")
    children <- if (is_printable_env(x)) {
      # Environments are funky as they don't have names before conversion to list
      # but do after, so let them handle their conversion.
      # We use all.names = TRUE in an effort to fully explain the object
      as.list.environment(x, all.names = TRUE)
    } else {
      # By wiping all attributes except for the names we force the object to be
      # a plain list. This is inspired by the (now depreciated) rlang::as_list().
      attributes(x) <- list(names = names(x))
      as.list(x)
    }

    # Traverse children, if any exist
    n_children <- length(children)
    child_names <- names(children)
    # If children have names, give them the names
    for (i in seq_along(children)) {
      id <- child_names[i]
      if ((rlang::is_null(id) || id == "") && opts$index_unnamed) id <- crayon::italic(i)

      child_type <- if (i < n_children) {
        "child"
      } else if (has_attributes) {
        # We use "attrs" here instead of full "attribute" so a grep for
        # attributes just gets plain "attribute" or "last-attribute" but a grep
        # for "attr" gets all attribute related types
        "pre-attrs"
      } else {
        "last-child"
      }
      termination_type <- Recall(
        x = children[[i]],
        x_id = id,
        branch_hist = c(branch_hist, child_type),
        opts = opts,
        counter_env = counter_env
      )
      if (termination_type == "early") {
        return(termination_type)
      }
    }
  }
  # ===== End recursion logic

  # Add any attributes as an "attr" prefixed children at end
  if (has_attributes) {
    n_attributes <- length(x_attributes)
    for (i in seq_len(n_attributes)) {
      termination_type <- Recall(
        x = x_attributes[[i]],
        x_id = crayon::italic(paste0("attr(,\"", names(x_attributes)[i], "\")")),
        opts = opts,
        branch_hist = c(branch_hist, paste0(if (i == n_attributes) "last-", "attribute")),
        attr_mode = TRUE, # Let tree know this is an attribute
        counter_env = counter_env
      )
      if (termination_type == "early") {
        return(termination_type)
      }
    }
  }
  # If all went smoothly we reach here
  "Normal finish"
}

# There are a few environments we don't want to recurse into
is_printable_env <- function(x) {
  is_environment(x) &&
    !(
      identical(x, rlang::global_env()) ||
        identical(x, rlang::empty_env()) ||
        identical(x, rlang::base_env()) ||
        rlang::is_namespace(x)
    )
}

#' Build element or node label in tree
#'
#' These methods control how the value of a given node is printed. New methods
#' can be added if support is needed for a novel class
#'
#' @inheritParams tree
#' @param opts A list of options that directly mirrors the named arguments of
#'   [tree]. E.g. `list(val_printer = crayon::red)` is equivalent to
#'   `tree(..., val_printer = crayon::red)`.
#'
#' @export
tree_label <- function(x, opts) {
  UseMethod("tree_label")
}

#' @export
tree_label.function <- function(x, opts) {
  func_args <- collapse_and_truncate_vec(methods::formalArgs(x), 5)
  crayon::italic(paste0("function(", func_args, ")"))
}

#' @export
tree_label.environment <- function(x, opts) {
  format.default(x)
}

#' @export
tree_label.NULL <- function(x, opts) {
  "<NULL>"
}

#' @export
tree_label.character <- function(x, opts) {

  # Get rid of new-line so they don't break tree flow
  if (opts$remove_newlines) {
    x <- gsub("\\n", replacement = "\u21B5", x = x, perl = TRUE)
  }

  # Shorten strings if needed
  max_standalone_length <- 35
  max_vec_length <- 15
  max_length <- if (length(x) == 1) max_standalone_length else max_vec_length
  x <- truncate_string(x, max_length)

  tree_label.default(paste0("\"", x, "\""), opts)
}


#' @export
tree_label.default <- function(x, opts) {
  if (rlang::is_atomic(x)) {
    opts$val_printer(collapse_and_truncate_vec(x, 10))
  } else if (rlang::is_function(x)) {
    # Lots of times function-like functions don't actually trigger the s3 method
    # for function because they dont have function in their class-list. This
    # catches those.
    tree_label.function(x, opts)
  } else if (rlang::is_environment(x)) {
    # Environments also tend to have the same trouble as functions. For instance
    # the srcobject attached to a function's attributes is an environment but
    # doesn't report as one to s3.
    tree_label.environment(x, opts)
  } else if (rlang::is_expression(x) || rlang::is_formula(x)) {
    paste0(label_class(x, opts), " ", crayon::italic(deparse(x)))
  } else {
    # The "base-case" is simply a list-like object.
    label_class(x, opts)
  }
}


collapse_and_truncate_vec <- function(vec, max_length) {
  vec <- as.character(vec)
  too_long <- length(vec) > max_length
  if (too_long) {
    vec <- utils::head(vec, max_length)
    vec <- c(vec, "...")
  }
  paste0(vec, collapse = ", ")
}

truncate_string <- function(char_vec, max_length) {
  ifelse(
    nchar(char_vec) > max_length,
    # Since we add an elipses we need to take a bit more than the max length
    # off. The gsub adds elipses but also makes sure we dont awkwardly end on
    # a space.
    gsub(
      x = substr(char_vec, start = 1, max_length - 3),
      pattern = "\\s*$",
      replacement = "...",
      perl = TRUE
    ),
    char_vec
  )
}

make_type_abrev <- function(x, omit_scalars) {
  if (!rlang::is_atomic(x) || (rlang::is_scalar_atomic(x) && omit_scalars)) {
    return("")
  }

  type_abrev <- switch(typeof(x),
    logical = "lgl",
    integer = "int",
    double = "dbl",
    character = "chr",
    complex = "cpl",
    expression = "expr",
    raw = "raw",
    "unknown"
  )

  paste0("<", type_abrev, " [", format(length(x), big.mark = ","), "]>")
}


# Inspired by waldo:::friendly_type_of(). Prints the class name and hierarchy
# encased in angle brackets along with a prefix that tells you what OO system
# the object belongs to (if it does.)
label_class <- function(x, opts) {
  if (is_missing(x)) {
    return("absent")
  }
  oo_prefix <- ""

  class_list <- if (!is.object(x)) {
    typeof(x)
  } else if (isS4(x)) {
    oo_prefix <- "S4"
    methods::is(x)
  } else if (inherits(x, "R6")) {
    oo_prefix <- "R6"
    setdiff(class(x), "R6")
  } else {
    oo_prefix <- "S3"
    class(x)
  }

  opts$class_printer(
    paste0(oo_prefix, "<", paste(class_list, collapse = "/"), ">")
  )
}
