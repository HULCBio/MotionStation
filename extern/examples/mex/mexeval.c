#include "mex.h"

/*
 * mexeval.c : Example MEX-file code emulating the functionality of the
 *             MATLAB command EVAL
 *
 *              
 * Copyright 1984-2000 The MathWorks, Inc.
 * $Revision: 1.6 $
 */

void
mexFunction( int nlhs, mxArray *plhs[],
	     int nrhs, const mxArray *prhs[] )
{
  if(nrhs==0)
    mexErrMsgTxt("Function 'mexeval' not defined for variables of class 'double'.\n");

  else if(!mxIsChar(prhs[0])) {
    const char str[]="Function 'mexeval' not defined for variables of class";
    char errMsg[100];
    
    sprintf(errMsg,"%s '%s'\n",str,mxGetClassName(prhs[0]));
    mexErrMsgTxt(errMsg);
  }
  
  else {
    /* causes MATLAB to execute the string as an expression 
     * or statement the biggest limitation is that it won't 
     * evaluate any left-hand arguments except 'ans'
     */
    char *fcn;
    int   status;
    int   buflen=mxGetN(prhs[0])+1;
    
    fcn=(char *)mxCalloc(buflen,sizeof(char));
    status=mxGetString(prhs[0],fcn,buflen);
    
    status=mexEvalString(fcn);
    
    if((nrhs==2)&&(status)) {
      /* provides the ability to catch errors.  It
       * executes string s1 and returns if the operation was
       * successful. If the operation generates an error,
       * string s2 is evaluated before returning.
       */
      char *cmd;
      int   buflen;
      
      buflen=mxGetN(prhs[1])+1;
      cmd=(char *)mxCalloc(buflen,sizeof(char));
      
      mxGetString(prhs[1],cmd,buflen);
      mexEvalString(cmd);
      
      mxFree(cmd);
    }
    
    mxFree(fcn);
  }
}
