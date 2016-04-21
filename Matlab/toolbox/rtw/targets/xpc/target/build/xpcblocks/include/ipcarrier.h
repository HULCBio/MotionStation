/* $Revision: 1.2 $ */
/* 
   ipcarrier.c - constants for supported IP carrier boards

   Copyright 1996-2002 The MathWorks, Inc.
*/

#define SBS_VENDOR_ID (0x124b)

#define PCI40A_DEVICE_ID (0x0040)

// PCI-40A register word addresses
#define CNTL0        (0x280) 
#define CNTL1        (0x300)
#define CNTL2        (0x380)

// CNTL0 bits
#define CLR_AUTO     (0x10) 
#define AUTO_ACK     (0x20) 

// CNTL2 bits
#define AUTO_INT_SET (0x40) 

#define SLOT_OFS     (0x800) // words
#define SLOT_LEN     (0x800) // words
#define ID_PROM      (0x80)  // word

// Flex/104A registers
#define DATA(base)   (base + 0) // Data
#define ACCESS(base) (base + 2) // IP Access 
#define UPADDR(base) (base + 4) // Upper Address 
#define CSR(base)    (base + 6) // Control and Status 

// Flex/104A Control and Status bits
#define IRQ1B        (0x40)
#define IRQ1A        (0x20)
#define IPWAIT       (0x10)
#define TMSTAT       (0x08)
#define RSTSTAT      (0x04)
#define IRQ0B        (0x02)
#define TMRST        (0x02)
#define IPRST        (0x01)
#define IRQ0A        (0x01)

// Flex/104A IP Access bits
#define IOSPACE      (0) 
#define IDSPACE      (1 << 7)
#define INTSPACE     (1 << 7) 
#define SLOT(slot)   (((slot-1) & 1) << 8) // slot 1 = A = left, slot 2 = B = right

enum CarrierEnum
{
    undefined,
    SBS_PCI40A,
    SBS_FLEX104A
};

typedef enum CarrierEnum CarrierType;

