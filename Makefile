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

# Test generation folder
TEST_OBJ_DIR      = $(TEST_BUILD_DIR)/obj
TEST_COV_DIR      = $(TEST_BUILD_DIR)/cov
TEST_MOCK_DIR     = $(TEST_BUILD_DIR)/mocks

# Unit test generation folder
UNIT_TEST_BUILD_DIR    = $(TEST_BUILD_DIR)/unit
UNIT_TEST_BIN_DIR      = $(UNIT_TEST_BUILD_DIR)/bin
UNIT_TEST_RUNNER_DIR   = $(UNIT_TEST_BUILD_DIR)/runner
UNIT_TEST_RES_DIR      = $(UNIT_TEST_BUILD_DIR)/results

# Integration test generation folder
INTEGRATION_TEST_BUILD_DIR    = $(TEST_BUILD_DIR)/integration
INTEGRATION_TEST_BIN_DIR      = $(INTEGRATION_TEST_BUILD_DIR)/bin
INTEGRATION_TEST_RUNNER_DIR   = $(INTEGRATION_TEST_BUILD_DIR)/runner
INTEGRATION_TEST_RES_DIR      = $(INTEGRATION_TEST_BUILD_DIR)/results

# Source Dir
SRC_DIR           = $(SOURCE_DIR)/src
TEST_SRC_DIR      = $(SOURCE_DIR)/tests
UNIT_TEST_SRC_DIR = $(TEST_SRC_DIR)/unit
INTEGRATION_TEST_SRC_DIR = $(TEST_SRC_DIR)/integration
TOOLS_DIR         = $(SOURCE_DIR)/tools

# Sources files
SRCS        = $(shell $(FIND) $(SRC_DIR) -name "*.c" -o -name "*.s" -o -name "*.S")
HDRS        = $(shell $(FIND) $(SRC_DIR) $(CONAN_INCLUDE_DIRS) -name "*.h")

# Temporary build files
PRES        = $(patsubst $(SRC_DIR)/%.c,$(PRE_DIR)/%.i,$(SRCS))
DEPS        = $(patsubst $(SRC_DIR)/%.c,$(DEP_DIR)/%.d,$(SRCS))
OBJS        = $(patsubst $(SRC_DIR)/%.c,$(OBJ_DIR)/%.o,$(SRCS))

# Overal tests files
TESTED_OBJS       = $(patsubst $(SRC_DIR)/%.c,$(TEST_OBJ_DIR)/%.o,$(SRCS))
TESTS_GCNO        = $(if $(filter 1,$(COVERAGE)),$(patsubst $(TEST_OBJ_DIR)/%.o,$(TEST_COV_DIR)/%.gcno,$(TESTED_OBJS)))
TESTS_GCDA        = $(if $(filter 1,$(COVERAGE)),$(patsubst $(TEST_OBJ_DIR)/%.o,$(TEST_COV_DIR)/%.gcda,$(TESTED_OBJS)))
TESTS_MOCKS_H     = $(patsubst %.h,$(TEST_MOCK_DIR)/Mock%.h,$(notdir $(HDRS)))
TESTS_MOCKS_C     = $(patsubst %.h,$(TEST_MOCK_DIR)/Mock%.c,$(notdir $(HDRS)))
TESTS_MOCKS_OBJS  = $(patsubst %.h,$(TEST_MOCK_DIR)/Mock%.o,$(notdir $(HDRS)))

# Unit tests files
UNIT_TESTS_SCENAR      = $(shell $(FIND) $(UNIT_TEST_SRC_DIR) -name "ut_*.c")
UNIT_TESTS_SCENAR_OBJS = $(patsubst $(UNIT_TEST_SRC_DIR)/%.c,$(TEST_OBJ_DIR)/%.o,$(UNIT_TESTS_SCENAR))
UNIT_TESTS_ASSET       = $(filter-out $(UNIT_TESTS_SCENAR),$(shell $(FIND) $(UNIT_TEST_SRC_DIR) -name "*.c"))
UNIT_TESTS_ASSET_OBJS  = $(patsubst $(UNIT_TEST_SRC_DIR)/%.c,$(TEST_OBJ_DIR)/%.o,$(UNIT_TESTS_ASSET))
UNIT_TESTS_RUNNER      = $(patsubst $(UNIT_TEST_SRC_DIR)/%.c,$(UNIT_TEST_RUNNER_DIR)/%_Runner.c,$(UNIT_TESTS_SCENAR))
UNIT_TESTS_RUNNER_OBJS = $(patsubst $(UNIT_TEST_SRC_DIR)/%.c,$(UNIT_TEST_RUNNER_DIR)/%_Runner.o,$(UNIT_TESTS_SCENAR))
UNIT_TESTS_BIN         = $(patsubst $(UNIT_TEST_SRC_DIR)/%.c,$(UNIT_TEST_BIN_DIR)/%,$(UNIT_TESTS_SCENAR))
UNIT_TESTS_RESULTS     = $(patsubst $(UNIT_TEST_SRC_DIR)/%.c,$(UNIT_TEST_RES_DIR)/%.testresults,$(UNIT_TESTS_SCENAR))

