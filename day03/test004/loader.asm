	org 0x9000				;告诉编译器要将该程序装载到的目的地址，即程序要从指定的这个地址开始(联想到程序都编译成基地址＋偏移地址进行执行)；MBR地址范围0x7000-0x71ff
	
start:
	mov	ax, 0				;使用ax初始化ds, es, ss非通用寄存器不能直接赋立即数
	mov	ss, ax
	mov	sp, 0x9000
	mov	ds, ax
	mov	es, ax
	
	mov	si, msg
putloop:
	mov	al, [si]
	add	si, 1
	cmp	al, 0
	je	fin
	mov	ah, 0x0e
	mov bx, 15
	int	0x10			;中断10调用BIOS的控制显卡函数, 参数如下：
						;AH=0x0e;
						;AL=character code;
						;BH=0;
						;BL=color code;
	jmp	putloop

fin:
	hlt
	jmp	fin
	
msg:
	db	0x0a, 0x0a
	db	"hello, botos !"
	db	0x0a
	db	0
	times 510 - ($ - $$) db 0	;$表示当前相对开始处的偏移地址，$$$$表示当前段的开始处的地址
	
	db 0x55, 0xaa
