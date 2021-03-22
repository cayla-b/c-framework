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

# Unit test generation folder
UNIT_TEST_BUILD_DIR    = $(TEST_BUILD_DIR)/unit
UNIT_TEST_BIN_DIR      = $(UNIT_TEST_BUILD_DIR)/bin
UNIT_TEST_OBJ_DIR      = $(UNIT_TEST_BUILD_DIR)/obj
UNIT_TEST_RUNNER_DIR   = $(UNIT_TEST_BUILD_DIR)/runner
UNIT_TEST_MOCK_DIR     = $(UNIT_TEST_BUILD_DIR)/mocks
UNIT_TEST_RES_DIR      = $(UNIT_TEST_BUILD_DIR)/results
UNIT_TEST_COV_DIR      = $(UNIT_TEST_BUILD_DIR)/cov

# Source Dir
SRC_DIR           = $(SOURCE_DIR)/src
TEST_SRC_DIR      = $(SOURCE_DIR)/tests
UNIT_TEST_SRC_DIR = $(TEST_SRC_DIR)/unit
TOOLS_DIR         = $(SOURCE_DIR)/tools

# Sources files
SRCS        = $(shell $(FIND) $(SRC_DIR) -name "*.c" -o -name "*.s" -o -name "*.S")
HDRS        = $(shell $(FIND) $(SRC_DIR) $(CONAN_INCLUDE_DIRS) -name "*.h")

# Temporary build files
PRES        = $(patsubst $(SRC_DIR)/%.c,$(PRE_DIR)/%.i,$(SRCS))
DEPS        = $(patsubst $(SRC_DIR)/%.c,$(DEP_DIR)/%.d,$(SRCS))
OBJS        = $(patsubst $(SRC_DIR)/%.c,$(OBJ_DIR)/%.o,$(SRCS))

# Unit tests files
UNIT_TESTED_OBJS       = $(patsubst $(SRC_DIR)/%.c,$(UNIT_TEST_OBJ_DIR)/%.o,$(SRCS))
UNIT_TESTS_SCENAR      = $(shell $(FIND) $(UNIT_TEST_SRC_DIR) -name "ut_*.c")
UNIT_TESTS_SCENAR_OBJS = $(patsubst $(UNIT_TEST_SRC_DIR)/%.c,$(UNIT_TEST_OBJ_DIR)/%.o,$(UNIT_TESTS_SCENAR))
UNIT_TESTS_ASSET       = $(filter-out $(UNIT_TESTS_SCENAR),$(shell $(FIND) $(UNIT_TEST_SRC_DIR) -name "*.c"))
UNIT_TESTS_ASSET_OBJS  = $(patsubst $(UNIT_TEST_SRC_DIR)/%.c,$(UNIT_TEST_OBJ_DIR)/%.o,$(UNIT_TESTS_ASSET))
UNIT_TESTS_RUNNER      = $(patsubst $(UNIT_TEST_SRC_DIR)/%.c,$(UNIT_TEST_RUNNER_DIR)/%_Runner.c,$(UNIT_TESTS_SCENAR))
UNIT_TESTS_RUNNER_OBJS = $(patsubst $(UNIT_TEST_SRC_DIR)/%.c,$(UNIT_TEST_RUNNER_DIR)/%_Runner.o,$(UNIT_TESTS_SCENAR))
UNIT_TESTS_MOCKS_C     = $(foreach dirs,$(patsubst %/,%,$(sort $(dir $(HDRS)))),$(patsubst $(dirs)/%.h,$(UNIT_TEST_MOCK_DIR)/Mock%.c,$(HDRS)))
UNIT_TESTS_MOCKS_H     = $(patsubst %.c,%.h,$(UNIT_TESTS_MOCKS_C))
UNIT_TESTS_MOCKS_OBJS  = $(patsubst %.c,%.o,$(UNIT_TESTS_MOCKS_C))
UNIT_TESTS_BIN         = $(patsubst $(UNIT_TEST_SRC_DIR)/%.c,$(UNIT_TEST_BIN_DIR)/%,$(UNIT_TESTS_SCENAR))
UNIT_TESTS_RESULTS     = $(patsubst $(UNIT_TEST_SRC_DIR)/%.c,$(UNIT_TEST_RES_DIR)/%.testresults,$(UNIT_TESTS_SCENAR))

# Build compiler flags
CFLAGS  = $(CONAN_CFLAGS)
CFLAGS += $(addprefix -I,$(patsubst %/,%,$(sort $(dir $(HDRS)))))
CFLAGS += $(addprefix -D,$(CONAN_DEFINES))
CFLAGS += -Wall

# Build linker flags
LDFLAGS  = $(addprefix -L,$(patsubst %/,%,$(CONAN_LIB_DIRS)))
LDFLAGS += -Wl,-\( $(addprefix -l,$(CONAN_LIBS)) -Wl,-\)

# resolving external environment - COVERAGE
COVERAGE ?= 0
ifeq ($(COVERAGE), 1)
COVERAGE_CFLAGS=-fprofile-arcs -ftest-coverage -fprofile-generate
COVERAGE_LDFLAGS=-fprofile-arcs -lgcov
else
COVERAGE_CFLAGS=
COVERAGE_LDFLAGS=
endif

# Unit test compiler flags
UNIT_TEST_CFLAGS  = $(CFLAGS)
UNIT_TEST_CFLAGS += -DTEST -I$(UNITY_DIR)/src -I$(CMOCK_DIR)/src
UNIT_OBJ_CFLAGS   = $(UNIT_TEST_CFLAGS)
UNIT_OBJ_CFLAGS  += $(COVERAGE_CFLAGS)