# Integration tests files
INTEGRATION_TESTS_SCENAR      = $(shell $(FIND) $(INTEGRATION_TEST_SRC_DIR) -name "it_*.c")
INTEGRATION_TESTS_SCENAR_OBJS = $(patsubst $(INTEGRATION_TEST_SRC_DIR)/%.c,$(TEST_OBJ_DIR)/%.o,$(INTEGRATION_TESTS_SCENAR))
INTEGRATION_TESTS_ASSET       = $(filter-out $(INTEGRATION_TESTS_SCENAR),$(shell $(FIND) $(INTEGRATION_TEST_SRC_DIR) -name "*.c"))
INTEGRATION_TESTS_ASSET_OBJS  = $(patsubst $(INTEGRATION_TEST_SRC_DIR)/%.c,$(TEST_OBJ_DIR)/%.o,$(INTEGRATION_TESTS_ASSET))
INTEGRATION_TESTS_RUNNER      = $(patsubst $(INTEGRATION_TEST_SRC_DIR)/%.c,$(INTEGRATION_TEST_RUNNER_DIR)/%_Runner.c,$(INTEGRATION_TESTS_SCENAR))
INTEGRATION_TESTS_RUNNER_OBJS = $(patsubst $(INTEGRATION_TEST_SRC_DIR)/%.c,$(INTEGRATION_TEST_RUNNER_DIR)/%_Runner.o,$(INTEGRATION_TESTS_SCENAR))
INTEGRATION_TESTS_BIN         = $(patsubst $(INTEGRATION_TEST_SRC_DIR)/%.c,$(INTEGRATION_TEST_BIN_DIR)/%,$(INTEGRATION_TESTS_SCENAR))
INTEGRATION_TESTS_RESULTS     = $(patsubst $(INTEGRATION_TEST_SRC_DIR)/%.c,$(INTEGRATION_TEST_RES_DIR)/%.testresults,$(INTEGRATION_TESTS_SCENAR))

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

# Overall test compiler flag
TEST_CFLAGS  = $(CFLAGS)
TEST_CFLAGS += -DTEST -I$(UNITY_DIR)/src -I$(CMOCK_DIR)/src
OBJ_CFLAGS   = $(CFLAGS)
OBJ_CFLAGS  += -DTEST $(COVERAGE_CFLAGS)

# Overall test linker flag
TEST_LDFLAGS = $(COVERAGE_LDFLAGS)

# Unit test compiler flags
UNIT_TEST_CFLAGS  = $(TEST_CFLAGS)

# Unit test linker flags
UNIT_TEST_LDFLAGS = $(TEST_LDFLAGS)

# Integration test compiler flags
INTEGRATION_TEST_CFLAGS  = $(TEST_CFLAGS)

# Unit test linker flags
INTEGRATION_TEST_LDFLAGS  = $(TEST_LDFLAGS)
INTEGRATION_TEST_LDFLAGS += $(LDFLAGS)

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
test: $(UNIT_TESTS_RESULTS) $(INTEGRATION_TESTS_RESULTS) $(TESTS_GCNO) $(TESTS_GCDA)
	$(V)$(RUBY) $(UNITY_DIR)/auto/unity_test_summary.rb $(TEST_BUILD_DIR)/
	@$(if $(filter 1,$(COVERAGE)),$(TARGET_GCOV) -n $(TESTS_GCNO) $(TESTS_GCDA) 2> /dev/null)

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
# Rules to build all tests
########################################################
$(TEST_OBJ_DIR)/%.o: $(SRC_DIR)/%.c
	@$(MKDIR) $(dir $@)
	$(V)$(HOST_CC) -c $(OBJ_CFLAGS) $< -o $@

$(TEST_OBJ_DIR)/unity.o: $(UNITY_DIR)/src/unity.c
	@$(MKDIR) $(dir $@)
	$(V)$(HOST_CC) -c $(TEST_CFLAGS) $< -o $@

$(TEST_OBJ_DIR)/cmock.o: $(CMOCK_DIR)/src/cmock.c
	@$(MKDIR) $(dir $@)
	$(V)$(HOST_CC) -c $(TEST_CFLAGS) $< -o $@

