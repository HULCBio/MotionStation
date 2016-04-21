/* $Revision: 1.8 $ $Date: 2002/04/26 23:43:45 $ */
/* ======================================================================== */
/*  TEXAS INSTRUMENTS, INC.                                                 */
/*                                                                          */
/*  DSPLIB  DSP Signal Processing Library                                   */
/*                                                                          */
/*      Release:        Version 1.02                                        */
/*      CVS Revision:   1.5     Fri Mar 22 00:59:57 2002 (UTC)              */
/*      Snapshot date:  18-Apr-2002                                         */
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
/*                                                                          */
/*  TEXAS INSTRUMENTS, INC.                                                 */
/*                                                                          */
/*  NAME                                                                    */
/*      DSP_autocor                                                         */
/*                                                                          */
/*  REVISION DATE                                                           */
/*      21-Mar-2002                                                         */
/*                                                                          */
/*  USAGE                                                                   */
/*      This routine has the following C prototype:                         */
/*                                                                          */
/*      void DSP_autocor                                                    */
/*      (                                                                   */
/*          short       *restrict r,                                        */
/*          const short *restrict x,                                        */
/*          int          nx,                                                */
/*          int          nr                                                 */
/*      )                                                                   */
/*                                                                          */
/*      r[nr]   : Output array.                                             */
/*      x[nr+nx]: Input  array.                                             */
/*                Must be word aligned.                                     */
/*      nx      : Length of autocorrelation.                                */
/*                Must be multiple of 8.                                    */
/*      nr      : Number of lags.                                           */
/*                Must be multiple of 2.                                    */
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
/*      x[nr] word aligned.                                                 */
/*                                                                          */
/*    C CODE                                                                */
/*      void autcor(short r[],short x[], int nx, int nr)                    */
/*      {                                                                   */
/*          int i,k,sum;                                                    */
/*                                                                          */
/*          for (i = 0; i < nr; i++)                                        */
/*          {                                                               */
/*              sum = 0;                                                    */
/*              for (k = nr; k < nx+nr; k++)                                */
/*                  sum += x[k] * x[k-i];                                   */
/*              r[i] = (sum >> 15);                                         */
/*           }                                                              */
/*      }                                                                   */
/*                                                                          */
/*    TECHNIQUES                                                            */
/*      The inner loop is unrolled eight times thus the length of           */
/*      the input array must be a multiple of eight.  The outer             */
/*      loop is unrolled twice so the length of output array must           */
/*      be a multiple of 2.                                                 */
/*                                                                          */
/*      The outer loop is conditionally executed in parallel with the       */
/*      inner loop.  This allows for a zero overhead outer loop.            */
/*                                                                          */
/*    ASSUMPTIONS                                                           */
/*      nx must be a multiple of 8                                          */
/*      nr must be a multiple of 2                                          */
/*      x[] must be word aligned                                            */
/*      No alignment restrictions on r[]                                    */
/*                                                                          */
/*    MEMORY NOTE                                                           */
/*      nr/2 - 1 memory hits occur.                                         */
/*      This code is a LITTLE ENDIAN implementation.                        */
/*                                                                          */
/*    NOTES                                                                 */
/*      This code is interrupt tolerant but not interuptible.               */
/*                                                                          */
/*   CYCLES                                                                 */
/*       nr * nx /2 + 31 + (nr/2 - 1)                                       */
/*                                                                          */
/*       For nx = 24, nr =  8: 130 cycles                                   */
/*       For nx = 40, nr = 10: 237 cycles                                   */
/*                                                                          */
/*   CODESIZE                                                               */
/*        544 bytes                                                         */
/*                                                                          */
/* ------------------------------------------------------------------------ */
/*            Copyright (c) 2002 Texas Instruments, Incorporated.           */
/*                           All Rights Reserved.                           */
/* ======================================================================== */
#ifndef DSP_AUTOCOR_H_
#define DSP_AUTOCOR_H_ 1

void DSP_autocor
(
    short       *restrict r,
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
