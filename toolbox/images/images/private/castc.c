/* $Revision: 1.2.4.3 $ */

/* Copyright 1993-2003 The MathWorks, Inc. */
#include "mex.h"
#include "string.h"

#define MAX(A, B)	((A) > (B) ? (A) : (B))
#define MIN(A, B)	((A) < (B) ? (A) : (B))

#define MAX_DATATYPE_SIZE 6

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {

    mxClassID in_class_ID, out_class_ID;
    int m, n;
    int out_m, out_n;
    int in_elt_size, out_elt_size;
    char out_class[MAX_DATATYPE_SIZE + 1];


    /* 
     * Error Checking. 
     */    

    if (nlhs > 1)
        mexErrMsgIdAndTxt("Images:castc:oneOutputVariableRequired",
                          "%s","This function requires one output argument.");
    if (nrhs != 2)
        mexErrMsgIdAndTxt("Images:castc:twoInputArgsRequired",
                          "%s","This function requires two input arguments.");

    if ((!mxIsNumeric(prhs[0])) || (mxIsSparse(prhs[0])))
        mexErrMsgIdAndTxt("Images:castc:firstArgMustBeFullNumArray",
                          "%s","The first input argument must"
                          " be a full numeric array.");

    m = mxGetM(prhs[0]);
    n = mxGetN(prhs[0]);

    if (((m * n) != MAX(m, n)) || (mxGetNumberOfDimensions(prhs[0]) != 2))
        mexErrMsgIdAndTxt("Images:castc:firstArgMustBeVector",
                          "%s","The first input argument must be a vector.");
    
    if (!mxIsChar(prhs[1]))
        mexErrMsgIdAndTxt("Images:castc:secondArgMustBeCharArray",
                          "%s","The second input argument"
                          " must be a character array.");


    /* 
     * Get details about input values. 
     */

    in_class_ID = mxGetClassID(prhs[0]);
    in_elt_size = mxGetElementSize(prhs[0]);


    /*
     * Create output array. 
     */


    /* Find output class and number of bytes per element. */
    mxGetString(prhs[1], out_class, (MAX_DATATYPE_SIZE + 1));

    if (strncmp(out_class, "int8", 4) == 0) {

        out_elt_size = 1;
        out_class_ID = mxINT8_CLASS;

    } else if (strncmp(out_class, "uint8",  5) == 0) {

        out_elt_size = 1;
        out_class_ID = mxUINT8_CLASS;

    } else if (strncmp(out_class, "int16",  5) == 0) {

        out_elt_size = 2;
        out_class_ID = mxINT16_CLASS;

    } else if (strncmp(out_class, "uint16", 6) == 0) {

        out_elt_size = 2;
        out_class_ID = mxUINT16_CLASS;

    } else if (strncmp(out_class, "int32",  5) == 0) {

        out_elt_size = 4;
        out_class_ID = mxINT32_CLASS;

    } else if (strncmp(out_class, "uint32", 6) == 0) {

        out_elt_size = 4;
        out_class_ID = mxUINT32_CLASS;

    } else if (strncmp(out_class, "int64",  5) == 0) {

        out_elt_size = 8;
        out_class_ID = mxINT64_CLASS;

    } else if (strncmp(out_class, "uint64", 6) == 0) {

        out_elt_size = 8;
        out_class_ID = mxUINT64_CLASS;

    } else if (strncmp(out_class, "single", 6) == 0) {

        out_elt_size = 4;
        out_class_ID = mxSINGLE_CLASS;

    } else if (strncmp(out_class, "double", 6) == 0) {

        out_elt_size = 8;
        out_class_ID = mxDOUBLE_CLASS;

    } else {

        mexErrMsgIdAndTxt("Images:castc:unsupportedClass",
                          "%s","Unsupported class.");

    }

    if (out_elt_size <= in_elt_size) {

        if ((in_elt_size % out_elt_size) != 0)
            mexErrMsgIdAndTxt("Images:castc:incompatibleSizes",
                              "%s","Incompatible sizes.");

    } else {

        if ((out_elt_size % in_elt_size) != 0)
            mexErrMsgIdAndTxt("Images:castc:incompatibleSizes",
                              "%s","Incompatible sizes.");

    }

    /* Find size of output array.  Preserve orientation. */
    if (m > n) {
        out_m = (m * in_elt_size) / out_elt_size;
        out_n = 1;
    } else {
        out_m = 1;
        out_n = (n * in_elt_size) / out_elt_size;
    }

    /* Create the output array. */
    plhs[0] = mxCreateNumericMatrix(out_m, out_n, out_class_ID, mxREAL);


    /* Populate it with the values from the old array which are implicitly
     * "cast" when they are used later in MATLAB. */
    memcpy(mxGetData(plhs[0]), mxGetData(prhs[0]),
           (out_m * out_n * out_elt_size));

}