$(TESTS_GCNO) $(TESTS_GCDA): $(TESTED_OBJS) $(UNIT_TESTS_RESULTS) $(INTEGRATION_TESTS_RESULTS)
	@$(MKDIR) $(dir $@)
	@$(MV) -f $(patsubst $(TEST_COV_DIR)/%,$(TEST_OBJ_DIR)/%,$@) $@ 2> /dev/null || true

$(TEST_MOCK_DIR)/%.o: $(TEST_MOCK_DIR)/%.c $(TEST_MOCK_DIR)/%.h
	@$(MKDIR) $(dir $@)
	$(V)$(HOST_CC) -c $(TEST_CFLAGS) $< -o $@

$(TESTS_MOCKS_C) $(TESTS_MOCKS_H): $(HDRS)
	@$(MKDIR) $(dir $@)
	$(V)$(RUBY) $(CMOCK_DIR)/lib/cmock.rb $^ -o$(SOURCE_DIR)/test.yml
	@$(CP) -rf -T mocks $(TEST_MOCK_DIR)
	@$(RM) -rf --preserve-root mocks

########################################################
# Rules to build unit tests (ut_<module_name><test id>.c)
########################################################
$(subst $(UNIT_TEST_BIN_DIR)/,,$(UNIT_TESTS_BIN)):
	@$(MAKE) $(filter %$@.testresults, $(UNIT_TESTS_RESULTS))
	@cat $(filter %$@.testresults, $(UNIT_TESTS_RESULTS))

$(UNIT_TEST_RES_DIR)/%.testresults: $(UNIT_TEST_BIN_DIR)/%
	@$(MKDIR) $(dir $@)
	-@if test -e $<; then \
	$< > $@; \
	else \
	$(ECHO) $(patsubst $(UNIT_TEST_RES_DIR)/%.testresults,$(UNIT_TEST_SRC_DIR)/%.c,$@):1:test_compilation:INFO: Error at compile time > $@; \
	$(ECHO) $(patsubst $(UNIT_TEST_RES_DIR)/%.testresults,$(UNIT_TEST_SRC_DIR)/%.c,$@):1:test_compilation:FAIL >> $@; \
	$(ECHO) -n >> $@; \
	$(ECHO) ----------------------- >> $@; \
	$(ECHO) 1 Tests 1 Failures 0 Ignored >> $@; \
	fi

$(UNIT_TEST_RUNNER_DIR)/%_Runner.o: $(UNIT_TEST_RUNNER_DIR)/%_Runner.c
	@$(MKDIR) $(dir $@)
	-$(V)$(HOST_CC) -c $(UNIT_TEST_CFLAGS) $< -o $@

$(UNIT_TEST_RUNNER_DIR)/%_Runner.c: $(UNIT_TEST_SRC_DIR)/%.c
	@$(MKDIR) $(dir $@)
	-$(V)$(RUBY) $(UNITY_DIR)/auto/generate_test_runner.rb $(SOURCE_DIR)/test.yml $< $@

$(TEST_OBJ_DIR)/%.o: $(UNIT_TEST_SRC_DIR)/%.c
	@$(MKDIR) $(dir $@)
	-$(V)$(HOST_CC) -c $(UNIT_TEST_CFLAGS) $< -o $@

define UNIT_TEST_generate =
$(UNIT_TEST_BIN_DIR)$(1)ut_$(2)%:$(UNIT_TEST_RUNNER_DIR)$(1)ut_$(2)%_Runner.o \
						 $(TEST_OBJ_DIR)$(1)ut_$(2)%.o \
						 $(UNIT_TESTS_ASSET_OBJS) \
						 $(filter %$(2).o,$(TESTED_OBJS)) \
						 $(TESTS_MOCKS_OBJS) \
						 $(TEST_OBJ_DIR)/unity.o \
						 $(TEST_OBJ_DIR)/cmock.o
	@$(MKDIR) $$(dir $$@)
	-$(V)$(HOST_CC) $(UNIT_TEST_LDFLAGS) $$^ -o $$@
endef
UNIT_MODULE_TO_TEST:=$(basename $(notdir $(TESTED_OBJS)))
UNIT_REL_PATH_TO_MODULE:=$(subst $(UNIT_TEST_BIN_DIR),,$(dir $(UNIT_TESTS_BIN)))
$(foreach rel_path,$(UNIT_REL_PATH_TO_MODULE),\
	$(foreach module,$(UNIT_MODULE_TO_TEST),\
		$(eval $(call UNIT_TEST_generate,$(rel_path),$(module)))\
	)\
)

########################################################
# Rules to build integration tests (it_<test id>.c)
########################################################
$(subst $(INTEGRATION_TEST_BIN_DIR)/,,$(INTEGRATION_TESTS_BIN)):
	@$(MAKE) $(filter %$@.testresults, $(INTEGRATION_TESTS_RESULTS))
	@cat $(filter %$@.testresults, $(INTEGRATION_TESTS_RESULTS))

