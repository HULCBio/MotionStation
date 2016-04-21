/* $Revision: 1.8 $ $Date: 2002/04/26 23:45:37 $ */
/* ======================================================================== */
/*  TEXAS INSTRUMENTS, INC.                                                 */
/*                                                                          */
/*  DSPLIB  DSP Signal Processing Library                                   */
/*                                                                          */
/*      Release:        Version 1.02                                        */
/*      CVS Revision:   1.4     Sun Mar 10 00:34:40 2002 (UTC)              */
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
/*          DSP_fltoq15                                                     */
/*                                                                          */
/*    REVISION DATE                                                         */
/*        27-Jul-2001                                                       */
/*                                                                          */
/*  USAGE                                                                   */
/*      This routine is C-callable and can be called as:                    */
/*                                                                          */
/*      void DSP_fltoq15                                                    */
/*      (                                                                   */
/*          const float *restrict x,                                        */
/*          short       *restrict r,                                        */
/*          int         nx                                                  */
/*      );                                                                  */
/*                                                                          */
/*      x[nx] :  Pointer to values of type float                            */
/*      r[nx] :  Contains Q15 values of x[nx]                               */
/*      nx    :  Number of elements in arrays                               */
/*                                                                          */
/*  DESCRIPTION                                                             */
/*      Convert the IEEE floating point numbers stored in vector x[] into   */
/*      Q.15 format numbers stored in vector r[]. Results will be rounded   */
/*      towards negative infinity. All values that exceed the size limit    */
/*      will be saturated to 0x7fff if value is positive and 0x8000 if      */
/*      value is negative.                                                  */
/*                                                                          */
/*  C CODE                                                                  */
/*      void DSP_fltoq15                                                    */
/*      (                                                                   */
/*          const float *restrict x,                                        */
/*          short       *restrict r,                                        */
/*          int         nx                                                  */
/*      )                                                                   */
/*      {                                                                   */
/*          int i, a;                                                       */
/*                                                                          */
/*          for(i = 0; i < nx; i++)                                         */
/*          {                                                               */
/*              a = floor(32768 * x[i]);                                    */
/*                                                                          */
/*              // saturate to 16-bit //                                    */
/*              if (a>32767)  a =  32767;                                   */
/*              if (a<-32768) a = -32768;                                   */
/*                                                                          */
/*              r[i] = (short) a;                                           */
/*          }                                                               */
/*      }                                                                   */
/*                                                                          */
/*  TECHNIQUES                                                              */
/*      Loop is unrolled twice.                                             */
/*      Collapsed 1 epilog stage, 2 prolog stages                           */
/*                                                                          */
/*  ASSUMPTIONS                                                             */
/*      nx >= 2 and a multiple of 2                                         */
/*                                                                          */
/*  NOTES                                                                   */
/*      This code is interrupt-tolerant but not interruptible.              */
/*      This implementation is ENDIAN NEUTRAL.                              */
/*                                                                          */
/*  CYCLES                                                                  */
/*      7 * nx/2 + 12                                                       */
/*                                                                          */
/*  CODESIZE                                                                */
/*      320 bytes                                                           */
/*                                                                          */
/* ------------------------------------------------------------------------ */
/*            Copyright (c) 2002 Texas Instruments, Incorporated.           */
/*                           All Rights Reserved.                           */
/* ======================================================================== */
#ifndef DSP_FLTOQ15_H_
#define DSP_FLTOQ15_H_ 1

void DSP_fltoq15
(
    const float *restrict x,
    short       *restrict r,
    int         nx
);

#endif
/* ======================================================================== */
/*  End of file:  dsp_fltoq15.h                                             */
/* ------------------------------------------------------------------------ */
/*            Copyright (c) 2002 Texas Instruments, Incorporated.           */
/*                           All Rights Reserved.                           */
/* ======================================================================== */
