#!/usr/bin/make
########################################################
# Root directory                                       #
# ---------------------------------------------------- #
# Options:                                             #
#  - ROOTDIR: The directory containing this makefile   #
#  - BUILDDIR: The directory where files are generated #
########################################################
# resolving external environment - SOURCE_DIR
ROOT_DIR ?= .
ifeq ($(shell uname -o), Cygwin)
SOURCE_DIR = $(shell cygpath -m $(abspath $(ROOT_DIR)))
else
SOURCE_DIR = $(abspath $(ROOT_DIR))
endif

# resolving external environment - VERBOSE_DIR
VERBOSE ?= 0
ifeq ($(VERBOSE), 1)
V?=
else
V?=@
endif

# resolving external environment - BUILD_DIR
BUILD_DIR ?= $(SOURCE_DIR)/build
ifeq ($(shell uname -o), Cygwin)
GENERATION_DIR = $(shell cygpath -m $(abspath $(BUILD_DIR)))
else
GENERATION_DIR = $(abspath $(BUILD_DIR))
endif

-include $(SOURCE_DIR)/conanbuildinfo.mak

# Generation tools if not defined by conanbuildinfo.mak
FIND           ?= find
DOXYGEN        ?= doxygen
MKDIR          ?= mkdir -p
ECHO           ?= echo
HOST_LD        ?= ld
HOST_AR        ?= ar
HOST_CC        ?= gcc
TARGET_LD      ?= ld
TARGET_AR      ?= ar
TARGET_CC      ?= gcc
RM             ?= rm --preserve-root -rf
CP             ?= cp
MV             ?= mv
$(shell $(FIND) --version > /dev/null)
$(shell $(DOXYGEN) --version > /dev/null)
$(shell $(MKDIR) --version > /dev/null)
$(shell $(ECHO) --version > /dev/null)
$(shell $(HOST_LD) --version > /dev/null)
$(shell $(HOST_AR) --version > /dev/null)
$(shell $(HOST_CC) --version > /dev/null)
$(shell $(TARGET_LD) --version > /dev/null)
$(shell $(TARGET_AR) --version > /dev/null)
$(shell $(TARGET_CC) --version > /dev/null)
$(shell $(RM) --version > /dev/null)
$(shell $(CP) --version > /dev/null)

export UNITY_DIR=$(TOOLS_DIR)/cmock/vendor/unity
export CMOCK_DIR=$(TOOLS_DIR)/cmock

# Generation folder
BIN_DIR           = $(GENERATION_DIR)/bin
OBJ_DIR           = $(GENERATION_DIR)/obj
PRE_DIR           = $(GENERATION_DIR)/pre
DEP_DIR           = $(GENERATION_DIR)/dep
DOC_DIR           = $(GENERATION_DIR)/doc
TEST_BUILD_DIR    = $(GENERATION_DIR)/tests
TEST_BIN_DIR      = $(TEST_BUILD_DIR)/bin
TEST_OBJ_DIR      = $(TEST_BUILD_DIR)/obj
TEST_RUNNER_DIR   = $(TEST_BUILD_DIR)/runner
TEST_MOCK_DIR     = $(TEST_BUILD_DIR)/mocks
TEST_RES_DIR      = $(TEST_BUILD_DIR)/results
TEST_COV_DIR      = $(TEST_BUILD_DIR)/cov

# Source Dir
SRC_DIR           = $(SOURCE_DIR)/src
TEST_SRC_DIR      = $(SOURCE_DIR)/tests
TOOLS_DIR         = $(SOURCE_DIR)/tools

SRCS        = $(shell $(FIND) $(SRC_DIR) -name "*.c" -o -name "*.s" -o -name "*.S")
HDRS        = $(shell $(FIND) $(SRC_DIR) $(CONAN_INCLUDE_DIRS) -name "*.h")

PRES        = $(patsubst $(SRC_DIR)/%.c,$(PRE_DIR)/%.i,$(SRCS))
DEPS        = $(patsubst $(SRC_DIR)/%.c,$(DEP_DIR)/%.d,$(SRCS))
OBJS        = $(patsubst $(SRC_DIR)/%.c,$(OBJ_DIR)/%.o,$(SRCS))
TESTED_OBJS = $(patsubst $(SRC_DIR)/%.c,$(TEST_OBJ_DIR)/%.o,$(SRCS))

