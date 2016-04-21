/* $Revision: 1.10 $ */
/*=================================================================
 * revord.c 
 * example for illustrating how to copy the string data from MATLAB
 * to a C-style string and back again
 *
 * takes a row vector string and returns a string in reverse order.
 *
 * This is a MEX-file for MATLAB.
 * Copyright 1984-2000 The MathWorks, Inc.
 *=============================================================*/
#include "mex.h"

void revord(char *input_buf, int buflen, char *output_buf)
{
  int   i;

  /* reverse the order of the input string */
  for(i=0;i<buflen-1;i++) 
    *(output_buf+i) = *(input_buf+buflen-i-2);
}

void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{
    char *input_buf, *output_buf;
    int   buflen,status;
    
    /* check for proper number of arguments */
    if(nrhs!=1) 
      mexErrMsgTxt("One input required.");
    else if(nlhs > 1) 
      mexErrMsgTxt("Too many output arguments.");

    /* input must be a string */
    if ( mxIsChar(prhs[0]) != 1)
      mexErrMsgTxt("Input must be a string.");

    /* input must be a row vector */
    if (mxGetM(prhs[0])!=1)
      mexErrMsgTxt("Input must be a row vector.");
    
    /* get the length of the input string */
    buflen = (mxGetM(prhs[0]) * mxGetN(prhs[0])) + 1;

    /* allocate memory for input and output strings */
    input_buf=mxCalloc(buflen, sizeof(char));
    output_buf=mxCalloc(buflen, sizeof(char));

    /* copy the string data from prhs[0] into a C string input_ buf.
     * If the string array contains several rows, they are copied,
     * one column at a time, into one long string array.
     */
    status = mxGetString(prhs[0], input_buf, buflen);
    if(status != 0) 
      mexWarnMsgTxt("Not enough space. String is truncated.");
    
    /* call the C subroutine */
    revord(input_buf, buflen, output_buf);

    /* set C-style string output_buf to MATLAB mexFunction output*/
    plhs[0] = mxCreateString(output_buf);
    return;
}

