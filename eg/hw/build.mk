

# SPDX-FileCopyrightText: 2021 Monaco F. J. <https://github.com/monacofj>
#
# SPDX-License-Identifier: GPL-3.0-or-later
#
# This file is part of SYSeg (https://github.com/monacofj/syseg)

kh : kh.c
	$(CC) -Wno-implicit-int -Wno-implicit-function-declaration -Wno-builtin-declaration-mismatch $< -o $@
