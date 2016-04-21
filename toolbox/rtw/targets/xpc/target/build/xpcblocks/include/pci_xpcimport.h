/* $Revision: 1.6 $ */
/* $Date: 2002/03/25 04:13:59 $ */

/* Abstract: PCI-bus functions imported from kernel
*
*  Copyright 1996-2002 The MathWorks, Inc.
*
*/
 
/* 
 * $Log: pci_xpcimport.h,v $
 * Revision 1.6  2002/03/25 04:13:59  batserve
 * Copyright fix in all the files Related Records: . Code Reviewer: rroy
 *
 * Revision 1.6  2002/03/20 20:44:28  ekbas
 * Copyright fix in all the files
 * Related Records: .
 * Code Reviewer: rroy
 *
 * Revision 1.5  2001/04/27 22:53:04  shaishaa
 * Update CopyRights
 * Code Reviewer: Rajiv,Michael
 *
 * Revision 1.4  2001/04/06 15:20:37  rroy
 * ifdef guard added.
 *
 * Revision 1.3  2000/03/17 20:15:00  mvetsch
 * WEB server, Broadcast Memory, GPIB (Beta5)
 *
 * Revision 1.2  1999/08/31 20:43:13  mvetsch
 * neccessary changes for future support of Visual C/C++
 *
 * Related Records: 66451
 *
 * Revision 1.1.1.1  1999/08/31 18:27:53  mvetsch
 * Branch 1.1.1.1 forced from 1.1 for R11
 *
 * Revision 1.1  1999/07/06 17:36:28  mvetsch
 * Initial revision
 *
 */

#ifndef __PCI_XPCIMPORT_H__
#define __PCI_XPCIMPORT_H__

typedef struct PCIDeviceInfoStruct{
    unsigned long BaseAddress[6];
    unsigned short AddressSpaceIndicator[6];
    unsigned short MemoryType[6];
    unsigned short Prefetchable[6];
    unsigned short InterruptLine;
} PCIDeviceInfo;

static  void (XPCCALLCONV * rl32eShowPCIDev)(void);
static  void (XPCCALLCONV * rl32eShowPCIInfo)(PCIDeviceInfo pciinfo);
static int (XPCCALLCONV * rl32eGetPCIInfo)(unsigned short vendor_id, unsigned short device_id, PCIDeviceInfo *pciinfo);
static int (XPCCALLCONV * rl32eGetPCIInfoAtSlot)(unsigned short vendor_id, unsigned short device_id, int slot, PCIDeviceInfo *pciinfo);
static int (XPCCALLCONV * xpceAssignPCIInterrupt)(unsigned short vendor_id, unsigned short device_id, unsigned short interruptLine);

#endif /* __PCI_XPCIMPORT_H__ */
