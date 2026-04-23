OUTPUT_FORMAT(binary)
SECTIONS
{
	. = 0x7c00;
	.text : SUBALIGN(1)
	      {
		*(.text)
		*(.rodata)
		*(.data)
	      }
	. = 0x7c00 + 510;
	.signature : { SHORT(0xaa55)}
}
