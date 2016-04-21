/* ======================================================================== */
/*  TEXAS INSTRUMENTS, INC.                                                 */
/*                                                                          */
/*  DSPLIB  DSP Signal Processing Library                                   */
/*                                                                          */
/*      Release:        Version 1.02                                        */
/*      CVS Revision:   1.6     Tue Mar 12 01:04:57 2002 (UTC)              */
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
/*  TEXAS INSTRUMENTS, INC.                                                 */
/*                                                                          */
/*  NAME                                                                    */
/*      DSP_fir_sym -- Symmetric FIR                                        */
/*                                                                          */
/*  REVISION DATE                                                           */
/*      11-Mar-2002                                                         */
/*                                                                          */
/*  USAGE                                                                   */
/*      This function is C callable, and may be called as follows:          */
/*                                                                          */
/*      void DSP_fir_sym                                                    */
/*      (                                                                   */
/*          const short * x,      // Input samples                   //     */
/*          const short * h ,     // Filter taps                     //     */
/*          short * restrict r,   // Output samples                  //     */
/*          int nh,               // Number of symmetric filter taps //     */
/*          int nr,               // Number of output samples        //     */
/*          int s                 // Final output shift.             //     */
/*      );                                                                  */
/*                                                                          */
/*  DESCRIPTION                                                             */
/*      This function applies a symmetric filter to the input samples.      */
/*      The filter tap array h[] provides 'nh + 1' total filter taps.       */
/*      The filter tap at h[nh] forms the center point of the filter.       */
/*      The taps at h[nh - 1] through h[0] form a symmetric filter          */
/*      about this central tap.  The effective filter length is thus        */
/*      2*nh + 1 taps.                                                      */
/*                                                                          */
/*      The filter is performed on 16-bit data with 16-bit coefficients,    */
/*      accumulating intermediate results to 40-bit precision.  The         */
/*      accumulator is rounded and truncated according to the value         */
/*      provided in 's'.  This allows a variety of Q-points to be used.     */
/*                                                                          */
/*      Note that samples are added together before multiplication, and     */
/*      so overflow *may* result for large-scale values, despite the        */
/*      40-bit accumulation.                                                */
/*                                                                          */
/*  C CODE                                                                  */
/*      Below is a C code implementation without restrictions.  The         */
/*      optimized implementations have restrictions, as noted under         */
/*      "ASSUMPTIONS" and "MEMORY NOTE" below.                              */
/*                                                                          */
/*      void DSP_fir_sym                                                    */
/*      (                                                                   */
/*          const short * x,      // Input samples                   //     */
/*          const short * h ,     // Filter taps                     //     */
/*          short * restrict r,   // Output samples                  //     */
/*          int nh,               // Number of symmetric filter taps //     */
/*          int nr,               // Number of output samples        //     */
/*          int s                 // Final output shift.             //     */
/*      )                                                                   */
/*      {                                                                   */
/*          int  i, j;                                                      */
/*          long y0, round = (long) 1 << (s - 1);                           */
/*                                                                          */
/*          for (j = 0; j < nr; j++)                                        */
/*          {                                                               */
/*              y0 = round;                                                 */
/*                                                                          */
/*              for (i = 0; i < nh; i++)                                    */
/*                  y0 += ((short) (x[j + i] + x[j + 2 * nh - i])) * h[i];  */
/*                                                                          */
/*              y0 += x[j + nh] * h[nh];                                    */
/*                                                                          */
/*              r[j] = (int) (y0 >> s);                                     */
/*          }                                                               */
/*      }                                                                   */
/*                                                                          */
/*  ASSUMPTIONS                                                             */
/*      The optimized versions of this kernel may assume that nr is         */
/*      a multiple of 4 and nh is a multiple of 8.                          */
/*                                                                          */
/*  MEMORY NOTE.                                                            */
/*      The code assumes that 'x' and 'h' are double-word aligned, and      */
/*      that 'r' is word alignend.                                          */
/*                                                                          */
/*      The code expects the device to be in LITTLE ENDIAN mode.            */
/*                                                                          */
/*  CYCLES                                                                  */
/*      cycles = (10 * nh/8 + 15) * nr/4 + 26                               */
/*                                                                          */
/*  CODESIZE                                                                */
/*      664 bytes                                                           */
/*                                                                          */
/* ------------------------------------------------------------------------ */
/*            Copyright (c) 2002 Texas Instruments, Incorporated.           */
/*                           All Rights Reserved.                           */
/* ======================================================================== */
#ifndef DSP_FIR_SYM_H_
#define DSP_FIR_SYM_H_ 1

void DSP_fir_sym
(
    const short * x,      /* Input samples                   */
    const short * h ,     /* Filter taps                     */
    short * restrict r,   /* Output samples                  */
    int nh,               /* Number of symmetric filter taps */
    int nr,               /* Number of output samples        */
    int s                 /* Final output shift.             */
);

#endif
/* ======================================================================== */
/*  End of file:  dsp_fir_sym.h                                             */
/* ------------------------------------------------------------------------ */
/*            Copyright (c) 2002 Texas Instruments, Incorporated.           */
/*                           All Rights Reserved.                           */
/* ======================================================================== */
