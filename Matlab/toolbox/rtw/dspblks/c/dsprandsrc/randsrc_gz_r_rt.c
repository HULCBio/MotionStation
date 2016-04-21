/*
 *  randsrc_gz_r_rt.c
 *  DSP Random Source Run-Time Library Helper Function
 *
 *  Copyright 1995-2004 The MathWorks, Inc.
 *  $Revision: 1.4.4.3 $ $Date: 2004/04/12 23:48:32 $
 */

#include "dsprandsrc32bit_rt.h"
#include <math.h>

EXPORT_FCN void MWDSP_RandSrc_GZ_R(real32_T *outPtr,     /* output signal */ 
                        const real32_T *mean, /* vector of means */
                        int_T meanLen,        /* length of mean vector */
                        const real32_T *std,  /* vector of std deviations */
                        int_T stdLen,         /* length of std vector */
                        uint32_T *state,      /* state vectors */
                        int_T nChans,         /* number of channels */
                        int_T nSamps)         /* number of samples/channel */
{
    static const real32_T aa = 12.37586F,   b  = 0.4878992F, c = 12.67706F;
    static const real32_T c1 = 0.9689279F,  c2 = 1.301198F;
    static const real32_T pc = 0.01958303F, xn = 2.776994F;
    static const real32_T tpm32 = 2.328306436538696e-10F;
    static const real32_T tpm31 = 4.656612873077393e-10F;
    static const real32_T vt[] = {
	0.3409450F, 0.4573146F, 0.5397793F, 0.6062427F, 0.6631691F, 0.7136975F,
	0.7596125F, 0.8020356F, 0.8417227F, 0.8792102F, 0.9148948F, 0.9490791F,
	0.9820005F, 1.0138492F, 1.0447810F, 1.0749254F, 1.1043917F, 1.1332738F,
	1.1616530F, 1.1896010F, 1.2171815F, 1.2444516F, 1.2714635F, 1.2982650F,
	1.3249008F, 1.3514125F, 1.3778399F, 1.4042211F, 1.4305929F, 1.4569915F,
	1.4834527F, 1.5100122F, 1.5367061F, 1.5635712F, 1.5906454F, 1.6179680F,
	1.6455802F, 1.6735255F, 1.7018503F, 1.7306045F, 1.7598422F, 1.7896223F,
	1.8200099F, 1.8510770F, 1.8829044F, 1.9155831F, 1.9492166F, 1.9839239F,
	2.0198431F, 2.0571356F, 2.0959930F, 2.1366450F, 2.1793713F, 2.2245175F,
	2.2725186F, 2.3239338F, 2.3795008F, 2.4402218F, 2.5075117F, 2.5834658F,
	2.6713916F, 2.7769942F, 2.7769942F, 2.7769942F, 2.7769942F};


    int32_T i;
    int_T j;
    real32_T r,x,s,y;
    real32_T val;

    while (nChans--) {
        uint32_T icng = state[0];
        uint32_T jsr = state[1];
        int_T samps = nSamps;
        while (samps--) {
            icng = 69069*icng + 1234567;
            jsr ^= (jsr<<13); jsr ^= (jsr>>17); jsr ^= (jsr<<5);
            i = icng + jsr;
            j = i&0x3f;
            r = (real32_T)i*tpm31*vt[j+1];
            if (fabsf(r) <= vt[j]) {
                val = r;
            } else {
                x = (fabsf(r)-vt[j])/(vt[j+1]-vt[j]);
                icng = 69069*icng + 1234567;
                jsr ^= (jsr<<13); jsr ^= (jsr>>17); jsr ^= (jsr<<5);
                i = icng+jsr;
                y = 0.5F + i*tpm32;
                s = x + y;
                if (s > c2) {
                    val = (r < 0 ? b*x-b : b-b*x);
                } else if (s <= c1) {
                    val = r;
                } else {
                    x = b - b*x;
                    if (y > c-aa*expf(-0.5F*x*x)) {
                        val = (r < 0 ? -x : x);
                    } else if (expf(-0.5F*vt[j+1]*vt[j+1])+y*pc/vt[j+1] <= 
                               expf(-0.5F*r*r)) {
                        val = r;
                    } else {
                        do {
                            icng = 69069*icng + 1234567;
                            jsr ^= (jsr<<13); jsr ^= (jsr>>17); jsr ^= (jsr<<5);
                            i = icng+jsr;
                            x = logf(0.5F+i*tpm32)/xn;
                            icng = 69069*icng+1234567;
                            jsr ^= (jsr<<13); jsr ^= (jsr>>17); jsr ^= (jsr<<5);
                            i = icng+jsr;
                        } while (-2.0F*logf(0.5F+i*tpm32) <= x*x);
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

/* [EOF] randsrc_gz_r_rt.c */
