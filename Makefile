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
RUBY           ?= ruby
PYTHON         ?= python
MKDIR          ?= mkdir -p
ECHO           ?= echo
HOST_LD        ?= ld
HOST_AR        ?= ar
HOST_CC        ?= gcc
HOST_GCOV      ?= gcov
TARGET_LD      ?= ld
TARGET_AR      ?= ar
TARGET_CC      ?= gcc
TARGET_GCOV    ?= gcov
RM             ?= rm --preserve-root -rf
CP             ?= cp
MV             ?= mv
$(shell $(FIND) --version > /dev/null)
$(shell $(DOXYGEN) --version > /dev/null)
$(shell $(RUBY) --version > /dev/null)
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
UNIT_TESTS_MOCKS_H     = $(patsubst %.h,$(UNIT_TEST_MOCK_DIR)/Mock%.h,$(notdir $(HDRS)))
UNIT_TESTS_MOCKS_C     = $(patsubst %.h,$(UNIT_TEST_MOCK_DIR)/Mock%.c,$(notdir $(HDRS)))
UNIT_TESTS_MOCKS_OBJS  = $(patsubst %.h,$(UNIT_TEST_MOCK_DIR)/Mock%.o,$(notdir $(HDRS)))
UNIT_TESTS_BIN         = $(patsubst $(UNIT_TEST_SRC_DIR)/%.c,$(UNIT_TEST_BIN_DIR)/%,$(UNIT_TESTS_SCENAR))
UNIT_TESTS_RESULTS     = $(patsubst $(UNIT_TEST_SRC_DIR)/%.c,$(UNIT_TEST_RES_DIR)/%.testresults,$(UNIT_TESTS_SCENAR))
UNIT_TESTS_GCNO        = $(if $(filter 1,$(COVERAGE)),$(patsubst $(UNIT_TEST_OBJ_DIR)/%.o,$(UNIT_TEST_COV_DIR)/%.gcno,$(UNIT_TESTED_OBJS)))
UNIT_TESTS_GCDA        = $(if $(filter 1,$(COVERAGE)),$(patsubst $(UNIT_TEST_OBJ_DIR)/%.o,$(UNIT_TEST_COV_DIR)/%.gcda,$(UNIT_TESTED_OBJS)))

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
test: $(UNIT_TESTS_RESULTS) $(UNIT_TESTS_GCNO) $(UNIT_TESTS_GCDA)
	$(V)$(RUBY) $(UNITY_DIR)/auto/unity_test_summary.rb $(UNIT_TEST_RES_DIR)/
	@$(if $(filter 1,$(COVERAGE)),$(TARGET_GCOV) -n $(UNIT_TESTS_GCNO) $(UNIT_TESTS_GCDA) 2> /dev/null)

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
	-@$< > $@

$(UNIT_TEST_RUNNER_DIR)/%_Runner.o: $(UNIT_TEST_RUNNER_DIR)/%_Runner.c
	@$(MKDIR) $(dir $@)
	$(V)$(HOST_CC) -c $(UNIT_TEST_CFLAGS) $< -o $@

$(UNIT_TEST_RUNNER_DIR)/%_Runner.c: $(UNIT_TEST_SRC_DIR)/%.c
	@$(MKDIR) $(dir $@)
	$(V)$(RUBY) $(UNITY_DIR)/auto/generate_test_runner.rb $(SOURCE_DIR)/test.yml $< $@

$(UNIT_TEST_OBJ_DIR)/%.o: $(UNIT_TEST_SRC_DIR)/%.c
	@$(MKDIR) $(dir $@)
	$(V)$(HOST_CC) -c $(UNIT_TEST_CFLAGS) $< -o $@

$(UNIT_TEST_OBJ_DIR)/%.o: $(SRC_DIR)/%.c
	@$(MKDIR) $(dir $@)
	$(V)$(HOST_CC) -c $(UNIT_OBJ_CFLAGS) $< -o $@

$(UNIT_TEST_OBJ_DIR)/unity.o: $(UNITY_DIR)/src/unity.c
	@$(MKDIR) $(dir $@)
	$(V)$(HOST_CC) -c $(UNIT_TEST_CFLAGS) $< -o $@

