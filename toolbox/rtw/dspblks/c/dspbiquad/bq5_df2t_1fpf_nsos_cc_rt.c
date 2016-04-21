/*
 *  DSP Biquad Run-Time Library Helper Function
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.4.2.2 $  $Date: 2004/04/12 23:41:48 $
 */

#include "dsp_rt.h"

EXPORT_FCN void MWDSP_BQ5_DF2T_1fpf_Nsos_CC (const creal32_T *u,
                                  creal32_T *y,
                                  creal32_T *state,
                                  const creal32_T *coeffs,
                                  const int_T sampsPerChan,
                                  const int_T numChans,
                                  const int_T numSections) {
  int_T i,j;
  creal32_T  out;

  for (i=0; i++ < numChans; ) {
    for (j=0; j++ < sampsPerChan; ) {
      int_T sectionCounter = numSections;
      creal32_T  *mem = state;
      const creal32_T  *c = coeffs;
      creal32_T  in = *u++; 

      /* Loop through all sections
       * (guaranteed to be at least one).
       *
       * sectionCounter is used as loop counter
       */
      do {
        out.re      = mem->re + in.re * c->re - in.im * c->im; 
        out.im      = mem->im + in.re * c->im + in.im * c->re; 
        c++; 
        mem->re     = (mem+1)->re + (in.re * c->re - in.im * c->im) 
          - (out.re * (c+2)->re - out.im * (c+2)->im); 
        mem->im     = (mem+1)->im + (in.re * c->im + in.im * c->re) 
          - (out.re * (c+2)->im + out.im * (c+2)->re); 
        ++mem;
        mem->re     = (in.re * (c+1)->re - in.im * (c+1)->im) 
          - (out.re * (c+3)->re - out.im * (c+3)->im); 
        (mem++)->im = (in.re * (c+1)->im + in.im * (c+1)->re) 
          - (out.re * (c+3)->im + out.im * (c+3)->re); 
        in = out;
        c += 4; 
      } while ((--sectionCounter) > 0);
      *y++ = out;  /* Output from final section */
    } /* Frame */
    /* Move to the state memory for the next channel */
    state += 2 * numSections;
  } /* Channel */
}    

