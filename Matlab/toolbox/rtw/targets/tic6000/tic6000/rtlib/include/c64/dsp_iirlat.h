/* ======================================================================== */
/*  TEXAS INSTRUMENTS, INC.                                                 */
/*                                                                          */
/*  DSPLIB  DSP Signal Processing Library                                   */
/*                                                                          */
/*      Release:        Version 1.02                                        */
/*      CVS Revision:   1.2     Wed Apr 17 16:06:59 2002 (UTC)              */
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
/*      DSP_iirlat                                                          */
/*                                                                          */
/*  REVISION DATE                                                           */
/*      15-Apr-2002                                                         */
/*                                                                          */
/*  USAGE                                                                   */
/*      This routine is C Callable and can be called as:                    */
/*                                                                          */
/*      void DSP_iirlat                                                     */
/*      (                                                                   */
/*          short       *x,                                                 */
/*          int          nx,                                                */
/*          const short *restrict k,                                        */
/*          int          nk,                                                */
/*          int         *restrict b,                                        */
/*          short       *r                                                  */
/*      );                                                                  */
/*                                                                          */
/*      x[nx]   : Input vector (16-bit)                                     */
/*      nx      : Length of input vector.                                   */
/*      k[nk]   : Reflection coefficients in Q.15 format                    */
/*      nk      : Number of reflection coefficients/lattice stages          */
/*                Must be multiple of 2 and >=10.                           */
/*      b[nk+1] : Delay line elements from previous call. Should be         */
/*                initialized to all zeros prior to the first call.         */
/*      r[nx]   : Output vector (16-bit)                                    */
/*                                                                          */
/*  DESCRIPTION                                                             */
/*      This routine implements a real all-pole IIR filter in lattice       */
/*      structure (AR lattice). The filter consists of nk lattice stages.   */
/*      Each stage requires one reflection coefficient k and one delay      */
/*      element b. The routine takes an input vector x[] and returns the    */
/*      filter output in r[]. Prior to the first call of the routine the    */
/*      delay elements in b[] should be set to zero. The input data may     */
/*      have to be pre-scaled to avoid overflow or achieve better SNR. The  */
/*      reflections coefficients lie in the range -1.0 < k < 1.0. The       */
/*      order of the coefficients is such that k[nk-1] corresponds to the   */
/*      first lattice stage after the input and k[0] corresponds to the     */
/*      last stage.                                                         */
/*                                                                          */
/*  C CODE                                                                  */
/*      void DSP_iirlat                                                     */
/*      (                                                                   */
/*          short       *x,                                                 */
/*          int         nx,                                                 */
/*          const short *restrict k,                                        */
/*          int         nk,                                                 */
/*          int         *restrict b,                                        */
/*          short       *r                                                  */
/*      )                                                                   */
/*      {                                                                   */
/*          int rt;     // output       //                                  */
/*          int i, j;                                                       */
/*                                                                          */
/*          for (j=0; j<nx; j++)                                            */
/*          {                                                               */
/*              rt = x[j] << 15;                                            */
/*                                                                          */
/*              for (i = nk - 1; i >= 0; i--)                               */
/*              {                                                           */
/*                  rt       = rt   - (short)(b[i] >> 15) * k[i];           */
/*                  b[i + 1] = b[i] + (short)(rt   >> 15) * k[i];           */
/*              }                                                           */
/*                                                                          */
/*              b[0] = rt;                                                  */
/*                                                                          */
/*              r[j] = rt >> 15;                                            */
/*          }                                                               */
/*      }                                                                   */
/*                                                                          */
/*  TECHNIQUES                                                              */
/*      Prolog and epilog of the inner loop are partially collapsed         */
/*      and overlapped to reduce outer loop overhead.                       */
/*                                                                          */
/*  ASSUMPTIONS                                                             */
/*      - nk must be a multiple of 2 and >= 10.                             */
/*      - no special alignment requirements                                 */
/*                                                                          */
/*  MEMORY NOTE                                                             */
/*      No bank conflicts occur.                                            */
/*                                                                          */
/*  NOTES                                                                   */
/*      This code is interrupt-tolerant but not interruptible.              */
/*      This code is ENDIAN NEUTRAL                                         */
/*                                                                          */
/*  CYCLES                                                                  */
/*      (2 * nk + 7) * nx + 9                                               */
/*                                                                          */
/*  CODESIZE                                                                */
/*      360 bytes                                                           */
/*                                                                          */
/* ------------------------------------------------------------------------ */
/*            Copyright (c) 2002 Texas Instruments, Incorporated.           */
/*                           All Rights Reserved.                           */
/* ======================================================================== */
#ifndef DSP_IIRLAT_H_
#define DSP_IIRLAT_H_ 1

void DSP_iirlat
(
    short       *x,
    int          nx,
    const short *restrict k,
    int          nk,
    int         *restrict b,
    short       *r
);

#endif
/* ======================================================================== */
/*  End of file:  dsp_iirlat.h                                              */
/* ------------------------------------------------------------------------ */
/*            Copyright (c) 2002 Texas Instruments, Incorporated.           */
/*                           All Rights Reserved.                           */
/* ======================================================================== */
