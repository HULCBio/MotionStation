//=======================================================================
//
// NAME:    pdfw_def.h
//
//
// DESCRIPTION:
//
//          Definitions for PowerDAQ Firmware Commands.
//
// NOTES:
//
// REV:     3.3
//
//
// HISTORY:
//
//      Rev 0.1,    16-JUN-97,  B.S.,   Initial version.
//      Rev 0.2,     7-JUL-97,  B.S.,   Updated list with new commands.
//      Rev 0.3,    17-JUL-97,  B.S.,   Added AIn commands to list.
//      Rev 0.4,    30-JUL-97,  B.S.,   Remove PCI Test Commands.
//      Rev 0.5,    30-JUL-97,  B.S.,   Added Cfg & Status bit defs.
//      Rev 0.6,     7-AUG-97,  B.S.,   Split interface test function
//                                      defs to new file pdfw_if.h.
//      Rev 0.7,    20-NOV-97,  B.S.,   Revised for new PowerDAQ FW.
//      Rev 0.8,    11-DEC-97,  B.S.,   Added CAL commands.
//      Rev 0.9,    17-JAN-98,  B.S.,   Rearranged PCI defs.
//      Rev 0.91    18-MAR-98,  A.I.,   Add changes for autocalibration.
//      Rev 0.92    08-MAY-98,  A.I.,   Add bits for buffered I/O.->replaced with new buffer
//      Rev 0.93    01-JUN-98,  B.S.,   Reorganized status/event handling.
//      Rev 0.94    15-JUL-98,  B.S.,   Added AIn DMA Block Transfer mode.
//      Rev 0.95    03-MAY-99,  A.I.,   PDII series and PDDIO support added
//      Rev 0.951   21-JUL-99,  A.I.,   SSH PGA control added, AOut buffer increased
//      Rev 0.96    22-AUG-99,  A.I.,   FW version flags added
//      Rev 0.97    13-SEP-99,  A.I.,   AO board constants added
//      Rev 0.98    12-MAR-2000,A.I.,   DSP registers r/w added along with XFer size
//      Rev 3.00    12-DEC-2000,A.I.,   Revised to rev.3.0
//      Rev 3.01    14-FEB-2002,D.K.,   Has changed bits (see AOut Subsystem Configuration (AOutCfg) Bits)
//      Rev 3.02    22-APR-2002,A.I.,   Extended DAC FIFO added, board ID fixed
//      Rev 3.03    08-MAY-2002,A.I.,   AOut bitfields corrected
//      Rev 3.07    08-MAY-2002,A.I.,   DSP WF mode - waveform is calculated by DSP on the fly
//      Rev 3.1     31-JUL-2002,A.I.,   Bus mastering implemented
//      Rev 3.2     04-DEC-2002,d.k.,   Added bit AO96_WRITEHOLDBIT (see AO 32 Subsystem Configuration (AO32) Bits)
//      Rev 3.3     06-MAR-2003,d.k.,   Added Real-time Bus Master mode for PDx-MF only
//
//
//-----------------------------------------------------------------------
//
//      Copyright (C) 1997-2000 United Electronic Industries, Inc.
//      All rights reserved.
//      United Electronic Industries Confidential Information.
//
//=======================================================================

#ifndef _INC_PDFW_DEF
#define _INC_PDFW_DEF

#include "pdpcidef.h"           // DSP56301 PCI Interface Defs

//-----------------------------------------------------------------------
// PowerDAQ PCI Definitions.
//-----------------------------------------------------------------------
#define PCI_VENDORID    0x1057  // Motorola PCI Vendor ID
#define PCI_DEVICEID    0x1801  // DSP56301 PCI Device ID
#define PCI_SUBVENID    0x54A9  // 'UEI' PCI Subsystem Vendor ID

//-----------------------------------------------------------------------
// PowerDAQ PCI Definitions.
//-----------------------------------------------------------------------
#define MOTOROLA_VENDORID   0x1057  // Motorola PCI Vendor ID
#define DSP56301_DEVICEID   0x1801  // DSP56301 PCI Device ID
#define UEI_SUBVENID        0x54A9  // 'UEI' PCI Subsystem Vendor ID
#define ADAPTER_SUBID       0x0001  // Board # 0101 PCI Subsystem ID

//---------------------------------------------------------------------------
// PowerDAQ ID information
//---------------------------------------------------------------------------
#define PD_SUBSYSTEMID_FIRST      0x101     // First valid PowerDAQ model
#define PD_SUBSYSTEMID_LAST       0x28F     // Last valid PowerDAQ model
#define ADAPTER_AUTOCAL           0x0300    // Boards with autocalibration type 1
#define PD_AIB_SELMODE0           0x01FE    // Firmware mode0 logic support

//-----------------------------------------------------------------------
// Board types
//
#define PD_IS_MFX(id)   (((id>=0x101)&&(id<=0x14A))||((id>=0x169)&&(id<=0x182)))
#define PD_IS_MF(id)    (((id>=0x111)&&(id<=0x12C))||((id>=0x16F)&&(id<=0x182)))
#define PD_IS_MFS(id)   (((id>=0x12D)&&(id<=0x14A))||((id>=0x169)&&(id<=0x16E)))
#define PD_IS_AO(id)    ((id>=0x14E)&&(id<=0x158))
#define PD_IS_DIO(id)   (((id>=0x14B)&&(id<=0x14D))||((id>=0x159)&&(id<=0x168))||((id>=0x187)&&(id<=0x18A)))
#define PDL_IS_MFX(id)  ((id>=0x183)&&(id<=0x186))
#define PDL_IS_AO(id)   ((id>=0x18B)&&(id<=0x18E))
#define PDL_IS_DIO(id)  ((id>=0x187)&&(id<=0x18A))
#define PD_IS_PDXI(id)  ((id >=0x200)&&(id<=0x2FF))

#define PD_IS_LABMF(id) ((id>=0x183)&&(id<=0x186))
#define PD_IS_LABDIO(id)((id>=0x187)&&(id<=0x18A))||PD_IS_DIO(id)
#define PD_IS_LABAO(id) ((id>=0x18B)&&(id<=0x18E))

//-----------------------------------------------------------------------
// Real-time Bus Master mode (PDx-MF only)
// In the future this mode  will be automatically enable/disable 
//-----------------------------------------------------------------------
// In this mode BM transfers are used to transfer of necessary quantity of channel list.
// The UCT2 is used for calculation of necessary quantity of channel list.
// For this it is necessary to connect Pin#36(Channel List Done Output) to Pin#2(CTR2-IN).
// See connector J2 on screw terminal STP-9616.
// In order to function properly following settings should be used: 
// -	CL clock - internal
// -	CV clock continuous or fast enough to acquire of necessary quantity of channel list of A/D data.
// -	Number of channels in the channel list: 4/8/16/32 or 64.
// -    Number of channel list to be sent (RTModeAIBM_NumOfChList)
// -	BM parameters should be tuned in accordance with information below
// For this mode you need to change the parameters (AIBM_DEFDMASIZE, AIBM_DEFBURSTS, BmFHFXFers and BmPageXFers). See below:
// -------------------------------------------------------------------------------
// Number of channels 
// in the channel list           		4	8	16	32	64
// -------------------------------------------------------------------------------                      
// Burst Size (RTModeAIBM_DEFDMASIZE)	 	3	7	15	15	15
// # Bursts per block (RTModeAIBM_DEFBURSTS)    1	1	1	2	4
// # Blocks per 1/2 FIFO (BmFHFXFers)		1	1	1	1	1
// # Blocks per page (BmPageXFers) 		1	1	1	1	1


