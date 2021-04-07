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
#'       list(id = "b1",val = 2.5),
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
#' tree(x, val_printer = function(x){paste0("_", x, "_")})
#'
#' @export
tree <- function(
  x,
  ...,
  index_unnamed = FALSE,
  max_depth = 10L,
  max_length = 1000L,
  show_environments = TRUE,
  val_printer = crayon::blue,
  class_printer = crayon::silver,
  show_attributes = FALSE,
  remove_newlines = TRUE,
  tree_chars = box_chars()
){
  ellipsis::check_dots_empty()

  # Pack up the unchanging arguments into a list and send to tree_internal
  termination_type <- tree_internal(
    x,
    opts = list(
      index_unnamed = index_unnamed,
      max_depth = max_depth,
      max_length = max_length,
      show_envs = show_environments,
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
tree_internal <- function(
  x,
  x_id = NULL,
  branch_hist = character(0),
  opts,
  attr_mode = FALSE,
  counter_env = rlang::new_environment(data = list(n_elements_printed = 0, envs_seen = c()))
) {
  counter_env$n_elements_printed <- counter_env$n_elements_printed + 1
  # Stop if we've reached the max number of times printed desired
  if (counter_env$n_elements_printed > opts$max_length) {
    return("early")
  }

  depth <- length(branch_hist)

  # Build branch string from branch history
  # Start with empty spaces
  branch_chars <- rep_len("  ", depth)

  branch_chars[branch_hist == "child"] <- paste0(opts$tree_chars$v, " ")
  branch_chars[branch_hist == "pre-attrs"] <- paste0(opts$tree_chars$vd, " ")

  # Next update the final element (aka the current step) with the correct branch type
  last_step <- branch_hist[depth]
  root_node <- length(branch_hist) == 0

  branch_chars[depth] <- if (root_node) {
    ""
  }  else {
    paste0(
      if (grepl("last", last_step)) opts$tree_chars$l else opts$tree_chars$j,
      if (grepl("attribute", last_step)) opts$tree_chars$hd else opts$tree_chars$h
    )
  }

  # Build label
  label <- paste0(
    x_id,
    if (!rlang::is_null(x_id) && x_id != "") ": ",
    tree_label(
      x,
      class_printer = opts$class_printer,
      val_printer = opts$val_printer,
      remove_newlines = opts$remove_newlines
    )
  )

  # Figure out how many children we have (plus attributes if they are being
  # printed) so we can setup how to proceed
  x_attributes <- attributes(x)
  if (attr_mode){
    # Filter out "names" attribute as this is already shown by tree
    x_attributes <- x_attributes[names(x_attributes) != "names"]
  }
  has_attributes <- length(x_attributes) > 0 & opts$show_attributes

  has_children <- has_attributes | length(x) > 1
  max_depth_reached <- depth >= opts$max_depth & has_children

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

  # Using negative tense here because so it's easier to state when we don't want
  # to recurse than when we do
  dont_recurse_into <-
    is_atomic(x) |
    max_depth_reached |
    is_function(x) |
    (is_environment(x) & !opts$show_env)


  if (!dont_recurse_into) {

    children <- as.list(x)

    if (is_environment(x)) {
      # If we're looking at an environment, we add its parent as child
      parent <- env_parent(x)

      already_seen_parent <- any(as.logical(lapply(counter_env$envs_seen, identical, parent)))
      # Stop recursion into environments when we get to either the calling
      # environment, the global environment, or an empty environment
      if (
        !(
          already_seen_parent |
          identical(parent, rlang::caller_env()) |
          identical(parent, rlang::empty_env()) |
          identical(parent, rlang::global_env())
        )
      ) {
        counter_env$envs_seen <- c(counter_env$envs_seen, parent)
        children <- c(children, parent = env_parent(x))
      }
    }

    # Traverse children, if any exist
    n_children <- length(children)
    child_names <- names(children)
    # If children have names, give them the names
    for (i in seq_along(children)) {
      id <- child_names[i]
      if ((rlang::is_null(id) || id == "") & opts$index_unnamed) id <- crayon::italic(i)

      child_type <- if (i < n_children){
        "child"
      } else if (has_attributes) {
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
      if (termination_type == "early") return(termination_type)
    }
  }
  # ===== End recursion logic

  # Add any attributes as an "attr" prefixed children at end
  if (has_attributes){
    n_attributes <- length(x_attributes)
    for (i in seq_len(n_attributes)) {
      termination_type <- Recall(
        x = x_attributes[[i]],
        x_id = crayon::italic(paste0("<attr>", names(x_attributes)[i])),
        opts = opts,
        branch_hist = c(branch_hist, paste0(if (i == n_attributes) "last-", "attribute")),
        attr_mode = TRUE, # Let tree know this is an attribute
        counter_env = counter_env
      )
      if (termination_type == "early") return(termination_type)
    }
  }
  # If all went smoothly we reach here
  "Normal finish"
}

#' Build element or node label in tree
#'
#' These methods control how the value of a given node is printed. New methods
#' can be added if support is needed for a novel class
#'
#' @inheritParams tree
#'
#' @export
tree_label <- function(x, val_printer, class_printer, remove_newlines){
  UseMethod("tree_label")
}

#' @export
tree_label.function <- function(x, ...){
  crayon::italic("function(){...}")
}

#' @export
tree_label.environment <- function(x,...){
  format.default(x)
}

#' @export
tree_label.NULL <- function(x,...){
  "<NULL>"
}

#' @export
tree_label.character <- function(x, remove_newlines, ...){

  # Get rid of new-line so they don't break tree flow
  if (remove_newlines){
    x <- gsub("\\n", replacement = "\u21B5", x = x, perl = TRUE)
  }

  # Shorten strings if needed
  max_standalone_length <- 35
  max_vec_length <- 15
  max_length <- if (length(x) == 1) max_standalone_length else max_vec_length
  x <- ifelse(
    nchar(x) > max_length,
    # Since we add an elipses we need to take a bit more than the max length
    # off. The gsub adds elipses but also makes sure we dont awkwardly end on
    # a space.
    gsub(x = substr(x, start = 1, max_length - 3),
         pattern = "\\s*$",
         replacement = "...",
         perl = TRUE),
    x
  )

  tree_label.default(paste0("\"", x, "\""),...)
}



#' @export
tree_label.default <- function(x, val_printer, class_printer, remove_newlines){

  # There are a few psuedo-types that we want different printing behavior for.
  # Since s3 methods cant differentiate between something like a single
  # character and a vector of characters we use some logical branching here to
  # try and use the best printing type for the passed value.

  if (rlang::is_atomic(x)) {

    num_els <- length(x)
    if (num_els > 1) {
      # Atomic vectors are truncated to a max of 10 elements and printed inline
      x <- as.character(x)
      too_long <- num_els > 10
      if (too_long) {
        x <- head(x, 10)
        x <- c(x, "...")
      }
      x <- paste0("[", paste(x, collapse = ", "), "]")
      if (too_long) x <- paste0(x, " n:", num_els)
    }

    # Single length atomics just go through unscathed
    val_printer(x)

  } else if (rlang::is_function(x)) {
    # Lots of times function-like functions don't actually trigger the s3 method
    # for function because they dont have function in their class-list. This
    # catches those.
    tree_label.function(x, class_printer, val_printer)
  } else if (rlang::is_environment(x)) {
    # Environments also tend to have the same trouble as functions. For instance
    # the srcobject attached to a function's attributes is an environment but
    # doesn't report as one to s3.
    tree_label.environment(x)
  } else {
    # The "base-case" is simply a list-like object. This will get printed with
    # angle brackets enclosing the class name.
    class_printer(paste0("<", class(x)[1], ">"))
  }
}
