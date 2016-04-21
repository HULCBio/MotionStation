/* $Revision: 1.9 $ $Date: 2002/04/26 23:46:22 $ */
/* ======================================================================== */
/*  TEXAS INSTRUMENTS, INC.                                                 */
/*                                                                          */
/*  DSPLIB  DSP Signal Processing Library                                   */
/*                                                                          */
/*      Release:        Version 1.02                                        */
/*      CVS Revision:   1.4     Fri Mar 29 19:40:03 2002 (UTC)              */
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
/*  NAME                                                                    */
/*      DSP_mul32                                                           */
/*                                                                          */
/*  REVISION DATE                                                           */
/*      29-Mar-2002                                                         */
/*                                                                          */
/*  USAGE                                                                   */
/*      This routine is C-callable and can be called as:                    */
/*                                                                          */
/*          void DSP_mul32                                                  */
/*          (                                                               */
/*              const int    *x,                                            */
/*              const int    *y,                                            */
/*              int *restrict r,                                            */
/*              int           nx                                            */
/*          );                                                              */
/*                                                                          */
/*          x[nx] = pointer to input vector 1 of size nx                    */
/*          y[nx] = pointer to input vector 2 of size nx                    */
/*          r[nx] = pointer to output vector of size nx                     */
/*          nx    = number of elements in input and output vectors          */
/*                                                                          */
/*                                                                          */
/*  DESCRIPTION                                                             */
/*      This routine performs a 32-bit by 32-bit multiply, returning the    */
/*      upper 32 bits of the 64-bit result.  This is equivalent to a        */
/*      Q31 x Q31 multiply, yielding a Q30 result.                          */
/*                                                                          */
/*  NOTES                                                                   */
/*      The 32 x 32 multiply is constructed from 16 x 16 multiplies.        */
/*      For efficiency reasons, the 'lo * lo' term of the 32 x 32           */
/*      multiply is omitted, as it has minimal impact on the final          */
/*      result.  This is due to the fact that the 'lo * lo' term            */
/*      primarily affects the lower 32 bits of the result, and these        */
/*      are not returned.  Due to this omission, the results of this        */
/*      function differ from the exact results of a 32 x 32 multiply by     */
/*      at most 1.                                                          */
/*                                                                          */
/*  ASSUMPTIONS                                                             */
/*      "nx" is at least 8 and is a multiple of 2.                          */
/*      Arrays x[], y[] and r[] must be word aligned.                       */
/*      Input and output arrays are independent of each other.              */
/*                                                                          */
/*  NOTES                                                                   */
/*      This code is ENDIAN NEUTRAL.                                        */
/*      This function is interrupt tolerant, but not interruptible.         */
/*                                                                          */
/*  CYCLES                                                                  */
/*      cycles = 1.5*nx + 24.                                               */
/*                                                                          */
/*  CODESIZE                                                                */
/*      224 bytes                                                           */
/* ------------------------------------------------------------------------ */
/*            Copyright (c) 2002 Texas Instruments, Incorporated.           */
/*                           All Rights Reserved.                           */
/* ======================================================================== */
#ifndef DSP_MUL32_H_
#define DSP_MUL32_H_ 1

void DSP_mul32
(
    const int    *x,
    const int    *y,
    int *restrict r,
    int           nx
);

#endif
/* ======================================================================== */
/*  End of file:  dsp_mul32.h                                               */
/* ------------------------------------------------------------------------ */
/*            Copyright (c) 2002 Texas Instruments, Incorporated.           */
/*                           All Rights Reserved.                           */
/* ======================================================================== */
