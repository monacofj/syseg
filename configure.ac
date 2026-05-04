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

	eg/Makefile
	eg/hello/Makefile
)

AC_OUTPUT

