/*
 * MWGUIDGEN  MEX-file
 *
 * Generate a Microsoft globally unique ID (GUID).
 *
 * GUID = MWGUIDGEN generates a 16-element UINT8 array containing the 128
 * bits of the GUID.
 *
 * GUIDs are only generated on Windows platforms.
 */

/*
 * Copyright 1993-2003 The MathWorks, Inc.
 * $Revision: 1.4.4.2 $  $Date $
 */

#include "mex.h"

/* The value _MSC_VER is defined by MSVC on all Windows platforms. */
#ifdef _MSC_VER

/* On Windows machines, generate a GUID. */

#include "windows.h"

void mexFunction(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[])
{
    HRESULT hr = S_OK;
    void* pData;
    
    /* Check arguments */
    if (nlhs > 1)
        mexErrMsgIdAndTxt("Images:mwguidgen:tooManyOutputs",
                          "Too many output arguments");
    
    /* Allocate array for GUID */
    plhs[0] = mxCreateNumericMatrix(1, sizeof(GUID), mxUINT8_CLASS, 0);
    if (plhs[0] == NULL)
        mexErrMsgIdAndTxt("Images:mwguidgen:outOfMemory",
                          "GUID generation failed: memory allocation error");
    
    pData = mxGetData(plhs[0]);

    /*Generate new GUID */
    hr = CoCreateGuid((GUID*)pData);
    if (FAILED(hr))
        mexErrMsgIdAndTxt("Images:mwguidgen:systemError",
                          "GUID generation failed: system error");

}

#else

/* GUID creation doesn't exist for non-Windows platforms. */

void mexFunction(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[])
{
    mexErrMsgIdAndTxt("Images:mwguidgen:unsupportedPlatform",
                      "GUID creation is not supported on this platform");
}

#endif  /* WIN32 */
