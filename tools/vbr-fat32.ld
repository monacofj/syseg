OUTPUT_FORMAT(binary)
SECTIONS
{
	. = 0x7c00 + 90;
	.text : SUBALIGN(1)
	      {
		*(.text)
		*(.rodata)
	      }
	/DISCARD/ :
	      {
		*(*)
	      }
	ASSERT(. <= 0x7c00 + 510, "VBR bootstrap exceeds boot sector")
}