#define RTBMMODE               0    // Set Real-time BM Mode (1-enable, 0-disable)

// Definitions for PowerDAQ driver:
#define RTModeBmFHFXFers       1//2    // # Blocks per 1/2 FIFO 
#define RTModeBmPageXFers      2//4    // # Blocks per page
#define RTModeXBMPageSz        1       // Size of page

// Definitions for firmware:
// Bit definitions in dwRtBmModeCFG
#define EnableRtBmMode         (1<<0)  // Enable Real-time BM mode
#define EnableExtraTransfer    (1<<1)  // Enable extra BM transfer
#define RTModeTransferSample   712


//-----------------------------------------------------------------------
// DSP IVECs.
//-----------------------------------------------------------------------
#define I_VEC  0x0
// Non-Maskable interrupts
// Interrupt Request Pins
#define DSP_I_IRQA   I_VEC+0x10  // IRQA 
#define DSP_I_IRQB   I_VEC+0x12  // IRQB
#define DSP_I_IRQC   I_VEC+0x14  // IRQC
#define DSP_I_IRQD   I_VEC+0x16  // IRQD
// DMA Interrupts
// Timer Interrupts
// ESSI Interrupts 
// SCI Interrupts  
// HOST Interrupts 

//-----------------------------------------------------------------------
// PowerDAQ Command IVECs.
//-----------------------------------------------------------------------
// Start of PowerDAQ Command IVEC table.
#define PCI_IVEC    0x72
#define PCI_HNMI    (PCI_IVEC|(1L<<HCVR_HNMI)) // Reset board command

// The following commands are valid only during Secondary Bootstrap:
#define PCI_LOAD    PCI_IVEC+2  // Bootstrap code/data load command
#define PCI_EXEC    PCI_IVEC+4  // Bootstrap execute code command

// PowerDAQ Board Level Command IVECs.
#define PD_BRD_BASE     PCI_IVEC+2
#define PD_BRDHRDRST    PCI_HNMI        // Board Hard Reset (HNMI Interrupt)
#define PD_BRDFWDNLD    PD_BRD_BASE     // Board Code Loader Download
#define PD_BRDSFTRST    PD_BRD_BASE+2   // Board Soft Reset
#define PD_BRDEPRMRD    PD_BRD_BASE+4   // Board SPI EEPROM Read
#define PD_BRDWRONDATE  PD_BRD_BASE+6   // Board Write First Power-On Date
#define PD_BRDINTEN     PD_BRD_BASE+8   // Board Interrupt Enable/Disable
#define PD_BRDINTACK    ((PD_BRD_BASE+10)|(1L<<HCVR_HNMI)) // Board Intr. Ack.
#define PD_BRDSTATUS    PD_BRD_BASE+12  // Board Get Board Status Words
#define PD_BRDSETEVNTS1 PD_BRD_BASE+14  // Board Set ADUEIntrStat Events
#define PD_BRDSETEVNTS2 PD_BRD_BASE+16  // Board Set AIOIntr Events
#define PD_BRDFWLOAD    PD_BRD_BASE+18  // Board Firmware Load
#define PD_BRDFWEXEC    PD_BRD_BASE+20  // Board Firmware Execute
#define PD_BRDREGWR     PD_BRD_BASE+22  // DSP Register write
#define PD_BRDREGRD     PD_BRD_BASE+24  // DSP Register read
#define PD_BRD_LAST     PD_BRDREGRD

// PowerDAQ AIn Subsystem Command IVECs.
#define PD_AIN_BASE     PD_BRD_LAST+2
#define PD_AICFG        PD_AIN_BASE     // AIn Set Configuration
#define PD_AICVCLK      PD_AIN_BASE+2   // AIn Set Conv Clock
#define PD_AICLCLK      PD_AIN_BASE+4   // AIn Set Channel List Clock
#define PD_AICHLIST     PD_AIN_BASE+6   // AIn Set Channel List
#define PD_AISETEVNT    PD_AIN_BASE+8   // AIn Set Events
#define PD_AISTATUS     PD_AIN_BASE+10  // AIn Get Status
#define PD_AICVEN       PD_AIN_BASE+12  // AIn Conv enable
#define PD_AISTARTTRIG  PD_AIN_BASE+14  // AIn Start Trigger
#define PD_AISTOPTRIG   PD_AIN_BASE+16  // AIn Stop Trigger
#define PD_AISWCVSTART  PD_AIN_BASE+18  // AIn SW Conv Start
#define PD_AISWCLSTART  PD_AIN_BASE+20  // AIn SW Ch List Start
#define PD_AICLRESET    PD_AIN_BASE+22  // AIn Reset Channel List
#define PD_AICLRDATA    PD_AIN_BASE+24  // AIn Clear Data
#define PD_AIRESET      PD_AIN_BASE+26  // AIn Reset to default
#define PD_AIGETVALUE   PD_AIN_BASE+28  // AIn Get Single Value
#define PD_AIGETSAMPLES PD_AIN_BASE+30  // AIn Get Buffered Samples
#define PD_AISETSSHGAIN PD_AIN_BASE+32  // AIn Set SSH Gain Register
#define PD_AIXFERSIZE   PD_AIN_BASE+34  // Set size for XFer (sub 1)
#define PD_AIN_LAST     PD_AIXFERSIZE

// PowerDAQ AOut Subsystem Command IVECs.
#define PD_AOUT_BASE    PD_AIN_LAST+2
#define PD_AOCFG        PD_AOUT_BASE    // AOut Set Configuration
#define PD_AOCVCLK      PD_AOUT_BASE+2  // AOut Set Conv Clock
#define PD_AOSETEVNT    PD_AOUT_BASE+4  // AOut Set Events
#define PD_AOSTATUS     PD_AOUT_BASE+6  // AOut Get Status
#define PD_AOCVEN       PD_AOUT_BASE+8  // AOut Conv Enable
#define PD_AOSTARTTRIG  PD_AOUT_BASE+10 // AOut Start Trigger
#define PD_AOSTOPTRIG   PD_AOUT_BASE+12 // AOut Stop Trigger
#define PD_AOSWCVSTART  PD_AOUT_BASE+14 // AOut SW Conv Start
#define PD_AOCLRDATA    PD_AOUT_BASE+16 // AOut Clear Data
#define PD_AORESET      PD_AOUT_BASE+18 // AOut Reset to default
#define PD_AOPUTVALUE   PD_AOUT_BASE+20 // AOut Put Single Value
#define PD_AOPUTBLOCK   PD_AOUT_BASE+22 // AOut Put Block
#define PD_AODMASET     PD_AOUT_BASE+24 // AOut DMA Set
#define PD_AOSETWAVE    PD_AOUT_BASE+26 // AOut WD Set
#define PD_AOUT_LAST    PD_AOSETWAVE

