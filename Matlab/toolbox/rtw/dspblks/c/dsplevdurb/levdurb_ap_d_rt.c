/* 
 * levdurb_ap_d_rt.c  - Signal Processing Blockset Levinson-Durbin run-time function 
 * 
 * Specifications: 
 * 
 * - Double precision inputs/outputs 
 * - Computes {A and P} outputs 
 * 
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.3.2.3 $  $Date: 2004/04/12 23:46:48 $ 
 */ 
#include "dsp_rt.h" 
 
EXPORT_FCN void MWDSP_LevDurb_AP_D(
    const real_T *u,   /* *u   Input pointer */ 
          real_T *y_A, /* *y_A A output pointer */ 
          real_T *y_P, /* *y_P P output pointer  */ 
    const int_T   N    /* N    Input array length */ 
    ) 
{ 
    real_T E = u[0];
    int_T  i; 
    for(i=1; i<N; i++)  
    { 
        int_T  j; 
        real_T ki = u[i]; 
         
        /* Update reflection coefficient: */ 
        for (j=1; j<i; j++)ki += y_A[j] * u[i-j]; 

        ki   /= -E; 
        E    *= (1 - ki*ki); 
         
        /* Update polynomial: */ 
        for (j=1; j<=RSL(i-1,1); j++)  
        { 
            real_T t  = y_A[j]; 
            y_A[j]   += ki * y_A[i-j]; 
            y_A[i-j] += ki * t; 
        } 
         
        if (i%2 == 0) y_A[RSL(i,1)] *= 1+ki; 
         
        /* Record reflection coefficient */ 
        y_A[i] = ki; 
                
    } /* end of for loop */     
    y_A[0] = 1.0; 
    *y_P = E;
} 
 
/* [EOF] levdurb_ap_d_rt.c */ 

