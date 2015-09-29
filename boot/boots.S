#include <boot.h>

.globl start
start:
.code16

	cli
	cld

	xorw %ax, %ax
	movw %ax, %ds
	movw %ax, %es
	movw %ax, %ss

enablea20.1:
	inb $0x64, %al
	testb $0x2, %al
    jnz enablea20.1

    movb $0xd1, %al
    outb %al, $0x64

enablea20.2:
	inb $0x64, %al
	testb $0x2, %al
    jnz enablea20.2

	movb $0xdf, %al
	outb %al, $0x60

	lgdt gdtdesc
	movl %cr0, %eax
	orl $CR0_PE_ON, %eax
	movl %eax, %cr0

	ljmp $PROT_MODE_CSEG, $protcseg

.code32
protcseg:

	movw $PROT_MODE_DSEG, %ax
	movw %ax, %ds
	movw %ax, %es
	movw %ax, %fs
	movw %ax, %gs
	movw %ax, %ss

	movl $0x0, %ebp
	movl $start, %esp
#	call boot_start
	jmp spin

spin:
	jmp protcseg

.data
.p2align 2
gdt:
	SEG_NULLASM
	SEG_ASM(STA_X|STA_R, 0x0, 0xffffffff)
	SEG_ASM(STA_W, 0x0, 0xffffffff)

gdtdesc:
	.word 0x17
	.long gdt

