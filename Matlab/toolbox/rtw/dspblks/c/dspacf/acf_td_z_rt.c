/*
 * acf_td_z_rt.c - Signal Processing Blockset AutoCorrelation run-time library components.
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.3.2.3 $  $Date: 2004/04/12 23:40:41 $
 */

#include "dsp_rt.h"

/*
 * Time domain autocorrelation of a complex double precision signal.
 */

EXPORT_FCN void MWDSP_ACF_TD_Z(
    const creal_T *inPtr,
    int_T         inRows,
    creal_T       *outPtr,
    int_T         outRows,
    int_T         outChans
)
{
    int_T   i, c, jcnt;
    const creal_T *p0, *p1;
    creal_T *y = outPtr, csum;

    for(c=0; c<outChans; c++) {
        for(i=0; i<outRows; i++) {
            p0   = inPtr + c*inRows;
            p1   = inPtr + c*inRows + i;
            csum.re  = 0.0;
            csum.im  = 0.0;
            jcnt = inRows-i;
        
            while(jcnt-- > 0) {
                csum.re += CMULT_XCONJ_RE(*p0, *p1);
                csum.im += CMULT_XCONJ_IM(*p0, *p1);
                p0++; p1++;
            }
            *y++ = csum;
        }
    }
}

/* [EOF] acf_td_z_rt.c */
