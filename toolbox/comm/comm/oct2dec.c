/* 
 * C-mex function. Convert octal numbers to decimal numbers.
 * Copyright 1996-2002 The MathWorks, Inc.
 * $Revision: 1.5 $  
 * $Date: 2002/03/27 00:08:55 $
 * Author: Mojdeh Shakeri
 */

#include "mex.h"
#include "comoctal.h"

/* Function: mexFunction (oct2dec.c) ===========================================
 * Abstract: Convert octal numbers to decimal numbers.
 */
void mexFunction(int nlhs,       mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{    
    char *msg = NULL;
    /* Check for proper number of arguments */
    if (nrhs != 1) {
        msg = "oct2dec requires one input argument.";
        goto EXIT_POINT;
    }

    if (nlhs > 1) {
        msg = "oct2dec requires at most one output argument.";
        goto EXIT_POINT;
    }
    if (!mxIsNumeric(prhs[0]) ||  mxIsComplex(prhs[0]) || 
        mxIsSparse(prhs[0])   || !mxIsDouble(prhs[0])  ||
        mxIsStruct(prhs[0])   ||  mxIsCell(prhs[0])    || 
        mxIsEmpty(prhs[0])) {
        msg = "oct2dec requires the input argument to be a nonempty "
              "octal matrix.";
        goto EXIT_POINT;
    }
    
    /* Check if the input is valid octal numbers */
    {
        int_T     numElms = mxGetNumberOfElements(prhs[0]);
        real_T    *pr     = mxGetPr(prhs[0]);
        int_T     i;
        boolean_T isValid = 1;
        for(i = 0; i < numElms; ++i){
            isValid = IsValidOctalNumber(pr[i]);
            if(!isValid) break;
        }
        if(!isValid){
            msg = "oct2dec requires the input argument to be a valid "
                  "octal matrix.";
            goto EXIT_POINT;
        }
    }

    /* Convert the octal numbers to decimal numbers */
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
            prOut[i] = ConvertOctaltoDecimal((int32_T)(prIn[i]));
        }
    }
 EXIT_POINT:
    if(msg != NULL){
        mexErrMsgTxt(msg);
    }
}

