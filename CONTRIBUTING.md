# Linux Make/GCC C repository
==============================================
## Presentation

This tools aims at providing a framework for C development.
I try to do it with cross-compilation in mind.
I am doing this out-of the single purpose of doing it, if you want to use it in an efficient way please
use an already existing framework and stick to it.

## Repository structure

- /build                      : Build directory where all artifact will be generated
- /build/bin                  : Where your binary are generated (static library, dynamic library or executable)
- /build/docs                 : Where you should generate your project documentation
- /build/deps                 : Where your project internal dependency should be generated
- /build/include              : Where your public C interface will be place after generation
- /build/objs                 : Where object issue from C/Assembly compilation will be generated
- /assets                     : Project assets (e.g. Image, Template, default configuration files, etc...)
- **/src                        : Source directory where all source must be stored** Here is what you search for !!!
- **/tests                      : Overall test directory** Here is where the important stuff is !!!
- /tests/assets               : Test assets directory
- /tests/project              : Test directory of the project using CMock/Unity
- /tests/toolchain            : Test directory of the present toolchain using python3.9
- /tools                      : Tools directory
- /tools/default_Makefile     : The default Makefile for building (cf. Convention)
- /tools/default_testMakefile : The default Makefile for test (cf. Convention)
- /compile.mk                 : Default object, dependencies and binary makefile
- /directory.mk               : Defines this repository structur
- /LICENSE                    : The license file for this repository
- /CONTRIBUTING.md            : This repository presentation and user manual

## Convention
### Private interface

Header file suffixed _r.h are exclude from public interface of the package being built.

***BE CAREFUL*** All other .h would be exported to included interface, hence it is up to the developper
to avoid including private interface into project visibility

### New source folder

Source directory as well as any of its subfolder must contain a file name Makefile being
a copy of /tools/default_Makefile.

### New test rolder

Project test directory as well as any of its subfolder must contain a file name Makefile being
a copy of /tools/default_testMakefile.

### Configuration files

3 configuration files exists in this framework. Their name are reserved and shall not be use for any other purpose.

1. conanfile.py

This file is the input for Conan package manager.

2. /src/config.mk

Generated to root by conan or a copy of an existing config.mk. This file contains all the nécessary input
for the toolchain (binary name, compiler, host system possibility)

3. config.h

Generated to source directory root by conan or a copy of an existing config.h. This file contain all
project related options...
