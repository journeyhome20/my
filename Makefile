CC		:=gcc
EMPTY	:=
SPACE	:= $(EMPTY) $(EMPTY)
SLASH	:= /
OBJDIR	:= obj
BINDIR	:= bin
V 		:= @
IMG 	:= destiny.img
QEMU := $(shell if which qemu-system-i386 > /dev/null; \
	then echo 'qemu-system-i386'; exit; \
	elif which i386-ucore-elf-qemu > /dev/null; \
	then echo 'i386-ucore-elf-qemu'; exit; \
	else \
	echo "***" 1>&2; \
	echo "*** Error: Couldn't find a working QEMU executable." 1>&2; \
	echo "*** Is the directory containing the qemu binary in your PATH" 1>&2; \
	echo "***" 1>&2; exit 1; fi)
packetname = $(if $(1),$(addprefix $(OBJPREFIX),$(1)),$(OBJPREFIX))
includ := -Ilibs/ -Ikernel/libs/ -Iboot/
cflags := -fno-builtin -Wall -ggdb -m32 -gstabs -nostdinc $(includ)
cflags += $(shell $(CC) -fno-stack-protector -E -x c /dev/null >/dev/null 2>&1 && echo -fno-stack-protector)
ldflags	:= -m $(shell $(LD) -V | grep elf_i386 2>/dev/null)
ldflags	+= -nostdlib
kld := kernel.ld
bld := boot.ld
dirkobj := $(foreach v,$(filter %.c %.S,$(shell ls -R kernel/)),$(OBJDIR)$(SLASH)k$(SLASH)$(v:.c=.o))
ksrc := $(filter %.c %.S,$(shell find kernel/))
bsrc := $(filter %.c %.S,$(shell find boot/))
dirbobj := $(foreach v,$(filter %.c %.S,$(shell ls -R boot/)),$(OBJDIR)$(SLASH)b$(SLASH)$(patsubst %.S,%.o,$(v:.c=.o)))
read_src = $(shell echo "$(2)" | awk '{for(i=1;i<=NF;i++)if($$i~/$(1).[cS]/)print $$i}')

.PHONY: clean qemu all
clean:
	rm -f -r obj bin
	
all: $(BINDIR)$(SLASH)$(IMG)
	make boot
	
qemu: $(BINDIR)$(SLASH)$(IMG)
	$(V)gnome-terminal -e "$(QEMU) -S -s -d in_asm -hda $(BINDIR)$(SLASH)$(IMG) -monitor stdio -serial null"
	$(V)sleep 2
	$(V)gnome-terminal -e "gdb -q -x tool/gdbinit"
	

$(BINDIR)$(SLASH)$(IMG) : $(BINDIR)$(SLASH)b$(SLASH)boot
	$(V)$(CC) -g -Wall -O2 -c tool/sign.c -o obj/sign.o
	$(V)$(CC) -g -Wall -O2 obj/sign.o -o bin/sign
	objcopy -S -O binary $(BINDIR)$(SLASH)b$(SLASH)boot $(BINDIR)$(SLASH)b$(SLASH)boot.out
	bin/sign $(BINDIR)$(SLASH)b$(SLASH)boot.out $(BINDIR)$(SLASH)bootblock
	dd if=/dev/zero of=$@ count=10000
	dd if=$(BINDIR)$(SLASH)bootblock of=$@ conv=notrunc

kernel : $(BINDIR)$(SLASH)k$(SLASH)kernel

$(BINDIR)$(SLASH)k$(SLASH)kernel : $(kld)

$(BINDIR)$(SLASH)kernel : $(dirkobj)
	@echo ++ld kernel $(dirkobj)
	$(V)ld $(ldflags) -T $(kld) -o $@ $(dirkobj)
	
$(dirkobj) : $(call read_src,$(basename $(notdir $@)),$(ksrc))
	@mkdir -p $(BINDIR)$(SLASH)k $(OBJDIR)$(SLASH)k
	@echo ++cc $@
	$(V)$(CC) $(cflags) -c -Os -o $@ $(call read_src,$(basename $(notdir $@)),$(ksrc))

boot : $(BINDIR)$(SLASH)b$(SLASH)boot

$(BINDIR)$(SLASH)b$(SLASH)boot : $(bld)

$(BINDIR)$(SLASH)b$(SLASH)boot : $(dirbobj)
	@echo ++ld boot $(dirbobj)
	$(V)ld $(ldflags) -T $(bld) -o $@ $(dirbobj)

$(dirbobj) : $(call read_src,$(basename $(notdir $@)),$(bsrc))
	@mkdir -p $(BINDIR)$(SLASH)b $(OBJDIR)$(SLASH)b
	@echo ++cc $@
	$(V)$(CC) $(cflags) -c -Os -o $@ $(call read_src,$(basename $(notdir $@)),$(bsrc))
	
