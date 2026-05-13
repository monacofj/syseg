;;; SPDX-FileCopyrightText: 2026 Monaco F. J. <https://github.com/monacofj>
;;;
;;; SPDX-License-Identifier: GPL-3.0-or-later
;;;
;;; This file is part of SYSeg (https://github.com/monacofj/syseg)


	;; Segment registers canonicalization
	
	bits 16     
              
        org ORG	           ; Defined in the command line.

        xor ax, ax         ; Data segments as 0000
        mov ds, ax
        mov es, ax
        cli
        mov ss, ax          ; Stack as 0000:7c00
        mov sp, 0x7c00
        sti
	jmp 0x0000:start    ; CS:IP as 0000:start
start:                     

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

msg:                                
        db 'Hello World', 0x0
        
        times 510 - ($-$$) db 0     
        dw 0xaa55     

	;; Note: In these and following examples, we're avoinding the need to
	;; write  3 versions of the code for each case: bin, floppy and disk.
	;; Instead, we pass ORG in the command line.
