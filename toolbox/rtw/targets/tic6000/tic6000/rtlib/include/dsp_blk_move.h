/* $Revision: 1.8 $ $Date: 2002/04/26 23:44:15 $ */
/* ======================================================================== */
/*  TEXAS INSTRUMENTS, INC.                                                 */
/*                                                                          */
/*  DSPLIB  DSP Signal Processing Library                                   */
/*                                                                          */
/*      Release:        Version 1.02                                        */
/*      CVS Revision:   1.7     Fri Mar 22 02:00:23 2002 (UTC)              */
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
/*  NAME                                                                    */
/*      DSP_blk_move -- Move a block of memory.  Endian Neutral             */
/*                                                                          */
/*  REVISION DATE                                                           */
/*      11-Dec-2001                                                         */
/*                                                                          */
/*  USAGE                                                                   */
/*      This routine is C-callable and can be called as:                    */
/*                                                                          */
/*      void DSP_blk_move(const short *restrict x,                          */
/*                    short *restrict r, int nx);                           */
/*                                                                          */
/*          x  --- block of data to be moved                                */
/*          r  --- destination of block of data                             */
/*          nx --- number of elements in block                              */
/*                                                                          */
/*  DESCRIPTION                                                             */
/*      Move nx 16-bit elements from one memory location                    */
/*      to another.                                                         */
/*                                                                          */
/*      void DSP_blk_move(const short *restrict x,                          */
/*                    short *restrict r, int nx)                            */
/*      {                                                                   */
/*          int i;                                                          */
/*          for (i = 0 ; i < nx; i++)                                       */
/*              r[i] = x[i];                                                */
/*      }                                                                   */
/*                                                                          */
/*  ASSUMPTIONS                                                             */
/*      nx greater than or equal to 4                                       */
/*      nx a multiple of 2                                                  */
/*      Source and destination arrays are word aligned.                     */
/*      Source and destination arrays do not overlap.                       */
/*                                                                          */
/*  TECHNIQUES                                                              */
/*      Twin input and output pointers are used.                            */
/*      Unrolled 4 times to use parallel LDWs and STWs.                     */
/*      Peeled off half-iteration to allow mult. of 2 instead mult. of 4.   */
/*      Return branch issued from loop kernel to save cycles.               */
/*                                                                          */
/*  NOTES                                                                   */
/*      This function is interrupt tolerant, but not interruptible.         */
/*      It locks out interrupts for its entire duration.                    */
/*                                                                          */
/*  MEMORY NOTE                                                             */
/*      No bank conflicts occur in this code.                               */
/*      This code is ENDIAN NEUTRAL.                                        */
/*                                                                          */
/*  CYCLES                                                                  */
/*      cycles = MAX(2 * (nx >> 2) + 15, 21)                                */
/*      For nx <= 14,  cycles == 21.                                        */
/*      For nx == 16,  cycles == 23.                                        */
/*      For nx == 100, cycles == 65.                                        */
/*                                                                          */
/*  CODESIZE                                                                */
/*      128 bytes.                                                          */
/* ------------------------------------------------------------------------ */
/*            Copyright (c) 2002 Texas Instruments, Incorporated.           */
/*                           All Rights Reserved.                           */
/* ======================================================================== */
#ifndef DSP_BLK_MOVE_H_
#define DSP_BLK_MOVE_H_ 1

void DSP_blk_move(const short *restrict x,
              short *restrict r, int nx);

#endif
/* ======================================================================== */
/*  End of file:  dsp_blk_move.h                                            */
/* ------------------------------------------------------------------------ */
/*            Copyright (c) 2002 Texas Instruments, Incorporated.           */
/*                           All Rights Reserved.                           */
/* ======================================================================== */
