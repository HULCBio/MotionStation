/*=================================================================
 * mexlock.c
 *
 * This example demonstrates how to use mexLock, mexUnlock, and 
 * mexIsLocked.
 *
 * You must call mexlock with one argument.  If you pass in a 1, it
 * will lock the MEX-file. If you pass in a -1, it will unlock the
 * MEX-file. If you pass in 0, it will report lock status.   It uses
 * mexIsLocked to check the status of the MEX-file. If the file is
 * already in the state you requested, the MEX-file errors out.
 *
 * This is a MEX-file for MATLAB.  
 * Copyright 1984-2000 The MathWorks, Inc.
 * All rights reserved.
 *=================================================================*/
/* $Revision: 1.5 $ */
#include "mex.h"

void
mexFunction(int nlhs,mxArray *plhs[],int nrhs,const mxArray *prhs[])
{
    double lock;
    
    /* Check for proper number of input and output arguments */   
    if (nrhs != 1 || !mxIsDouble(prhs[0]) ||  
	mxGetN(prhs[0])*mxGetM(prhs[0]) != 1  || mxIsComplex(prhs[0])) {
	mexErrMsgTxt("Input argument must be a real scalar double");
    }
    if(nlhs > 0){
	mexErrMsgTxt("No output arguments expected.");
    }
    lock = mxGetScalar(prhs[0]);
    if((lock != 0.0) && lock != 1.0 && lock != -1.0) {
	mexErrMsgTxt("Input argument must be either 1 to lock or -1 to\
 unlock or 0 for lock status.\n");
    }
    if(mexIsLocked()) {
	if(lock > 0.0) {
	    mexErrMsgTxt("MEX-file is already locked\n");
	}
	else if(lock < 0.0) {
	    mexUnlock();
	    mexPrintf("MEX-file is unlocked\n");
	}
	else {
	    mexPrintf("MEX-file is locked\n");
	}    
    } else {
	if(lock < 0.0) {
	    mexErrMsgTxt("MEX-file is already unlocked\n");
	}
	else if(lock > 0.0) {
	    mexLock();
	    mexPrintf("MEX-file is locked\n");
	}
	else {
	    mexPrintf("MEX-file is unlocked\n");
	}    
    }
}
