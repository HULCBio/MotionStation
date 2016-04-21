/* $Revision: 1.8 $ $Date: 2002/04/26 23:45:01 $ */
/* ======================================================================== */
/*  TEXAS INSTRUMENTS, INC.                                                 */
/*                                                                          */
/*  DSPLIB  DSP Signal Processing Library                                   */
/*                                                                          */
/*      Release:        Version 1.02                                        */
/*      CVS Revision:   1.4     Fri Mar 29 21:10:31 2002 (UTC)              */
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
/*      DSP_w_vec: Weighted vector sum                                      */
/*                                                                          */
/*                                                                          */
/*  REVISION DATE                                                           */
/*      29-Mar-2002                                                         */
/*                                                                          */
/*  USAGE                                                                   */
/*      This routine is C-callable and can be called as:                    */
/*                                                                          */
/*          void DSP_w_vec                                                  */
/*          (                                                               */
/*              const short *x,     // Vector being weighted  //            */
/*              const short *y,     // Non-weighted vector    //            */
/*              short m,            // weighting factor       //            */
/*              short *restrict r,  // Result vector          //            */
/*              int nr              // Number of samples.     //            */
/*          );                                                              */
/*                                                                          */
/*  DESCRIPTION                                                             */
/*      The benchmark performs a weighted vector sum.  The elements         */
/*      of the x[] vector are weighted according to the Q15 value 'm',      */
/*      and then added to the corresponding elements of the y[] vector.     */
/*      The results are written to the r[] vector.                          */
/*                                                                          */
/*  C CODE                                                                  */
/*      The following is a C code description of the algorithm.  This       */
/*      implementation may have restrictions, as noted under                */
/*      "ASSUMPTIONS" below.                                                */
/*                                                                          */
/*          void DSP_w_vec                                                  */
/*          (                                                               */
/*              const short *x,     // Vector being weighted  //            */
/*              const short *y,     // Non-weighted vector    //            */
/*              short m,            // weighting factor       //            */
/*              short *restrict r,  // Result vector          //            */
/*              int nr              // Number of samples.     //            */
/*          )                                                               */
/*          {                                                               */
/*              int i;                                                      */
/*                                                                          */
/*              for (i = 0; i < nr; i++)                                    */
/*                  r[i] = ((m * x[i]) >> 15) + y[i];                       */
/*          }                                                               */
/*                                                                          */
/*  ASSUMPTIONS                                                             */
/*      m is not -32768.                                                    */
/*      nr >= 4, nr is multiple of four.                                    */
/*      Input and output arrays must be word aligned.                       */
/*                                                                          */
/*  MEMORY NOTE                                                             */
/*      No bank conflicts occur.                                            */
/*      This code is endian neutral.                                        */
/*                                                                          */
/*  TECHNIQUES                                                              */
/*      This loop is unrolled 4x to make full use of the available          */
/*      memory bandwidth.                                                   */
/*                                                                          */
/*      SMPY is used in conjunction with shifts and masks so that the       */
/*      m * x[i] terms may be packed pairs within 32-bit registers.  This   */
/*      allows us to use packed-data processing for the rest of the         */
/*      algorithm, thereby maximizing our load/store bandwidth.             */
/*                                                                          */
/*  NOTES                                                                   */
/*      This code is interrupt tolerant but not interruptible.              */
/*                                                                          */
/*  CYCLES                                                                  */
/*      3*nr/4 + 19                                                         */
/*      For nr = 256,  cycles = 211.                                        */
/*      For nr = 1000, cycles = 770.                                        */
/*                                                                          */
/*  CODESIZE                                                                */
/*      192 bytes                                                           */
/*                                                                          */
/*  SOURCE                                                                  */
/*      DSPLIB.                                                             */
/* ------------------------------------------------------------------------ */
/*            Copyright (c) 2002 Texas Instruments, Incorporated.           */
/*                           All Rights Reserved.                           */
/* ======================================================================== */
#ifndef DSP_W_VEC_H_
#define DSP_W_VEC_H_ 1

void DSP_w_vec
(
    const short *x,     /* Vector being weighted  */
    const short *y,     /* Non-weighted vector    */
    short m,            /* weighting factor       */
    short *restrict r,  /* Result vector          */
    int nr              /* Number of samples.     */
);

#endif
/* ======================================================================== */
/*  End of file:  dsp_w_vec.h                                               */
/* ------------------------------------------------------------------------ */
/*            Copyright (c) 2002 Texas Instruments, Incorporated.           */
/*                           All Rights Reserved.                           */
/* ======================================================================== */
