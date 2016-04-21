/* Abstract: Hook functions for Bittware AudioPMC+ board
 *
 * Copyright 1996-2002 The MathWorks, Inc.
 */
/* $Revision: 1.2 $ $Date: 2002/12/10 23:20:53 $ */

#ifndef __XPCAUDIOPMCHOOKS_C__
#define __XPCAUDIOPMCHOOKS_C__

#include <conio.h>
#include <windows.h>
#include "pci_xpcimport.h"

// #define NULL 0

void __cdecl xpcaudpmcprehook(PCIDeviceInfo *pci);
void __cdecl xpcaudpmcstart(int vendor_id, int device_id, int slot);
void __cdecl xpcaudpmcstop(int vendor_id, int device_id, int slot);

void __cdecl xpcaudpmcprehook(PCIDeviceInfo *pci)
{
    int temp;
    int simask, sistatus;
    unsigned char mbcontents = 0;
    char *apmcaddr;

    apmcaddr = (char *)pci->BaseAddress[0];

    // read mailbox interrupt status
    temp = *(volatile char *)(apmcaddr + 0x85);
    // Clear mailbox interrupt status
    *(volatile char *)(apmcaddr + 0x85) = temp;

    // Read each mailbox once or we don't get any interrupts!
    mbcontents = *(volatile char *)(apmcaddr + 0x78);
    mbcontents = *(volatile char *)(apmcaddr + 0x79);
    mbcontents = *(volatile char *)(apmcaddr + 0x7a);
    mbcontents = *(volatile char *)(apmcaddr + 0x7b);
    return;
}

void __cdecl xpcaudpmcstart(int vendor_id, int device_id, int slot)
{
    // Enable interrupts from the board.
    PCIDeviceInfo pci;
    int temp;
    int simask, sistatus;
    unsigned char mbcontents = 0;
    char *apmcaddr;

#include "pci_xpcimport.c"
    if (slot == -1) {
        if (rl32eGetPCIInfo((unsigned short)vendor_id,
                            (unsigned short)device_id, &pci)) {
            printf("InitIRQ: Unable to find board\n");
            return;
        }
    } else {
        if (rl32eGetPCIInfoAtSlot((unsigned short)vendor_id,
                                  (unsigned short)device_id, slot, &pci)) {
            printf("InitIRQ: Unable to find board\n");
            return;
        }
    }
    _asm { cli };

    apmcaddr = (char *)pci.BaseAddress[0];
    // Set mailbox interrupt mask
    *(volatile char *)(apmcaddr + 0x8d) = 0xff;
    // read mailbox interrupt status
    temp = *(volatile char *)(apmcaddr + 0x85);
    // Clear mailbox interrupt status
    *(volatile char *)(apmcaddr + 0x85) = temp;
    // Clear SharcFIN interrupt mask
    *(volatile int *)(apmcaddr + 0x160) = 0;

    // Read each mailbox once or we don't get any interrupts!
    mbcontents = *(volatile char *)(apmcaddr + 0x78);
    mbcontents = *(volatile char *)(apmcaddr + 0x79);
    mbcontents = *(volatile char *)(apmcaddr + 0x7a);
    mbcontents = *(volatile char *)(apmcaddr + 0x7b);
    mbcontents = *(volatile char *)(apmcaddr + 0x7c);
    mbcontents = *(volatile char *)(apmcaddr + 0x7d);
    mbcontents = *(volatile char *)(apmcaddr + 0x7e);
    mbcontents = *(volatile char *)(apmcaddr + 0x7f);

    _asm { sti };
    return;
}

void __cdecl xpcaudpmcstop(int vendor_id, int device_id, int slot)
{
    // Enable interrupts from the board.
    PCIDeviceInfo pci;
    int temp;
    int simask, sistatus;
    unsigned char mbcontents = 0;
    char *apmcaddr;

#include "pci_xpcimport.c"
    if (slot == -1) {
        if (rl32eGetPCIInfo((unsigned short)vendor_id,
                            (unsigned short)device_id, &pci)) {
            printf("InitIRQ: Unable to find board\n");
            return;
        }
    } else {
        if (rl32eGetPCIInfoAtSlot((unsigned short)vendor_id,
                                  (unsigned short)device_id, slot, &pci)) {
            printf("InitIRQ: Unable to find board\n");
            return;
        }
    }

    _asm { cli };

    apmcaddr = (char *)pci.BaseAddress[0];

    // Set mailbox interrupt mask
    *(volatile char *)(apmcaddr + 0x8d) = 0x00;
    // read mailbox interrupt status
    temp = *(volatile char *)(apmcaddr + 0x85);
    // Clear mailbox interrupt status
    *(volatile char *)(apmcaddr + 0x85) = temp;
    // Clear SharcFIN interrupt mask
    *(volatile int *)(apmcaddr + 0x160) = 0;
    // Set User Interrupt mask
    *(volatile char *)(apmcaddr + 0x8f) = 0;

    // Read each mailbox once or we don't get any interrupts!
    mbcontents = *(volatile char *)(apmcaddr + 0x78);
    mbcontents = *(volatile char *)(apmcaddr + 0x79);
    mbcontents = *(volatile char *)(apmcaddr + 0x7a);
    mbcontents = *(volatile char *)(apmcaddr + 0x7b);
    mbcontents = *(volatile char *)(apmcaddr + 0x7c);
    mbcontents = *(volatile char *)(apmcaddr + 0x7d);
    mbcontents = *(volatile char *)(apmcaddr + 0x7e);
    mbcontents = *(volatile char *)(apmcaddr + 0x7f);

    _asm { sti };
//printf("end\n");
    return;
}

#endif /* __XPC6804HOOKS_C__ */
