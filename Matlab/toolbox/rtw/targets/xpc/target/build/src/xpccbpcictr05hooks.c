/* Abstract: Hook functions for PCI CTR05
 *
 * Copyright 1996-2003 The MathWorks, Inc.
 */
/* $Revision: 1.7.6.1 $ $Date: 2004/04/08 21:01:21 $ */

#ifndef __XPCCBPCICTR05HOOKS_C__
#define __XPCCBPCICTR05HOOKS_C__

#ifdef _MSC_VER                         /* Visual C/C++ */
#define OUTPD _outpd
#define INPD  _inpd
#elif defined(__WATCOMC__)              /* WATCOM C/C++ */
#define OUTPD outpd
#define INPD  inpd
#else                                   /* error out */
#define OUTPD
#define INPD
#endif

#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include "pci_xpcimport.h"

#include <conio.h>

typedef unsigned short uint16_T;

void __cdecl xpccbpcictr05start(int vendor_id, int device_id, int slot);
void __cdecl xpccbpcictr05stop(int vendor_id, int device_id, int slot);
void __cdecl xpccbpcictr05prehook(PCIDeviceInfo *pci);

void __cdecl xpccbpcictr05prehook(PCIDeviceInfo *pci) {
    unsigned long  ulPortData = 0;
    unsigned short pciAdd;
    _asm { cli };
    pciAdd = pci->BaseAddress[1];
    ulPortData = INPD((uint16_T)(pciAdd + 0x4c));
    OUTPD((uint16_T)(pciAdd + 0x4c), ulPortData | 0x0400);
    _asm { sti };
    return;
}

void __cdecl xpccbpcictr05start(int vendor_id, int device_id, int slot) {
    PCIDeviceInfo pci;
    unsigned long  ulPortData = 0;
    unsigned short pciAdd;
#include "pci_xpcimport.c"
    if (slot == -1) {
        if (rl32eGetPCIInfo((uint16_T)vendor_id, 
                            (uint16_T)device_id, &pci)) {
            printf("InitIRQ: Unable to find board\n");
            return;
        }
    } else {
        if (rl32eGetPCIInfoAtSlot((uint16_T)vendor_id,
                                  (uint16_T)device_id, slot, &pci)) {
            printf("InitIRQ: Unable to find board\n");
            return;
        }
    }
    _asm { cli };
    pciAdd = pci.BaseAddress[1];
    ulPortData = INPD((uint16_T)(pciAdd + 0x4c));
    OUTPD((uint16_T)(pciAdd + 0x4c), ulPortData | 0x143);
    _asm { sti };
    return;
}

void __cdecl xpccbpcictr05stop(int vendor_id, int device_id, int slot) {
    PCIDeviceInfo pci;
    unsigned long  ulPortData = 0;
    unsigned short pciAdd;
#include "pci_xpcimport.c"
    if (slot == -1) {
        if (rl32eGetPCIInfo((uint16_T)vendor_id,
                            (uint16_T)device_id, &pci)) {
            printf("InitIRQ: Unable to find board\n");
            return;
        }
    } else {
        if (rl32eGetPCIInfoAtSlot((uint16_T)vendor_id,
                                  (uint16_T)device_id, slot, &pci)) {
            printf("InitIRQ: Unable to find board\n");
            return;
        }
    }
    _asm { cli };
     pciAdd = pci.BaseAddress[1];
    ulPortData = INPD((uint16_T)(pciAdd + 0x4c));
    OUTPD((uint16_T)(pciAdd + 0x4c), ulPortData & ~0x143);

    _asm { sti };
    return;
}

#endif /* __XPCCANAC2HOOKS_C__ */