TESTS_SCENAR      = $(shell $(FIND) $(TEST_SRC_DIR) -name "ut_*.c" -o -name "it_*.c")

TESTS_SCENAR_OBJS = $(patsubst $(TEST_SRC_DIR)/%.c,$(TEST_OBJ_DIR)/%.o,$(TESTS_SCENAR))
TESTS_ASSET       = $(filter-out $(TESTS_SCENAR),$(shell $(FIND) $(TEST_SRC_DIR) -name "*.c"))
TESTS_ASSET_OBJS  = $(patsubst $(TEST_SRC_DIR)/%.c,$(TEST_OBJ_DIR)/%.o,$(TESTS_ASSET))
TESTS_RUNNER      = $(patsubst $(TEST_SRC_DIR)/%.c,$(TEST_RUNNER_DIR)/%_Runner.c,$(TESTS_SCENAR))
TESTS_RUNNER_OBJS = $(patsubst $(TEST_SRC_DIR)/%.c,$(TEST_RUNNER_DIR)/%_Runner.o,$(TESTS_SCENAR))
TESTS_MOCKS_C     = $(foreach dirs,$(patsubst %/,%,$(sort $(dir $(HDRS)))),$(patsubst $(dirs)/%.h,$(TEST_MOCK_DIR)/Mock%.c,$(HDRS)))
TESTS_MOCKS_H     = $(patsubst %.c,%.h,$(TESTS_MOCKS_C))
TESTS_MOCKS_OBJS  = $(patsubst %.c,%.o,$(TESTS_MOCKS_C))
TESTS_BIN         = $(patsubst $(TEST_SRC_DIR)/%.c,$(TEST_BIN_DIR)/%,$(TESTS_SCENAR))
TESTS_RESULTS     = $(patsubst $(TEST_SRC_DIR)/%.c,$(TEST_RES_DIR)/%.testresults,$(TESTS_SCENAR))

CFLAGS  = $(CONAN_CFLAGS)
CFLAGS += $(addprefix -I,$(patsubst %/,%,$(sort $(dir $(HDRS)))))
CFLAGS += $(addprefix -D,$(CONAN_DEFINES))
CFLAGS += -Wall

LDFLAGS  = $(addprefix -L,$(patsubst %/,%,$(CONAN_LIB_DIRS)))
LDFLAGS += -Wl,-\( $(addprefix -l,$(CONAN_LIBS)) -Wl,-\)

# resolving external environment - COVERAGE
COVERAGE ?= 0
ifeq ($(COVERAGE), 1)
COVERAGE_CFLAGS=--coverage -fprofile-note=$(TEST_COV_DIR)
COVERAGE_LDLAGS=
else
COVERAGE_CFLAGS=
COVERAGE_LDLAGS=
endif

########################################################
# PHONY build rules
########################################################
TARGET=myProject
.PHONY: all
all: build doc test

.PHONY: build
build: $(BIN_DIR)

.PHONY: doc
doc: $(SOURCE_DIR)/Doxyfile $(SRCS) $(HDRS)
	@$(RM) --preserve-root -rf $(DOC_DIR)
	@$(MKDIR) $(dir $@)
	@$(DOXYGEN)
	@$(MV) ./doc $(DOC_DIR)

.PHONY: test
test: $(TESTS_RESULTS)
	@ruby $(UNITY_DIR)/auto/unity_test_summary.rb $(TEST_RES_DIR) $(SOURCE_DIR)

########################################################
# Rules to build the target
########################################################
$(BIN_DIR): $(BIN_DIR)/$(TARGET) $(BIN_DIR)/lib$(TARGET).a

$(BIN_DIR)/%: $(OBJS)
	@$(MKDIR) $(dir $@)
	@$(ECHO) LD $(notdir $@)
	$(V)$(TARGET_CC) $(LDFLAGS) $^ -o $@ -Wl,-Map=$(@:=.map)

