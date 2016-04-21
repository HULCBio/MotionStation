/* 
 * File : sfun_frm_dft_wrapper.h
 * Abstract:
 *    External definitions of routines that implements a multi-channel 
 *    frame-based Discrete-Fourier transform (and its inverse).
 *
 * Copyright 1990-2002 The MathWorks, Inc.
 * $Revision: 1.3 $
 */

extern void sfun_frm_dft_wrapper(real_T *x, creal_T *y, int_T frmSize,
                                 int_T nChans, int_T dftSize);

extern void sfun_frm_idft_wrapper(creal_T *x, real_T *y, int_T frmSize,
                                  int_T nChans, int_T dftSize);


/* [eof] sfun_frmdft_wrapper.h */
