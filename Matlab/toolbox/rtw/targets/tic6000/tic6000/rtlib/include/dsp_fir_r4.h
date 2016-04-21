/* $Revision: 1.8 $ $Date: 2002/04/26 23:45:22 $ */
/* ======================================================================== */
/*  TEXAS INSTRUMENTS, INC.                                                 */
/*                                                                          */
/*  DSPLIB  DSP Signal Processing Library                                   */
/*                                                                          */
/*      Release:        Version 1.02                                        */
/*      CVS Revision:   1.4     Fri Mar 22 01:51:54 2002 (UTC)              */
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
/*      DSP_fir_r4                                                          */
/*                                                                          */
/*  REVISION DATE                                                           */
/*      25-Feb-2002                                                         */
/*                                                                          */
/*  USAGE                                                                   */
/*      This routine is C-callable and can be called as:                    */
/*                                                                          */
/*      void DSP_fir_r4                                                     */
/*      (                                                                   */
/*          const short *x,                                                 */
/*          const short *h,                                                 */
/*          short       *r,                                                 */
/*          int nh,                                                         */
/*          int nr                                                          */
/*      );                                                                  */
/*                                                                          */
/*      x[nr+nh-1]: Input samples.                                          */
/*      h[nh]     : Filter coefficients. Must be in reverse order.          */
/*      r[nr]     : Output samples.                                         */
/*      nh        : Number of filter coefficients.                          */
/*                  Must be multiple of 4 and >= 8.                         */
/*      nr        : Number of output samples.                               */
/*                  Must be multiple of 2.                                  */
/*                                                                          */
/*  DESCRIPTION                                                             */
/*      Computes a real FIR filter (direct-form) using coefficients stored  */
/*      in vector h.  The real data input is stored in vector x. The        */
/*      filter output is stored in vector r. The filter computes nr output  */
/*      samples and nh coefficients. It operates on 16-bit data with a      */
/*      32-bit accumulate.                                                  */
/*                                                                          */
/*  C CODE                                                                  */
/*      void DSP_fir_r4                                                     */
/*      (                                                                   */
/*          const short *x,                                                 */
/*          const short *h,                                                 */
/*          short       *r,                                                 */
/*          int nh,                                                         */
/*          int nr                                                          */
/*      )                                                                   */
/*      {                                                                   */
/*         int i, j, sum;                                                   */
/*                                                                          */
/*         for (j = 0; j < nr; j++)                                         */
/*         {                                                                */
/*            sum = 0;                                                      */
/*            for (i = 0; i < nh; i++)                                      */
/*              sum += x[i + j] * h[i];                                     */
/*            r[j] = sum >> 15;                                             */
/*         }                                                                */
/*      }                                                                   */
/*                                                                          */
/*                                                                          */
/*  ASSUMPTIONS                                                             */
/*      nh must be a multiple of 4 and >= 8.                                */
/*      nr must be a multiple of 2 and >= 2.                                */
/*                                                                          */
/*  MEMORY NOTE                                                             */
/*      No memory bank hits under any conditions.                           */
/*      This code is Endian neutral.                                        */
/*                                                                          */
/*  TECHNIQUES                                                              */
/*      The assembly routine performs 2 output samples at a time.           */
/*      The inner loop is unrolled four times.  The outer loop is unrolled  */
/*      twice. Both the inner and outer loops are software pipelined.       */
/*                                                                          */
/*  CYCLES                                                                  */
/*      (8 + nh) * nr/2 + 14                                                */
/*                                                                          */
/*  CODESIZE                                                                */
/*      544 bytes                                                           */
/*                                                                          */
/*                                                                          */
/* ------------------------------------------------------------------------ */
/*            Copyright (c) 2002 Texas Instruments, Incorporated.           */
/*                           All Rights Reserved.                           */
/* ======================================================================== */
#ifndef DSP_FIR_R4_H_
#define DSP_FIR_R4_H_ 1

void DSP_fir_r4
(
    const short *x,
    const short *h,
    short       *r,
    int nh,
    int nr
);

#endif
/* ======================================================================== */
/*  End of file:  dsp_fir_r4.h                                              */
/* ------------------------------------------------------------------------ */
/*            Copyright (c) 2002 Texas Instruments, Incorporated.           */
/*                           All Rights Reserved.                           */
/* ======================================================================== */
