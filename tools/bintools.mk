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

# Default tool dependencies, which can be overridden by environment variables
XORRISO ?= require-xorriso
OBJDUMP ?= require-objdump
OBJCOPY ?= require-objcopy
READELF ?= require-readelf
HEXDUMP ?= require-hexdump
SYSEG_AS ?= require-as
SYSEG_LD ?= require-ld
MKFS_FAT ?= require-mkfs.fat
PARTED ?= require-parted
MMD ?= require-mmd
MCOPY ?= require-mcopy
QEMU_32 ?= require-qemu-system-i386
QEMU_64 ?= require-qemu-system-x86_64
ISOHYBRID_MBR ?= require-isohdpfx.bin

-include $(top_builddir)/tools/config.mk


.PHONY: FORCE
FORCE:

.PHONY: require-%
require-%: FORCE
	@echo
	@echo "error: required dependency '$*' was not found"
	@echo "hint: install '$*' and rerun ./configure in the project root directory"
	@echo
	@exit 1

DISASM_TOOLS = $(OBJDUMP)
HEX_TOOLS = $(HEXDUMP)
ELF_HEX_TOOLS = $(READELF) $(OBJCOPY) $(HEXDUMP)
FAT12_TOOLS = $(MKFS_FAT)
FAT32_TOOLS = $(PARTED) $(MKFS_FAT)
EFI_TOOLS = $(PARTED) $(MKFS_FAT) $(MMD) $(MCOPY)
CSM_FLOPPY_TOOLS = $(MKFS_FAT) $(MMD) $(MCOPY)
CSM_DISK_TOOLS = $(PARTED) $(MKFS_FAT) $(MMD) $(MCOPY)

.DELETE_ON_ERROR:

.PRECIOUS: %.o %.bin %-floppy.bin %-disk.bin %.vbr %.efi %.img
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

%.bin/i16 %.bin/i32 %.bin/i64: %.bin FORCE $(DISASM_TOOLS)
	$(OBJDUMP) -D -b binary -m $(arch_$(notdir $@)) -M intel $<

%.bin/a16 %.bin/a32 %.bin/a64: %.bin FORCE $(DISASM_TOOLS)
	$(OBJDUMP) -D -b binary -m $(arch_$(patsubst a%,i%,$(notdir $@))) $<

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

%.o/i: %.o FORCE $(DISASM_TOOLS)
	$(OBJDUMP) -D $(LOADABLE) -M intel $<

%.o/a: %.o FORCE $(DISASM_TOOLS)
	$(OBJDUMP) -D $(LOADABLE) -M att $<

%.o/i16 %.o/i32 %.o/i64: %.o FORCE $(DISASM_TOOLS)
	$(OBJDUMP) -D $(LOADABLE) -M intel,$(arch_$(notdir $@)) $<

%.o/a16 %.o/a32 %.o/a64: %.o FORCE $(DISASM_TOOLS)
	$(OBJDUMP) -D $(LOADABLE) -M att,$(arch_$(patsubst a%,i%,$(notdir $@))) $<

# Disassemble executable sections

%.o/ix: %.o FORCE $(DISASM_TOOLS)
	$(OBJDUMP) -d -M intel $<

%.o/ax: %.o FORCE $(DISASM_TOOLS)
	$(OBJDUMP) -d -M att $<

%.o/i16x %.o/i32x %.o/i64x: %.o FORCE $(DISASM_TOOLS)
	$(OBJDUMP) -d -M intel,$(arch_$(patsubst %x,%,$(notdir $@))) $<

%.o/a16x %.o/a32x %.o/a64x: %.o FORCE $(DISASM_TOOLS)
	$(OBJDUMP) -d -M att,$(arch_$(patsubst a%x,i%,$(notdir $@))) $<

# Disassemble all sections 

%.o/I: %.o FORCE $(DISASM_TOOLS)
	$(OBJDUMP) -D -M intel $<

%.o/A: %.o FORCE $(DISASM_TOOLS)
	$(OBJDUMP) -D -M att $<

%.o/I16 %.o/I32 %.o/I64: %.o FORCE $(DISASM_TOOLS)
	$(OBJDUMP) -D -M intel,$(arch_$(subst I,i,$(notdir $@))) $<

%.o/A16 %.o/A32 %.o/A64: %.o FORCE $(DISASM_TOOLS)
	$(OBJDUMP) -D -M att,$(arch_$(subst A,i,$(notdir $@))) $<

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

%.bin/hex: %.bin FORCE $(HEX_TOOLS)
	$(HEXDUMP) -C $<

