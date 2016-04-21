/* $Revision: 1.8 $ $Date: 2002/04/26 23:46:27 $ */
/* ======================================================================== */
/*  TEXAS INSTRUMENTS, INC.                                                 */
/*                                                                          */
/*  DSPLIB  DSP Signal Processing Library                                   */
/*                                                                          */
/*      Release:        Version 1.02                                        */
/*      CVS Revision:   1.7     Fri Mar 29 16:07:26 2002 (UTC)              */
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
/*      DSP_neg32                                                           */
/*                                                                          */
/*  REVISION DATE                                                           */
/*      29-Mar-2002                                                         */
/*                                                                          */
/*  USAGE                                                                   */
/*      This routine is C callable, and may be called using the following   */
/*      C function prototype:                                               */
/*                                                                          */
/*          void DSP_neg32                                                  */
/*          (                                                               */
/*              const int *restrict x,      // Input data array     //      */
/*              int       *restrict r,      // Output data array    //      */
/*              int       nx                // Number of elements.  //      */
/*          );                                                              */
/*                                                                          */
/*  DESCRIPTION                                                             */
/*      This routine negates an array of 32-bit integers.                   */
/*                                                                          */
/*  ASSUMPTIONS                                                             */
/*      nx must be at least 4 and a multiple of 2.                          */
/*      Arrays x[] and r[] must be word aligned.                            */
/*      The input and output arrays must not overlap.                       */
/*                                                                          */
/*  NOTES                                                                   */
/*      This code is interrupt tolerant, but not interruptible.  It locks   */
/*      out interrupts for its entire duration.                             */
/*                                                                          */
/*  MEMORY NOTE                                                             */
/*      This code has no bank conflicts, regardless of the alignment        */
/*      of 'x' and 'r'.                                                     */
/*                                                                          */
/*      This kernel is ENDIAN NEUTRAL.                                      */
/*                                                                          */
/*  CYCLES                                                                  */
/*      nx + 18                                                             */
/*                                                                          */
/*  CODESIZE                                                                */
/*      128 bytes                                                           */
/*                                                                          */
/*                                                                          */
/* ------------------------------------------------------------------------ */
/*            Copyright (c) 2002 Texas Instruments, Incorporated.           */
/*                           All Rights Reserved.                           */
/* ======================================================================== */
#ifndef DSP_NEG32_H_
#define DSP_NEG32_H_ 1

void DSP_neg32
(
    const int *restrict x,      /* Input data array     */
    int       *restrict r,      /* Output data array    */
    int       nx                /* Number of elements.  */
);

#endif
/* ======================================================================== */
/*  End of file:  dsp_neg32.h                                               */
/* ------------------------------------------------------------------------ */
/*            Copyright (c) 2002 Texas Instruments, Incorporated.           */
/*                           All Rights Reserved.                           */
/* ======================================================================== */
