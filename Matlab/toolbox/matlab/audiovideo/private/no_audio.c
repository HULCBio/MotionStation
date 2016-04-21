/*
 *  $RCSfile: no_audio.c,v $
 *  Included when no audio is supported on specific platform.
 *
 *  Copyright 1984-2002 The MathWorks, Inc.
 *  $Revision: 1.1.6.1 $  $Date: 2003/07/11 15:53:56 $
 */

#include <math.h>
#include "mex.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    mexErrMsgTxt("Audio function is not supported on this platform.");
}

/* [EOF] no_audio.c */
