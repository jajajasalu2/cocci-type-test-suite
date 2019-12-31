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
