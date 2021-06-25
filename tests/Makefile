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
else
ROOTDIR ?= $(abspath ..)
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
else
ifeq ($(COVERAGE),Statement)
COVERAGE_CFLAGS=-fprofile-arcs -ftest-coverage -fprofile-generate
else
ifeq ($(COVERAGE),Decisions)
COVERAGE_CFLAGS=-fprofile-arcs -ftest-coverage -fprofile-generate
else
ifeq ($(COVERAGE),MC_DC)
COVERAGE_CFLAGS=
$(error $(COVERAGE) coverage not yet handled !)
else
$(error Unknown coverage $(COVERAGE) please select one of the following [None,Statement,Decisions,MC_DC] !)
endif
endif
endif
endif

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
UNITEST_SRCS ?= $(shell $(FIND) $(UNIT_TEST_SRC_DIR) -name "*.c")
UNITEST_HDRS ?= $(shell $(FIND) $(UNIT_TEST_SRC_DIR) -name "*.h")
INTTEST_SRCS ?= $(shell $(FIND) $(INTEGRATION_TEST_SRC_DIR) -name "*.c")
INTTEST_HDRS ?= $(shell $(FIND) $(INTEGRATION_TEST_SRC_DIR) -name "*.h")

# Temporary build files
PRES          = $(patsubst $(SRC_DIR)/%.c,$(PRE_DIR)/%.i,$(filter %.c,$(SRCS)))
PRES         += $(patsubst $(SRC_DIR)/%.S,$(PRE_DIR)/%.i,$(filter %.S,$(SRCS)))
DEPS          = $(patsubst $(SRC_DIR)/%.c,$(DEP_DIR)/%.d,$(filter %.c,$(SRCS)))
DEPS         += $(patsubst $(SRC_DIR)/%.S,$(DEP_DIR)/%.d,$(filter %.S,$(SRCS)))
TESTED_OBJS   = $(patsubst $(SRC_DIR)/%.c,$(TEST_OBJ_DIR)/%.o,$(filter %.c,$(SRCS)))
TESTED_OBJS  += $(patsubst $(SRC_DIR)/%.s,$(TEST_OBJ_DIR)/%.o,$(filter %.s,$(SRCS)))
TESTED_OBJS  += $(patsubst $(SRC_DIR)/%.S,$(TEST_OBJ_DIR)/%.o,$(filter %.S,$(SRCS)))
MOCKED_OBJS   = $(patsubst %.h,$(TEST_MOCK_DIR)/mock_%.o,$(notdir $(HDRS)))
MOCKED_SRCS   = $(patsubst %.o,%.c,$(MOCKED_OBJS))
MOCKED_HDRS   = $(patsubst %.o,%.h,$(MOCKED_OBJS))

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
all: $(TEST_OBJ_DIR)/lib2test.a $(MOCKED_OBJS)
	$(V)$(MAKE) -C $(UNIT_TEST_SRC_DIR) ROOTDIR=$(ROOTDIR) BUILDDIR=$(BUILDDIR) VERBOSE=$(VERBOSE) COVERAGE=$(COVERAGE) all
	$(V)$(MAKE) -C $(INTEGRATION_TEST_SRC_DIR) ROOTDIR=$(ROOTDIR) BUILDDIR=$(BUILDDIR) VERBOSE=$(VERBOSE) COVERAGE=$(COVERAGE) all

$(TEST_OBJ_DIR)/lib2test.a: $(TESTED_OBJS)
	@$(MKDIR) $(dir $@)
	@$(ECHO) AR $(notdir $@)
	$(V)$(HOST_AR) r $@ $^

$(TEST_OBJ_DIR)/%.o: $(SRC_DIR)/%.c $(PRE_DIR)/%.i $(DEP_DIR)/%.d
	@$(MKDIR) $(dir $@)
	@$(ECHO) CC $(notdir $@)
	$(V)$(HOST_CC) -c $(CFLAGS) $(COVERAGE_CFLAGS) $< -o $@

$(TEST_OBJ_DIR)/%.o: $(SRC_DIR)/%.s
	@$(MKDIR) $(dir $@)
	@$(ECHO) AS $(notdir $@)
	$(V)$(HOST_CC) -c $(CFLAGS) $< -o $@

$(TEST_OBJ_DIR)/%.o: $(SRC_DIR)/%.S $(PRE_DIR)/%.i $(DEP_DIR)/%.d
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
	$(V)$(HOST_CC) -c $(CFLAGS) -I$(UNITY_DIR)/src -I$(CMOCK_DIR)/src -I$(TEST_MOCK_DIR) $< -o $@

########################################################
# PHONY clean rules
########################################################
.PRECIOUS: $(TEST_OBJ_DIR)/lib2test.a $(TESTED_OBJS) $(MOCKED_OBJS) $(MOCKED_SRCS) $(MOCKED_HDRS) $(PRES) $(DEPS)
.PHONY: clean
clean:
	-$(V)$(RM) --preserve-root -rf $(TEST_OBJ_DIR)/* $(TEST_MOCK_DIR)/*
	$(V)$(MAKE) -C $(UNIT_TEST_SRC_DIR) ROOTDIR=$(ROOTDIR) BUILDDIR=$(BUILDDIR) VERBOSE=$(VERBOSE) COVERAGE=$(COVERAGE) clean
	$(V)$(MAKE) -C $(INTEGRATION_TEST_SRC_DIR) ROOTDIR=$(ROOTDIR) BUILDDIR=$(BUILDDIR) VERBOSE=$(VERBOSE) COVERAGE=$(COVERAGE) clean

-include $(DEPS)
