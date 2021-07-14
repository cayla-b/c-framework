#!/usr/bin/make
########################################################
# Directory makefile                                   #
# ---------------------------------------------------- #
# Expected variables:                                  #
#  - ROOTDIR: The directory containing this makefile   #
#  - BUILDDIR: The directory where files are generated #
########################################################
# Generation folder
BIN_DIR           = $(BUILDDIR)/bin
OBJ_DIR           = $(BUILDDIR)/obj
PRE_DIR           = $(BUILDDIR)/pre
DEP_DIR           = $(BUILDDIR)/dep
DOC_DIR           = $(BUILDDIR)/doc
TEST_BUILDDIR     = $(BUILDDIR)/tests

# Test generation folder
TEST_BIN_DIR      = $(TEST_BUILDDIR)/bin
TEST_OBJ_DIR      = $(TEST_BUILDDIR)/obj
TEST_OBJSRC_DIR   = $(TEST_OBJ_DIR)/src
TEST_DEP_DIR      = $(TEST_BUILDDIR)/dep
TEST_COV_DIR      = $(TEST_BUILDDIR)/cov
TEST_MOCK_DIR     = $(TEST_BUILDDIR)/mocks
TEST_RUNNER_DIR   = $(TEST_BUILDDIR)/runner
TEST_RES_DIR      = $(TEST_BUILDDIR)/results

# Sources Dir
SRC_DIR           			= $(ROOTDIR)/src
TEST_SRC_DIR      			= $(ROOTDIR)/tests
TOOLS_DIR        			= $(ROOTDIR)/tools
