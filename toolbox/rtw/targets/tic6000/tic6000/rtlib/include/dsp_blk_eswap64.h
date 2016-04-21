/* $Revision: 1.5 $ $Date: 2002/04/26 23:44:10 $ */
/* ======================================================================== */
/*  TEXAS INSTRUMENTS, INC.                                                 */
/*                                                                          */
/*  DSPLIB  DSP Signal Processing Library                                   */
/*                                                                          */
/*      Release:        Version 1.02                                        */
/*      CVS Revision:   1.5     Mon Mar 11 21:56:18 2002 (UTC)              */
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
/*  NAME                                                                    */
/*      DSP_blk_eswap64 -- Endian-swap a block of 64-bit values             */
/*                                                                          */
/*  REVISION DATE                                                           */
/*      10-Aug-2001                                                         */
/*                                                                          */
/*  USAGE                                                                   */
/*      This routine has the following C prototype:                         */
/*                                                                          */
/*          void DSP_blk_eswap64                                            */
/*          (                                                               */
/*              void *restrict src, // Source data                    //    */
/*              void *restrict dst, // Destination array              //    */
/*              int  n_dbls         // Number of double-words to swap //    */
/*          );                                                              */
/*                                                                          */
/*      This function performs an endian-swap on the data in the "src"      */
/*      array, writing the results to "dst".  If NULL is passed in for      */
/*      the destination, then the endian-swap is performed in-place.        */
/*      The "n_dbls" argument gives the total length of the array in        */
/*      double-words.                                                       */
/*                                                                          */
/*  DESCRIPTION                                                             */
/*      The data in the "src" array is endian swapped, meaning that the     */
/*      byte-order of the bytes within each double-word of the src[]        */
/*      array is reversed.  This is meant to facilitate moving big-endian   */
/*      data to a little-endian system or vice-versa.                       */
/*                                                                          */
/*      When the "dst" pointer is non-NULL, the endian-swap occurs          */
/*      out-of-place, similar to a block move.  When the "dst" pointer      */
/*      is NULL, the endian-swap occurs in-place, allowing the swap to      */
/*      occur without using any additional storage.                         */
/*                                                                          */
/*  ASSUMPTIONS                                                             */
/*      Input and output arrays do not overlap, except in the very          */
/*      specific case that "dst == NULL" so that the operation occurs       */
/*      in-place.                                                           */
/*                                                                          */
/*      The input array and output array are expected to be double-word     */
/*      aligned, and a multiple of 2 double-words long.                     */
/*                                                                          */
/*      The input array must be at least 2 double-words long.               */
/*                                                                          */
/*  NOTES                                                                   */
/*      This function locks out interrupts for its entire duration.         */
/*      It is interrupt tolerant, but not interruptible.                    */
/*                                                                          */
/*  CODESIZE                                                                */
/*      224 bytes                                                           */
/*                                                                          */
/*  CYCLES                                                                  */
/*      cycles = 20 + 3 * n_dbls                                            */
/*                                                                          */
/* ------------------------------------------------------------------------ */
/*            Copyright (c) 2002 Texas Instruments, Incorporated.           */
/*                           All Rights Reserved.                           */
/* ======================================================================== */
#ifndef DSP_BLK_ESWAP64_H_
#define DSP_BLK_ESWAP64_H_ 1

void DSP_blk_eswap64
(
    void *restrict src, /* Source data                    */
    void *restrict dst, /* Destination array              */
    int  n_dbls         /* Number of double-words to swap */
);

#endif
/* ======================================================================== */
/*  End of file:  dsp_blk_eswap64.h                                         */
/* ------------------------------------------------------------------------ */
/*            Copyright (c) 2002 Texas Instruments, Incorporated.           */
/*                           All Rights Reserved.                           */
/* ======================================================================== */
