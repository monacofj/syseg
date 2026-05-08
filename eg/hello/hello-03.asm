;;; SPDX-FileCopyrightText: 2026 Monaco F. J. <https://github.com/monacofj>
;;;
;;; SPDX-License-Identifier: GPL-3.0-or-later
;;;
;;; This file is part of SYSeg (https://github.com/monacofj/syseg)

	;; This is the same program than hello-02.hex, but now
	;; NASM assembly (Intel Syntax).

	bits 16                 ; Set 16-bit mode
        
        mov ah, 0xe             ; set BIOS teletype mode

        mov al, 'H'             ; Load 'H' ascii code
        int 0x10                ; Issue BIOS interrupt
        mov al, 'e'             ; Load 'H' ascii code; 
        int 0x10                ; Issue BIOS interrupt
        mov al, 'l'             ; Load 'H' ascii code
        int 0x10                ; Issue BIOS interrupt
        mov al, 'l'             ; Load 'H' ascii code
        int 0x10                ; Issue BIOS interrupt
        mov al, 'o'             ; Load 'H' ascii code
        int 0x10                ; Issue BIOS interrupt
        mov al, ' '             ; Load ' ' ascii code
        int 0x10                ; Issue BIOS interrupt

        mov al, 'W'             ; Load 'W' ascii code
        int 0x10                ; Issue BIOS interrupt
        mov al, 'o'             ; Load 'o' ascii code
        int 0x10                ; Issue BIOS interrupt
        mov al, 'r'             ; Load 'r' ascii code
        int 0x10                ; Issue BIOS interrupt
        mov al, 'l'             ; Load 'l' ascii code
        int 0x10                ; Issue BIOS interrupt
        mov al, 'd'             ; Load 'd' ascii code
        int 0x10                ; Issue BIOS interrupt

halt:   
    	hlt			   ; Halt the machine
    	jmp halt		   ; Safeguard

       times 510 - ($-$$) db 0 ; Pad with zeros
       dw 0xaa55               ; Boot signature
