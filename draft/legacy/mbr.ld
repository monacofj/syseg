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
	ASSERT(SIZEOF(.text) <= 446, "MBR bootstrap exceeds 446 bytes")
}
