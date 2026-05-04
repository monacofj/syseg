/*
 * SPDX-FileCopyrightText: 2026 Monaco F. J. <https://github.com/monacofj>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * This file is part of SYSeg (https://github.com/monacofj/syseg)
 */


/* Converts hexadecimal byte values from standard input to binary bytes
   on standard output. Usage: hex2bin < input.txt > output.bin */

#include <stdio.h>
#include <stdlib.h>

int main(int argc, char **argv)
{
  char h[3];			/* Read at most two characters. */
  long val=0;			/* Numerical equivalent.        */
  char *end;			/* Non-zero if invalid input.   */

  /* Read every two bytes until end of file. */
  
  while ( fscanf (stdin, "%2s", h) != EOF )
    {

      val = strtol (h, &end, 16); /* Convert to numerical value. */
      
      if ( *end != '\0')	  /* Check for invalid input.    */
	{
	  fprintf (stderr, "Invalid input: %s", h);
	  return 1;
	}
	
      putchar (val);		/* Output numerical value. */
    }
  
  return 0;
}
