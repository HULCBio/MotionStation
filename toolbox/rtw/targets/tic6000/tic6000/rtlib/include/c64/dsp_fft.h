/* ======================================================================== */
/*  TEXAS INSTRUMENTS, INC.                                                 */
/*                                                                          */
/*  DSPLIB  DSP Signal Processing Library                                   */
/*                                                                          */
/*      Release:        Version 1.02                                        */
/*      CVS Revision:   1.12    Sun Mar 10 01:10:26 2002 (UTC)              */
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
/*                                                                          */
/*  TEXAS INSTRUMENTS, INC.                                                 */
/*                                                                          */
/*  NAME                                                                    */
/*      DSP_fft                                                             */
/*                                                                          */
/*                                                                          */
/*  REVISION DATE                                                           */
/*      16-Oct-2000                                                         */
/*                                                                          */
/*  USAGE                                                                   */
/*      This routine is C-callable and can be called as:                    */
/*                                                                          */
/*      void DSP_fft(const short *w, int nsamp, short *x, short *y);        */
/*                                                                          */
/*      nsamp = length of DSP_fft in complex samples                        */
/*      x     = pointer to complex data input, time domain                  */
/*      w     = pointer to complex twiddle factors                          */
/*      y     = pointer to complex data output, frequency domain            */
/*                                                                          */
/*  DESCRIPTION                                                             */
/*      This code performs a Radix-4 FFT with digit reversal.  The code     */
/*      uses a special ordering of twiddle factors and memory accesses      */
/*      to improve performance in the presence of cache.  It operates       */
/*      largely in-place, but the final digit-reversed output is written    */
/*      out-of-place.                                                       */
/*                                                                          */
/*      This code requires a special sequence of twiddle factors stored     */
/*      in Q.15 fixed-point format.  The following C code illustrates       */
/*      one way to generate the desired twiddle-factor array:               */
/*                                                                          */
/*      #include <math.h>                                                   */
/*                                                                          */
/*      #ifndef PI                                                          */
/*      # define PI (3.14159265358979323846)                                */
/*      #endif                                                              */
/*                                                                          */
/*      short d2s(double d)                                                 */
/*      {                                                                   */
/*          d = floor(0.5 + d);  // Explicit rounding to integer //         */
/*          if (d >=  32767.0) return  32767;                               */
/*          if (d <= -32768.0) return -32768;                               */
/*          return (short)d;                                                */
/*      }                                                                   */
/*                                                                          */
/*      void gen_twiddle(short *w, int n)                                   */
/*      {                                                                   */
/*          double M = 32767.5;                                             */
/*          int i, j, k;                                                    */
/*                                                                          */
/*          for (j = 1, k = 0; j < n >> 2; j = j << 2)                      */
/*          {                                                               */
/*              for (i = 0; i < n >> 2; i += j << 1)                        */
/*              {                                                           */
/*                  w[k + 11] = d2s(M * cos(6.0 * PI * (i + j) / n));       */
/*                  w[k + 10] = d2s(M * sin(6.0 * PI * (i + j) / n));       */
/*                  w[k +  9] = d2s(M * cos(6.0 * PI * (i    ) / n));       */
/*                  w[k +  8] = d2s(M * sin(6.0 * PI * (i    ) / n));       */
/*                                                                          */
/*                  w[k +  7] = d2s(M * cos(4.0 * PI * (i + j) / n));       */
/*                  w[k +  6] = d2s(M * sin(4.0 * PI * (i + j) / n));       */
/*                  w[k +  5] = d2s(M * cos(4.0 * PI * (i    ) / n));       */
/*                  w[k +  4] = d2s(M * sin(4.0 * PI * (i    ) / n));       */
/*                                                                          */
/*                  w[k +  3] = d2s(M * cos(2.0 * PI * (i + j) / n));       */
/*                  w[k +  2] = d2s(M * sin(2.0 * PI * (i + j) / n));       */
/*                  w[k +  1] = d2s(M * cos(2.0 * PI * (i    ) / n));       */
/*                  w[k +  0] = d2s(M * sin(2.0 * PI * (i    ) / n));       */
/*                                                                          */
/*                  k += 12;                                                */
/*              }                                                           */
/*          }                                                               */
/*          w[2*n - 1] = w[2*n - 3] = w[2*n - 5] = 32767;                   */
/*          w[2*n - 2] = w[2*n - 4] = w[2*n - 6] = 0;                       */
/*      }                                                                   */
/*                                                                          */
/*  ASSUMPTIONS                                                             */
/*      n must be a power of 4 and n >= 16 & n < 32768.                     */
/*      FFT data x are aligned on a double word boundary, in real/imag      */
/*      pairs, FFT twiddle factors w are also aligned on a double word      */
/*      boundary in real/imaginary pairs.                                   */
/*                                                                          */
/*      Input FFT coeffs. are in signed Q.15 format.                        */
/*      The memory Configuration is LITTLE ENDIAN.                          */
/*      The complex data will be returned in natural order. This code is    */
/*      uninteruptable, interupts are disabled on entry to the function and */
/*      re-enabled on exit.                                                 */
/*                                                                          */
/*  MEMORY NOTE                                                             */
/*      No bank conflict stalls occur in this code.                         */
/*                                                                          */
/*  TECHNIQUES                                                              */
/*      A special sequence of coefficients. are used (as generated above)   */
/*      to produce the DSP_fft. This collapses the inner 2 loops in the     */
/*      taditional Burrus and Parks implementation Fortran Code.            */
/*                                                                          */
/*     The following C code represents an implementation of the Cooley      */
/*     Tukey radix 4 DIF FFT. It accepts the inputs in normal order and     */
/*     produces the outputs in digit reversed order. The natural C code     */
/*     shown in this file on the other hand, accepts the inputs in nor-     */
/*     mal order and produces the outputs in normal order.                  */
/*                                                                          */
/*     Several transformations have been applied to the original Cooley     */
/*     Tukey code to produce the natural C code description shown here.     */
/*     In order to understand these it would first be educational to        */
/*     understand some of the issues involved in the conventional Cooley    */
/*     Tukey FFT code.                                                      */
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
/*      N/4 ..1. Hence the behaviour in (a) and (b) are exactly opposite    */
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
/*      The DSP_fft() code shown here performs the bulk of the computation  */
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
/*      part of the complex multiply is implemented using _dotpn2           */
/*      after the twiddle factors are swizzled within the half word.        */
/*                                                                          */
/*      (X + jY) ( C + j S) = (XC + YS) + j (YC - XS).                      */
/*                                                                          */
/*      The actual twiddle factors for the FFT are cosine, - sine. The      */
/*      twiddle factors stored in the table are csine and sine, hence       */
/*      the sign of the "sine" term is comprehended during multipli-        */
/*      cation as shown above.                                              */
/*                                                                          */
/*  CYCLES                                                                  */
/*      cycles = 1.25*nsamp*log4(nsamp) - 0.5*nsamp + 23*log4(nsamp) - 1    */
/*                                                                          */
/*      For nsamp = 1024,  cycles = 6002                                    */
/*      For nsamp = 256,   cycles = 1243                                    */
/*      For nsamp = 64,    cycles = 276                                     */
/*                                                                          */
/*  CODESIZE                                                                */
/*      984 bytes                                                           */
/*                                                                          */
/*  C CODE                                                                  */
/*      This is the C equivalent of the assembly code without restrictions: */
/*      Note that the assembly code is hand optimized and restrictions may  */
/*      apply.                                                              */
/*                                                                          */
/* void DSP_fft(short *ptr_w, int n, short *ptr_x, short *ptr_y)            */
/* {                                                                        */
/*   int   i, j, l1, l2, h2, predj, tw_offset, stride, fft_jmp;             */
/*   short xt0_0, yt0_0, xt1_0, yt1_0, xt2_0, yt2_0;                        */
/*   short xt0_1, yt0_1, xt1_1, yt1_1, xt2_1, yt2_1;                        */
/*   short xh0_0, xh1_0, xh20_0, xh21_0, xl0_0, xl1_0, xl20_0, xl21_0;      */
/*   short xh0_1, xh1_1, xh20_1, xh21_1, xl0_1, xl1_1, xl20_1, xl21_1;      */
/*   short x_0, x_1, x_2, x_3, x_l1_0, x_l1_1, x_l1_2, x_l1_3, x_l2_0:      */
/*   short x_10, x_11, x_12, x_13, x_14, x_15, x_16, x_17, x_l2_1, x_h2_3;  */
/*   short x_4, x_5, x_6, x_7, x_l2_2, x_l2_3, x_h2_0, x_h2_1, x_h2_2;      */
/*   short si10, si20, si30, co10, co20, co30;                              */
/*   short si11, si21, si31, co11, co21, co31;                              */
/*   short * x, *w, * x2, * x0;                                             */
/*   short * y0, * y1, * y2, *y3;                                           */
/*                                                                          */
/*   stride = n; -* n is the number of complex samples *-                   */
/*   tw_offset = 0;                                                         */
/*   while (stride > 4)  // for all strides > 4 //                          */
/*   {                                                                      */
/*       j = 0;                                                             */
/*       fft_jmp = stride + (stride>>1);                                    */
/*       h2 = stride>>1;                          // n/4 //                 */
/*       l1 = stride;                             // n/2 //                 */
/*       l2 = stride + (stride>>1);               // 3n/4 //                */
/*       x = ptr_x;                                                         */
/*       w = ptr_w + tw_offset;                                             */
/*       tw_offset += fft_jmp;                                              */
/*       stride = stride>>2;                                                */
/*                                                                          */
/*       for (i = 0; i < n>>1; i += 4)                                      */
/*       {                                                                  */
/*           co10 = w[j+1];    si10 = w[j+0];   // W  //                    */
/*           co11 = w[j+3];    si11 = w[j+2];                               */
/*           co20 = w[j+5];    si20 = w[j+4];   // W^2 //                   */
/*           co21 = w[j+7];    si21 = w[j+6];                               */
/*           co30 = w[j+9];    si30 = w[j+8];   // W^3 //                   */
/*           co31 = w[j+11];   si31 = w[j+10];                              */
/*                                                                          */
/*           x_0 = x[0];       x_1 = x[1];         // perform 2 parallel // */
/*           x_2 = x[2];       x_3 = x[3];         // radix4 butterflies // */
/*                                                                          */
/*           x_l1_0 = x[l1  ]; x_l1_1 = x[l1+1];                            */
/*           x_l1_2 = x[l1+2]; x_l1_3 = x[l1+3];                            */
/*                                                                          */
/*           x_l2_0 = x[l2  ]; x_l2_1 = x[l2+1];                            */
/*           x_l2_2 = x[l2+2]; x_l2_3 = x[l2+3];                            */
/*                                                                          */
/*           x_h2_0 = x[h2  ]; x_h2_1 = x[h2+1];                            */
/*           x_h2_2 = x[h2+2]; x_h2_3 = x[h2+3];                            */
/*                                                                          */
/*           xh0_0  = x_0    + x_l1_0; xh1_0  = x_1    + x_l1_1;            */
/*           xh0_1  = x_2    + x_l1_2; xh1_1  = x_3    + x_l1_3;            */
/*                                                                          */
/*           xl0_0  = x_0    - x_l1_0; xl1_0  = x_1    - x_l1_1;            */
/*           xl0_1  = x_2    - x_l1_2; xl1_1  = x_3    - x_l1_3;            */
/*                                                                          */
/*           xh20_0 = x_h2_0 + x_l2_0; xh21_0 = x_h2_1 + x_l2_1;            */
/*           xh20_1 = x_h2_2 + x_l2_2; xh21_1 = x_h2_3 + x_l2_3;            */
/*                                                                          */
/*           xl20_0 = x_h2_0 - x_l2_0; xl21_0 = x_h2_1 - x_l2_1;            */
/*           xl20_1 = x_h2_2 - x_l2_2; xl21_1 = x_h2_3 - x_l2_3;            */
/*                                                                          */
/*           x0 = x;                                                        */
/*           x2 = x0;                 // copy pointers for output//         */
/*                                                                          */
/*           j += 12;                                                       */
/*           x += 4;                                                        */
/*           predj = (j - fft_jmp);   // check if reached end of //         */
/*           if (!predj) x += fft_jmp;// current twiddle factor section //  */
/*           if (!predj) j = 0;                                             */
/*                                                                          */
/*           x0[0] = xh0_0 + xh20_0; x0[1] = xh1_0 + xh21_0;                */
/*           x0[2] = xh0_1 + xh20_1; x0[3] = xh1_1 + xh21_1;                */
/*                                                                          */
/*           xt0_0 = xh0_0 - xh20_0;  yt0_0 = xh1_0 - xh21_0;               */
/*           xt0_1 = xh0_1 - xh20_1;  yt0_1 = xh1_1 - xh21_1;               */
/*                                                                          */
/*           xt1_0 = xl0_0 + xl21_0;  yt2_0 = xl1_0 + xl20_0;               */
/*           xt2_0 = xl0_0 - xl21_0;  yt1_0 = xl1_0 - xl20_0;               */
/*           xt1_1 = xl0_1 + xl21_1;  yt2_1 = xl1_1 + xl20_1;               */
/*           xt2_1 = xl0_1 - xl21_1;  yt1_1 = xl1_1 - xl20_1;               */
/*                                                                          */
/*           x2[h2  ] = (si10 * yt1_0 + co10 * xt1_0) >> 15;                */
/*           x2[h2+1] = (co10 * yt1_0 - si10 * xt1_0) >> 15;                */
/*                                                                          */
/*           x2[h2+2] = (si11 * yt1_1 + co11 * xt1_1) >> 15;                */
/*           x2[h2+3] = (co11 * yt1_1 - si11 * xt1_1) >> 15;                */
/*                                                                          */
/*           x2[l1  ] = (si20 * yt0_0 + co20 * xt0_0) >> 15;                */
/*           x2[l1+1] = (co20 * yt0_0 - si20 * xt0_0) >> 15;                */
/*                                                                          */
/*           x2[l1+2] = (si21 * yt0_1 + co21 * xt0_1) >> 15;                */
/*           x2[l1+3] = (co21 * yt0_1 - si21 * xt0_1) >> 15;                */
/*                                                                          */
/*           x2[l2  ] = (si30 * yt2_0 + co30 * xt2_0) >> 15;                */
/*           x2[l2+1] = (co30 * yt2_0 - si30 * xt2_0) >> 15;                */
/*                                                                          */
/*           x2[l2+2] = (si31 * yt2_1 + co31 * xt2_1) >> 15;                */
/*           x2[l2+3] = (co31 * yt2_1 - si31 * xt2_1) >> 15;                */
/*       }                                                                  */
/*   }-* end while *-                                                       */
/*                                                                          */
/*   y0 = ptr_y;                                                            */
/*   y1 = y0 + (int)(n>>1);                                                 */
/*   y2 = y1 + (int)(n>>1);                                                 */
/*   y3 = y2 + (int)(n>>1);                                                 */
/*   x0 = ptr_x;                                                            */
/*   x2 = ptr_x + (int)(n>>1);                                              */
/*   l1 = _norm(n) + 2;                                                     */
/*   j = 0;                                                                 */
/*   for (i = 0; i < n; i += 8)                                             */
/*   {                                                                      */
/*       h2 = _deal(j);                                                     */
/*       h2 = _bitr(h2);                                                    */
/*       h2 = _rotl(h2, 16);                                                */
/*       h2 = _shfl(h2);                                                    */
/*       h2 >>= l1;                                                         */
/*                                                                          */
/*       x_0 = x0[0]; x_1 = x0[1];                                          */
/*       x_2 = x0[2]; x_3 = x0[3];                                          */
/*       x_4 = x0[4]; x_5 = x0[5];                                          */
/*       x_6 = x0[6]; x_7 = x0[7];                                          */
/*       x0 += 8;                                                           */
/*                                                                          */
/*       xh0_0  = x_0 + x_4; xh1_0  = x_1 + x_5;                            */
/*       xl0_0  = x_0 - x_4; xl1_0  = x_1 - x_5;                            */
/*       xh20_0 = x_2 + x_6; xh21_0 = x_3 + x_7;                            */
/*       xl20_0 = x_2 - x_6; xl21_0 = x_3 - x_7;                            */
/*                                                                          */
/*       xt0_0 = xh0_0 - xh20_0;                                            */
/*       yt0_0 = xh1_0 - xh21_0;                                            */
/*       xt1_0 = xl0_0 + xl21_0;                                            */
/*       yt2_0 = xl1_0 + xl20_0;                                            */
/*       xt2_0 = xl0_0 - xl21_0;                                            */
/*       yt1_0 = xl1_0 - xl20_0;                                            */
/*                                                                          */
/*       y0[2*h2  ] = xh0_0 + xh20_0;                                       */
/*       y0[2*h2+1] = xh1_0 + xh21_0;                                       */
/*       y1[2*h2  ] = xt1_0;                                                */
/*       y1[2*h2+1] = yt1_0;                                                */
/*       y2[2*h2  ] = xt0_0;                                                */
/*       y2[2*h2+1] = yt0_0;                                                */
/*       y3[2*h2  ] = xt2_0;                                                */
/*       y3[2*h2+1] = yt2_0;                                                */
/*                                                                          */
/*       x_10 = x2[0]; x_11 = x2[1];                                        */
/*       x_12 = x2[2]; x_13 = x2[3];                                        */
/*       x_14 = x2[4]; x_15 = x2[5];                                        */
/*       x_16 = x2[6]; x_17 = x2[7];                                        */
/*       x2 += 8;                                                           */
/*                                                                          */
/*       xh0_1  = x_10 + x_14; xh1_1  = x_11 + x_15;                        */
/*       xl0_1  = x_10 - x_14; xl1_1  = x_11 - x_15;                        */
/*       xh20_1 = x_12 + x_16; xh21_1 = x_13 + x_17;                        */
/*       xl20_1 = x_12 - x_16; xl21_1 = x_13 - x_17;                        */
/*                                                                          */
/*       xt0_1 = xh0_1 - xh20_1;                                            */
/*       yt0_1 = xh1_1 - xh21_1;                                            */
/*       xt1_1 = xl0_1 + xl21_1;                                            */
/*       yt2_1 = xl1_1 + xl20_1;                                            */
/*       xt2_1 = xl0_1 - xl21_1;                                            */
/*       yt1_1 = xl1_1 - xl20_1;                                            */
/*                                                                          */
/*       y0[2*h2+2] = xh0_1 + xh20_1;                                       */
/*       y0[2*h2+3] = xh1_1 + xh21_1;                                       */
/*       y1[2*h2+2] = xt1_1;                                                */
/*       y1[2*h2+3] = yt1_1;                                                */
/*       y2[2*h2+2] = xt0_1;                                                */
/*       y2[2*h2+3] = yt0_1;                                                */
/*       y3[2*h2+2] = xt2_1;                                                */
/*       y3[2*h2+3] = yt2_1;                                                */
/*                                                                          */
/*       j += 4;                                                            */
/*       if (j == n>>2)                                                     */
/*       {                                                                  */
/*         j  += n>>2;                                                      */
/*         x0 += (int) n>>1;                                                */
/*         x2 += (int) n>>1;                                                */
/*       }                                                                  */
/*     }                                                                    */
/* }                                                                        */
/* ------------------------------------------------------------------------ */
/*            Copyright (c) 2002 Texas Instruments, Incorporated.           */
/*                           All Rights Reserved.                           */
/* ======================================================================== */
#ifndef DSP_FFT_H_
#define DSP_FFT_H_ 1

void DSP_fft(const short *w, int nsamp, short *x, short *y);

#endif
/* ======================================================================== */
/*  End of file:  dsp_fft.h                                                 */
/* ------------------------------------------------------------------------ */
/*            Copyright (c) 2002 Texas Instruments, Incorporated.           */
/*                           All Rights Reserved.                           */
/* ======================================================================== */
