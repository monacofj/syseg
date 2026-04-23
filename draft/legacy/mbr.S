#    SPDX-FileCopyrightText: 2021 Monaco F. J. <monaco@usp.br>
#
#    SPDX-License-Identifier: GPL-3.0-or-later
#
#    This file is part of SYSeg, available at https://gitlab.com/monaco/syseg.

	## MBR bootstrap for a disk with one active FAT32 partition.
	##
	## The partition table and the 0x55aa signature are provided by the
	## partitioning tool. This file only supplies the bootstrap code that fits
	## in the first 446 bytes of sector 0.

	.code16

	.set RELOC_BASE, 0x0600
	.set PTABLE_RELOC, RELOC_BASE + 0x1be

	.global _start

_start:
	cli
	xorw  %ax, %ax
	movw  %ax, %ds
	movw  %ax, %es
	movw  %ax, %ss
	movw  $0x7c00, %sp
	cld

	# Move the full boot sector away before loading the partition VBR at 0x7c00.
	movw  $0x7c00, %si
	movw  $RELOC_BASE, %di
	movw  $256, %cx
	rep
	movsw

	ljmp  $0x0000, $relocated_start_rebased

relocated_start:
	movb  %dl, boot_drive_reloc

	movw  $PTABLE_RELOC, %si
	movw  $4, %cx

find_active:
	cmpb  $0x80, (%si)
	je    active_found
	addw  $16, %si
	loop  find_active

	movw  $msg_no_active_reloc, %si
	call  print_string
	jmp   halt

active_found:
	movw  8(%si), %ax
	movw  %ax, dap_lba_reloc
	movw  10(%si), %ax
	movw  %ax, dap_lba_reloc+2
	xorw  %ax, %ax
	movw  %ax, dap_lba_reloc+4
	movw  %ax, dap_lba_reloc+6

	movb  boot_drive_reloc, %dl
	movw  $dap_reloc, %si
	movb  $0x42, %ah
	int   $0x13
	jnc   boot_vbr

	movw  $msg_disk_error_reloc, %si
	call  print_string
	jmp   halt

boot_vbr:
	ljmp  $0x0000, $0x7c00

print_string:
	lodsb
	testb %al, %al
	je    print_done
	movb  $0x0e, %ah
	int   $0x10
	jmp   print_string

print_done:
	ret

halt:
	hlt
	jmp   halt

boot_drive:
	.byte 0

	.align 2
dap:
	.byte 16			# DAP size
	.byte 0			# reserved
	.word 1			# sectors to read
	.word 0x7c00		# target offset
	.word 0x0000		# target segment
dap_lba:
	.word 0, 0, 0, 0	# 64-bit starting LBA

msg_no_active:
	.asciz "No active partition"

msg_disk_error:
	.asciz "Disk read error"

	.set relocated_start_rebased, relocated_start - _start + RELOC_BASE
	.set boot_drive_reloc, boot_drive - _start + RELOC_BASE
	.set dap_reloc, dap - _start + RELOC_BASE
	.set dap_lba_reloc, dap_lba - _start + RELOC_BASE
	.set msg_no_active_reloc, msg_no_active - _start + RELOC_BASE
	.set msg_disk_error_reloc, msg_disk_error - _start + RELOC_BASE