$(INTEGRATION_TEST_RES_DIR)/%.testresults: $(INTEGRATION_TEST_BIN_DIR)/%
	@$(MKDIR) $(dir $@)
	-@if test -e $<; then \
	$< > $@; \
	else \
	$(ECHO) $(patsubst $(INTEGRATION_TEST_RES_DIR)/%.testresults,$(INTEGRATION_TEST_SRC_DIR)/%.c,$@):1:test_compilation:INFO: Error at compile time > $@; \
	$(ECHO) $(patsubst $(INTEGRATION_TEST_RES_DIR)/%.testresults,$(INTEGRATION_TEST_SRC_DIR)/%.c,$@):1:test_compilation:FAIL >> $@; \
	$(ECHO) -n >> $@; \
	$(ECHO) ----------------------- >> $@; \
	$(ECHO) 1 Tests 1 Failures 0 Ignored >> $@; \
	fi

$(INTEGRATION_TEST_RUNNER_DIR)/%_Runner.o: $(INTEGRATION_TEST_RUNNER_DIR)/%_Runner.c
	@$(MKDIR) $(dir $@)
	-$(V)$(HOST_CC) -c $(INTEGRATION_TEST_CFLAGS) $< -o $@

$(INTEGRATION_TEST_RUNNER_DIR)/%_Runner.c: $(INTEGRATION_TEST_SRC_DIR)/%.c
	@$(MKDIR) $(dir $@)
	-$(V)$(RUBY) $(UNITY_DIR)/auto/generate_test_runner.rb $(SOURCE_DIR)/test.yml $< $@

$(TEST_OBJ_DIR)/%.o: $(INTEGRATION_TEST_SRC_DIR)/%.c
	@$(MKDIR) $(dir $@)
	-$(V)$(HOST_CC) -c $(INTEGRATION_TEST_CFLAGS) $< -o $@

define INTEGRATION_TEST_generate =
$(INTEGRATION_TEST_BIN_DIR)$(1)it_%:$(INTEGRATION_TEST_RUNNER_DIR)$(1)it_%_Runner.o \
						 $(TEST_OBJ_DIR)$(1)it_%.o \
						 $(INTEGRATION_TESTS_ASSET_OBJS) \
						 $(TESTED_OBJS) \
						 $(TESTS_MOCKS_OBJS) \
						 $(TEST_OBJ_DIR)/unity.o \
						 $(TEST_OBJ_DIR)/cmock.o
	@$(MKDIR) $$(dir $$@)
	-$(V)$(HOST_CC) $(INTEGRATION_TEST_LDFLAGS) $$^ -o $$@
endef
INTEGRATION_REL_PATH_TO_MODULE:=$(subst $(INTEGRATION_TEST_BIN_DIR),,$(dir $(INTEGRATION_TESTS_BIN)))
$(foreach rel_path,$(INTEGRATION_REL_PATH_TO_MODULE),\
	$(eval $(call INTEGRATION_TEST_generate,$(rel_path)))\
)

########################################################
# PHONY clean rules
########################################################
.PRECIOUS:  $(PRES) $(OBJS) $(DEPS) \
			$(UNIT_TESTS_BIN) $(UNIT_TESTS_RUNNER) $(UNIT_TESTS_RUNNER_OBJS) \
			$(UNIT_TESTS_ASSET_OBJS) $(UNIT_TESTS_SCENAR_OBJS) \
			$(INTEGRATION_TESTS_BIN) $(INTEGRATION_TESTS_RUNNER) $(INTEGRATION_TESTS_RUNNER_OBJS) \
			$(INTEGRATION_TESTS_ASSET_OBJS) $(INTEGRATION_TESTS_SCENAR_OBJS)  \
			$(TESTED_OBJS) $(TESTS_MOCKS_C) $(TESTS_MOCKS_H) $(TESTS_MOCKS_OBJS)
.PHONY: clean
clean:
	-$(V)$(RM) --preserve-root -rf $(BIN_DIR)/* \
			   $(OBJ_DIR)/* $(PRE_DIR)/* $(DEP_DIR)/* $(DOC_DIR)/* \
			   $(UNIT_TEST_BIN_DIR)/* $(TEST_OBJ_DIR)/* $(UNIT_TEST_RUNNER_DIR)/* $(TEST_MOCK_DIR)/* \
			   $(UNIT_TEST_RES_DIR)/* $(TEST_COV_DIR)/* $(INTEGRATION_TEST_BUILD_DIR)/* $(INTEGRATION_TEST_BIN_DIR)/* \
			   $(INTEGRATION_TEST_RUNNER_DIR)/* $(INTEGRATION_TEST_RES_DIR)/*

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