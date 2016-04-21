/* ======================================================================== */
/*  TEXAS INSTRUMENTS, INC.                                                 */
/*                                                                          */
/*  DSPLIB  DSP Signal Processing Library                                   */
/*                                                                          */
/*      Release:        Version 1.02                                        */
/*      CVS Revision:   1.4     Tue Feb 26 13:35:28 2002 (UTC)              */
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
/*      DSP_bitrev_cplx                                                     */
/*                                                                          */
/*  REVISION DATE                                                           */
/*      18-Sep-2001                                                         */
/*                                                                          */
/*  USAGE                                                                   */
/*      This routine is C Callable and can be called as:                    */
/*                                                                          */
/*      void DSP_bitrev_cplx(int *x, short *index, int nx)                  */
/*                                                                          */
/*      x[nx]  : Input array to be bit-reversed.                            */
/*      index[]: Array of size ~sqrt(nx) created by the routine             */
/*               bitrev_index to allow the fast implementation of the       */
/*               bit-reversal.                                              */
/*      nx     : Number of points in array x[]. Must be power of 2.         */
/*                                                                          */
/*  DESCRIPTION                                                             */
/*      This routine performs the bit-reversal of the input array x[].      */
/*      where x[] is an array of length nx 16-bit complex pairs of data.    */
/*      This requires the index array provided by the program below.  This  */
/*      index should be generated at compile time not by the DSP. The code  */
/*      is given below.                                                     */
/*                                                                          */
/*      authorizes the use of the bit-reversal code and related table       */
/*      generation code with TMS320-family DSPs manufactured by TI.         */
/*                                                                          */
/*      // ----------------------------------------------------------- //   */
/*      //  This routine calculates the index for bit reversal of      //   */
/*      //  an array of length n.  The length of the index table is    //   */
/*      //  2^(2*ceil(k/2)) where n = 2^k.                             //   */
/*      //                                                             //   */
/*      //  In other words, the length of the index table is:          //   */
/*      //                                                             //   */
/*      //                 Even power      Odd Power                   //   */
/*      //                  of radix        of radix                   //   */
/*      //                  sqrt(n)        sqrt(2*n)                   //   */
/*      //                                                             //   */
/*      // ----------------------------------------------------------- //   */
/*      void bitrev_index(short *index, int n)                              */
/*      {                                                                   */
/*          int   i, j, k, radix = 2;                                       */
/*          short nbits, nbot, ntop, ndiff, n2, raddiv2;                    */
/*                                                                          */
/*          nbits = 0;                                                      */
/*          i = n;                                                          */
/*          while (i > 1)                                                   */
/*          {                                                               */
/*              i = i >> 1;                                                 */
/*              nbits++;                                                    */
/*          }                                                               */
/*                                                                          */
/*          raddiv2 = radix >> 1;                                           */
/*          nbot    = nbits >> raddiv2;                                     */
/*          nbot    = nbot << raddiv2 - 1;                                  */
/*          ndiff   = nbits & raddiv2;                                      */
/*          ntop    = nbot + ndiff;                                         */
/*          n2      = 1 << ntop;                                            */
/*                                                                          */
/*          index[0] = 0;                                                   */
/*          for ( i = 1, j = n2/radix + 1; i < n2 - 1; i++)                 */
/*          {                                                               */
/*              index[i] = j - 1;                                           */
/*                                                                          */
/*              for (k = n2/radix; k*(radix-1) < j; k /= radix)             */
/*                  j -= k*(radix-1);                                       */
/*                                                                          */
/*              j += k;                                                     */
/*          }                                                               */
/*          index[n2 - 1] = n2 - 1;                                         */
/*      }                                                                   */
/*                                                                          */
/*    C CODE                                                                */
/*        void bitrev(int *x, short *index, int nx)                         */
/*        {                                                                 */
/*            int     i;                                                    */
/*            short       i0, i1, i2, i3;                                   */
/*            short       j0, j1, j2, j3;                                   */
/*            int     xi0, xi1, xi2, xi3;                                   */
/*            int     xj0, xj1, xj2, xj3;                                   */
/*            short       t;                                                */
/*            int     a, b, ia, ib, ibs;                                    */
/*            int     mask;                                                 */
/*            int     nbits, nbot, ntop, ndiff, n2, halfn;                  */
/*            short   *xs = (short *) x;                                    */
/*                                                                          */
/*            nbits = 0;                                                    */
/*            i = nx;                                                       */
/*            while (i > 1)                                                 */
/*            {                                                             */
/*                i = i >> 1;                                               */
/*                nbits++;                                                  */
/*            }                                                             */
/*                                                                          */
/*            nbot    = nbits >> 1;                                         */
/*            ndiff   = nbits & 1;                                          */
/*            ntop    = nbot + ndiff;                                       */
/*            n2      = 1 << ntop;                                          */
/*            mask    = n2 - 1;                                             */
/*            halfn   = nx >> 1;                                            */
/*                                                                          */
/*            for (i0 = 0; i0 < halfn; i0 += 2)                             */
/*            {                                                             */
/*                b   = i0 & mask;                                          */
/*                a   = i0 >> nbot;                                         */
/*                if (!b) ia  = index[a];                                   */
/*                ib  = index[b];                                           */
/*                ibs = ib << nbot;                                         */
/*                                                                          */
/*                j0  = ibs + ia;                                           */
/*                t   = i0 < j0;                                            */
/*                xi0 = x[i0];                                              */
/*                xj0 = x[j0];                                              */
/*                                                                          */
/*                if (t){x[i0] = xj0;                                       */
/*                x[j0] = xi0;}                                             */
/*                                                                          */
/*                i1  = i0 + 1;                                             */
/*                j1  = j0 + halfn;                                         */
/*                xi1 = x[i1];                                              */
/*                xj1 = x[j1];                                              */
/*                x[i1] = xj1;                                              */
/*                x[j1] = xi1;                                              */
/*                                                                          */
/*                i3  = i1 + halfn;                                         */
/*                j3  = j1 + 1;                                             */
/*                xi3 = x[i3];                                              */
/*                xj3 = x[j3];                                              */
/*                if (t){x[i3] = xj3;                                       */
/*                x[j3] = xi3;}                                             */
/*            }                                                             */
/*        }                                                                 */
/*                                                                          */
/*  ASSUMPTIONS                                                             */
/*      nx must be a power of 2.                                            */
/*      The table from bitrev_index is already created.                     */
/*      LITTLE ENDIAN configuration used.                                   */
/*                                                                          */
/*  NOTES                                                                   */
/*      If N <= 4K one can use the char (8-bit) data type for               */
/*      the "index" variable. This would require changing the LDH when      */
/*      loading index values in the assembly routine to LDB. This would     */
/*      further reduce the size of the Index Table by half its size.        */
/*                                                                          */
/*      This code is interrupt tolerant, but not interruptible.             */
/*                                                                          */
/*  CYCLES                                                                  */
/*      (N/4 + 2) * 7 + 18                                                  */
/*                                                                          */
/*      e.g. N = 256, cycles = 480                                          */
/*                                                                          */
/*  CODESIZE                                                                */
/*      352 bytes                                                           */
/*                                                                          */
/* ------------------------------------------------------------------------ */
/*            Copyright (c) 2002 Texas Instruments, Incorporated.           */
/*                           All Rights Reserved.                           */
/* ======================================================================== */
#ifndef DSP_BITREV_CPLX_H_
#define DSP_BITREV_CPLX_H_ 1

void DSP_bitrev_cplx(int *x, short *index, int nx);

#endif
/* ======================================================================== */
/*  End of file:  dsp_bitrev_cplx.h                                         */
/* ------------------------------------------------------------------------ */
/*            Copyright (c) 2002 Texas Instruments, Incorporated.           */
/*                           All Rights Reserved.                           */
/* ======================================================================== */