// PowerDAQ DIn Subsystem Command IVECs.
#define PD_DIN_BASE     PD_AOUT_LAST+2
#define PD_DICFG        PD_DIN_BASE     // DIn Set Configuration
#define PD_DISTATUS     PD_DIN_BASE+2   // DIn Get Status
#define PD_DIREAD       PD_DIN_BASE+4   // DIn Read Input Value
#define PD_DICLRDATA    PD_DIN_BASE+6   // DIn Clear Data
#define PD_DIRESET      PD_DIN_BASE+8   // DIn Reset to default
#define PD_DIN_LAST     PD_DIRESET

// PowerDAQ DOut Subsystem Command IVECs.
#define PD_DOUT_BASE    PD_DIN_LAST+2
#define PD_DOWRITE      PD_DOUT_BASE    // DOut Write Value
#define PD_DOUT_LAST    PD_DOWRITE

// PowerDAQ UCT Subsystem Command IVECs.
#define PD_UCT_BASE     PD_DOUT_LAST+2
#define PD_UCTCFG       PD_UCT_BASE     // UCT Set Configuration
#define PD_UCTSTATUS    PD_UCT_BASE+2   // UCT Get Status
#define PD_UCTWRITE     PD_UCT_BASE+4   // UCT Write
#define PD_UCTREAD      PD_UCT_BASE+6   // UCT Read
#define PD_UCTSWGATE    PD_UCT_BASE+8   // UCT SW Set Gate
#define PD_UCTSWCLK     PD_UCT_BASE+10  // UCT SW Clock Strobe
#define PD_UCTRESET     PD_UCT_BASE+12  // UCT Reset to default
#define PD_UCT_LAST     PD_UCTRESET

// PowerDAQ DIO-256 Subsystem Command IVECs.
#define PD_DIO256_BASE  PD_UCT_LAST+2
#define PD_DI0256RD     PD_DIO256_BASE    // DIO 256 Command (Read/Configure)
#define PD_DI0256WR     PD_DIO256_BASE+2  // DIO 256 Command (Write/Configure)
#define PD_DINSETINTRMASK PD_DIO256_BASE+4  // Set DIO 256 Interrupt Mask
#define PD_DINGETINTRDATA PD_DIO256_BASE+6  // Get DIO 256 Interrupt Data
#define PD_DININTRREENABLE PD_DIO256_BASE+8 // (Re-)enable DIO 256 interrupts
#define PD_DIODMASET    PD_DIO256_BASE+10
#define PD_DIO256_LAST  PD_DIODMASET

// PowerDAQ Cal Subsystem Command IVECs.
#define PD_CAL_BASE     PD_DIO256_LAST+2
#define PD_CALCFG       PD_CAL_BASE     // CAL Set Configuration
#define PD_CALDACWRITE  PD_CAL_BASE+2   // CAL DAC Write
#define PD_CAL_LAST     PD_CALDACWRITE

// >>>> NOTE: THIS LIST WILL GROW AS COMMANDS ARE DEFINED <<<<

// PowerDAQ Diag Subsystem Command IVECs.
#define PD_DIAG_BASE    PD_CAL_LAST+2
#define PD_DIAGPCIECHO  PD_DIAG_BASE    // DIAG PCI Echo test
#define PD_DIAGPCIINT   PD_DIAG_BASE+2  // DIAG PCI Interrupt test
#define PD_BRDEPRMWR    PD_DIAG_BASE+4  // Board SPI EEPROM Write
#define PD_DIAG_LAST    PD_BRDEPRMWR

// PowerDAQ Block Transfer Command IVECs.
#define PD_BLKXFER_BASE PD_DIAG_LAST+2
#define PD_AIN_BLK_XFER PD_BLKXFER_BASE // AIn Block Transfer IVEC
#define PD_BLKXFER_LAST X_AIN_BLK_XFER

//-------------------------------------
#define PD_LAST         PD_BLKXFER_LAST

//***********************************************************************

//-----------------------------------------------------------------------
// Return value constants.
//-----------------------------------------------------------------------
#define CMD_VALID       1               // Success return value
#define ERR_RET         0x00800000      // Error return value

//-----------------------------------------------------------------------
// DAQ Constants.
//-----------------------------------------------------------------------
#define AIN_BLKSIZE     512     // AIn Transfer Block Size
#define AOUT_BLKSIZE   1024     // AOut Transfer Block Size
 
//----------------------------------
#define AIB_NotUse     (1L<<20) 
//----------------------------------
#define AIBM_SET       (1L<<23) // CL size modifier to set up BM parameters
#define AIBM_GET       (1L<<22) // CL size modifier to request BM counter status
#define AIBM_TXSIZE    512      // internal BM buffer size, samples
#define AIBM_BURSTSIZE 32       // size of the BM burst, limited to 32 transfers
#define AIBM_GETPAGE   (1L<<23) // return physical/virtual/linear address of the page

//-----------------------------------------------------------------------
// Board Control Subsystem Status (BrdStatus) Bits
//-----------------------------------------------------------------------
#define BRDB_HINT       (1L<<0)  // PCI Host Interrupt Status
#define BRDB_HINTEN     (1L<<1)  // PCI Host Interrupt Enabled
#define BRDB_HINTASRT   (1L<<2)  // PCI Host Interrupt Assert Condition
#define BRDB_ERR        (1L<<3)  // Board error occured
#define BRDB_DSPERR     (1L<<4)  // DSP error occured
#define BRDB_PCIERR     (1L<<5)  // PCI Slave Mode FIFO Error occured
#define BRDB_HCVERR     (1L<<6)  // PCI Slave Mode HCV Error occured
#define BRDB_BMERR      (1L<<7)  // PCI Bus Master Error occured

//-----------------------------------------------------------------------
// Board Subsystem Interrupt Status (BrdIntStat) Debug Only Bits
//-----------------------------------------------------------------------
#define BRDB_IRQA       (1L<<0)  // (DBG ONLY) DSP IRQ A Interrupt Status
#define BRDB_IRQB       (1L<<1)  // (DBG ONLY) DSP IRQ B Interrupt Status
#define BRDB_IRQC       (1L<<2)  // (DBG ONLY) DSP IRQ C Interrupt Status
#define BRDB_IRQD       (1L<<3)  // (DBG ONLY) DSP IRQ D Interrupt Status
#define BRDB_WDTIMER    (1L<<4)  // (DBG ONLY) DSP Watchdog Timer TC
#define BRDB_HINTSET    (1L<<5)  // (DBG ONLY) PCI Host Interrupt Set
#define BRDB_HINTACK    (1L<<6)  // (DBG ONLY) PCI Host Interrupt Acknowledged

//-----------------------------------------------------------------------
// ADUEIntrStat: AIn/AOut/DIn/UCT/ExTrig Interrupt/Status Register
//
// Note: All Interrupt Mask Bits:
//
//          Write '1' to enable, '0' to disable
//          Read current bit setting
//
//       All Interrupt Status/Clear Bits:
//
//          Write '0' to clear interrupt
//          Read '1' cause active, '0' inactive
//
//       1. UCTxIntr interrupts are active on either edge transition.
//
//       2. ExTrigIm enables both rising edge and falling edge External
//          Trigger input signal interrupts.
//
//       3. B_AInCVDone and B_AInCLDone are used by firmware only in SW Strobe
//          Start clocks.
//
//-----------------------------------------------------------------------
#define UTB_Uct0Im      (1L<<0)  // UCT 0 Interrupt mask
#define UTB_Uct1Im      (1L<<1)  // UCT 1 Interrupt mask
#define UTB_Uct2Im      (1L<<2)  // UCT 2 Interrupt mask

