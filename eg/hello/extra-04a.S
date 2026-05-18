# SPDX-FileCopyrightText: 2026 Monaco F. J. <https://github.com/monacofj>
#
# SPDX-License-Identifier: GPL-3.0-or-later
#
# This file is part of SYSeg (https://github.com/monacofj/syseg)

	# Call an external routine 
	
	.code16

	.section .text
	
	.extern hello		
	
        call hello		

halt:
        hlt
        jmp halt


