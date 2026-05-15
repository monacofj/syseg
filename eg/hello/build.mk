

# SPDX-FileCopyrightText: 2021 Monaco F. J. <https://github.com/monacofj>
#
# SPDX-License-Identifier: GPL-3.0-or-later
#
# This file is part of SYSeg (https://github.com/monacofj/syseg)

#LD = $(SYSEG_LD)


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

# Variation of hello-02.bin for BIOSes that may overwrite BPB fields in the
# loaded boot sector, assuming a FAT filesystem. The trick is to leave room
# where a FAT BPB would be and start the sector with a jump over that area.
# Common reports mention BIOSes overwriting offset 0x24  (the drive number in
# a FAT12 BPB), what may affect boot via USB-FDD emulation. This version spares
# room to the whole FAT12 header and jumps to offset 0x3e (62), where the
# executable code starts.

hello-02a.bin : hello-02a.hex
	$(TOOLS_PATH)/hex2bin < $< > $@

# An alternative to placate presumptuous BPB-overwritting BIOSes: use a true
# FAT12 media. First, create a 1.44M floppy disk image and format it. The
# formatting program will prepare the boot sector (sector 0) with a complete
# FAT12 header and the boot signature. The FAT header will include the
# leading instruction to bypass the BPB and lands at 0x3e. Usually, the
# program will include also a small bootable program that just outputs
# a message telling that the disk has no system to boot. We then overwrite
# this program with our own. 
#
# Try
#
# make hello-02-floppy.img
# make hello-02-floppy.img/bios
#
# If your computer happens to have a UEFI class 3 firmware, without support
# for legacy BIOS booting, you may try to build a floppy image containing
# a software implementation of a BIOS-compatible CSM, which should load the
# the program from the boot sector and run it in real-mode.
#
# Try
#
# make hello-02-floppy-csm.img
# make hello-02-floppy-csm.img/bios
# make hello-02-floppy-csm.img/uefi
#
# Then write the image to an USB flash stick and boot the hardware with it.
#
# As a last resort in the event your UEFI has trouble booting via USB-FDD,
# proceed as above but replacing the image name hello-02-floppy-csm.img 
# with hello-02-disk-csm.img

# The same program as hello-02.hex but in NASM assembly.

hello-03.bin : hello-03.asm
	$(NASM) -f bin $< -o $@

# An improved version of the former program, using a loop.

hello-04.bin : hello-04.asm
	$(NASM) -f bin $< -o $@

# A manual fix (workaround) for hello-04.asm

hello-05.bin : hello-05.asm
	$(NASM) -f bin $< -o $@

hello-05-floppy.bin : hello-05-floppy.asm
	$(NASM) -f bin $< -o $@

hello-05-disk.bin : hello-05-disk.asm
	$(NASM) -f bin $< -o $@

# The propper way to fix hello-04.asm with 'org' directive

hello-06.bin : hello-06.asm
	$(NASM) -f bin $< -o $@

hello-06-floppy.bin : hello-06-floppy.asm
	$(NASM) -f bin $< -o $@

hello-06-disk.bin : hello-06-disk.asm
	$(NASM) -f bin $< -o $@


# Canonicalization of segement registers


hello-07.bin : hello-07.asm	
	$(NASM) -f bin $< -DORG=0x7c00 -o $@

hello-07-floppy.bin : hello-07.asm	
	$(NASM) -f bin $< -DORG=0x7c3e -o $@

hello-07-disk.bin : hello-07.asm	
	$(NASM) -f bin $< -DORG=0x7c5a -o $@

# Bonus: using VRAN instead of BIOS int 0x10

hello-07vram.bin : hello-07vram.asm
	$(NASM) -f bin $< -DORG=0x7c00 -o $@

hello-07vram-floppy.bin : hello-07vram.asm
	$(NASM) -f bin $< -DORG=0x7c3e -o $@

hello-07vram-disk.bin : hello-07vram.asm
	$(NASM) -f bin $< -DORG=0x7c5a -o $@

# Like hello-07.asm but including rt0.asm.

hello-08.bin : hello-08.asm
	$(NASM) -f bin -DORG=0x7c00 $< -o $@

hello-08-floppy.bin : hello-08.asm
	$(NASM) -f bin -DORG=0x7c3e $< -o $@

hello-08-disk.bin : hello-08.asm
	$(NASM) -f bin -DORG=0x7c5a $< -o $@

# Callable subroutine

hello-09.bin : hello-09.asm
	$(NASM) -f bin -DORG=0x7c00 $< -o $@

hello-09-floppy.bin : hello-09.asm
	$(NASM) -f bin -DORG=0x7c3e $< -o $@

hello-09-disk.bin : hello-09.asm
	$(NASM) -f bin -DORG=0x7c5a $< -o $@

# Using the linker

%.o : %.asm
	$(NASM) -f elf32 $< -o $@

# Works for
#
# hello-10.bin

%.bin : %a.o %b.o %.ld rt0a.o
	$(SYSEG_LD) -melf_i386 -T $*.ld $*a.o $*b.o -o $@


##
## Auxiliary examples
##

extra-01a.bin : extra-01a.asm
	$(NASM) -f bin $< -o $@

extra-01b.bin : extra-01b.asm
	$(NASM) -f bin $< -o $@

extra-02.o : extra-02.asm
	$(NASM) -f elf32 $< -o $@

extra-02.bin : extra-02.o
	$(LD) -melf_i386 -T extra-02.ld $< -o $@

extra-02a.o : extra-02a.asm
	$(NASM) -f elf32 $< -o $@
extra-02a.bin : extra-02a.o
	$(SYSEG_LD) -melf_i386 -T extra-02a.ld $< -o $@


extra-02b.o : extra-02a.asm
	$(NASM) -f elf32 $< -o $@

extra-02b.bin : extra-02b.o rt0a.o
	$(SYSEG_LD) -melf_i386 -T extra-02b.ld $< -o $@



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

%-floppy.bin : %.bin
	cp $< $@

%-disk.bin : %.bin
	cp $< $@

%.bin : %.o
	ld -melf_i386 -T bin.ld $< -o $@


.PHONY: manual-clean

manual-clean:
	rm -f *.o *.bin *.img *.efi *.fd *.vbr *.csm *.iso
	rm -f hello-00 hello-01
