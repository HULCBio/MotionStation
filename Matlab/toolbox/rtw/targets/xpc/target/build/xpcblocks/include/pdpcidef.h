/* $Revision: 1.1.6.1 $ */

//=======================================================================
//
// NAME:    pdpcidef.h
//
//
// DESCRIPTION:
//
//          Definitions for PowerDAQ Firmware PCI interface.
//
// NOTES:
//
// AUTHOR:  Boris Shajenko
//
// DATE:    20-MAR-97
//
// REV:     0.5
//
// R DATE:  01-JUN-98
//
// HISTORY:
//
//      Rev 0.1,    20-MAR-97,  B.S.,   Initial version.
//      Rev 0.2,     2-JUN-97,  B.S.,   Renamed from pci16def.h.
//      Rev 0.3,    16-JUN-97,  B.S.,   Moved Commands to pdfw_def.h.
//      Rev 0.4,    17-JAN-98,  B.S.,   Rearranged PCI defs.
//      Rev 0.5,    01-JUN-98,  B.S.,   Reorganized status/event handling.
//
//
//-----------------------------------------------------------------------
//
//      Copyright (C) 1997, 1998 United Electronic Industries, Inc.
//      All rights reserved.
//      United Electronic Industries Confidential Information.
//
//=======================================================================

#ifndef _INC_PDFWPCIDEF
#define _INC_PDFWPCIDEF

// Motorola DSP56301 PCI Registers.
//---------------------------------

//-----------------------------------------------------------------------
// DSP PCI interface register ULONG offsets in PCI Memory Address Space:
//-----------------------------------------------------------------------
#define DSP_HCTR    0x0004      // DSP PCI Host Control Register
#define DSP_HSTR    0x0005      // DSP PCI Host Status Register
#define DSP_HCVR    0x0006      // DSP PCI Host Command Vector Register
#define DSP_HTXR    0x0007      // DSP PCI Host Transmit Data FIFO
#define DSP_HRXS    0x0007      // DSP PCI Host Slave Receive Data FIFO

//-----------------------------------------------------------------------
// Register Byte Offsets in PCI Memory Address Space:
//-----------------------------------------------------------------------
#define PCI_HCTR    0x0010      // PCI Host Interface Control Reg
#define PCI_HSTR    0x0014      // PCI Host Interface Status Reg
#define PCI_HCVR    0x0018      // PCI Host Command Vector Reg
#define PCI_HTXR    0x001c      // PCI Host Transmit Data FIFO
#define PCI_HRXS    0x001c      // PCI Host Slave Receive Data FIFO

//-----------------------------------------------------------------------
// Register Byte Offsets in PCI Configuration Address Space:
//-----------------------------------------------------------------------
#define PCI_CDID    0x0000      // PCI Host Device ID/Vendor ID Config Reg
#define PCI_CSTR    0x0004      // PCI Host Status Config Reg
#define PCI_CCMR    0x0004      // PCI Host Command Config Reg
#define PCI_CCCR    0x0008      // PCI Host Class Code/Revision ID Config Reg
#define PCI_CLAT    0x000c      // PCI Host Header Type/Latency Timer Config
#define PCI_CBMA    0x0010      // PCI Host Memory Space Base Adrs Config
#define PCI_CSID    0x002c      // PCI Host Subsystem ID/Subvendor ID
#define PCI_CILP    0x003c      // PCI Host Intr Line-Intr Pin Config Reg

// PCI HI32 Control Register (HCTR) Bits:
#define HCTR_HF     0x03        // Host Flags (3 bits)
#define HCTR_SFT    0x07        // Slave Fetch Type
#define HCTR_HTF0   0x08        // Host Transmit Data Transfer Format
#define HCTR_HTF1   0x09        //  "
#define HCTR_HRF0   0x0b        // Host Receive Data Transfer Format
#define HCTR_HRF1   0x0c        //  "
#define HCTR_HS     0x0e        // Host Semaphores (3 bits)
#define HCTR_TWSD   0x13        // Target Wait State Disable

// PCI HI32 Status Register (HSTR) Bits:
#define HSTR_TRDY   0x00        // Transmitter Ready
#define HSTR_HTRQ   0x01        // Host Transmit Data Request
#define HSTR_HRRQ   0x02        // Host Receive Data Request
#define HSTR_HF     0x03        // Host Flags
#define HSTR_HINT   0x06        // Host Interrupt A
#define HSTR_HREQ   0x07        // Host Request

// PCI HI32 Host Command Vector Register (HCVR) Bits:
#define HCVR_HC     0x00        // Host Command
#define HCVR_HV     0x01        // Host Command vector
#define HCVR_HNMI   0x0f        // Host Non Maskable Interrupt

// PCI HI32 Status/Command Configuration Register (CSTR/CCMR) Bits:
#define CCMR_MSE    0x01        // Memory Space Enable
#define CCMR_BM     0x02        // Bus Master Enable
#define CCMR_PERR   0x06        // Parity Error Response
#define CCMR_WCC    0x07        // Wait Cycle Control (HW 1)
#define CCMR_SERE   0x08        // System Error Enable

#define CSTR_FBBC   0x17        // Fast Back-to-Back Capable (HW 1)
#define CSTR_DPR    0x18        // Data Parity Reported
#define CSTR_DST    0x19        // DEVSEL Timing (HW 1)
#define CSTR_STA    0x1b        // Signaled Target Abort
#define CSTR_RTA    0x1c        // Received Target Abort
#define CSTR_RMA    0x1d        // Received Master Abort
#define CSTR_SSE    0x1e        // Signaled System Error
#define CSTR_DPE    0x1f        // Detected Parity Error

// PCI HI32 Class Code/Revision ID Configuration Register (CCCR/CRID) Bits:
// (HW $048000)
#define CCCR_RID    0x00        // Revision ID (8 bits)
#define CCCR_PI     0x08        // PCI Device Program Interface (8 bits)
#define CCCR_SC     0x10        // PCI Device Sub-Class (8 bits)
#define CCCR_BC     0x18        // PCI Device Base Class (8 bits)

// PCI HI32 Header Type/Latency Timer Configuration Register (CHTY/CLAT) Bits:
#define CLAT_CLAT   0x08        // Latency Timer (High) (8 bits)
#define CLAT_CHTY   0x10        // Header Type (HW $00)

// PCI HI32 Memory Space Base Address Configuration Register (CBMA) Bits:
#define CBMA_MSI    0x00        // Memory Space Indicator (HW 0)
#define CBMA_MS     0x01        // Memory Space (2 bits) (HW 0)
#define CBMA_PF     0x03        // Pre-fetch (HW 0)
#define CBMA_PML    0x04        // Memory Base Address Low (12 bits) (HW 0)
#define CBMA_PMH    0x10        // Memory Base Address High (16 bits)

// PCI HI32 Interrupt Line - Interrupt Pin Configuration Register (CILP) Bits:
#define CILP_IL     0x00        // Interrupt Line (8 bits)
#define CILP_IP     0x08        // Interrupt Pin (8 bits) (HW $01)
#define CILP_MG     0x10        // MIN_GNT (8 bits) (HW $00)
#define CILP_ML     0x18        // MAX_LAT (8 bits) (HW $00)

#endif /* _INC_PDFWPCIDEF */

//-----------------------------------------------------------------------
// end of pdpcidef.h
