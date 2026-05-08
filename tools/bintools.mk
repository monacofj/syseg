# SPDX-FileCopyrightText: 2021 Monaco F. J.
#
# SPDX-License-Identifier: GPL-3.0-or-later
#
# This file is part of SYSeg (https://github.com/monacofj/syseg)

# This file intentionally uses GNU make extensions, including pattern rules
# with '%' and automatic variables.  Keep it opaque to Automake; see
# configure.ac and the @TOOLS_PATH@ include used by example Makefile.am files.
ifndef MAKE_VERSION
$(error This makefile requires GNU make)
endif

TOOLS_PATH = $(top_srcdir)/tools


.PHONY: FORCE
FORCE:

.DELETE_ON_ERROR:

.PRECIOUS: %.o %.bin %.vbr %.efi %.img
.PRECIOUS: %-floppy.img %-disk.img %-csm.img
.PRECIOUS: %-floppy-csm.img %-disk-csm.img

## Disassembling shortcuts
##
## Naming rules:
##
##   Targets have the form name/type, where the suffix after / selects
##   syntax, section scope, and optional forced disassembly mode.
##
##   /a or /i     AT&T or Intel syntax, loadable sections.
##   /ax or /ix   AT&T or Intel syntax, executable sections only (objdump -d).
##   /A or /I     AT&T or Intel syntax, all sections (objdump -D).
##   /aN or /iN   Same as /a or /i,   force decoding N = 16, 32, or 64 bits
##   /aNx or /iNx Same as /ax or /ix, force decoding N = 16, 32, or 64 bits.
##   /AN or /IN   Same as /A or /I,   force decoding N = 16, 32, or 64 bits.
##   .elf/...     Alias to the corresponding .o/... rule.
##
## Examples:
##
##   make foo.bin/a16   # flat binary, AT&T syntax, force 16-bit decoding
##   make foo.bin/i32   # flat binary, Intel syntax, force 32-bit decoding
##   make foo.o/a       # ELF object, AT&T syntax, loadable sections
##   make foo.o/ix      # ELF object, Intel syntax, executable sections only
##   make foo.o/A16     # ELF object, AT&T syntax, all sections, force 16-bit
##   make foo.elf/a     # alias for foo.o/a
##

LOADABLE_SECTIONS = .text .rodata .data .bss
LOADABLE = $(addprefix -j ,$(LOADABLE_SECTIONS))

#
# Disassemble a flat binary 
#

# Architectures

arch_i16 := i8086
arch_i32 := i386
arch_i64 := i386:x86-64

%.bin/i16 %.bin/i32 %.bin/i64: %.bin FORCE
	objdump -D -b binary -m $(arch_$(notdir $@)) -M intel $<

%.bin/a16 %.bin/a32 %.bin/a64: %.bin FORCE
	objdump -D -b binary -m $(arch_$(patsubst a%,i%,$(notdir $@))) $<

#
# Disassemble and ELF object / binary
#

# ELF aliases

%.elf/i: %.o/i ;
%.elf/a: %.o/a ;
%.elf/ix: %.o/ix ;
%.elf/ax: %.o/ax ;
%.elf/I: %.o/I ;
%.elf/A: %.o/A ;

%.elf/i16: %.o/i16 ;
%.elf/i32: %.o/i32 ;
%.elf/i64: %.o/i64 ;
%.elf/a16: %.o/a16 ;
%.elf/a32: %.o/a32 ;
%.elf/a64: %.o/a64 ;
%.elf/i16x: %.o/i16x ;
%.elf/i32x: %.o/i32x ;
%.elf/i64x: %.o/i64x ;
%.elf/a16x: %.o/a16x ;
%.elf/a32x: %.o/a32x ;
%.elf/a64x: %.o/a64x ;
%.elf/I16: %.o/I16 ;
%.elf/I32: %.o/I32 ;
%.elf/I64: %.o/I64 ;
%.elf/A16: %.o/A16 ;
%.elf/A32: %.o/A32 ;
%.elf/A64: %.o/A64 ;

# Disassemble loadable sections

%.o/i: %.o FORCE
	objdump -D $(LOADABLE) -M intel $<

