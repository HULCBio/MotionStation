/* $Revision: 1.1.6.1 $ $Date: 2003/09/19 22:08:57 $ */
/* ueidefines.h - xPC Target, defines for the UEI MF series boards */
/* for A/D section of UEI series boards                            */
/* Copyright 1996-2003 The MathWorks, Inc.                         */

#define AIB_INPMODE              (1L<<0)
#define AIB_INPTYPE              (1L<<1)  // AIn Input Type (Unipolar/Bipolar)
#define AIB_INPRANGE             (1L<<2)  // AIn Input Range (Low/High)
#define AIB_CVSTART0             (1L<<3)
#define AIB_CVSTART1             (1L<<4)
#define AIB_CLSTART0             (1L<<6)  // AIn Ch List Start (Burst) Clk Source (2 bits)
#define AIB_CLSTART1             (1L<<7)
#define AIB_INTCVSBASE           (1L<<9)  // AIn Internal Conv Start Clk Base, 33 Mhz if set
#define AIB_INTCLSBASE           (1L<<10) // AIn Internal Ch List Start Clk Base, 33 Mhz if set
#define AIB_SELMODE0             (1L<<19) // FW Mode, logic family
#define AIB_SELMODE1             (1L<<20) // FW Mode, Bus Master mode

// Neither bit set is software clocking
#define AIN_CV_CLOCK_INTERNAL    (AIB_CVSTART0)
#define AIN_CV_CLOCK_EXTERNAL    (AIB_CVSTART1)
#define AIN_CV_CLOCK_CONTINUOUS  (AIB_CVSTART0 | AIB_CVSTART1)
// Neither bit set is software clocking
#define AIN_CL_CLOCK_INTERNAL    (AIB_CLSTART0)
#define AIN_CL_CLOCK_EXTERNAL    (AIB_CLSTART1)
#define AIN_CL_CLOCK_CONTINUOUS  (AIB_CLSTART0 | AIB_CLSTART1)
#define AIN_DIFFERENTIAL         AIB_INPMODE
#define AIN_BIPOLAR              AIB_INPTYPE
#define AIN_RANGE_10V            AIB_INPRANGE

//#define CL_SIZE     48
#define PD_MAX_CL_SIZE  64

#define CHAN(c)     ((c) & 0x3f)
#define GAIN(g)     (((g) & 0x3) << 6)
#define SLOW        (1<<8)
#define CHLIST_ENT(c,g,s)   (CHAN(c) | GAIN(g) | ((s) ? SLOW : 0))

// Defines needed to set up bus master DMA mode.
#define ADRAIBM_DEFDMASIZE   0x1D  // Default DMA burst size -1 (bursts>=32 usually not supported by BIOS)
#define ADRAIBM_DEFBURSTS    0x1E  // Default # of BM bursts per one DMA3 transfer
#define ARDAIBM_DEFBURSTSIZE 0x1F  // Default BM burst size (BL field)
#define ADRREALTIMEBMMODE    0x20  // Enable/Disable Real Time Bus master mode

#define ADRAIBM_TRANSFERSIZE 0x23  // Size of the transmitted data 

// Counter defines

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

//-----------------------------------------------------------------------
// UCT Subsystem Level/Latch (UctStatus) Bits
//-----------------------------------------------------------------------
#define UTB_LEVEL0      (1L<<0)  // UCT 0 Output Level
#define UTB_LEVEL1      (1L<<1)  // UCT 1 Output Level
#define UTB_LEVEL2      (1L<<2)  // UCT 2 Output Level
#define UTB_INTR0       (1L<<3)  // UCT 0 Latched Interrupt
#define UTB_INTR1       (1L<<4)  // UCT 1 Latched Interrupt
#define UTB_INTR2       (1L<<5)  // UCT 2 Latched Interrupt

#define UTB_Uct0Im      (1L<<0)  // UCT 0 Interrupt mask
#define UTB_Uct1Im      (1L<<1)  // UCT 1 Interrupt mask
#define UTB_Uct2Im      (1L<<2)  // UCT 2 Interrupt mask

#define UTB_Uct0IntrSC  (1L<<3)  // UCT 0 Interrupt Status/Clear
#define UTB_Uct1IntrSC  (1L<<4)  // UCT 1 Interrupt Status/Clear
#define UTB_Uct2IntrSC  (1L<<5)  // UCT 2 Interrupt Status/Clear

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
#define  UCT_RW16bit      (UCT_RW0 | UCT_RW1)

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

// Board hardware event words.
typedef struct
{
    unsigned int   Board;
    unsigned int   ADUIntr;
    unsigned int   AIOIntr;
    unsigned int   AInIntr;
    unsigned int   AOutIntr;

} TEvents, * PTEvents;

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
#define AIB_BMErrSC     (1L<<15) // Bus Master PRD Table Empty Error 
//----------------------------------
// Status only bits:
#define AIB_Enabled     (1L<<16) // AIn Enabled Status
#define AIB_Active      (1L<<17) // AIn Active (Started) Status
#define AIB_BMEnabled   (1L<<18) // AIn Bus Master Enabled Status
#define AIB_BMActive    (1L<<19) // AIn Bus Master Active (Started) Status

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

//-----------------------------------------------------------------------
// DSP PCI interface register ULONG offsets in PCI Memory Address Space:
//-----------------------------------------------------------------------
#define DSP_HCTR    0x0004      // DSP PCI Host Control Register
#define DSP_HSTR    0x0005      // DSP PCI Host Status Register
#define DSP_HCVR    0x0006      // DSP PCI Host Command Vector Register
#define DSP_HTXR    0x0007      // DSP PCI Host Transmit Data FIFO
#define DSP_HRXS    0x0007      // DSP PCI Host Slave Receive Data FIFO

#define HCVR_HNMI   0x0f        // Host Non Maskable Interrupt

// PCI HI32 Status Register (HSTR) Bits:
#define HSTR_TRDY   0x00        // Transmitter Ready
#define HSTR_HTRQ   0x01        // Host Transmit Data Request
#define HSTR_HRRQ   0x02        // Host Receive Data Request
#define HSTR_HF     0x03        // Host Flags
#define HSTR_HINT   0x06        // Host Interrupt A
#define HSTR_HREQ   0x07        // Host Request

