# Creidts to frizensami/ramos, because I am bad at Makefiles
all: sos.bin

# These are files that are part of the distribution but are not source code
AUXFILES := Makefile lessons.txt

# All project directories to search for files in - only current dir for now 
PROJDIRS := .

# We require a CROSS-COMPILER (changing this from i686-elf-gcc doesn't work)
CC := i686-elf-gcc

# Enabled warnings for the compiler
WARNINGS := -Wall -Wextra -Wshadow -Wpointer-arith -Wcast-align \
            -Wwrite-strings -Wmissing-declarations \
            -Wredundant-decls -Wnested-externs -Winline -Wno-long-long \
            -Wconversion -Wno-strict-prototypes
# Actual compiler settings: -g (debug symbols) and 
CFLAGS := -g -std=gnu99 -ffreestanding $(WARNINGS)

# The types of files we will be compiling
SRCFILES    := $(shell find $(PROJDIRS) -type f -name "*.c")
ASMFILES    := $(shell find $(PROJDIRS) -type f -name "*.s")
HDRFILES    := $(shell find $(PROJDIRS) -type f -name "*.h")
OBJASMFILES := $(patsubst %.s,%.o,$(ASMFILES))
OBJCFILES   := $(patsubst %.c,%.o,$(SRCFILES))
OBJFILES    := $(OBJCFILES) $(OBJASMFILES)
# Depfiles is special: GCC will generate .d dependancy files so that Make can parse them
DEPFILES    := $(patsubst %.c,%.d,$(SRCFILES))
-include $(DEPFILES) 
ALLFILES    := $(SRCFILES) $(ASMFILES) $(HDRFILES) $(AUXFILES)

# We need a custom linker script so that we can assemble the final binary
# with the sections laid out in our own way.
LINKSCRIPT  := boot/linker.ld

# This is to avoid a situation where we have a file called "all" or "clean"
# And make does nothing, since the "all" file already exists
.PHONY: all clean run sos.bin

sos.bin: $(LINKSCRIPT) $(OBJFILES) $(HDRFILES) 
	$(CC) -ffreestanding -nostdlib -g -T $(LINKSCRIPT) $(OBJFILES) -o sos.bin -lgcc

%.o: %.c Makefile
	$(CC) $(CFLAGS) -MMD -MP -c $< -o $@

%.o: %.s Makefile
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	$(RM) $(wildcard $(OBJFILES) $(DEPFILES))

run: sos.bin
	qemu-system-i386 -kernel sos.bin