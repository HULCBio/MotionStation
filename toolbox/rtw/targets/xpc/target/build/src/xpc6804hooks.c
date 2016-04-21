/* Abstract: Hook functions for RTD DM6804 boards
 *
 * Copyright 1996-2003 The MathWorks, Inc.
 */
/* $Revision: 1.5.6.1 $ $Date: 2004/04/08 21:01:19 $ */

#ifndef __XPC6804HOOKS_C__
#define __XPC6804HOOKS_C__

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

void __cdecl xpc6804prehook(PCIDeviceInfo *pci);
void __cdecl xpc6804start(int vendor_id, int device_id, int slot);
void __cdecl xpc6804stop(int vendor_id, int device_id, int slot);

void __cdecl xpc6804prehook(PCIDeviceInfo *pci) {
    /* clear the interrupt status on the board */
    /* actual value written is irrelevant */
    OUTP((unsigned short)(pci->BaseAddress[0] + 7), 0);
    return;
}

void __cdecl xpc6804start(int vendor_id, int device_id, int slot) {
    _asm { cli };
    OUTP((unsigned short)(slot + 6), 1); /* enable interrupt generation */
    _asm { sti };
    return;
}

void __cdecl xpc6804stop(int vendor_id, int device_id, int slot) {
    _asm { cli };
    OUTP((unsigned short)(slot + 6), 0);    /* disable interrupt generation */
    _asm { sti };
    return;
}

#endif /* __XPC6804HOOKS_C__ */
