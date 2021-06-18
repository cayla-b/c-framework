#!/usr/bin/make
########################################################
# Source directory (default makefile could be changed) #
# ---------------------------------------------------- #
# Required variables:                                  #
#  - ROOTDIR: The directory containing this makefile   #
#  - BUILDDIR: The directory where files are generated #
# Option defines source.mak in this folder defining    #
#  - SRCS : Sources files to consider to accelerate    #
#  - HDRS : Headers files to consider to accelerate    #
########################################################
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

# Include makefile useful to defines (directory mandatory, whilst configuration and conanbuildinfo requires conan configuration set up)
-include $(ROOTDIR)/configuration.mak
-include $(ROOTDIR)/conanbuildinfo.mak
include  $(ROOTDIR)/directory.mak
include  $(ROOTDIR)/tools.mak

# Sources files (recursive search or declarative source to fasten the process)
-include $(BUILDDIR)/source.mak
SRCS       ?= $(shell $(FIND) $(SRC_DIR) -name "*.c" -o -name "*.s" -o -name "*.S")
HDRS       ?= $(shell $(FIND) $(SRC_DIR) $(CONAN_INCLUDE_DIRS) -name "*.h")

# Temporary build files
PRES        = $(patsubst $(SRC_DIR)/%.c,$(PRE_DIR)/%.i,$(filter %.c,$(SRCS)))
PRES       += $(patsubst $(SRC_DIR)/%.S,$(PRE_DIR)/%.i,$(filter %.S,$(SRCS)))
DEPS        = $(patsubst $(SRC_DIR)/%.c,$(DEP_DIR)/%.d,$(filter %.c,$(SRCS)))
DEPS       += $(patsubst $(SRC_DIR)/%.S,$(DEP_DIR)/%.d,$(filter %.S,$(SRCS)))
OBJS        = $(patsubst $(SRC_DIR)/%.c,$(OBJ_DIR)/%.o,$(filter %.c,$(SRCS)))
OBJS       += $(patsubst $(SRC_DIR)/%.s,$(OBJ_DIR)/%.o,$(filter %.s,$(SRCS)))
OBJS       += $(patsubst $(SRC_DIR)/%.S,$(OBJ_DIR)/%.o,$(filter %.S,$(SRCS)))

# Build preprocessor/compiler/assembler flags
CFLAGS  = $(CONAN_CFLAGS)
CFLAGS += $(addprefix -I,$(patsubst %/,%,$(sort $(dir $(HDRS)))))
CFLAGS += $(addprefix -D,$(CONAN_DEFINES))
CFLAGS += -Wall

# Build linker flags
LDFLAGS  = $(addprefix -L,$(patsubst %/,%,$(CONAN_LIB_DIRS)))
LDFLAGS += -Wl,-\( $(addprefix -l,$(CONAN_LIBS)) -Wl,-\)
TARGET  ?= myProject

########################################################
# PHONY build rules
########################################################
.PHONY: all
all: $(BIN_DIR)/$(TARGET)

$(BIN_DIR)/%: $(BIN_DIR)/lib%.a
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

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.s
	@$(MKDIR) $(dir $@)
	@$(ECHO) AS $(notdir $@)
	$(V)$(TARGET_CC) -c $(CFLAGS) $< -o $@

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.S $(PRE_DIR)/%.i $(DEP_DIR)/%.d
	@$(MKDIR) $(dir $@)
	@$(ECHO) AS $(notdir $@)
	$(V)$(TARGET_CC) -c $(CFLAGS) $< -o $@

$(PRE_DIR)/%.i: $(SRC_DIR)/%.c
	@$(MKDIR) $(dir $@)
	$(V)$(TARGET_CC) -E $(CFLAGS) $< > $@

$(PRE_DIR)/%.i: $(SRC_DIR)/%.S
	@$(MKDIR) $(dir $@)
	$(V)$(TARGET_CC) -E $(CFLAGS) $< > $@

$(DEP_DIR)/%.d: $(SRC_DIR)/%.c
	@$(MKDIR) $(dir $@)
	$(V)$(TARGET_CC) $(CFLAGS) -MT $(patsubst $(DEP_DIR)/%.d,$(OBJ_DIR)/%.o,$@) -MM -MF $@ $<

$(DEP_DIR)/%.d: $(SRC_DIR)/%.S
	@$(MKDIR) $(dir $@)
	$(V)$(TARGET_CC) $(CFLAGS) -MT $(patsubst $(DEP_DIR)/%.d,$(OBJ_DIR)/%.o,$@) -MM -MF $@ $<

########################################################
# PHONY clean rules
########################################################
.PRECIOUS: $(PRES) $(OBJS) $(DEPS) $(BIN_DIR)/$(TARGET) $(BIN_DIR)/lib$(TARGET).a

.PHONY: clean
clean:
	-$(V)$(RM) --preserve-root -rf $(BIN_DIR)/* $(OBJ_DIR)/* $(PRE_DIR)/* $(DEP_DIR)/* $(DOC_DIR)/*

-include $(DEPS)