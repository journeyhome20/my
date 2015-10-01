OUTPUT_FORMAT("elf32-i386", "elf32-i386", "elf32-i386")
OUTPUT_ARCH(i386)
ENTRY(init)


SECTIONS{
	
	. = 0x100000;
	
	.text : {
        *(.text .stub .text.* .gnu.linkonce.t.*)
    }
}