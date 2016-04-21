/* 
 * levdurb_ak_c_rt.c  - Signal Processing Blockset Levinson-Durbin run-time function 
 * 
 * Specifications: 
 * 
 * - Complex single precision inputs/outputs 
 * - Computes {A and K} outputs
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.3.2.3 $  $Date: 2004/04/12 23:46:39 $ 
 */ 
#include "dsp_rt.h" 

EXPORT_FCN void MWDSP_LevDurb_AK_C(
    const creal32_T *u,   /* *u   Input pointer */ 
          creal32_T *y_A, /* *y_A A output pointer */ 
          creal32_T *y_K, /* *y_K K output pointer */ 
    const int_T      N    /* N    Input array length */ 
    ) 
{ 
    real32_T E = u[0].re;  /* Only use the real part of the 1st element*/
    int_T    i; 
    for(i=1; i<N; i++) 
    {
      creal32_T k;
      real32_T overE;
      int_T   j;

      k.re = u[i].re;
      k.im = u[i].im;

      for (j=1; j<i; j++) 
      {
           /* k = y * r[reverse order] */
           k.re += CMULT_RE(u[i-j],y_A[j]);
           k.im += CMULT_IM(u[i-j],y_A[j]);
       }
   
       overE = (1.0F / E);
       k.re *= -overE;
       k.im *= -overE;
       E *= (1.0F - CMAGSQ(k));
   
       /* Update polynomial: */
       for (j=1; j<=RSL(i-1,1); j++) 
       {
           creal32_T t = y_A[j];
       
           /*
            * ynew = yold + conj(yold[reverse order]) * k 
            */
           y_A[j].re += CMULT_XCONJ_RE(y_A[i-j], k);
           y_A[j].im += CMULT_XCONJ_IM(y_A[i-j], k);
       
           y_A[i-j].re += CMULT_XCONJ_RE(t,k);
           y_A[i-j].im += CMULT_XCONJ_IM(t,k);
       }
   
       if (i%2 == 0) 
       {
           int_T     n = RSL(i,1);
           creal32_T t = y_A[n];
       
           /* To compare to the real input case:
            * y *= 1 + ki    <==>   y += k * conj(y)
            *  (Real)                (Complex)
            */
           y_A[n].re += CMULT_XCONJ_RE(t,k);
           y_A[n].im += CMULT_XCONJ_IM(t,k);
       } 
   
       /* Record reflection coefficient */
       y_A[i]   = k;
       y_K[i-1] = k;
    }
    y_A[0].re = 1.0F;
    y_A[0].im = 0.0F;
} 

/* [EOF] levdurb_ak_c_rt.c */ 
