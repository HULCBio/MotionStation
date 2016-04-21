/* $Revision: 1.8 $ $Date: 2002/04/26 23:45:17 $ */
/* ======================================================================== */
/*  TEXAS INSTRUMENTS, INC.                                                 */
/*                                                                          */
/*  DSPLIB  DSP Signal Processing Library                                   */
/*                                                                          */
/*      Release:        Version 1.02                                        */
/*      CVS Revision:   1.5     Sun Mar 17 11:25:23 2002 (UTC)              */
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
/*    TEXAS INSTRUMENTS, INC.                                               */
/*                                                                          */
/*    NAME                                                                  */
/*          DSP_fir_gen                                                     */
/*                                                                          */
/*    REVISION DATE                                                         */
/*        15-Feb-2002                                                       */
/*                                                                          */
/*  USAGE                                                                   */
/*      This routine is C-callable and can be called as:                    */
/*                                                                          */
/*      void DSP_fir_gen                                                    */
/*      (                                                                   */
/*          const short *restrict x,                                        */
/*          const short *restrict h,                                        */
/*          short       *restrict r,                                        */
/*          int nh,                                                         */
/*          int nr                                                          */
/*      )                                                                   */
/*                                                                          */
/*      x[nr+nh-1] : Input array                                            */
/*      h[nh]      : Coefficient array. Must be in reverse order.           */
/*      r[nr]      : Output array                                           */
/*      nh         : Number of coefficients. Must be >= 5.                  */
/*      nr         : Number of output samples                               */
/*                                                                          */
/*  DESCRIPTION                                                             */
/*      Computes a real FIR filter (direct-form) using coefficients stored  */
/*      in vector h. The coefficients have to be arranged in reverse        */
/*      order. The real data input is stored in vector x. The filter        */
/*      output result is stored in vector r. It operates on 16-bit data     */
/*      with a 32-bit accumulate. The filter is nr output samples and nh    */
/*      coefficients.                                                       */
/*                                                                          */
/*  C CODE                                                                  */
/*      void DSP_fir_gen                                                    */
/*      (                                                                   */
/*          const short *restrict x,                                        */
/*          const short *restrict h,                                        */
/*          short       *restrict r,                                        */
/*          int nh,                                                         */
/*          int nr                                                          */
/*      )                                                                   */
/*      {                                                                   */
/*          int i, j, sum;                                                  */
/*                                                                          */
/*          for (j = 0; j < nr; j++)                                        */
/*          {                                                               */
/*              sum = 0;                                                    */
/*              for (i = 0; i < nh; i++)                                    */
/*                  sum += x[i + j] * h[i];                                 */
/*              r[j] = sum >> 15;                                           */
/*          }                                                               */
/*      }                                                                   */
/*                                                                          */
/*  TECHNIQUES                                                              */
/*      The inner loop is unrolled four times, but the last three           */
/*      accumulates are executed conditionally to allow for a number of     */
/*      coefficients that is not a multiple of four. The outer loop is      */
/*      unrolled twice, but the last store is executed conditionally to     */
/*      allow for a number of output samples that is not a multiple of      */
/*      two. Both the inner and outer loops are software pipelined.         */
/*                                                                          */
/*  ASSUMPTIONS                                                             */
/*      nh must be >= 5.                                                    */
/*                                                                          */
/*  MEMORY NOTE                                                             */
/*      No memory bank hits under any conditions.                           */
/*                                                                          */
/*  NOTES                                                                   */
/*     This function is interrupt-tolerant but not interruptible.           */
/*     This function is endian neutral.                                     */
/*                                                                          */
/*  CYCLES                                                                  */
/*      (4 * ceil(nh/4) + 9) *  ceil(nr/2) + 18                             */
/*                                                                          */
/*      For nh = 13, nr = 19: 268 cycles                                    */
/*                                                                          */
/*  CODESIZE                                                                */
/*      640 bytes                                                           */
/*                                                                          */
/* ------------------------------------------------------------------------ */
/*            Copyright (c) 2002 Texas Instruments, Incorporated.           */
/*                           All Rights Reserved.                           */
/* ======================================================================== */
#ifndef DSP_FIR_GEN_H_
#define DSP_FIR_GEN_H_ 1

void DSP_fir_gen
(
    const short *restrict x,
    const short *restrict h,
    short       *restrict r,
    int nh,
    int nr
);

#endif
/* ======================================================================== */
/*  End of file:  dsp_fir_gen.h                                             */
/* ------------------------------------------------------------------------ */
/*            Copyright (c) 2002 Texas Instruments, Incorporated.           */
/*                           All Rights Reserved.                           */
/* ======================================================================== */
