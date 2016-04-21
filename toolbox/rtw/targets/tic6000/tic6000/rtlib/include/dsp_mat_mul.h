/* $Revision: 1.6 $ $Date: 2002/04/26 23:45:52 $ */
/* ======================================================================== */
/*  TEXAS INSTRUMENTS, INC.                                                 */
/*                                                                          */
/*  DSPLIB  DSP Signal Processing Library                                   */
/*                                                                          */
/*      Release:        Version 1.02                                        */
/*      CVS Revision:   1.6     Fri Mar 22 01:53:17 2002 (UTC)              */
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
/*  TEXAS INSTRUMENTS, INC.                                                 */
/*                                                                          */
/*  NAME                                                                    */
/*      DSP_mat_mul -- Matrix Multiply                                      */
/*                                                                          */
/*  REVISION DATE                                                           */
/*      15-Jan-2002                                                         */
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
/*      This function computes the expression "r = x * y" for the           */
/*      matrices x and y.  The columnar dimension of x must match           */
/*      the row dimension of y.  The resulting matrix has the same          */
/*      number of rows as x and the same number of columns as y.            */
/*                                                                          */
/*      The values stored in the matrices are assumed to be fixed-point     */
/*      or integer values.  All intermediate sums are retained to 32-bit    */
/*      precision, and no overflow checking is performed.  The results      */
/*      are right-shifted by a user-specified amount, and then truncated    */
/*      to 16 bits.                                                         */
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
/*      The outer two loops are unrolled 2x.  For odd-sized dimensions,     */
/*      we end up doing extra multiplies along the edges.  This offsets     */
/*      the overhead of the nested loop structure, though.                  */
/*                                                                          */
/*      The outer two levels of loop nest are collapsed, further reducing   */
/*      the overhead of the looping structure.                              */
/*                                                                          */
/*  NOTES                                                                   */
/*      This code is ENDIAN NEUTRAL.                                        */
/*                                                                          */
/*      This code is interrupt tolerant, but not interruptible.             */
/*      Interrupts are locked out in the body of this function by branch    */
/*      delay slots.                                                        */
/*                                                                          */
/*      For odd values of r1 or c2, this code rounds the dimension up to    */
/*      the next larger even dimension when calculating loop trip counts.   */
/*      Array addressing is not affected by this rounding.                  */
/*                                                                          */
/*  MEMORY NOTE                                                             */
/*      The load instructions in the inner loop are predicated to avoid     */
/*      significant over-fetching on the matrices.  However, since the      */
/*      outer loops are unrolled, this code may fetch approximately one     */
/*      full row beyond the end of the 'x' matrix and approximately one     */
/*      word beyond the end of the 'y' matrix.  The values read are         */
/*      discarded and do not affect the results of the computation.         */
/*                                                                          */
/*      The code is organized so that accesses to the 'x' and 'y' matrices  */
/*      occur in parallel.  On C620x and C670x devices, this will result    */
/*      in memory bank conflicts unless both 'x' and 'y' are placed in      */
/*      separate memory spaces.  When both 'x' and 'y' are in separate      */
/*      memory spaces, no conflicts occur.  On C621x and C671x, there are   */
/*      no bank conflicts as the devices use dual-ported memory.            */
/*                                                                          */
/*      When 'x' and 'y' are placed in the same memory space (eg. the       */
/*      same half of data memory on C620x and C670x devices), bank          */
/*      conflicts will occur in a pattern that depends on the dimensions    */
/*      of matrices and the number and size of the memory banks on the      */
/*      specific device being used.  The code places the following          */
/*      accesses in parallel:  (Refer to C code above for the meaning of    */
/*      the indices 'i', 'j', and 'k'.)                                     */
/*                                                                          */
/*          x[k + (i + 0)*c1]  in parallel with  y[(j + 0) + k*c2]          */
/*          x[k + (i + 1)*c1]  in parallel with  y[(j + 1) + k*c2]          */
/*                                                                          */
/*      The exact analysis of bank conflicts requires the dimensions of     */
/*      the matrices being multiplied, and this calculation is left to      */
/*      the user.  Bank conflicts cause between 3% and 40% degradation      */
/*      on a 4-bank device such as C6201 when x and y are in the same       */
/*      memory space.                                                       */
/*                                                                          */
/*  CYCLES                                                                  */
/*      Assuming no bank conflicts, the following formula applies:          */
/*                                                                          */
/*      cycles = 0.5 * (r1'*c2'*c1) + 3 * (r1'*c2') + 24, where:            */
/*      r1' = r1 + (r1&1);   // r1 rounded up to next even                  */
/*      c2' = c2 + (c2&1);   // c2 rounded up to next even                  */
/*                                                                          */
/*      For r1= 1, c1= 1, c2= 1,  cycles =    38.                           */
/*      For r1= 8, c1=20, c2= 8,  cycles =   856.                           */
/*      For r1=12, c1=14, c2=18,  cycles =  2184.                           */
/*      For r1=32, c1=32, c2=32,  cycles = 19480.                           */
/*                                                                          */
/*      The cycle count includes 6 cycles of function call overhead.  The   */
/*      exact overhead seen by a given application will depend on the       */
/*      compiler options used.                                              */
/*                                                                          */
/*  CODESIZE                                                                */
/*      448 bytes.                                                          */
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
