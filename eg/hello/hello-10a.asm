;;; SPDX-FileCopyrightText: 2026 Monaco F. J. <https://github.com/monacofj>
;;;
;;; SPDX-License-Identifier: GPL-3.0-or-later
;;;
;;; This file is part of SYSeg (https://github.com/monacofj/syseg)

	;; Call an external routine
	
	bits 16
	
	extern hello		; Tell the assembler that hello is not here
	
        call hello		; Call the external symbol

halt:
        hlt
        jmp halt


