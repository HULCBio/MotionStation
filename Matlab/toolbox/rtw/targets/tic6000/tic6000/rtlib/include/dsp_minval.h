/* $Revision: 1.9 $ $Date: 2002/04/26 23:46:17 $ */
/* ======================================================================== */
/*  TEXAS INSTRUMENTS, INC.                                                 */
/*                                                                          */
/*  DSPLIB  DSP Signal Processing Library                                   */
/*                                                                          */
/*      Release:        Version 1.02                                        */
/*      CVS Revision:   1.4     Wed Apr 17 15:51:08 2002 (UTC)              */
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
/*   DSP_minval                                                             */
/*                                                                          */
/*  REVISION DATE                                                           */
/*      27-Jul-2001                                                         */
/*                                                                          */
/*  USAGE                                                                   */
/*      This routine is C-callable and can be called as:                    */
/*                                                                          */
/*       short DSP_minval(const short *x, int nx);                          */
/*                                                                          */
/*          x  = address to array of values                                 */
/*          nx = number of values in array                                  */
/*                                                                          */
/*  DESCRIPTION                                                             */
/*      This routine finds the minimum value of a vector and returns        */
/*      the value.                                                          */
/*                                                                          */
/*  C CODE                                                                  */
/*      The following is a C description of the algorithm without           */
/*      restrictionms.  This implementation may have restrictions           */
/*      as noted under 'ASSUMPTIONS' below.                                 */
/*                                                                          */
/*          short DSP_minval(const short *x, int nx)                        */
/*          {                                                               */
/*              int i;                                                      */
/*              short DSP_minval = 32767;                                   */
/*                                                                          */
/*              for (i = 0; i < nx; i++)                                    */
/*                  if (x[i] < DSP_minval)                                  */
/*                       DSP_minval = x[i];                                 */
/*                                                                          */
/*              return DSP_minval;                                          */
/*          }                                                               */
/*                                                                          */
/*  ASSUMPTIONS                                                             */
/*      Nx must be a multiple of 4.                                         */
/*      Nx must be greater then or equal to 16.                             */
/*      x[] must be word-aligned.                                           */
/*                                                                          */
/*  MEMORY NOTE                                                             */
/*      This code is ENDIAN NEUTRAL.                                        */
/*                                                                          */
/*  NOTES                                                                   */
/*      This code is interrupt tolerant but not interruptible.              */
/*                                                                          */
/*  CODESIZE                                                                */
/*      224 bytes                                                           */
/*                                                                          */
/*  CYCLES                                                                  */
/*      cycles = nx / 2 + 21.                                               */
/*                                                                          */
/* ------------------------------------------------------------------------ */
/*            Copyright (c) 2002 Texas Instruments, Incorporated.           */
/*                           All Rights Reserved.                           */
/* ======================================================================== */
#ifndef DSP_MINVAL_H_
#define DSP_MINVAL_H_ 1

short DSP_minval(const short *x, int nx);

#endif
/* ======================================================================== */
/*  End of file:  dsp_minval.h                                              */
/* ------------------------------------------------------------------------ */
/*            Copyright (c) 2002 Texas Instruments, Incorporated.           */
/*                           All Rights Reserved.                           */
/* ======================================================================== */
