# Display tree of source references

View source reference metadata attached to R objects in a tree
structure. Shows source file information, line/column locations, and
lines of source code.

## Usage

``` r
src(x, max_depth = 5L, max_length = 100L, ...)
```

## Arguments

- x:

  An R object with source references. Can be:

  - A `srcref` object

  - A list of `srcref` objects

  - A expression vector with attached source references

  - An evaluated closure with attached source references

  - A quoted call with attached source references

- max_depth:

  Maximum depth to traverse nested structures (default 5)

- max_length:

  Maximum number of srcref nodes to display (default 100)

- ...:

  Additional arguments passed to
  [`tree()`](https://lobstr.r-lib.org/reference/tree.md)

## Value

Returns a structured list containing the source reference information.
Print it to view the formatted tree.

## Overview

Source references are made of two kinds of objects:

- `srcref` objects, which contain information about a specific location
  within the source file, such as the line and column numbers.

- `srcfile` objects, which contain metadata about the source file such
  as its name, path, and encoding.

### Where and when are source references created?

Ultimately the R parser creates source references. The main two entry
points to the parser are:

- The R function [`parse()`](https://rdrr.io/r/base/parse.html).

- The frontend hook `ReadConsole`, which powers the console input parser
  in the R CLI and in IDEs. This C-level parser can also be accessed
  from C code via `R_ParseVector()`.

In principle, anything that calls
[`parse()`](https://rdrr.io/r/base/parse.html) may create source
references, but here are the important direct and indirect callers:

- [`source()`](https://rdrr.io/r/base/source.html) and
  [`sys.source()`](https://rdrr.io/r/base/sys.source.html) which parse
  and evaluate code.

- [`loadNamespace()`](https://rdrr.io/r/base/ns-load.html) calls
  [`sys.source()`](https://rdrr.io/r/base/sys.source.html) when loading
  a *source* package:
  <https://github.com/r-devel/r-svn/blob/acd196be/src/library/base/R/namespace.R#L573>.

- `R CMD install` creates a lazy-load database from a source package.
  The first step is to call
  [`loadNamespace()`](https://rdrr.io/r/base/ns-load.html):
  <https://github.com/r-devel/r-svn/blob/acd196be/src/library/tools/R/makeLazyLoad.R#L32>

By default source references are not created but can be enabled by:

- Passing `keep.source = TRUE` explicitly to
  [`parse()`](https://rdrr.io/r/base/parse.html),
  [`source()`](https://rdrr.io/r/base/source.html),
  [`sys.source()`](https://rdrr.io/r/base/sys.source.html), or
  [`loadNamespace()`](https://rdrr.io/r/base/ns-load.html).

- Setting `options(keep.source = TRUE)`. This affects the default
  arguments of the aforementioned functions, as well as the console
  input parser. In interactive sessions, `keep.source` is set to `TRUE`
  by default:
  <https://github.com/r-devel/r-svn/blob/3a4745af/src/library/profile/Common.R#L26>.

- Setting `options(keep.source.pkgs = TRUE)`. This affects loading a
  package from source, and installing a package from source.

### `srcref` objects

`srcref` objects are compact integer vectors describing a character
range in a source. It records start/end lines and byte/column positions
and, optionally, the parsed-line numbers if `#line` directives were
used.

Lengths of 4, 6, or 8 are allowed:

- 4: basic (first_line, first_byte, last_line, last_byte). Byte
  positions are within the line.

- 6: adds columns in Unicode codepoints (first_col, last_col)

- 8: adds parsed-line numbers (first_parsed, last_parsed)

The "column" information does not represent grapheme clusters, but
Unicode codepoints. The column cursor is incremented at every UTF-8 lead
byte and there is no support for encodings other than UTF-8.

The srcref columns are right-boundary positions, meaning that for an
expression starting at the start of a line, the column will be 1.
`wholeSrcref` (see below) on the other hand starts at 0, before the
first character. It might also end 1 character after the last srcref
column.

They are attached as attributes (e.g. `attr(x, "srcref")` or
`attr(x, "wholeSrcref")`), possibly wrapped in a list, to the following
objects:

- Expression vectors returned by
  [`parse()`](https://rdrr.io/r/base/parse.html) (wrapped in a list)

- Quoted function calls (unwrapped)

- Quoted `{` calls (wrapped in a list). This is crucial for debugging:
  when R steps through brace lists, the srcref for the current
  expression is saved to a global variable (`R_Srcref`) so the IDE knows
  exactly where execution is paused. See:
  <https://github.com/r-devel/r-svn/blob/fa0b47c5/src/main/eval.c#L2986>.

- Evaluated closures (unwrapped)

They have a `srcfile` attribute that points to the source file.

Methods:

- [`as.character()`](https://rdrr.io/r/base/character.html): Retrieves
  relevant source lines from the `srcfile` reference.

#### `wholeSrcref` attributes

These are `srcref` objects stored in the `wholeSrcref` attributes of:

- Expression vectors returned by
  [`parse()`](https://rdrr.io/r/base/parse.html), which seems to be the
  intended usage.

- `{` calls, which seems unintended.

For expression vectors, the `wholeSrcref` spans from the first position
to the last position and represents the entire document. For braces,
they span from the first position to the location of the closing brace.
There is no way to know the location of the opening brace without
reparsing, which seems odd. It's probably an overlook from
`xxexprlist()` calling `attachSrcrefs()` in
<https://github.com/r-devel/r-svn/blob/52affc16/src/main/gram.y#L1380>.
That function is also called at the end of parsing, where it's intended
for the `wholeSrcref` attribute to be attached.

For evaluated closures, the `wholeSrcref` attribute on the body has the
same unreliable start positions as `{` nodes.

### `srcfile` objects

`srcfile` objects are environments representing information about a
source file that a source reference points to. They typically refer to a
file on disk and store the filename, working directory, a timestamp, and
encoding information.

While it is possible to create bare `srcfile` objects, specialized
subclasses are much more common.

#### `srcfile`

A bare `srcfile` object does not contain any data apart from the file
path. It lazily loads lines from the file on disk, without any caching.

Fields common to all `srcfile` objects:

- `filename`: The filename of the source file. If relative, the path is
  resolved against `wd`.

- `wd`: The working directory
  ([`getwd()`](https://rdrr.io/r/base/getwd.html)) at the time the
  srcfile was created, generally at the time of parsing).

- `timestamp`: The timestamp of the source file. Retrieved from
  `filename` with
  [`file.mtime()`](https://rdrr.io/r/base/file.info.html).

- `encoding`: The encoding of the source file.

- `Enc`: The encoding of output lines. Used by
  [`getSrcLines()`](https://rdrr.io/r/base/srcfile.html), which calls
  [`iconv()`](https://rdrr.io/r/base/iconv.html) when `Enc` does not
  match `encoding`.

- `parseData` (optional): Parser information saved when
  `keep.source.data` is set to `TRUE`.

Implementations:

- [`print()`](https://rdrr.io/r/base/print.html) and
  [`summary()`](https://rdrr.io/r/base/summary.html) to print
  information about the source file.

- [`open()`](https://rdrr.io/r/base/connections.html) and
  [`close()`](https://rdrr.io/r/base/connections.html) to access the
  underlying file as a connection.

Helpers:

- [`getSrcLines()`](https://rdrr.io/r/base/srcfile.html): Retrieves
  source lines from a `srcfile`.

#### `srcfilecopy`

A `srcfilecopy` stores the actual source lines in memory in `$lines`.
`srcfilecopy` is useful when the original file may change or does not
exist, because it preserves the exact text used by the parser.

This type of srcfile is the most common. It's created by:

- The R-level [`parse()`](https://rdrr.io/r/base/parse.html) function
  when `text` is supplied:

      # Creates a `"<text>"` non-file `srcfilecopy`
      parse(text = "...", keep.source = TRUE)

- The console's input parser when `getOption("keep.source")` is `TRUE`.

- [`sys.source()`](https://rdrr.io/r/base/sys.source.html) when
  `keep.source = TRUE`:

      sys.source(file, keep.source = TRUE)

  The `srcfilecopy` object is timestamped with the file's last
  modification time.
  <https://github.com/r-devel/r-svn/blob/52affc16/src/library/base/R/source.R#L273-L276>

Fields:

- `filename`: The filename of the source file. If `isFile` is `FALSE`,
  the field is non meaningful. For instance `parse(text = )` sets it to
  `"<text>"`, and the console input parser sets it to `""`.

- `isFile`: A logical indicating whether the source file exists.

- `fixedNewlines`: If `TRUE`, `lines` is a character vector of lines
  with no embedded `\n` characters. The
  [`getSrcLines()`](https://rdrr.io/r/base/srcfile.html) helper
  regularises `lines` in this way and sets `fixedNewlines` to `TRUE`.

Note that the C-level parser (used directly mainly when parsing console
input) does not call the R-level constructor and only instantiates the
`filename` (set to `""`) and `lines` fields.

#### `srcfilealias`

This object wraps an existing `srcfile` object (stored in `original`).
It allows exposing a different `filename` while delegating the
open/close/get lines operations to the `srcfile` stored in `original`.

The typical way aliases are created is via `#line *line* *filename*`
directives where the optional `*filename*` argument is supplied. These
directives remap the srcref and srcfile of parsed code to a different
location, for example from a temporary file or generated file to the
original location on disk.

Created by
[`install.packages()`](https://rdrr.io/r/utils/install.packages.html)
when installing a *source* package with `keep.source.pkgs` set to `TRUE`
(see
<https://github.com/r-devel/r-svn/blob/52affc16/src/library/tools/R/install.R#L545>),
but [only
when](https://github.com/r-devel/r-svn/blob/52affc16/src/library/tools/R/admin.R#L308):

- `Encoding` was supplied in `DESCRIPTION`

- The system locale is not "C" or "POSIX".

The source files are converted to the encoding of the system locale,
then collated in a single source file with `#line` directives mapping
them to their original file names (with full paths):
<https://github.com/r-devel/r-svn/blob/52affc16/src/library/tools/R/admin.R#L342>.

Note that the `filename` of the `original` srcfile incorrectly points to
the package path in the install destination.

Fields:

- `filename`: The virtual file name (or full path) of the parsed code.

- `original`: The actual `srcfile` the code was parsed from.

## See also

- [`srcfile()`](https://rdrr.io/r/base/srcfile.html): Base documentation
  for `srcref` and `srcfile` objects.

- [`getParseData()`](https://rdrr.io/r/utils/getParseData.html): Parse
  information stored when `keep.source.data` is `TRUE`.

- Source References (R Journal):
  <https://journal.r-project.org/articles/RJ-2010-010/>

Other object inspectors:
[`ast()`](https://lobstr.r-lib.org/reference/ast.md),
[`ref()`](https://lobstr.r-lib.org/reference/ref.md),
[`sxp()`](https://lobstr.r-lib.org/reference/sxp.md)
