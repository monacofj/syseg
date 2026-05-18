;;; SPDX-FileCopyrightText: 2026 Monaco F. J. <https://github.com/monacofj>
;;;
;;; SPDX-License-Identifier: GPL-3.0-or-later
;;;
;;; This file is part of SYSeg (https://github.com/monacofj/syseg)

	bits 16  

	org ORG
	
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
