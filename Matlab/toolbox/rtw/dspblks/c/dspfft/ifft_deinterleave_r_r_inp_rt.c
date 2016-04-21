/*
 * ifft_deinterleave_r_r_inp_rt.c - Signal Processing Blockset FFT run-time library components.
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.5.2.3 $  $Date: 2004/04/12 23:44:19 $
 */

#include "dspfft_rt.h"

/*
 * In-place deinterleaving of real and imag parts of an array into
 * separate arrays. Input is a real_T pointer to a space containing creal_T data.
 * 
 */


static int_T getNextOrbitIndex(int_T prevIdx, int_T N) {
     int_T nextIdx = prevIdx<<1;
     if (nextIdx >= N) {nextIdx-=(N-1);}
     return(nextIdx);
}


EXPORT_FCN void MWDSP_Ifft_Deinterleave_R_R_Inp(real32_T *y, const int_T nChans, const int_T N, real32_T *tmp)
{
    int_T     firstIndexOfOrbit = 1;
    int_T     moveCnt = N-2;

    while (moveCnt>0) {
        int_T nextIdx = firstIndexOfOrbit;
        int_T goodOrbit;
        do {
            nextIdx = getNextOrbitIndex(nextIdx, N);
            goodOrbit = (nextIdx >= firstIndexOfOrbit);
        } while (nextIdx > firstIndexOfOrbit);

        if (goodOrbit) {
            int_T     k;
            int_T prevIdx = firstIndexOfOrbit;
            nextIdx       = getNextOrbitIndex(prevIdx, N);
            for (k=0; k<nChans; k++) tmp[k] = *(y+(k*N)+prevIdx);
            do {
                for (k=0; k<nChans; k++) *(y+(k*N)+prevIdx) = *(y+(k*N)+nextIdx);
                moveCnt--;
                prevIdx = nextIdx;
                nextIdx = getNextOrbitIndex(prevIdx, N);
            } while (nextIdx != firstIndexOfOrbit);
            for (k=0; k<nChans; k++) *(y+(k*N)+prevIdx) = tmp[k];
            moveCnt--;
        }
        firstIndexOfOrbit += 2;
    }
}

/* [EOF] ifft_deinterleave_r_r_inp_rt.c */
