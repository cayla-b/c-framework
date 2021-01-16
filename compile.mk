#!/usr/bin/make
ROOTDIR  ?= $(shell git rev-parse --show-toplevel)
include $(ROOTDIR)/directory.mk
include $(ROOTDIR)/config.mk

##################################################
# Additional flags
##################################################
CFLAGS  += -I$(SRCDIR)
ASFLAGS += -I$(SRCDIR)
ARFLAG  += -r
LDFLAGS += 

##################################################
# Build general files
##################################################
$(BINDIR)/$(LIB_PREFIX)%$(LIB_SUFFIX):
	@-$(MKDIR) $(dir $@)
	@$(ECHO) AR $(notdir $@)
	$(AR) $(ARFLAGS) $@ $(shell find $(OBJDIR) -name *.o)
	@$(ECHO) "Compile C files with options: $(CFLAGS)"
	@$(ECHO) "Compile ASM files with options: $(ASFLAGS)"
	@$(ECHO) "Archived with options $(ARFLAGS)"

$(BINDIR)/$(EXE_PREFIX)%$(EXE_SUFFIX):
	@-$(MKDIR) $(dir $@)
	@$(ECHO) LD $(notdir $@)
	@$(CC) $(LDFLAGS) $(shell find $(OBJDIR) -name *.o) -o $@
	@$(ECHO) "Compile with options: $(CFLAGS)"
	@$(ECHO) "Compile ASM files with options: $(ASFLAGS)"
	@$(ECHO) "Link with options: $(LDFLAGS)"

$(BINDIR)/$(SO_PREFIX)%$(SO_SUFFIX):
	@-$(MKDIR) $(dir $@)
	@$(ECHO) No rule to this point to build shared object !
	@$(ECHO) Will be added here if required !

##############################################
# Rule C build definition
##############################################
$(OBJDIR)/%.o: $(SRCDIR)/%.c $(DEPDIR)/%.d
	@-$(MKDIR) $(dir $@)
	@$(ECHO) CC $(notdir $@)
	@$(CC) -c $(CFLAGS) -o $@ $<

##############################################
# Rule S build definition
##############################################
$(OBJDIR)/%.o: $(SRCDIR)/%.s $(DEPDIR)/%.d
	@-$(MKDIR) $(dir $@)
	@$(ECHO) CC $(notdir $@)
	@$(CC) -S $(ASFLAGS) -o $@ $<

$(OBJDIR)/%.o: $(SRCDIR)/%.S $(DEPDIR)/%.d
	@-$(MKDIR) $(dir $@)
	@$(ECHO) CC $(notdir $@)
	@$(CC) -S $(ASFLAGS) -o $@ $<

##############################################
# Rule dependencies files
##############################################
$(DEPDIR)/%.d: $(SRCDIR)/%.c
	@-$(MKDIR) $(dir $@)
	@$(CC) -M -MF $@ $(CFLAGS) $<
	
$(DEPDIR)/%.d: $(SRCDIR)/%.s
	@-$(MKDIR) $(dir $@)
	@$(CC) -M -MF $@ $(ASFLAGS) $<
	
$(DEPDIR)/%.d: $(SRCDIR)/%.S
	@-$(MKDIR) $(dir $@)
	@$(CC) -M -MF $@ $(ASFLAGS) $<

##############################################
# API export
##############################################
$(INCDIR)/%.h: $(SRCDIR)/%.h
	@-$(MKDIR) $(dir $@)
	@$(CP) $< $@
