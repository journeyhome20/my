#ifndef __VGA_H__
#define __VGA_H__

#include <global.h>

#define VGA_BASE        0x3D4
#define VGA_BUF         0xB8000
#define CRT_ROWS        25
#define CRT_COLS        80
#define CRT_SIZE        (CRT_ROWS * CRT_COLS)

public void vga_putc(char c);
public void vga_init(void);

#endif
