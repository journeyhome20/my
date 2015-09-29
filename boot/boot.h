#ifndef __BOOT_H__
#define __BOOT_H__

#define PROT_MODE_CSEG        0x8
#define PROT_MODE_DSEG        0x10
#define CR0_PE_ON             0x1

#define SEG_NULLASM                                             \
    .word 0, 0;                                                 \
    .byte 0, 0, 0, 0

#define SEG_ASM(type,base,lim)                                  \
    .word (((lim) >> 12) & 0xffff), ((base) & 0xffff);          \
    .byte (((base) >> 16) & 0xff), (0x90 | (type)),             \
        (0xC0 | (((lim) >> 28) & 0xf)), (((base) >> 24) & 0xff)

#define STA_X       0x8
#define STA_E       0x4
#define STA_C       0x4
#define STA_W       0x2
#define STA_R       0x2
#define STA_A       0x1

#endif/*__BOOT_H__*/
