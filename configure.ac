#                                               -*- Autoconf -*-
# SPDX-FileCopyrightText: 2021 Monaco F. J. <https://github.com/monacofj>
#
# SPDX-License-Identifier: GPL-3.0-or-later

# Process this file with autoconf to produce a configure script.

##
## Autotools setup
##

AC_PREREQ([2.71])
AC_INIT([SYSeg], [0.2.0], [monaco@.usp.br])
AC_CONFIG_SRCDIR([docs/syseg.md])
AC_CONFIG_HEADERS([config.h])
AC_CONFIG_MACRO_DIR([m4])
AM_INIT_AUTOMAKE([1.16.5 -Wall foreign subdir-objects])

##
## Checks for programs.
##

AC_PROG_CC

##
## Init libtool
##

LT_INIT

##
## Propagate variables
##

AC_SUBST([TEMPFILES], ["*~ *.tmp"])

# We need this because tools/*.mk and build.mk must be opaque to Autotools,
# as manual build rules and auxiliary explicitly rely on GNU Automake.

AC_SUBST([TOOLS_PATH], ['$(top_srcdir)/tools'])
AC_SUBST([MANUAL_BUILD_RULES], [build.mk])
SYSEG_MISSING_TOOLS=

##
## Checks for programs/tools
##

SYSEG_CHECK_PROGRAM([xorriso], [XORRISO])
SYSEG_CHECK_PROGRAM([objdump], [OBJDUMP])
SYSEG_CHECK_PROGRAM([objcopy], [OBJCOPY])
SYSEG_CHECK_PROGRAM([readelf], [READELF])
SYSEG_CHECK_PROGRAM([hexdump], [HEXDUMP])
SYSEG_CHECK_PROGRAM([nasm],    [NASM])
SYSEG_CHECK_PROGRAM([mkfs.fat], [MKFS_FAT])
SYSEG_CHECK_PROGRAM([parted],   [PARTED])
SYSEG_CHECK_PROGRAM([mmd], [MMD])
SYSEG_CHECK_PROGRAM([mcopy], [MCOPY])
SYSEG_CHECK_PROGRAM([qemu-system-i386], [QEMU_32])
SYSEG_CHECK_PROGRAM([qemu-system-x86_64], [QEMU_64])

SYSEG_TOOL_PATH_FROM_VAR([CC], [SYSEG_CC])
SYSEG_TOOL_PATH_FROM_VAR([AS], [SYSEG_AS])
SYSEG_TOOL_PATH_FROM_VAR([LD], [SYSEG_LD])

SYSEG_CHECK_ISOHYBRID_MBR

##
## Checks for libraries.
##

##
## Checks for header files.
##

##
## Checks for typedefs, structures, and compiler characteristics.
##

##
## Checks for library functions.
##

AC_CONFIG_FILES(
	Makefile

	tools/Makefile
	tools/config.mk
	tools/getsysinfo

	eg/Makefile
	eg/hello/Makefile
)

AC_OUTPUT

chmod +x tools/getsysinfo

rm -f syseg.log
if test -n "$SYSEG_MISSING_TOOLS"; then
	cat > syseg.log <<'_SYSEG_EOF'
log_note
_SYSEG_EOF
	for tool in $SYSEG_MISSING_TOOLS; do
		echo "- $tool" >> syseg.log
	done
	AC_MSG_NOTICE([Some optional dependencies were not found. Details were written to ./syseg.log])
	AC_MSG_NOTICE([Dumping ./syseg.log:])
	cat syseg.log
fi
