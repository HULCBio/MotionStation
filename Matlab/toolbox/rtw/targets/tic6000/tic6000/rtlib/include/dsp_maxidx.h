/* $Revision: 1.9 $ $Date: 2002/04/26 23:46:02 $ */
/* ======================================================================== */
/*  TEXAS INSTRUMENTS, INC.                                                 */
/*                                                                          */
/*  DSPLIB  DSP Signal Processing Library                                   */
/*                                                                          */
/*      Release:        Version 1.02                                        */
/*      CVS Revision:   1.4     Sun Mar 10 00:53:48 2002 (UTC)              */
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
/*      DSP_maxidx                                                          */
/*                                                                          */
/*  REVISION DATE                                                           */
/*      28-Jan-2002                                                         */
/*                                                                          */
/*  USAGE                                                                   */
/*      This routine is C-callable and can be called as:                    */
/*                                                                          */
/*      int DSP_maxidx(const short x[], int nx)                             */
/*                                                                          */
/*      x[] : Vector array                                                  */
/*      nx  : Number of elements in x[]                                     */
/*                                                                          */
/*  DESCRIPTION                                                             */
/*      This routine finds the max value of a vector and returns the index  */
/*      of the value. In case of ties the smallest index is returned.       */
/*                                                                          */
/*  C CODE                                                                  */
/*      int DSP_maxidx(const short x[], int nx)                             */
/*      {                                                                   */
/*          int max, index, i;                                              */
/*                                                                          */
/*          max = -32768;                                                   */
/*          index = 0;                                                      */
/*                                                                          */
/*          for (i = 0; i < nx; i++)                                        */
/*              if (x[i] > max)                                             */
/*              {                                                           */
/*                  max = x[i];                                             */
/*                  index = i;                                              */
/*              }                                                           */
/*          return index;                                                   */
/*      }                                                                   */
/*                                                                          */
/*  TECHNIQUES                                                              */
/*      The loop is unrolled three times.                                   */
/*      After finding a new max value, multiply units are used to move      */
/*      value between registers.                                            */
/*                                                                          */
/*  ASSUMPTIONS                                                             */
/*      nx is a multiple of 3 and >= 3                                      */
/*                                                                          */
/*  MEMORY NOTE                                                             */
/*      No memory bank hits under any conditions.                           */
/*                                                                          */
/*  NOTE                                                                    */
/*      This code is ENDIAN NEUTRAL.                                        */
/*      This code is interrupt-tolerant but not interruptible.              */
/*                                                                          */
/*  CYCLES                                                                  */
/*      2 * nx/3 + 13                                                       */
/*                                                                          */
/*      for nx = 108, cycles = 85                                           */
/*                                                                          */
/*  CODESIZE                                                                */
/*      224 bytes                                                           */
/*                                                                          */
/* ------------------------------------------------------------------------ */
/*            Copyright (c) 2002 Texas Instruments, Incorporated.           */
/*                           All Rights Reserved.                           */
/* ======================================================================== */
#ifndef DSP_MAXIDX_H_
#define DSP_MAXIDX_H_ 1

int DSP_maxidx(const short x[], int nx);

#endif
/* ======================================================================== */
/*  End of file:  dsp_maxidx.h                                              */
/* ------------------------------------------------------------------------ */
/*            Copyright (c) 2002 Texas Instruments, Incorporated.           */
/*                           All Rights Reserved.                           */
/* ======================================================================== */
