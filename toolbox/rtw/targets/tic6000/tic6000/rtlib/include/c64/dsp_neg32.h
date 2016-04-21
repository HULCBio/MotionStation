/* ======================================================================== */
/*  TEXAS INSTRUMENTS, INC.                                                 */
/*                                                                          */
/*  DSPLIB  DSP Signal Processing Library                                   */
/*                                                                          */
/*      Release:        Version 1.02                                        */
/*      CVS Revision:   1.5     Mon Dec 10 20:51:15 2001 (UTC)              */
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
/*      DSP_neg32                                                           */
/*                                                                          */
/*  REVISION DATE                                                           */
/*      10-Dec-2001                                                         */
/*                                                                          */
/*  USAGE                                                                   */
/*      This routine is C callable, and may be called using the following   */
/*      C function prototype:                                               */
/*                                                                          */
/*          void DSP_neg32                                                  */
/*          (                                                               */
/*              int   *x,      // Input data array     //                   */
/*              int   *r,      // Output data array    //                   */
/*              short nx       // Number of elements.  //                   */
/*          );                                                              */
/*                                                                          */
/*  DESCRIPTION                                                             */
/*      This routine negates an array of 32-bit integers, and stores        */
/*      the result either in a new array, or back to the same array.        */
/*                                                                          */
/*          void DSP_neg32                                                  */
/*          (                                                               */
/*              int   *x,      // Input data array     //                   */
/*              int   *r,      // Output data array    //                   */
/*              short nx       // Number of elements.  //                   */
/*          )                                                               */
/*          {                                                               */
/*              int i;                                                      */
/*                                                                          */
/*              for (i = 0; i < nx; i++)                                    */
/*                  r[i] = -x[i];                                           */
/*          }                                                               */
/*                                                                          */
/*  ASSUMPTIONS                                                             */
/*      The input must be at least 8 elements long, and a multiple of 4.    */
/*                                                                          */
/*      The input and output arrays must not overlap, except in the         */
/*      special case where the input and output pointers are exactly        */
/*      equal.                                                              */
/*                                                                          */
/*      The x and r arrays must be double-word aligned                      */
/*                                                                          */
/*  MEMORY NOTE                                                             */
/*      No memory bank hits will occur.                                     */
/*      This kernel is ENDIAN NEUTRAL.                                      */
/*                                                                          */
/*  NOTES                                                                   */
/*      Code is interrupt tolerant but not interruptible.  It locks out     */
/*      interrupts for its entire duration.                                 */
/*                                                                          */
/*  CYCLES                                                                  */
/*      cycles = nx/2 + 19.                                                 */
/*      nx = 96, cycles = 56 cycles                                         */
/*                                                                          */
/*  CODESIZE                                                                */
/*      124 bytes                                                           */
/*                                                                          */
/* ------------------------------------------------------------------------ */
/*            Copyright (c) 2002 Texas Instruments, Incorporated.           */
/*                           All Rights Reserved.                           */
/* ======================================================================== */
#ifndef DSP_NEG32_H_
#define DSP_NEG32_H_ 1

void DSP_neg32
(
    int   *x,      /* Input data array     */
    int   *r,      /* Output data array    */
    short nx       /* Number of elements.  */
);

#endif
/* ======================================================================== */
/*  End of file:  dsp_neg32.h                                               */
/* ------------------------------------------------------------------------ */
/*            Copyright (c) 2002 Texas Instruments, Incorporated.           */
/*                           All Rights Reserved.                           */
/* ======================================================================== */
