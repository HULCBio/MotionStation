/*
 *  DSP Biquad Run-Time Library Helper Function
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.3.2.2 $  $Date: 2004/04/12 23:41:25 $
 */

#include "dsp_rt.h"

EXPORT_FCN void MWDSP_BQ4_DF2T_1fpf_1sos_CR (const creal32_T *u,
                                  creal32_T *y,
                                  creal32_T *state,
                                  const real32_T *coeffs,
                                  const int_T sampsPerChan,
                                  const int_T numChans) {
  int_T i,j;
  creal32_T  out;

  for (i=0; i++ < numChans; ) {
    for (j=0; j++ < sampsPerChan; ) {
      creal32_T  *mem = state;
      const real32_T  *c = coeffs;
      creal32_T  in = *u++; 
      out.re      = mem->re + in.re; 
      out.im      = mem->im + in.im; 
      mem->re     = (mem+1)->re + in.re * *c - out.re * *(c+2); 
      mem->im     = (mem+1)->im + in.im * *c - out.im * *(c+2); 
      ++mem;
      mem->re     = in.re * *(c+1) - out.re * *(c+3); 
      (mem++)->im = in.im * *(c+1) - out.im * *(c+3); 
      *y++ = out;
    } /* Frame */
    /* Move to the state memory for the next channel */
    state += 2;
  } /* Channel */
}    