%.o/a: %.o FORCE
	objdump -D $(LOADABLE) -M att $<

%.o/i16 %.o/i32 %.o/i64: %.o FORCE
	objdump -D $(LOADABLE) -M intel,$(arch_$(notdir $@)) $<

%.o/a16 %.o/a32 %.o/a64: %.o FORCE
	objdump -D $(LOADABLE) -M att,$(arch_$(patsubst a%,i%,$(notdir $@))) $<

# Disassemble executable sections

%.o/ix: %.o FORCE
	objdump -d -M intel $<

%.o/ax: %.o FORCE
	objdump -d -M att $<

%.o/i16x %.o/i32x %.o/i64x: %.o FORCE
	objdump -d -M intel,$(arch_$(patsubst %x,%,$(notdir $@))) $<

%.o/a16x %.o/a32x %.o/a64x: %.o FORCE
	objdump -d -M att,$(arch_$(patsubst a%x,i%,$(notdir $@))) $<

# Disassemble all sections 

%.o/I: %.o FORCE
	objdump -D -M intel $<

%.o/A: %.o FORCE
	objdump -D -M att $<

%.o/I16 %.o/I32 %.o/I64: %.o FORCE
	objdump -D -M intel,$(arch_$(subst I,i,$(notdir $@))) $<

%.o/A16 %.o/A32 %.o/A64: %.o FORCE
	objdump -D -M att,$(arch_$(subst A,i,$(notdir $@))) $<

##
## Dump hexadecimal bytes of a file
##
## Naming rules:
##
##   /hex        Hexdump using the default view for the file type.
##               For .bin, dump the whole file. For .o, dump $(LOADABLE).
##   /hexx       Hexdump executable sections only.
##   /h          Hex bytes only (middle column of hexdump -C), whole file.
##   /Hex        Hexdump the whole file, regardless of type.
##   .elf/...    Alias to the corresponding .o/... rule.
##
## Examples:
##
##   make foo.bin/hex    # flat binary, dump the whole file
##   make foo.o/hex      # ELF object, dump $(LOADABLE)
##   make foo.o/hexx     # ELF object, dump executable sections only
##   make foo.bin/h      # only hex-byte column, whole file
##   make foo.o/Hex      # raw hexdump of the whole ELF file
##   make foo.elf/hex    # alias for foo.o/hex
##

%.elf/hex: %.o/hex ;
%.elf/hexx: %.o/hexx ;

%.bin/hex: %.bin FORCE
	hexdump -C $<

%.o/hex: %.o FORCE
	@tmp=$$(mktemp /tmp/syseg-hex.XXXXXX); \
	trap 'rm -f "$$tmp"' EXIT; \
	for sec in $(LOADABLE_SECTIONS); do \
		if readelf -SW $< | awk '$$1 == "[" { print $$3 }' | grep -Fx "$$sec" >/dev/null; then \
			echo ""; \
			echo "$$sec:"; \
			rm -f "$$tmp"; \
			if objcopy --dump-section "$$sec=$$tmp" $< 2>/dev/null && [ -f "$$tmp" ]; then \
				hexdump -C "$$tmp"; \
			else \
				echo "[no contents]"; \
			fi; \
		fi; \
	done

%.o/hexx: %.o FORCE
	@tmp=$$(mktemp /tmp/syseg-hex.XXXXXX); \
	trap 'rm -f "$$tmp"' EXIT; \
	for sec in $$(readelf -SW $< | awk '$$1 == "[" && index($$(NF-3),"X") { print $$3 }'); do \
		echo ""; \
		echo "$$sec:"; \
		rm -f "$$tmp"; \
		if objcopy --dump-section "$$sec=$$tmp" $< 2>/dev/null && [ -f "$$tmp" ]; then \
			hexdump -C "$$tmp"; \
		else \
			echo "[no contents]"; \
		fi; \
	done

%/h: % FORCE
	@hexdump -v -e '16/1 "%02x " "\n"' $<

%/Hex: % FORCE
	hexdump -C $<


## 
## Prepare bootable floppy (fat12) or disk (fat32)images
##

CSM_64 ?= $(TOOLS_PATH)/csmwrapx64.efi  # Wraps a 64-bit UEFI firmware 
                                        # for legacy booting
