/*
 * GRAYTO16 MEX-file
 *
 * B = GRAYTO16(A) converts the double array A to uint16 by scaling A by 65535
 * and then rounding.  NaN's in A are converted to 0.  Values in A greater 
 * than 1.0 are converted to 65535; values less than 0.0 are converted to 0.
 *
 * B = GRAYTO16(A) converts the uint8 array A by scaling the elements of A
 * 257 and then casting to uint8.
 *
 * Copyright 1993-2003 The MathWorks, Inc.
 *
 */

#include "mex.h"
#include "math.h"

static char rcsid[] = "$Revision: 1.9.4.3 $";

void ConvertFromDouble(double *pr, uint16_T *qr, int numElements)
{
    int k;
    double val;

    for (k = 0; k < numElements; k++)
    {
        val = *pr++;
        if (mxIsNaN(val)) {
            *qr++ = 0;
        }
        else {
            val = val * 65535.0 + 0.5;
            if (val > 65535.0) val = 65535.0;
            if (val < 0.0)   val = 0.0;
            *qr++ = (uint16_T) val;
        }
    }
}

void ConvertFromUint8(uint8_T *pr, uint16_T *qr, int numElements)
{
    int k;
    uint16_T val;

    for (k = 0; k < numElements; k++)
    {
        val = (uint16_T) *pr++;
        val = (val << 8) | val;  /* equivalent to multiplication by 257 */
        *qr++ = val;
    }
}

void ValidateInputs(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    if (nrhs < 1)
    {
        mexErrMsgIdAndTxt("Images:grayto16:tooFewInputs",
                          "%s","Too few input arguments.");
    }
    if (nrhs > 1)
    {
        mexErrMsgIdAndTxt("Images:grayto16:tooManyInputs",
                          "%s","Too many input arguments.");
    }
    if (!mxIsDouble(prhs[0]) && !mxIsUint8(prhs[0]))
    {
        mexErrMsgIdAndTxt("Images:grayto16:inputMustBeDoubleOrUin8",
                          "%s","Input must be double or uint8.");
    }
    if (mxIsComplex(prhs[0]))
    {
        mexWarnMsgIdAndTxt("Images:grayto16:ignoringImaginaryPartOfInput",
                           "%s", "Ignoring imaginary part of input.");
    }
}


void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{
    uint16_T *qr;

    ValidateInputs(nlhs, plhs, nrhs, prhs);

    plhs[0] = mxCreateNumericArray(mxGetNumberOfDimensions(prhs[0]), 
                                   mxGetDimensions(prhs[0]), 
                                   mxUINT16_CLASS, mxREAL);
    qr = (uint16_T *) mxGetData(plhs[0]);

    if (mxIsDouble(prhs[0]))
    {
        ConvertFromDouble((double *) mxGetData(prhs[0]), qr, 
                          mxGetNumberOfElements(prhs[0]));
    }
    else if (mxIsUint8(prhs[0]))
    {
        ConvertFromUint8((uint8_T *) mxGetData(prhs[0]), qr, 
                         mxGetNumberOfElements(prhs[0]));
    }
}
