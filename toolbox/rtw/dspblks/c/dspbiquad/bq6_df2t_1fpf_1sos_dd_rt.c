/*
 *  DSP Biquad Run-Time Library Helper Function
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.3.2.2 $  $Date: 2004/04/12 23:41:58 $
 */

#include "dsp_rt.h"

EXPORT_FCN void MWDSP_BQ6_DF2T_1fpf_1sos_DD (const real_T *u,
                                  real_T *y,
                                  real_T *state,
                                  const real_T *coeffs,
                                  const real_T  a0inv,
                                  const int_T sampsPerChan,
                                  const int_T numChans) {
  int_T i,j;
  real_T  out;

  for (i=0; i++ < numChans; ) {
    for (j=0; j++ < sampsPerChan; ) {
      real_T *mem = state;
      const real_T *c = coeffs;
      real_T  in = *u++;             
      out    = (*mem + in * *c++) * a0inv; 
      *mem = *(mem+1) + (in * *c) - out * *(c+3); 
      ++mem;
      *mem++ = in * *(c+1) - out * *(c+4); 
      *y++ = out;
    } /* Frame */
    /* Move to the state memory for the next channel */
    state += 2;
  } /* Channel */
}    

