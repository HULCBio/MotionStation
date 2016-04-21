/* 
 * ldl_d_rt.c - Signal Processing Blockset LDL Factorization run-time function 
 * 
 * Specifications: 
 * 
 * Real double precision inputs/outputs 
 * 
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.3.2.3 $Date: 
 */
#include "dsp_rt.h" 

EXPORT_FCN void MWDSP_LDL_D(
                 real_T    *A,     /* Output Matrix */
                 real_T    *V,     /* Intermediate array */
                 int_T      n,     /* Number of square matrix rows (or columns)*/
                 boolean_T *state  /* Boolean signaling positive definiteness */
                 )
{
    int_T j;
    for(j=0; j<n; j++) {
        real_T *Aji = A+j;
        real_T *Vi = V;
        {
            real_T *Aii = A;
            int_T   i;
            for (i=j; i-- > 0; ) {
                *Vi++ = *Aji * *Aii;  /* conj(Aji) */
                Aii += n+1;
                Aji += n;
            }
        }
        {
            /* At this point, Aji points to A[j,j], vi points to v[j] */
            real_T *Vj  = Vi;
            Vi  = V;
            *Vj = *Aji;
            Aji = A+j;  /* Point to A[j,i] for i=1 */
            {
                real_T Vjsum = *Vj;
                int_T  i;
                for(i=j; i-- > 0; ) {
                    Vjsum -= *Aji * *Vi++;
                    Aji += n;
                }
                if (Vjsum <= 0.0) {
                    * state = (boolean_T) 1;
                    return;  /* Return with error flag set */
                }
                *Vj = Vjsum;
            }

            /* At this point, Aji points to A[j,j] */
            *Aji = *Vj;
            {
                real_T *Ajpki = A+j+1;
                int_T   i;
                Vi = V;
                for (i=j; i-- > 0; ) {
                    real_T *Ajik = Aji;  /* init to subdiagonal */
                    const real_T Vi_val = *Vi++;
                    int_T k;
                    for (k=n-j-1; k-- > 0; ) {
                        *(++Ajik) -= *Ajpki++ * Vi_val;
                    }
                    /* At this point, Ajpki points to A[1, i+1]
                     * Increment so Ajpki points to A[j+1, i+1]
                     */
                    Ajpki += j+1;
                }
            }
            {
                real_T *Ajik = Aji;
                int_T k;
                /* More efficient: */
                const real_T Vjrecip = 1.0 / *Vj;
                for (k=n-j-1; k-- > 0; ) {
                    *(++Ajik) *= Vjrecip;
                }
            }
        }
    } /* j loop */

    /* Transpose and copy upper subtriang to lower */
    {
        int_T c;
        for (c=0; c<n; c++) {
            int_T r;
            for (r=c; r<n; r++) {
                A[r*n+c] = A[c*n+r];
            }
        }
    }
    *state = (boolean_T) 0;
    return;
}


