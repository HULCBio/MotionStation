/* ======================================================================== */
/*  TEXAS INSTRUMENTS, INC.                                                 */
/*                                                                          */
/*  DSPLIB  DSP Signal Processing Library                                   */
/*                                                                          */
/*      Release:        Version 1.02                                        */
/*      CVS Revision:   1.3     Thu Sep  6 18:22:41 2001 (UTC)              */
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
/*=========================================================================S*/
/*     TEXAS INSTRUMENTS, INC.                                              */
/*                                                                          */
/*     NAME                                                                 */
/*           DSP_ifft16x32                                                  */
/*                                                                          */
/*     USAGE                                                                */
/*           This routine is C-callable and can be called as:               */
/*                                                                          */
/*          void DSP_ifft16x32(const short * ptr_w, int  npoints,           */
/*                           int   * ptr_x, int  *ptr_y ) ;                 */
/*                                                                          */
/*            ptr_w   =  input twiddle factors                              */
/*            npoints =  number of points                                   */
/*            ptr_x   =  transformed data reversed                          */
/*            ptr_y   =  linear transformed data                            */
/*                                                                          */
/*           (See the C compiler reference guide.)                          */
/*                                                                          */
/*     In reality one can re-use fft16x32 to perform IFFT, by first         */
/*     conjugating the input, performing the FFT, conjugating again.        */
/*     This allows fft16x32 to perform the IFFT as well. However if         */
/*     the double conjugation needs to be avoided then this routine         */
/*     uses the same twiddle factors as the FFT and performs an IFFT.       */
/*     The change in the sign of the twiddle factors is adjusted for        */
/*     software. Hence this routine uses the same twiddle factors as        */
/*     the FFT routine.                                                     */
/*                                                                          */
/*  DESCRIPTION                                                             */
/*      The following code performs a mixed radix IFFT for "npoints" which  */
/*      is either a multiple of 4 or 2. It uses logN4 - 1 stages of radix4  */
/*      transform and performs either a radix2 or radix4 transform on the   */
/*      last stage depending on "npoints". If "npoints" is a multiple of 4, */
/*      then this last stage is also a radix4 transform, otherwise it is a  */
/*      radix2 transform. This program is available as a C compilable file  */
/*      to automatically generate the twiddle factors "twiddle_split.c"     */
/*                                                                          */
/*        int i, j, k, n = N;                                               */
/*        double theta1, theta2, theta3, x_t, y_t;                          */
/*        const double M = 32768.0, PI = 3  41592654;                       */
/*                                                                          */
/*        for (j=1, k=0; j < n>>2; j = j<<2)                                */
/*        {                                                                 */
/*            for (i=0; i < n>>2; i += j<<1)                                */
/*            {                                                             */
/*                theta1 = 2*PI*i/n;                                        */
/*                x_t = M*cos(theta1);                                      */
/*                y_t = M*sin(theta1);                                      */
/*                w[k+1] = (short) x_t;                                     */
/*                if (x_t >= M) w[k+1] = 0x7fff;                            */
/*                w[k+0] = (short) y_t;                                     */
/*                if (y_t >= M) w[k+0] = 0x7fff;                            */
/*                                                                          */
/*                theta1 = 2*PI*(i+j)/n;                                    */
/*                x_t = M*cos(theta1);                                      */
/*                y_t = M*sin(theta1);                                      */
/*                w[k+7] = (short) x_t;                                     */
/*                if (x_t >= M) w[k+3] = 0x7fff;                            */
/*                w[k+6] = (short) y_t;                                     */
/*                if (y_t >= M) w[k+2] = 0x7fff;                            */
/*                                                                          */
/*                theta2 = 4*PI*i/n;                                        */
/*                x_t = M*cos(theta2);                                      */
/*                y_t = M*sin(theta2);                                      */
/*                w[k+3] = (short) x_t;                                     */
/*                if (x_t >= M) w[k+5] = 0x7fff;                            */
/*                w[k+2] = (short) y_t;                                     */
/*                if (y_t >= M) w[k+4] = 0x7fff;                            */
/*                                                                          */
/*                theta2 = 4*PI*(i+j)/n;                                    */
/*                x_t = M*cos(theta2);                                      */
/*                y_t = M*sin(theta2);                                      */
/*                w[k+9] = (short) x_t;                                     */
/*                if (x_t >= M) w[k+7] = 0x7fff;                            */
/*                w[k+8] = (short) y_t;                                     */
/*                if (y_t >= M) w[k+6] = 0x7fff;                            */
/*                                                                          */
/*                theta3 = 6*PI*i/n;                                        */
/*                x_t = M*cos(theta3);                                      */
/*                y_t = M*sin(theta3);                                      */
/*                w[k+5] = (short) x_t;                                     */
/*                if (x_t >= M) w[k+9] = 0x7fff;                            */
/*                w[k+4] = (short) y_t;                                     */
/*                if (y_t >= M) w[k+8] = 0x7fff;                            */
/*                                                                          */
/*                theta3 = 6*PI*(i+j)/n;                                    */
/*                x_t = M*cos(theta3);                                      */
/*                y_t = M*sin(theta3);                                      */
/*                w[k+11] = (short) x_t;                                    */
/*                if (x_t >= M) w[k+11] = 0x7fff;                           */
/*                w[k+10] = (short) y_t;                                    */
/*                if (y_t >= M) w[k+10] = 0x7fff;                           */
/*                                                                          */
/*                k += 12;                                                  */
/*            }                                                             */
/*        }                                                                 */
/*        w[2*n-1] = w[2*n-3] = w[2*n-5] = 0x7fff;                          */
/*        w[2*n-2] = w[2*n-4] = w[2*n-6] = 0x0000;                          */
/*                                                                          */
/*  ASSUMPTIONS                                                             */
/*      This code works for  both "npoints" a multiple of 2 or 4.           */
/*      The arrays 'x[]', 'y[]', and 'w[]' all must be aligned on a         */
/*      double-word boundary for the "optimized" implementations.           */
/*                                                                          */
/*      The input and output data are complex, with the real/imaginary      */
/*      components stored in adjacent locations in the array.  The real     */
/*      components are stored at even array indices, and the imaginary      */
/*      components are stored at odd array indices.                         */
/*                                                                          */
/*  TECHNIQUES                                                              */
/*      The following C code represents an implementation of the Cooley     */
/*      Tukey radix 4 DIF IFFT. It accepts the inputs in normal order and   */
/*      produces the outputs in digit reversed order. The natural C code    */
/*      shown in this file on the other hand, accepts the inputs in nor-    */
/*      mal order and produces the outputs in normal order.                 */
/*                                                                          */
/*      Several transformations have been applied to the original Cooley    */
/*      Tukey code to produce the natural C code description shown here.    */
/*      In order to understand these it would first be educational to       */
/*      understand some of the issues involved in the conventional Cooley   */
/*      Tukey FFT code.                                                     */
/*                                                                          */
/*      void radix4(int n, short x[], short wn[])                           */
/*      {                                                                   */
/*          int    n1,  n2,  ie,   ia1,  ia2, ia3;                          */
/*          int    i0,  i1,  i2,    i3,    i, j,     k;                     */
/*          short  co1, co2, co3,  si1,  si2, si3;                          */
/*          short  xt0, yt0, xt1,  yt1,  xt2, yt2;                          */
/*          short  xh0, xh1, xh20, xh21, xl0, xl1,xl20,xl21;                */
/*                                                                          */
/*          n2 = n;                                                         */
/*          ie = 1;                                                         */
/*          for (k = n; k > 1; k >>= 2)                                     */
/*          {                                                               */
/*              n1 = n2;                                                    */
/*              n2 >>= 2;                                                   */
/*              ia1 = 0;                                                    */
/*                                                                          */
/*              for (j = 0; j < n2; j++)                                    */
/*              {                                                           */
/*                   ia2 = ia1 + ia1;                                       */
/*                   ia3 = ia2 + ia1;                                       */
/*                                                                          */
/*                   co1 = wn[2 * ia1    ];                                 */
/*                   si1 = wn[2 * ia1 + 1];                                 */
/*                   co2 = wn[2 * ia2    ];                                 */
/*                   si2 = wn[2 * ia2 + 1];                                 */
/*                   co3 = wn[2 * ia3    ];                                 */
/*                   si3 = wn[2 * ia3 + 1];                                 */
/*                   ia1 = ia1 + ie;                                        */
/*                                                                          */
/*                   for (i0 = j; i0< n; i0 += n1)                          */
/*                   {                                                      */
/*                       i1 = i0 + n2;                                      */
/*                       i2 = i1 + n2;                                      */
/*                       i3 = i2 + n2;                                      */
/*                                                                          */
/*                                                                          */
/*                       xh0  = x[2 * i0    ] + x[2 * i2    ];              */
/*                       xh1  = x[2 * i0 + 1] + x[2 * i2 + 1];              */
/*                       xl0  = x[2 * i0    ] - x[2 * i2    ];              */
/*                       xl1  = x[2 * i0 + 1] - x[2 * i2 + 1];              */
/*                                                                          */
/*                       xh20 = x[2 * i1    ] + x[2 * i3    ];              */
/*                       xh21 = x[2 * i1 + 1] + x[2 * i3 + 1];              */
/*                       xl20 = x[2 * i1    ] - x[2 * i3    ];              */
/*                       xl21 = x[2 * i1 + 1] - x[2 * i3 + 1];              */
/*                                                                          */
/*                       x[2 * i0    ] = xh0 + xh20;                        */
/*                       x[2 * i0 + 1] = xh1 + xh21;                        */
/*                                                                          */
/*                       xt0  = xh0 - xh20;                                 */
/*                       yt0  = xh1 - xh21;                                 */
/*                       xt1  = xl0 - xl21;                                 */
/*                       yt2  = xl1 - xl20;                                 */
/*                       xt2  = xl0 + xl21;                                 */
/*                       yt1  = xl1 + xl20;                                 */
/*                                                                          */
/*                       x[2 * i1    ] = (xt1 * co1 - yt1 * si1) >> 15;     */
/*                       x[2 * i1 + 1] = (yt1 * co1 + xt1 * si1) >> 15;     */
/*                       x[2 * i2    ] = (xt0 * co2 - yt0 * si2) >> 15;     */
/*                       x[2 * i2 + 1] = (yt0 * co2 + xt0 * si2) >> 15;     */
/*                       x[2 * i3    ] = (xt2 * co3 - yt2 * si3) >> 15;     */
/*                       x[2 * i3 + 1] = (yt2 * co3 + xt2 * si3) >> 15;     */
/*                   }                                                      */
/*             }                                                            */
/*                                                                          */
/*             ie <<= 2;                                                    */
/*         }                                                                */
/*     }                                                                    */
/*                                                                          */
/*      The conventional Cooley Tukey FFT, is written using three loops.    */
/*      The outermost loop "k" cycles through the stages. There are log     */
/*      N to the base 4 stages in all. The loop "j" cycles through the      */
/*      groups of butterflies with different twiddle factors, loop "i"      */
/*      reuses the twiddle factors for the different butterflies within     */
/*      a stage. It is interesting to note the following:                   */
/*                                                                          */
/*-------------------------------------------------------------------------S*/
/*      Stage#     #Groups     # Butterflies with common     #Groups*Bflys  */
/*                               twiddle factors                            */
/*-------------------------------------------------------------------------S*/
/*       1         N/4          1                            N/4            */
/*       2         N/16         4                            N/4            */
/*       ..                                                                 */
/*       logN      1            N/4                          N/4            */
/*-------------------------------------------------------------------------S*/
/*                                                                          */
/*      The following statements can be made based on above observations:   */
/*                                                                          */
/*      a) Inner loop "i0" iterates a veriable number of times. In          */
/*      particular the number of iterations quadruples every time from      */
/*      1..N/4. Hence software pipelining a loop that iterates a vraiable   */
/*      number of times is not profitable.                                  */
/*                                                                          */
/*      b) Outer loop "j" iterates a variable number of times as well.      */
/*      However the number of iterations is quartered every time from       */
/*      N/4 .  . Hence the behaviour in (a) and (b) are exactly opposite    */
/*      to each other.                                                      */
/*                                                                          */
/*      c) If the two loops "i" and "j" are colaesced together then they    */
/*      will iterate for a fixed number of times namely N/4. This allows    */
/*      us to combine the "i" and "j" loops into 1 loop. Optimized impl-    */
/*      ementations will make use of this fact.                             */
/*                                                                          */
/*      In addition the Cooley Tukey FFT accesses three twiddle factors     */
/*      per iteration of the inner loop, as the butterflies that re-use     */
/*      twiddle factors are lumped together. This leads to accessing the    */
/*      twiddle factor array at three points each sepearted by "ie". Note   */
/*      that "ie" is initially 1, and is quadrupled with every iteration.   */
/*      Therfore these three twiddle factors are not even contiguous in     */
/*      the array.                                                          */
/*                                                                          */
/*      In order to vectorize the FFT, it is desirable to access twiddle    */
/*      factor array using double word wide loads and fetch the twiddle     */
/*      factors needed. In order to do this a modified twiddle factor       */
/*      array is created, in which the factors WN/4, WN/2, W3N/4 are        */
/*      arranged to be contiguous. This eliminates the seperation between   */
/*      twiddle factors within a butterfly. However this implies that as    */
/*      the loop is traversed from one stage to another, that we maintain   */
/*      a redundant version of the twiddle factor array. Hence the size     */
/*      of the twiddle factor array increases as compared to the normal     */
/*      Cooley Tukey FFT.  The modified twiddle factor array is of size     */
/*      "2 * N" where the conventional Cooley Tukey FFT is of size"3N/4"    */
/*      where N is the number of complex points to be transformed. The      */
/*      routine that generates the modified twiddle factor array was        */
/*      presented earlier. With the above transformation of the FFT,        */
/*      both the input data and the twiddle factor array can be accessed    */
/*      using double-word wide loads to enable packed data processing.      */
/*                                                                          */
/*      The final stage is optimised to remove the multiplication as        */
/*      w0 = 1.  This stage also performs digit reversal on the data,       */
/*      so the final output is in natural order.                            */
/*                                                                          */
/*      The fft() code shown here performs the bulk of the computation      */
/*      in place. However, because digit-reversal cannot be performed       */
/*      in-place, the final result is written to a separate array, y[].     */
/*                                                                          */
/*      There is one slight break in the flow of packed processing that     */
/*      needs to be comprehended. The real part of the complex number is    */
/*      in the lower half, and the imaginary part is in the upper half.     */
/*      The flow breaks in case of "xl0" and "xl1" because in this case     */
/*      the real part needs to be combined with the imaginary part because  */
/*      of the multiplication by "j". This requires a packed quantity like  */
/*      "xl21xl20" to be rotated as "xl20xl21" so that it can be combined   */
/*       using add2's and sub2's. Hence the natural version of C code       */
/*      shown below is transformed using packed data processing as shown:   */
/*                                                                          */
/*                       xl0  = x[2 * i0    ] - x[2 * i2    ];              */
/*                       xl1  = x[2 * i0 + 1] - x[2 * i2 + 1];              */
/*                       xl20 = x[2 * i1    ] - x[2 * i3    ];              */
/*                       xl21 = x[2 * i1 + 1] - x[2 * i3 + 1];              */
/*                                                                          */
/*                       xt1  = xl0 + xl21;                                 */
/*                       yt2  = xl1 + xl20;                                 */
/*                       xt2  = xl0 - xl21;                                 */
/*                       yt1  = xl1 - xl20;                                 */
/*                                                                          */
/*                       xl1_xl0   = _sub2(x21_x20, x21_x20)                */
/*                       xl21_xl20 = _sub2(x32_x22, x23_x22)                */
/*                       xl20_xl21 = _rotl(xl21_xl20, 16)                   */
/*                                                                          */
/*                       yt2_xt1   = _add2(xl1_xl0, xl20_xl21)              */
/*                       yt1_xt2   = _sub2(xl1_xl0, xl20_xl21)              */
/*                                                                          */
/*      Also notice that xt1, yt1 endup on seperate words, these need to    */
/*      be packed together to take advantage of the packed twiddle fact     */
/*      ors that have been loaded. In order for this to be achieved they    */
/*      are re-aligned as follows:                                          */
/*                                                                          */
/*      yt1_xt1 = _packhl2(yt1_xt2, yt2_xt1)                                */
/*      yt2_xt2 = _packhl2(yt2_xt1, yt1_xt2)                                */
/*                                                                          */
/*      The packed words "yt1_xt1" allows the loaded"sc" twiddle factor     */
/*      to be used for the complex multiplies. The real part os the         */
/*      complex multiply is implemented using _dotp2. The imaginary         */
/*      part of the complex multiply is implemented using the 16x32         */
/*      multiply instruction "mpylir" or "mpyhir".                          */
/*                                                                          */
/*      (X + jY) ( C + j S) = (XC + YS) + j (YC - XS).                      */
/*                                                                          */
/*      The actual twiddle factors for the FFT are cosine, - sine. The      */
/*      twiddle factors stored in the table are csine and sine, hence       */
/*      the sign of the "sine" term is comprehended during multipli-        */
/*      cation as shown above.                                              */
/*                                                                          */
/*  MEMORY NOTE                                                             */
/*      The optimized implementations are written for LITTLE ENDIAN.        */
/*                                                                          */
/*  INTERRUPTS                                                              */
/*      This code is interrupt tolerant but not interruptible. It masks out */
/*      interrupts for the entire duration of the code.                     */
/*                                                                          */
/*  CYCLES                                                                  */
/*      (13 * N/8 + 25) * ceil(log4(N) - 1) + (N + 8) * 1.5 + 30            */
/*                                                                          */
/*      N = 512, (13 * 64 + 25) * 4 + 520 * 1.5 + 30 = 4238 cycles          */
/*                                                                          */
/*  CODESIZE                                                                */
/*      1064 bytes                                                          */
/* ------------------------------------------------------------------------ */
/*            Copyright (c) 2002 Texas Instruments, Incorporated.           */
/*                           All Rights Reserved.                           */
/* ======================================================================== */
/*==========================================================================S*/
#ifndef DSP_IFFT16X32_H_
#define DSP_IFFT16X32_H_ 1

void DSP_ifft16x32(const short * ptr_w, int  npoints,
                 int   * ptr_x, int  *ptr_y ) ;

#endif
/* ======================================================================== */
/*  End of file:  dsp_ifft16x32.h                                           */
/* ------------------------------------------------------------------------ */
/*            Copyright (c) 2002 Texas Instruments, Incorporated.           */
/*                           All Rights Reserved.                           */
/* ======================================================================== */
