/* Abstract: Asynchronous interrupt functions imported from kernel
 *
 *  Copyright 1996-2003 The MathWorks, Inc.
 *
 */
/* $Revision: 1.5.6.1 $  $Date: 2004/04/08 21:02:28 $ */

#ifndef __ASYNC_XPCIMPORT_H__
#define __ASYNC_XPCIMPORT_H__

#include "pci_xpcimport.h"

typedef void (*ISRHandler)(void);
typedef void (*HookFunc)(PCIDeviceInfo *);

static int (XPCCALLCONV *
            xpceRegisterISR)(unsigned char IRQ, ISRHandler handler,
                             HookFunc PreISR, HookFunc postISR,
                             int preemptable, int vendId, int deviceId,
                             int pciSlot);
static int (XPCCALLCONV *xpceDeRegisterISR)(unsigned char IRQ);

#endif /* __ASYNC_XPCIMPORT_H__ */
