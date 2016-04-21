/* Abstract: Hook functions for SBS25x0 Broadcast Memory board
 *
 * Copyright 1996-2004 The MathWorks, Inc.
 */
/* $Revision: 1.1.6.2 $ $Date: 2004/04/08 21:01:22 $ */

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
#define VENDOR_ID                 (uint16_T)(0x108A) 

#define CSR_BT_REG_CTRL          (*((volatile uint8_T *)(csr_base_address+0x00)))
#define CSR_BT_REG_IRQ           (*((volatile uint8_T *)(csr_base_address+0x01)))
#define CSR_BT_REG_MEM_SIZE      (*((volatile uint8_T *)(csr_base_address+0x02)))
#define CSR_BT_REG_RESET         (*((volatile uint8_T *)(csr_base_address+0x03)))
#define CSR_BT_REG_WRIRQ         (*((volatile uint32_T *)(csr_base_address+0x04)))
#define CSR_BT_REG_TRANS_RX_ERR  (*((volatile uint8_T *)(csr_base_address+0x20)))
#define CSR_BT_REG_LINK_STATUS   (*((volatile uint8_T *)(csr_base_address+0x24)))
#define CSR_BT_REG_TX_ERR        (*((volatile uint8_T *)(csr_base_address+0x28)))
#define CSR_BT_REG_LINK_ID       (*((volatile uint8_T *)(csr_base_address+0x2C)))

#include <conio.h>
#include "tmwtypes.h"

void __cdecl xpcsbs25x0prehook(PCIDeviceInfo *pci);
void __cdecl xpcsbs25x0start(int vendor_id, int device_id, int slot);
void __cdecl xpcsbs25x0stop( int vendor_id, int device_id, int slot);

// Pre hook is called for each interrupt and should
// clear the interrupt.  This is called while interrupts are disabled
//
void __cdecl xpcsbs25x0prehook(PCIDeviceInfo *ppci) {

   volatile uint8_T *csr_base_address = (volatile uint8_T *)(ppci->BaseAddress[0] & 0xFFFFFFF0);
   /* uint32_T reg32_wrirq;
    do {
       reg32_wrirq = CSR_BT_REG_WRIRQ;  // Clear out WIR Interrupts
    } while (!(reg32_wrirq & 0x01));
    */
    // Clear all other interupts sources
   
      CSR_BT_REG_IRQ = 0x01;
      CSR_BT_REG_IRQ = 0x01;
      CSR_BT_REG_IRQ = 0x10;
      CSR_BT_REG_IRQ = 0x08;

      // clear status
      CSR_BT_REG_LINK_STATUS= 0x20;
      CSR_BT_REG_LINK_STATUS= 0x10;
      CSR_BT_REG_LINK_STATUS= 0x08;
      CSR_BT_REG_LINK_STATUS= 0x04;
      CSR_BT_REG_LINK_STATUS= 0x02;
     

    return;
}
 
