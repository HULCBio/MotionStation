/* ======================================================================== */
/*  TEXAS INSTRUMENTS, INC.                                                 */
/*                                                                          */
/*  DSPLIB  DSP Signal Processing Library                                   */
/*                                                                          */
/*      Release:        Version 1.02                                        */
/*      CVS Revision:   1.7     Thu Sep  6 18:22:31 2001 (UTC)              */
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
/* ========================================================================= */
/*                                                                           */
/*  TEXAS INSTRUMENTS, INC.                                                  */
/*                                                                           */
/*  NAME                                                                     */
/*        DSP_fft16x16r : 16x16 FFT with rounding and scaling                */
/*                                                                           */
/*                                                                           */
/*  REVISION DATE                                                            */
/*      12-Sep-2000                                                          */
/*                                                                           */
/*  USAGE                                                                    */
/*        This routine is C-callable and can be called as:                   */
/*                                                                           */
/*        void DSP_fft16x16r                                                 */
/*        (                                                                  */
/*            int                       n,                                   */
/*            short *restrict           ptr_x,                               */
/*            const short *restrict     ptr_w,                               */
/*            unsigned char *restrict   brev,                                */
/*            short *restrict           ptr_y,                               */
/*            int                       radix,                               */
/*            int                       offset,                              */
/*            int                       nmax                                 */
/*        )                                                                  */
/*                                                                           */
/*        N      = length of fft in complex samples, power of 2 <=16384      */
/*        ptr_x  = pointer to complex data input                             */
/*        ptr_w  = pointer to complex twiddle factor (see below)             */
/*        brev   = pointer to bit reverse table containing 64 entries        */
/*        n_min  = smallest fft butterfly used in computation                */
/*                 used for decomposing fft into subffts, see notes          */
/*        offset = index in complex samples of sub-fft from start of main ff */
/*        n_max  = size of main fft in complex samples                       */
/*                                                                           */
/*  DESCRIPTION                                                              */
/*       The benchmark performs a mixed radix forwards fft using             */
/*       a special sequence of coefficients generated in the following       */
/*       way:                                                                */
/*                                                                           */
/*         -* generate vector of twiddle factors for optimized algorithm *-  */
/*        void tw_gen(short * w, int N)                                      */
/*        {                                                                  */
/*          int j, k;                                                        */
/*          double x_t, y_t, theta1, theta2, theta3;                         */
/*          const double PI = 3.141592654, M = 32767.0;                      */
/*                                       -* M is 16383 for scale by 4 *-     */
/*                                                                           */
/*          for (j=1, k=0; j <= N>>2; j = j<<2)                              */
/*          {                                                                */
/*              for (i=0; i < N>>2; i+=j)                                    */
/*              {                                                            */
/*                  theta1 = 2*PI*i/N;                                       */
/*                  x_t = M*cos(theta1);                                     */
/*                  y_t = M*sin(theta1);                                     */
/*                  w[k]   =  (short)x_t;                                    */
/*                  w[k+1] =  (short)y_t;                                    */
/*                                                                           */
/*                  theta2 = 4*PI*i/N;                                       */
/*                  x_t = M*cos(theta2);                                     */
/*                  y_t = M*sin(theta2);                                     */
/*                  w[k+2] =  (short)x_t;                                    */
/*                  w[k+3] =  (short)y_t;                                    */
/*                                                                           */
/*                  theta3 = 6*PI*i/N;                                       */
/*                  x_t = M*cos(theta3);                                     */
/*                  y_t = M*sin(theta3);                                     */
/*                  w[k+4] =  (short)x_t;                                    */
/*                  w[k+5] =  (short)y_t;                                    */
/*                  k+=6;                                                    */
/*              }                                                            */
/*          }                                                                */
/*        }                                                                  */
/*       This redundent set of twiddle factors is size 2*N short samples.    */
/*       As pointed out later dividing these twiddle factors by 2 will give  */
/*       an effective divide by 4 at each stage to guarentee no overflow.    */
/*       The function is accurate to about 68dB of signal to noise ratio     */
/*       to the DFT function below:                                          */
/*                                                                           */
/*        void dft(int n, short x[], short y[])                              */
/*        {                                                                  */
/*           int k,i, index;                                                 */
/*           const double PI = 3  4159654;                                   */
/*           short * p_x;                                                    */
/*           double arg, fx_0, fx_1, fy_0, fy_1, co, si;                     */
/*                                                                           */
/*           for(k = 0; k<n; k++)                                            */
/*           {                                                               */
/*             p_x = x;                                                      */
/*             fy_0 = 0;                                                     */
/*             fy_1 = 0;                                                     */
/*             for(i=0; i<n; i++)                                            */
/*             {                                                             */
/*               fx_0 = (double)p_x[0];                                      */
/*               fx_1 = (double)p_x[1];                                      */
/*               p_x += 2;                                                   */
/*               index = (i*k) % n;                                          */
/*               arg = 2*PI*index/n;                                         */
/*               co = cos(arg);                                              */
/*               si = -sin(arg);                                             */
/*               fy_0 += ((fx_0 * co) - (fx_1 * si));                        */
/*               fy_1 += ((fx_1 * co) + (fx_0 * si));                        */
/*             }                                                             */
/*             y[2*k] = (short)2*fy_0/sqrt(N);                               */
/*             y[2*k+1] = (short)2*fy_1/sqrt(N);                             */
/*           }                                                               */
/*        }                                                                  */
/*       Scaling takes place at each stage except the last one.              */
/*       This is a divide by 2 to prevent overflow. All shifts are rounded t */
/*       reduce truncation noise power by 3dB.                               */
/*       The function takes the table and input data and calculates the fft  */
/*       producing the frequency domain data in the Y array.                 */
/*       As the fft allows every input point to effect every output point in */
/*       a cache based system such as the c6211, this causes cache thrashing */
/*       This is mitigated by allowing the main fft of size N to be divided  */
/*       into several steps, allowing as much data reuse as possible.        */
/*                                                                           */
/*       For example the following function:                                 */
/*                                                                           */
/*       DSP_fft16x16r  (1024, &x_asm[0],&w[0],y_asm,brev,4,  0,1024);       */
/*                                                                           */
/*       is equvalent to:                                                    */
/*                                                                           */
/*       DSP_fft16x16r  (1024,&x_asm[2*0],  &w[0]  ,y_asm,brev,256, 0,1024); */
/*       DSP_fft16x16r  (256, &x_asm[2*0],  &w[2*768],y_asm,brev,4, 0,1024); */
/*       DSP_fft16x16r (256, &x_asm[2*256],&w[2*768],y_asm,brev,4, 256,1024); */
/*       DSP_fft16x16r (256, &x_asm[2*512],&w[2*768],y_asm,brev,4, 512,1024); */
/*       DSP_fft16x16r (256, &x_asm[2*768],&w[2*768],y_asm,brev,4, 768,1024); */
/*                                                                           */
/*       Notice how the 1st fft function is called on the entire 1K data set */
/*       it covers the 1st pass of the fft until the butterfly size is 256.  */
/*       The following 4 ffts do 256 pt ffts 25% of the size. These continue */
/*       down to the end when the buttefly is of size 4. The use an index to */
/*       the main twiddle factor array of 0.75*2*N. This is because the      */
/*       twiddle factor array is composed of successively decimated versions */
/*       of the main array.                                                  */
/*                                                                           */
/*       N not equal to a power of 4 can be used, i.e. 512. In this case to  */
/*       decompose the fft the following would be needed :                   */
/*                                                                           */
/*       DSP_fft16x16r   (512, &x_asm[0],&w[0],y_asm,brev,2,  0,512);        */
/*                                                                           */
/*       is equvalent to:                                                    */
/*                                                                           */
/*       DSP_fft16x16r   (512, &x_asm[0],    &w[0],  y_asm,brev,128, 0,512); */
/*       DSP_fft16x16r   (128, &x_asm[2*0],  &w[2*384],y_asm,brev,2, 0,512); */
/*       DSP_fft16x16r (128, &x_asm[2*128],&w[2*384],y_asm,brev,2, 128,512); */
/*       DSP_fft16x16r (128, &x_asm[2*256],&w[2*384],y_asm,brev,2, 256,512); */
/*       DSP_fft16x16r (128, &x_asm[2*384],&w[2*384],y_asm,brev,2, 384,512); */
/*                                                                           */
/*       The twiddle factor array is composed of log4(N) sets of twiddle     */
/*       factors, (3/4)*N, (3/16)*N, (3/64)*N, etc.  The index into this     */
/*       array for each stage of the fft is calculated by summing these      */
/*       indices up appropriately.                                           */
/*       For multiple ffts they can share the same table by calling the smal */
/*       ffts from further down in the twiddle factor array. In the same way */
/*       as the decomposition works for more data reuse.                     */
/*                                                                           */
/*       Thus, the above decomposition can be summarized for a general N ,   */
/*       radix "rad" as follows:                                             */
/*                                                                           */
/*  DSP_fft16x16r(N,  &x[0],         &w[0],        brev, y_cn, N/4, 0,    N) */
/*  DSP_fft16x16r(N/4,&x[0],         &w[2*(3*N/4)],brev, y_cn, rad, 0,    N) */
/*  DSP_fft16x16r(N/4,&x[2*(N/4)],   &w[2*(3*N/4)],brev, y_cn, rad, N/4,  N) */
/*  DSP_fft16x16r(N/4,&x[2*(N/2)],   &w[2*(3*N/4)],brev, y_cn, rad, N/2,  N) */
/*  DSP_fft16x16r(N/4,&x[2*(3*N/4)], &w[2*3*N/4)], brev, y_cn, rad, 3*N/4, N) */
/*                                                                           */
/*       As discussed previously, N can be either a power of 4 or 2.  If  N  */
/*       N is a power  of 4, rad = 4, and if N is a power of 2, and not  a   */
/*       power of 4, then rad = 2. "rad" is used to control how many stages  */
/*       of decomposition are performed. It is also used to dtermine whether */
/*       a radix4 or radix2 decomposition should be performed at the last    */
/*       stage. Hence when "rad" is set to "N/4" the first stage of the      */
/*       transform alone is performed and the code exits. To complete the    */
/*       FFT four other calls are required to perform N/4 size FFT's. In     */
/*       fact the ordering of these 4 FFT's amonst themselves does not       */
/*       matter and hence from a cahe perspective it helps to go through     */
/*       the remaining 4 FFT's in exactly the opposite order to the first.   */
/*                                                                           */
/*       This is illustrated as follows:                                     */
/*                                                                           */
/*  DSP_fft16x16r(N,  &x[0],         &w[0],        brev, y_cn, N/4, 0,    N) */
/*  DSP_fft16x16r(N/4,&x[2*(3*N/4)], &w[2*3*N/4)], brev, y_cn, rad, 3*N/4, N) */
/*  DSP_fft16x16r(N/4,&x[2*(N/2)],   &w[2*(3*N/4)],brev, y_cn, rad, N/2,  N) */
/*  DSP_fft16x16r(N/4,&x[2*(N/4)],   &w[2*(3*N/4)],brev, y_cn, rad, N/4,  N) */
/*  DSP_fft16x16r(N/4,&x[0],         &w[2*(3*N/4)],brev, y_cn, rad, 0,    N) */
/*                                                                           */
/*       In addition this function can be used to minimize call overhead, by */
/*       completing the FFT with one function call invocation as shown below */
/*                                                                           */
/*       DSP_fft16x16r(N, &x_cn[0], &w[0], y_cn, brev, rad, 0, N)            */
/*                                                                           */
/*   ASSUMPTIONS:                                                            */
/*       n must be a power of 2 and n >= 8  n <= 16384 points.               */
/*       Complex time data x and twiddle facotrs w are aligned on double     */
/*       word boundares. Real values are stored in even word positions and   */
/*       imaginary values in odd positions.                                  */
/*                                                                           */
/*       All data is in short precision integer fixed point form. The        */
/*       complex frequency data will be returned in linear order.            */
/*                                                                           */
/*       If Interupts are required the decomposition can be used to allow    */
/*       interupts to occur in between function calls. In this way interupts */
/*       Can occur roughly every 20%  of the time through the function.      */
/*                                                                           */
/*   MEMORY NOTE:                                                            */
/*       Configuration is LITTLE ENDIAN the code will not function if the -m */
/*       flag is enabled but it can be modified for BIG ENDIAN usage.        */
/*                                                                           */
/*   TECHNIQUES                                                              */
/*       A special sequence of coeffs. used as generated above               */
/*       produces the fft. This collapses the inner 2 loops in the           */
/*       taditional Burrus and Parks implementation Fortran Code.            */
/*                                                                           */
/*       The revised FFT uses a redundant sequence of twiddle factors to     */
/*       allow a linear access through the data. This linear access enables  */
/*       data and instruction level parallelism.                             */
/*       The data produced by the DSP_fft16x16r fft is in normal form, the   */
/*       whole data array is written into a new output buffer.               */
/*                                                                           */
/*       The DSP_fft16x16r butterfly is bit reversed, i.e. the inner 2 points of */
/*       the butterfly are corssed over, this has the effect of making the   */
/*       data come out in bit reversed rather than in radix 4 digit reversed */
/*       order. This simplifies the last pass of the loop. A simple table    */
/*       is used to do the bit reversal out of place.                        */
/*                                                                           */
/*           unsigned char brev[64] = {                                      */
/*                 0x0, 0x20, 0x10, 0x30, 0x8, 0x28, 0x18, 0x38,             */
/*                 0x4, 0x24, 0x14, 0x34, 0xc, 0x2c, 0x1c, 0x3c,             */
/*                 0x2, 0x22, 0x12, 0x32, 0xa, 0x2a, 0x1a, 0x3a,             */
/*                 0x6, 0x26, 0x16, 0x36, 0xe, 0x2e, 0x1e, 0x3e,             */
/*                 0x1, 0x21, 0x11, 0x31, 0x9, 0x29, 0x19, 0x39,             */
/*                 0x5, 0x25, 0x15, 0x35, 0xd, 0x2d, 0x1d, 0x3d,             */
/*                 0x3, 0x23, 0x13, 0x33, 0xb, 0x2b, 0x1b, 0x3b,             */
/*                 0x7, 0x27, 0x17, 0x37, 0xf, 0x2f, 0x1f, 0x3f              */
/*           };                                                              */
/*                                                                           */
/*        This function no longer uses the lookup table to perform bit       */
/*        reversal. It is performed using the _bitr instruction on C64x      */
/*        architecture. It is performed using a macro BIT_REV instead.       */
/*                                                                           */
/*   NOTES                                                                   */
/*       For more aggressive overflow control the shift in the DC term can b */
/*       adjusted to 2 and the twiddle factors shifted right by 1. This give */
/*       a divide by 4 at each stage. For better accuracy the data can be pr */
/*       asserted left by so many bits so that as it builds in magnitude the */
/*       divide by 2 prevents too much growth. An optimal point for example  */
/*       with an 8192pt fft with input data precision of 8 bits is to asert  */
/*       the input 4 bits left to make it 12 bits. This gives an SNR of 68dB */
/*       at the output. By trying combinations the optimal can be found.     */
/*       If scaling isnot required it is possible to replace the MPY by SMPY */
/*       this will give a shift left by 1 so a shift right by 16 gives a     */
/*       total 15 bit shift right. The DC term must be adjusted to give a    */
/*       zero shift.                                                         */
/*                                                                           */
/*   C CODE                                                                  */
/*       The following code is the traditional Burrus and Parks implemen-    */
/*       tation, which performs a mixed radix FFT capable of 2^M, 4^M.       */
/*       However it does not support multiple calls. It uses a traditional   */
/*       twiddle factor array wn, generated as follows:                      */
/*                                                                           */
/*       const double M = 32767.0;                                           */
/*       const double PI = 3  41592654;                                      */
/*                                                                           */
/*       for (i=0, k = 0; i < 3*(N>>2); i++)                                 */
/*       {                                                                   */
/*          theta1 = 2*PI*i/N;                                               */
/*          x_t = M*cos(theta1);                                             */
/*          y_t = M*sin(theta1);                                             */
/*          wn[k]   = (short) x_t;                                           */
/*          if (x_t >= M) wn[k  ] = 0x7fff;                                  */
/*          wn[k+1] = (short) y_t;                                           */
/*          if (y_t >= M) wn[k+1] = 0x7fff;                                  */
/*          k+=2;                                                            */
/*       }                                                                   */
/*                                                                           */
/*       The C code that implements the traditional mixed radix FFT is       */
/*       shown below. It has three nested loops, one for the stages,         */
/*       one for the groups of butterflies, one for the passes.              */
/*                                                                           */
/* void DSP_fft16x16r(int n, short x[], short wn[],                          */
/*       unsigned char brev[], short y[], int radix, int offset, int nmax)   */
/* {                                                                         */
/*     int    n1, n2, ie, ia1, ia2, ia3, i0, i1, i2, i3, i, l0;              */
/*     short  co1, co2, co3, si1, si2, si3;                                  */
/*     short  xt0, yt0, xt1, yt1, xt2, yt2;                                  */
/*     short  xh0,xh1,xh20,xh21,xl0,xl1,xl20,xl21;                           */
/*     short * ptr_x0, * y0;                                                 */
/*     unsigned int  j0, j1, k0, k1, k, j;                                   */
/*     short x0, x1, x2, x3, x4, x5, x6, x7;                                 */
/*     short xh0_0, xh1_0, xh0_1, xh1_1;                                     */
/*     short xl0_0, xl1_0, xl0_1, xl1_1;                                     */
/*     short yt3, yt4, yt5, yt6, yt7;                                        */
/*                                                                           */
/*     n2 = n;                                                               */
/*     ie = 1;                                                               */
/*     for (k = n; k > radix; k >>= 2)                                       */
/*     {                                                                     */
/*         n1 = n2;                                                          */
/*         n2 >>= 2;                                                         */
/*         ia1 = 0;                                                          */
/*         for (j = 0; j < n2; j++)                                          */
/*         {                                                                 */
/*             ia2 = ia1 + ia1;                                              */
/*             ia3 = ia2 + ia1;                                              */
/*             co1 = w[2 * ia1    ];                                         */
/*             si1 = w[2 * ia1 + 1];                                         */
/*             co2 = w[2 * ia2    ];                                         */
/*             si2 = w[2 * ia2 + 1];                                         */
/*             co3 = w[2 * ia3    ];                                         */
/*             si3 = w[2 * ia3 + 1];                                         */
/*             ia1 = ia1 + ie;                                               */
/*             for (i0 = j; i0 < n; i0 += n1)                                */
/*             {                                                             */
/*                 i1 = i0 + n2;                                             */
/*                 i2 = i1 + n2;                                             */
/*                 i3 = i2 + n2;                                             */
/*                                                                           */
/*                 xh0  = x[2 * i0    ] + x[2 * i2    ];                     */
/*                 xh1  = x[2 * i0 + 1] + x[2 * i2 + 1];                     */
/*                 xl0  = x[2 * i0    ] - x[2 * i2    ];                     */
/*                 xl1  = x[2 * i0 + 1] - x[2 * i2 + 1];                     */
/*                                                                           */
/*                 xh20 = x[2 * i1    ] + x[2 * i3    ];                     */
/*                 xh21 = x[2 * i1 + 1] + x[2 * i3 + 1];                     */
/*                 xl20 = x[2 * i1    ] - x[2 * i3    ];                     */
/*                 xl21 = x[2 * i1 + 1] - x[2 * i3 + 1];                     */
/*                                                                           */
/*                 x[2 * i0    ] = (xh0 + xh20 + 1)>>1;                      */
/*                 x[2 * i0 + 1] = (xh1 + xh21 + 1)>>1;                      */
/*                                                                           */
/*                 xt0  = xh0 - xh20;                                        */
/*                 yt0  = xh1 - xh21;                                        */
/*                 xt1  = xl0 + xl21;                                        */
/*                 yt2  = xl1 + xl20;                                        */
/*                 xt2  = xl0 - xl21;                                        */
/*                 yt1  = xl1 - xl20;                                        */
/*                                                                           */
/*                 x[2 * i2    ]= (xt1 * co1 + yt1 * si1 + 0x00008000)>> 16; */
/*                 x[2 * i2 + 1]= (yt1 * co1 - xt1 * si1 + 0x00008000)>> 16; */
/*                 x[2 * i1    ]= (xt0 * co2 + yt0 * si2 + 0x00008000)>> 16; */
/*                 x[2 * i1 + 1]= (yt0 * co2 - xt0 * si2 + 0x00008000)>> 16; */
/*                 x[2 * i3    ]= (xt2 * co3 + yt2 * si3 + 0x00008000)>> 16; */
/*                 x[2 * i3 + 1]= (yt2 * co3 - xt2 * si3 + 0x00008000)>> 16; */
/*             }                                                             */
/*         }                                                                 */
/*                                                                           */
/*         ie <<= 2;                                                         */
/*    }                                                                      */
/*                                                                           */
/*    j = 0;                                                                 */
/*    ptr_x0 = x;                                                            */
/*    y0 = y;                                                                */
/*    l0 = _norm(n) - 17;                                                    */
/*                                                                           */
/*    if(radix == 2 || radix  == 4) for (i = 0; i < n; i += 4)               */
/*    {                                                                      */
/*                                                                           */
/*                                                                           */
/*            j0 = (j     ) & 0x3F;                                          */
/*            j1 = (j >> 6) & 0x3F;                                          */
/*            k0 = brev[j0];                                                 */
/*            k1 = brev[j1];                                                 */
/*            k = (k0 << 6) |  k1;                                           */
/*            if (l0 < 0) k = k << -l0;                                      */
/*            else        k = k >> l0;                                       */
/*            j++;                                                           */
/*                                                                           */
/*            x0   = ptr_x0[0];  x1 = ptr_x0[1];                             */
/*            x2   = ptr_x0[2];  x3 = ptr_x0[3];                             */
/*            x4   = ptr_x0[4];  x5 = ptr_x0[5];                             */
/*            x6   = ptr_x0[6];  x7 = ptr_x0[7];                             */
/*            ptr_x0 += 8;                                                   */
/*                                                                           */
/*            xh0_0  = x0 + x4;                                              */
/*            xh1_0  = x1 + x5;                                              */
/*            xh0_1  = x2 + x6;                                              */
/*            xh1_1  = x3 + x7;                                              */
/*                                                                           */
/*            if (radix == 2)                                                */
/*            {                                                              */
/*                xh0_0 = x0;                                                */
/*                xh1_0 = x1;                                                */
/*                xh0_1 = x2;                                                */
/*                xh1_1 = x3;                                                */
/*            }                                                              */
/*                                                                           */
/*            yt0  = xh0_0 + xh0_1;                                          */
/*            yt1  = xh1_0 + xh1_1;                                          */
/*            yt4  = xh0_0 - xh0_1;                                          */
/*            yt5  = xh1_0 - xh1_1;                                          */
/*                                                                           */
/*            xl0_0  = x0 - x4;                                              */
/*            xl1_0  = x1 - x5;                                              */
/*            xl0_1  = x2 - x6;                                              */
/*            xl1_1  = x3 - x7;                                              */
/*                                                                           */
/*            if (radix == 2)                                                */
/*            {                                                              */
/*                  xl0_0 = x4;                                              */
/*                  xl1_0 = x5;                                              */
/*                  xl1_1 = x6;                                              */
/*                  xl0_1 = x7;                                              */
/*            }                                                              */
/*                                                                           */
/*            yt2  = xl0_0 + xl1_1;                                          */
/*            yt3  = xl1_0 - xl0_1;                                          */
/*                                                                           */
/*            yt6  = xl0_0 - xl1_1;                                          */
/*            yt7  = xl1_0 + xl0_1;                                          */
/*                                                                           */
/*            if (radix == 2)                                                */
/*            {                                                              */
/*                 yt7  = xl1_0 - xl0_1;                                     */
/*                 yt3  = xl1_0 + xl0_1;                                     */
/*            }                                                              */
/*                                                                           */
/*            y0[k] = yt0; y0[k+1] = yt1;                                    */
/*            k += n>>1                                                      */
/*            y0[k] = yt2; y0[k+1] = yt3;                                    */
/*            k += n>>1;                                                     */
/*            y0[k] = yt4; y0[k+1] = yt5;                                    */
/*            k += n>>1;                                                     */
/*            y0[k] = yt6; y0[k+1] = yt7;                                    */
/*       }                                                                   */
/*   }                                                                       */
/*                                                                           */
/*       Although code shown above is the simplest equivalent way of writing */
/*       this code, it already carries several optimization ideas. It has    */
/*       a special last stage to avoid multiplication by 1. In addition it   */
/*       was shown by Panos Papamichalis that if the two middle legs of a    */
/*       radix 4 butterfly are reversed, the outputs for a radix4 transform  */
/*       end up in the bit reversed fashion. The code also carries a linear  */
/*       time look up table for bit reversal. This can be used as shown in   */
/*       the code to construct a bit reversed index. The last stage perfo-   */
/*       rms either a radix4 or radix2 as the case may be.                   */
/*                                                                           */
/*       The code shown below performs loop coalescing as it is realized     */
/*       that while the "i" and "j" loop individually iterate for variable   */
/*       number of times, together they always iterate for N/4 times. The    */
/*       natural C code and the code shown below use a modified twiddle      */
/*       factor array to allow for vectorization of the loop. In addition    */
/*       bit-reversal is performed by a macro BIT_REV. This makes the bit-   */
/*       reversal table redundant.                                           */
/*                                                                           */
/*       This is the C equivalent of the assembly code without restrictions: */
/*       Note that the assembly code is hand optimized and restrictions may  */
/*       apply.                                                              */
/*                                                                           */
/*                                                                           */
/*      void DSP_fft16x16r(int n, short ptr_x[], short ptr_w[], short ptr_y[] */
/*                   unsigned char brev[], int n_min, int offset, int n_max) */
/*      {                                                                    */
/*         int  i, j, k, l1, l2, h2, predj;                                  */
/*         int  tw_offset, stride, fft_jmp;                                  */
/*                                                                           */
/*         short x0, x1, x2, x3,x4,x5,x6,x7;                                 */
/*         short xt0, yt0, xt1, yt1, xt2, yt2, yt3;                          */
/*         short yt4, yt5, yt6, yt7;                                         */
/*         short si1,si2,si3,co1,co2,co3;                                    */
/*         short xh0,xh1,xh20,xh21,xl0,xl1,xl20,xl21;                        */
/*         short x_0, x_1, x_l1, x_l1p1, x_h2 , x_h2p1, x_l2, x_l2p1;        */
/*         short xl0_0, xl1_0, xl0_1, xl1_1;                                 */
/*         short xh0_0, xh1_0, xh0_1, xh1_1;                                 */
/*         short *x,*w;                                                      */
/*         int   k0, k1, j0, j1, l0, radix;                                  */
/*         short * y0, * ptr_x0, * ptr_x2;                                   */
/*                                                                           */
/*         radix = n_min;                                                    */
/*                                                                           */
/*         stride = n; -* n is the number of complex samples *-              */
/*         tw_offset = 0;                                                    */
/*         while (stride > radix)                                            */
/*         {                                                                 */
/*             j = 0;                                                        */
/*             fft_jmp = stride + (stride>>1);                               */
/*             h2 = stride>>1;                                               */
/*             l1 = stride;                                                  */
/*             l2 = stride + (stride>>1);                                    */
/*             x = ptr_x;                                                    */
/*             w = ptr_w + tw_offset;                                        */
/*                                                                           */
/*             for (i = 0; i < n; i += 4)                                    */
/*             {                                                             */
/*                 co1 = w[j];                                               */
/*                 si1 = w[j+1];                                             */
/*                 co2 = w[j+2];                                             */
/*                 si2 = w[j+3];                                             */
/*                 co3 = w[j+4];                                             */
/*                 si3 = w[j+5];                                             */
/*                                                                           */
/*                 x_0    = x[0];                                            */
/*                 x_1    = x[1];                                            */
/*                 x_h2   = x[h2];                                           */
/*                 x_h2p1 = x[h2+1];                                         */
/*                 x_l1   = x[l1];                                           */
/*                 x_l1p1 = x[l1+1];                                         */
/*                 x_l2   = x[l2];                                           */
/*                 x_l2p1 = x[l2+1];                                         */
/*                                                                           */
/*                 xh0  = x_0    + x_l1;                                     */
/*                 xh1  = x_1    + x_l1p1;                                   */
/*                 xl0  = x_0    - x_l1;                                     */
/*                 xl1  = x_1    - x_l1p1;                                   */
/*                                                                           */
/*                 xh20 = x_h2   + x_l2;                                     */
/*                 xh21 = x_h2p1 + x_l2p1;                                   */
/*                 xl20 = x_h2   - x_l2;                                     */
/*                 xl21 = x_h2p1 - x_l2p1;                                   */
/*                                                                           */
/*                 ptr_x0 = x;                                               */
/*                 ptr_x0[0] = ((short) (xh0 + xh20))>>1; can be changed to  */
/*                 ptr_x0[1] = ((short) (xh1 + xh21))>>1; can be changed to  */
/*                                                                           */
/*                 ptr_x2 = ptr_x0;                                          */
/*                 x += 2;                                                   */
/*                 j += 6;                                                   */
/*                 predj = (j - fft_jmp);                                    */
/*                 if (!predj) x += fft_jmp;                                 */
/*                 if (!predj) j = 0;                                        */
/*                                                                           */
/*                 xt0 = xh0 - xh20;                                         */
/*                 yt0 = xh1 - xh21;                                         */
/*                 xt1 = xl0 + xl21;                                         */
/*                 yt2 = xl1 + xl20;                                         */
/*                 xt2 = xl0 - xl21;                                         */
/*                 yt1 = xl1 - xl20;                                         */
/*                                                                           */
/*                 ptr_x2[l1  ] = (xt1 * co1 + yt1 * si1 + 0x8000)>>16;      */
/*                 ptr_x2[l1+1] = (yt1 * co1 - xt1 * si1 + 0x8000)>>16;      */
/*                 ptr_x2[h2  ] = (xt0 * co2 + yt0 * si2 + 0x8000)>>16;      */
/*                 ptr_x2[h2+1] = (yt0 * co2 - xt0 * si2 + 0x8000)>>16;      */
/*                 ptr_x2[l2  ] = (xt2 * co3 + yt2 * si3 + 0x8000)>>16;      */
/*                 ptr_x2[l2+1] = (yt2 * co3 - xt2 * si3 + 0x8000)>>16;      */
/*             }                                                             */
/*             tw_offset += fft_jmp;                                         */
/*             stride = stride>>2;                                           */
/*         }-* end while *-                                                  */
/*                                                                           */
/*         j = offset>>2;                                                    */
/*                                                                           */
/*         ptr_x0 = ptr_x;                                                   */
/*         y0 = ptr_y;                                                       */
/*         l0 = _norm(nmax) - 17; -* get size of fft *-                      */
/*                                                                           */
/*         if (radix <= 4) for (i = 0; i < n; i += 4)                        */
/*         {                                                                 */
/*                 -* reversal computation *-                                */
/*                                                                           */
/*                 j0 = (j     ) & 0x3F;                                     */
/*                 j1 = (j >> 6) & 0x3F;                                     */
/*                 k0 = brev[j0];                                            */
/*                 k1 = brev[j1];                                            */
/*                 k = (k0 << 6) |  k1;                                      */
/*                 k = k >> l0;                                              */
/*                 j++;        -* multiple of 4 index *-                     */
/*                                                                           */
/*                 x0   = ptr_x0[0];  x1 = ptr_x0[1];                        */
/*                 x2   = ptr_x0[2];  x3 = ptr_x0[3];                        */
/*                 x4   = ptr_x0[4];  x5 = ptr_x0[5];                        */
/*                 x6   = ptr_x0[6];  x7 = ptr_x0[7];                        */
/*                 ptr_x0 += 8;                                              */
/*                                                                           */
/*                 xh0_0  = x0 + x4;                                         */
/*                 xh1_0  = x1 + x5;                                         */
/*                 xh0_1  = x2 + x6;                                         */
/*                 xh1_1  = x3 + x7;                                         */
/*                                                                           */
/*                 if (radix == 2) {                                         */
/*                   xh0_0 = x0;                                             */
/*                   xh1_0 = x1;                                             */
/*                   xh0_1 = x2;                                             */
/*                   xh1_1 = x3;                                             */
/*                 }                                                         */
/*                                                                           */
/*                 yt0  = xh0_0 + xh0_1;                                     */
/*                 yt1  = xh1_0 + xh1_1;                                     */
/*                 yt4  = xh0_0 - xh0_1;                                     */
/*                 yt5  = xh1_0 - xh1_1;                                     */
/*                                                                           */
/*                 xl0_0  = x0 - x4;                                         */
/*                 xl1_0  = x1 - x5;                                         */
/*                 xl0_1  = x2 - x6;                                         */
/*                 xl1_1  = x3 - x7;                                         */
/*                                                                           */
/*                 if (radix == 2) {                                         */
/*                   xl0_0 = x4;                                             */
/*                   xl1_0 = x5;                                             */
/*                   xl1_1 = x6;                                             */
/*                   xl0_1 = x7;                                             */
/*                 }                                                         */
/*                                                                           */
/*                 yt2  = xl0_0 + xl1_1;                                     */
/*                 yt3  = xl1_0 - xl0_1;                                     */
/*                 yt6  = xl0_0 - xl1_1;                                     */
/*                 yt7  = xl1_0 + xl0_1;                                     */
/*                                                                           */
/*                 if (radix == 2) {                                         */
/*                   yt7  = xl1_0 - xl0_1;                                   */
/*                   yt3  = xl1_0 + xl0_1;                                   */
/*                 }                                                         */
/*                                                                           */
/*                 y0[k] = yt0; y0[k+1] = yt1;                               */
/*                 k += n>>1;                                                */
/*                 y0[k] = yt2; y0[k+1] = yt3;                               */
/*                 k += n>>1;                                                */
/*                 y0[k] = yt4; y0[k+1] = yt5;                               */
/*                 k += n>>1;                                                */
/*                 y0[k] = yt6; y0[k+1] = yt7;                               */
/*         }                                                                 */
/*     }                                                                     */
/*                                                                           */
/*  REFERENCES                                                               */
/*  [1] C. S. Burrus and T.W. Parks (1985) "DFT/FFT and Convolution Algos -  */
/*      Theory and Implementation", J. Wiley.                                */
/*  [2] Implementation of Various Precision Fast Fourier Transforms on the   */
/*      TMS320C6400 processor - DJH, ESC 2000                                */
/*  [3] Burrus - Rice University and Papamichalis - TI (1988) - Paper on the */
/*      convertion of radix4 to radix2 digit reversal.                       */
/*                                                                           */
/*  SPECIAL NOTES                                                            */
/*  1. Complex multiplies are performed using _dotp2 and _dotpn2. _dotpn2    */
/*  requires the data to be swizzled about the halfword, so that an extra    */
/*  negate can be avoided.                                                   */
/*  2. The intermediate adds and subtracts are performed using _add2's,      */
/*  _sub2's.                                                                 */
/*  3. Data is loaded in using the intrinsic _amemd8 as a double word, and   */
/*  the low and high halves are accessed using _lo and _hi intrinsic.        */
/*  4. Middle two legs of radix4 butterfly are swapped to get intermediate   */
/*  outputs in bit reversed order. Final output in the output array "y" is   */
/*  in normal order.                                                         */
/*                                                                           */
/* CYCLES                                                                    */
/*     Cycle count formula is  for single pass only.                         */
/*     ceil(log4(N) - 1) * (5 * N/4 + 25) + 5 * N/4 + 26                     */
/*                                                                           */
/*     N = 128  cycles = 756  cycles    Single pass                          */
/*     N = 128  cycles = 1041 cycles    Multi  pass                          */
/*     N = 256  cycles = 1383 cycles    Single pass                          */
/*     N = 256  cycles = 1683 cycles    Multi  pass                          */
/*     N = 512  cycles = 3337 cycles    Single pass                          */
/*     N = 512  cycles = 3699 cycles    Multi  pass                          */
/*                                                                           */
/* CODESIZE                                                                  */
/*     868 bytes                                                             */
/*                                                                           */
/*==========================================================================S*/
/*            Copyright (c) 2002 Texas Instruments, Incorporated.           */
/*                           All Rights Reserved.                           */
/*==========================================================================S*/
#ifndef DSP_FFT16X16R_H_
#define DSP_FFT16X16R_H_ 1

void DSP_fft16x16r
(
    int                       n,
    short *restrict           ptr_x,
    const short *restrict     ptr_w,
    unsigned char *restrict   brev,
    short *restrict           ptr_y,
    int                       radix,
    int                       offset,
    int                       nmax
);

#endif
/* ======================================================================== */
/*  End of file:  dsp_fft16x16r.h                                           */
/* ------------------------------------------------------------------------ */
/*            Copyright (c) 2002 Texas Instruments, Incorporated.           */
/*                           All Rights Reserved.                           */
/* ======================================================================== */
