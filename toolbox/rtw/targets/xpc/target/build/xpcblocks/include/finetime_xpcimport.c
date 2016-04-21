/* File:     finetime_xpcimport.c
 * Abstract: Fine time (Pentium counter) functions imported from the kernel
 *
 * Copyright 1996-2002 The MathWorks, Inc.
 */

/* $Revision: 1.1 $  $Date: 2002/04/25 14:19:14 $ */

#define GETFUNC(name) name = (void *)GetProcAddress(GetModuleHandle(NULL), \
                                            #name); \
  if (name == NULL) { \
      printf(#name " not found\n"); \
      return; \
  }

GETFUNC(xpceFTReadTime);
GETFUNC(xpceFTAdd);
GETFUNC(xpceFTSubtract);
