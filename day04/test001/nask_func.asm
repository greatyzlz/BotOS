;nask_func

[bits 32]

	global _io_hlt			;导出函数名，供其他文件用
	global _write_mem8
	
;函数体
[section .text]				;目标文件中标明代码段

_write_mem8: ; void write_mem8(int addr, int data);
	mov ecx, [esp+4] ; [ESP + 4]中存放的是地址，将其读入ECX
	mov al, [esp+8] ; [ESP + 8]中存放的是数据，将其读入AL
	mov [ecx], al
	ret

_io_hlt:					;void io_hlt(void)
	hlt
	ret