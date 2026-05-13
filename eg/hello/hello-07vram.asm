;;; SPDX-FileCopyrightText: 2026 Monaco F. J. <https://github.com/monacofj>
;;;
;;; SPDX-License-Identifier: GPL-3.0-or-later
;;;
;;; This file is part of SYSeg (https://github.com/monacofj/syseg)


	;; Using VRAM instead of BIOS int 0x10
	
	bits 16     
              
        org ORG           

        xor ax, ax         ; Data segments as 0000
        mov ds, ax
        cli
        mov ss, ax          ; Stack as 0000:7c00
        mov sp, 0x7c00
        sti
	jmp 0x0000:start    ; CS:IP as 0000:start
start:                     

	mov ax, 0xb800
	mov es, ax
	xor si, si
	mov di, 2*(80*2)
	
loop:                           
        mov al, [msg + si] 
        cmp al, 0x0                    
        je halt

	mov byte [es:di], al
	mov byte [es:di + 1], 0x2
	
        inc si
        add di, 0x2                 
        jmp loop                    

halt:
        hlt                         
        jmp halt                    

msg:                                
        db 'Hello World', 0x0
        
        times 510 - ($-$$) db 0     
        dw 0xaa55     