$(BIN_DIR)/lib%.a: $(OBJS)
	@$(MKDIR) $(dir $@)
	@$(ECHO) AR $(notdir $@)
	$(V)$(TARGET_AR) r $@ $^

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c $(PRE_DIR)/%.i $(DEP_DIR)/%.d
	@$(MKDIR) $(dir $@)
	@$(ECHO) CC $(notdir $@)
	$(V)$(TARGET_CC) -c $(CFLAGS) $< -o $@

$(PRE_DIR)/%.i: $(SRC_DIR)/%.c
	@$(MKDIR) $(dir $@)
	$(V)$(TARGET_CC) -E $(CFLAGS) $< > $@

$(DEP_DIR)/%.d: $(SRC_DIR)/%.c
	@$(MKDIR) $(dir $@)
	$(V)$(TARGET_CC) $(CFLAGS) -MT $(patsubst $(DEP_DIR)/%.d,$(OBJ_DIR)/%.o,$@) -MM -MF $@ $<

########################################################
# Rules to build tests
########################################################
$(TEST_RES_DIR)/%.testresults: $(TEST_BIN_DIR)/%
	@$(MKDIR) $(dir $@)
	@$< > $@

$(TEST_RUNNER_DIR)/%_Runner.o: $(TEST_RUNNER_DIR)/%_Runner.c
	@$(MKDIR) $(dir $@)
	@$(ECHO) CC $(notdir $@)
	$(V)$(HOST_CC) -c $(CFLAGS) -DTEST -I$(UNITY_DIR)/src -I$(CMOCK_DIR)/src $< -o $@

$(TEST_RUNNER_DIR)/%_Runner.c: $(TEST_SRC_DIR)/%.c
	@$(MKDIR) $(dir $@)
	@ruby $(UNITY_DIR)/auto/generate_test_runner.rb $< $@

$(TEST_OBJ_DIR)/%.o: $(TEST_SRC_DIR)/%.c
	@$(MKDIR) $(dir $@)
	@$(ECHO) CC $(notdir $@)
	$(V)$(HOST_CC) -c $(CFLAGS) -DTEST -I$(UNITY_DIR)/src -I$(CMOCK_DIR)/src $< -o $@

$(TEST_OBJ_DIR)/%.o: $(SRC_DIR)/%.c
	@$(MKDIR) $(dir $@)
	@$(MKDIR) $(TEST_COV_DIR)
	@$(ECHO) CC $(notdir $@)
	$(V)$(TARGET_CC) -c $(CFLAGS) $(COVERAGE_CFLAGS) -DTEST $< -o $@

$(UNITY_DIR)/src/unity.o: $(UNITY_DIR)/src/unity.c
	@$(ECHO) CC $(notdir $@)
	$(V)$(HOST_CC) -c $(CFLAGS) -DTEST -I$(UNITY_DIR)/src -I$(CMOCK_DIR)/src $< -o $@

$(CMOCK_DIR)/src/cmock.o: $(CMOCK_DIR)/src/cmock.c
	@$(ECHO) CC $(notdir $@)
	$(V)$(HOST_CC) -c $(CFLAGS) -DTESTs -I$(UNITY_DIR)/src -I$(CMOCK_DIR)/src $< -o $@

########################################################
# Rules dedicated to build unitary test (ut_<module_name>*.c)
########################################################
define UNIT_TEST_generate =
$(TEST_BIN_DIR)/ut_$(1)%:$(TEST_RUNNER_DIR)/ut_$(1)%_Runner.o \
						 $(TEST_OBJ_DIR)/ut_$(1)%.o \
						 $(TESTS_ASSET_OBJS) \
						 $(filter %$(1).o,$(TESTED_OBJS)) \
						 $(TESTS_MOCKS_OBJS) \
						 $(UNITY_DIR)/src/unity.o \
						 $(CMOCK_DIR)/src/cmock.o
	@$(MKDIR) $$(dir $$@)
	@$(ECHO) LD $$(notdir $$@)
	$(V)$(TARGET_CC) $(COVERAGE_LDFLAGS) $$^ -o $$@
