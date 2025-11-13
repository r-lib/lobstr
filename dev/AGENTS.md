# AGENTS.md

This file provides guidance to agents like Claude Code when working with
code in this repository.

## About This Project

lobstr is a package for R developers that prints data structures and
objects in a tree-like fashion. It provides specialized
`base::str()`-like functions that help visualize objects during
development:

- [`ast()`](https://lobstr.r-lib.org/dev/reference/ast.md): draws the
  abstract syntax tree of R expressions
- [`ref()`](https://lobstr.r-lib.org/dev/reference/ref.md): shows hows
  objects can be shared across data structures by digging into the
  underlying references
- [`obj_size()`](https://lobstr.r-lib.org/dev/reference/obj_size.md):
  computes the size of an object taking these shared references into
  account
- [`cst()`](https://lobstr.r-lib.org/dev/reference/cst.md) shows how
  frames on the call stack are connected

## Key development commands

General advice: \* When running R from the console, always run it with
`--quiet --vanilla` \* Always run `air format .` after generating code

### Testing

- Use `devtools::test()` to run all tests

- Use `devtools::test_file("tests/testthat/test-filename.R")` to run
  tests in a specific file

- DO NOT USE `devtools::test_active_file()`

- All testing functions automatically load code; you don’t needs to.

- All new code should have an accompanying test.

- Tests for `R/{name}.R` go in `tests/testthat/test-{name}.R`.

- If there are existing tests, place new tests next to similar existing
  tests.

### Documentation

- Run `devtools::document()` after changing any roxygen2 docs.
- Every user facing function should be exported and have roxygen2
  documentation.
- Whenever you add a new documentation file, make sure to also add the
  topic name to `_pkgdown.yml`.
- Run
  [`pkgdown::check_pkgdown()`](https://pkgdown.r-lib.org/reference/check_pkgdown.html)
  to check that all topics are included in the reference index.
- Use sentence case for all headings

## Core Architecture

### Main Components

1.  **Abstract Syntax Trees** (`R/ast.R`):
    - [`ast()`](https://lobstr.r-lib.org/dev/reference/ast.md) -
      Visualizes R expression structure as a tree
    - Recursively processes calls, symbols, and literals
    - Uses rlang for quosure handling and expression manipulation
    - Output formatting handled by tree display utilities
2.  **Reference Tracking** (`R/ref.R`, `src/address.cpp`):
    - [`ref()`](https://lobstr.r-lib.org/dev/reference/ref.md) - Shows
      memory addresses and shared references
    - [`obj_addr()`](https://lobstr.r-lib.org/dev/reference/obj_addr.md),
      [`obj_addrs()`](https://lobstr.r-lib.org/dev/reference/obj_addr.md) -
      Get memory locations of objects
    - Tracks how objects are shared across data structures
    - Handles lists, environments, and optionally character vectors
      (global string pool)
    - Uses depth-first search with seen tracking to avoid infinite loops
3.  **Object Size Calculation** (`R/size.R`, `src/size.cpp`):
    - [`obj_size()`](https://lobstr.r-lib.org/dev/reference/obj_size.md) -
      Computes memory size accounting for shared references
    - [`obj_sizes()`](https://lobstr.r-lib.org/dev/reference/obj_size.md) -
      Shows individual contributions of multiple objects
    - Handles ALTREP objects correctly (R 3.5+)
    - Smart environment handling: stops at global, base, empty, and
      namespace environments
    - C++ implementation traverses object tree with deduplication
4.  **Call Stack Trees** (`R/cst.R`):
    - [`cst()`](https://lobstr.r-lib.org/dev/reference/cst.md) -
      Displays call stack relationships
    - Wrapper around
      [`rlang::trace_back()`](https://rlang.r-lib.org/reference/trace_back.html)
      with simplified output
    - Shows how frames are connected through parent relationships
5.  **Low-Level Inspection** (`R/sxp.R`, `src/inspect.cpp`):
    - [`sxp()`](https://lobstr.r-lib.org/dev/reference/sxp.md) - Deep
      inspection of C-level SEXP structures
    - Recursive descent into R’s internal data structures
    - Optional expansion of: character pool, ALTREP, environments,
      calls, bytecode
    - Returns structured list with metadata (type, length, address,
      named status, etc.)
6.  **Memory Utilities** (`R/mem.R`):
    - [`mem_used()`](https://lobstr.r-lib.org/dev/reference/mem_used.md) -
      Current R memory usage via
      [`gc()`](https://rdrr.io/r/base/gc.html)
    - Platform-aware node size calculation (32-bit vs 64-bit)
7.  **Generic Tree Printing** (`R/tree.R`):
    - [`tree()`](https://lobstr.r-lib.org/dev/reference/tree.md) -
      General-purpose tree printer for nested lists
    - Highly customizable (depth, length limits, value/class printers)
    - Handles environments with cycle detection
    - Attribute display support

### Key Design Patterns

- **Tree Visualization**: Consistent tree-based output across all
  functions using shared utilities (`R/tree.R`, `R/utils.R`)
- **C++ Integration**: Performance-critical operations (memory
  addresses, size calculation, SEXP inspection) implemented in C++ via
  cpp11
- **Reference Tracking**: Inspection functions use `seen` sets to handle
  cycles and shared references
- **Lazy Evaluation**:
  [`ast()`](https://lobstr.r-lib.org/dev/reference/ast.md) and
  [`obj_addr()`](https://lobstr.r-lib.org/dev/reference/obj_addr.md) use
  rlang quasiquotation to quote the AST or avoid taking unnecessary
  references
- **Testing Stability**: Address normalization in tests (sequential IDs
  instead of actual pointers)

### File Organization

- `R/` - R source code organized by main user-facing functions
  - `ast.R`, `ref.R`, `size.R`, `cst.R`, `sxp.R` - Main visualization
    functions
  - `mem.R` - Memory utilities
  - `address.R` - Address helper functions
  - `tree.R` - Generic tree printing infrastructure
  - `utils.R` - Shared utilities (string, display, box characters)
- `src/` - C++ source code using cpp11
  - `address.cpp` - Memory address extraction
  - `size.cpp` - Object size calculation with tree traversal
  - `inspect.cpp` - Deep SEXP inspection
  - `utils.h` - Shared C++ utilities
- `tests/testthat/` - Comprehensive test suite

### C++ Implementation Details

All C++ code uses the cpp11 interface for R integration: - Uses
`std::set<SEXP>` for tracking seen objects during traversal - Implements
custom vector size calculation matching R’s memory allocation strategy -
Handles ALTREP objects (R 3.5+) with conditional compilation - Recursive
tree traversal with depth limits to prevent stack overflow - Namespace
and special environment detection to avoid infinite recursion

This codebase prioritizes accurate visualization of R’s internal
structures while maintaining performance through C++ implementation of
core algorithms.
