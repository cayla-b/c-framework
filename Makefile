#!/usr/bin/make
########################################################
# Root directory                                       #
# ---------------------------------------------------- #
# Options:                                             #
#  - ROOTDIR: The directory containing this makefile   #
#  - BUILDDIR: The directory where files are generated #
########################################################
# Rules to make object
ROOTDIR  ?= $(shell git rev-parse --show-toplevel || echo '$(realpath .)')
include $(ROOTDIR)/directory.mk
include $(ROOTDIR)/compile.mk

########################################################
# PHONY build rules
########################################################
.PHONY: all
all:
all: bin test
	@$(ECHO) Package component

.PHONY: bin
bin:
	@-$(MAKE) -C $(SRCDIR) ROOTDIR=$(ROOTDIR) BUILDDIR=$(BUILDDIR) all
	@-$(RM) $(BINDIR)/$(TARGETNAME)
	@-$(MAKE) $(BINDIR)/$(TARGETNAME)

.PHONY: test
test:
	@-$(MAKE) -C $(TESTSDIR) ROOTDIR=$(ROOTDIR) BUILDDIR=$(BUILDDIR) all

########################################################
# PHONY clean rules
########################################################
.PHONY: clean
clean:
	@-$(MAKE) -C $(SRCDIR)   ROOTDIR=$(ROOTDIR) BUILDDIR=$(BUILDDIR) clean
	@-$(MAKE) -C $(TESTSDIR) ROOTDIR=$(ROOTDIR) BUILDDIR=$(BUILDDIR) clean
	@-$(RM) $(BINDIR)/$(TARGETNAME)

.PHONY: distclean
distclean:
	@-$(RM) -r $(BUILDDIR)
	@$(ECHO) Remove config.mk and config.h

########################################################
# PHONY help rules
########################################################
.PHONY: help
help:
	@$(ECHO) Help for this repository
	@$(ECHO)
	@$(ECHO) "=== Available rules ============================================================"
	@$(ECHO) "        all       : Build the entire package"
	@$(ECHO) "        bin       : Build only the binary artifact $(TARGETNAME)"
	@$(ECHO) "        test      : Pass the entire test campaign"
	@$(ECHO) "        clean     : Remove all make generated artifact"
	@$(ECHO) "        distclean : Remove all generated files (e.g. pre-make files)"
	@$(ECHO) "        help      : Display this message"
	@$(ECHO) "        tools_ver : "
	@$(ECHO)
	@$(ECHO) "=== Available options =========================================================="
	@$(ECHO) "        ROOTDIR   : Path to this makefile"
	@$(ECHO) "        BUILDDIR  : Path to the repository where to build this package"
	@$(ECHO)
	@$(ECHO) "Note:  All provided path must be either absolute or pwd relative ($(shell $(PWD)))"
	@$(ECHO) "Note2: If ROOTDIR not provided, and pwd in a git repository then considers repository root"
	@$(ECHO) "Note3: If ROOTDIR not provided, and pwd not a repostiroy then consider pwd"
	@$(ECHO)

.PHONY: tools_ver
tools_ver:
	@$(ECHO) "=== Tools version =============================================================="
	@$(ECHO) "Make version"
	@$(MAKE) --version
	@$(ECHO)
	@$(ECHO) "Compiler version"
	@$(CC) --version
	@$(ECHO) "Binutils version"
	@$(LD) --version