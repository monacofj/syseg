;;; SPDX-FileCopyrightText: 2026 Monaco F. J. <https://github.com/monacofj>
;;;
;;; SPDX-License-Identifier: GPL-3.0-or-later
;;;
;;; This file is part of SYSeg (https://github.com/monacofj/syseg)

        ;; This code snippet is meant to be included by some examples to
        ;; prepare the execution environment. This kind of code is often
        ;; referred to as a runtime initializer, runtime zero, or rt0.
	
	;; Canonicalization of the real-mode execution state.
	
	xor ax, ax          
        mov ds, ax          ; Data segemnts as 0000
        mov es, ax
        cli		    
        mov ss, ax          ; Stack starts at 0000:7c00
        mov sp, 0x7c00
        sti
	jmp 0x0000:start    ; CS:IP as 0000:start
start:                     
