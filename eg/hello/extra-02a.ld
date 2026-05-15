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
	. = 0x7c00;		       /* Advance current ofset to 0x700.     */
	.code : SUBALIGN(1) {*}        /* Include all input sections in .code.*/
	. = 0x7c00 + 510;	       /* Advance to 0x7c00 and fill the gap. */
	.signature : { SHORT(0xaa55) } /* Add boot signature.                 */
}

/* Notes

   Here, since we have two sections, .text and .rodata, the linker is compelled
   to memory-align them at multiple-of-16 positions. To avoid that, we use the
   SUBALIGN() keyword.

 */
