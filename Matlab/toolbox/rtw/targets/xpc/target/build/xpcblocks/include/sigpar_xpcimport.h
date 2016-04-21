/* Abstract: Signal monitoring/Parameter tuning routine.
 *
 * Copyright 1996-2002 The MathWorks, Inc.
 */

/* $Revision: 1.2 $  $Date: 2002/03/25 04:14:11 $ */


#ifndef __SIGPAR_XPCIMPORT_H__
#define __SIGPAR_XPCIMPORT_H__

static double (XPCCALLCONV *xpceGetSignalValue)(int sigNo);
static void   (XPCCALLCONV *xpceSetParameter)(int parIdx, double *par);
static void   (XPCCALLCONV *xpceGetParameter)(int parIdx, double *par);

#endif /* __SIGPAR_XPCIMPORT_H__ */