CSM_32 ?= $(TOOLS_PATH)/csmwrapia32.efi # Wraps a 32-bit UEFI firmware 
                                        # for legacy booting

DISK_SECTORS ?= 262144        # 128 MiB disk image
FLOPPY_SECTORS ?= 2880        # 1.44 MiB floppy disk image
PART1_START ?= 2048           # Start of the first partition in sectors (1 MiB)
SECTOR_SIZE ?= 512            # Size of a sector in bytes

PART1_OFFSET := $(shell echo $$(($(PART1_START) * $(SECTOR_SIZE))))
PART1_LAST_SECTOR := $(shell echo $$(($(DISK_SECTORS) - 1)))

FAT12_VBR_PAYLOAD_SIZE := $(shell echo $$(($(SECTOR_SIZE) - 62 - 2))) 
FAT32_VBR_PAYLOAD_SIZE := $(shell echo $$(($(SECTOR_SIZE) - 90 - 2))) 

# This is an MBR bootstrap code for a FAT32 image, which loads the VBR code 
# (e.g. a bootloader) from the active partition and transferring control to it.

mbr-fat32.o : $(TOOLS_PATH)/mbr-fat32.S
	as --32 $< -o $@

mbr-fat32.bin : mbr-fat32.o $(TOOLS_PATH)/mbr-fat32.ld
	ld -melf_i386 -T $(TOOLS_PATH)/mbr-fat32.ld $< -o $@


# Build the object file as a payload for the VBR of a FAT partition.

%-fat32.vbr : %.o $(TOOLS_PATH)/vbr-fat32.ld
	ld -melf_i386 -T $(TOOLS_PATH)/vbr-fat32.ld $< -o $@

%-fat12.vbr : %.o $(TOOLS_PATH)/vbr-fat12.ld
	ld -melf_i386 -T $(TOOLS_PATH)/vbr-fat12.ld $< -o $@
	

#
# Prepare images for legacy BIOS booting..
#

# Create a FAT12 floppy disk image if we can build the payload  as an
# ELF object file (i.e. there is a rule to build %.o from the source file).  

%-floppy.img : %-fat12.vbr
	rm -f $@
	dd if=/dev/zero of=$@ bs=$(SECTOR_SIZE) count=$(FLOPPY_SECTORS)
	mkfs.fat -F12 $@
	dd if=$< of=$@ bs=1 seek=62 conv=notrunc 

# Create a FAT12 floppy disk from a binary file, if we can only build 
# the payload as a flat binary (i.e. there is a rule to build %.bin from the 
# source file, but there is no rule to build %.o) 

%-floppy.img : %.bin
	rm -f $@
	dd if=/dev/zero of=$@ bs=$(SECTOR_SIZE) count=$(FLOPPY_SECTORS)
	mkfs.fat -F12 $@
	dd if=$< of=$@ bs=1 seek=62 conv=notrunc count=$(FAT12_VBR_PAYLOAD_SIZE)

# Create a FAT32 disk image if we can build the payload  as an
# ELF object file (i.e. there is a rule to build %.o from the source file).
# The payload is stored in the VBR of the unique FAT32 partition. 

%-disk.img : %-fat32.vbr mbr-fat32.bin 
	rm -f $@
	dd if=/dev/zero of=$@ bs=$(SECTOR_SIZE) count=$(DISK_SECTORS)
	parted -s $@ mklabel msdos
	parted -s $@ unit s mkpart primary fat32 $(PART1_START) $(PART1_LAST_SECTOR)
	parted -s $@ set 1 boot on
	parted -s $@ set 1 esp on
	mkfs.fat -F32 --offset $(PART1_START) $@
	dd if=mbr-fat32.bin of=$@ bs=446 count=1 conv=notrunc
	dd if=$< of=$@ bs=1 seek=$$(($(PART1_OFFSET) + 90)) conv=notrunc


# Create a FAT32 floppy disk from a binary file, if we can only build 
# the payload as a flat binary (i.e. there is a rule to build %.bin from the 
# source file, but there is no rule to build %.o).
# The payload is stored in the VBR of the unique FAT32 partition. 

