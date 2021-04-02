#' Pretty tree-like object printing
#'
#' A cleaner and easier to read replacement for `str` for nested list-like
#' objects
#'
#' @param x A tree like object (list, etc.)
#' @param index_arraylike Should children of containers without names have
#'   indices used as stand-in?
#' @param max_depth How far down the tree structure should be printed. E.g. `1`
#'   means only direct children of the root element will be shown. Useful for
#'   very deep lists.
#' @param val_printer Function that values get passed to before being drawn to
#'   screen. Can be used to color or generally style output.
#' @param class_printer Same as `val_printer` but for the the class types of
#'   non-atomic tree elements.
#' @param show_attributes Should attributes be printed as a child of the list or
#'   avoided?
#' @param remove_newlines Should character strings with newlines in them have the
#'   newlines removed? Not doing so will mess up the vertical flow of the tree
#'   but may be desired for some use-cases if newline structure is important to
#'   understanding object state.
#' @param
#' char_vertical,char_horizontal,char_branch,char_final_branch,char_vertical_attr,char_horizontal_attr
#' Unicode characters used to construct the tree. Typically you wont want to
#' change these.
#' @param ... Ignored (used to force use of names)
#'
#' @return console output of structure
#'
#' @examples
#'
#' x <- list(
#' list(id = "a",
#'      val = 2),
#' list(id = "b",
#'      val = 1,
#'      children = list(
#'        list(id = "b1",
#'             val = 2.5),
#'        list(id = "b2",
#'             val = 8,
#'             children = list(
#'               list(id = "b21",
#'                    val = 4)
#'             )))),
#' list(id = "c",
#'      val = 8,
#'      children = list(
#'        list(id = "c1"),
#'        list(id = "c2",
#'             val = 1))))
#'
#' # Basic usage
#' tree(x)
#'
#' # Even cleaner output can be achieved by not printing indices
#' tree(x, index_arraylike = FALSE)
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
  index_arraylike = TRUE,
  max_depth = Inf,
  val_printer = crayon::blue,
  class_printer = crayon::silver,
  show_attributes = FALSE,
  remove_newlines = TRUE,
  char_vertical = "\u2502",
  char_horizontal = "\u2500",
  char_branch = "\u251c",
  char_final_branch = "\u2514",
  char_vertical_attr = "\u250A",
  char_horizontal_attr = "\u2504"
){
  args_in_dots <- list(...)
  if (length(args_in_dots) != 0) {
    named_args <- names(args_in_dots)[names(args_in_dots) != ""]
    if(length(named_args) > 0) {
      warning(
        "Unknown arguments passed to tree:\n",
        paste0("   - \"", named_args, "\"", collapse = "\n"),
        "\nWere these mispecified?"
      )
    }

    n_unamed <- sum(!has_name)
    if(n_unamed != 0) {
      warning(
        n_unamed, " unnamed arguments passed to tree. These are ignored."
      )
    }
  }

  # Pack up the unchanging arguments into a list and send to tree_internal
  tree_internal(
    x,
    opts = list(
      index_arraylike = index_arraylike,
      max_depth = max_depth,
      val_printer = val_printer,
      class_printer = class_printer,
      show_attributes = show_attributes,
      remove_newlines = remove_newlines,
      vertical = char_vertical,
      horizontal = char_horizontal,
      branch = char_branch,
      final_branch = char_final_branch,
      vertical_attr = char_vertical_attr,
      horizontal_attr = char_horizontal_attr
    )
  )
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
                          attr_mode = FALSE){

  depth <- length(branch_hist)

  # Build branch string from branch history
  # Start with empty spaces
  branch_chars <- rep_len("  ", depth)

  # Store history in short name so logic is more legible
  branch_chars[branch_hist == "child"] <- paste0(opts$vertical, " ")
  branch_chars[branch_hist == "pre-attrs"] <- paste0(opts$vertical_attr, " ")

  # Next update the final element (aka the current step) with the correct branch type
  last_step <- branch_hist[depth]
  root_node <- length(branch_hist) == 0
  branch_chars[depth] <- if(root_node) "" else paste0(
    if(grepl("last", last_step)) opts$final_branch else opts$branch,
    if(grepl("attribute", last_step)) opts$horizontal_attr else opts$horizontal
  )

  # Build label
  label <- paste0(
    x_id,
    if(!is.null(x_id) && x_id != "") ":",
    tree_label(x,
               class_printer = opts$class_printer,
               val_printer = opts$val_printer,
               remove_newlines = opts$remove_newlines)
  )

  # Do the actual printing to the console
  cat("\n", paste(branch_chars, collapse = ""), label, sep = "")

  x_attributes <- attributes(x)
  if(attr_mode){
    # Filter out "names" attribute as this is already shown by tree
    x_attributes <- x_attributes[names(x_attributes) != "names"]
  }
  has_attributes <- length(x_attributes) > 0 & opts$show_attributes

  # ===== Start recursion logic
  # Turn into a s3 method for recursion
  if(!is.atomic(x) & depth <= opts$max_depth & !is.function(x) & !is.environment(x)){
    children <- as.list(x)

    # Traverse children, if any exist
    n_children <- length(children)

    # If children have names, give them the names
    for (i in seq_along(children)) {
      id <- names(x)[i]
      if(is.null(id) & opts$index_arraylike) id <- i

      child_type <- if(i < n_children){
        "child"
      } else if(has_attributes) {
        "pre-attrs"
      } else {
        "last-child"
      }
      tree_internal(
        x = children[[i]],
        x_id = id,
        branch_hist = c(branch_hist, child_type),
        opts = opts
      )
    }
  }
  # ===== End recursion logic

  # Add any attributes as an "attr" prefixed children at end
  if(has_attributes){
    n_attributes <- length(x_attributes)
    for(i in seq_len(n_attributes)){
      tree_internal(
        x = x_attributes[[i]],
        x_id = crayon::italic(paste0("<attr>", names(x_attributes)[i])),
        opts = opts,
        branch_hist = c(branch_hist, paste0(if(i == n_attributes) "last-", "attribute")),
        attr_mode = TRUE # Let tree know this is an attribute
      )
    }
  }
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
  if(remove_newlines){
    x <- gsub("\\n", replacement = " ", x = x, perl = TRUE)
  }

  # Shorten strings if needed
  max_standalone_length <- 35
  max_vec_length <- 25
  max_length <- if(length(x) == 1) max_standalone_length else max_vec_length
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
  is_atomic_value <- is.atomic(x)
  is_environment <- is.environment(x)

  if(is_atomic_value) {

    num_els <- length(x)
    if(num_els > 1) {
      # Atomic vectors are truncated to a max of 10 elements and printed inline
      x <- as.character(x)
      if(num_els > 10){
        x <- head(x, 10)
        x <- c(x, paste0("...(n = ", num_els, ")"))
      }
      x <- paste(x, collapse = ",")
    }

    # Single length atomics just go through unscathed
    val_printer(x)

  } else if(is.function(x)) {
    # Lots of times function-like functions don't actually trigger the s3 method
    # for function because they dont have function in their class-list. This
    # catches those.
    tree_label.function(x, class_printer, val_printer)
  } else if(is.environment(x)) {
    # Environments also tend to have the same trouble as functions. For instance
    # the srcobject attached to a function's attributes is an environment but
    # doesn't report as one to s3.
    tree_label.environment(x)
  } else {
    # The "base-case" is simply a list-like object. Here we use curly braces if
    # it has named elements and print the class name
    delims <- if(!is.null(names(x))) c("{","}") else c("[", "]")
    class_printer(paste0(delims[1], class(x)[1], delims[2]))
  }
}
