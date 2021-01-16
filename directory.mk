#!/usr/bin/make
# Environment variable (by default launch make here)
BUILDDIR ?= $(ROOTDIR)/build
# Generation folder
BINDIR        = $(BUILDDIR)/bin
OBJDIR        = $(BUILDDIR)/objs
DEPDIR        = $(BUILDDIR)/deps
INCDIR        = $(BUILDDIR)/include
DOCDIR        = $(BUILDDIR)/docs
TESTRESULTDIR = $(BUILDDIR)/tests
UNITRESULTDIR = $(TESTRESULTDIR)/results
COVRESULTDIR  = $(TESTRESULTDIR)/cov

# Source Dir
SRCDIR    = $(ROOTDIR)/src
TESTSDIR  = $(ROOTDIR)/tests
TOOLSDIR  = $(ROOTDIR)/tools