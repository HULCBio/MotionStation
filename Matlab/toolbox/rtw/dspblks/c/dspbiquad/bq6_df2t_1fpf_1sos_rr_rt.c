/*
 *  DSP Biquad Run-Time Library Helper Function
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.3.2.2 $  $Date: 2004/04/12 23:42:01 $
 */

#include "dsp_rt.h"

EXPORT_FCN void MWDSP_BQ6_DF2T_1fpf_1sos_RR (const real32_T *u,
                                  real32_T *y,
                                  real32_T *state,
                                  const real32_T *coeffs,
                                  const real32_T  a0inv,
                                  const int_T sampsPerChan,
                                  const int_T numChans) {
  int_T i,j;
  real32_T  out;

  for (i=0; i++ < numChans; ) {
    for (j=0; j++ < sampsPerChan; ) {
      real32_T *mem = state;
      const real32_T *c = coeffs;
      real32_T  in = *u++;             
      out = (*mem + in * *c++) * a0inv; 
      *mem = *(mem+1) + (in * *c) - out * *(c+3); 
      ++mem;
      *mem++ = in * *(c+1) - out * *(c+4); 
      *y++ = out;
    } /* Frame */
    /* Move to the state memory for the next channel */
    state += 2;
  } /* Channel */
}    