#define UTB_Uct0IntrSC  (1L<<3)  // UCT 0 Interrupt Status/Clear
#define UTB_Uct1IntrSC  (1L<<4)  // UCT 1 Interrupt Status/Clear
#define UTB_Uct2IntrSC  (1L<<5)  // UCT 2 Interrupt Status/Clear

#define DIB_IntrIm      (1L<<6)  // DIn Interrupt mask
#define DIB_IntrSC      (1L<<7)  // DIn Interrupt Status/Clear

#define BRDB_ExTrigIm   (1L<<8)  // External Trigger Interrupt mask
#define BRDB_ExTrigReSC (1L<<9)  // Ext Trigger Rising Edge Interrupt Status/Clear
#define BRDB_ExTrigFeSC (1L<<10) // Ext Trigger Falling Edge Interrupt Status/Clear
//----------------------------------
// Status only bits:
#define AIB_FNE         (1L<<11) // 1 = ADC FIFO Not Empty
#define AIB_FHF         (1L<<12) // 1 = ADC FIFO Half Full
#define AIB_FF          (1L<<13) // 1 = ADC FIFO Full
#define AIB_CVDone      (1L<<14) // 1 = ADC Conversion Done
#define AIB_CLDone      (1L<<15) // 1 = ADC Channel List Done
#define UTB_Uct0Out     (1L<<16) // Current state of UCT0 output
#define UTB_Uct1Out     (1L<<17) // Current state of UCT1 output
#define UTB_Uct2Out     (1L<<18) // Current state of UCT2 output

#define BRDB_ExTrigLevel (1L<<19)// Current state of External Trigger input
//#define AOB_CVDone    (1L<<20) // 1 = DAC CV Done, 0 = DAC Conversion in progress

//-----------------------------------------------------------------------
// AIOIntr:  AIn/AOut Interrupt Registers #1 & #2
//
// Note: All Interrupt Mask Bits:
//
//          Write '1' to enable, '0' to disable
//          Read current bit setting
//
//       All Interrupt Status/Clear Bits:
//
//          Write '0' to clear interrupt
//          Read '1' cause active, '0' inactive
//
//       AOutCVDoneIm, AOutCVDoneSC, AOutCVStrtErrIm, and AOutCVStrtErrSC
//       will be implemented in future board versions with parallel DAC.
//
//       Interrupt bits AIB_CLDoneIm/AIB_CLDoneSC must not be modified
//       by driver or user software.
//
//-----------------------------------------------------------------------
//#define AIB_FNEIm     (1L<<0)  // AIn FIFO Not Empty Interrupt mask
#define AIB_FHFIm       (1L<<1)  // AIn FIFO Half Full Interrupt mask
#define AIB_CLDoneIm    (1L<<2)  // AIn CL Done Interrupt mask
//#define AIB_FNESC     (1L<<3)  // AIn FIFO Not Empty Interrupt Status/Clear
#define AIB_FHFSC       (1L<<4)  // AIn FIFO Half Full Interrupt Status/Clear
#define AIB_CLDoneSC    (1L<<5)  // AIn CL Done Interrupt Status/Clear
//#define AOB_CVDoneIm  (1L<<6)  // AOut CV Done Interrupt mask
//#define AOB_CVDoneSC  (1L<<7)  // AOut CV Done Interrupt Status/Clear
//----------------------------------
#define AIB_FFIm        (1L<<8)  // AIn FIFO Full Interrupt mask
#define AIB_CVStrtErrIm (1L<<9)  // AIn CV Start Error Interrupt mask
#define AIB_CLStrtErrIm (1L<<10) // AIn CL Start Error Interrupt mask
#define AIB_OTRLowIm    (1L<<11) // AIn OTR Low Error Interrupt mask
#define AIB_OTRHighIm   (1L<<12) // AIn OTR High Error Interrupt mask
#define AIB_FFSC        (1L<<13) // AIn FIFO Full Interrupt Status/Clear
#define AIB_CVStrtErrSC (1L<<14) // AIn CV Start Error Interrupt Status/Clear
#define AIB_CLStrtErrSC (1L<<15) // AIn CL Start Error Interrupt Status/Clear
#define AIB_OTRLowSC    (1L<<16) // AIn OTR Low Error Interrupt Status/Clear
#define AIB_OTRHighSC   (1L<<17) // AIn OTR High Error Interrupt Status/Clear
//#define AOB_CVStrtErrIm (1L<<18)// AOut CV Start Error Interrupt mask
//#define AOB_CVStrtErrSC (1L<<19)// AOut CV Start Error Interrupt Status/Clear

//-----------------------------------------------------------------------
// AIn Subsystem Configuration (AInCfg) Bits (MF, MFS and Lab boards)
//-----------------------------------------------------------------------
#define AIB_INPMODE     (1L<<0)  // AIn Input Mode (Single-Ended/Differential)
#define AIB_INPTYPE     (1L<<1)  // AIn Input Type (Unipolar/Bipolar)
#define AIB_INPRANGE    (1L<<2)  // AIn Input Range (Low/High)
#define AIB_CVSTART0    (1L<<3)  // AIn Conv Start Clk Source (2 bits)
#define AIB_CVSTART1    (1L<<4)
#define AIB_EXTCVS      (1L<<5)  // AIn External Conv Start (Pacer) Clk Edge
#define AIB_CLSTART0    (1L<<6)  // AIn Ch List Start (Burst) Clk Source (2 bits)
#define AIB_CLSTART1    (1L<<7)
#define AIB_EXTCLS      (1L<<8)  // AIn External Ch List Start (Burst) Clk Edge
#define AIB_INTCVSBASE  (1L<<9)  // AIn Internal Conv Start Clk Base
#define AIB_INTCLSBASE  (1L<<10) // AIn Internal Ch List Start Clk Base
#define AIB_STARTTRIG0  (1L<<11) // AIn Start Trigger Source (2 bits)
#define AIB_STARTTRIG1  (1L<<12)
#define AIB_STOPTRIG0   (1L<<13) // AIn Stop Trigger Source (2 bits)
#define AIB_STOPTRIG1   (1L<<14)
#define AIB_PRETRIG     (1L<<15) // Use AIn Pre-Trigger Scan Count
#define AIB_POSTTRIG    (1L<<16) // Use AIn Post-Trigger Scan Count
//#define AIB_BLKBUF      (1L<<17) // Use Block Buffer Mode for data transfer
#define AIB_EXTGATE     (1L<<17) // Use AIn trig line as external gate for the A/D clock
#define AIB_BUSMSTR     (1L<<18) // Use Bus Master Mode for data transfer
#define AIB_SELMODE0    (1L<<19) // FW Mode
#define AIB_SELMODE1    (1L<<20) // FW Mode
#define AIB_SELMODE2    (1L<<21) // FW Mode
#define AIB_SELMODE3    (1L<<22) // FW Mode
#define AIB_SELMODE4    (1L<<23) // FW Mode
#define AIB_DMAEN       (1L<<24) // Driver takes care of this bit not firmware

