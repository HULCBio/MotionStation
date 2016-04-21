/*
 * Copyright 1994-2003 The MathWorks, Inc.
 *
 * File: ext_util.h     $Revision: 1.1.6.3 $
 *
 * Abstract:
 * Headers for utility functions in ext_util.c.
 */

extern void Copy32BitsToTarget(
    ExternalSim  *ES,
    char         *dst,
    const void   *src,
    const int    n);

extern void Copy32BitsFromTarget(
    ExternalSim *ES,
    void        *dst,
    const char  *src,
    const int    n);

extern void ProcessConnectResponse1(ExternalSim *ES, PktHeader *pktHdr);

extern void ProcessTargetDataSizes(ExternalSim *ES, uint32_T *bufPtr);

extern void InstallIntegerOnlyDoubleConversionRoutines(ExternalSim *ES);