%.o/hex: %.o FORCE $(ELF_HEX_TOOLS)
	@tmp=$$(mktemp /tmp/syseg-hex.XXXXXX); \
	trap 'rm -f "$$tmp"' EXIT; \
	for sec in $(LOADABLE_SECTIONS); do \
		if $(READELF) -SW $< | awk '$$1 == "[" { print $$3 }' | grep -Fx "$$sec" >/dev/null; then \
			echo ""; \
			echo "$$sec:"; \
			rm -f "$$tmp"; \
			if $(OBJCOPY) --dump-section "$$sec=$$tmp" $< 2>/dev/null && [ -f "$$tmp" ]; then \
				$(HEXDUMP) -C "$$tmp"; \
			else \
				echo "[no contents]"; \
			fi; \
		fi; \
	done

%.o/hexx: %.o FORCE $(ELF_HEX_TOOLS)
	@tmp=$$(mktemp /tmp/syseg-hex.XXXXXX); \
	trap 'rm -f "$$tmp"' EXIT; \
	for sec in $$($(READELF) -SW $< | awk '$$1 == "[" && index($$(NF-3),"X") { print $$3 }'); do \
		echo ""; \
		echo "$$sec:"; \
		rm -f "$$tmp"; \
		if $(OBJCOPY) --dump-section "$$sec=$$tmp" $< 2>/dev/null && [ -f "$$tmp" ]; then \
			$(HEXDUMP) -C "$$tmp"; \
		else \
			echo "[no contents]"; \
		fi; \
	done

%/h: % FORCE $(HEX_TOOLS)
	@$(HEXDUMP) -v -e '16/1 "%02x " "\n"' $<

%/Hex: % FORCE $(HEX_TOOLS)
	@$(HEXDUMP) -C $<


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

mbr-fat32.o : $(TOOLS_PATH)/mbr-fat32.S $(SYSEG_AS)
	$(SYSEG_AS) --32 $< -o $@

mbr-fat32.bin : mbr-fat32.o $(TOOLS_PATH)/mbr-fat32.ld $(SYSEG_LD)
	$(SYSEG_LD) -melf_i386 -T $(TOOLS_PATH)/mbr-fat32.ld $< -o $@


# Build the object file as a payload for the VBR of a FAT partition.

%-fat32.vbr : %.o $(TOOLS_PATH)/vbr-fat32.ld $(SYSEG_LD)
	$(SYSEG_LD) -melf_i386 -T $(TOOLS_PATH)/vbr-fat32.ld $< -o $@

%-fat12.vbr : %.o $(TOOLS_PATH)/vbr-fat12.ld $(SYSEG_LD)
	$(SYSEG_LD) -melf_i386 -T $(TOOLS_PATH)/vbr-fat12.ld $< -o $@
	

#
# Prepare images for legacy BIOS booting..
#

# Create a FAT12 floppy disk image if we can build the payload  as an
# ELF object file (i.e. there is a rule to build %.o from the source file).  

%-floppy.img : %-fat12.vbr $(FAT12_TOOLS)
	rm -f $@
	dd if=/dev/zero of=$@ bs=$(SECTOR_SIZE) count=$(FLOPPY_SECTORS)
	$(MKFS_FAT) -F12 $@
	dd if=$< of=$@ bs=1 seek=62 conv=notrunc 

# Create a FAT12 floppy disk from a binary file, if we can only build 
# the payload as a flat binary (i.e. there is a rule to build %-floppy.bin
# from the source file, but there is no rule to build %.o).

%-floppy.img : %-floppy.bin $(FAT12_TOOLS)
	rm -f $@
	dd if=/dev/zero of=$@ bs=$(SECTOR_SIZE) count=$(FLOPPY_SECTORS)
	$(MKFS_FAT) -F12 $@
	dd if=$< of=$@ bs=1 seek=62 conv=notrunc count=$(FAT12_VBR_PAYLOAD_SIZE)

# Create a FAT32 disk image if we can build the payload  as an
# ELF object file (i.e. there is a rule to build %.o from the source file).
# The payload is stored in the VBR of the unique FAT32 partition. 

%-disk.img : %-fat32.vbr mbr-fat32.bin $(FAT32_TOOLS)
	rm -f $@
	dd if=/dev/zero of=$@ bs=$(SECTOR_SIZE) count=$(DISK_SECTORS)
	$(PARTED) -s $@ mklabel msdos
	$(PARTED) -s $@ unit s mkpart primary fat32 $(PART1_START) $(PART1_LAST_SECTOR)
	$(PARTED) -s $@ set 1 boot on
	$(PARTED) -s $@ set 1 esp on
	$(MKFS_FAT) -F32 --offset $(PART1_START) $@
	dd if=mbr-fat32.bin of=$@ bs=446 count=1 conv=notrunc
	dd if=$< of=$@ bs=1 seek=$$(($(PART1_OFFSET) + 90)) conv=notrunc


# Create a FAT32 floppy disk from a binary file, if we can only build 
# the payload as a flat binary (i.e. there is a rule to build %-disk.bin from
# the source file, but there is no rule to build %.o).
# The payload is stored in the VBR of the unique FAT32 partition. 

