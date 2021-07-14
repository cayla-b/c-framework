#!/usr/bin/make
#########################################################
# Test directory (default makefile could be changed)    #
# ----------------------------------------------------  #
# Required variables:                                   #
#  - ROOTDIR: The directory containing this makefile    #
#  - BUILDDIR: The directory where files are generated  #
#  - VERBOSE: Equal to 1 if verbose output required     #
#  - COVERAGE: Define the expected level of coverage    #
#  - UNITY_DIR: Unity test framework directory          #
#  - CMOCK_DIR: CMock mocking framework directory       #
# Option defines tests.mak in this folder defining      #
#  - SRCS : Sources files to consider to accelerate     #
#  - HDRS : Headers files to consider to accelerate     #
#  - UNITEST_SRCS : Sources files for unit tests        #
#  - UNITEST_HDRS : Headers files for unit tests        #
#  - INTTEST_SRCS : Sources files for integration tests #
#  - INTTEST_HDRS : Headers files for integration tests #
#########################################################
# Resolving external environment - ROOTDIR - PWD by default
ifeq ($(shell uname -o), Cygwin)
ROOTDIR ?= $(shell cygpath -m $(abspath ..))
convert_func = $(shell cygpath -u $(1))
else
ROOTDIR ?= $(abspath ..)
convert_func = $(1)
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
ifeq ($(COVERAGE),None)
COVERAGE_CFLAGS=
COVERAGE_LFLAGS=
else
ifeq ($(COVERAGE),Statement)
COVERAGE_CFLAGS=-fprofile-arcs -ftest-coverage -fprofile-generate
COVERAGE_LFLAGS=-fprofile-arcs -ftest-coverage
else
ifeq ($(COVERAGE),Decisions)
COVERAGE_CFLAGS=-fprofile-arcs -ftest-coverage -fprofile-generate
COVERAGE_LFLAGS=-fprofile-arcs -ftest-coverage
else
ifeq ($(COVERAGE),MC_DC)
COVERAGE_CFLAGS=
COVERAGE_LFLAGS=
$(error $(COVERAGE) coverage not yet handled !)
else
$(error Unknown coverage $(COVERAGE) please select one of the following [None,Statement,Decisions,MC_DC] !)
endif
endif
endif
endif

TIMEOUT_IN_TIME=60s
export UNITY_DIR ?= $(TOOLS_DIR)/cmock/vendor/unity
export CMOCK_DIR ?= $(TOOLS_DIR)/cmock

# Include makefile useful to defines (directory mandatory, whilst configuration and conanbuildinfo requires conan configuration set up)
-include $(ROOTDIR)/configuration.mak
-include $(ROOTDIR)/conanbuildinfo.mak
include  $(ROOTDIR)/directory.mak
include  $(ROOTDIR)/tools.mak

# Sources files (recursive search or declarative source to fasten the process)
-include $(BUILDDIR)/tests.mak
SRCS         ?= $(shell $(FIND) $(SRC_DIR) -name "*.c" -o -name "*.s" -o -name "*.S")
HDRS         ?= $(shell $(FIND) $(SRC_DIR) $(CONAN_INCLUDE_DIRS) -name "*.h")
SCENARII_SRCS = $(shell $(FIND) $(TEST_SRC_DIR) -name "test_*.c")
SCENARII_OBJS = $(patsubst $(TEST_SRC_DIR)/%.c,$(TEST_OBJ_DIR)/%.o,$(SCENARII_SRCS))
ASSETS_SRCS   = $(filter-out $(SCENARII_SRCS),$(shell $(FIND) $(TEST_SRC_DIR) -name "*.c"))
ASSETS_OBJS   = $(patsubst $(TEST_SRC_DIR)/%.c,$(TEST_OBJ_DIR)/%.o,$(ASSETS_SRCS))
SCENARII_MKS  = $(shell $(FIND) $(TEST_SRC_DIR) -name "*.mak")

