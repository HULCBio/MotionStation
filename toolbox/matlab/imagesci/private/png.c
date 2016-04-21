/* Copyright 1984-2001 The MathWorks, Inc.  */

/*
 * PNG.MEX
 *
 * This is a wrapper MEX-file for three MEX-like functions: WritePNG, 
 * ReadPNG, and InfoPNG.  These functions are packaged into one MEX-file
 * to avoid loading the statically linked libpng multiple times.
 *
 * varargout = png('write', ...)
 * varargout = png('read', ...)
 * varargout = png('info', ...)
 *
 */

#include <string.h>
#include "pngmex.h"
#include "mex.h"

static char rcsid[] = "$Revision: 1.1.6.1 $";

#define BUFFER_LENGTH 32
#define OPTION_STR prhs[0]

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    char buffer[BUFFER_LENGTH];
    
    if (nrhs < 1)
    {
        mexErrMsgTxt("Too few inputs.");
    }
    if (!mxIsChar(OPTION_STR))
    {
        mexErrMsgTxt("First input must an option string.");
    }

    mxGetString(OPTION_STR, buffer, BUFFER_LENGTH);
    if (strcmp(buffer, "write") == 0)
    {
        WritePNG(nlhs, plhs, nrhs, prhs);
    }
    else if (strcmp(buffer, "read") == 0)
    {
        ReadPNG(nlhs, plhs, nrhs, prhs);
    }
    else if (strcmp(buffer, "info") == 0)
    {
        InfoPNG(nlhs, plhs, nrhs, prhs);
    }
    else
    {
        mexErrMsgTxt("Unknown option.");
    }
}

