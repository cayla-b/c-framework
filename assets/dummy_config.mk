#############################################
# Project specifics
#############################################
TARGETNAME=yourProject
CCFLAGS   =
ASFLAGS   =
ARFLAGS   =
LDFLAGS   =

#############################################
# Compilation Toolchain
#############################################
CC=gcc
AS=as
AR=ar
LD=ld
LIB_PREFIX=lib
LIB_SUFFIX=.a
EXE_PREFIX=
EXE_SUFFIX=
SO_PREFIX=lib
SO_SUFFIX=.so

#############################################
# System
#############################################
ECHO=echo
RM=rm
MKDIR=mkdir -p
CP=cp
RECURSIVE_PARSING=ls -d -1 */ 2> /dev/null