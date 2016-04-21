/* ======================================================================== */
/*  TEXAS INSTRUMENTS, INC.                                                 */
/*                                                                          */
/*  DSPLIB  DSP Signal Processing Library                                   */
/*                                                                          */
/*      Release:        Version 1.02                                        */
/*      CVS Revision:   1.7     Fri Mar 22 00:59:23 2002 (UTC)              */
/*      Snapshot date:  17-Apr-2002                                         */
/*                                                                          */
/*  This library contains proprietary intellectual property of Texas        */
/*  Instruments, Inc.  The library and its source code are protected by     */
/*  various copyrights, and portions may also be protected by patents or    */
/*  other legal protections.                                                */
/*                                                                          */
/*  This software is licensed for use with Texas Instruments TMS320         */
/*  family DSPs.  This license was provided to you prior to installing      */
/*  the software.  You may review this license by consulting the file       */
/*  TI_license.PDF which accompanies the files in this library.             */
/* ------------------------------------------------------------------------ */
/*          Copyright (C) 2002 Texas Instruments, Incorporated.             */
/*                          All Rights Reserved.                            */
/* ======================================================================== */
/* ======================================================================== */
/*  NAME                                                                    */
/*      DSP_autocor -- Autocorrelation                                      */
/*                                                                          */
/*  REVISION DATE                                                           */
/*      21-Jan-2002                                                         */
/*                                                                          */
/*  USAGE                                                                   */
/*      This routine has the following C prototype:                         */
/*                                                                          */
/*      void DSP_autocor                                                    */
/*      (                                                                   */
/*          short *restrict r,                                              */
/*          const short *restrict x,                                        */
/*          int          nx,                                                */
/*          int          nr                                                 */
/*      )                                                                   */
/*                                                                          */
/*      r[nr]   : output array                                              */
/*      x[nr+nx]: input  array                                              */
/*      nx      : length of autocorrelation                                 */
/*      nr      : number of lags                                            */
/*                                                                          */
/*  DESCRIPTION                                                             */
/*      This routine performs an autocorrelation of an input vector         */
/*      x. The length of the autocorrelation is nx samples. Since nr        */
/*      such autocorrelations are performed, input vector x needs to be     */
/*      of length nx + nr. This produces nr output results which are        */
/*      stored in an output array r.                                        */
/*                                                                          */
/*      The following diagram illustrates how the correlations are          */
/*      obtained.                                                           */
/*                                                                          */
/*      Example for nr=8, nx=24:                                            */
/*      0       nr                  nx+nr-1                                 */
/*      |-------|----------------------|  <- x[]                            */
/*      |       |----------------------|  -> r[0]                           */
/*      |      |----------------------|   -> r[1]                           */
/*      |     |----------------------|    -> r[2]                           */
/*      |    |----------------------|     -> r[3]                           */
/*      |   |----------------------|      -> r[4]                           */
/*      |  |----------------------|       -> r[5]                           */
/*      | |----------------------|        -> r[6]                           */
/*                                                                          */
/*      Note that x[0] is never used, but is required for padding to make   */
/*      x[nr] double-word aligned.                                          */
/*                                                                          */
/*    TECHNIQUES                                                            */
/*      Loop coalescing is implemented and both loops are colesced          */
/*      together. Separate copies of inner loop counter are made to         */
/*      de-couple input loads and output stores. Double word wide loads     */
/*      are used on the input data array.                                   */
/*                                                                          */
/*    ASSUMPTIONS                                                           */
/*      nx is a multiple of 8                                               */
/*      nr is a multiple of 4                                               */
/*      x[] is double-word aligned                                          */
/*      No alignment restrictions on r[]                                    */
/*                                                                          */
/*    MEMORY NOTE                                                           */
/*      No memory bank hits under any conditions.                           */
/*      This code is a LITTLE ENDIAN implementation.                        */
/*                                                                          */
/*    NOTES                                                                 */
/*      This code is interrupt tolerant but not interuptible                */
/*                                                                          */
/*   CYCLES                                                                 */
/*      nx*nr/4 + 19                                                        */
/*                                                                          */
/*      e.g. nx=160, nr=32, cycles=1299                                     */
/*                                                                          */
/*   CODESIZE                                                               */
/*      496 bytes                                                           */
/*                                                                          */
/* ------------------------------------------------------------------------ */
/*            Copyright (c) 2002 Texas Instruments, Incorporated.           */
/*                           All Rights Reserved.                           */
/* ======================================================================== */
#ifndef DSP_AUTOCOR_H_
#define DSP_AUTOCOR_H_ 1

void DSP_autocor
(
    short *restrict r,
    const short *restrict x,
    int          nx,
    int          nr
);

#endif
/* ======================================================================== */
/*  End of file:  dsp_autocor.h                                             */
/* ------------------------------------------------------------------------ */
/*            Copyright (c) 2002 Texas Instruments, Incorporated.           */
/*                           All Rights Reserved.                           */
/* ======================================================================== */
