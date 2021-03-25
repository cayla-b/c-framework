# Linux Make/GCC C repository
==============================================
## Presentation

This tools aims at providing a framework for C development.
I try to do it with cross-compilation in mind.
I am doing this out-of the single purpose of doing it, if you want to use it in an efficient way please
use an already existing framework and stick to it.

## Repository structure

- /build                      : Build directory where all artifact will be generated
- /build/bin                  : Where your binary are generated (dynamic library or executable, and static library)
- /build/doc                  : Where your documentation are generated
- /build/dep                  : Where your project internal dependency should be generated
- /build/obj                  : Where object issue from C/Assembly compilation will be generated
- /build/pre                  : Where intermediate pre-processed files are generated (for possible static analysis)
- **/src                        : Source directory where all source must be stored** Here is what you search for !!!
- **/tests                      : Overall test directory** Here is where the important stuff is !!!
- **/tests/unit                 : Unit test scenarii shall be name ut_<tested C file name>_<id>.c** (all others files are considered assets)
- **/tests/integration          : Integration test scenarii shall be name it_<id>.c** (all others files are considered assets)
- /tools                      : Tools directory
- /tools/cmock                : Tested framework
- /LICENSE                    : The license file for this repository
- /CONTRIBUTING.md            : This repository presentation and user manual
- /Doxyfile                   : Generation documentation file
- /Makefile                   : The build file system description
- /test.yml                   : The Test framework configuration file (note: weak configuration shall be left)

## Convention
### New source folder

To add a new source simply add .c, .s, .S or .h files in src folder.

### New test rolder

To create a new test, it depends on which kind of test is required:
 - Unit test: test 1 source file that whose test scenario shall be named ut_<code(c,s,S) filename>_<id>.c
   - Unit test assets
 - Integration test: test overall source of this folder with its correct dependancy scenario shall be named it_<id>.c
   - Integration test assets

### Configuration files

3 configuration files exists in this framework. Their name are reserved and shall not be use for any other purpose.

1. conanfile.py

This file is the input for Conan package manager.

2. /Doxyfile

This file contains the information required for document generation

3. /test.yml

This file contains the configuration for test framework
