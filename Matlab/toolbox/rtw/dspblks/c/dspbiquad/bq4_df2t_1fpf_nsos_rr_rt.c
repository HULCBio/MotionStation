/*
 *  DSP Biquad Run-Time Library Helper Function
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.3.2.2 $  $Date: 2004/04/12 23:41:37 $
 */

#include "dsp_rt.h"

EXPORT_FCN void MWDSP_BQ4_DF2T_1fpf_Nsos_RR (const real32_T *u,
                                  real32_T *y,
                                  real32_T *state,
                                  const real32_T *coeffs,
                                  const int_T sampsPerChan,
                                  const int_T numChans,
                                  const int_T numSections) {
  int_T i,j;
  real32_T  out;

  for (i=0; i++ < numChans; ) {
    for (j=0; j++ < sampsPerChan; ) {
      int_T sectionCounter = numSections;
      real32_T  *mem = state;
      const real32_T  *c = coeffs;
      real32_T  in = *u++; 

      /* Loop through all sections
       * (guaranteed to be at least one).
       *
       * sectionCounter is used as loop counter
       */
      do {
        out = *mem + in; 
        *mem = *(mem+1) + (in * *c) - out * *(c+2); 
        ++mem;
        *mem++ = in * *(c+1) - out * *(c+3); 
        in = out;
        c += 4; 
      } while ((--sectionCounter) > 0);
      *y++ = out;  /* Output from final section */
    } /* Frame */
    /* Move to the state memory for the next channel */
    state += 2 * numSections;
  } /* Channel */
}    

