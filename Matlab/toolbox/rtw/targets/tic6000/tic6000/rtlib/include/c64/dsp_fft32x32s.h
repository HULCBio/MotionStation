/* ======================================================================== */
/*  TEXAS INSTRUMENTS, INC.                                                 */
/*                                                                          */
/*  DSPLIB  DSP Signal Processing Library                                   */
/*                                                                          */
/*      Release:        Version 1.02                                        */
/*      CVS Revision:   1.4     Thu Sep  6 18:22:33 2001 (UTC)              */
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
/*           DSP_fft32x32s: Double Precision FFT with scaling               */
/*                                                                          */
/*     USAGE                                                                */
/*           This routine is C-callable and can be called as:               */
/*                                                                          */
/*          void DSP_fft32x32s(const int  * ptr_w, int  npoints,            */
/*                           int   * ptr_x, int  * ptr_y ) ;                */
/*                                                                          */
/*            ptr_w   =  input twiddle factors                              */
/*            npoints =  number of points                                   */
/*            ptr_x   =  transformed data reversed                          */
/*            ptr_y   =  linear transformed data                            */
/*                                                                          */
/*           (See the C compiler reference guide.)                          */
/*                                                                          */
/*  DESCRIPTION                                                             */
/*      The following code performs a mixed radix FFT for "npoints" which   */
/*      is either a multiple of 4 or 2. It uses logN4 - 1 stages of radix4  */
/*      transform and performs either a radix2 or radix4 transform on the   */
/*      last stage depending on "npoints". If "npoints" is a multiple of 4, */
/*      then this last stage is also a radix4 transform, otherwise it is a  */
/*      radix2 transform. This program is available as a C compilable file  */
/*      to automatically generate the twiddle factors "twiddle_split.c"     */
/*                                                                          */
/*      Generate special vector of twiddle factors                          */
/*                                                                          */
/*      for (j=1, k=0; j < npoints>>2; j = j <<2 )                          */
/*      {                                                                   */
/*          for (i=0; i < npoints>>2; i += j)                               */
/*          {                                                               */
/*              theta1 = 2*PI*i/npoints;                                    */
/*              x_t = M*cos(theta1);                                        */
/*              y_t = M*sin(theta1);                                        */
/*              ptr_w[k+1] = (int) x_t;                                     */
/*              if (x_t >= M) ptr_w[k+1] = 0x7fffffff;                      */
/*              ptr_w[k+0] = (int) y_t;                                     */
/*              if (y_t >= M) ptr_w[k+0] = 0x7fffffff;                      */
/*                                                                          */
/*              theta2 = 4*PI*i/npoints;                                    */
/*              x_t = M*cos(theta2);                                        */
/*              y_t = M*sin(theta2);                                        */
/*              ptr_w[k+3] = (int) x_t;                                     */
/*                                                                          */
/*              if (x_t >= M) ptr_w[k+3] = 0x7fffffff;                      */
/*              ptr_w[k+2] = (int) y_t;                                     */
/*              if (y_t >= M) ptr_w[k+2] = 0x7fffffff;                      */
/*                                                                          */
/*              theta3 = 6*PI*i/npoints;                                    */
/*              x_t = M*cos(theta3);                                        */
/*              y_t = M*sin(theta3);                                        */
/*              ptr_w[k+5] = (int) x_t;                                     */
/*              if (x_t >= M) ptr_w[k+5] = 0x7fffffff;                      */
/*              ptr_w[k+4] = (int) y_t;                                     */
/*              if (y_t >= M) ptr_w[k+4] = 0x7fffffff;                      */
/*              k += 6;                                                     */
/*          }                                                               */
/*      }                                                                   */
/*                                                                          */
/*                                                                          */
/*  ASSUMPTIONS                                                             */
/*      This code works for  both "npoints" a multiple of 2 or 4.           */
/*      The arrays 'x[]', 'y[]', and 'w[]' all must be aligned on a         */
/*      double-word boundary for the "optimized" implementations.           */
/*      The input and output data are complex, with the real/imaginary      */
/*      components stored in adjacent locations in the array.  The real     */
/*      components are stored at even array indices, and the imaginary      */
/*      components are stored at odd array indices. The input, twiddle      */
/*      factors are in 32 bit precision. The 32 by 32 multiplies are        */
/*      done with a 1.5 bit loss in accuracy. This comes about because      */
/*      the contribution of the low sixteen bits to the 32 bit result       */
/*      is not computed. In addition the contribution of the low * high     */
/*      term is shifted by 16 as opposed to 15, for a loss 0f 0.5 bits      */
/*      after rounding. To illustrate real part of complex multiply of:     */
/*      (X + jY) ( C + jS) =                                                */
/*                                                                          */
/*      _mpyhir(si10 , yt1_0)  + _mpyhir(co10 , xt1_0) +                    */
/*                       (((MPYLUHS(si10,yt1_0) + MPYLUHS(co10, xt1_0)      */
/*                                              + 0x8000)  >> 16) << 1)     */
/*                                                                          */
/*      The intrinsic C version of this code performs this function as:     */
/*                                                                          */
/*      _mpyhir(si10 , yt1_0)  + _mpyhir(co10 , xt1_0) +                    */
/*                       (_dotprsu2(yt1_0xt1_0, si10co10) << 1);            */
/*                                                                          */
/*                                                                          */
/*      where the functions _mpyhir, MPYLUHS are as follows:                */
/*                                                                          */
/*  #define _mpyhir(x,y) \                                                  */
/*  (((int)((short)(x>>16)*(unsigned short)(y&0x0000FFFF)+0x4000) >> 15)    */
/*   + \ ((int)((short)(x >> 16) * (short)((y) >> 16)) << 1))               */
/*                                                                          */
/*  #define MPYLUHS(x,y)   \                                                */
/*      ( (int) ((unsigned short)(x & 0x0000FFFF) * (short) (y >> 16)) )    */
/*                                                                          */
/*                                                                          */
/*  TECHNIQUES                                                              */
/*      The following C code represents an implementation of the Cooley     */
/*      Tukey radix 4 DIF FFT. It accepts the inputs in normal order and    */
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
/*                       xt1  = xl0 + xl21;                                 */
/*                       yt2  = xl1 + xl20;                                 */
/*                       xt2  = xl0 - xl21;                                 */
/*                       yt1  = xl1 - xl20;                                 */
/*                                                                          */
/*                       x[2 * i1    ] = (xt1 * co1 + yt1 * si1) >> 15;     */
/*                       x[2 * i1 + 1] = (yt1 * co1 - xt1 * si1) >> 15;     */
/*                       x[2 * i2    ] = (xt0 * co2 + yt0 * si2) >> 15;     */
/*                       x[2 * i2 + 1] = (yt0 * co2 - xt0 * si2) >> 15;     */
/*                       x[2 * i3    ] = (xt2 * co3 + yt2 * si3) >> 15;     */
/*                       x[2 * i3 + 1] = (yt2 * co3 - xt2 * si3) >> 15;     */
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
/*      In the folllowing code since all data elements are 32 bits, add2    */
/*      sub2 are replaced with normal 32 bit add's and subtracts.           */
/*      The packed words "yt1_xt1" allows the loaded"sc" twiddle factor     */
/*      to be used for the complex multiplies. The real part of the         */
/*      multiply and the imaginary part of the multiply are performed       */
/*      as 16x32 multiplies using MPYLIR and MPYHIR                         */
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
/*  CYCLES                                                                  */
/*      [(N/4 + 1) * 10 + 10] * ceil(log4(N) - 1) + 6 * (N/4 + 2) + 27      */
/*                                                                          */
/*      N = 512, [1290 + 10] * 4 + 6 * 130 + 27 = 6007 cycles               */
/*                                                                          */
/*  CODESIZE                                                                */
/*      932 bytes                                                           */
/* ------------------------------------------------------------------------ */
/*            Copyright (c) 2002 Texas Instruments, Incorporated.           */
/*                           All Rights Reserved.                           */
/* ======================================================================== */
/*==========================================================================S*/
#ifndef DSP_FFT32X32S_H_
#define DSP_FFT32X32S_H_ 1

void DSP_fft32x32s(const int  * ptr_w, int  npoints,
                 int   * ptr_x, int  * ptr_y ) ;

#endif
/* ======================================================================== */
/*  End of file:  dsp_fft32x32s.h                                           */
/* ------------------------------------------------------------------------ */
/*            Copyright (c) 2002 Texas Instruments, Incorporated.           */
/*                           All Rights Reserved.                           */
/* ======================================================================== */
