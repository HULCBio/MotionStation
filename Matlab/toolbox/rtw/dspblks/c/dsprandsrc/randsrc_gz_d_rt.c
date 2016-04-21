/*
 *  randsrc_gz_d_rt.c
 *  DSP Random Source Run-Time Library Helper Function
 *
 *  Copyright 1995-2004 The MathWorks, Inc.
 *  $Revision: 1.3.4.3 $ $Date: 2004/04/12 23:48:31 $
 */

#include "dsprandsrc64bit_rt.h"
#include <math.h>

EXPORT_FCN void MWDSP_RandSrc_GZ_D(real64_T *outPtr,     /* output signal */ 
                        const real64_T *mean, /* vector of means */
                        int_T meanLen,        /* length of mean vector */
                        const real64_T *std,  /* vector of std deviations */
                        int_T stdLen,         /* length of std vector */
                        uint32_T *state,      /* state vectors */
                        int_T nChans,         /* number of channels */
                        int_T nSamps)         /* number of samples/channel */
{
    static const real64_T aa = 12.37586,   b = 0.4878992, c = 12.67706;
    static const real64_T c1 = 0.9689279,  c2 = 1.301198;
    static const real64_T pc = 0.01958303, xn = 2.776994;
    static const real64_T tpm31 = 4.656612873077393e-10;
    static const real64_T tpm32 = 2.328306436538696e-10;
    static const real64_T vt[] = {
	0.3409450, 0.4573146, 0.5397793, 0.6062427, 0.6631691, 0.7136975,
	0.7596125, 0.8020356, 0.8417227, 0.8792102, 0.9148948, 0.9490791,
	0.9820005, 1.0138492, 1.0447810, 1.0749254, 1.1043917, 1.1332738,
	1.1616530, 1.1896010, 1.2171815, 1.2444516, 1.2714635, 1.2982650,
	1.3249008, 1.3514125, 1.3778399, 1.4042211, 1.4305929, 1.4569915,
	1.4834527, 1.5100122, 1.5367061, 1.5635712, 1.5906454, 1.6179680,
	1.6455802, 1.6735255, 1.7018503, 1.7306045, 1.7598422, 1.7896223,
	1.8200099, 1.8510770, 1.8829044, 1.9155831, 1.9492166, 1.9839239,
	2.0198431, 2.0571356, 2.0959930, 2.1366450, 2.1793713, 2.2245175,
	2.2725186, 2.3239338, 2.3795008, 2.4402218, 2.5075117, 2.5834658,
	2.6713916, 2.7769942, 2.7769942, 2.7769942, 2.7769942};


    int32_T i;
    int_T j;
    real64_T r,x,s,y;
    real64_T val;

    while (nChans--) {
        uint32_T icng = state[0];
        uint32_T jsr = state[1];
        int_T samps = nSamps;
        while (samps--) {
            icng = 69069*icng + 1234567;
            jsr ^= (jsr<<13); jsr ^= (jsr>>17); jsr ^= (jsr<<5);
            i = icng + jsr;
            j = i&0x3f;
            r = (real64_T)i*tpm31*vt[j+1];
            if (fabs(r) <= vt[j]) {
                val = r;
            } else {
                x = (fabs(r)-vt[j])/(vt[j+1]-vt[j]);
                icng = 69069*icng + 1234567;
                jsr ^= (jsr<<13); jsr ^= (jsr>>17); jsr ^= (jsr<<5);
                i = icng+jsr;
                y = 0.5 + i*tpm32;
                s = x + y;
                if (s > c2) {
                    val = (r < 0 ? b*x-b : b-b*x);
                } else if (s <= c1) {
                    val = r;
                } else {
                    x = b - b*x;
                    if (y > c-aa*exp(-0.5*x*x)) {
                        val = (r < 0 ? -x : x);
                    } else if (exp(-0.5*vt[j+1]*vt[j+1])+y*pc/vt[j+1] <= 
                               exp(-.5*r*r)) {
                        val = r;
                    } else {
                        do {
                            icng = 69069*icng + 1234567;
                            jsr ^= (jsr<<13); jsr ^= (jsr>>17); jsr ^= (jsr<<5);
                            i = icng+jsr;
                            x = log(0.5+i*tpm32)/xn;
                            icng = 69069*icng+1234567;
                            jsr ^= (jsr<<13); jsr ^= (jsr>>17); jsr ^= (jsr<<5);
                            i = icng+jsr;
                        } while (-2.*log(0.5+i*tpm32) <= x*x);
                        val = (r < 0 ? x-xn : xn-x);
                    }
                }
            }
            *outPtr++ = *mean + (*std * val);
        }
        *state++ = icng;
        *state++ = jsr;
        /* advance mean, std */
        if (meanLen > 1) mean++;
        if (stdLen > 1) std++;
    }
}
