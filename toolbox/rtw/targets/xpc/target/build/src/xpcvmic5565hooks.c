/* Abstract: Hook functions for CAN AC2 PCI boards
 *
 * Copyright 1996-2003 The MathWorks, Inc.
 */
/* $Revision: 1.1.6.3 $ $Date: 2004/04/08 21:01:24 $ */

#ifndef __XPCVMIC5565HOOKS_C__
#define __XPCVMIC5565HOOKS_C__

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


#define RFM_BRV    (*((uint8_T *)(rfmcontrolregisters+0x00)))
#define RFM_BID    (*((uint8_T *)(rfmcontrolregisters+0x01)))
#define RFM_NID    (*((uint8_T *)(rfmcontrolregisters+0x04)))
#define RFM_LCSR1  (*((uint32_T *)(rfmcontrolregisters+0x08)))
#define RFM_LISR   (*((uint32_T *)(rfmcontrolregisters+0x10)))

#define RFM_SID1   (*((uint8_T *)(rfmcontrolregisters+0x24)))
#define RFM_SID2   (*((uint8_T *)(rfmcontrolregisters+0x2C)))
#define RFM_SID3   (*((uint8_T *)(rfmcontrolregisters+0x34)))
#define RFM_INITN  (*((uint8_T *)(rfmcontrolregisters+0x3C)))

#define RUNREG_INTCSR (*((uint32_T *)(runtimeregisters+0x68)))

#include <conio.h>
#include "tmwtypes.h"

void __cdecl xpcvmic5565prehook(PCIDeviceInfo *pci);
void __cdecl xpcvmic5565start(int vendor_id, int device_id, int slot);
void __cdecl xpcvmic5565stop( int vendor_id, int device_id, int slot);

// Pre hook is called for each interrupt and should
// clear the interrupt.  This is called while interrupts are disabled
//
void __cdecl xpcvmic5565prehook(PCIDeviceInfo *pci) {

   volatile uint8_T *rfmcontrolregisters = (void *)(pci->BaseAddress[2]);
   volatile uint8_T *runtimeregisters =(void *)(pci->BaseAddress[0]);

   uint32_T intcsr = RUNREG_INTCSR;
   uint32_T lisr = RFM_LISR;
   uint8_T dummy;

  // if( !(intcsr & 0x8000) ) {
       // (disable interrupts and exit) ??
   //    return;  // spurious interrupt 
  // }
   //check for a network interrupt
     
   if(lisr & 0x01) {
       dummy = RFM_SID1;
       RFM_SID1 = 0;  // clear ALL pending interrupts from FIFO
   }
   if(lisr & 0x02) { // Network interrupt 1
       dummy = RFM_SID2;
       RFM_SID2 = 0;  /// clear ALL pending interrupts from FIFO
   }
   if(lisr & 0x04) { // Network interrupt 1
       dummy = RFM_SID3;
       RFM_SID3 = 0;   /// clear ALL pending interrupts from FIFO
   }
   if(lisr & 0x80) { // Init interrupt 
       dummy = RFM_INITN;
       RFM_INITN = 0;   /// clear ALL pending interrupts from FIFO
   }
    return;
}
 
// this is called at mdlStart time to configure the interrupt
// Note specific interrupt souce must have been defined in
//  the init block.  This simply enables the interrupt bit
void __cdecl xpcvmic5565start(int vendor_id, int device_id, int slot) {
    PCIDeviceInfo pci;
    volatile uint8_T  *rfmcontrolregisters;  // Base Address 2 (define as byte-wide to simplify offset calculation)
    volatile uint8_T  *runtimeregisters;  // Base Address 2 (define as byte-wide to simplify offset calculation)

#include "pci_xpcimport.c"


    if (slot == -1) {
       if (rl32eGetPCIInfo((uint16_T)vendor_id, (uint16_T)device_id, &pci)) {
            printf("InitIRQ-5565: Unable to find board\n");
            return;
        }
    } else {
         if (rl32eGetPCIInfoAtSlot((uint16_T)vendor_id, (uint16_T)device_id,slot, &pci)) {
           printf("InitIRQ-5565: Unable to find board at (fixed) slot %d\n",slot);
            return;
        }
    }
    rfmcontrolregisters= (void *)(pci.BaseAddress[2]);
    runtimeregisters =(void *)(pci.BaseAddress[0]);

    _asm { cli };

    RFM_SID1 = 0;  // Clear any unscheduled network interrupts (old ones)
    RFM_SID2 = 0;
    RFM_SID3 = 0;
    RFM_INITN =0;
    RFM_LISR = 0x4000;   // Enable interrupts on board (and clear any old stuff)
   
    RUNREG_INTCSR = RUNREG_INTCSR | 0x900;  //sets bit 11 and 8 of INTCSR

    _asm { sti };


    return;
}

void __cdecl xpcvmic5565stop(int vendor_id, int device_id, int slot) {
    PCIDeviceInfo pci;
    volatile uint8_T  *rfmcontrolregisters;  // Base Address 2 (define as byte-wide to simplify offset calculation)
    volatile uint8_T  *runtimeregisters;  // Base Address 2 (define as byte-wide to simplify offset calculation)

#include "pci_xpcimport.c"

    if (slot == -1) {
        if (rl32eGetPCIInfo((uint16_T)vendor_id, (uint16_T)device_id, &pci)) {
            printf("InitIRQ: Unable to find board\n");
            return;
        }
    } else {
        if (rl32eGetPCIInfoAtSlot((uint16_T)vendor_id, (uint16_T)device_id,slot, &pci)) {
           printf("InitIRQ: Unable to find board\n");
            return;
        }
    }
    rfmcontrolregisters= (void *)(pci.BaseAddress[2]);
    runtimeregisters =(void *)(pci.BaseAddress[0]);
    _asm { cli };
    RFM_LISR = 0x0000;   // Disable interrupts on board (and clear any old stuff)
    _asm { sti };
    return;
}

#endif /* __XPCVMIC5565HOOKS_C__ */