# Unit test linker flags
UNIT_TEST_LDFLAGS = $(COVERAGE_LDFLAGS)

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
test: $(UNIT_TESTS_RESULTS)
	@ruby $(UNITY_DIR)/auto/unity_test_summary.rb $(UNIT_TEST_RES_DIR) $(SOURCE_DIR)

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
# Rules to build unit test tests
########################################################
$(UNIT_TEST_RES_DIR)/%.testresults: $(UNIT_TEST_BIN_DIR)/%
	@$(MKDIR) $(dir $@)
	@$< > $@

$(UNIT_TEST_RUNNER_DIR)/%_Runner.o: $(UNIT_TEST_RUNNER_DIR)/%_Runner.c
	@$(MKDIR) $(dir $@)
	@$(ECHO) CC $(notdir $@)
	$(V)$(HOST_CC) -c $(UNIT_TEST_CFLAGS) $< -o $@

$(UNIT_TEST_RUNNER_DIR)/%_Runner.c: $(UNIT_TEST_SRC_DIR)/%.c
	@$(MKDIR) $(dir $@)
	@ruby $(UNITY_DIR)/auto/generate_test_runner.rb $< $@

$(UNIT_TEST_OBJ_DIR)/%.o: $(UNIT_TEST_SRC_DIR)/%.c
	@$(MKDIR) $(dir $@)
	@$(ECHO) CC $(notdir $@)
	$(V)$(HOST_CC) -c $(UNIT_TEST_CFLAGS) $< -o $@

$(UNIT_TEST_OBJ_DIR)/%.o: $(SRC_DIR)/%.c
	@$(MKDIR) $(dir $@)
	@$(MKDIR) $(UNIT_TEST_COV_DIR)
	@$(ECHO) CC $(notdir $@)
	$(V)$(HOST_CC) -c $(UNIT_OBJ_CFLAGS) $< -o $@

$(UNITY_DIR)/src/unity.o: $(UNITY_DIR)/src/unity.c
	@$(ECHO) CC $(notdir $@)
	$(V)$(HOST_CC) -c $(UNIT_TEST_CFLAGS) $< -o $@

$(CMOCK_DIR)/src/cmock.o: $(CMOCK_DIR)/src/cmock.c
	@$(ECHO) CC $(notdir $@)
	$(V)$(HOST_CC) -c $(UNIT_TEST_CFLAGS) $< -o $@

########################################################
# Rules dedicated to build unitary test (ut_<module_name>*.c)
########################################################
define UNIT_TEST_generate =
$(UNIT_TEST_BIN_DIR)/ut_$(1)%:$(UNIT_TEST_RUNNER_DIR)/ut_$(1)%_Runner.o \
						 $(UNIT_TEST_OBJ_DIR)/ut_$(1)%.o \
						 $(UNIT_TESTS_ASSET_OBJS) \
						 $(filter %$(1).o,$(UNIT_TESTED_OBJS)) \
						 $(UNIT_TESTS_MOCKS_OBJS) \
						 $(UNITY_DIR)/src/unity.o \
						 $(CMOCK_DIR)/src/cmock.o
	@$(MKDIR) $$(dir $$@)
	@$(ECHO) LD $$(notdir $$@)
	$(V)$(HOST_CC) $(UNIT_TEST_LDFLAGS) $$^ -o $$@
endef
MODULE_TO_TEST=$(basename $(notdir $(UNIT_TESTED_OBJS)))
$(foreach module,$(MODULE_TO_TEST),$(eval $(call UNIT_TEST_generate,$(module))))

$(UNIT_TEST_MOCK_DIR)/Mock%.o: $(UNIT_TEST_MOCK_DIR)/Mock%.c $(UNIT_TEST_MOCK_DIR)/Mock%.h
	@$(MKDIR) $(dir $@)
	@$(ECHO) CC $(notdir $@)
	$(V)$(HOST_CC) -c $(UNIT_TEST_CFLAGS) $< -o $@

$(UNIT_TESTS_MOCKS_C) $(UNIT_TESTS_MOCKS_H): $(HDRS)
	@ruby $(CMOCK_DIR)/lib/cmock.rb $^ -o$(SOURCE_DIR)/test.yml
	@$(CP) -rf -T mocks $(UNIT_TEST_MOCK_DIR)
	@$(RM) -rf --preserve-root mocks

########################################################
# PHONY clean rules
########################################################
.PRECIOUS: $(PRES) $(OBJS) $(DEPS) $(UNIT_TESTS_BIN) $(UNIT_TESTS_RUNNER) $(UNIT_TESTS_RUNNER_OBJS) $(UNIT_TESTS_ASSET_OBJS) $(UNIT_TESTS_SCENAR_OBJS) $(UNIT_TESTS_MOCKS_C) $(UNIT_TESTS_MOCKS_H) $(UNIT_TESTS_MOCKS_OBJS) $(UNIT_TESTED_OBJS)
.PHONY: clean
clean:
	-$(V)$(RM) --preserve-root -rf $(BIN_DIR)/* \
			   $(OBJ_DIR)/* $(PRE_DIR)/* $(DEP_DIR)/* $(DOC_DIR)/* \
			   $(UNIT_TEST_BIN_DIR)/* $(UNIT_TEST_OBJ_DIR)/* $(UNIT_TEST_RUNNER_DIR)/* $(UNIT_TEST_MOCK_DIR)/* $(UNIT_TEST_RES_DIR)/* $(UNIT_TEST_COV_DIR)/*

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
	$(V)$(ECHO) "        COVERAGE  : Set to 1 to obtain test coverage"
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