# Temporary build files
PRES          = $(patsubst $(SRC_DIR)/%.c,$(PRE_DIR)/%.i,$(filter %.c,$(SRCS)))
PRES         += $(patsubst $(SRC_DIR)/%.S,$(PRE_DIR)/%.i,$(filter %.S,$(SRCS)))
DEPS          = $(patsubst $(SRC_DIR)/%.c,$(DEP_DIR)/%.d,$(filter %.c,$(SRCS)))
DEPS         += $(patsubst $(SRC_DIR)/%.S,$(DEP_DIR)/%.d,$(filter %.S,$(SRCS)))
TESTED_OBJS   = $(patsubst $(SRC_DIR)/%.c,$(TEST_OBJSRC_DIR)/%.o,$(filter %.c,$(SRCS)))
TESTED_OBJS  += $(patsubst $(SRC_DIR)/%.s,$(TEST_OBJSRC_DIR)/%.o,$(filter %.s,$(SRCS)))
TESTED_OBJS  += $(patsubst $(SRC_DIR)/%.S,$(TEST_OBJSRC_DIR)/%.o,$(filter %.S,$(SRCS)))
MOCKED_OBJS   = $(patsubst %.h,$(TEST_MOCK_DIR)/mock_%.o,$(notdir $(HDRS)))
MOCKED_SRCS   = $(patsubst %.o,%.c,$(MOCKED_OBJS))
MOCKED_HDRS   = $(patsubst %.o,%.h,$(MOCKED_OBJS))
TESTS_RESULTS = $(patsubst $(TEST_SRC_DIR)/%.c,$(TEST_RES_DIR)/%.testresults,$(SCENARII_SRCS))
TESTS_BINS    = $(patsubst $(TEST_RES_DIR)/%.testresults,$(TEST_BIN_DIR)/%,$(TESTS_RESULTS))
TESTS_RUNNER  = $(patsubst $(TEST_RES_DIR)/%.testresults,$(TEST_RUNNER_DIR)/%_runner.c,$(TESTS_RESULTS))
TESTS_RUNNER_OBJS = $(patsubst $(TEST_RUNNER_DIR)/%_runner.c,$(TEST_RUNNER_DIR)/%_runner.o,$(TESTS_RUNNER))

# Build preprocessor/compiler/assembler flags
CFLAGS  = $(CONAN_CFLAGS)
CFLAGS += $(addprefix -I,$(patsubst %/,%,$(sort $(dir $(HDRS)))))
CFLAGS += $(addprefix -D,$(CONAN_DEFINES))
CFLAGS += -Wall

# Build linker flags
LDFLAGS  = $(addprefix -L,$(patsubst %/,%,$(CONAN_LIB_DIRS)))
LDFLAGS += -Wl,-\( $(addprefix -l,$(CONAN_LIBS)) -Wl,-\)

########################################################
# PHONY build rules
########################################################
.PHONY: all
all: $(TESTED_OBJS) $(TESTS_RESULTS)
	@$(MKDIR) $(TEST_COV_DIR)
	-$(V)gcovr -r $(call convert_func,$(ROOTDIR)) --html-details $(call convert_func,$(TEST_COV_DIR)/report.html) --html-self-contained
	-$(V)gcovr -r $(call convert_func,$(ROOTDIR)) --xml $(call convert_func,$(TEST_COV_DIR)/report.xml) --xml-pretty
	-$(V)gcovr -r $(call convert_func,$(ROOTDIR)) --sonarqube $(call convert_func,$(TEST_COV_DIR)/report.sonar)
	-$(V)gcovr -r $(call convert_func,$(ROOTDIR)) --json $(call convert_func,$(TEST_COV_DIR)/report.json) --json-pretty
	-$(V)gcovr -r $(call convert_func,$(ROOTDIR)) --json-summary $(call convert_func,$(TEST_COV_DIR)/report-summary.json) --json-summary-pretty
	-$(V)gcovr -r $(call convert_func,$(ROOTDIR)) --coveralls $(call convert_func,$(TEST_COV_DIR)/report.coveralls) --coveralls-pretty
	-$(V)$(RUBY) $(UNITY_DIR)/auto/unity_test_summary.rb $(TEST_RES_DIR)/ $(ROOTDIR)/
	-$(V)gcovr -s -r $(call convert_func,$(ROOTDIR))

$(TEST_OBJ_DIR)/lib2test.a: $(TESTED_OBJS)
	@$(MKDIR) $(dir $@)
	@$(ECHO) AR $(notdir $@)
	$(V)$(HOST_AR) r $@ $^

$(TEST_OBJSRC_DIR)/%.o: $(SRC_DIR)/%.c $(PRE_DIR)/%.i $(DEP_DIR)/%.d
	@$(MKDIR) $(dir $@)
	@$(ECHO) CC $(notdir $@)
	$(V)$(HOST_CC) -c $(CFLAGS) $(COVERAGE_CFLAGS) $(call convert_func,$<) -o $(call convert_func,$@)

$(TEST_OBJSRC_DIR)/%.o: $(SRC_DIR)/%.s
	@$(MKDIR) $(dir $@)
	@$(ECHO) AS $(notdir $@)
	$(V)$(HOST_CC) -c $(CFLAGS) $< -o $@

$(TEST_OBJSRC_DIR)/%.o: $(SRC_DIR)/%.S $(PRE_DIR)/%.i $(DEP_DIR)/%.d
	@$(MKDIR) $(dir $@)
	@$(ECHO) AS $(notdir $@)
	$(V)$(HOST_CC) -c $(CFLAGS) $< -o $@

