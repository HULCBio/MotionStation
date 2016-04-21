/* 
 * ldl_c_rt.c - Signal Processing Blockset LDL Factorization run-time function 
 * 
 * Specifications: 
 * 
 * Complex single precision inputs/outputs 
 * 
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.3.2.3 $Date: 
 */ 
#include "dsp_rt.h" 

EXPORT_FCN void MWDSP_LDL_C(
                 creal32_T  *A,    /* Output Matrix */
                 creal32_T  *V,    /* Intermediate array */
                 int_T       n,    /* Number of square matrix rows (or columns)*/ 
                 boolean_T  *state /* Boolean signaling positive definiteness */
                 )
{
    int_T      j=n;
    creal32_T *Aji;
    creal32_T *Vi;

    /* Zero out imaginary part of main diagonal */
    Aji = A; /* Use Aji as a temp */
    while( j-- >0 ) {
        Aji->im = 0.0F;
        Aji += n+1;
    }

    for(j=0; j<n; j++) {
        Aji = A+j;
        Vi = V;
        {
            creal32_T *Aii = A;
            int_T   i;

            for (i=j; i-- > 0; ) {
                Vi->re     = CMULT_XCONJ_RE(*Aji, *Aii);
                (Vi++)->im = CMULT_XCONJ_IM(*Aji, *Aii);
                Aii += n+1;
                Aji += n;
            }
        }
        {
            /* At this point, Aji points to A[j,j], vi points to v[j] */
            creal32_T *Vj  = Vi;
            Vi  = V;
            *Vj = *Aji;
            Aji = A+j;  /* Point to A[j,i] for i=1 */
            {
                real32_T Vjsum = Vj->re;
                int_T  i;
                for(i=j; i-- > 0; ) {
                    /* Diag is real, no need to compute imaginary part */
                    Vjsum -= CMULT_RE(*Aji, *Vi);
                    Vi++;
                    Aji += n;
                }

                /* Check for positive definiteness */
                if (Vjsum <= 0.0F) {
                    * state = (boolean_T)1;
                    return;  /* Return with error flag set */
             }
                Vj->re = Vjsum;
                Vj->im = 0.0F;
            }

            /* At this point, Aji points to A[j,j] */
            *Aji = *Vj;
            {
                creal32_T *Ajpki = A+j+1;
                int_T   i;
                Vi = V;
                for (i=j; i-- > 0; ) {
                    creal32_T *Ajik = Aji;  /* init to subdiagonal */
                    const creal32_T Vi_val = *Vi++;
                    int_T k;
                    for (k=n-j-1; k-- > 0; ) {
                        (++Ajik)->re -= CMULT_RE(*Ajpki, Vi_val);
                        Ajik->im     -= CMULT_IM(*Ajpki, Vi_val);
                        Ajpki++;
                    }
                    /* At this point, Ajpki points to A[1, i+1]
                     * Increment so Ajpki points to A[j+1, i+1]
                     */
                    Ajpki += j+1;
                }
            }
            {
                creal32_T Vjrecip;
                creal32_T *Ajik = Aji;
                int_T k;
                /* More efficient: */
                CRECIP32(*Vj, Vjrecip);
                for (k=n-j-1; k-- > 0; ) {
                    creal32_T Ajik_val;
                    Ajik_val = *(++Ajik);
                    Ajik->re = CMULT_RE(Ajik_val, Vjrecip);
                    Ajik->im = CMULT_IM(Ajik_val, Vjrecip);
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
                A[r*n+c].re =  A[c*n+r].re;
                A[r*n+c].im = -A[c*n+r].im; /* Hermitian transpose */
            }
        }
    }

    *state=(boolean_T) 0;
    return;
}

