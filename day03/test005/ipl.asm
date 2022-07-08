	org 0x7c00				;告诉编译器要将该程序装载到的目的地址，即程序要从指定的这个地址开始(联想到程序都编译成基地址＋偏移地址进行执行)；MBR地址范围0x7000-0x71ff
CYLS	equ		10
	
start:
	mov	ax, 0			;使用ax初始化ds, es, ss非通用寄存器不能直接赋立即数
	mov	ss, ax
	mov	sp, 0x7c00
	mov	ds, ax
	mov	es, ax
	
	mov ax, 0x0900
	mov es, ax
	mov ch, 0			;柱面/磁道号(0为起始号)
	mov dh, 0			;磁头0
	mov cl, 2			;起始扇区号(1为起始号)
						;ES:BX = 数据区中Ｉ/Ｏ缓冲区的地址(除检验操作外)
readloop:
	mov si, 0
	
retry:
	mov bx, 0
	mov ah, 0x02		;要执行的操作：复位(0), 读状态(1), 读磁盘(2), 写磁盘(3), 检验扇区(4)
	mov al, 1			;扇区数
	mov dl, 0x0		;驱动器号: 软盘:0=驱动器Ａ，1=驱动器Ｂ，硬盘:81h=驱动器１，81h=驱动器２，...
	int 0x13			;调用bois 13号中断服务
	jnc next
	add si, 1
	cmp si, 5
	jae error
	mov ah, 0x00
	mov dl, 0x0
	int 0x13			;重置驱动器
	jmp retry
	
next:
	mov ax, es			;将内存地址往后移动512字节，则段地址为512/16=0x20
	add ax, 0x0020
	mov es, ax
	add cl, 1
	cmp cl, 18			;硬盘最大只能是14个扇区，但我的vhd磁盘是963磁道4磁头17扇区的，换成软盘就可以了，这里搞不懂
	jbe readloop
	mov cl, 1
	add dh, 1
	cmp dh, 2			;磁盘有双面，所以有两个磁头
	jb  readloop
	mov dh, 0
	add ch, 1
	cmp ch, CYLS
	jb  readloop
	mov [0x0ff0], ch
	jmp 0x9000
	
fin:
	hlt
	jmp	fin
	
error:	
	mov	si, msg
	jmp putloop
ok:
	mov si, ok_msg
	jmp putloop
	
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

	
msg:
	db	0x0a, 0x0a
	db	"load error !"
	db	0x0a
	db	0

ok_msg:
	db	0x0a, 0x0a
	db	"load ok !"
	db	0x0a
	db	0	
	
	times 510 - ($ - $$) db 0	;$表示当前相对开始处的偏移地址，$$$$表示当前段的开始处的地址
	db 0x55, 0xaa
