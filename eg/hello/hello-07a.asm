;;; SPDX-FileCopyrightText: 2026 Monaco F. J. <https://github.com/monacofj>
;;;
;;; SPDX-License-Identifier: GPL-3.0-or-later
;;;
;;; This file is part of SYSeg (https://github.com/monacofj/syseg)


	;; This program is like hello-07.asm, but suitable for a
	;; VBR payload in a FAT12 floppy or disk partition.
	;; The program starts at 0x7c00+62.

	
	bits 16     
              
        org 0x7c3e           

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

	;; Notice: this won't work for floppy or disk images.
	;; See hello-06-floppy.asm and hello-06-disk.asm.