$(UNIT_TEST_OBJ_DIR)/cmock.o: $(CMOCK_DIR)/src/cmock.c
	@$(MKDIR) $(dir $@)
	$(V)$(HOST_CC) -c $(UNIT_TEST_CFLAGS) $< -o $@

$(UNIT_TESTS_GCNO) $(UNIT_TESTS_GCDA): $(UNIT_TESTED_OBJS) $(UNIT_TESTS_RESULTS)
	@$(MKDIR) $(dir $@)
	-@$(MV) -f $(patsubst $(UNIT_TEST_COV_DIR)/%,$(UNIT_TEST_OBJ_DIR)/%,$@) $@ 2> /dev/null | true

########################################################
# Rules dedicated to build unitary test (ut_<module_name>*.c)
########################################################
define UNIT_TEST_generate =
$(UNIT_TEST_BIN_DIR)$(1)ut_$(2)%:$(UNIT_TEST_RUNNER_DIR)$(1)ut_$(2)%_Runner.o \
						 $(UNIT_TEST_OBJ_DIR)$(1)ut_$(2)%.o \
						 $(UNIT_TESTS_ASSET_OBJS) \
						 $(filter %$(2).o,$(UNIT_TESTED_OBJS)) \
						 $(UNIT_TESTS_MOCKS_OBJS) \
						 $(UNIT_TEST_OBJ_DIR)/unity.o \
						 $(UNIT_TEST_OBJ_DIR)/cmock.o
	@$(MKDIR) $$(dir $$@)
	$(V)$(HOST_CC) $(UNIT_TEST_LDFLAGS) $$^ -o $$@
endef
MODULE_TO_TEST:=$(basename $(notdir $(UNIT_TESTED_OBJS)))
REL_PATH_TO_MODULE:=$(subst $(UNIT_TEST_BIN_DIR),,$(dir $(UNIT_TESTS_BIN)))
$(foreach rel_path,$(REL_PATH_TO_MODULE),\
	$(foreach module,$(MODULE_TO_TEST),\
		$(eval $(call UNIT_TEST_generate,$(rel_path),$(module)))\
	)\
)

$(UNIT_TEST_MOCK_DIR)/%.o: $(UNIT_TEST_MOCK_DIR)/%.c $(UNIT_TEST_MOCK_DIR)/%.h
	@$(MKDIR) $(dir $@)
	$(V)$(HOST_CC) -c $(UNIT_TEST_CFLAGS) $< -o $@

$(UNIT_TESTS_MOCKS_C) $(UNIT_TESTS_MOCKS_H): $(HDRS)
	$(V)$(RUBY) $(CMOCK_DIR)/lib/cmock.rb $^ -o$(SOURCE_DIR)/test.yml
	@$(CP) -rf -T mocks $(UNIT_TEST_MOCK_DIR)
	@$(RM) -rf --preserve-root mocks

########################################################
# PHONY clean rules
########################################################
.PRECIOUS:  $(PRES) $(OBJS) $(DEPS) \
			$(UNIT_TESTS_BIN) $(UNIT_TESTS_RUNNER) $(UNIT_TESTS_RUNNER_OBJS) \
			$(UNIT_TESTS_ASSET_OBJS) $(UNIT_TESTS_SCENAR_OBJS) $(UNIT_TESTS_MOCKS_C) \
			$(UNIT_TESTS_MOCKS_H) $(UNIT_TESTS_MOCKS_OBJS) $(UNIT_TESTED_OBJS)
.PHONY: clean
clean:
	-$(V)$(RM) --preserve-root -rf $(BIN_DIR)/* \
			   $(OBJ_DIR)/* $(PRE_DIR)/* $(DEP_DIR)/* $(DOC_DIR)/* \
			   $(UNIT_TEST_BIN_DIR)/* $(UNIT_TEST_OBJ_DIR)/* $(UNIT_TEST_RUNNER_DIR)/* $(UNIT_TEST_MOCK_DIR)/* \
			   $(UNIT_TEST_RES_DIR)/* $(UNIT_TEST_COV_DIR)/*

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
	$(V)$(PYTHON) --version
	$(V)$(ECHO)

-include $(DEPS)