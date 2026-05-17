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
#    explicit return type;
#   -Wno-implicit-function-declaration: accept the call to `printf()` without
#    a prototype in scope;
#   -Wno-builtin-declaration-mismatch: avoid complaining that the implicit
#    `printf()` declaration disagrees with GCC's built-in declaration.

hello-00 : hello-00.c
	$(SYSEG_CC) -Wno-implicit-int -Wno-implicit-function-declaration -Wno-builtin-declaration-mismatch $< -o $@

# The standard, C-99 style "Hello World" program.

hello-01 : hello-01.c
	$(SYSEG_CC) $< -o $@

# A minimal machine-code implementation as boot sector payload intended to be
# loaded by the BIOS in legacy mode and executed as 8086 code in real mode.
#
# The program hex2bin, found in directory tools, simply converts the 
# hexadecimal representation of the machine code into a binary file. 

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

# An alternative to placate presumptuous BPB-overwriting BIOSes: use a true
# FAT12 media. First, create a 1.44M floppy disk image and format it. The
# formatting program will prepare the boot sector (sector 0) with a complete
# FAT12 header and the boot signature. The FAT header will include the
# leading jump instruction to bypass the BPB and lands at 0x3e. Usually, the
# formatting program will include also a small bootable program that just 
# outputs a message telling that the disk has no system to boot. We  
# overwrite this program with our own. 
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
# with hello-02-disk-csm.img. This will build a FAT32 disk image, which may be # more compatible with modern UEFI firmware. The boot program is again stored
# as the VBR payload of the single FAT32 partition. The MBR bootstrap code
# will also perform some register initialization that can sanitize the
# environment for certain BIOSes, before loading the boot program.
#
# This expedient can be used with any of the remaining example in this 
# directory. The only requirement is that the boot program must be small enough # to fit in the payload area of the VBR sector of the image: 448 bytes for a 
# FAT12 floppy (512-62-2), 420 bytes for a FAT32 disk (512-90-2).

# The same program as hello-02.hex but in NASM assembly.
#
# The recipe to build a raw binary file from an ASM source using NASK is
#
#  nasm -f bin foo.asm -o foo.bin
#
# The same recipe is used for all analogous examples that follow, by means of
# the pattern rules defined at the end of this file.

hello-03.bin : hello-03.asm
	$(NASM) -f bin $< -o $@

# An improved version of the former program, using a loop.

hello-04.bin : hello-04.asm
	$(NASM) -f bin $< -o $@

# A manual fix (workaround) for hello-04.asm

hello-05.bin : hello-05.asm
	$(NASM) -f bin $< -o $@

# The proper way to fix hello-04.asm with 'org' directive

hello-06.bin : hello-06.asm
	$(NASM) -f bin $< -o $@


# Canonicalization of segment registers

hello-07.bin : hello-07.asm	
	$(NASM) -f bin $< -DORG=0x7c00 -o $@


# Bonus: using VRAN instead of BIOS int 0x10

hello-07vram.bin : hello-07vram.asm
	$(NASM) -f bin $< -DORG=0x7c00 -o $@


# Like hello-07.asm but including rt0.asm.

hello-08.bin : hello-08.asm
	$(NASM) -f bin -DORG=0x7c00 $< -o $@


# Callable subroutine

hello-09.bin : hello-09.asm
	$(NASM) -f bin -DORG=0x7c00 $< -o $@


# Call external library.


hello-10.bin : hello-10a.o hello-10b.o hello-10-rt0.o hello-10.ld
	$(SYSEG_LD) -melf_i386 --defsym ORG=0x7c00 -T hello-10.ld hello-10a.o hello-10b.o -o $@

# Better implementation of hello-10.bin.


hello-11.bin : hello-11a.o hello-11b.o hello-11-rt0.o hello-11.ld
	$(SYSEG_LD) -melf_i386 --defsym ORG=0x7c00 -T hello-11.ld hello-11a.o hello-11b.o -o $@

##
## Auxiliary examples
##

extra-01a.bin : extra-01a.asm
	$(NASM) -f bin $< -o $@

extra-01b.bin : extra-01b.asm
	$(NASM) -f bin $< -o $@

extra-02.bin : extra-02.o extra-02.ld
	$(LD) -melf_i386 -T extra-02.ld $< -o $@

extra-02a.bin : extra-02a.o extra-02a.ld
	$(SYSEG_LD) -melf_i386 -T extra-02a.ld $< -o $@

extra-02b.bin : extra-02b.o extra-02b-rt0.o extra-02b.ld
	$(SYSEG_LD) -melf_i386 -T extra-02b.ld $< -o $@


# Temporary examples for testing the build system. 

hello-bios.bin : hello-bios.o
	ld -melf_i386 -T bin.ld $< -o $@


hello-uefi.o : hello-uefi.S
	as --64 $< -o $@
hello-uefi.efi : hello-uefi.o
	ld -m i386pep -shared -e efi_main --subsystem 10 $< -o $@	

##
## These are pattern rules to automate the build of the examples. 
##


# Pattern rules to build binary files from hex or NASM assembly source.
# The ORG variable is set to match raw, floppy and disk images.

%.bin : %.asm
	$(NASM) -f bin -DORG=$(ORG) $< -o $@

%.bin : %.hex
	$(TOOLS_PATH)/hex2bin < $< > $@

# Pattern rules to build object files.

%.o : %.asm
	$(NASM) -f elf32 $< -o $@

%.o : %.S
	$(AS) --32 $< -o $@

%.o : %.c
	$(CC) -m16 -Og $(LEAN_ASM) -c $< -o $@

# Pattern rule to link objects a binary file.

%.bin : %.o %-rt0.o %.ld
	$(SYSEG_LD) -melf_i386 --defsym ORG=$(ORG) -T $*.ld $*.o -o $@

%.bin : %a.o %b.o %-rt0.o %.ld
	$(SYSEG_LD) -melf_i386 --defsym ORG=$(ORG) -T $*.ld $*a.o $*b.o -o $@
	
##
## These rules are used by bintools to build floppy/disk variants.
##

%.bin : ORG:=0x7c00
%-floppy.bin : ORG:=0x7c3e
%-disk.bin : ORG:=0x7c5a


# Automatic variants from linked families.


%-floppy.bin : %a.o %b.o %-rt0.o %.ld
	$(SYSEG_LD) -melf_i386 --defsym ORG=$(ORG) -T $*.ld $*a.o $*b.o -o $@

%-disk.bin : %a.o %b.o %-rt0.o %.ld
	$(SYSEG_LD) -melf_i386 --defsym ORG=$(ORG) -T $*.ld $*a.o $*b.o -o $@

# Automatic variants from plain assembly source.

%-floppy.bin : %.asm
	$(NASM) -f bin -DORG=$(ORG) $< -o $@

%-disk.bin : %.asm
	$(NASM) -f bin -DORG=$(ORG) $< -o $@

# Automatic floppy/disk variants from hexadecimal source.
%-floppy.bin : %.hex
	$(TOOLS_PATH)/hex2bin < $< > $@

%-disk.bin : %.hex
	$(TOOLS_PATH)/hex2bin < $< > $@



.PHONY: manual-clean

manual-clean:
	rm -f *.o *.bin *.img *.efi *.fd *.vbr *.csm *.iso
	rm -f hello-00 hello-01
