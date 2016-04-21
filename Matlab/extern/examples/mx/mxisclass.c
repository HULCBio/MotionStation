/*=================================================================
 * mxisclass.c 
 *
 * mxisclass takes no input arguments and returns no output
 * arguments. It creates an inline MATLAB object, and then gets and
 * prints the fields of this object.
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
    mxArray *output, *input;
    int number_of_fields, field_num;

    /* Check for proper number of input and output arguments */    
    if (nrhs !=0) {
	mexErrMsgTxt("No input argument required.");
    } 
    if(nlhs > 1){
	mexErrMsgTxt("Too many output arguments.");
    }
    input=mxCreateString("sin(3*x)");

    /* Use mexCallMATLAB to call the constructor and create the
       object in MATLAB */
    mexCallMATLAB(1,&output, 1, &input,"inline");
    mxDestroyArray(input);

    /* Verify that the output an inline object, if it is get 
       its fields and print them. */
    if (!mxIsClass(output, "inline")) {
	mxDestroyArray(output);
	mexErrMsgTxt("Failed to create an object of class inline"); 
    }
    number_of_fields = mxGetNumberOfFields(output);
    mexPrintf("This object contains the following fields:\n");
    mexPrintf("name\t\tclass\t\tvalue\n");
    mexPrintf("-------------------------------------\n");
    /* Get the first field name, then the second, and so on. */ 
    for (field_num=0; field_num<number_of_fields; field_num++){
	mxArray *pa;
	mexPrintf("%s", mxGetFieldNameByNumber(output, field_num));
	pa = mxGetFieldByNumber(output, 0, field_num);
	mexPrintf("\t\t%s\t\t", mxGetClassName(pa));
	mexCallMATLAB(0, NULL, 1, &pa, "disp");
    }
    mxDestroyArray(output);
}
