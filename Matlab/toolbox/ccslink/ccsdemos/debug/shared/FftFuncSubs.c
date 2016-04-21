/*
 * Real-Time Workshop code generation for Simulink system "<Root>/FftFuncSubs"
 */

#include "FftFuncSubs_private.h"

/* Output and update for atomic system: '<Root>/FftFuncSubs' */
void DspblksFft_FftFuncSubs(const short inArr[1024], cplxShort outArr[1024])
{

  /* DSP Blockset FFT (sdspfft2) - '<S1>/FFT' */
  /* Real input, 1 channels, 1024 rows, linear output order */
  {                                     /* Bit reverse scramble and copy from input buffer to output */
    int j=0, i=0;
    for (;i<1023; i++) {
      outArr[j].re = inArr[i];
      outArr[j].im = 0;
      {
        int bit = 1024;
        do { bit>>=1; j^=bit; } while (!(j & bit));
      }
    }
    outArr[j].re = inArr[i];
    outArr[j].im = 0;
  }
  {                                     /* Decimation in time FFT */
    short accum;
    short prod;
    cplxShort ctemp, ctemp2;
    int i;
    /* Remove trivial multiplies for first stage */
    for (i=0; i<1023; i+=2) {
      /* CTEMP = y[i] - y[i+1]; */
      accum = outArr[i].re;
      accum -= outArr[i+1].re;
      accum = ASR(1,accum);
      ctemp.re = accum;
      accum = outArr[i].im;
      accum -= outArr[i+1].im;
      accum = ASR(1,accum);
      ctemp.im = accum;
      /* y[i] = y[i] + y[i+1]; */
      accum = outArr[i].re;
      accum += outArr[i+1].re;
      accum = ASR(1,accum);
      outArr[i].re = accum;
      accum = outArr[i].im;
      accum += outArr[i+1].im;
      accum = ASR(1,accum);
      outArr[i].im = accum;
      /* y[i+1] = CTEMP; */
      outArr[i+1].re = ctemp.re;
      outArr[i+1].im = ctemp.im;
    }
    {
      int idelta=2;
      int k = 256;
      while (k > 0) {
        int istart = 0;
        int i2;
        int j=k;
        int i1=istart;
        /* Remove trivial multiplies for first butterfly in remaining stages */
        for (i=0; i<k; i++) {
          i2 = i1 + idelta;
          /* CTEMP = y[0] - y[idelta]; */
          accum = outArr[i1].re;
          accum -= outArr[i2].re;
          accum = ASR(1,accum);
          ctemp.re = accum;
          accum = outArr[i1].im;
          accum -= outArr[i2].im;
          accum = ASR(1,accum);
          ctemp.im = accum;
          /* y[0] = y[0] + y[idelta]; */
          accum = outArr[i1].re;
          accum += outArr[i2].re;
          accum = ASR(1,accum);
          outArr[i1].re = accum;
          accum = outArr[i1].im;
          accum += outArr[i2].im;
          accum = ASR(1,accum);
          outArr[i1].im = accum;
          /* y[idelta] = CTEMP */
          outArr[i2].re = ctemp.re;
          outArr[i2].im = ctemp.im;
          i1 += (idelta<<1);
        }
        istart++;
        for (; j<512; j+= k) {
          int i1=istart;
          for (i=0; i<k; i++) {
            i2 = i1 + idelta;
            /* Compute ctemp = W * y[i2] */
            MUL_S16_S16_S16_SR15(prod,outArr[i2].re,(FFT_TwiddleTable[j+256]));
            accum = prod;
            MUL_S16_S16_S16_SR15(prod,outArr[i2].im,(FFT_TwiddleTable[j+512]));
            accum -= prod;
            ctemp.re = accum;
            MUL_S16_S16_S16_SR15(prod,outArr[i2].re,(FFT_TwiddleTable[j+512]));
            accum = prod;
            MUL_S16_S16_S16_SR15(prod,outArr[i2].im,(FFT_TwiddleTable[j+256]));
            accum += prod;
            ctemp.im = accum;
            /* Compute ctemp2 = y[i1] + ctemp */
            accum = outArr[i1].re;
            accum += ctemp.re;
            accum = ASR(1,accum);
            ctemp2.re = accum;
            accum = outArr[i1].im;
            accum += ctemp.im;
            accum = ASR(1,accum);
            ctemp2.im = accum;
            /* Compute y[i2] = y[i1] - ctemp */
            accum = outArr[i1].re;
            accum -= ctemp.re;
            accum = ASR(1,accum);
            outArr[i2].re = accum;
            accum = outArr[i1].im;
            accum -= ctemp.im;
            accum = ASR(1,accum);
            outArr[i2].im = accum;
            /* y[i1] = ctemp2 */
            outArr[i1].re = ctemp2.re;
            outArr[i1].im = ctemp2.im;
            i1 += (idelta<<1);
          }
          istart++;
        }
        idelta <<= 1;
        k >>= 1;
      }
    }
  }
}

