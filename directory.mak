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
TEST_OBJ_DIR      = $(TEST_BUILDDIR)/obj
TEST_COV_DIR      = $(TEST_BUILDDIR)/cov
TEST_MOCK_DIR     = $(TEST_BUILDDIR)/mocks

# Unit test generation folder
UNIT_TEST_BUILDDIR     = $(TEST_BUILDDIR)/unit
UNIT_TEST_BIN_DIR      = $(UNIT_TEST_BUILDDIR)/bin
UNIT_TEST_OBJ_DIR      = $(UNIT_TEST_BUILDDIR)/obj
UNIT_TEST_DEP_DIR      = $(UNIT_TEST_BUILDDIR)/dep
UNIT_TEST_RUNNER_DIR   = $(UNIT_TEST_BUILDDIR)/runner
UNIT_TEST_RES_DIR      = $(UNIT_TEST_BUILDDIR)/results

# Integration test generation folder
INTEGRATION_TEST_BUILDDIR     = $(TEST_BUILDDIR)/integration
INTEGRATION_TEST_BIN_DIR      = $(INTEGRATION_TEST_BUILDDIR)/bin
INTEGRATION_TEST_OBJ_DIR      = $(INTEGRATION_TEST_BUILDDIR)/obj
INTEGRATION_TEST_DEP_DIR      = $(INTEGRATION_TEST_BUILDDIR)/dep
INTEGRATION_TEST_RUNNER_DIR   = $(INTEGRATION_TEST_BUILDDIR)/runner
INTEGRATION_TEST_RES_DIR      = $(INTEGRATION_TEST_BUILDDIR)/results

# Sources Dir
SRC_DIR           			= $(ROOTDIR)/src
TEST_SRC_DIR      			= $(ROOTDIR)/tests
UNIT_TEST_SRC_DIR 			= $(TEST_SRC_DIR)/unit
INTEGRATION_TEST_SRC_DIR 	= $(TEST_SRC_DIR)/integration
TOOLS_DIR        			= $(ROOTDIR)/tools
