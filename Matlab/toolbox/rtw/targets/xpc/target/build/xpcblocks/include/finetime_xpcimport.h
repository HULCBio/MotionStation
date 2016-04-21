/* File:     finetime_xpcimport.h
 * Abstract: Fine time (Pentium counter) functions imported from kernel
 *
 *  Copyright 1996-2002 The MathWorks, Inc.
 *
 */
/* $Revision: 1.1 $  $Date: 2002/04/25 14:19:14 $ */

#ifndef __FINETIME_XPCIMPORT_H__
#define __FINETIME_XPCIMPORT_H__

typedef struct {
   unsigned long TimeLow;
   unsigned long TimeHigh;
} xPCFineTime;

static void (XPCCALLCONV *xpceFTReadTime)(xPCFineTime *T);
static void (XPCCALLCONV *xpceFTAdd)(     xPCFineTime *Res,
                                          xPCFineTime *T1, xPCFineTime *T2);
static void (XPCCALLCONV *xpceFTSubtract)(xPCFineTime *Res,
                                          xPCFineTime *T1, xPCFineTime *T2);
#endif /* __FINETIME_XPCIMPORT_H__ */
