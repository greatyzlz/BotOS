;nask_func

[bits 32]

	global _io_hlt			;导出函数名，供其他文件用
	global write_mem8
	
;函数体
[section .text]				;目标文件中标明代码段
_io_hlt:					;void io_hlt(void)
	hlt
	ret
	
write_mem8:					;void write_mem8(int addr, int data)
	mov ecx, [esp + 4]
	mov al, [esp + 8]
	mov [ecx], al
	ret
