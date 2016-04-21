/* ======================================================================== */
/*  TEXAS INSTRUMENTS, INC.                                                 */
/*                                                                          */
/*  DSPLIB  DSP Signal Processing Library                                   */
/*                                                                          */
/*      Release:        Version 1.02                                        */
/*      CVS Revision:   1.7     Mon Feb 18 00:59:02 2002 (UTC)              */
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
/*    TEXAS INSTRUMENTS, INC.                                               */
/*                                                                          */
/*    NAME                                                                  */
/*          DSP_mat_trans                                                   */
/*                                                                          */
/*    REVISION DATE                                                         */
/*        17-Feb-2002                                                       */
/*                                                                          */
/*  USAGE                                                                   */
/*      This routine is C-callable and can be called as:                    */
/*                                                                          */
/*      void DSP_mat_trans(const short *x, short rows, short columns, short *r) */
/*                                                                          */
/*      x       : Pointer to input matrix containing 16-bit elements        */
/*      rows    : Number of rows in matrix                                  */
/*      columns : Number of columnss in matrix                              */
/*      r       : Pointer to output matrix (transpose of input matrix)      */
/*                                                                          */
/*  DESCRIPTION                                                             */
/*      The program transposes a matrix of 16-bit values and user-          */
/*      determined dimensions. The result of a matrix transpose is a        */
/*      matrix with the number of rows = number of columns of input matrix  */
/*      and number of columns = number of rows of input matrix The value    */
/*      of an elements of the output matrix is equal to the value of the    */
/*      element from the input matrix with switched coordinates (rows,      */
/*      columns).                                                           */
/*                                                                          */
/*    C CODE                                                                */
/*        void DSP_mat_trans(short *x, short rows, short columns, short *r) */
/*        {                                                                 */
/*            short i,j;                                                    */
/*            for(i=0; i<columns; i++)                                      */
/*                for(j=0; j<rows; j++)                                     */
/*                    *(r+i*rows+j)=*(x+i+columns*j);                       */
/*        }                                                                 */
/*                                                                          */
/*    TECHNIQUES                                                            */
/*        Data from four adjacent rows, spaced columns apart are read, and  */
/*        local 4x4 transpose is performed in the register file. This leads */
/*        to four double words, that are "rows" apart. These loads and      */
/*        stores can cause bank conflicts, hence non-aligned loads and      */
/*        stores are used.                                                  */
/*                                                                          */
/*    ASSUMPTIONS                                                           */
/*        rows and columns must be a multiple of 4                          */
/*                                                                          */
/*    NOTES                                                                 */
/*        LITTLE ENDIAN Configuration used.                                 */
/*                                                                          */
/*        This code is interruptible throughout as it is single register    */
/*        assignment code.                                                  */
/*                                                                          */
/*    CYCLES                                                                */
/*        (0.5 * rows + 2.0) * cols + 11                                    */
/*                                                                          */
/*        rows = 20, cols = 12, cycles = 153                                */
/*                                                                          */
/*        This includes 6 cycles function call overhead.  This may vary     */
/*        depending on compiler options.                                    */
/*                                                                          */
/*    CODESIZE                                                              */
/*        224 bytes                                                         */
/*                                                                          */
/* ------------------------------------------------------------------------ */
/*            Copyright (c) 2002 Texas Instruments, Incorporated.           */
/*                           All Rights Reserved.                           */
/* ======================================================================== */
#ifndef DSP_MAT_TRANS_H_
#define DSP_MAT_TRANS_H_ 1

void DSP_mat_trans(const short *x, short rows, short columns, short *r);

#endif
/* ======================================================================== */
/*  End of file:  dsp_mat_trans.h                                           */
/* ------------------------------------------------------------------------ */
/*            Copyright (c) 2002 Texas Instruments, Incorporated.           */
/*                           All Rights Reserved.                           */
/* ======================================================================== */