endef
MODULE_TO_TEST=$(basename $(notdir $(TESTED_OBJS)))
$(foreach module,$(MODULE_TO_TEST),$(eval $(call UNIT_TEST_generate,$(module))))

$(TEST_MOCK_DIR)/Mock%.o: $(TEST_MOCK_DIR)/Mock%.c $(TEST_MOCK_DIR)/Mock%.h
	@$(MKDIR) $(dir $@)
	@$(ECHO) CC $(notdir $@)
	$(V)$(HOST_CC) -c $(CFLAGS) -DTEST -I$(UNITY_DIR)/src -I$(CMOCK_DIR)/src $< -o $@

$(TESTS_MOCKS_C) $(TESTS_MOCKS_H): $(HDRS)
	@ruby $(CMOCK_DIR)/lib/cmock.rb $^ -o$(SOURCE_DIR)/test.yml
	@$(CP) -rf -T mocks $(TEST_MOCK_DIR)
	@$(RM) -rf --preserve-root mocks

########################################################
# PHONY clean rules
########################################################
.PRECIOUS: $(PRES) $(OBJS) $(DEPS) $(TESTS_BIN) $(TESTS_RUNNER) $(TESTS_RUNNER_OBJS) $(TESTS_ASSET_OBJS) $(TESTS_SCENAR_OBJS) $(TESTS_MOCKS_C) $(TESTS_MOCKS_H) $(TESTS_MOCKS_OBJS)
.PHONY: clean
clean:
	-$(V)$(RM) --preserve-root -rf $(BIN_DIR)/* \
			   $(OBJ_DIR)/* $(PRE_DIR)/* $(DEP_DIR)/* $(DOC_DIR)/* \
			   $(TEST_BIN_DIR)/* $(TEST_OBJ_DIR)/* $(TEST_RUNNER_DIR)/* $(TEST_MOCK_DIR)/* $(TEST_RES_DIR)/* $(TEST_COV_DIR)/*

.PHONY: distclean
distclean: clean
	-$(V)$(RM) --preserve-root -rf $(ROOTDIR)/conanbuildinfo.mak

########################################################
# PHONY help rules
########################################################
.PHONY: help
help:
	$(V)$(ECHO) Help for this repository
	$(V)$(ECHO)
	$(V)$(ECHO) "=== Available rules ============================================================"
	$(V)$(ECHO) "        all       : Build the entire package"
	$(V)$(ECHO) "        bin       : Build only the binary artifact $(TARGETNAME)"
	$(V)$(ECHO) "        test      : Pass the entire test campaign"
	$(V)$(ECHO) "        clean     : Remove all make generated artifact"
	$(V)$(ECHO) "        distclean : Remove all generated files (e.g. pre-make files)"
	$(V)$(ECHO) "        help      : Display this message"
	$(V)$(ECHO) "        tools_ver : Display tool version"
	$(V)$(ECHO)
	$(V)$(ECHO) "=== Available options =========================================================="
	$(V)$(ECHO) "        ROOTDIR   : Path to this makefile"
	$(V)$(ECHO) "        BUILDDIR  : Path to the repository where to build this package"
	$(V)$(ECHO) "        VERBOSE   : Set to 1 to obatin verbose output"
	$(V)$(ECHO)
	$(V)$(ECHO) "Note:  All provided path must be either absolute or pwd relative ($(shell $(PWD)))"
	$(V)$(ECHO) "Note2: If ROOTDIR not provided, and pwd in a git repository then considers repository root"
	$(V)$(ECHO) "Note3: If ROOTDIR not provided, and pwd not a repostiroy then consider pwd"
	$(V)$(ECHO)

.PHONY: tools_ver
tools_ver:
	$(V)$(ECHO) "=== Tools version =============================================================="
	$(V)$(ECHO) "Make version"
	$(V)$(MAKE) --version
	$(V)$(ECHO)
	$(V)$(ECHO) "Python version"
	$(V)python --version
	$(V)$(ECHO)
	$(V)$(ECHO) "Compiler version"
	$(V)$(CC) --version
	$(V)$(ECHO) "Binutils version"
	$(V)$(LD) --version

-include $(DEPS)