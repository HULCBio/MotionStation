/* 
 * C-mex function to check if the input is a valid octal vector.
 * Copyright 1996-2002 The MathWorks, Inc.
 * $Revision: 1.5 $  
 * $Date: 2002/03/27 00:14:27 $
 * Author: Mojdeh Shakeri
 */

#include "mex.h"
#include "comoctal.h"

/* Function: mexFunction (isoctal) =============================================
 * Abstract: Return 1 if the input is a valid octal vector, otherwise, return 0.
 */
void mexFunction(int nlhs,       mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{    
    char *msg = NULL;
    /* Check for proper number of arguments */  
    if (nrhs != 1) {
        msg = "isoctal requires one input argument.";
        goto EXIT_POINT;
    }

    if (nlhs > 1) {
        msg = "isoctal requires at most one output argument.";
        goto EXIT_POINT;
    }

    if (!mxIsNumeric(prhs[0]) ||  mxIsComplex(prhs[0]) || 
        mxIsSparse(prhs[0])   || !mxIsDouble(prhs[0])  ||
        mxIsStruct(prhs[0])   ||  mxIsCell(prhs[0])    || 
        mxIsEmpty(prhs[0])) {
        /* Invalid octal number */
        plhs[0] = mxCreateScalarDouble(0);
    } else {
        /* Check for valid octal numbers */
        int_T     numElms = mxGetNumberOfElements(prhs[0]);
        real_T    *pr     = mxGetPr(prhs[0]);
        boolean_T isValid = 1;
        int_T     i;
        
        for(i = 0; i < numElms; ++i){
            isValid = IsValidOctalNumber(pr[i]);
            if(!isValid) break;
        }
        plhs[0] = mxCreateScalarDouble(isValid);
    }

 EXIT_POINT:
    if(msg != NULL){
        mexErrMsgTxt(msg);
    }
}


