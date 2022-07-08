
NASM=nasm
DD=dd
MAKE=make
FLOPPY=../../botos.img

all:ipl.bin loader.bin
	$(DD) if=ipl.bin of=$(FLOPPY) seek=0 count=1 conv=notrunc
	$(DD) if=loader.bin of=$(FLOPPY) seek=1 count=1 conv=notrunc

ipl.bin:ipl4.asm
	$(NASM) $< -o $@

loader.bin:loader.asm
	$(NASM) $< -o $@

.PYONY:clean
clean:
	rm *.bin