%-disk.img : %.bin mbr-fat32.bin 
	rm -f $@
	dd if=/dev/zero of=$@ bs=$(SECTOR_SIZE) count=$(DISK_SECTORS)
	parted -s $@ mklabel msdos
	parted -s $@ unit s mkpart primary fat32 $(PART1_START) $(PART1_LAST_SECTOR)
	parted -s $@ set 1 boot on
	parted -s $@ set 1 esp on
	mkfs.fat -F32 --offset $(PART1_START) $@
	dd if=mbr-fat32.bin of=$@ bs=446 count=1 conv=notrunc
	dd if=$< of=$@ bs=1 seek=$$(($(PART1_OFFSET) + 90)) conv=notrunc \
	   count=$(FAT32_VBR_PAYLOAD_SIZE)

#
# Prepare images for booting an EFI application.
#

# Create a FAT32 disk image containing the .efi file in the default 
# path for UEFI booting. The application %.efi is the payload.

%-disk.img : %.efi
	rm -f $@
	dd if=/dev/zero of=$@ bs=$(SECTOR_SIZE) count=$(DISK_SECTORS)
	parted -s $@ mklabel msdos
	parted -s $@ unit s mkpart primary fat32 $(PART1_START) $(PART1_LAST_SECTOR)
	parted -s $@ set 1 boot on
	parted -s $@ set 1 esp on
	mkfs.fat -F32 --offset $(PART1_START) $@
	mmd -i $@@@$(PART1_OFFSET) ::/EFI
	mmd -i $@@@$(PART1_OFFSET) ::/EFI/BOOT
	mcopy -i $@@@$(PART1_OFFSET) $< ::/EFI/BOOT/BOOTX64.EFI


#
# Prepare images for legacy BIOS booting from a UEFI via CSM wrapper.  
#

# Create a FAT12 floppy disk image if we can build the payload  as an
# ELF object file (i.e. there is a rule to build %.o from the source file). 
# A CSM wrapper is added to the image to allow legacy BIOS booting from a UEFI.

%-floppy-csm.img : %.bin $(CSM_64) $(CSM_32)
	rm -f $@
	dd if=/dev/zero of=$@ bs=$(SECTOR_SIZE) count=$(FLOPPY_SECTORS)
	mkfs.fat -F12 $@
	dd if=$< of=$@ bs=1 seek=62 conv=notrunc count=$(FAT12_VBR_PAYLOAD_SIZE)
	mmd -i $@@@0 ::/EFI
	mmd -i $@@@0 ::/EFI/BOOT
	mcopy -i $@@@0 $(CSM_64) ::/EFI/BOOT/BOOTX64.EFI
	mcopy -i $@@@0 $(CSM_32) ::/EFI/BOOT/BOOTIA32.EFI

# Create a FAT12 floppy disk from a binary file, if we can only build 
# the payload as a flat binary (i.e. there is a rule to build %.bin from the 
# source file, but there is no rule to build %.o).
# A CSM wrapper is added to the image to allow legacy BIOS booting from a UEFI.

%-floppy-csm.img : %-fat12.vbr
	rm -f $@
	dd if=/dev/zero of=$@ bs=$(SECTOR_SIZE) count=$(FLOPPY_SECTORS)
	mkfs.fat -F12 $@
	dd if=$< of=$@ bs=1 seek=62 conv=notrunc 
	mmd -i $@@@0 ::/EFI
	mmd -i $@@@0 ::/EFI/BOOT
	mcopy -i $@@@0 $(CSM_64) ::/EFI/BOOT/BOOTX64.EFI
	mcopy -i $@@@0 $(CSM_32) ::/EFI/BOOT/BOOTIA32.EFI

# Create a FAT32 disk image if we can build the payload  as an
# ELF object file (i.e. there is a rule to build %.o from the source file).
# The payload is stored in the VBR of the unique FAT32 partition. 
# A CSM wrapper is added to the image to allow legacy BIOS booting from a UEFI.

