/* $Revision: 1.8 $ $Date: 2002/04/26 23:45:57 $ */
/* ======================================================================== */
/*  TEXAS INSTRUMENTS, INC.                                                 */
/*                                                                          */
/*  DSPLIB  DSP Signal Processing Library                                   */
/*                                                                          */
/*      Release:        Version 1.02                                        */
/*      CVS Revision:   1.3     Fri Mar 22 01:53:40 2002 (UTC)              */
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
/*      DSP_mat_trans                                                       */
/*                                                                          */
/*  REVISION DATE                                                           */
/*      27-Jul-2001                                                         */
/*                                                                          */
/*  USAGE                                                                   */
/*      This routine is C-callable and can be called as:                    */
/*                                                                          */
/*      void DSP_mat_trans                                                  */
/*      (                                                                   */
/*          const short *restrict x,                                        */
/*          short       rows,                                               */
/*          short       columns,                                            */
/*          short       *restrict r                                         */
/*      );                                                                  */
/*                                                                          */
/*      x[rows*columns] : Pointer to input matrix. In-place                 */
/*                        processing not allowed.                           */
/*      rows            : Number of rows in input matrix                    */
/*      columns         : Number of columns in input matrix                 */
/*      r[columns*rows] : Pointer to output matrix.                         */
/*                                                                          */
/*  DESCRIPTION                                                             */
/*      The program transposes a matrix of 16-bit values with dimension     */
/*      rows x columns, i.e. the value of an element in the output matrix   */
/*      is equal to the value of the element from the input matrix with     */
/*      switched coordinates.                                               */
/*                                                                          */
/*  C CODE                                                                  */
/*      void DSP_mat_trans(short *x, short rows, short columns, short *r)   */
/*      {                                                                   */
/*          short i,j;                                                      */
/*                                                                          */
/*          for(i = 0; i < columns; i++)                                    */
/*              for(j = 0; j < rows; j++)                                   */
/*                  r[i * rows + j] = x[i + columns * j];                   */
/*      }                                                                   */
/*                                                                          */
/*  TECHNIQUES                                                              */
/*      The kernel of the code combines two loops in one. As the program    */
/*      goes accross the input matrix (always just incrementing pointer),   */
/*      it must go down the output matrix (addition to pointer). After      */
/*      each write it checks to see if the output pointer has reached the   */
/*      end of the column. If so, it redirects the output pointer to the    */
/*      beginning of the next column. This technique is good for most size  */
/*      matrices, but for very large matrices, a more efficient technique   */
/*      would use two loops so that the inner one could accomodate          */
/*      more elements per cycle.                                            */
/*                                                                          */
/*  ASSUMPTIONS                                                             */
/*      Matrices have 16-bit elements                                       */
/*                                                                          */
/*  MEMORY NOTE                                                             */
/*      This code is ENDIAN NEUTRAL.                                        */
/*      No memory bank hits occur.                                          */
/*                                                                          */
/*  CYCLES                                                                  */
/*      6 * floor[rows * columns / 3] + 11                                  */
/*                                                                          */
/*      For rows = 69, columns = 17: 2357 cycles                            */
/*                                                                          */
/*  CODESIZE                                                                */
/*      192 bytes                                                           */
/*                                                                          */
/* ------------------------------------------------------------------------ */
/*            Copyright (c) 2002 Texas Instruments, Incorporated.           */
/*                           All Rights Reserved.                           */
/* ======================================================================== */
#ifndef DSP_MAT_TRANS_H_
#define DSP_MAT_TRANS_H_ 1

void DSP_mat_trans
(
    const short *restrict x,
    short       rows,
    short       columns,
    short       *restrict r
);

#endif
/* ======================================================================== */
/*  End of file:  dsp_mat_trans.h                                           */
/* ------------------------------------------------------------------------ */
/*            Copyright (c) 2002 Texas Instruments, Incorporated.           */
/*                           All Rights Reserved.                           */
/* ======================================================================== */
