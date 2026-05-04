# SPDX-FileCopyrightText: 2021 Monaco F. J. <https://github.com/monacofj>
#
# SPDX-License-Identifier: GPL-3.0-or-later
#
# This file is part of SYSeg (https://github.com/monacofj/syseg)


EXPORT_FILES = README bin.ld hello-00.c hello-01.c hello-02.hex
EXPORT_TOOLS = $(PREPFILES) hex2bin

include $(TOOLS_PATH)/local.mk

EXPORT_TOOLS += $(BINTOOLS)

# Uncomment to include bintools in this example directory.

include @TOOLS_PATH@/bintools.mk

clean-local: manual-clean

LEAN_ASM = -fno-pie -fno-asynchronous-unwind-tables -fcf-protection=none -fno-ident -fno-stack-protector -fomit-frame-pointer -fno-align-functions -fno-merge-constants -fno-reorder-functions -fno-toplevel-reorder -ffreestanding -mpreferred-stack-boundary=2 -mincoming-stack-boundary=2