%-disk.img : %-disk.bin mbr-fat32.bin $(FAT32_TOOLS)
	rm -f $@
	dd if=/dev/zero of=$@ bs=$(SECTOR_SIZE) count=$(DISK_SECTORS)
	$(PARTED) -s $@ mklabel msdos
	$(PARTED) -s $@ unit s mkpart primary fat32 $(PART1_START) $(PART1_LAST_SECTOR)
	$(PARTED) -s $@ set 1 boot on
	$(PARTED) -s $@ set 1 esp on
	$(MKFS_FAT) -F32 --offset $(PART1_START) $@
	dd if=mbr-fat32.bin of=$@ bs=446 count=1 conv=notrunc
	dd if=$< of=$@ bs=1 seek=$$(($(PART1_OFFSET) + 90)) conv=notrunc \
	   count=$(FAT32_VBR_PAYLOAD_SIZE)

#
# Prepare images for booting an EFI application.
#

# Create a FAT32 disk image containing the .efi file in the default 
# path for UEFI booting. The application %.efi is the payload.

%-disk.img : %.efi $(EFI_TOOLS)
	rm -f $@
	dd if=/dev/zero of=$@ bs=$(SECTOR_SIZE) count=$(DISK_SECTORS)
	$(PARTED) -s $@ mklabel msdos
	$(PARTED) -s $@ unit s mkpart primary fat32 $(PART1_START) $(PART1_LAST_SECTOR)
	$(PARTED) -s $@ set 1 boot on
	$(PARTED) -s $@ set 1 esp on
	$(MKFS_FAT) -F32 --offset $(PART1_START) $@
	$(MMD) -i $@@@$(PART1_OFFSET) ::/EFI
	$(MMD) -i $@@@$(PART1_OFFSET) ::/EFI/BOOT
	$(MCOPY) -i $@@@$(PART1_OFFSET) $< ::/EFI/BOOT/BOOTX64.EFI


#
# Prepare images for legacy BIOS booting from a UEFI via CSM wrapper.  
#

# Create a FAT12 floppy disk image if we can build the payload  as an
# ELF object file (i.e. there is a rule to build %.o from the source file). 
# A CSM wrapper is added to the image to allow legacy BIOS booting from a UEFI.

%-floppy-csm.img : %-floppy.bin $(CSM_64) $(CSM_32) $(CSM_FLOPPY_TOOLS)
	rm -f $@
	dd if=/dev/zero of=$@ bs=$(SECTOR_SIZE) count=$(FLOPPY_SECTORS)
	$(MKFS_FAT) -F12 $@
	dd if=$< of=$@ bs=1 seek=62 conv=notrunc count=$(FAT12_VBR_PAYLOAD_SIZE)
	$(MMD) -i $@@@0 ::/EFI
	$(MMD) -i $@@@0 ::/EFI/BOOT
	$(MCOPY) -i $@@@0 $(CSM_64) ::/EFI/BOOT/BOOTX64.EFI
	$(MCOPY) -i $@@@0 $(CSM_32) ::/EFI/BOOT/BOOTIA32.EFI

# Create a FAT12 floppy disk from a binary file, if we can only build 
# the payload as a flat binary (i.e. there is a rule to build %-floppy.bin
# from the source file, but there is no rule to build %.o).
# A CSM wrapper is added to the image to allow legacy BIOS booting from a UEFI.

%-floppy-csm.img : %-fat12.vbr $(CSM_FLOPPY_TOOLS)
	rm -f $@
	dd if=/dev/zero of=$@ bs=$(SECTOR_SIZE) count=$(FLOPPY_SECTORS)
	$(MKFS_FAT) -F12 $@
	dd if=$< of=$@ bs=1 seek=62 conv=notrunc 
	$(MMD) -i $@@@0 ::/EFI
	$(MMD) -i $@@@0 ::/EFI/BOOT
	$(MCOPY) -i $@@@0 $(CSM_64) ::/EFI/BOOT/BOOTX64.EFI
	$(MCOPY) -i $@@@0 $(CSM_32) ::/EFI/BOOT/BOOTIA32.EFI

# Create a FAT32 disk image if we can build the payload  as an
# ELF object file (i.e. there is a rule to build %.o from the source file).
# The payload is stored in the VBR of the unique FAT32 partition. 
# A CSM wrapper is added to the image to allow legacy BIOS booting from a UEFI.

