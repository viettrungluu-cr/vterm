Testing
=======

Strategy
--------

We test using a "layout test" approach: we pass prepared input sequences to the
terminal model and then examine the state of the model afterwards (comparing it
to some expected state). The state includes display state (characters displayed,
with colors and other attributes), and things like cursor position, whether the
bell was rung (and when), etc.

Though it's entirely possible to manually generate baseline output, it's more
convenient to compare output to that from "known good" terminal models (given
the same input), possibly written in different languages. As such, it's
convenient to standardize the input/output pipeline.

Test input
----------

Input shall consist of a sequence of files, possibly interleaved with some input
given via standard input. See below for how this input is given to the
terminal-model-specific pipeline.

Test output
-----------

Output shall be to standard output, in the form of JSON. TODO(vtl): specifics.

Terminal-model-specific pipeline
--------------------------------

For a given terminal model `foo`, there should be a program `foo_test_filter`
that can take command-line parameters:

```
foo_test_filter [option]... [--] (FILE|-)...
```

If necessary, `foo_test_filter` may be preceded by necessary verbiage to invoke
the interpreter (or similar).

`option` shall be of the form `-f` or `--flag`; combining multiple single-letter
options (so that, e.g., `-abc` is equivalent to `-a -b -a`) need not be
supported. Standard options include `-h`/`--help` and `-v`/`--verbose` (verbose
logging shall be to standard error).

Option processing will be terminated by the first file (not beginning with `-`),
the first instance of `-` (alone) indicating standard input, or by the no-op
option `--`.

E.g.,

```
foo_test_filter -v -- -v file -- -
```

shall invoke the test filter in verbose mode (first `-v`), taking input from a
file called `-v`, then from a file called `file`, then from a file called `--`
(the second `--`), and finally from standard input (the `-`).
