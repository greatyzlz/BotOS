
NASM=nasm
DD=dd
MAKE=make
CC=gcc
LD=ld
OBJCOPY=objcopy

FLOPPY=../../botos.img
VHD = ../../BotOS.vhd

all:ipl.bin loader.bin
	$(DD) if=ipl.bin of=$(VHD) seek=0 count=1 conv=notrunc
	$(DD) if=loader.bin of=$(VHD) seek=1 count=30 conv=notrunc

ipl.bin:ipl.asm
	$(NASM) $< -o $@

loader.bin:loader.elf
	$(OBJCOPY) -O binary $< $@

loader.elf:asm_head.o nask_func.o first.o
	$(LD) -s -Ttext 0x9000 $^ -o $@

asm_head.o:asm_head.asm
	$(NASM) -f elf -o $@ $<

nask_func.o:nask_func.asm
	$(NASM) -f elf -o $@ $<

first.o:first.c
	$(CC) -c -o $@ $<

.PYONY:clean
clean:
	rm *.bin *.o *.elf
