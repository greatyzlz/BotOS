extern void _io_hlt(void);
extern void write_mem8(int addr, int data);

void main(void)
{
	int i = 0;
	
	for (i = 0xa0000; i <= 0xaffff; ++i)
	{
		write_mem8(i, 15); /*mov [i], 15*/
	}
	
	for (;;)
		_io_hlt();

}
