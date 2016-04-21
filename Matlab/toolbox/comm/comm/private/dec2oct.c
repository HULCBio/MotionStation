/*
 * C-mex function. Convert decimal numbers to octal numbers.
 * Copyright 1996-2002 The MathWorks, Inc.
 * $Revision: 1.5 $  
 * $Date: 2002/03/27 00:14:15 $
 * Author: Mojdeh Shakeri
 */

#include "mex.h"
#include "comoctal.h"

/* Function: mexFunction (dec2oct.c) ===========================================
 * Abstract: Convert decimal numbers to octal numbers.
 */
void mexFunction(int nlhs,       mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{    
    char *msg = NULL;
    /* Check for proper number of arguments */  
    if (nrhs != 1) {
        msg = "dec2oct requires one input argument.";
        goto  EXIT_POINT;
    }

    if (nlhs > 1) {
        msg = "dec2oct requires at most one output argument.";
        goto EXIT_POINT;
    }
    if (!mxIsNumeric(prhs[0]) ||  mxIsComplex(prhs[0]) || 
        mxIsSparse(prhs[0])   || !mxIsDouble(prhs[0])  ||
        mxIsStruct(prhs[0])   ||  mxIsCell(prhs[0])    || 
        mxIsEmpty(prhs[0]) ) {
        msg = "dec2oct requires the input argument to be a nonempty "
              "noncomplex decimal matrix.";
        goto EXIT_POINT;
    }

    /* Check if the input is valid integer numbers */
    {
        int_T     numElms = mxGetNumberOfElements(prhs[0]);
        real_T    *pr     = mxGetPr(prhs[0]);
        int_T     i;
        boolean_T isValid = 1;
        for(i = 0; i < numElms; ++i){
            isValid = (pr[i] >= 0);
            if(!isValid) break;

            isValid = (pr[i] - (real_T)((int32_T)(pr[i]))) == 0;
            if(!isValid) break;
        }
        if(!isValid){
            msg = "dec2oct requires a nonnegative decimal input argument.";
            goto EXIT_POINT;
        }
    }
    
    /* Convert decimal numbers to octal numbers */
    {
        int_T   m       = mxGetM(prhs[0]);
        int_T   n       = mxGetN(prhs[0]);
        int_T   numElms = m * n;
        real_T  *prIn   = mxGetPr(prhs[0]);
        real_T  *prOut;   
        int_T   i;
        
        plhs[0] = mxCreateDoubleMatrix(m, n, mxREAL);
        prOut   = mxGetPr(plhs[0]);
        
        for(i = 0; i < numElms; ++i){
            prOut[i] = ConvertDecimaltoOctal((int32_T)(prIn[i]));
        }
    }

EXIT_POINT:
    if(msg != NULL){
        mexErrMsgTxt(msg);
    }
}
