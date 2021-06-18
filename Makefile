#!/usr/bin/make
########################################################
# Root Makefile                                        #
# ---------------------------------------------------- #
# Options:                                             #
#  - ROOTDIR: The directory containing this makefile   #
#  - BUILDDIR: The directory where files are generated #
#  - VERBOSE: Equal to 1 if verbose output required    #
#  - COVERAGE: Define the expected level of coverage   #
########################################################
# Resolving external environment - ROOTDIR - PWD by default
ifeq ($(shell uname -o), Cygwin)
ROOTDIR ?= $(shell cygpath -m $(abspath .))
else
ROOTDIR ?= $(abspath .)
endif

# Resolving external environment - BUILDDIR - PWD/build by default
ifeq ($(shell uname -o), Cygwin)
BUILDDIR ?= $(shell cygpath -m $(abspath $(ROOTDIR)/build))
else
BUILDDIR ?= $(abspath $(ROOTDIR)/build)
endif

# resolving external environment - VERBOSE_DIR - Not verbose by default
VERBOSE ?= 0
ifeq ($(VERBOSE), 1)
V?=
else
V?=@
endif

# resolving external environment - COVERAGE - Covered by default
COVERAGE ?= Statement
ifneq ($(COVERAGE),None)
ifneq ($(COVERAGE),Statement)
ifneq ($(COVERAGE),Decisions)
ifneq ($(COVERAGE),MC_DC)
$(error Unknown coverage $(COVERAGE) please select one of the following [None,Statement,Decisions,MC_DC] !)
endif
endif
endif
endif

# Include makefile useful to defines (directory mandatory, whilst configuration and conanbuildinfo requires conan configuration set up)
-include $(ROOTDIR)/configuration.mak
-include $(ROOTDIR)/conanbuildinfo.mak
include  $(ROOTDIR)/directory.mak
include  $(ROOTDIR)/tools.mak

########################################################
# PHONY build rules
########################################################
.PHONY: all
all: build doc tests

.PHONY: build
build:
	$(V)$(MAKE) -C $(SRC_DIR) ROOTDIR=$(ROOTDIR) BUILDDIR=$(BUILDDIR) VERBOSE=$(VERBOSE) all

.PHONY: doc
doc: $(ROOTDIR)/Doxyfile
	-$(V)$(RM) --preserve-root -rf $(DOC_DIR)
	$(V)$(MKDIR) $(dir $(DOC_DIR))
	$(V)$(DOXYGEN)
	$(V)$(MV) ./doc $(DOC_DIR)

.PHONY: tests
tests:
	$(V)$(MAKE) -C $(TEST_SRC_DIR) ROOTDIR=$(ROOTDIR) BUILDDIR=$(BUILDDIR) VERBOSE=$(VERBOSE) COVERAGE=$(COVERAGE) all

########################################################
# PHONY clean rules
########################################################
.PHONY: clean
clean:
	-$(V)$(MAKE) -i -C $(SRC_DIR) ROOTDIR=$(ROOTDIR) BUILDDIR=$(BUILDDIR) VERBOSE=$(VERBOSE) clean
	-$(V)$(RM) --preserve-root -rf $(DOC_DIR)/*
	-$(V)$(MAKE) -i -C $(TEST_SRC_DIR) ROOTDIR=$(ROOTDIR) BUILDDIR=$(BUILDDIR) VERBOSE=$(VERBOSE) COVERAGE=$(COVERAGE) clean

.PHONY: distclean
distclean: clean
	-$(V)$(RM) --preserve-root $(ROOTDIR)/configuration.mak
	-$(V)$(RM) --preserve-root $(ROOTDIR)/conanbuildinfo.mak

########################################################
# PHONY help rules
########################################################
.PHONY: help
help:
	$(V)$(ECHO) Help for this repository
	$(V)$(ECHO)
	$(V)$(ECHO) "=== Available rules ============================================================"
	$(V)$(ECHO) "        all       : Build the entire package"
	$(V)$(ECHO) "        build     : Build only the binary artifact according to $(SRC_DIR) Makefiles"
	$(V)$(ECHO) "        test      : Pass the entire test campaign according to $(TEST_SRC_DIR) Makefiles"
	$(V)$(ECHO) "        clean     : Remove all make generated artifact & test"
	$(V)$(ECHO) "        distclean : Remove all generated files (e.g. pre-make files)"
	$(V)$(ECHO) "        help      : Display this message"
	$(V)$(ECHO) "        tools_ver : Display tool version"
	$(V)$(ECHO)
	$(V)$(ECHO) "=== Available options =========================================================="
	$(V)$(ECHO) "        ROOTDIR   : Path to this makefile (default: $(PWD))"
	$(V)$(ECHO) "        BUILDDIR  : Path to the repository where to build this package (default: $(PWD)/build)"
	$(V)$(ECHO) "        VERBOSE   : Set to 1 to obatin verbose output (default: 0)"
	$(V)$(ECHO) "        COVERAGE  : Provide a coverage analysis of all C files in $(SRC_DIR) by all test inside $(TEST_SRC_DIR) (default: Statement)"
	$(V)$(ECHO) "                  - None, bypass the coverage analysis"
	$(V)$(ECHO) "                  - Statement, provide a C statement coverage"
	$(V)$(ECHO) "                  - Decision, provide a C decision (true/false) coverage"
	$(V)$(ECHO) "                  - MC_DC, provide a C full combinatory coverage"
	$(V)$(ECHO)

.PHONY: tools_ver
tools_ver:
	$(V)$(ECHO) "=== Tools version =============================================================="
	-$(V)$(MAKE) --version
	-$(V)$(FIND) --version
	-$(V)$(TIMEOUT) --version
	-$(V)$(DOXYGEN) --version
	-$(V)$(RUBY) --version
	-$(V)$(PYTHON) --version
	-$(V)$(MKDIR) --version
	-$(V)$(ECHO) --version
	-$(V)$(HOST_LD) --version
	-$(V)$(HOST_AR) --version
	-$(V)$(HOST_AS) --version
	-$(V)$(HOST_CC) --version
	-$(V)$(HOST_GCOV) --version
	-$(V)$(TARGET_LD) --version
	-$(V)$(TARGET_AR) --version
	-$(V)$(TARGET_AS) --version
	-$(V)$(TARGET_CC) --version
	-$(V)$(TARGET_GCOV) --version
	-$(V)$(RM) --version
	-$(V)$(CP) --version
	-$(V)$(MV) --version