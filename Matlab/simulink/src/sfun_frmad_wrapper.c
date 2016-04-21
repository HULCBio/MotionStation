/*
 * File : sfun_frmad_wrapper.c
 * Abstract:
 *    Routine that implements a frame-based source block. This is used to
 *    act as a A-D converter in demo models.
 *
 * Copyright 1990-2002 The MathWorks, Inc.
 * $Revision: 1.5 $
 */

#include "tmwtypes.h"
#include "sfun_frmad_wrapper.h"
#include <math.h>

#define PI 3.14159265358979
#undef MAX /* undefining MAX in case it was already defined somewhere else*/
#define MAX(a,b) (((a) >= (b)) ? (a) : (b))

void sfun_frmad_const_wrapper(real_T *y, 
                              int_T  frmSize, real_T ts,
                              int_T  count,
                              int_T  nAmps,   const real_T *amps,
                              real_T noisA,   real_T noisF)
{
    int_T  el      = 0;
    int_T  i;
    int_T  k;
    
    for (k = 0; k < nAmps; k++) {
        real_T amp     = amps[k];
        real_T counter = (real_T) (count);
        for (i = 0; i < frmSize; i++) {
            y[el]  = amp;
            y[el] += noisA*sin(2*PI*noisF*ts*counter);
            el++;
            counter++;
        }
    }
}



void sfun_frmad_sine_wrapper(real_T *y, 
                             int_T  frmSize, real_T ts,
                             int_T  count,
                             int_T  nAmps,   const real_T *amps,
                             int_T  nFreqs,  const real_T *freqs,
                             real_T noisA,   real_T noisF)
{
    int_T  el      = 0;
    int_T  i;
    int_T  k;
    int_T  nChans  = MAX(nAmps, nFreqs);
    
    for (k = 0; k < nChans; k++) {
        real_T amp     = (nAmps == 1) ? (*amps) : amps[k];
        real_T freq    = (nFreqs == 1) ? (*freqs) : freqs[k];
        real_T counter = (real_T) (count);
        for (i = 0; i < frmSize; i++) {
            y[el]  = amp*sin(2*PI*freq*ts*counter);
            y[el] += noisA*sin(2*PI*noisF*ts*counter);
            counter++;
            el++;
            }
    }
}

/* [EOF] sfun_frmad_wrapper.c */
