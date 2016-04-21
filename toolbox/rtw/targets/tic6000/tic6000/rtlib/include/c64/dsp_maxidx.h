/* ======================================================================== */
/*  TEXAS INSTRUMENTS, INC.                                                 */
/*                                                                          */
/*  DSPLIB  DSP Signal Processing Library                                   */
/*                                                                          */
/*      Release:        Version 1.02                                        */
/*      CVS Revision:   1.4     Sun Mar 17 11:19:45 2002 (UTC)              */
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
/*      DSP_maxidx                                                          */
/*                                                                          */
/*  REVISION DATE                                                           */
/*      17-Feb-2002                                                         */
/*                                                                          */
/*  USAGE                                                                   */
/*      This routine is C callable, and has the following C prototype:      */
/*                                                                          */
/*          int DSP_maxidx(const short *x, int nx);                         */
/*                                                                          */
/*          x       = pointer to input data                                 */
/*          nx      = number of samples                                     */
/*          return  = max index                                             */
/*                                                                          */
/*  DESCRIPTION                                                             */
/*      This routine finds the maximum value of the vector x[ ] and         */
/*      returns the index of that value.                                    */
/*                                                                          */
/*      The input array is treated as 16 separate "columns" that are        */
/*      interleaved throughout the array.  If values in different           */
/*      columns are equal to the maximum value, then the element in         */
/*      the leftmost column is returned.  If two values within a            */
/*      column are equal to the maximum, then the one with the lower        */
/*      index is returned.                                                  */
/*                                                                          */
/*      Column takes precedence over index.                                 */
/*                                                                          */
/*          int DSP_maxidx(const short *x, int nx)                          */
/*          {                                                               */
/*              int col, idx;                                               */
/*              short max_val;                                              */
/*              int   max_idx;                                              */
/*                                                                          */
/*              max_val = x[0];                                             */
/*              max_idx = 0;                                                */
/*                                                                          */
/*              for (col = 0; col < 16; col++)                              */
/*                  for (idx = col; idx < nx; idx += 16)                    */
/*                      if (x[idx] > max_val)                               */
/*                      {                                                   */
/*                          max_val = x[idx];                               */
/*                          max_idx = idx;                                  */
/*                      }                                                   */
/*                                                                          */
/*              return max_idx;                                             */
/*          }                                                               */
/*                                                                          */
/*      The above C code is a general implementation without                */
/*      restrictions.  The assembly code has some restrictions, as          */
/*      noted below.                                                        */
/*                                                                          */
/*  TECHNIQUES                                                              */
/*      The code is unrolled 16 times to enable the full bandwidth of       */
/*      LDDW and MAX2 instructions to be utilized.  This splits the         */
/*      search into 16 subranges.  The global maximum is then found         */
/*      from the list of maximums of the subsranges.                        */
/*                                                                          */
/*      Then using this offset from the subranges, the global maximum       */
/*      and the index of it are found using a simple match.                 */
/*                                                                          */
/*      For common maximums in multiple ranges, the index will be           */
/*      different to the above C code.                                      */
/*                                                                          */
/*  ASSUMPTIONS                                                             */
/*      The input data are stored on double-word aligned boundaries.        */
/*      nx must be a multiple of 16 and >= 48                               */
/*                                                                          */
/*  MEMORY NOTE                                                             */
/*      There are no bank conflicts in this code.                           */
/*                                                                          */
/*      This code is ENDIAN NEUTRAL.                                        */
/*                                                                          */
/*      This code requires 40 bytes of stack space for a temporary          */
/*      buffer.                                                             */
/*                                                                          */
/*  NOTES                                                                   */
/*      Interupts are disabled for the duration of this function.           */
/*                                                                          */
/*  CYCLES                                                                  */
/*      5/16 * nx + 42                                                      */
/*      For nx = 128, cycles = 82.                                          */
/*                                                                          */
/*  CODESIZE                                                                */
/*      384 bytes                                                           */
/*                                                                          */
/* ------------------------------------------------------------------------ */
/*            Copyright (c) 2002 Texas Instruments, Incorporated.           */
/*                           All Rights Reserved.                           */
/* ======================================================================== */
#ifndef DSP_MAXIDX_H_
#define DSP_MAXIDX_H_ 1

int DSP_maxidx(const short *x, int nx);

#endif
/* ======================================================================== */
/*  End of file:  dsp_maxidx.h                                              */
/* ------------------------------------------------------------------------ */
/*            Copyright (c) 2002 Texas Instruments, Incorporated.           */
/*                           All Rights Reserved.                           */
/* ======================================================================== */
