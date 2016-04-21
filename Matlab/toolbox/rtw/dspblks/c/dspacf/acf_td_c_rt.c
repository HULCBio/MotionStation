/*
 * acf_td_c_rt.c - Signal Processing Blockset AutoCorrelation run-time library components.
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.3.2.3 $  $Date: 2004/04/12 23:40:38 $
 */

#include "dsp_rt.h"

/*
 * Time domain autocorrelation of a complex single precision signal.
 */

EXPORT_FCN void MWDSP_ACF_TD_C(
    const creal32_T *inPtr,
    int_T           inRows,
    creal32_T       *outPtr,
    int_T           outRows,
    int_T           outChans
)
{
    int_T   i, c, jcnt;
    const creal32_T *p0, *p1;
    creal32_T *y = outPtr, csum;

    for(c=0; c<outChans; c++) {
        for(i=0; i<outRows; i++) {
            p0   = inPtr + c*inRows;
            p1   = inPtr + c*inRows + i;
            csum.re  = 0.0F;
            csum.im  = 0.0F;
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

/* [EOF] acf_td_c_rt.c */
