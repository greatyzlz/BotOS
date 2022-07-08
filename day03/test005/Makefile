
NASM=nasm
DD=dd
MAKE=make
FLOPPY=../../botos.img

all:ipl10.bin loader.bin	
	$(DD) if=ipl10.bin of=$(FLOPPY) seek=0 count=1 conv=notrunc
	$(DD) if=loader.bin of=$(FLOPPY) seek=1 count=1 conv=notrunc

ipl10.bin:ipl.asm
	$(NASM) $< -o $@

loader.bin:loader.asm
	$(NASM) $< -o $@

.PYONY:clean
clean:
	rm *.bin