#define AIB_MODEBITS    (AIB_INPTYPE|AIB_INPRANGE)    // autocal needed on mode chages

//-----------------------------------------------------------------------
// DIn Subsystem Configuration (DInCfg) Bits (PD2-DIO boards)
//-----------------------------------------------------------------------
#define DIB_CVSTART0    (1L<<3)  // DIn Conv Start Clk Source (2 bits)
#define DIB_CVSTART1    (1L<<4)
#define DIB_EXTCVS      (1L<<5)  // DIn External Conv Start (Pacer) Clk Edge
#define DIB_INTCVSBASE  (1L<<9)  // DIn Internal Conv Start Clk Base
#define DIB_STARTTRIG0  (1L<<11) // DIn Start Trigger Source (2 bits)
#define DIB_STARTTRIG1  (1L<<12)
#define DIB_STOPTRIG0   (1L<<13) // DIn Stop Trigger Source (2 bits)
#define DIB_STOPTRIG1   (1L<<14)
#define DIB_BLKBUF      (1L<<17) // Use Block Buffer Mode for data transfer
#define DIB_BUSMSTR     (1L<<18) // Use Bus Master Mode for data transfer

//-----------------------------------------------------------------------
// CT Subsystem Configuration (CTCfg) Bits (PD2-DIO boards)
//-----------------------------------------------------------------------
#define CTB_CVSTART0    (1L<<3)  // CT Conv Start Clk Source (2 bits)
#define CTB_CVSTART1    (1L<<4)
#define CTB_EXTCVS      (1L<<5)  // CT External Conv Start (Pacer) Clk Edge
#define CTB_INTCVSBASE  (1L<<9)  // CT Internal Conv Start Clk Base
#define CTB_STARTTRIG0  (1L<<11) // CT Start Trigger Source (2 bits)
#define CTB_STARTTRIG1  (1L<<12)
#define CTB_STOPTRIG0   (1L<<13) // CT Stop Trigger Source (2 bits)
#define CTB_STOPTRIG1   (1L<<14)

//-----------------------------------------------------------------------
// AIn Subsystem Interrupt/Status (AInIntrStat) Bits
//
// Note: Status bits AIB_Enabled, AIB_Active, AIB_BMEnabled, and
//       AIB_BMActive must not be modified by driver or user software.
//
//-----------------------------------------------------------------------
#define AIB_StartIm     (1L<<0)  // AIn Sample Acquisition Started Int mask
#define AIB_StopIm      (1L<<1)  // AIn Sample Acquisition Stopped Int mask
#define AIB_SampleIm    (1L<<2)  // AIn One or More Samples Acquired Int mask
#define AIB_ScanDoneIm  (1L<<3)  // AIn One or More CL Scans Acquired Int mask

#define AIB_ErrIm       (1L<<4)  // AIn Subsystem Error Int mask
#define AIB_BMPgDoneIm  (1L<<5)  // AIn Bus Master Blocks Transferred Int mask
#define AIB_BMErrIm     (1L<<6)  // Bus Master Data Transfer Error Int mask
#define AIB_BMEmptyIm   (1L<<7)  // Bus Master PRD Table Empty Error Int mask
//----------------------------------
#define AIB_StartSC     (1L<<8)  // AIn Sample Acquisition Started Status/Clear
#define AIB_StopSC      (1L<<9)  // AIn Sample Acquisition Stopped Status/Clear
#define AIB_SampleSC    (1L<<10) // AIn One or More Samples Acquired Status/Clear
#define AIB_ScanDoneSC  (1L<<11) // AIn One or More CL Scans Acquired Status/Clear

#define AIB_ErrSC       (1L<<12) // AIn Subsystem Error Status/Clear
#define AIB_BMPg0DoneSC (1L<<13) // AIn Bus Master Blocks Transferred Status/Clear
#define AIB_BMPg1DoneSC (1L<<14) // Bus Master Data Transfer Error Status/Clear
#define AIB_BMErrSC     (1L<<15) // Bus Master PRD Table Empty Error Status/Clear
//----------------------------------
// Status only bits:
#define AIB_Enabled     (1L<<16) // AIn Enabled Status
#define AIB_Active      (1L<<17) // AIn Active (Started) Status
#define AIB_BMEnabled   (1L<<18) // AIn Bus Master Enabled Status
#define AIB_BMActive    (1L<<19) // AIn Bus Master Active (Started) Status
//----------------------------------

// Page control/status bits
// When interrupt fires "1" in following bits tell what page is completed
// Write "0" to tell firmware to reuse this page
#define AIB_BMPage0     (1L<<20) // BM Page0 is completed
#define AIB_BMPage1     (1L<<21) // BM Page1 is completed
#define AIB_BMPage2     (1L<<22) // BM Page2 is completed
#define AIB_BMPage3     (1L<<23) // BM Page3 is completed

//-----------------------------------------------------------------------
// AOut Subsystem Configuration (AOutCfg) Bits (PDx-MFx and PD2-AO boards)
//-----------------------------------------------------------------------
#define AOB_CVSTART0    (1L<<0)  // AOut Conv (Pacer) Start Clk Source (2 bits)
#define AOB_CVSTART1    (1L<<1)
#define AOB_SWR         (1L<<3)  // Scaled Waveform regeneration (AOx) ; add dk
                                 // This flag must be set with  Time sequencer mode (AOB_TSEQ)
#define AOB_NODMARD     (1L<<4)  // Disable analog output DMA mode fom users application.
                                 // Disable DMA transfer from Host to PC 
#define AOB_HS_SYNC     (1L<<5)  // Enable synchronization for high-speed AO board.
                                 // AOB_HS_SYNC=0 if acquisition speed < 1.6MHz 
                                 // AOB_HS_SYNC=1 if acquisition speed = 1.6MHz -11MHz
                                 // For acquisition speed = 1.6MHz-11MHz synchronization cable should connect:
                                 // - pin 3 (TMR0) on the J2 connector on the master board to the pin 3 of the slave board(s) 
                                 // - pin 4 (TMR2) on the J2 connector on the master board to the pin 4 of the slave board(s)
                                 //   via 100 Ohm  protection resistor (for PD2-AO-8,16,32) . If PD2-AO-96/16 boards are 
                                 //   synchronized pin 4 on the master board should be connected to the pin 29 on all slave boards.
                                 // For acquisition speed < 1.6MHz synchronization cable should connect:
                                 // - pin 4 on master board should be connected to the pin 4 on slave board(s) via 100 Ohm.
                                 //   If PD2-AO-96/16 boards are synchronized pin 4 on the master board
                                 //   should be connected to the pin 29 on all slave boards.

