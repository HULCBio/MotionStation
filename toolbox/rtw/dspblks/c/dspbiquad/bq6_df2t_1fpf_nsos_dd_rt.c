/*
 *  DSP Biquad Run-Time Library Helper Function
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.3.2.2 $  $Date: 2004/04/12 23:42:06 $
 */

#include "dsp_rt.h"

EXPORT_FCN void MWDSP_BQ6_DF2T_1fpf_Nsos_DD (const real_T *u,
                                  real_T *y,
                                  real_T *state,
                                  const real_T *coeffs,
                                  const real_T *a0invs,
                                  const int_T sampsPerChan,
                                  const int_T numChans,
                                  const int_T numSections) {
  int_T i,j;
  real_T  out;

  for (i=0; i++ < numChans; ) {
    for (j=0; j++ < sampsPerChan; ) {
      int_T sectionCounter = numSections;
      real_T *mem = state;
      const real_T *c = coeffs;
      const real_T *a0i = a0invs;
      real_T  in = *u++;             
      /* Loop through all sections
       * (guaranteed to be at least one).
       * sectionCounter is used as loop counter
       */
      do {
        out    = (*mem + in * *c++) * *a0i++; 
        *mem = *(mem+1) + (in * *c) - out * *(c+3); 
        ++mem;
        *mem++ = in * *(c+1) - out * *(c+4); 
        in = out;
        c += 5; 
      } while ((--sectionCounter) > 0);
      *y++ = out;  /* Output from final section */
    } /* Frame */
    /* Move to the state memory for the next channel */
    state += 2 * numSections;
  } /* Channel */
}    

