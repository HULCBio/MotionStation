/*
 * File : sfun_frm_dft_wrapper.c
 * Abstract:
 *    Routine that implements a multi-channel frame-based Discrete-Fourier
 *    transform.
 *
 * Copyright 1990-2002 The MathWorks, Inc.
 * $Revision: 1.3 $
 */

#include "tmwtypes.h"
#include "sfun_frmdft_wrapper.h"
#include <math.h>

#define PI 3.14159265358979

void sfun_frm_dft_wrapper(real_T *x, creal_T *y, int_T frmSize, int_T nChans,
                          int_T dftSize)
{
    int_T   n,k,c;
    int_T   oCount  = 0;

    /* Zero out the output */
    for (k = 0; k < nChans*dftSize; k++) {
        y[k].re = 0.0;
        y[k].im = 0.0;
    } 
        
    for (c = 0; c < nChans; c++) {
        int_T nOffset = frmSize * c;
        for (k = 0; k < dftSize; k++) {
            real_T freqFactor = 2.0*PI*k/((real_T)dftSize);
            for (n = 0; n < frmSize; n++) {
                y[oCount].re += x[n+nOffset] * (cos(freqFactor*n));
                y[oCount].im += -(x[n+nOffset] * (sin(freqFactor*n)));
            }
            oCount++;
        }
    }
}



void sfun_frm_idft_wrapper(creal_T *x, real_T *y, int_T frmSize, int_T nChans,
                           int_T dftSize)
{
    int_T   n,k,c;
    int_T   oCount  = 0;

    /* Zero out the output */
    for (k = 0; k < nChans*dftSize; k++) {
        y[k] = 0.0;
    } 
        
    for (c = 0; c < nChans; c++) {
        int_T nOffset = frmSize * c;
        for (k = 0; k < dftSize; k++) {
            for (n = 0; n < frmSize; n++) {
                real_T tmp = x[n+nOffset].re * (cos(2*PI*k*n/dftSize)) -
                    x[n+nOffset].im * (sin(2*PI*k*n/dftSize));
                y[oCount] += (1/((real_T) frmSize)) * tmp;
            }
            oCount++;
        }
    }
}

/* [EOF] sfun_frmdft_wrapper.c */
