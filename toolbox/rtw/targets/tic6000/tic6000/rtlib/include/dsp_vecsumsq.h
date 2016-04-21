/* $Revision: 1.8 $ $Date: 2002/04/26 23:44:56 $ */
/* ======================================================================== */
/*  TEXAS INSTRUMENTS, INC.                                                 */
/*                                                                          */
/*  DSPLIB  DSP Signal Processing Library                                   */
/*                                                                          */
/*      Release:        Version 1.02                                        */
/*      CVS Revision:   1.4     Fri Mar 29 20:00:04 2002 (UTC)              */
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
/*      DSP_vecsumsq                                                        */
/*                                                                          */
/*  REVISION DATE                                                           */
/*      13-Aug-1999                                                         */
/*                                                                          */
/*  USAGE                                                                   */
/*      This routine is C callable, and has the following C prototype:      */
/*                                                                          */
/*          int DSP_vecsumsq                                                */
/*          (                                                               */
/*              const short *x,    // Pointer to vector  //                 */
/*              int          nx    // Length of vector.  //                 */
/*          )                                                               */
/*                                                                          */
/*      This routine returns the sum of squares as its return value.        */
/*                                                                          */
/*  DESCRIPTION                                                             */
/*      The "DSP_vecsumsq" function returns the sum of squares of the       */
/*      elements contained in vector "x".                                   */
/*                                                                          */
/*  C CODE                                                                  */
/*      The following C code is a general implementation without            */
/*      restrictions.  This implementation may have restrictions, as        */
/*      noted under "ASSUMPTIONS" below.                                    */
/*                                                                          */
/*          int DSP_vecsumsq                                                */
/*          (                                                               */
/*              const short *x,    // Pointer to vector  //                 */
/*              int          nx    // Length of vector.  //                 */
/*          )                                                               */
/*          {                                                               */
/*              int i, sum = 0;                                             */
/*                                                                          */
/*              for (i = 0; i < nx; i++)                                    */
/*                  sum += x[i] * x[i];                                     */
/*                                                                          */
/*              return sum;                                                 */
/*          }                                                               */
/*                                                                          */
/*                                                                          */
/*  ASSUMPTIONS                                                             */
/*      The input length is a multiple of 2 and at least 8.                 */
/*                                                                          */
/*  NOTES                                                                   */
/*      This function is interrupt tolerant, but not interruptible.         */
/*      It locks out interrupts for its entire duration.                    */
/*                                                                          */
/*  MEMORY NOTE                                                             */
/*      This function is ENDIAN NEUTRAL.                                    */
/*      No bank conflicts occur under any conditions.                       */
/*                                                                          */
/*  CYCLES                                                                  */
/*      cycles = count/2 + 19.                                              */
/*                                                                          */
/*  CODESIZE                                                                */
/*      192 bytes                                                           */
/*                                                                          */
/* ------------------------------------------------------------------------ */
/*            Copyright (c) 2002 Texas Instruments, Incorporated.           */
/*                           All Rights Reserved.                           */
/* ======================================================================== */
#ifndef DSP_VECSUMSQ_H_
#define DSP_VECSUMSQ_H_ 1

int DSP_vecsumsq
(
    const short *x,    /* Pointer to vector  */
    int          nx    /* Length of vector.  */
);

#endif
/* ======================================================================== */
/*  End of file:  dsp_vecsumsq.h                                            */
/* ------------------------------------------------------------------------ */
/*            Copyright (c) 2002 Texas Instruments, Incorporated.           */
/*                           All Rights Reserved.                           */
/* ======================================================================== */
