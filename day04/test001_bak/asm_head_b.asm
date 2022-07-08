BOTPAK	EQU		0x00280000		;安装bootpack的目的地
DSKCAC	EQU		0x00100000		; 磁盘缓存位置
DSKCAC0	EQU		0x00008000		; 磁盘缓存位置（实时模式）

;有关BOOT_INFO
CYLS	equ		0x0ff0		;设定启动区
LEDS	equ		0x0ff1		
VMODE	equ		0x0ff2		;关于颜色数目的信息，颜色位数
SCRNX	equ		0x0ff4		;x方向分辨率
SCRNY	equ		0x0ff6		;y方向分辨率
VRAM	equ		0x0ff8		;图像缓冲区的开始地址
	
	;org 0x9000				;告诉编译器要将该程序装载到的目的地址，即程序要从指定的这个地址开始(联想到程序都编译成基地址＋偏移地址进行执行)
[bits 16]	
[section .text]
global _start
_start:
	mov al, 0x13		;VGA显卡，320x200x8位彩色，可以查看bois网页
						;0x03：16色字符模式，80 × 25
						;0x12：VGA 图形模式，640 × 480 × 4位彩色模式，独特的4面存储模式
						;0x13：VGA 图形模式，320 × 200 × 8位彩色模式，调色板模式
						;0x6a：扩展VGA 图形模式，800 × 600 × 4位彩色模式，独特的4面存储模式（有的显卡不支持这个模式
	mov ah, 0x00
	int 0x10
	
	;保存设置信息到内存
	mov byte [VMODE], 8	;记录画面模式
	mov word [SCRNX], 320
	mov word [SCRNY], 200
	mov dword [VRAM], 0x000a0000	;0xa0000~0xaffff 64K 为BIOS画面模式的VRAM
	
	;用BOIS取得键盘上各种LED指示灯的状态
	mov ah, 0x02
	int 0x16			;16号中断2号功能返回led状态在al
	mov [LEDS], al
	
; 防止PIC接受一切中断
;	AT兼容机的规格中，如果要初始化PIC
;	这家伙不在CLI前做的话，偶尔会死机
;	PIC的初始化之后再做

	mov		al, 0xff
	out		0x21, al
	nop						; 据说有如果连续OUT命令就无法顺利进行的机型
	out		0xa1, al

	cli						; 甚至CPU级别也禁止插队

; 为了能够从CPU访问1MB以上的存储器，设定A20GATE

	call	waitkbdout
	mov		al, 0xd1
	out		0x64, al
	call	waitkbdout
	mov		al, 0xdf			; enable A20
	out		0x60, al
	call	waitkbdout

; 转向保护模式

;[INSTRSET "i486p"]				; 到486的命令为止都想使用的记述
[bits 32]
	lgdt	[gdtr0]			; Setting provisional DDT
	mov		eax, cr0
	and		eax, 0x7fffffff	; Bit 31 (for paging)
	or 		eax, 0x00000001	; Set bit0 to 1 (for protected mode transition)
	mov		cr0, eax
	jmp		pipelineflush
pipelineflush:
	mov		ax, 1*8			;  Read / write segment 32bit
	mov		ds, AX
	mov		es, AX
	mov		fs, AX
	mov		gs, AX
	mov		ss, AX

; bootpackの転送

	mov		esi, bootpack	; Send yuan
	mov		edi, BOTPAK		; Send first
	mov		ecx, 512*1024/4
	call	memcpy

;Transfer disk data to its original position

; Boot sector

	mov		esi, 0x7c00		; Send yuan
	mov		edi, DSKCAC		; Send first
	mov		ecx, 512/4
	call	memcpy

; All remaining

	mov		esi, DSKCAC0+512	; Send yuan
	mov		edi, DSKCAC+512	    ; Send first
	mov		ecx, 0
	mov		cl, byte [CYLS]
	imul	ecx, 512*18*2/4	; Convert from cylinder count to number
	sub		ecx, 512/4		; Subtract by IPL
	call	memcpy

; All I have to do with asmhead is over.
; 	 Leave it to bootpack
; Bootpack boot

	mov		ebx, BOTPAK
	mov		ecx, [ebx+16]
	add		ecx, 3			; ECX += 3;
	shr		ecx, 2			; ECX /= 4;
	jz		skip			; Nothing to transfer
	mov		esi, [ebx+20]	; Send first
	add		esi, ebx
	mov		edi, [ebx+12]	; Send first
	call	memcpy
skip:
	mov		esp, [ebx+12]	; 堆栈初始值
	jmp		dword 2*8:0x0000001b

waitkbdout:
	in		 al, 0x64
	and		 al, 0x02
	jnz		 waitkbdout		; AND的结果如果不是0的话就变成waitkbdout
	ret

memcpy:
	MOV		eax,[esi]
	ADD		esi,4
	mov		[edi],eax
	add		edi,4
	sub		ecx,1
	jnz		memcpy			; 减去的结果如果不是0的话就变成memcpy
	ret
	
; 如果memcpy不忘记输入地址大小前缀，也可以用串命令来写

	alignb	16
gdt0:
	resb	8				; 无效选择器
	dw		0xffff,0x0000,0x9200,0x00cf	; 可读写段32比特
	dw		0xffff,0x0000,0x9a28,0x0047	; 可执行段32比特（用于bootpack）

	dw		0
gdtr0:
	dw		8*3-1
	dd		gdt0

	alignb	16
bootpack:


