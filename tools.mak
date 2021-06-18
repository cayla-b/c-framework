#!/usr/bin/make
########################################################
# Required tools makefile                              #
########################################################
# Tools to use
# Generation tools if not defined by configuration.mak
FIND           ?= find
TIMEOUT		   ?= timeout
DOXYGEN        ?= doxygen
RUBY           ?= ruby
PYTHON         ?= python
MKDIR          ?= mkdir -p
ECHO           ?= echo
HOST_LD        ?= ld
HOST_AR        ?= ar
HOST_AS        ?= as
HOST_CC        ?= gcc
HOST_GCOV      ?= gcov
TARGET_LD      ?= ld
TARGET_AR      ?= ar
TARGET_AS      ?= as
TARGET_CC      ?= gcc
TARGET_GCOV    ?= gcov
RM             ?= rm --preserve-root -rf
CP             ?= cp
MV             ?= mv
$(shell $(MAKE) --version > /dev/null)
$(shell $(FIND) --version > /dev/null)
$(shell $(TIMEOUT) --version > /dev/null)
$(shell $(DOXYGEN) --version > /dev/null)
$(shell $(RUBY) --version > /dev/null)
$(shell $(PYTHON) --version > /dev/null)
$(shell $(MKDIR) --version > /dev/null)
$(shell $(ECHO) --version > /dev/null)
$(shell $(HOST_LD) --version > /dev/null)
$(shell $(HOST_AR) --version > /dev/null)
$(shell $(HOST_CC) --version > /dev/null)
$(shell $(HOST_GCOV) --version > /dev/null)
$(shell $(TARGET_LD) --version > /dev/null)
$(shell $(TARGET_AR) --version > /dev/null)
$(shell $(TARGET_CC) --version > /dev/null)
$(shell $(TARGET_GCOV) --version > /dev/null)
$(shell $(RM) --version > /dev/null)
$(shell $(CP) --version > /dev/null)
$(shell $(MV) --version > /dev/null)
