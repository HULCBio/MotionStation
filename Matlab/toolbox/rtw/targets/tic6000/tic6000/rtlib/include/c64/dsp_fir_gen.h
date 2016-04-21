/* ======================================================================== */
/*  TEXAS INSTRUMENTS, INC.                                                 */
/*                                                                          */
/*  DSPLIB  DSP Signal Processing Library                                   */
/*                                                                          */
/*      Release:        Version 1.02                                        */
/*      CVS Revision:   1.11    Sun Mar 10 01:00:59 2002 (UTC)              */
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
/*                                                                          */
/*  TEXAS INSTRUMENTS, INC.                                                 */
/*                                                                          */
/*  NAME                                                                    */
/*      DSP_fir_gen: FIR Filter (general purpose)                           */
/*                                                                          */
/*  USAGE                                                                   */
/*      This routine is C-callable and can be called as:                    */
/*                                                                          */
/*      void DSP_fir_gen                                                    */
/*      (                                                                   */
/*          const short *restrict x,  // Input ('nr + nh - 1' samples) //   */
/*          const short *restrict h,  // Filter coefficients (nh taps) //   */
/*          short       *restrict r,  // Output array ('nr' samples)   //   */
/*          int                   nh, // Length of filter (nh >= 5)    //   */
/*          int                   nr  // Length of output (nr >= 1)    //   */
/*      );                                                                  */
/*                                                                          */
/*  C CODE                                                                  */
/*                                                                          */
/*      This is the C equivalent of the assembly code. Note that the        */
/*      assembly code is hand optimized and restrictions may apply.         */
/*                                                                          */
/*      void DSP_fir_gen                                                    */
/*      (                                                                   */
/*          const short *restrict x,  // Input ('nr + nh - 1' samples) //   */
/*          const short *restrict h,  // Filter coefficients (nh taps) //   */
/*          short       *restrict r,  // Output array ('nr' samples)   //   */
/*          int                   nh, // Length of filter (nh >= 5)    //   */
/*          int                   nr  // Length of output (nr >= 1)    //   */
/*      )                                                                   */
/*      {                                                                   */
/*          int i, j, sum;                                                  */
/*                                                                          */
/*          for (j = 0; j < nr; j++)                                        */
/*          {                                                               */
/*              sum = 0;                                                    */
/*              for (i = 0; i < nh; i++)                                    */
/*                  sum += x[i + j] * h[i];                                 */
/*                                                                          */
/*              r[j] = sum >> 15;                                           */
/*          }                                                               */
/*      }                                                                   */
/*                                                                          */
/*  DESCRIPTION                                                             */
/*      Computes a real FIR filter (direct-form) using coefficients         */
/*      stored in vector h. The real data input is stored in vector x.      */
/*      The filter output result is stored in vector r. This FIR            */
/*      assumes the number of filter coefficients is greater than or        */
/*      equal to 5. It operates on 16-bit data with a 32-bit                */
/*      accumulate. This routine has no memory hits regardless of where     */
/*      x, h, and r arrays are located in memory. The filter is nr          */
/*      output samples and nh coefficients. The assembly routine            */
/*      performs 4 output samples at a time.                                */
/*                                                                          */
/*  TECHNIQUES                                                              */
/*      1. Load double word instruction is used to simultaneously load      */
/*         four values in a single clock cycle.                             */
/*                                                                          */
/*      2. The inner loop is unrolled four times and will always            */
/*         compute a multiple of 4 of nh and nr. If nh % 4 != 0, the        */
/*         code will fill in 0s to make nh a multiple of 4. If nr % 4       */
/*         != 0, the code will still perform a mutiple of 4 outputs.        */
/*                                                                          */
/*      3. Both the inner and outer loops are software pipelined.           */
/*                                                                          */
/*      4. This code yields best performance when ratio of outer            */
/*         loop to inner loop is less than or equal to 4.                   */
/*                                                                          */
/*  ASSUMPTIONS                                                             */
/*      1. Little Endian is assumed for LDNDW.                              */
/*      2. nh >= 5.                                                         */
/*      3. nr multiple of 4.                                                */
/*      4. Output array r[] must be word-aligned                            */
/*                                                                          */
/*  MEMORY NOTE                                                             */
/*      No memory bank hits under any conditions.                           */
/*      Little Endian operation is assumed.                                 */
/*                                                                          */
/*  CYCLES                                                                  */
/*      [11 + 4 * ceil(nh/4)] * nr/4 + 15                                   */
/*                                                                          */
/*  CODESIZE                                                                */
/*      544  bytes                                                          */
/*                                                                          */
/* ------------------------------------------------------------------------ */
/*            Copyright (c) 2002 Texas Instruments, Incorporated.           */
/*                           All Rights Reserved.                           */
/* ======================================================================== */
#ifndef DSP_FIR_GEN_H_
#define DSP_FIR_GEN_H_ 1

void DSP_fir_gen
(
    const short *restrict x,  // Input ('nr + nh - 1' samples) //
    const short *restrict h,  // Filter coefficients (nh taps) //
    short       *restrict r,  // Output array ('nr' samples)   //
    int                   nh, // Length of filter (nh >= 5)    //
    int                   nr  // Length of output (nr >= 1)    //
);

#endif
/* ======================================================================== */
/*  End of file:  dsp_fir_gen.h                                             */
/* ------------------------------------------------------------------------ */
/*            Copyright (c) 2002 Texas Instruments, Incorporated.           */
/*                           All Rights Reserved.                           */
/* ======================================================================== */
