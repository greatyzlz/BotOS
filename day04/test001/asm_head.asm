LOADER_PHY equ 0x9000
; LOADER_PHY equ LOADER_BASE_ADDR * 0x10

DA_32	equ	0x4000	;32位代码段
DA_C	equ	0x98	;只执行代码段的属性
DA_DRW	equ 0x92	;可读写数据段
DA_DRWA	equ	0x93	;存在的已访问的可读写的
DA_LDT	equ 0x82	;省局
SA_TIL	equ 0x4		;具体的任务

%macro Descriptor 3
	dw %2 & 0xFFFF	;段的界限1（2Bytes）
	dw %1 & 0xFFFF	;段基址1（2Bytes）
	db (%1 >> 16) & 0xFF	;段基址2（1Byte）
	dw ((%2 >> 8) & 0xF00) | (%3 & 0xF0FF)	;属性1 + 段界限2+属性2 （2 bytes）
	db (%1 >> 24) & 0xFF	;段基址3（1Byte）
%endmacro

; section loader vstart=0x900

[bits 16]
align 16
	global _start
_start:
	mov ax, 0xb800
	mov es, ax
	mov byte [es:0x18], 'M'
	mov byte [es:0x19], 0x0C

	; jmp PM_BEGIN	;跳入到标号为PM_BEGIN代码段开始推进
	; jmp test
	mov byte [es:0x16], 'N'
	mov byte [es:0x17], 0x0C

	mov ax, cs
	mov ds, ax
	mov es, ax
	mov ss, ax
	mov sp, LOADER_PHY

	;加载GDTR
	; xor eax, eax
	; mov ax, ds
	; shl eax, 4
	; add eax, PM_GDT
	; mov dword [GdtPtr + 2], PM_GDT + LOADER_PHY
	lgdt [GdtPtr]

	;A20
	cli
	
	in al, 0x92
	or al, 00000010b
	out 0x92, al
	
	;切换到保护模式
	mov eax, cr0
	or eax, 1
	mov cr0, eax



	jmp dword SelectorCode32:PM_SEG_CODE32

[section .gdt]
;GDT
;							段基址	|	段界限			| 	属性
PM_GDT: 		Descriptor	0		,	0				,	0
PM_DESC_CODE32: Descriptor	0		,	0xFFFFF			,	DA_C + DA_32
PM_DESC_DATA:	Descriptor	0		,	0xFFFFF			,	DA_DRW
PM_DESC_VIDEO:	Descriptor	0xB8000	,	0xBFFFF			,	DA_DRW
;end of definition gdt
GdtLen equ $ - PM_GDT
GdtPtr:
	dw GdtLen - 1
	dd PM_GDT	;GDT 基地址

;GDT 选择子
SelectorCode32 equ PM_DESC_CODE32 - PM_GDT
SelectorDATA equ PM_DESC_DATA - PM_GDT
SelectorVideo equ PM_DESC_VIDEO - PM_GDT
;end of [section .gdt]

[section .s32]	;32位的代码段
align 32
[bits 32]
PM_SEG_CODE32:
	mov ax, SelectorDATA	;通过数据段的选择子放入ds寄存器，就可以用段+偏移进行寻址
	mov ds, ax	
	mov ax, SelectorVideo
	mov gs, ax

	mov ah, 0x0C
	xor esi, esi
	xor edi, edi
	mov esi, PM_DATA
	mov edi, (80*2+0)*2
	cld
	
.1:
	lodsb
	test al,al
	jz .2
	mov [gs:edi],ax
	add edi,2
	jmp .1
	
.2: ;显示完毕

	;测试段的寻址
	mov ax,SelectorVideo
	mov gs,ax 
	mov edi,(80*15 +0) *2
	mov ah,0Ch
	mov al,'A'
	mov [gs:edi],ax

	jmp $	
fin:
	hlt
	jmp fin

;end of [section .s32]

[section .data1]
; align 32
[bits 32]
PM_DATA:
	db "Protect Mode", 0
;end of [section .data1]




