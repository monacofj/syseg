#!/bin/sh

# SPDX-FileCopyrightText: 2021 Monaco F. J <https://github.com/monacofj>
#
# SPDX-License-Identifier: GPL-3.0-or-later

# Check for programs.
check_cmd() {
    CHECK_CMD_FOUND=''

    printf 'Checking for %s ...' "$1"

    for cmd in "$@"; do
        if command -v "$cmd" >/dev/null 2>&1; then
            CHECK_CMD_FOUND=$cmd
            break
        fi
    done

    if [ -z "$CHECK_CMD_FOUND" ]; then
        printf ' no\n\n'
        printf 'SYSeg: *** required tool not found: ' >&2
        sep=''
        for cmd in "$@"; do
            printf '%s%s' "$sep" "$cmd" >&2
            sep=' or '
        done
        printf '\n' >&2
        exit 1
    fi

    printf ' yes'
    if [ "$CHECK_CMD_FOUND" != "$1" ]; then
        printf ' (%s)' "$CHECK_CMD_FOUND"
    fi
    printf '\n'
}

# Move to the directory where the script itself lives.
srcdir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd) || {
    printf "SYSeg: *** cannot determine script directory.\n" >&2
    exit 1
}
cd "$srcdir" || {
    printf "SYSeg: *** cannot cd to %s.\n" "$srcdir" >&2
    exit 1
}

# Core tools needed to bootstrap the development environment.
check_cmd autoreconf
check_cmd autoconf
check_cmd automake
check_cmd autoheader
check_cmd aclocal
check_cmd m4
check_cmd perl
check_cmd libtoolize glibtoolize


# Autoreconf

autoreconf --install --verbose
