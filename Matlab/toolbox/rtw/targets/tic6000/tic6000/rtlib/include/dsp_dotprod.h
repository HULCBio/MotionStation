/* $Revision: 1.8 $ $Date: 2002/04/26 23:44:20 $ */
/* ======================================================================== */
/*  TEXAS INSTRUMENTS, INC.                                                 */
/*                                                                          */
/*  DSPLIB  DSP Signal Processing Library                                   */
/*                                                                          */
/*      Release:        Version 1.02                                        */
/*      CVS Revision:   1.4     Wed Apr 17 15:49:07 2002 (UTC)              */
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
/*      DSP_dotprod                                                         */
/*                                                                          */
/*  REVISION DATE                                                           */
/*      29-Mar-2002                                                         */
/*                                                                          */
/*  USAGE                                                                   */
/*      This routine is C-callable and can be called as:                    */
/*                                                                          */
/*          int DSP_dotprod                                                 */
/*          (                                                               */
/*              const short *x,    // first input vector  //                */
/*              const short *y,    // second input vector //                */
/*              int nx             // number of elements  //                */
/*          );                                                              */
/*                                                                          */
/*                                                                          */
/*  DESCRIPTION                                                             */
/*      This routine takes two vectors and calculates their vector          */
/*      product.  The inputs are 16-bit number, and the result is           */
/*      a 32-bit number.                                                    */
/*                                                                          */
/*      This is the C equivalent of the assembly code without restrictions: */
/*      Note that the assembly code is hand optimized and restrictions may  */
/*      apply.                                                              */
/*                                                                          */
/*          int DSP_dotprod                                                 */
/*          (                                                               */
/*              const short *x,                                             */
/*              const short *y,                                             */
/*              int nx                                                      */
/*          )                                                               */
/*          {                                                               */
/*              int sum = 0, i;                                             */
/*                                                                          */
/*              for (i = 0; i < nx; i++)                                    */
/*                  sum += x[i] * y[i];                                     */
/*                                                                          */
/*              return sum;                                                 */
/*          }                                                               */
/*                                                                          */
/*  TECHNIQUES                                                              */
/*      Load words are used to load two 16-bit values at a time.            */
/*      The loop is unrolled once.                                          */
/*                                                                          */
/*  ASSUMPTIONS                                                             */
/*      nx must be a multiple of 2 and greater than 2.                      */
/*      Vectors x and y must be aligned on word boundaries.                 */
/*                                                                          */
/*  MEMORY NOTE                                                             */
/*      Vectors x and y should be aligned on opposite memory banks          */
/*      to avoid memory hits. Example:                                      */
/*          #pragma DATA_MEM_BANK(x, 0)                                     */
/*          #pragma DATA_MEM_BANK(y, 2)                                     */
/*                                                                          */
/*  NOTES                                                                   */
/*      This code is ENDIAN NEUTRAL.                                        */
/*      This code is interrupt-tolerant but not interruptible.              */
/*                                                                          */
/*  CYCLES                                                                  */
/*     nx/2 + 12                                                            */
/*     For nx = 40: 32 cycles                                               */
/*                                                                          */
/*  CODESIZE                                                                */
/*     160 bytes                                                            */
/*                                                                          */
/* ------------------------------------------------------------------------ */
/*            Copyright (c) 2002 Texas Instruments, Incorporated.           */
/*                           All Rights Reserved.                           */
/* ======================================================================== */
#ifndef DSP_DOTPROD_H_
#define DSP_DOTPROD_H_ 1

int DSP_dotprod
(
    const short *x,    /* first input vector  */
    const short *y,    /* second input vector */
    int nx             /* number of elements  */
);

#endif
/* ======================================================================== */
/*  End of file:  dsp_dotprod.h                                             */
/* ------------------------------------------------------------------------ */
/*            Copyright (c) 2002 Texas Instruments, Incorporated.           */
/*                           All Rights Reserved.                           */
/* ======================================================================== */
