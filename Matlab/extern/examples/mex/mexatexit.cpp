/*=================================================================
 * mexatexit.cpp 
 * 
 * This example is the C++ version of mexatexit.c.  It demonstrates
 * how to write strings to a data file using a C++ static class
 * contructor.  In this example, we do not need to use a mexatexit
 * function to close the data file. This is because in C++ when you
 * instantiate a static class constructor, the destructor for that
 * static class gets called automatically when the MEX-file is cleared
 * or exited.  
 *
 * The input to the MEX-file is a string.  You may continue calling
 * the function with new strings to add to the data file
 * matlab.data. The data file will not be closed until the MEX-file is
 * cleared or MATLAB is exited.

 * This is a MEX-file for MATLAB.  
 * Copyright (c) 1984-1999 The MathWorks, Inc. All Rights Reserved.
 * All rights reserved.
 *=================================================================*/

/* $Revision: 1.2 $ */

#include <stdio.h>
#include "mex.h"
#include <string.h>

/* Instantiate a static class constuctor */
class fileresource {
public:
  fileresource() { fp=fopen("matlab.data","w");}
  ~fileresource() { fclose(fp);}
  FILE *fp;
};

static fileresource file;

void 
mexFunction(int nlhs,mxArray *plhs[],int nrhs,const mxArray *prhs[])
  
{
    char *str;
    
    /* Check to be sure the file was opened correctly */
    if(file.fp == NULL){
	mexErrMsgTxt("Could not open matlab.data\n");
    }

    /* Check for proper number of input and output arguments */    
    if (nrhs != 1) {
	mexErrMsgTxt("One input argument required.");
    } 
    if (nlhs > 1){
	mexErrMsgTxt("Too many output arguments.");
    }
    
    /* Check to be sure input is of type char */
    if (!(mxIsChar(prhs[0]))){
	mexErrMsgTxt("Input must be of type string.\n.");
    }
    
    /* The user passes a string in prhs[0]; write the string
       to the data file. NOTE: you must free str after it is used */ 
    str=mxArrayToString(prhs[0]);
    if (fprintf(file.fp,"%s\n", str) != strlen(str) +1){
	mxFree(str);
   	mexErrMsgTxt("Could not write data to file.\n");
    }
    mexPrintf("Writing data to file.\n");
    mxFree(str);
    return;
}