%-disk-csm.img : %-fat32.vbr mbr-fat32.bin $(CSM_64) $(CSM_32)
	rm -f $@
	dd if=/dev/zero of=$@ bs=$(SECTOR_SIZE) count=$(DISK_SECTORS)
	parted -s $@ mklabel msdos
	parted -s $@ unit s mkpart primary fat32 $(PART1_START) $(PART1_LAST_SECTOR)
	parted -s $@ set 1 boot on
	parted -s $@ set 1 esp on
	mkfs.fat -F32 --offset $(PART1_START) $@
	dd if=mbr-fat32.bin of=$@ bs=446 count=1 conv=notrunc
	dd if=$< of=$@ bs=1 seek=$$(($(PART1_OFFSET) + 90)) conv=notrunc
	mmd -i $@@@$(PART1_OFFSET) ::/EFI
	mmd -i $@@@$(PART1_OFFSET) ::/EFI/BOOT
	mcopy -i $@@@$(PART1_OFFSET) $(CSM_64) ::/EFI/BOOT/BOOTX64.EFI
	mcopy -i $@@@$(PART1_OFFSET) $(CSM_32) ::/EFI/BOOT/BOOTIA32.EFI

# Create a FAT32 floppy disk from a binary file, if we can only build 
# the payload as a flat binary (i.e. there is a rule to build %.bin from the 
# source file, but there is no rule to build %.o).
# The payload is stored in the VBR of the unique FAT32 partition.
# A CSM wrapper is added to the image to allow legacy BIOS booting from a UEFI. 

%-disk-csm.img : %.bin mbr-fat32.bin $(CSM_64) $(CSM_32)
	rm -f $@
	dd if=/dev/zero of=$@ bs=$(SECTOR_SIZE) count=$(DISK_SECTORS)
	parted -s $@ mklabel msdos
	parted -s $@ unit s mkpart primary fat32 $(PART1_START) $(PART1_LAST_SECTOR)
	parted -s $@ set 1 boot on
	parted -s $@ set 1 esp on
	mkfs.fat -F32 --offset $(PART1_START) $@
	dd if=mbr-fat32.bin of=$@ bs=446 count=1 conv=notrunc
	dd if=$< of=$@ bs=1 seek=$$(($(PART1_OFFSET) + 90)) conv=notrunc \
	   count=$(FAT32_VBR_PAYLOAD_SIZE)
	mmd -i $@@@$(PART1_OFFSET) ::/EFI
	mmd -i $@@@$(PART1_OFFSET) ::/EFI/BOOT
	mcopy -i $@@@$(PART1_OFFSET) $(CSM_64) ::/EFI/BOOT/BOOTX64.EFI
	mcopy -i $@@@$(PART1_OFFSET) $(CSM_32) ::/EFI/BOOT/BOOTIA32.EFI



## 
## Boot a binary file or a floppy/disk image in QEMU
##

QEMU_32 ?= qemu-system-i386   # QEMU executable for 32-bit emulation
QEMU_64 ?= qemu-system-x86_64 # QEMU executable for 64-bit emulation
OVMF_CODE ?= /usr/share/OVMF/OVMF_CODE_4M.fd # OVMF code firmware
OVMF_VARS_TEMPLATE ?= /usr/share/OVMF/OVMF_VARS_4M.fd # OVMF variables template
OVMF_VARS_LOCAL ?= ovmf-vars.fd # Local copy of OVMF variables 
MEM ?= 256M                  # Amount of memory to allocate for QEMU
SMP ?= 2                     # Number of CPU cores to allocate for QEMU

# Use this to boot an image in QEMU with BIOS legacy booting.

%/bios : %
	$(QEMU_32) \
		-drive format=raw,file=$< -boot c -net none

# Use this to boot an image in QEMU with UEFI firmware (native or CSM-wrapped).

%/uefi : %  $(OVMF_VARS_LOCAL)
	$(QEMU_64) \
		-drive if=pflash,format=raw,readonly=on,file=$(OVMF_CODE) \
		-drive if=pflash,format=raw,file=$(OVMF_VARS_LOCAL) \
		-drive format=raw,file=$< \
		-net none \
		-smp $(SMP) \
		-m $(MEM) \
		-vga std

$(OVMF_VARS_LOCAL): $(OVMF_VARS_TEMPLATE)
	cp $< $@
