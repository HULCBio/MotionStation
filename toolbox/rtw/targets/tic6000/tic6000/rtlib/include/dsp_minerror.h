/* $Revision: 1.4 $ $Date: 2002/04/26 23:46:12 $ */
/* ======================================================================== */
/*  TEXAS INSTRUMENTS, INC.                                                 */
/*                                                                          */
/*  DSPLIB  DSP Signal Processing Library                                   */
/*                                                                          */
/*      Release:        Version 1.02                                        */
/*      CVS Revision:   1.4     Fri Mar 22 01:54:04 2002 (UTC)              */
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
/*      DSP_minerror                                                        */
/*                                                                          */
/*  REVISION DATE                                                           */
/*      08-Mar-2002                                                         */
/*                                                                          */
/*  USAGE                                                                   */
/*      This routine is C-callable and can be called as:                    */
/*                                                                          */
/*      int DSP_minerror                                                    */
/*      (                                                                   */
/*          const short *restrict GSP0_TABLE,                               */
/*          short       *restrict errCoefs,                                 */
/*          int         *restrict max_index                                 */
/*      );                                                                  */
/*                                                                          */
/*      GSP0_TABLE[256*9] :  Pointer to GSP0 terms array.                   */
/*                           Must be word aligned.                          */
/*      errCoefs[9]       :  Array of error coefficients.                   */
/*                           Must be word aligned.                          */
/*      max_index         :  Index to GSP0_TABLE[max_index], the first      */
/*                           element of the 9-element vector that resulted  */
/*                           in the maximum dot product.                    */
/*      return int        :  Maximum dot product result.                    */
/*                                                                          */
/*  DESCRIPTION                                                             */
/*      Performs a dot product on 256 pairs of 9 element vectors and        */
/*      searches for the pair of vectors which produces the maximum dot     */
/*      product result. This is a large part of the VSELP vocoder codebook  */
/*      search.                                                             */
/*                                                                          */
/*  C CODE                                                                  */
/*      This is the C equivalent of the assembly code without restrictions  */
/*      Note that the assembly code is hand optimized and restrictions may  */
/*      apply.                                                              */
/*                                                                          */
/*      int DSP_minerror                                                    */
/*      (                                                                   */
/*          const short *restrict GSP0_TABLE,                               */
/*          short       *restrict errCoefs,                                 */
/*          int         *restrict max_index                                 */
/*      )                                                                   */
/*      {                                                                   */
/*          int val, maxVal = -50;                                          */
/*          int i, j;                                                       */
/*                                                                          */
/*          for (i = 0; i < GSP0_NUM; i++)                                  */
/*          {                                                               */
/*              for (val = 0, j = 0; j < GSP0_TERMS; j++)                   */
/*                  val += GSP0_TABLE[i*GSP0_TERMS+j] * errCoefs[j];        */
/*                                                                          */
/*              if (val > maxVal)                                           */
/*              {                                                           */
/*                  maxVal = val;                                           */
/*                  *max_index = i*GSP0_TERMS;                              */
/*              }                                                           */
/*          }                                                               */
/*                                                                          */
/*          return (maxVal);                                                */
/*      }                                                                   */
/*                                                                          */
/*  TECHNIQUES                                                              */
/*      Inner loop is completely unrolled.                                  */
/*      Word-wide loads are used to read in GSP0_TABLE and errCoefs.        */
/*                                                                          */
/*  ASSUMPTIONS                                                             */
/*      Arrays GSP0_TABLE[] and errCoefs[] must be word aligned.            */
/*                                                                          */
/*  MEMORY NOTE                                                             */
/*      Align GSP0_TABLE[] and errCoefs[] at different memory banks to      */
/*      avoid 4 bank conflicts.                                             */
/*                                                                          */
/*  NOTES                                                                   */
/*      This code is LITTLE ENDIAN.                                         */
/*      This code is interrupt-tolerant but not interruptible.              */
/*                                                                          */
/*  CYCLES                                                                  */
/*     1189                                                                 */
/*                                                                          */
/*  CODESIZE                                                                */
/*      576 bytes                                                           */
/*                                                                          */
/* ------------------------------------------------------------------------ */
/*            Copyright (c) 2002 Texas Instruments, Incorporated.           */
/*                           All Rights Reserved.                           */
/* ======================================================================== */
#ifndef DSP_MINERROR_H_
#define DSP_MINERROR_H_ 1

int DSP_minerror
(
    const short *restrict GSP0_TABLE,
    short       *restrict errCoefs,
    int         *restrict max_index
);

#endif
/* ======================================================================== */
/*  End of file:  dsp_minerror.h                                            */
/* ------------------------------------------------------------------------ */
/*            Copyright (c) 2002 Texas Instruments, Incorporated.           */
/*                           All Rights Reserved.                           */
/* ======================================================================== */
