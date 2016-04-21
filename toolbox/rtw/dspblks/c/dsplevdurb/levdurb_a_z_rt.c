/* 
 * levdurb_a_z_rt.c  - Signal Processing Blockset Levinson-Durbin run-time function 
 * 
 * Specifications: 
 * 
 * - Complex double precision inputs/outputs 
 * - Computes {A} output only 
 * 
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.3.2.3 $  $Date: 2004/04/12 23:46:38 $ 
 */ 
#include "dsp_rt.h" 
 
EXPORT_FCN void MWDSP_LevDurb_A_Z(
    const creal_T *u,   /* *u   Input pointer */ 
          creal_T *y_A, /* *y_A   A output pointer */ 
    const int_T    N    /* N    Input array length */ 
    ) 
{                        
    real_T E = u[0].re;  /* Only use the real part of the 1st element*/
    int_T  i;
    for(i=1; i<N; i++) 
    {
      creal_T k;
      real_T  overE;
      int_T   j;

      k.re = u[i].re;
      k.im = u[i].im;

      for (j=1; j<i; j++) 
      {
           /* k = y * r[reverse order] */
           k.re += CMULT_RE(u[i-j],y_A[j]);
           k.im += CMULT_IM(u[i-j],y_A[j]);
      }

      overE = (1.0 / E);
      k.re *= -overE;
      k.im *= -overE;
      E    *= (1 - CMAGSQ(k));
   
      /* Update polynomial: */
      for (j=1; j<=RSL(i-1,1); j++) 
      {
          creal_T t = y_A[j];
       
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
           int_T   n = RSL(i,1);
           creal_T t = y_A[n];
       
           /* To compare to the real input case:
            * y *= 1 + ki    <==>   y += k * conj(y)
            *  (Real)                (Complex)
            */
           y_A[n].re += CMULT_XCONJ_RE(t,k);
           y_A[n].im += CMULT_XCONJ_IM(t,k);
       } 
   
       /* Record reflection coefficient */
       y_A[i] = k;
    }
    y_A[0].re = 1.0;
    y_A[0].im = 0.0;
} 

/* [EOF] levdurb_a_z_rt.c */ 