#define AOB_INTCVSBASE  (1L<<6)  // 11Mhz (0) or 33MHz (1) internal base clock
#define AOB_STARTTRIG0  (1L<<7)  // AOut Start Trigger Source (2 bits)
#define AOB_STARTTRIG1  (1L<<8)
#define AOB_STOPTRIG0   (1L<<9)  // AOut Stop Trigger Source (2 bits)
#define AOB_STOPTRIG1   (1L<<10)
#define AOB_REGENERATE  (1L<<13) // Switch to regenerate mode
#define AOB_AOUT32      (1L<<14) // switch to PD2-AO board (format: (channel<<16)|(value & 0xFFFF))
#define AOB_DOUT32      (1L<<14) // switch to PD2-DIO board (format: (channel<<16)|(value & 0xFFFF))
#define AOB_DMAEN       (1L<<15) // enable analog output DMA mode
//#define AOB_DSPWF       (1L<<16) // DSP WF mode - waveform is calculated by DSP on the fly
#define AOB_WFMODE      (1L<<16) // Enables waveform generation mode
#define AOB_TSEQ        (1L<<17) // Enable time sequencer mode  
#define AOB_NOCLEARDAC  (1L<<18) // Output DAC are not erase ; add dk
#define AOB_ESSI0       (1L<<19) // redirect output to ESSI0 port
#define AOB_EXTMSIZE0   (1L<<20) // Select AOut FIFO size (memory option)
#define AOB_EXTMSIZE1   (1L<<21) // 00 = 64k, 01 = 32k, 10 = 16k, 11 = 8k
#define AOB_EXTM        (1L<<22) // use 64k external memory buffer
#define AOB_DMARD       (1L<<23) // Use DMA for transfer data from PCI FIFO to DSP memory

// Obsolete flags - do not use them
#define AOB_BUFMODE0    (1L<<30) // AOut Buf Mode (Single-Value/Block) (2 bits)
#define AOB_BUFMODE1    (1L<<30)
#define AOB_EXTCVS      (1L<<30)  // AOut External Conv (Pacer) Clock Edge
#define AOB_DACBLK0     (1L<<30)  // DACs Enabled in Block Mode (4 bits)
#define AOB_DACBLK1     (1L<<30)
#define AOB_DACBLK2     (1L<<30)
#define AOB_DACBLK3     (1L<<30)

//-----------------------------------------------------------------------
// DSP WF mode - waveform is calculated by DSP on the fly
#define AWF_NOWAVE      (0)      //
#define AWF_DC          (1L<<1)  //
#define AWF_TRIANGLE    (1L<<2)  //
#define AWF_RAMP        (1L<<3)  //
#define AWF_SAWTOOTH    (1L<<4)  //
#define AWF_SQUARE      (1L<<5)  //
#define AWF_USER        (1L<<6)  // Waveform is in the user buffer
#define AWF_SINE        (1L<<7)  // sinewave
#define AWF_NOSMOOTH    (1L<<23) // Do not smooth transition between waveforms

//-----------------------------------------------------------------------
// DOut Subsystem Configuration (DOutCfg) Bits (PD2-DIO boards)
//-----------------------------------------------------------------------
#define DOB_CVSTART0    (1L<<0)  // DOut Conv (Pacer) Start Clk Source (2 bits)
#define DOB_CVSTART1    (1L<<1)
#define DOB_EXTCVS      (1L<<2)  // DOut External Conv (Pacer) Clock Edge
#define DOB_STARTTRIG0  (1L<<7)  // DOut Start Trigger Source (2 bits)
#define DOB_STARTTRIG1  (1L<<8)
#define DOB_STOPTRIG0   (1L<<9)  // DOut Stop Trigger Source (2 bits)
#define DOB_STOPTRIG1   (1L<<10)
#define DOB_BUFMODE0    (1L<<11) // DOut Buf Mode (Single-Value/Block) (2 bits)
#define DOB_BUFMODE1    (1L<<12)
#define DOB_REGENERATE  (1L<<13) // Switch to regenerate mode

//-----------------------------------------------------------------------
// AOut Subsystem Interrupt/Status (AOutIntrStat) Bits
//
// Note: Status bits AOB_Enabled, AOB_Active, AIB_BMEnabled, AOB_BufFull,
//       AOB_QEMPTY, AOB_QHF, and AOB_QFULL must not be modified by driver
//       or user software.
//
//-----------------------------------------------------------------------
#define AOB_StartIm     (1L<<0)  // AOut Conversion Started Int mask
#define AOB_StopIm      (1L<<1)  // AOut Conversion Stopped Int mask
#define AOB_ScanDoneIm  (1L<<2)  // AOut Single Conversion/Scan Done Int mask
#define AOB_HalfDoneIm  (1L<<3)  // AOut Half Buffer Done Int mask

#define AOB_BufDoneIm   (1L<<4)  // AOut Buffer Done Int mask
#define AOB_BlkXDoneIm  (1L<<5)
#define AOB_BlkYDoneIm  (1L<<6)
#define AOB_UndRunErrIm (1L<<7)  // AOut Buffer Underrun Error Int mask

//----------------------------------
#define AOB_CVStrtErrIm (1L<<8)  // AOut Conversion Start Error Int mask
#define AOB_StartSC     (1L<<9)  // AOut Conversion Started Status/Clear
#define AOB_StopSC      (1L<<10)  // AOut Conversion Stopped Status/Clear
#define AOB_ScanDoneSC  (1L<<11) // AOut Single Conversion/Scan Done Status/Clear

#define AOB_HalfDoneSC  (1L<<12) // AOut Half Buffer Done Status/Clear
#define AOB_BufDoneSC   (1L<<13) // AOut Buffer Done Status/Clear
#define AOB_BlkXDoneSC  (1L<<14)
#define AOB_BlkYDoneSC  (1L<<15)
//----------------------------------

#define AOB_UndRunErrSC (1L<<16) // AOut Buffer Underrun Error Status/Clear
#define AOB_CVStrtErrSC (1L<<17) // AOut Conversion Start Error Status/Clear

// Status only bits:
#define AOB_Enabled     (1L<<18) // AOut Enabled Status
#define AOB_Active      (1L<<19) // AOut Active (Started) Status
#define AOB_BufFull     (1L<<20) // AOut Buffer Full Error Status
#define AOB_QEMPTY      (1L<<21) // AOut Queue Empty Status
#define AOB_QHF         (1L<<22) // AOut Queue Half Full Status
#define AOB_QFULL       (1L<<23) // AOut Queue Full Status

//-----------------------------------------------------------------------
// DIn Subsystem Configuration (DInCfg) Bits
//-----------------------------------------------------------------------
#define DIB_0CFG0       (1L<<0)  // DIn Bit 0 Intr Cfg bit 0
#define DIB_0CFG1       (1L<<1)  // DIn Bit 0 Intr Cfg bit 1
#define DIB_1CFG0       (1L<<2)  // DIn Bit 1 Intr Cfg bit 0
#define DIB_1CFG1       (1L<<3)  // DIn Bit 1 Intr Cfg bit 1
#define DIB_2CFG0       (1L<<4)  // DIn Bit 2 Intr Cfg bit 0
#define DIB_2CFG1       (1L<<5)  // DIn Bit 2 Intr Cfg bit 1
#define DIB_3CFG0       (1L<<6)  // DIn Bit 3 Intr Cfg bit 0
#define DIB_3CFG1       (1L<<7)  // DIn Bit 3 Intr Cfg bit 1
#define DIB_4CFG0       (1L<<8)  // DIn Bit 4 Intr Cfg bit 0
#define DIB_4CFG1       (1L<<9)  // DIn Bit 4 Intr Cfg bit 1
#define DIB_5CFG0       (1L<<10) // DIn Bit 5 Intr Cfg bit 0
#define DIB_5CFG1       (1L<<11) // DIn Bit 5 Intr Cfg bit 1
#define DIB_6CFG0       (1L<<12) // DIn Bit 6 Intr Cfg bit 0
#define DIB_6CFG1       (1L<<13) // DIn Bit 6 Intr Cfg bit 1
#define DIB_7CFG0       (1L<<14) // DIn Bit 7 Intr Cfg bit 0
#define DIB_7CFG1       (1L<<15) // DIn Bit 7 Intr Cfg bit 1

