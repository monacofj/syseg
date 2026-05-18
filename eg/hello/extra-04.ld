/*
 * SPDX-FileCopyrightText: 2026 Monaco F. J. <https://github.com/monacofj>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * This file is part of SYSeg (https://github.com/monacofj/syseg)
 */

/* Very simple linker script. */

OUTPUT_FORMAT(binary)		       /* Choose output format: flat binary.  */
SECTIONS
{
	. = ORG;		       /* Advance current ofset to 0x700.     */
	.code . : SUBALIGN(1)
	{
            extra-04-rt0.o (.text)
	    extra-04a.o(.text)
	    extra-04b.o(.text)
	    extra-04b.o(.rodata)
	}
	. = 0x7c00 + 510;	       /* Advance to 0x7c00 and fill the gap. */
	.signature : { SHORT(0xaa55) } /* Add boot signature.                 */

	STACK_BASE = 0x7c00 ;	       /* Define symbol STACK_BASE.            */

}
STARTUP(extra-04-rt0.o)

/* Notes.

   This linker scripts ensures that the input objects are processed in the
   correct order, independently from the order in which they appear in the
   command line.

   Alse we define the symbol STACK_BASE, with the value 0x7c00. Remember,
   STACK_BASE is not a variable, it's just a name for an address. We then use
   the symbol in rt0b.asm.

*/
