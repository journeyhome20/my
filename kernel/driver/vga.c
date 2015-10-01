#include <vga.h>
#include <x86.h>

static uint16_t *crt_buf;
static uint16_t crt_pos;

public void vga_init(){

	crt_buf = (uint16_t *)VGA_BUF;

	uint32_t pos;
	outb(VGA_BASE, 14);
	pos = inb(VGA_BASE + 1) << 8;
	outb(VGA_BASE, 15);
	pos |= inb(VGA_BASE + 1);

	crt_pos = pos;
}

public void vga_putc(char c){
	uint16_t data = (uint16_t)c | 0x0700;

	switch (c & 0xff) {
	    case '\b':
	        if (crt_pos > 0) {
	            crt_pos --;
	            crt_buf[crt_pos] = data;
	        }
	        break;
	    case '\n':
	        crt_pos += CRT_COLS;
	    case '\r':
	        crt_pos -= (crt_pos % CRT_COLS);
	        break;
	    default:
	        crt_buf[crt_pos ++] = data;
	}

	outb(VGA_BASE, 14);
	outb(VGA_BASE + 1, crt_pos >> 8);
	outb(VGA_BASE, 15);
	outb(VGA_BASE + 1, crt_pos);
}
