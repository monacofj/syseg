

# SPDX-FileCopyrightText: 2021 Monaco F. J. <https://github.com/monacofj>
#
# SPDX-License-Identifier: GPL-3.0-or-later
#
# This file is part of SYSeg (https://github.com/monacofj/syseg)


# Original Kernighan & Richie Hello World, as it appeared in 1978's book
# "The C Programming Language". To build it with GCC, we need to disable
# a few ISO-C-era diagnostics:
#
#   -Wno-implicit-int: accept the old-style `main()` declaration without an
#     explicit return type;
#   -Wno-implicit-function-declaration: accept the call to `printf()` without
#     a prototype in scope;
#   -Wno-builtin-declaration-mismatch: avoid complaining that the implicit
#     `printf()` declaration disagrees with GCC's built-in declaration.

hello-00 : hello-00.c
	$(CC) -Wno-implicit-int -Wno-implicit-function-declaration -Wno-builtin-declaration-mismatch $< -o $@

# The standard, C-99 style "Hello World" program.

hello-01 : hello-01.c
	$(CC) $< -o $@

# A minimal machine-code implementation as an MBR boot sector intended to be
# loaded by the BIOS in legacy mode and executed as 8086 code in real mode.

hello-02.bin : hello-02.hex
	$(TOOLS_PATH)/hex2bin < $< > $@




#############
hello.o : hello-bios.S
	as --32 $< -o $@

hello-bios.bin : hello-bios.o
	ld -melf_i386 -T bin.ld $< -o $@


hello-uefi.o : hello-uefi.S
	as --64 $< -o $@
hello-uefi.efi : hello-uefi.o
	ld -m i386pep -shared -e efi_main --subsystem 10 $< -o $@	

%.o : %.S
	as --32 $< -o $@

%.o : %.c
	$(CC) -m16 -Og $(LEAN_ASM) -c $< -o $@

%.bin : %.o
	ld -melf_i386 -T bin.ld $< -o $@


.PHONY: manual-clean

manual-clean:
	rm -f *.o *.bin *.img *.efi *.fd *.vbr *.csm
	rm -f hello-00 hello-01