// this is called at mdlStart time to configure the interrupt
// Note specific interrupt souce must have been defined in
//  the init block.  This simply enables the interrupt bit
void __cdecl xpcsbs25x0start(int vendor_id, int device_id, int slot) {
    PCIDeviceInfo pci;
    volatile uint8_T *csr_base_address ;  // Base Address 2 (define as byte-wide to simplify offset 
   uint32_T reg32_wrirq;

#include "pci_xpcimport.c"

    if (slot == -1) {
        // look for the PCI-Device
		  if (rl32eGetPCIInfo(VENDOR_ID,0x100,&pci)) {
			  if (rl32eGetPCIInfo(VENDOR_ID,0x101,&pci)) {
				  if (rl32eGetPCIInfo(VENDOR_ID,0x102,&pci)) {
					  if (rl32eGetPCIInfo(VENDOR_ID,0x103,&pci)) {
              printf("Interrupt source - SBS Tech 25x0 board not present");
						  return;
					  }
				  }
			  }
		  }
    } else {
      // look for the PCI-Device
      if (rl32eGetPCIInfoAtSlot(VENDOR_ID,0x100,slot,&pci)) {
	      if (rl32eGetPCIInfoAtSlot(VENDOR_ID,0x101,slot,&pci)) {
          if (rl32eGetPCIInfoAtSlot(VENDOR_ID,0x102,slot,&pci)) {
            if (rl32eGetPCIInfoAtSlot(VENDOR_ID,0x103,slot,&pci)) {
                printf("Interrupt source - SBS Tech 25x0 board (slot %d): not present", slot );
                return;
            }
          }
        }
      }
    }
   csr_base_address = (volatile uint8_T *)(pci.BaseAddress[0] & 0xFFFFFFF0);

    _asm { cli };
    // Clear all outstanding interrupts;

    do {
       reg32_wrirq = CSR_BT_REG_WRIRQ;  // Clear out any pending WIR Interrupts
    } while (!(reg32_wrirq & 0x01));
    // Clear all other interupts sources
   
    CSR_BT_REG_IRQ = 0x01;
    CSR_BT_REG_IRQ = 0x01;
    CSR_BT_REG_IRQ = 0x10;
    CSR_BT_REG_IRQ = 0x08;

    CSR_BT_REG_LINK_STATUS= 0x20;
    CSR_BT_REG_LINK_STATUS= 0x10;
    CSR_BT_REG_LINK_STATUS= 0x08;
    CSR_BT_REG_LINK_STATUS= 0x04;
    CSR_BT_REG_LINK_STATUS= 0x02;


    CSR_BT_REG_CTRL |= 0x08;  // Enable WRI Interrupts

    _asm { sti };


    return;
}

void __cdecl xpcsbs25x0stop(int vendor_id, int device_id, int slot) {
   PCIDeviceInfo pci;
    volatile uint8_T *csr_base_address ;  // Base Address 2 (define as byte-wide to simplify offset 
   uint32_T reg32_wrirq;
#include "pci_xpcimport.c"

    if (slot == -1) {
        // look for the PCI-Device
		  if (rl32eGetPCIInfo(VENDOR_ID,0x100,&pci)) {
			  if (rl32eGetPCIInfo(VENDOR_ID,0x101,&pci)) {
				  if (rl32eGetPCIInfo(VENDOR_ID,0x102,&pci)) {
					  if (rl32eGetPCIInfo(VENDOR_ID,0x103,&pci)) {
              printf("Interrupt source - SBS Tech 25x0 board not present");
						  return;
					  }
				  }
			  }
		  }
    } else {
      // look for the PCI-Device
      if (rl32eGetPCIInfoAtSlot(VENDOR_ID,0x100,slot,&pci)) {
	      if (rl32eGetPCIInfoAtSlot(VENDOR_ID,0x101,slot,&pci)) {
          if (rl32eGetPCIInfoAtSlot(VENDOR_ID,0x102,slot,&pci)) {
            if (rl32eGetPCIInfoAtSlot(VENDOR_ID,0x103,slot,&pci)) {
                printf("Interrupt source - SBS Tech 25x0 board (slot %d): not present", slot );
                return;
            }
          }
        }
      }
    }
    csr_base_address = (volatile uint8_T *)(pci.BaseAddress[0] & 0xFFFFFFF0);


    _asm { cli };
     CSR_BT_REG_CTRL &= 0xF7;  // Disable WRI Interrupts
    _asm { sti };
    CSR_BT_REG_IRQ = 0x01;
    CSR_BT_REG_IRQ = 0x01;
    CSR_BT_REG_IRQ = 0x10;
    CSR_BT_REG_IRQ = 0x08;

    CSR_BT_REG_LINK_STATUS= 0x20;
    CSR_BT_REG_LINK_STATUS= 0x10;
    CSR_BT_REG_LINK_STATUS= 0x08;
    CSR_BT_REG_LINK_STATUS= 0x04;
    CSR_BT_REG_LINK_STATUS= 0x02;

    return;
}

#endif /* __XPCVMIC5565HOOKS_C__ */
