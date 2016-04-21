/* $Revision: 1.8 $ $Date: 2002/04/26 23:44:46 $ */
/* ======================================================================== */
/*  TEXAS INSTRUMENTS, INC.                                                 */
/*                                                                          */
/*  DSPLIB  DSP Signal Processing Library                                   */
/*                                                                          */
/*      Release:        Version 1.02                                        */
/*      CVS Revision:   1.3     Fri Mar 22 02:08:27 2002 (UTC)              */
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
/*      DSP_radix2 -- In-place Radix-2 FFT (Little Endian)                  */
/*                                                                          */
/*  REVISION DATE                                                           */
/*      10-Dec-2001                                                         */
/*                                                                          */
/*  USAGE                                                                   */
/*      This routine is C-callable and can be called as:                    */
/*                                                                          */
/*      void DSP_radix2(int n, short *restrict xy,                          */
/*                  const short *restrict w);                               */
/*                                                                          */
/*      n    -- FFT size                            (input)                 */
/*      xy[] -- input and output sequences (dim-n)  (input/output)          */
/*      w[]  -- FFT coefficients (dim-n/2)          (input)                 */
/*                                                                          */
/*  DESCRIPTION                                                             */
/*      This routine is used to compute FFT of a complex sequece of size    */
/*      n, a power of 2, with "decimation-in-frequency decomposition"       */
/*      method, ie, the output is in bit-reversed order. Each complex       */
/*      value is with interleaved 16-bit real and imaginary parts. To       */
/*      prevent overflow, input samples may have to be scaled by 1/n.       */
/*                                                                          */
/*      void DSP_radix2(int n, short *restrict xy,                          */
/*                  const short *restrict w)                                */
/*      {                                                                   */
/*          short n1,n2,ie,ia,i,j,k,l;                                      */
/*          short xt,yt,c,s;                                                */
/*                                                                          */
/*          n2 = n;                                                         */
/*          ie = 1;                                                         */
/*          for (k=n; k > 1; k = (k >> 1) )                                 */
/*          {                                                               */
/*              n1 = n2;                                                    */
/*              n2 = n2>>1;                                                 */
/*              ia = 0;                                                     */
/*              for (j=0; j < n2; j++)                                      */
/*              {                                                           */
/*                  c = w[2*ia];                                            */
/*                  s = w[2*ia+1];                                          */
/*                  ia = ia + ie;                                           */
/*                  for (i=j; i < n; i += n1)                               */
/*                  {                                                       */
/*                      l = i + n2;                                         */
/*                      xt      = xy[2*l] - xy[2*i];                        */
/*                      xy[2*i] = xy[2*i] + xy[2*l];                        */
/*                      yt      = xy[2*l+1] - xy[2*i+1];                    */
/*                      xy[2*i+1] = xy[2*i+1] + xy[2*l+1];                  */
/*                      xy[2*l]   = (c*xt + s*yt)>>15;                      */
/*                      xy[2*l+1] = (c*yt - s*xt)>>15;                      */
/*                  }                                                       */
/*              }                                                           */
/*              ie = ie<<1;                                                 */
/*          }                                                               */
/*      }                                                                   */
/*                                                                          */
/*  ASSUMPTIONS                                                             */
/*      16 <= n <= 32768                                                    */
/*      Both input xy and coefficient w must be aligned on word boundary.   */
/*      w coef stored ordered is k*(-cos[0*delta]), k*(-sin[0*delta]),      */
/*      k*(-cos[1*delta]), ...  where delta = 2*PI/N, k = 32767             */
/*      Assembly code is written for processor in Little Endian mode        */
/*      Input xy and coefficients w are 16 bit data.                        */
/*                                                                          */
/*  MEMORY NOTE                                                             */
/*      Align xy and w on different word boundaries to minimize             */
/*      memory bank hits.                                                   */
/*                                                                          */
/*  TECHNIQUES                                                              */
/*      1. Loading input xy as well as coefficient w in word.               */
/*      2. Both loops j and i shown in the C code are placed in the         */
/*         INNERLOOP of the assembly code.                                  */
/*                                                                          */
/*  CYCLES                                                                  */
/*      cycles = log2(N) * (4*N/2+7) + 34 + N/4.                            */
/*                                                                          */
/*      (The N/4 term is due to bank conflicts that occur when xy and w     */
/*      are aligned as suggested above, under "MEMORY NOTE.")               */
/*                                                                          */
/*      For N = 256, cycles = 4250.                                         */
/*                                                                          */
/*  CODESIZE                                                                */
/*      800 bytes                                                           */
/*                                                                          */
/* ------------------------------------------------------------------------ */
/*            Copyright (c) 2002 Texas Instruments, Incorporated.           */
/*                           All Rights Reserved.                           */
/* ======================================================================== */
#ifndef DSP_RADIX2_H_
#define DSP_RADIX2_H_ 1

void DSP_radix2(int n, short *restrict xy,
            const short *restrict w);

#endif
/* ======================================================================== */
/*  End of file:  dsp_radix2.h                                              */
/* ------------------------------------------------------------------------ */
/*            Copyright (c) 2002 Texas Instruments, Incorporated.           */
/*                           All Rights Reserved.                           */
/* ======================================================================== */
