/* Abstract: Hook functions for UEI MFX boards
 *
 * Copyright 1996-2003 The MathWorks, Inc.
 */
/* $Revision: 1.1.6.1 $ $Date: 2003/09/19 22:08:46 $ */

#ifndef __XPCUEIPD2MFXHOOKS_C__
#define __XPCUEIPD2MFXHOOKS_C__

#include <conio.h>
#include <windows.h>
#include "pci_xpcimport.h"
#include "ueidefines.h"
#include "pdfw_def.h"

// #define NULL 0

void __cdecl xpcueipd2mfxprehook(PCIDeviceInfo *pci);
void __cdecl xpcueipd2mfxstart(int vendor_id, int device_id, int slot);
void __cdecl xpcueipd2mfxstop(int vendor_id, int device_id, int slot);

void __cdecl xpcueipd2mfxprehook(PCIDeviceInfo *pci)
{
    volatile int temp;
//    int simask, sistatus;
//    unsigned char mbcontents = 0;
    volatile long *ueiaddr;
    int i;
    volatile int j;

    ueiaddr = (long *)pci->BaseAddress[0];

    // Check for interrupt pending bit
    temp = *(ueiaddr + DSP_HSTR);
    if( !(temp & (1<<HSTR_HINT) ) )
    { 

        printf("Bad interrupt\n");
        return;
    }
    *(ueiaddr + DSP_HCVR) = (unsigned long)(1 | PD_BRDINTACK);
    for( i = 0 ; ; i++ )
    {
        for( j = 100 ; j ; j-- )
           ;
        temp = *(ueiaddr + DSP_HSTR);
        if( !(temp & (1<<HSTR_HINT) ) )
           break;
    }
    return;
}

void __cdecl xpcueipd2mfxstart(int vendor_id, int device_id, int slot)
{
    // Enable interrupts from the board.
    PCIDeviceInfo pci;
    volatile int temp;
    volatile long *ueiaddr;
    int i, j;

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
    //_asm { cli };

    ueiaddr = (long *)pci.BaseAddress[0];

    // Start the board.

    // Have to perform the start trigger with low level primitives
    // that take the board address, not board number.
//printf("Start\n");
    // The high level commands are:
    //pd_dsp_command(board, PD_AISTARTTRIG); 
    //return (pd_dsp_read(board) == 1) ? 1 : 0;

    *(ueiaddr + DSP_HCVR) = PD_AISTARTTRIG | 1L;
    while( *(ueiaddr + DSP_HSTR) & ( 1 << HSTR_HRRQ ) )
	;
    temp = *(ueiaddr + DSP_HRXS );

    _asm { sti };
    return;
}

void __cdecl xpcueipd2mfxstop(int vendor_id, int device_id, int slot)
{
    // Enable interrupts from the board.
    PCIDeviceInfo pci;
    volatile int temp;
//    int simask, sistatus;
//    unsigned char mbcontents = 0;
    volatile long *ueiaddr;
//    int i, j;

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

    //_asm { cli };

    ueiaddr = (long *)pci.BaseAddress[0];

    // Stop the board and disable interrupts.
    *(ueiaddr + DSP_HCVR) = PD_AISTOPTRIG | 1L;
    while( *(ueiaddr + DSP_HSTR) & ( 1 << HSTR_HRRQ ) )
	;
    temp = *(ueiaddr + DSP_HRXS );

    //_asm { sti };
//printf("stop\n");
    return;
}

#endif /* __XPCUEIPD2MFXHOOKS_C__ */
