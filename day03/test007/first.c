extern void _io_hlt(void);

void first_main(void)
{
fin:
	_io_hlt();
	goto fin;
}