%-disk-csm.img : %-fat32.vbr mbr-fat32.bin $(CSM_64) $(CSM_32) $(CSM_DISK_TOOLS)
	rm -f $@
	dd if=/dev/zero of=$@ bs=$(SECTOR_SIZE) count=$(DISK_SECTORS)
	$(PARTED) -s $@ mklabel msdos
	$(PARTED) -s $@ unit s mkpart primary fat32 $(PART1_START) $(PART1_LAST_SECTOR)
	$(PARTED) -s $@ set 1 boot on
	$(PARTED) -s $@ set 1 esp on
	$(MKFS_FAT) -F32 --offset $(PART1_START) $@
	dd if=mbr-fat32.bin of=$@ bs=446 count=1 conv=notrunc
	dd if=$< of=$@ bs=1 seek=$$(($(PART1_OFFSET) + 90)) conv=notrunc
	$(MMD) -i $@@@$(PART1_OFFSET) ::/EFI
	$(MMD) -i $@@@$(PART1_OFFSET) ::/EFI/BOOT
	$(MCOPY) -i $@@@$(PART1_OFFSET) $(CSM_64) ::/EFI/BOOT/BOOTX64.EFI
	$(MCOPY) -i $@@@$(PART1_OFFSET) $(CSM_32) ::/EFI/BOOT/BOOTIA32.EFI

# Create a FAT32 floppy disk from a binary file, if we can only build 
# the payload as a flat binary (i.e. there is a rule to build %-disk.bin from
# the source file, but there is no rule to build %.o).
# The payload is stored in the VBR of the unique FAT32 partition.
# A CSM wrapper is added to the image to allow legacy BIOS booting from a UEFI. 

%-disk-csm.img : %-disk.bin mbr-fat32.bin $(CSM_64) $(CSM_32) $(CSM_DISK_TOOLS)
	rm -f $@
	dd if=/dev/zero of=$@ bs=$(SECTOR_SIZE) count=$(DISK_SECTORS)
	$(PARTED) -s $@ mklabel msdos
	$(PARTED) -s $@ unit s mkpart primary fat32 $(PART1_START) $(PART1_LAST_SECTOR)
	$(PARTED) -s $@ set 1 boot on
	$(PARTED) -s $@ set 1 esp on
	$(MKFS_FAT) -F32 --offset $(PART1_START) $@
	dd if=mbr-fat32.bin of=$@ bs=446 count=1 conv=notrunc
	dd if=$< of=$@ bs=1 seek=$$(($(PART1_OFFSET) + 90)) conv=notrunc \
	   count=$(FAT32_VBR_PAYLOAD_SIZE)
	$(MMD) -i $@@@$(PART1_OFFSET) ::/EFI
	$(MMD) -i $@@@$(PART1_OFFSET) ::/EFI/BOOT
	$(MCOPY) -i $@@@$(PART1_OFFSET) $(CSM_64) ::/EFI/BOOT/BOOTX64.EFI
	$(MCOPY) -i $@@@$(PART1_OFFSET) $(CSM_32) ::/EFI/BOOT/BOOTIA32.EFI


#
# Prepare hybrid ISO images for booting from CD-ROM or USB flash drive.
#

%.iso : %-floppy-csm.img $(XORRISO) $(ISOHYBRID_MBR)
	$(XORRISO) -as mkisofs -o $@ \
	  -c boot.cat \
	  -b $< -no-emul-boot -boot-load-size 4 \
	  -eltorito-alt-boot \
	  -e $< -no-emul-boot \
	  -isohybrid-mbr $(ISOHYBRID_MBR) \
	  -isohybrid-gpt-basdat \
	  ./


## 
## Boot a binary file or a floppy/disk image in QEMU
##

OVMF_CODE ?= /usr/share/OVMF/OVMF_CODE_4M.fd # OVMF code firmware
OVMF_VARS_TEMPLATE ?= /usr/share/OVMF/OVMF_VARS_4M.fd # OVMF variables template
OVMF_VARS_LOCAL ?= ovmf-vars.fd # Local copy of OVMF variables 
MEM ?= 256M                  # Amount of memory to allocate for QEMU
SMP ?= 2                     # Number of CPU cores to allocate for QEMU

# Use this to boot an image in QEMU with BIOS legacy booting.

%.iso/bios : %.iso $(QEMU_32)
	$(QEMU_32) \
		-cdrom $< -boot d -net none

%/bios : % $(QEMU_32)
	$(QEMU_32) \
		-drive format=raw,file=$< -boot c -net none

# Use this to boot an image in QEMU with UEFI firmware (native or CSM-wrapped).

%.iso/uefi : %.iso $(OVMF_VARS_LOCAL) $(QEMU_64)
	$(QEMU_64) \
		-drive if=pflash,format=raw,readonly=on,file=$(OVMF_CODE) \
		-drive if=pflash,format=raw,file=$(OVMF_VARS_LOCAL) \
		-drive media=cdrom,file=$< \
		-net none \
		-smp $(SMP) \
		-m $(MEM) \
		-vga std

%/uefi : % $(OVMF_VARS_LOCAL) $(QEMU_64)
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
