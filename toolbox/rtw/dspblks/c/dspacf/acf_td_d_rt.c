/*
 * acf_td_d_rt.c - Signal Processing Blockset AutoCorrelation run-time library components.
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.3.2.3 $  $Date: 2004/04/12 23:40:39 $
 */

#include "dsp_rt.h"

/*
 * Time domain autocorrelation of a real double precision signal.
 */

EXPORT_FCN void MWDSP_ACF_TD_D(
    const real_T  *inPtr,
    int_T         inRows,
    real_T        *outPtr,
    int_T         outRows,
    int_T         outChans
)
{
    int_T   i, c, jcnt;
    const real_T *p0, *p1;
    real_T *y = outPtr, sum;

    for(c=0; c<outChans; c++) {
        for(i=0; i<outRows; i++) {
            p0   = inPtr + c*inRows;
            p1   = inPtr + c*inRows + i;
            sum  = 0.0;
            jcnt = inRows-i;
        
            while(jcnt-- > 0) {
                sum += *p0++ * *p1++;
            }
            *y++ = sum;
        }
    }
}

/* [EOF] acf_td_d_rt.c */
