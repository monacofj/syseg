/*
 *    SPDX-FileCopyrightText: 2021 Monaco F. J. <https://github.com/monacofj>
 *   
 *    SPDX-License-Identifier: GPL-3.0-or-later
 *
 *    This file is part of SYSeg, available at https://gitlab.com/monaco/syseg.
 */

/* Behold the original K&R example, as it appeared in 1978's "The C Programming
   Language". All in small caps, with comma, and a trailing newline;
   no exclamation mark!

   It was accepted by the compiler of the time even without `#include
   <stdio.h>`, because undeclared functions were treated as implicitly
   returning `int`, so `printf()` was allowed without a prototype. The old
   compiler also accepted `main()` without an explicit return type, and it
   tolerated falling off the end of `main` without writing `return 0;`.
   */

main()
{
  printf ("hello, world!\n");
}
