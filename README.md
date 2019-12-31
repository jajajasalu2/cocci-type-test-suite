# Coccinelle type-test-suite generation

This repository contains files for generating the test suite to be used in
the Linux Kernel Mentorship Program project 'Linux dev-tools: Handling
complex types and attributes in Coccinelle'.

## Usage

To generate the test suite for one or more files:

```
make FILES="<filenames_separated_by_space>"
```

To generate the test suite for one directory:

```
make DIR=<directory_name>
```

To add comments of the filename and line number of each type, use the
`CODEBASE_DIR` and `ADD_COMMENTS` vars as so:

```
make FILES=<filenames_separated_by_space> ADD_COMMENTS=1 CODEBASE_DIR=<path>
```

`ADD_COMMENTS` sets the comments on.

`CODEBASE_DIR` is the path to the base directory of the codebase to generate
the files for. If it isn't given, complete paths of the files are used in the
comments. If it is given, the file path with the base directory path snipped is
used in the comments.

To run the test suite:

```
make test
```

## Helper scripts

`helper.sh` contains functions to easily interact with the generated
C/cocci files.

To remove a rule from the generated cocci file:

```
./helper.sh remrule <rule_no> [<file_name>]
```

By default, `build/output.cocci` is modified.
