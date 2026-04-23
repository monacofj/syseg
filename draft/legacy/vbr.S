#    SPDX-FileCopyrightText: 2021 Monaco F. J. <monaco@usp.br>
#
#    SPDX-License-Identifier: GPL-3.0-or-later
#
#    This file is part of SYSeg, available at https://gitlab.com/monaco/syseg.

	## FAT32 VBR bootstrap payload
	##
	## This code is meant to be placed after the FAT32 BPB/EBPB that mkfs.fat
	## writes into the partition boot sector. The linker script positions the
	## code at 0x7c00 + 90 so that the formatter-owned header remains intact.

	.code16

	.global _start

_start:

	movb  $0x0e, %ah	      # BIOS teletype output
	xorw  %si, %si

loop:
	movb  msg(%si), %al
	cmpb  $0x00, %al
	je    halt
	int   $0x10
	incw  %si
	jmp   loop

halt:
	hlt
	jmp   halt

msg:
	.string "Hello World"


	# Notes
	#
	# This file does not define the FAT32 BPB or the 0x55aa boot signature.
	# Those are expected to come from the filesystem formatter. The build flow
	# should inject only this payload into the formatter-generated VBR.
