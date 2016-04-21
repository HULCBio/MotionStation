/* $Revision: 1.8 $ $Date: 2002/04/26 23:45:32 $ */
/* ======================================================================== */
/*  TEXAS INSTRUMENTS, INC.                                                 */
/*                                                                          */
/*  DSPLIB  DSP Signal Processing Library                                   */
/*                                                                          */
/*      Release:        Version 1.02                                        */
/*      CVS Revision:   1.5     Fri Mar 22 02:07:52 2002 (UTC)              */
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
/*  TEXAS INSTRUMENTS, INC.                                                 */
/*                                                                          */
/*  NAME                                                                    */
/*      DSP_fir_sym: Symmetric FIR Filter                                   */
/*                                                                          */
/*  USAGE                                                                   */
/*      This routine is C-callable and can be called as:                    */
/*                                                                          */
/*      void DSP_fir_sym                                                    */
/*      (                                                                   */
/*          short *restrict x,                                              */
/*          short *restrict h,                                              */
/*          short *restrict r,                                              */
/*          int nh,                                                         */
/*          int nr,                                                         */
/*          int s                                                           */
/*      );                                                                  */
/*                                                                          */
/*      x[nr+2*nh] : Pointer to input array of size nr + 2*nh               */
/*      h[nh+1]    : Pointer to coefficient array of size nh + 1            */
/*     Must be word aligned.                                                */
/*      r[nr]      : Pointer to output array of size nr                     */
/*      nh         : Number of coefficients.                                */
/*                   Must be multiple of 8.                                 */
/*      nr         : Number of output samples.                              */
/*                   Must be multiple of 2.                                 */
/*      s          : Number of insignificant digits to truncate             */
/*                                                                          */
/*  DESCRIPTION                                                             */
/*      This symmetric FIR filter assumes the number of filter              */
/*      coefficients is 2*nh + 1. It operates on 16-bit data with a 40-bit  */
/*      accumulation.  The filter computes nr output samples.               */
/*                                                                          */
/*  C CODE                                                                  */
/*      void DSP_fir_sym                                                    */
/*      (                                                                   */
/*          short *restrict x,                                              */
/*          short *restrict h,                                              */
/*          short *restrict r,                                              */
/*          int nh,                                                         */
/*          int nr,                                                         */
/*          int s                                                           */
/*      )                                                                   */
/*      {                                                                   */
/*          int     i, j;                                                   */
/*          long    y0;                                                     */
/*          long    round = (long) 1 << (s - 1);                            */
/*                                                                          */
/*          for (j = 0; j < nr; j++)                                        */
/*          {                                                               */
/*              y0 = round;                                                 */
/*                                                                          */
/*              for (i = 0; i < nh; i++)                                    */
/*                  y0 += (short) (x[j + i] + x[j + 2 * nh - i]) * h[i];    */
/*                                                                          */
/*              y0 += x[j + nh] * h[nh];                                    */
/*              r[j] = (int) (y0 >> s);                                     */
/*          }                                                               */
/*      }                                                                   */
/*                                                                          */
/*  TECHNIQUES                                                              */
/*      Load word instruction is used to simultaneously load two            */
/*      values from h[] in a single clock cycle.                            */
/*      The inner loop is unrolled eight times.                             */
/*      The outer loop is unrolled eight times.                             */
/*      Both the inner and outer loops are  software pipelined.             */
/*                                                                          */
/*  ASSUMPTIONS                                                             */
/*      This code is Little Endian.                                         */
/*      nh must be a multiple of 8 and >= 8.                                */
/*      nr must be a multiple of 2.                                         */
/*      h[] must be word-aligned.                                           */
/*                                                                          */
/*  MEMORY NOTE                                                             */
/*      No memory bank hits under any conditions.                           */
/*                                                                          */
/*  CYCLES                                                                  */
/*      (3 * nh/2 + 10) * nr/2 + 20                                         */
/*      For nh=24, nr=42: 986 cycles                                        */
/*                                                                          */
/*  CODESIZE                                                                */
/*      416 bytes                                                           */
/*                                                                          */
/* ------------------------------------------------------------------------ */
/*            Copyright (c) 2002 Texas Instruments, Incorporated.           */
/*                           All Rights Reserved.                           */
/* ======================================================================== */
#ifndef DSP_FIR_SYM_H_
#define DSP_FIR_SYM_H_ 1

void DSP_fir_sym
(
    short *restrict x,
    short *restrict h,
    short *restrict r,
    int nh,
    int nr,
    int s
);

#endif
/* ======================================================================== */
/*  End of file:  dsp_fir_sym.h                                             */
/* ------------------------------------------------------------------------ */
/*            Copyright (c) 2002 Texas Instruments, Incorporated.           */
/*                           All Rights Reserved.                           */
/* ======================================================================== */
