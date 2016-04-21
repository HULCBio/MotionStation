#include "mex.h"

/*
 * mexfeval.c : Example MEX-file code emulating the functionality of the
 *              MATLAB command FEVAL
 *
 *              
 * Copyright 1984-2000 The MathWorks, Inc.
 * $Revision: 1.8 $
 */


void
mexFunction( int nlhs, mxArray *plhs[],
	     int nrhs, const mxArray *prhs[] )
{
  if(nrhs==0)
    mexErrMsgTxt("Not enough input arguments.\n");

  if(!mxIsChar(prhs[0]))
    mexErrMsgTxt("Variable must contain a string.\n");
  
  else {
    /*
     * overloaded functions could be a problem
     */
    mxArray **in;
    
    char *fcn;
    int   buflen=mxGetN(prhs[0])+1;
    int   status, i;

    fcn=(char *)mxCalloc(buflen,sizeof(char));
    status=mxGetString(prhs[0],fcn,buflen);

    in=(mxArray **)mxCalloc(nrhs-1,sizeof(mxArray *));
    
    for(i=0;i<nrhs-1;i++) 
      in[i]=mxDuplicateArray(prhs[i+1]);

    status=mexCallMATLAB(nlhs,plhs,nrhs-1,in,fcn);
   
    mxFree(fcn);
    for(i=0;i<nrhs-1;i++) 
      mxDestroyArray(in[i]);
    mxFree(in);
    
  }
}