$(PRE_DIR)/%.i: $(SRC_DIR)/%.c
	@$(MKDIR) $(dir $@)
	$(V)$(HOST_CC) -E $(CFLAGS) $< > $@

$(PRE_DIR)/%.i: $(SRC_DIR)/%.S
	@$(MKDIR) $(dir $@)
	$(V)$(HOST_CC) -E $(CFLAGS) $< > $@

$(DEP_DIR)/%.d: $(SRC_DIR)/%.c
	@$(MKDIR) $(dir $@)
	$(V)$(HOST_CC) $(CFLAGS) -MT $(patsubst $(DEP_DIR)/%.d,$(OBJ_DIR)/%.o,$@) -MM -MF $@ $<

$(DEP_DIR)/%.d: $(SRC_DIR)/%.S
	@$(MKDIR) $(dir $@)
	$(V)$(HOST_CC) $(CFLAGS) -MT $(patsubst $(DEP_DIR)/%.d,$(OBJ_DIR)/%.o,$@) -MM -MF $@ $<

$(TEST_MOCK_DIR)/%.o: $(HDRS)
	@$(MKDIR) $(dir $@)
	$(V)MOCK_OUT=$(TEST_MOCK_DIR) $(RUBY) $(CMOCK_DIR)/scripts/create_mock.rb $(filter %$(patsubst mock_%.o,%.h,$(notdir $@)),$^)
	@$(ECHO) CC $(notdir $@)
	$(V)$(HOST_CC) -c $(CFLAGS) -I$(UNITY_DIR)/src -I$(CMOCK_DIR)/src -I$(TEST_MOCK_DIR) $(patsubst %.o,%.c,$@) -o $@

$(TEST_RUNNER_DIR)/%_runner.c: $(TEST_SRC_DIR)/%.c
	@$(MKDIR) $(dir $@)
	$(V)$(RUBY) $(CMOCK_DIR)/scripts/create_runner.rb $< $@

$(TEST_RUNNER_DIR)/%.o: $(TEST_RUNNER_DIR)/%.c
	@$(MKDIR) $(dir $@)
	@$(ECHO) CC $(notdir $@)
	$(V)$(HOST_CC) -c $(CFLAGS) -I$(UNITY_DIR)/src -I$(CMOCK_DIR)/src $< -o $@

$(TEST_OBJ_DIR)/%.o: $(TEST_SRC_DIR)/%.c
	@$(MKDIR) $(dir $@)
	@$(ECHO) CC $(notdir $@)
	$(V)$(HOST_CC) -c $(CFLAGS) -I$(UNITY_DIR)/src -I$(CMOCK_DIR)/src $< -o $@

$(TEST_OBJ_DIR)/unity.o: $(UNITY_DIR)/src/unity.c
	@$(MKDIR) $(dir $@)
	@$(ECHO) CC $(notdir $@)
	$(V)$(HOST_CC) -c $(CFLAGS) -I$(UNITY_DIR)/src -I$(CMOCK_DIR)/src $< -o $@

$(TEST_OBJ_DIR)/cmock.o: $(CMOCK_DIR)/src/cmock.c
	@$(MKDIR) $(dir $@)
	@$(ECHO) CC $(notdir $@)
	$(V)$(HOST_CC) -c $(CFLAGS) -I$(UNITY_DIR)/src -I$(CMOCK_DIR)/src $< -o $@

$(TEST_BIN_DIR)/%: $(TEST_OBJ_DIR)/unity.o $(TEST_OBJ_DIR)/cmock.o $(TEST_RUNNER_DIR)/%_runner.o $(TEST_OBJ_DIR)/%.o
	@$(MKDIR) $(dir $@)
	@$(ECHO) LD $(notdir $@)
	$(V)$(TARGET_CC) $(LDFLAGS) $(COVERAGE_LFLAGS) $^ -o $@

$(TEST_RES_DIR)/%.testresults: $(TEST_BIN_DIR)/%
	@$(MKDIR) $(dir $@)
	@$(ECHO) Execute $(notdir $<)
	-$(V)$(TIMEOUT) $(TIMEOUT_IN_TIME) $< > $@

########################################################
# PHONY clean rules
########################################################
.PRECIOUS: $(TEST_OBJ_DIR)/lib2test.a $(TESTED_OBJS) $(MOCKED_OBJS) $(MOCKED_SRCS) $(MOCKED_HDRS) $(PRES) $(DEPS) $(TESTS_RESULTS) $(TESTS_BINS) $(TESTS_RUNNER) \
		   $(ASSETS_OBJS) $(SCENARII_OBJS) $(TESTS_RUNNER_OBJS)
.PHONY: clean
clean:
	-$(V)$(RM) --preserve-root -rf $(TEST_BUILDDIR)/*

-include $(DEPS)
-include $(SCENARII_MKS)
