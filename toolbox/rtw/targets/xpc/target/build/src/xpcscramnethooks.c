/* Abstract: Hook functions for Scramnet SC-150+ boards
 *
 * Copyright 1996-2003 The MathWorks, Inc.
 */
/* $Revision: 1.4.6.1 $ $Date: 2004/04/08 21:01:23 $ */

#ifndef __XPCSCRAMNETHOOKS_C__
#define __XPCSCRAMNETHOOKS_C__

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

#include "io_xpcimport.h"
#include "pci_xpcimport.h"

#include <conio.h>
#define CSR0                                    0x400001
#define CSR1                                    0x400080
#define CSR2                                    0x400103
#define CSR3                                    0x400182
#define CSR4                                    0x400205
#define CSR5                                    0x400284
#define CSR6                                    0x400307
#define CSR7                                    0x400386
#define CSR8                                    0x400409
#define CSR9                                    0x400488
#define CSR10                                   0x40050B
#define CSR11                                   0x40058A
#define CSR12                                   0x40060D
#define CSR13                                   0x40068C
#define CSR14                                   0x40070F
#define CSR15                                   0x40078E

typedef unsigned short uint16_T;

void __cdecl xpcscramnetprehook(PCIDeviceInfo *pci);
void __cdecl xpcscramnetstart(int, int, int);
void __cdecl xpcscramnetstop(int, int, int);

void __cdecl xpcscramnetprehook(PCIDeviceInfo *pci) {
    volatile unsigned long  *ioaddress32pci =
        (volatile unsigned long *)pci->BaseAddress[0];
    volatile unsigned short *ioaddress16    =
        (volatile unsigned short *)pci->BaseAddress[1];
    unsigned short csr4, csr5;
    unsigned long status;

    status= ioaddress32pci[0x12];
    ioaddress32pci[0x12]= status;

    csr5 = ioaddress16[CSR5];

    while ( (csr5 & 0x8000)== 0x8000) {
        csr4  = ioaddress16[CSR4];
        csr5 = ioaddress16[CSR5];
    }
    ioaddress16[CSR1]=0x0000;
    return;
}

void __cdecl xpcscramnetstart(int vendor_id, int device_id, int slot) {

    PCIDeviceInfo pci;
    volatile unsigned long  *ioaddress32pci;
    void * Physical0, * Virtual0, *Physical1, *Virtual1;
    unsigned long status;
    volatile unsigned short *ioaddress16;
    unsigned short csr4, csr5;

#include "io_xpcimport.c"
#include "pci_xpcimport.c"
    if (slot == -1) {
        if (rl32eGetPCIInfo((uint16_T)vendor_id, (uint16_T)device_id, &pci)) {
            printf("InitIRQ: Unable to find board\n");
            return;
        }
    } else {
        if (rl32eGetPCIInfoAtSlot((uint16_T)vendor_id, (uint16_T)device_id,
                                  slot, &pci)) {
            printf("InitIRQ: Unable to find board\n");
            return;
        }
    }
    Physical0=(void *)pci.BaseAddress[0];
    Virtual0 = rl32eGetDevicePtr(Physical0, 0x100, RT_PG_USERREADWRITE);
    ioaddress32pci=(void *)Physical0;

    Physical1 = (void *)pci.BaseAddress[1];
    Virtual1  = rl32eGetDevicePtr(Physical0, 0x1000000, RT_PG_USERREADWRITE);
    ioaddress16=(void *)Physical1;

    _asm { cli };
    ioaddress32pci[0x13]= 0x01060002;
    status= ioaddress32pci[0x12];
    ioaddress32pci[0x12]= status;
    csr5 = ioaddress16[CSR5];
    while ( (csr5 & 0x8000)== 0x8000) {
        csr4 = ioaddress16[CSR4];
        csr5 = ioaddress16[CSR5];
    }
    ioaddress16[CSR1]=0x0000;
    _asm { sti };
    return;
}

void __cdecl xpcscramnetstop(int vendor_id, int device_id, int slot) {
    PCIDeviceInfo pci;
    volatile unsigned long  *ioaddress32pci;
    void * Physical0, * Virtual0, *Physical1, *Virtual1;
    unsigned long status;
    volatile unsigned short *ioaddress16;
    unsigned short csr4, csr5;

#include "io_xpcimport.c"
#include "pci_xpcimport.c"
    if (slot == -1) {
        if (rl32eGetPCIInfo((uint16_T)vendor_id, (uint16_T)device_id, &pci)) {
            printf("InitIRQ: Unable to find board\n");
            return;
        }
    } else {
        if (rl32eGetPCIInfoAtSlot((uint16_T)vendor_id, (uint16_T)device_id,
                                  slot, &pci)) {
            printf("InitIRQ: Unable to find board\n");
            return;
        }
    }
    Physical0 = (void *)pci.BaseAddress[0];
    Virtual0  = rl32eGetDevicePtr(Physical0, 0x100, RT_PG_USERREADWRITE);
    ioaddress32pci = (void *)Physical0;
    Physical1 = (void *)pci.BaseAddress[1];
    Virtual1  = rl32eGetDevicePtr(Physical0, 0x1000000, RT_PG_USERREADWRITE);
    ioaddress16=(void *)Physical1;

    _asm { cli };
    ioaddress32pci[0x13]= 0x00000000;
    ioaddress16[CSR0]=0x0000;
    ioaddress16[CSR0]=0x2000;
    ioaddress16[CSR0]=0x0000;
    status= ioaddress32pci[0x12];
    ioaddress32pci[0x12]= status;
    csr5 = ioaddress16[CSR5];
    while ( (csr5 & 0x8000)== 0x8000) {
        csr4 = ioaddress16[CSR4];
        csr5 = ioaddress16[CSR5];
    }
    ioaddress16[CSR1]=0x0000;
    _asm { sti };
    return;
}

#endif /* __XPCSCRAMNETHOOKS_C__ */
