#include <console.h>
#include <global.h>

private const char mes[] = "Hello world!";

public void init(){

	console_init();

	int i = 0;
	for(;mes[i]!='\0';i++);
	int j=0;
	for(;j!=i;j++)
		vga_putc(mes[j]);
}