//-----------------------------------------------------------------------
// DIn Subsystem Level/Latch (DInStatus) Bits
//-----------------------------------------------------------------------
// Bits 0 - 7:  Digital Input Bit Level
#define DIB_LEVEL0      (1L<<0)  // DIn Bit 0 Input Level
#define DIB_LEVEL1      (1L<<1)  // DIn Bit 1 Input Level
#define DIB_LEVEL2      (1L<<2)  // DIn Bit 2 Input Level
#define DIB_LEVEL3      (1L<<3)  // DIn Bit 3 Input Level
#define DIB_LEVEL4      (1L<<4)  // DIn Bit 4 Input Level
#define DIB_LEVEL5      (1L<<5)  // DIn Bit 5 Input Level
#define DIB_LEVEL6      (1L<<6)  // DIn Bit 6 Input Level
#define DIB_LEVEL7      (1L<<7)  // DIn Bit 7 Input Level

// Bits 8 - 15: Digital Input Bit Trigger Status
#define DIB_INTR0       (1L<<8)  // DIn Bit 8 Latched Interrupt
#define DIB_INTR1       (1L<<9)  // DIn Bit 9 Latched Interrupt
#define DIB_INTR2       (1L<<10) // DIn Bit 10 Latched Interrupt
#define DIB_INTR3       (1L<<11) // DIn Bit 11 Latched Interrupt
#define DIB_INTR4       (1L<<12) // DIn Bit 12 Latched Interrupt
#define DIB_INTR5       (1L<<13) // DIn Bit 13 Latched Interrupt
#define DIB_INTR6       (1L<<14) // DIn Bit 14 Latched Interrupt
#define DIB_INTR7       (1L<<15) // DIn Bit 15 Latched Interrupt


//------------------------------------------------------------------------
// DIn Subsystem of DIO board Configuration (DIn256Cfg) Bits
//------------------------------------------------------------------------
#define DIB_256IntrIm   (1L<<1)  // DIO-256 Interrupt mask
#define DIB_256IntrSC   (1L<<2)  // DIO-256 Interrupt Status/Clear
   
#define DIB_IRQAIm      (1L<<3)  // IRQA Interrupt mask
#define DIB_IRQASC      (1L<<4)  // IRQA Interrupt Status/Clear
#define DIB_IRQBIm      (1L<<5)  // IRQB Interrupt mask
#define DIB_IRQBSC      (1L<<6)  // IRQB Interrupt Status/Clear
#define DIB_IRQCIm      (1L<<7)  // IRQC Interrupt mask
#define DIB_IRQCSC      (1L<<8)  // IRQC Interrupt Status/Clear
#define DIB_IRQDIm      (1L<<9)  // IRQD Interrupt mask
#define DIB_IRQDSC      (1L<<10) // IRQD Interrupt Status/Clear



//-----------------------------------------------------------------------
// DOut Subsystem Configuration (DOutCfg) Bits
//-----------------------------------------------------------------------
// N/A

//-----------------------------------------------------------------------
// DOut Subsystem Interrupt/Status (DOutIntrStat) Bits
//-----------------------------------------------------------------------
// N/A

//-----------------------------------------------------------------------
// DIO 256 Subsystem Configuration (DIO256) Bits
//-----------------------------------------------------------------------
#define DIO_REG0    0xFC0000       // DIO 16 I/O Register 0 mask
#define DIO_REG1    0xFC0001       // DIO 16 I/O Register 1 mask
#define DIO_REG2    0xFC0002       // DIO 16 I/O Register 2 mask
#define DIO_REG3    0xFC0003       // DIO 16 I/O Register 3 mask
#define DIO_REG4    0xFC0004       // DIO 16 I/O Register 4 mask
#define DIO_REG5    0xFC0005       // DIO 16 I/O Register 5 mask
#define DIO_REG6    0xFC0006       // DIO 16 I/O Register 6 mask
#define DIO_REG7    0xFC0007       // DIO 16 I/O Register 7 mask

#define DIO_SRD     0x000000       // Read register command
#define DIO_SWR     0x000000       // Write register command
#define DIO_LRD     0xFC0008       // Read latch command
#define DIO_LWR     0xFC0008       // Write latch enable command
#define DIO_PWR     0xFC0020       // Write propagate mask command
#define DIO_LAL     0xFC0040       // Latch all registers command
#define DIO_LAR     0x000060       // Latch and read register command
#define DIO_WOE     0xFC0060       // Write output enable state command

#define DIO_DIS_0_3 0xFC007B      // Disable reg 0 to 3 outputs
#define DIO_DIS_4_7 0xFC007F      // Disable reg 4 to 7 outputs

//-----------------------------------------------------------------------
// AO 32 Subsystem Configuration (AO32) Bits
//-----------------------------------------------------------------------
#define AO32_WRPR       0x0       // Write value to the DAC and set it
#define AO32_WRH        0x60      // Write value to the DAC but hold it
#define AO32_UPDALL     0x00      // Read to update all holded DACs
#define AO96_UPDALL     (1L<<7)
#define AO32_SETUPDMD   0x40      // Read to set last channel autoupdate
#define AO32_SETUPDEN   0x20      // Must be ORed with AO32_SETUPDMD
#define AO32_BASE       0xFC0000  // Base address
#define AO32_WRITEHOLDBIT (1L<<21) // Write but not update (used in channel list)
#define AO96_WRITEHOLDBIT (1L<<23) // Write but not update (used in channel list)
#define AO32_UPDATEBIT    (1L<<22) // Update All channels (used in channel list)

#define AOB_DACBASE        0xFC0000   // DACs base address
#define AOB_CTRBASE        0xBFF000   // Control registers/DIO base address
#define AOB_AO96WRITEHOLD  0x80       // Write and Hold command mask
#define AOB_AO96UPDATEALL  0x100      // Update all command mask
#define AOB_AO96CFG        0x0        // Configuration register mask
#define AOB_AO96DIO        0x100      // DIO register mask

#define AO_REG0 AOB_DACBASE           // First AO register. AO_REGx = AO_REG0 + x
#define AO_WR AO32_WRPR

