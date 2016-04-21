/*=================================================================
 * mxcreatestructarray.c
 *
 * mxcreatestructarray illustrates how to create a MATLAB structure
 * from a corresponding C structure.  It creates a 1-by-4 structure mxArray,
 * which contains two fields, name and phone number where name is store as a
 * string and phone number is stored as a double.  The structure that is
 * passed back to MATLAB could be used as input to the phonebook.c example
 * in $MATLAB/extern/examples/refbook.
 *
 * This is a MEX-file for MATLAB.  
 * Copyright 1984-2000 The MathWorks, Inc.
 * All rights reserved.
 *=================================================================*/

/* $Revision: 1.6 $ */
#include "mex.h"
#include <string.h>

#define NUMBER_OF_STRUCTS (sizeof(friends)/sizeof(struct phonebook))
#define NUMBER_OF_FIELDS (sizeof(field_names)/sizeof(*field_names))

struct phonebook
{
  const char *name;
  double phone;
};

void
mexFunction(int nlhs,mxArray *plhs[],int nrhs,const mxArray *prhs[])
{
    const char *field_names[] = {"name", "phone"};
    struct phonebook friends[] = {{"Jordan Robert", 3386},{"Mary Smith",3912},
				  {"Stacy Flora", 3238},{"Harry Alpert",3077}};
    int dims[2] = {1, NUMBER_OF_STRUCTS };
    int i, name_field, phone_field;
    
    /* Check for proper number of input and  output arguments */    
    if (nrhs !=0) {
        mexErrMsgTxt("No input argument required.");
    } 
    if(nlhs > 1){
        mexErrMsgTxt("Too many output arguments.");
    }
    
    /* Create a 1-by-n array of structs. */ 
    plhs[0] = mxCreateStructArray(2, dims, NUMBER_OF_FIELDS, field_names);

    /* This is redundant, but here for illustration.  Since we just
       created the structure and the field number indices are zero
       based, name_field will always be 0 and phone_field will always
       be 1 */
    name_field = mxGetFieldNumber(plhs[0],"name");
    phone_field = mxGetFieldNumber(plhs[0],"phone");

    /* Populate the name and phone fields of the phonebook structure. */ 
    for (i=0; i<NUMBER_OF_STRUCTS; i++) {
	mxArray *field_value;
	/* Use mxSetFieldByNumber instead of mxSetField for efficiency
	   mxSetField(plhs[0],i,"name",mxCreateString(friends[i].name); */
	mxSetFieldByNumber(plhs[0],i,name_field,mxCreateString(friends[i].name));
	field_value = mxCreateDoubleMatrix(1,1,mxREAL);
	*mxGetPr(field_value) = friends[i].phone;
	/* Use mxSetFieldByNumber instead of mxSetField for efficiency
	   mxSetField(plhs[0],i,"name",mxCreateString(friends[i].name); */
	mxSetFieldByNumber(plhs[0],i,phone_field,field_value);
    }
}

