# SPDX-FileCopyrightText: 2021 Monaco F. J. <https://github.com/monacofj>
#
# SPDX-License-Identifier: GPL-3.0-or-later
#
# This file is part of SYSeg (https://github.com/monacofj/syseg)

dnl Log message
m4_define([log_note],
[
Some tools were not found on your system.
----------------------------------------
Although they are not strictly required to build SYSeg, their absence may limit
your ability to explore some code examples or programming exercises that rely on
them. You may safely proceed without installing these tools. You will receive a
warning on a case-by-case basis when one of them is needed for a given example.
])


AC_DEFUN([SYSEG_CHECK_ISOHYBRID_MBR], [
	dnl Detect Syslinux isohybrid MBR template used by xorriso -isohybrid-mbr.
	AC_ARG_VAR([ISOHYBRID_MBR], [Path to Syslinux isohdpfx.bin for hybrid BIOS+UEFI ISO])
	AC_MSG_CHECKING([whether Syslinux isohybrid MBR template is available])
	if test "x$ISOHYBRID_MBR" = x; then
		for cand in \
			/usr/lib/ISOLINUX/isohdpfx.bin \
			/usr/lib/syslinux/isohdpfx.bin \
			/usr/share/syslinux/isohdpfx.bin \
			/usr/lib/syslinux/bios/isohdpfx.bin; do
			if test -f "$cand"; then
				ISOHYBRID_MBR="$cand"
				break
			fi
		done
	fi

	if test "x$ISOHYBRID_MBR" = x; then
		AC_MSG_RESULT([no])
		ISOHYBRID_MBR=require-isohdpfx.bin
		SYSEG_MISSING_TOOLS="${SYSEG_MISSING_TOOLS} isohdpfx.bin"
	else
		AC_MSG_RESULT([yes])
	fi
	AC_SUBST([ISOHYBRID_MBR])
])

AC_DEFUN([SYSEG_CHECK_PROGRAM], [
	AC_PATH_PROG([$2], [$1], [require-$1])
	if test "x$$2" = "xrequire-$1"; then
		SYSEG_MISSING_TOOLS="${SYSEG_MISSING_TOOLS} $1"
	fi
	AC_SUBST([$2])
])
