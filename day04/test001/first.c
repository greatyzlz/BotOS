void _io_hlt(void);
void _write_mem8(int addr, int data);
void HariMain(void)
{
	int i; /*变量声明：i是一个32位整数*/
	for (i = 0xa0000; i <= 0xaffff; i++) {
		_write_mem8(i, 15); /* MOV BYTE [i],15 */
	}
	for (;;) {
		_io_hlt();
	}
}
