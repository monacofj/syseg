;;; SPDX-FileCopyrightText: 2026 Monaco F. J. <https://github.com/monacofj>
;;;
;;; SPDX-License-Identifier: GPL-3.0-or-later
;;;
;;; This file is part of SYSeg (https://github.com/monacofj/syseg)

	;; Like hello-11, but using local labels
	
        bits 16

	section .text
	
	global hello		
	                        
hello:
	mov ah, 0xe
	mov si, 0x00
.loop:
	mov al, [msg + si]
	int 0x10
	cmp al, 0x0
	je .end
	add si, 0x1
	jmp .loop
.end:
    	ret

	section .rodata
	
msg:
    	db 'Hello World', 0x0
