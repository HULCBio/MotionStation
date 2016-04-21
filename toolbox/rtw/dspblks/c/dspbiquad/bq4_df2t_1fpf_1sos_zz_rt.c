/*
 *  DSP Biquad Run-Time Library Helper Function
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.3.2.2 $  $Date: 2004/04/12 23:41:31 $
 */

#include "dsp_rt.h"

EXPORT_FCN void MWDSP_BQ4_DF2T_1fpf_1sos_ZZ (const creal_T *u,
                                  creal_T *y,
                                  creal_T *state,
                                  const creal_T *coeffs,
                                  const int_T sampsPerChan,
                                  const int_T numChans) {
  int_T i,j;
  creal_T  out;

  for (i=0; i++ < numChans; ) {
    for (j=0; j++ < sampsPerChan; ) {
      creal_T  *mem = state;
      const creal_T  *c = coeffs;
      creal_T  in = *u++; 
      out.re      = mem->re + in.re; 
      out.im      = mem->im + in.im; 
      mem->re     = (mem+1)->re + (in.re * c->re - in.im * c->im) 
        - (out.re * (c+2)->re - out.im * (c+2)->im); 
      mem->im     = (mem+1)->im + (in.re * c->im + in.im * c->re) 
        - (out.re * (c+2)->im + out.im * (c+2)->re); 
      ++mem;
      mem->re     = (in.re * (c+1)->re - in.im * (c+1)->im) 
        - (out.re * (c+3)->re - out.im * (c+3)->im); 
      (mem++)->im = (in.re * (c+1)->im + in.im * (c+1)->re) 
        - (out.re * (c+3)->im + out.im * (c+3)->re); 
      *y++ = out;
    } /* Frame */
    /* Move to the state memory for the next channel */
    state += 2;
  } /* Channel */
}    

