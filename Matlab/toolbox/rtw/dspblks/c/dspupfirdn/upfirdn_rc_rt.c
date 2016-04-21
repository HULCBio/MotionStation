/*
 *  upfirdn_rc_rt.c - FIR Rate Converter block runtime helper function
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.3.2.3 $  $Date: 2004/04/12 23:49:35 $
 */
#include "dsp_rt.h"

EXPORT_FCN void MWDSP_UpFIRDn_RC(   const real32_T  *u,             /* input port*/
                               creal32_T *y,             /* output port*/
                               real32_T  *tap0,          /* points to input buffer start address per channel */
                               creal32_T *sums,          /* points to output of each interp phase per channel */
                               creal32_T *outBuf,        /* points to output buffer start address per channel */
                         const creal32_T * const filter, /* FIR coeff */
                               int32_T  *tapIdx,         /* points to input buffer location to read in u */
                               int32_T  *outIdx,         /* points to output buffer data for transfer to y */
                         const int_T  numChans,        /* number of channels */
                         const int_T  inFrameSize,     /* input frame size */
                         const int_T  iFactor,         /* interpolation factor */
                         const int_T  dFactor,         /* decimation factor */
                         const int_T  subOrder,        /* order of each iFactor*dFactor polyphase subfilter */
                         const int_T  memSize,         /* input buffer size per channel */
                         const int_T  outLen,          /* output buffer size per channel */
                         const int_T  n0,              /* inputs to each interpolation phase is separated by n0 samples */
                         const int_T  n1               /* outputs of each interpolation phase is separated by n1 samples */
                         )
{
    const creal32_T *cff = filter;
    int_T  i, j, k, m, mIdx=0, oIdx=0;

    for (k=0; k < numChans; k++) {
        int_T inIdx = 0; 
        mIdx = *tapIdx;
        oIdx = *outIdx;

        for (i=0; i < inFrameSize; i++) {
            *(tap0+mIdx) = *u++;

            for (j=0; j < iFactor; j++) {
                /* The temporary variables rsum and isum are needed due to
                 * a bug in the Visual C compiler level 2 optimization */
                real32_T  rsum = sums[j].re;
                real32_T  isum = sums[j].im;
                real32_T  *tap  = tap0 + mIdx - (iFactor-j)*n0;

                m = subOrder;
                tap += dFactor;
                while (m--) {
                    tap  -= dFactor;
                    tap   = (tap>=tap0) ? tap : (tap+memSize);
                    rsum += *tap * cff->re;
                    isum += *tap * (cff++)->im;
                }
                sums[j].re = rsum;
                sums[j].im = isum;
            }

            if (++inIdx == dFactor) {
                for (j=0; j < iFactor; j++) {

                    outBuf[(j*n1+oIdx) % outLen] = sums[j];

                    *y++ = outBuf[(j+oIdx) % outLen];

                    sums[j].re = 0.0;
                    sums[j].im = 0.0;
                }

                if ((oIdx+=iFactor) >= outLen) oIdx = 0;
                inIdx = 0;
                cff   = filter;
            }

            if (++mIdx >= memSize) mIdx = 0;
        } 
        sums   += iFactor;
        tap0   += memSize;
        outBuf += outLen;
    } 
    *tapIdx     = mIdx;
    *outIdx     = oIdx;
}

/* [EOF] */
