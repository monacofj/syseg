;;; SPDX-FileCopyrightText: 2026 Monaco F. J. <https://github.com/monacofj>
;;;
;;; SPDX-License-Identifier: GPL-3.0-or-later
;;;
;;; This file is part of SYSeg (https://github.com/monacofj/syseg)

        ;; Runtime initializer. Unlike rt0.asm, this is file is not meant to be
	;; included in source code format. Intead, it's meant to be assembled
	;; and linked to the main program by the linker script.
 
	bits 16
	
	section .text
	extern  STACK_BASE  ; This symbol is defined in the linker script.
	
	;; Canonicalization of the real-mode execution state.
	
	xor ax, ax          
        mov ds, ax          ; Data segemnts as 0000
        mov es, ax
        cli		    
        mov ss, ax          ; Stack starts at 0000:STACK_BASE
        mov sp, STACK_BASE  
        sti
	jmp 0x0000:start    ; CS:IP as 0000:start
start:                     
