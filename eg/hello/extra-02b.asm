;;; SPDX-FileCopyrightText: 2026 Monaco F. J. <https://github.com/monacofj>
;;;
;;; SPDX-License-Identifier: GPL-3.0-or-later
;;;
;;; This file is part of SYSeg (https://github.com/monacofj/syseg)


	;; Same as extra-02.asm, but splitted in sections.
	
	bits 16     

	section .text
	
	%include "extra-02b-rt0.asm"
	
        mov ah, 0xe                 
        mov si, 0x00                
loop:                           
        mov al, [msg + si] 
        cmp al, 0x0                    
        je halt                     
        int 0x10                 
        add si, 0x1                 
        jmp loop                    

halt:
        hlt                         
        jmp halt                    

	section .rodata
	
msg:                                
        db 'Hello World', 0x0
        
