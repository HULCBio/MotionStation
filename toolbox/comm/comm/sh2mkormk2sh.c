/*
 * Syntax:  C = sh2mkormk2sh(gen, var)
 *
 * gen is the generator polynomial in descending powers. 
 * var is the shift parameter when specified as a scalar. In that case C is 
 * the binary vector corresponding to the mask in descending powers. If Var 
 * is specified as a binary vector, then it corresponds to the mask and C is
 * the scalar shift evaluated. 
 *
 * Assumptions made: 
 *    gen is a binary vector.
 *    var is a scalar or a binary vector.
 *
 * NOTE: This C-mex function is called by the shift2mask (sh2mk) and mask2shift
 * (mk2sh) functions. No error checking is done for the parameters passed in 
 * here as that is done in the m-file wrapper functions.
 *   
 *  Copyright 1996-2002 The MathWorks, Inc.
 *  $Revision: 1.1 $  $Date: 2002/01/14 22:40:24 $
 */
 
#ifdef MATLAB_MEX_FILE
#include "mex.h"
#endif

#include <math.h>
#include "tmwtypes.h"
 
void mexFunction(int_T nlhs, mxArray *plhs[], int_T nrhs, const mxArray *prhs[])
{
    int_T   mgen, ngen, mvar, nvar, len_gen, len_var, i, N, *fvec;
    double  *gen, *var;
    
    /* Get input arguments */
    gen  = mxGetPr(prhs[0]);
    mgen = mxGetM(prhs[0]);
    ngen = mxGetN(prhs[0]);
    len_gen = mgen * ngen;
    N = len_gen - 1; /* degree of polynomial */
        
    var  = mxGetPr(prhs[1]);
    mvar = mxGetM(prhs[1]);
    nvar = mxGetN(prhs[1]);
    len_var = mvar * nvar;

    /* Field element in polynomial notation */
	fvec = (int_T *)mxCalloc(len_gen, sizeof(int_T)); 
    
    /* Algorithms */
    if (len_var > 1) /* mask is specified, evaluate shift */ 
    {   /* MASK2SHIFT */
        int_T temp, *temp_elem;
        double k, q;

        /* Setup output */    
        real_T *shift = mxGetPr(plhs[0] = mxCreateDoubleMatrix(1, 1, mxREAL));

        q = pow(2,N);        
    	temp_elem  = (int_T *)mxCalloc(N, sizeof(int_T));
	
        /* Search thru single [001000] elements */
        temp = 0;
        for (i = 0; i < N; i++){
            if (var[i] == 1){
                temp++;
                k = i;
            }
        }
        if (temp == 1){
            shift[0] = N - k - 1;
        } else 
        {   /* Search thru other elements */            
            temp_elem[0] = 1;  /* rest are zeros, corresponds to 2^(N-1)                             
            /* Start loop for all other elements */  
            for(k = N+1; k < q; k++)
            {   /* Left shift */
                for(i = 0; i < N; i++)
                    fvec[i] = temp_elem[i];
                fvec[N] = 0;
                /* XOR */
                if (fvec[0] > 0)
                {
                    for (i = 1; i < len_gen; i++)
                        fvec[i] = (fvec[i] + (int_T)gen[i]) % 2;
                }
                /* Set the field element */                               
                for (i = 1; i < len_gen; i++)
                    temp_elem[i-1] = fvec[i]; 
                /* Compare */                               
                temp = 0;
                for (i = 0; i < N; i++)
                {
                    if ( var[i] == temp_elem[i] )
                        temp++;
                }
                if (temp == N)
                {
                    shift[0] = k - 1;
                    break;
                }
            } /* end k for loop */
        } /* end else for other elements */

    } else /* shift is specified, evaluate mask */ 
    {   /* SHIFT2MASK */
        double *mask, j;
        
        if (*var > N-1)
        { 
            fvec[0] = 1; /* rest are zeros, corresponds to 2^N */

            for (j = 0; j < *var-N+1; j++)
            {   /* XOR */
                if (fvec[0] > 0)
                {
                    for (i = 0; i < len_gen; i++)
                        fvec[i] = (fvec[i] + (int_T)gen[i]) % 2;
                }
                /* Left shift */
                for (i = 0; i < N; i++)
                    fvec[i] = fvec[i+1];
                fvec[N] = 0;
            }
            /* Right shift */
            for (i = N; i > 0 ; i--)
                fvec[i] = fvec[i-1];
        } else 
        { /* direct single [001000] element lookup */
            i = (int_T) *var;
            fvec[N-i] = 1;
        }
        /* Assign output */
        mask = mxGetPr(plhs[0] = mxCreateDoubleMatrix(1, N, mxREAL));                 
        for (i = 0; i < N; i++)
            mask[i] = fvec[i+1];

    } /* end else shift is specified evaluate mask */       
    return;
}

/* [EOF] */
