/* $Revision: 1.9 $ $Date: 2002/04/26 23:45:07 $ */
/* ======================================================================== */
/*  TEXAS INSTRUMENTS, INC.                                                 */
/*                                                                          */
/*  DSPLIB  DSP Signal Processing Library                                   */
/*                                                                          */
/*      Release:        Version 1.02                                        */
/*      CVS Revision:   1.4     Sun Mar 10 00:53:44 2002 (UTC)              */
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
/*      DSP_firlms2                                                         */
/*                                                                          */
/*  REVISION DATE                                                           */
/*      06-Mar-2002                                                         */
/*                                                                          */
/*  USAGE                                                                   */
/*      This routine is C-callable and can be called as:                    */
/*                                                                          */
/*      long DSP_firlms2                                                    */
/*      (                                                                   */
/*          short       *restrict h,    // Coefficient Array           //   */
/*          const short *restrict x,    // Input Array                 //   */
/*          short b,                    // Error of from previous FIR  //   */
/*          int   nh                    // Number of coefficients      //   */
/*      );                                                                  */
/*                                                                          */
/*  DESCRIPTION                                                             */
/*      This is an Least Mean Squared Adaptive FIR Filter.  Given the       */
/*      error from the previous sample and pointer to the next sample       */
/*      it computes an update of the coefficents and then performs          */
/*      the FIR for the given input. Coefficents h[], input x[] and error   */
/*      b are in Q.15 format. The output sample is returned as Q.30.        */
/*                                                                          */
/*      long DSP_firlms2                                                    */
/*      (                                                                   */
/*          short       *restrict h,                                        */
/*          const short *restrict x,                                        */
/*          short b,                                                        */
/*          int   nh                                                        */
/*      )                                                                   */
/*      {                                                                   */
/*          int  i;                                                         */
/*          long r = 0;                                                     */
/*                                                                          */
/*          for (i = 0; i < nh; i++)                                        */
/*          {                                                               */
/*              h[i] += (x[i    ] * b) >> 15;                               */
/*              r    +=  x[i + 1] * h[i];                                   */
/*          }                                                               */
/*                                                                          */
/*          return r;                                                       */
/*      }                                                                   */
/*                                                                          */
/*                                                                          */
/*  TECHNIQUES                                                              */
/*      The loop is unrolled once.                                          */
/*                                                                          */
/*  ASSUMPTIONS                                                             */
/*      The number of coefficients nh must be a multiple of 2.              */
/*                                                                          */
/*  MEMORY NOTE                                                             */
/*      This routine has no memory hits.                                    */
/*                                                                          */
/*  NOTES                                                                   */
/*      This routine is interupt-tolerant but not interruptible.            */
/*      This code is ENDIAN NEUTRAL.                                        */
/*                                                                          */
/*  CYCLES                                                                  */
/*      3 * nh/2 + 26                                                       */
/*      For nh = 24: 62 cycles                                              */
/*      For nh = 16: 50 cycles                                              */
/*                                                                          */
/*  CODESIZE                                                                */
/*      256 bytes.                                                          */
/*                                                                          */
/* ------------------------------------------------------------------------ */
/*            Copyright (c) 2002 Texas Instruments, Incorporated.           */
/*                           All Rights Reserved.                           */
/* ======================================================================== */
#ifndef DSP_FIRLMS2_H_
#define DSP_FIRLMS2_H_ 1

long DSP_firlms2
(
    short       *restrict h,    // Coefficient Array           //
    const short *restrict x,    // Input Array                 //
    short b,                    // Error of from previous FIR  //
    int   nh                    // Number of coefficients      //
);

#endif
/* ======================================================================== */
/*  End of file:  dsp_firlms2.h                                             */
/* ------------------------------------------------------------------------ */
/*            Copyright (c) 2002 Texas Instruments, Incorporated.           */
/*                           All Rights Reserved.                           */
/* ======================================================================== */
