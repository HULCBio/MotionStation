/*=================================================================
 * mexsettrapflag.c 
 *
 * This example demonstrates how to use mexSetTrapFlag. If you call
 * this function with a 0, the trapflag is set to zero.  When
 * mexCallMATLAB fails, control goes directly to MATLAB.  If you call
 * this function with a 1, the trapflag is set to one.  When
 * mexCallMATLAB fails, control stays in the MEX-file and the MEX-file
 * causes the file to error out.
 *
 * This is a MEX-file for MATLAB.  
 * Copyright 1984-2000 The MathWorks, Inc.
 * =================================================================*/

/* $Revision: 1.9 $ */
#include "mex.h"

void
mexFunction(int nlhs,mxArray *plhs[],int nrhs,const mxArray *prhs[])
{
    int   status;
    mxArray *error_msg[1];
    char *buf;

    /* Check for proper number of input and output arguments */    
    if (nrhs !=1 || !mxIsDouble(prhs[0]) ||
	mxGetN(prhs[0])*mxGetM(prhs[0]) != 1 || mxIsComplex(prhs[0])) {
	mexErrMsgTxt("Input argument must be a real scalar double.");
    }
 
    if(nlhs > 1){
	mexErrMsgTxt("Too many output arguments.");
    }

    /* Get the input argument and use it to set mexTrapFlag */
    mexSetTrapFlag((int)mxGetScalar(prhs[0]));
	
    /* Invoke a function that does not exist */ 
    status = mexCallMATLAB(0, (mxArray **)NULL, 
			   0, (mxArray **)NULL, "nofcn");

    /* If input argument to mexsettrapflag is non-zero, control
       remains in MEX-file. */
    
    if(status==0){
      mexPrintf("???? nofcn exists ????\n");
    }
    else{

    /* Display contents of MATLAB function lasterr to see error
       issued in MATLAB */
   
    mexCallMATLAB(1,error_msg,0, (mxArray **)NULL, "lasterr"); 
    buf = mxArrayToString(error_msg[0]);
    mexPrintf("The last error message issued in MATLAB was: \n%s\n", buf);
    mxFree(buf);    
    mexErrMsgTxt("mexCallMATLAB failed.\n");
    }
}
	
	
	


     

