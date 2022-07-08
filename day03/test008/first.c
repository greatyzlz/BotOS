extern void _io_hlt(void);

void _io_hlt();

void first_main(void)
{
fin:
	_io_hlt();
	goto fin;
}
