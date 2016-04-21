/* $Revision: 1.2 $ $Date: 2002/03/25 04:13:47 $ */
/* multialaim16.h - Constant definitions for the Analogic */
/* AIM16 A/D and discrete IO pc104 board.                 */
/* Copyright 1996-2002 The MathWorks, Inc. */

// Register map, register offsets from IO base address.
// These are all 16 bit registers.
#define CSR           0
#define ASR           2
#define DTR           4
#define TLR           6
#define TMR           8
#define GR1          10
#define GR2          12
#define DIOR         14
#define ADR          16

// Bits in the CSR
#define CSRGO        0x1
#define CSRSTRIG     0x2
#define CSRDMAST     0x4
#define CSRLSBOUT    0x8
#define CSRMSBOUT    0x10
#define CSROFFSET    0x20
#define CSRRESET     0x40
#define CSRDA        0x80
#define CSRUB        0x100
//#define CSRTC        0x200
#define CSREMPTY     0x400
//#define CSRHALF      0x800
//#define CSROVR       0x1000
#define CSRREADY     0x8000

// Bits in the ASR
#define ASRFIRST        0xf        // 4 bit field for first channel
#define ASRLAST        0xf0        // 4 bit field for the last channel
#define ASRTS         0x300
#define    ASRSOFT    0x000
#define    ASREXT     0x100
#define    ASRTIME    0x200
#define ASRMODE       0xc00
#define    ASRM0      0x000
#define    ASRM1      0x400
#define    ASRM2      0x800
#define    ASRM3      0xc00
#define ASRBURST     0x1000
#define ASRDIFF      0x2000
#define ASR16BIT     0x4000    // AIM16 if bit is set, AIM12 if not set
#define ASRFAST      0x8000    // 100 Khz converter if not set, 200 Khz if set.

// The DTR is just set to 0, we don't use any of the interrupting functionality.

