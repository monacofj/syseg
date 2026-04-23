OUTPUT_FORMAT(binary)
SECTIONS
{
	. = 0x7c00 + 90;
	.text : SUBALIGN(1)
	      {
		*(.text)
		*(.rodata)
	      }
}
