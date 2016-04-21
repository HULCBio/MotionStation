/*
 *  upfirdn_dd_rt.c - FIR Rate Converter block runtime helper function
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.3.2.3 $  $Date: 2004/04/12 23:49:33 $
 */
#include "dsp_rt.h"

EXPORT_FCN void MWDSP_UpFIRDn_DD(   const real_T *u,             /* input port*/
                               real_T *y,             /* output port*/
                               real_T *tap0,          /* points to input buffer start address per channel */
                               real_T *sums,          /* points to output of each interp phase per channel */
                               real_T *outBuf,        /* points to output buffer start address per channel */
                         const real_T * const filter, /* FIR coeff */
                               int32_T  *tapIdx,        /* points to input buffer location to read in u */
                               int32_T  *outIdx,        /* points to output buffer data for transfer to y */
                         const int_T  numChans,       /* number of channels */
                         const int_T  inFrameSize,    /* input frame size */
                         const int_T  iFactor,        /* interpolation factor */
                         const int_T  dFactor,        /* decimation factor */
                         const int_T  subOrder,       /* order of each iFactor*dFactor polyphase subfilter */
                         const int_T  memSize,        /* input buffer size per channel */
                         const int_T  outLen,         /* output buffer size per channel */
                         const int_T  n0,             /* inputs to each interpolation phase is separated by n0 samples */
                         const int_T  n1              /* outputs of each interpolation phase is separated by n1 samples */
                         )
{
    const real_T *cff = filter;
    int_T  i, j, k, m, mIdx=0, oIdx=0;

    for (k=0; k < numChans; k++) {
        /* Each channel uses the same filter phase but accesses
         * its own state memory and input.
         */
        int_T inIdx = 0; 
        mIdx  = *tapIdx;
        oIdx  = *outIdx;

        for (i=0; i < inFrameSize; i++) {

            /* Since there are dFactor polyphase subfilters inside each interpolation 
             * phase, each interpolation phase is computed dFactor times 
             * (by incrementing inIdx and testing it against dFactor).
             * Outputs from the iFactor interpolation phases (sums[0], sums[1] ... 
             * sums[iFactor-1]) are then put into the output buffer. 
             */

            /* input values to the next slot in the input circular buffer */
            *(tap0+mIdx) = *u++;   

            /* Compute partial sums (sums[j]) for each interpolation phase */
            for (j=0; j < iFactor; j++) {

                /* Insert a time delay of n0 samples between inputs to each 
                 * interpolation phase */
                real_T  *tap = tap0 + mIdx - (iFactor-j)*n0; 

                /* Execute the inIdx polyphase filter of length subOrder in the jth 
                 * interpolation phase */
                m    = subOrder;
                tap += dFactor;
                while (m--) {
                    tap     -= dFactor;
                    tap      = (tap>=tap0) ? tap : (tap+memSize); /* circular buffer */
                    sums[j] += *tap * (*cff++);
                }
            }

            if (++inIdx == dFactor) {

                /* All polyphase sub-filters have now been executed.
                 * Output sums[0], ... ,sums[iFactor-1] to output buffer */
                for (j=0; j < iFactor; j++) {
                    
                    /* Insert a time delay of j*n1 samples on the output of the jth 
                     * interpolation phase */
                    outBuf[(j*n1+oIdx) % outLen] = sums[j];
                    
                    /* Output results */
                    *y++ = outBuf[(j+oIdx) % outLen];
                    
                    /* Reset sums[j] after they are written into output buffer */
                    sums[j] = 0.0;  
                }

                /* increment oIdx by iFactor for the next interpolation sum */
                if ((oIdx+=iFactor) >= outLen) oIdx = 0;

                /*  Reset inIdx and filter coef pointer */
                inIdx = 0;
                cff = filter;
            }

            /* increment mIdx for the next input sample */
            if (++mIdx >= memSize) mIdx = 0;

        } /* inFrameSize */

        /*  Point sums, tap0 and outBuf to their next channel memory locations */
        sums   += iFactor;
        tap0   += memSize;
        outBuf += outLen;
    } /* channel */

    /* Update stored indices for next time */
    *tapIdx     = mIdx;
    *outIdx     = oIdx;
}

/* [EOF] */
