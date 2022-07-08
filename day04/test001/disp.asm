	global _disp
[bits 16]
_disp:
	mov ax, 0xB800	;指向文本模式的显示缓冲区,0xB800为段首值，左移4为+偏移则为实际物理地址
	mov es, ax

	mov byte [es:0x0], 'I'	;物理地址0xB8000处放入I
	mov byte [es:0x1], 0x07	;物理地址0xB8000处放入0x07，黑底白字
	mov byte [es:0x2], 'L'
	mov byte [es:0x3], 0x07

	ret