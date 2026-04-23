

all:
	@echo "Nothing here"

## 
## This the MBR bootstrap code, which is responsible for loading the 
## VBR (booloader) and transferring control to it.
##

mbr.o : mbr.S
	as --32 $< -o $@

mbr.bin : mbr.o
	ld -melf_i386 -T mbr.ld $< -o $@


## 
## Basic configuration for image creation and QEMU execution.
##

CSM_64 ?= csmwrapx64.efi      # Wraps a 64-bit UEFI firmware for legacy booting
CSM_32 ?= csmwrapia32.efi     # Wraps a 32-bit UEFI firmware for legacy booting
DISK_SECTORS ?= 262144        # 128 MiB disk image
PART1_START ?= 2048           # Start of the first partition in sectors (1 MiB)
SECTOR_SIZE ?= 512            # Size of a sector in bytes
QEMU_32 ?= qemu-system-i386   # QEMU executable for 32-bit emulation
QEMU_64 ?= qemu-system-x86_64 # QEMU executable for 64-bit emulation
OVMF_CODE ?= /usr/share/OVMF/OVMF_CODE_4M.fd # OVMF code firmware
OVMF_VARS_TEMPLATE ?= /usr/share/OVMF/OVMF_VARS_4M.fd # OVMF variables template
OVMF_VARS_LOCAL ?= ovmf-vars.fd # Local copy of OVMF variables 
MEM ?= 256M                  # Amount of memory to allocate for QEMU
SMP ?= 2                     # Number of CPU cores to allocate for QEMU

PART1_OFFSET := $(shell echo $$(($(PART1_START) * $(SECTOR_SIZE))))
PART1_LAST_SECTOR := $(shell echo $$(($(DISK_SECTORS) - 1)))

# Don't delete intermediate files, as we may want to inspect them.

.PRECIOUS: %.bin %.efi %.img %.csm

# Conventions for file extensions:
#
# Payloads:
# hello.bin    16-bit flat binary (variants bit16, bin32, bin64)
# hello.efi	   64-bit PE/COFF executable (UEFI application)
#
# Disk images:
# hello.img    Depend on the payload; either VBR or UEFI application
# hello.csm    UEFI application wrapped in a VBR (for legacy booting)

# Example

hello-bios.o : hello-bios.S
	as --32 $< -o $@
hello-bios.vbr : hello-bios.o
	ld -melf_i386 -T vbr.ld $< -o $@
hello-bios.bin : hello-bios.o
	ld -melf_i386 -T bin.ld $< -o $@

hello.o : hello.S
	as --64 $< -o $@
hello.efi : hello.o
	ld -m i386pep -shared -e efi_main --subsystem 10 $< -o $@	


mem.o : mem.S
	as --32 $< -o $@
mem.vbr : mem.o
	ld  -melf_i386 -T vbr.ld $< -o $@ 

# Prepare a FAT32 disk image for BIOS legacy booting from VBR.

%.img : %.vbr mbr.bin
	rm -f $@
	dd if=/dev/zero of=$@ bs=$(SECTOR_SIZE) count=$(DISK_SECTORS)
	parted -s $@ mklabel msdos
	parted -s $@ unit s mkpart primary fat32 $(PART1_START) $(PART1_LAST_SECTOR)
	parted -s $@ set 1 boot on
	parted -s $@ set 1 esp on
	mkfs.fat -F32 --offset $(PART1_START) $@
	dd if=mbr.bin of=$@ bs=446 count=1 conv=notrunc
	dd if=$< of=$@ bs=1 seek=$$(($(PART1_OFFSET) + 90)) conv=notrunc

# Prepare a FAT32 disk image for UEFI booting from an EFI application.

%.img : %.efi mbr.bin 
	rm -f $@
	dd if=/dev/zero of=$@ bs=$(SECTOR_SIZE) count=$(DISK_SECTORS)
	parted -s $@ mklabel msdos
	parted -s $@ unit s mkpart primary fat32 $(PART1_START) $(PART1_LAST_SECTOR)
	parted -s $@ set 1 boot on
	parted -s $@ set 1 esp on
	mkfs.fat -F32 --offset $(PART1_START) $@
	dd if=mbr.bin of=$@ bs=446 count=1 conv=notrunc
	mmd -i $@@@$(PART1_OFFSET) ::/EFI
	mmd -i $@@@$(PART1_OFFSET) ::/EFI/BOOT
	mcopy -i $@@@$(PART1_OFFSET) $< ::/EFI/BOOT/BOOTX64.EFI


# Prepare a FAT32 disk image for legacy booting from a UEFI via CSM.  

%.csm : %.vbr mbr.bin $(CSM_64)
	rm -f $@
	dd if=/dev/zero of=$@ bs=$(SECTOR_SIZE) count=$(DISK_SECTORS)
	parted -s $@ mklabel msdos
	parted -s $@ unit s mkpart primary fat32 $(PART1_START) $(PART1_LAST_SECTOR)
	parted -s $@ set 1 boot on
	parted -s $@ set 1 esp on
	mkfs.fat -F32 --offset $(PART1_START) $@
	dd if=mbr.bin of=$@ bs=446 count=1 conv=notrunc
	dd if=$< of=$@ bs=1 seek=$$(($(PART1_OFFSET) + 90)) conv=notrunc
	mmd -i $@@@$(PART1_OFFSET) ::/EFI
	mmd -i $@@@$(PART1_OFFSET) ::/EFI/BOOT
	mcopy -i $@@@$(PART1_OFFSET) $(CSM_64) ::/EFI/BOOT/BOOTX64.EFI
	mcopy -i $@@@$(PART1_OFFSET) $(CSM_32) ::/EFI/BOOT/BOOTIA32.EFI


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

# Housekeeping.

clean:
	rm -f *.img *.o *.bin $(OVMF_VARS_LOCAL) *.vbr *.csm
