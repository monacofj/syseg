;;; SPDX-FileCopyrightText: 2026 Monaco F. J. <https://github.com/monacofj>
;;;
;;; SPDX-License-Identifier: GPL-3.0-or-later
;;;
;;; This file is part of SYSeg (https://github.com/monacofj/syseg)

	bits 16
	
	org 0x7c00

	%include "rt0.asm"

	
        call hello


halt:
        hlt
        jmp halt

	times 510 - ($-$$) db 0
	dw 0xaa55

	;; This example is meant to illustrate a reference to a symbol defined
	;; in another source file, and discuss the theoretical problem of
	;; having unresolved symbols. However, since we are assemblying code
	;; as a flat binary, NASM errors out and doesn't even produce the output.
	;; To work it around and produce the output, need to have the symbol here.
	;; For the discussions, the actually address of the symbol does not matter.

hello:
	ret
