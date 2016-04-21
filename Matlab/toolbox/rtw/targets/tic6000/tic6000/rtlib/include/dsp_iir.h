/* $Revision: 1.9 $ $Date: 2002/04/26 23:45:42 $ */
/* ======================================================================== */
/*  TEXAS INSTRUMENTS, INC.                                                 */
/*                                                                          */
/*  DSPLIB  DSP Signal Processing Library                                   */
/*                                                                          */
/*      Release:        Version 1.02                                        */
/*      CVS Revision:   1.5     Fri Mar 29 15:47:22 2002 (UTC)              */
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
/*      iir                                                                 */
/*                                                                          */
/*                                                                          */
/*  REVISION DATE                                                           */
/*      11-Feb-2002                                                         */
/*                                                                          */
/*  USAGE                                                                   */
/*      This routine is C callable and can be called as:                    */
/*                                                                          */
/*          void DSP_iir                                                    */
/*          (                                                               */
/*              short *restrict r1,      // Output array (used)      //     */
/*              const short     *x,      // Input array              //     */
/*              short *restrict r2,      // Output array (stored)    //     */
/*              const short     *h2,     // Filter Coeffs. AR part   //     */
/*              const short     *h1,     // Filter Coeffs. FIR part  //     */
/*              int             nr       // Number of output samples //     */
/*          )                                                               */
/*                                                                          */
/*  DESCRIPTION                                                             */
/*      The IIR performs an auto-regressive moving-average (ARMA) filter    */
/*      with 4 auto-regressive filter coefficients and 5 moving-average     */
/*      filter coefficients for nr output samples. The output vector is     */
/*      stored in two locations.  This routine is used as a high pass       */
/*      filter in the VSELP vocoder.                                        */
/*                                                                          */
/*  C CODE                                                                  */
/*      void DSP_iir                                                        */
/*      (                                                                   */
/*          short *restrict r1,      // Output array (used)      //         */
/*          const short     *x,      // Input array              //         */
/*          short *restrict r2,      // Output array (stored)    //         */
/*          const short     *h2,     // Filter Coeffs. AR part   //         */
/*          const short     *h1,     // Filter Coeffs. FIR part  //         */
/*          int             nr       // Number of output samples //         */
/*      )                                                                   */
/*      {                                                                   */
/*          int j, i;                                                       */
/*          int sum;                                                        */
/*                                                                          */
/*          for (i = 0; i < nr; i++)                                        */
/*          {                                                               */
/*              sum = h2[0] * x[4+i];                                       */
/*                                                                          */
/*              for (j = 1; j <= 4; j++)                                    */
/*                  sum += h2[j] * x[4+i-j] - h1[j] * r1[4+i-j];            */
/*                                                                          */
/*              r1[4+i] = (sum >> 15);                                      */
/*              r2[  i] = r1[4+i];                                          */
/*          }                                                               */
/*      }                                                                   */
/*                                                                          */
/*  TECHNIQUES                                                              */
/*      The inner loop is completely unrolled and software pipelined        */
/*      (i.e. each time the 5 cycle loop "LOOP" is executed the inner       */
/*      loop of the C code is executed.)                                    */
/*                                                                          */
/*  MEMORY NOTE                                                             */
/*      This code is ENDIAN NEUTRAL.                                        */
/*      This code is interrupt-tolerant but not interruptible.              */
/*                                                                          */
/*  MEMORY NOTE                                                             */
/*      To avoid memory hits r1[] and r2[] must be aligned on the next word */
/*      boundary following the alignment of x[], e.g.:                      */
/*          #pragma DATA_MEM_BANK(x, 0);                                    */
/*          #pragma DATA_MEM_BANK(r1, 2);                                   */
/*          #pragma DATA_MEM_BANK(r2, 2);                                   */
/*                                                                          */
/*  CYCLES                                                                  */
/*      5 * nr + 30                                                         */
/*                                                                          */
/*      For nr = 40: 230 cycles                                             */
/*                                                                          */
/*  CODESIZE                                                                */
/*      384 bytes                                                           */
/*                                                                          */
/* ------------------------------------------------------------------------ */
/*            Copyright (c) 2002 Texas Instruments, Incorporated.           */
/*                           All Rights Reserved.                           */
/* ======================================================================== */
#ifndef DSP_IIR_H_
#define DSP_IIR_H_ 1

void DSP_iir
(
    short *restrict r1,      /* Output array (used);      */
    const short     *x,      /* Input array              */
    short *restrict r2,      /* Output array (stored);    */
    const short     *h2,     /* Filter Coeffs. AR part   */
    const short     *h1,     /* Filter Coeffs. FIR part  */
    int             nr       /* Number of output samples */
);

#endif
/* ======================================================================== */
/*  End of file:  dsp_iir.h                                                 */
/* ------------------------------------------------------------------------ */
/*            Copyright (c) 2002 Texas Instruments, Incorporated.           */
/*                           All Rights Reserved.                           */
/* ======================================================================== */
