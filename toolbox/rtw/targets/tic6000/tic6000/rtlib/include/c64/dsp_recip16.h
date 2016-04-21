/* ======================================================================== */
/*  TEXAS INSTRUMENTS, INC.                                                 */
/*                                                                          */
/*  DSPLIB  DSP Signal Processing Library                                   */
/*                                                                          */
/*      Release:        Version 1.02                                        */
/*      CVS Revision:   1.4     Thu Sep  6 18:22:58 2001 (UTC)              */
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
/*      DSP_recip16                                                         */
/*                                                                          */
/*                                                                          */
/*  REVISION DATE                                                           */
/*      20-Jul-2001                                                         */
/*                                                                          */
/*  USAGE                                                                   */
/*      This routine is C-callable and can be called as:                    */
/*                                                                          */
/*      void DSP_recip16 (short *x, short *rfrac, short *rexp, short nx);   */
/*                                                                          */
/*      x[nx]     = Pointer to input vector of size nx                      */
/*      rfrac[nx] = Pointer to output vector of size nx to                  */
/*                  contain the fractional part of the reciprocal           */
/*      rexp[nx]  = Pointer to output vector of size nx to                  */
/*                  contain the exponent part of the reciprocal             */
/*      nx        = Number of elements in input vector                      */
/*                                                                          */
/*      (See the C compiler reference guide.)                               */
/*                                                                          */
/*  DESCRIPTION                                                             */
/*      This program performs a reciprocal on a vector of Q15 numbers.      */
/*      The result is stored in two parts: a Q15 part and an exponent       */
/*      (power of two) of the fraction.                                     */
/*      First, the input is loaded, then its absolute value is taken,       */
/*      then it is normalized, then divided using a loop of conditional     */
/*      subtracts, and finally it is negated if the original input was      */
/*      negative.                                                           */
/*                                                                          */
/*      void DSP_recip16 (short *x, short *rfrac, short *rexp, short nx)    */
/*      {                                                                   */
/*         int i,j,a,b;                                                     */
/*         short neg, normal;                                               */
/*                                                                          */
/*         for(i = nx; i > 0; i--)                                          */
/*         {                                                                */
/*             a = *(x++);                                                  */
/*             if(a < 0)             // take absolute value //              */
/*             {                                                            */
/*                 a = -a;                                                  */
/*                 neg = 1;                                                 */
/*             }                                                            */
/*             else                                                         */
/*                 neg = 0;                                                 */
/*             normal = _norm(a);              // normalize //              */
/*             a = a << normal;                                             */
/*             *(rexp++) = normal - 15;   // store exponent //              */
/*             b = 0x80000000;              // dividend = 1 //              */
/*             for(j = 15; j > 0; j--)                                      */
/*                 b = _subc(b,a);                // divide //              */
/*             b = b & 0x7FFF;           // clear remainder //              */
/*             if(neg) b = -b;       // if negative, negate //              */
/*             *(rfrac++) = b;            // store fraction //              */
/*         }                                                                */
/*      }                                                                   */
/*                                                                          */
/*  ASSUMPTIONS                                                             */
/*      LITTLE ENDIAN Configuration used                                    */
/*      x and rfrac are Q15 format                                          */
/*      output is accurate up to the least significant bit of rfrac, but    */
/*      note that this bit could carry over and change rexp too             */
/*                                                                          */
/*  MEMORY NOTE                                                             */
/*      There are no memory bank hits in this procedure                     */
/*                                                                          */
/*  NOTE                                                                    */
/*      interruptible (single assignment code)                              */
/*                                                                          */
/*  TECHNIQUES                                                              */
/*      The conditional subtract instruction, SUBC, is used for division    */
/*      SUBC is used once for every bit of quotient needed (15).            */
/*      2 stages of prolog and epilog collapsed                             */
/*      split 2 live-too-longs (A_neg and B_norm)                           */
/*                                                                          */
/*  CYCLES                                                                  */
/*       8 * nx + 14                                                        */
/*                                                                          */
/*  CODESIZE                                                                */
/*       196 bytes                                                          */
/* ------------------------------------------------------------------------ */
/*            Copyright (c) 2002 Texas Instruments, Incorporated.           */
/*                           All Rights Reserved.                           */
/* ======================================================================== */
#ifndef DSP_RECIP16_H_
#define DSP_RECIP16_H_ 1

void DSP_recip16 (short *x, short *rfrac, short *rexp, short nx);

#endif
/* ======================================================================== */
/*  End of file:  dsp_recip16.h                                             */
/* ------------------------------------------------------------------------ */
/*            Copyright (c) 2002 Texas Instruments, Incorporated.           */
/*                           All Rights Reserved.                           */
/* ======================================================================== */
