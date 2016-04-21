/* ======================================================================== */
/*  TEXAS INSTRUMENTS, INC.                                                 */
/*                                                                          */
/*  DSPLIB  DSP Signal Processing Library                                   */
/*                                                                          */
/*      Release:        Version 1.02                                        */
/*      CVS Revision:   1.3     Sun Mar 10 21:45:23 2002 (UTC)              */
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
/*      DSP_mat_mul -- Matrix Multiply, Little Endian                       */
/*                                                                          */
/*   REVISION DATE                                                          */
/*       10-Feb-2002                                                        */
/*                                                                          */
/*  USAGE                                                                   */
/*      This routine is C-callable and can be called as:                    */
/*                                                                          */
/*          void DSP_mat_mul                                                */
/*          (                                                               */
/*              const short *restrict x, int r1, int c1,                    */
/*              const short *restrict y,         int c2,                    */
/*              short       *restrict r,                                    */
/*              int                   qs                                    */
/*          );                                                              */
/*                                                                          */
/*      x  == Pointer to r1 by c1 input matrix.                             */
/*      y  == Pointer to c1 by c2 input matrix.                             */
/*      r  == Pointer to r1 by c2 output matrix.                            */
/*                                                                          */
/*      r1 == Number of rows in x.                                          */
/*      c1 == Number of columns in x.  Also number of rows in y.            */
/*      c2 == Number of columns in y.                                       */
/*                                                                          */
/*      qs == Final right-shift to apply to the result.                     */
/*                                                                          */
/*  DESCRIPTION                                                             */
/*      This function computes the expression "r = x * y" for the matrices  */
/*      x and y.  The columnar dimension of x must match the row dimension  */
/*      of y.  The resulting matrix has the same number of rows as x and    */
/*      the same number of columns as y.                                    */
/*                                                                          */
/*      The values stored in the matrices are assumed to be fixed-point     */
/*      or integer values.  All intermediate sums are retained to 32-bit    */
/*      precision.  No rounding or overflow checking is performed.  The     */
/*      results are right-shifted by the user-specified amount, and then    */
/*      truncated to 16 bits.                                               */
/*                                                                          */
/*      This code is suitable for dense matrices.  No optimizations are     */
/*      made for sparse matrices.                                           */
/*                                                                          */
/*      The following is a C description of the algorithm.  The assembly    */
/*      code may place restrictions on the inputs that the C code version   */
/*      does not.  These restrictions are noted under ASSUMPTIONS below.    */
/*                                                                          */
/*      void DSP_mat_mul                                                    */
/*      (                                                                   */
/*          const short *restrict x, int r1, int c1,                        */
/*          const short *restrict y,         int c2,                        */
/*          short       *restrict r,                                        */
/*          int                   qs                                        */
/*      )                                                                   */
/*      {                                                                   */
/*          int i, j, k;                                                    */
/*          int sum;                                                        */
/*                                                                          */
/*          // ---------------------------------------------------- //      */
/*          //  Multiply each row in x by each column in y.  The    //      */
/*          //  product of row m in x and column n in y is placed   //      */
/*          //  in position (m,n) in the result.                    //      */
/*          // ---------------------------------------------------- //      */
/*          for (i = 0; i < r1; i++)                                        */
/*              for (j = 0; j < c2; j++)                                    */
/*              {                                                           */
/*                  sum = 0;                                                */
/*                                                                          */
/*                  for (k = 0; k < c1; k++)                                */
/*                      sum += x[k + i*c1] * y[j + k*c2];                   */
/*                                                                          */
/*                  r[j + i*c2] = sum >> qs;                                */
/*              }                                                           */
/*      }                                                                   */
/*                                                                          */
/*  ASSUMPTIONS                                                             */
/*      The arrays 'x', 'y', and 'r' are stored in distinct arrays.  That   */
/*      is, in-place processing is not allowed.                             */
/*                                                                          */
/*      The input matrices have minimum dimensions of at least 1 row and    */
/*      1 column, and maximum dimensions of 32767 rows and 32767 columns.   */
/*                                                                          */
/*  TECHNIQUES                                                              */
/*      The 'i' loop and 'k' loops are unrolled 2x.  The 'j' loop is        */
/*      unrolled 4x.  For dimensions that are not multiples of the          */
/*      various loops' unroll factors, this code calculates extra results   */
/*      beyond the edges of the matrix.  These extra results are            */
/*      ultimately discarded.  This allows the loops to be unrolled for     */
/*      efficient operation on large matrices while not losing              */
/*      flexibility.                                                        */
/*                                                                          */
/*      The outer two levels of loop nest are collapsed, further reducing   */
/*      the overhead of the looping structure.                              */
/*                                                                          */
/*  NOTES                                                                   */
/*      This code blocks interrupts during its innermost loop.  Interrupts  */
/*      are not blocked otherwise.  As a result, interrupts can be blocked  */
/*      for up to 0.25*c1' + 16 cycles at a time.                           */
/*                                                                          */
/*      When calculating the loop trip counts, the values of r1 and c1      */
/*      are rounded up to the next even value.  The value of c2 is          */
/*      rounded up to the next multiple of 4.  This does not affect         */
/*      the memory layout of the input or output matrices.                  */
/*                                                                          */
/*  MEMORY NOTE                                                             */
/*      The load instructions in the inner loop are predicated to avoid     */
/*      significant over-fetching on the matrices.  However, since the      */
/*      outer loops are unrolled, this code may fetch approximately one     */
/*      full row beyond the end of the 'x' matrix and approximately one     */
/*      double-word beyond the end of the 'y' matrix.  The values read      */
/*      are discarded and do not affect the results of the computation.     */
/*                                                                          */
/*      This code has no memory alignment requirements, as non-aligned      */
/*      loads are used for accessing the inputs, and individual STHs are    */
/*      used for writing the results.                                       */
/*                                                                          */
/*      This is a LITTLE ENDIAN implementation.                             */
/*                                                                          */
/*  CYCLES                                                                  */
/*      cycles = 0.25 * (r1'*c2'*c1') + 2.25 * (r1'*c2') + 11, where:       */
/*                                                                          */
/*          r1' = 2 * ceil(r1/2.0)   // r1 rounded up to next even          */
/*          c1' = 2 * ceil(c1/2.0)   // c1 rounded up to next even          */
/*          c2' = 4 * ceil(c2/4.0);  // c2 rounded up to next mult of 4     */
/*                                                                          */
/*      For r1= 1, c1= 1, c2= 1,  cycles =    33.                           */
/*      For r1= 8, c1=20, c2= 8,  cycles =   475.                           */
/*      For r1=12, c1=14, c2=18,  cycles =  1391.                           */
/*      For r1=32, c1=32, c2=32,  cycles = 10507.                           */
/*                                                                          */
/*      The cycle count includes 6 cycles of function call overhead.  The   */
/*      exact overhead seen by a given application will depend on the       */
/*      compiler options used.                                              */
/*                                                                          */
/*  CODESIZE                                                                */
/*      416 bytes.                                                          */
/*                                                                          */
/* ------------------------------------------------------------------------ */
/*            Copyright (c) 2002 Texas Instruments, Incorporated.           */
/*                           All Rights Reserved.                           */
/* ======================================================================== */
#ifndef DSP_MAT_MUL_H_
#define DSP_MAT_MUL_H_ 1

void DSP_mat_mul
(
    const short *restrict x, int r1, int c1,
    const short *restrict y,         int c2,
    short       *restrict r,
    int                   qs
);

#endif
/* ======================================================================== */
/*  End of file:  dsp_mat_mul.h                                             */
/* ------------------------------------------------------------------------ */
/*            Copyright (c) 2002 Texas Instruments, Incorporated.           */
/*                           All Rights Reserved.                           */
/* ======================================================================== */
