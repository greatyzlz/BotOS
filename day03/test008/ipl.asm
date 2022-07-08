;能够将第二个扇区里面的内容加载入内存
;mbr.asm |  loader.asm
;0扇区   |  1扇区 
;0x7c00  |  0x9000

LOADER_BASE_ADDR	EQU		0x9000		;物理地址
LOADER_START_SECTOR	EQU		0x1			;表示以LBA的方式，loader存放在第1个扇区

section MBR vstart=0x7c00		;相当于org 0x7c00
	mov ax, cs
	mov ds, ax
	mov es, ax
	mov ss, ax
	mov fs, ax
	mov sp, 0x7c00
	mov ax, 0xb800
	mov gs, ax
	
	;查BIOS手册（实现清屏）
	;利用0x06的功能，调用10号中断，
	;AH = 0x06
	;AL = 0 表示全部都要清除
	;BH = 上卷行的属性
	;(CL,CH),即左上角(x, y)
	;(DL,DH),即右下角(x, y)
	mov ax, 0x0600
	mov bx, 0x0700
	mov cx, 0
	mov dx, 0x184f ;(80, 25)
	int 0x10
	
	;输出当前程序在MBR中运行
	mov byte [gs:0x0], 'I'
	mov byte [gs:0x1], 0xA4
	mov byte [gs:0x2], ' '
	mov byte [gs:0x3], 0xA4
	mov byte [gs:0x4], 'a'
	mov byte [gs:0x5], 0xA4
	mov byte [gs:0x6], 'm'
	mov byte [gs:0x7], 0xA4
	
	mov byte [gs:0x8], ' '
	mov byte [gs:0x9], 0xA4
	
	mov byte [gs:0xa], 'M'
	mov byte [gs:0xb], 0xA4
	
	mov byte [gs:0xc], 'B'
	mov byte [gs:0xd], 0xA4
	
	mov byte [gs:0xe], 'R'
	mov byte [gs:0xf], 0xA4
	
	
	mov eax, LOADER_START_SECTOR	;LBA读入的扇区
	mov bx, LOADER_BASE_ADDR		;写入的地址
	mov cx, 30						;等待读入的扇区数
	mov byte [gs:0x10], 'O'
	mov byte [gs:0x11], 0xA4
	call rd_disk
	mov byte [gs:0x12], 'K'
	mov byte [gs:0x13], 0xA4
	
	jmp LOADER_BASE_ADDR			;跳到实际物理内存执行
	
	
rd_disk:
	;eax LBA扇区号
	;bx 数据写入的内存地址
	;cx 读入的扇区数
	mov esi, eax ;备份eax
	mov di, cx	;备份cx
;读硬盘， 查手册
	mov dx, 0x1f2
	mov al, cl
	out dx, al
	mov eax, esi
	
;将LBA的地址存入0x1f3, 0x01f6
	;7-0 bit 写入0x1f3， 
	mov dx, 0x1f3
	out dx, al
	
	;15-8bit写给0x1f4
	mov cl, 8
	shr eax, cl ;右移8位
	mov dx, 0x1f4
	out dx, al
	
	;23-16bit 写给1f5
	shr eax, cl
	mov dx, 0x1f5
	out dx, al
	
	shr eax, cl
	and al, 0x0f
	or al, 0xe0		;设置7-4位为1110, 此时才是LBA模式
	mov dx, 0x1f6
	out dx, al
	
	;向0x1f7写入读命令
	mov dx, 0x1f7
	mov al, 0x20
	out dx, al
	
	;检查硬盘状态
	.not_ready:
	nop		;空指令，等待
	in al, dx
	and al, 0x88	;4位为1表示可以传输， 7位为1表示硬盘忙
	cmp al, 0x08
	jnz .not_ready
	
	;读数据
	mov ax, di
	mov dx, 256
	mul dx
	mov cx, ax
	mov dx, 0x1f0
	

.go_on:
	in ax, dx
	mov [bx], ax
	add bx, 2
	loop .go_on
	ret
	
	times 510 - ($ - $$) db 0
	db 0x55, 0xAA
	
