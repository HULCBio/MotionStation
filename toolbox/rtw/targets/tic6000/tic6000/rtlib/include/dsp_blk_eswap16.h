/* $Revision: 1.5 $ $Date: 2002/04/26 23:44:00 $ */
/* ======================================================================== */
/*  TEXAS INSTRUMENTS, INC.                                                 */
/*                                                                          */
/*  DSPLIB  DSP Signal Processing Library                                   */
/*                                                                          */
/*      Release:        Version 1.02                                        */
/*      CVS Revision:   1.3     Mon Mar 25 11:02:44 2002 (UTC)              */
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
/*      DSP_blk_eswap16 -- Endian-swap a block of 16-bit values             */
/*                                                                          */
/*  REVISION DATE                                                           */
/*      25-Mar-2002                                                         */
/*                                                                          */
/*  USAGE                                                                   */
/*      This routine has the following C prototype:                         */
/*                                                                          */
/*          void DSP_blk_eswap16                                            */
/*          (                                                               */
/*              void *restrict src,     // Source data                 //   */
/*              void *restrict dst,     // Destination array           //   */
/*              int  n_hwords           // Number of halfwords to swap //   */
/*          );                                                              */
/*                                                                          */
/*      This function performs an endian-swap on the data in the "src"      */
/*      array, writing the results to "dst".  If NULL is passed in for      */
/*      the destination, then the endian-swap is performed in-place.        */
/*      The "n_hwords" argument gives the total length of the array in      */
/*      half-words.                                                         */
/*                                                                          */
/*  DESCRIPTION                                                             */
/*      The data in the "src" array is endian swapped, meaning that the     */
/*      byte-order of the bytes within each word of the src[] array is      */
/*      reversed.  This is meant to facilitate moving big-endian data       */
/*      to a little-endian system or vice-versa.                            */
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
/*      The input array and output array are expected to be word            */
/*      aligned, and a multiple of 8 half-words must be processed.          */
/*                                                                          */
/*  NOTES                                                                   */
/*      This function locks out interrupts for its entire duration.         */
/*      It is interrupt tolerant, but not interruptible.                    */
/*                                                                          */
/*  CODESIZE                                                                */
/*      256 bytes                                                           */
/*                                                                          */
/*  CYCLES                                                                  */
/*      cycles = 19 + 0.375 * n_hwords.                                     */
/*                                                                          */
/* ------------------------------------------------------------------------ */
/*            Copyright (c) 2002 Texas Instruments, Incorporated.           */
/*                           All Rights Reserved.                           */
/* ======================================================================== */
#ifndef DSP_BLK_ESWAP16_H_
#define DSP_BLK_ESWAP16_H_ 1

void DSP_blk_eswap16
(
    void *restrict src,     /* Source data                 */
    void *restrict dst,     /* Destination array           */
    int  n_hwords           /* Number of halfwords to swap */
);

#endif
/* ======================================================================== */
/*  End of file:  dsp_blk_eswap16.h                                         */
/* ------------------------------------------------------------------------ */
/*            Copyright (c) 2002 Texas Instruments, Incorporated.           */
/*                           All Rights Reserved.                           */
/* ======================================================================== */
