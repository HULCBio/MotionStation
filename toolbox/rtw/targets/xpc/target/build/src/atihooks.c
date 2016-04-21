/* Abstract: Hook functions for ATI boards
 *
 * Copyright 1996-2002 The MathWorks, Inc.
 */
/* $Revision: 1.2 $ $Date: 2002/12/10 23:20:54 $ */

#ifndef __ATIHOOKS_C__
#define __ATIHOOKS_C__

#ifdef _MSC_VER                         /* Visual C/C++ */
#define OUTP _outp
#define INP  _inp
#elif defined(__WATCOMC__)              /* WATCOM C/C++ */
#define OUTP outp
#define INP  inp
#else                                   /* error out */
#define OUTP
#define INP
#endif

#include <conio.h>
#include "pci_xpcimport.h"

void __cdecl atiR5prehook(PCIDeviceInfo *pci);

/* This function is run just prior to the actual ISR (which may be the model
 * itself, or a real ISR using the async interrupt blocks). */
void __cdecl atiR5prehook(PCIDeviceInfo *pci) {
    /* code to acknowledge interrupt for ATI board */
    volatile unsigned int ClrInt;
    ClrInt = *((unsigned int *)0xCFFFC);
    return;
}
#endif /* __ATIHOOKS_C__ */
