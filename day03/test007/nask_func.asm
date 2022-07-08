;nask_func

[bits 32]

	global _io_hlt			;导出函数名，供其他文件用
	
;函数体
[section .text]				;目标文件中标明代码段
_io_hlt:					;void io_hlt(void)
	hlt
	ret