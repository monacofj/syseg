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
	.code . : SUBALIGN(1) {*}      /* Include all input sections in .code.*/
	. = 0x7c00 + 510;	       /* Advance to 0x7c00 and fill the gap. */
	.signature : { SHORT(0xaa55) } /* Add boot signature.                 */
}
STARTUP(hello-10-rt0.o)

/* Notes.

   Here we have two noteworthy observations.

   First, we use

   	  . = ORG

   and define ORG in the ld command line. The rationale is the same we used for
   nasm: to reuse the same code for binary blobs, floppy and disk images. In
   the present case, we use --defsym ORG=0x7c00 or the corresponding values.

   Second, the SUBALIGN() keyword controls the alignment of the input sections
   within the outputsection. It however does not ensure that the start of the
   outputsection itself is not default-aligned. For the .bin case, 0x7c00 is
   already 16-bit-aligned, so, we're good. But for 0x7c3e, the linker wants
   to align .code to 0x7c40. The soluction is to force .code to be aligned at
   ORG no matter what is ORG:

       .code . : SUBALIGN(1)

   recalling that . is ORG here.

*/
