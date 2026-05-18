# SPDX-FileCopyrightText: 2026 Monaco F. J. <https://github.com/monacofj>
#
# SPDX-License-Identifier: GPL-3.0-or-later
#
# This file is part of SYSeg (https://github.com/monacofj/syseg)

	# Like hello-11, but using local labels
	
        .code16

	.section .text
	
	.global hello		
	                        
hello:
	mov ah, 0xe
	mov si, 0x00
1:
	mov al, [msg + si]
	int 0x10
	cmp al, 0x0
	je 1f
	add si, 0x1
	jmp 1b
1:
    	ret

	.section .rodata
	
msg:
    	.string "Hello World"
