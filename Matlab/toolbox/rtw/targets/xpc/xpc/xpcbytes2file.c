/**
 * Utility function to convert a number of MATLAB arrays into a file
 * suitable for the xPC Target From File block to read. Essentially, the
 * raw data of the variables is simply concatenated together. Each column
 * of the variables represents one time step. The number of columns of each
 * variable must be the same.
 */
/* Copyright 1996-2003 The MathWorks, Inc. */
/* $Revision: $  $Date: $ */

#include "mex.h"
#include "matrix.h"

#include <stdlib.h>

char fName[201];

int getWidth(const mxArray *arr) {
    typedef struct types_tag {
        int type;
        int width;
    } TYPE;
    static TYPE types[] = {
        {mxDOUBLE_CLASS,   8},
        {mxSINGLE_CLASS,   4},
        {mxINT8_CLASS,     1},
        {mxUINT8_CLASS,    1},
        {mxINT16_CLASS,    2},
        {mxUINT16_CLASS,   2},
        {mxINT32_CLASS,    4},
        {mxUINT32_CLASS,   4},
        {mxUNKNOWN_CLASS, -1}};
    TYPE *t;
    for (t = types; t->type != mxUNKNOWN_CLASS; t++)
        if (t->type == mxGetClassID(arr))
            return t->width;
    mexErrMsgIdAndTxt("xPCTarget:invalidType", "Unknown type\n");
    return 0;
}

int   size[40];
void *data[40];

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
    FILE *fp;
    int i, j, numCols = 0;
    if (nrhs == 0) {
        mexErrMsgIdAndTxt("xPCTarget:TooFewArgs",
                          "Must specify at least one argument\n");
    }
    if (mxGetString(prhs[0], fName, 201)) {
        mexErrMsgIdAndTxt("xPCTarget:bytesToFile:badFileName",
                          "Error retrieving filename: must be a string "
                          "of length less than 200\n");
    }
    if ((fp = fopen(fName, "wb")) == NULL) {
        mexErrMsgIdAndTxt("xPCTarget:FopenError", "Error opening file\n");
    }
    nrhs--; prhs++;
    if (nrhs > 40)
        mexErrMsgTxt("xPCTarget:TooManyArgs", "At most 40 inputs allowed\n");
    for (i = 0; i < nrhs; i++) {
        if (numCols == 0) numCols = mxGetN(prhs[i]);
        if (mxGetN(prhs[i]) != numCols)
            mexErrMsgIdAndTxt("xPCTarget:bytesToFile:mismatchedSizes",
                         "All inputs must have same number of columns\n");
        size[i] = getWidth(prhs[i]) * mxGetM(prhs[i]);
        data[i] = mxGetData(prhs[i]);
    }
    for (i = 0; i < numCols; i++) {
        for (j = 0; j < nrhs; j++) {
            fwrite(data[j], size[j], 1, fp);
            (unsigned char *)data[j] += size[j];
        }
    }
    fclose(fp);
}