//-----------------------------------------------------------------------
// UCT Subsystem Configuration (UctCfg) Bits
//-----------------------------------------------------------------------
#define UTB_CLK0        (1L<<0)  // UCT 0 Clock Source (2 bits)
#define UTB_CLK0_1      (1L<<1)  //
#define UTB_CLK1        (1L<<2)  // UCT 1 Clock Source (2 bits)
#define UTB_CLK1_1      (1L<<3)  //
#define UTB_CLK2        (1L<<4)  // UCT 2 Clock Source (2 bits)
#define UTB_CLK2_1      (1L<<5)  //
#define UTB_GATE0       (1L<<6)  // UCT 0 Gate Source bit
#define UTB_GATE1       (1L<<7)  // UCT 1 Gate Source bit
#define UTB_GATE2       (1L<<8)  // UCT 2 Gate Source bit
#define UTB_SWGATE0     (1L<<9)  // UCT 0 SW Gate Setting bit
#define UTB_SWGATE1     (1L<<10) // UCT 1 SW Gate Setting bit
#define UTB_SWGATE2     (1L<<11) // UCT 2 SW Gate Setting bit
#define UTB_INTR0MSK    (1L<<12) // UCT 0 Output Event Interrupt Mask bit
#define UTB_INTR1MSK    (1L<<13) // UCT 1 Output Event Interrupt Mask bit
#define UTB_INTR2MSK    (1L<<14) // UCT 2 Output Event Interrupt Mask bit
#define UTB_FREQMODE0   (1L<<15) // UCT 0 freq. counter mode start/status
#define UTB_FREQMODE1   (1L<<16) // UCT 1 freq. counter mode start/status
#define UTB_FREQMODE2   (1L<<17) // UCT 2 freq. counter mode start/status

#define AIB_EXTENDEDMODE (1L<<23) // Extinded mode for DIO board. DSPUCT0 ISR chenged if set this bits.

//-----------------------------------------------------------------------
// UCT Subsystem Level/Latch (UctStatus) Bits
//-----------------------------------------------------------------------
#define UTB_LEVEL0      (1L<<0)  // UCT 0 Output Level
#define UTB_LEVEL1      (1L<<1)  // UCT 1 Output Level
#define UTB_LEVEL2      (1L<<2)  // UCT 2 Output Level
#define UTB_INTR0       (1L<<3)  // UCT 0 Latched Interrupt
#define UTB_INTR1       (1L<<4)  // UCT 1 Latched Interrupt
#define UTB_INTR2       (1L<<5)  // UCT 2 Latched Interrupt

//-----------------------------------------------------------------------
// Calibration Subsystem Status (CalStatus) Bits
//-----------------------------------------------------------------------
#define CAL_ACTIVE      (1L<<0)  // CAL Routine Executed flag

//-----------------------------------------------------------------------
// Diagnostics Subsystem Status (DiagStatus) Bits
//-----------------------------------------------------------------------
#define DIAG_ACTIVE     (1L<<0)  // DIAG Routine Executed flag

#define AIcontinuos 0
#define AIinternal  1
#define AIexternal  2

//---------------------------------------------------------------------------
// Description: Testing User Counter/Timer.
//---------------------------------------------------------------------------

#define  UCT_BCD          (1L << 0)
#define  UCT_M0           (1L << 1)
#define  UCT_M1           (1L << 2)
#define  UCT_M2           (1L << 3)
#define  UCT_RW0          (1L << 4)
#define  UCT_RW1          (1L << 5)
#define  UCT_SC0          (1L << 6)
#define  UCT_SC1          (1L << 7)
#define  UCT_CNT0         (1L << 1)
#define  UCT_CNT1         (1L << 2)
#define  UCT_CNT2         (1L << 3)
#define  UCT_STATUS       (1L << 4)
#define  UCT_COUNT        (1L << 5)
#define  UCT_NULLCNT      (1L << 6)
#define  UCT_OUTPUT       (1L << 7)

#define  UCT_SelCtr0      (0)
#define  UCT_SelCtr1      (UCT_SC0)
#define  UCT_SelCtr2      (UCT_SC1)
#define  UCT_ReadBack     (UCT_SC0 | UCT_SC1)
#define  UCT_Mode0        (0)
#define  UCT_Mode1        (UCT_M0)
#define  UCT_Mode2        (UCT_M1)
#define  UCT_Mode3        (UCT_M0 | UCT_M1)
#define  UCT_Mode4        (UCT_M2)
#define  UCT_Mode5        (UCT_M0 | UCT_M2)

#define  UCT_CtrLatch     (0)
#define  UCT_RWlsb        (UCT_RW0)
#define  UCT_RWmsb        (UCT_RW1)
#define  UCT_RW16Bit      (UCT_RW0 | UCT_RW1)
#define  UCT_RW16bit      UCT_RW16Bit

#define  UCTREAD_CFW      (1L << 8)
#define  UCTREAD_UCT0     (0)
#define  UCTREAD_UCT1     (1L << 9)
#define  UCTREAD_UCT2     (2L << 9)
#define  UCTREAD_0BYTES   (0)
#define  UCTREAD_1BYTE    (1L << 11)
#define  UCTREAD_2BYTES   (2L << 11)
#define  UCTREAD_3BYTES   (3L << 11)

#define  UCT_Mode_Low_High     (UCT_Mode0 | UCT_RW16Bit)
#define  UCT_Mode_One_Shot     (UCT_Mode1 | UCT_RW16Bit)
#define  UCT_Mode_Rate         (UCT_Mode2 | UCT_RW16Bit)
#define  UCT_Mode_Square_Wave  (UCT_Mode3 | UCT_RW16Bit)
#define  UCT_Mode_Sw_Strobe    (UCT_Mode4 | UCT_RW16Bit)
#define  UCT_Mode_Hw_Strobe    (UCT_Mode5 | UCT_RW16Bit)

/*
DWORD AIClClock[3] =
    {AIB_CLSTART0+AIB_CLSTART1,
     AIB_CLSTART0,
     AIB_CLSTART1};
*/
/*DWORD AICvClock[3] =
    {(AIB_CVSTART0 | AIB_CVSTART1),
     AIB_CVSTART0,
     AIB_CVSTART1};
	 */



//DWORD UCTModes[6] =
// 		{UCT_Mode_Low_High, UCT_Mode_One_Shot, UCT_Mode_Rate,
//		UCT_Mode_Square_Wave, UCT_Mode_Sw_Strobe, UCT_Mode_Hw_Strobe};


#define  UCT0  0
#define  UCT1  1
#define  UCT2  2
#define  UCTClkSW  0
#define  UCTClk1M  1
#define  UCTClkEx  2

/*

DWORD UCTClocks[3][3] =
		{0,UTB_CLK0, UTB_CLK0 | UTB_CLK0_1,
         0,UTB_CLK1, UTB_CLK1 | UTB_CLK1_1,
         0,UTB_CLK2, UTB_CLK2 | UTB_CLK2_1};
*/

#define  UCTGateSW   FALSE
#define  UCTGateEx   TRUE

/*
DWORD  UCTGates[3][2] =
    {UTB_SWGATE0, UTB_GATE0,
     UTB_SWGATE1, UTB_GATE1,
     UTB_SWGATE2, UTB_GATE2};
*/

#endif /* _INC_PDFW_DEF */

//-----------------------------------------------------------------------
// end of pdfw_def.h
