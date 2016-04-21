/* Copyright 1993-2003 The MathWorks, Inc. */

/* $Revision: 1.10.4.3 $ */

/*
 * IPTREGISTRY.MEX
 *
 * Usage:
 *         IPTREGISTRY(A) stores A in persistent memory.
 *         A = IPTREGISTRY returns the value currently stored.
 *
 * Once called, IPTREGISTRY cannot be cleared by calling clear mex.
 *
 * Steven L. Eddins, September 1996
 *
 */

static char rcsid[] = "$Id: iptregistry.c,v 1.10.4.3 2003/12/13 02:48:38 batserve Exp $";

#include "mex.h"

static mxArray *Registry = NULL;

void unloadIPTRegistry(void)
{
    mxDestroyArray(Registry);
    Registry = NULL;
    /* mexUnlock();  Joshua Marshall asked me to remove this. -sle, 11/2003 */
}

void mexFunction(int nlhs, 
                 mxArray *plhs[], 
                 int nrhs, 
                 const mxArray *prhs[])
{
    if (nrhs > 1)
    {
        mexErrMsgIdAndTxt("Images:bwfillc:tooManyInputs",
                          "%s","Too many input arguments");
    }
    if (nlhs > 1)
    {
        mexErrMsgIdAndTxt("Images:bwfillc:tooManyOutputs",
                          "%s","Too many output arguments");
    }

    if (Registry == NULL)
    {
        /* First time call */
        mexAtExit(unloadIPTRegistry);
        Registry = mxCreateDoubleMatrix(0, 0, mxREAL);
        mexMakeArrayPersistent(Registry);
        mexLock();
    }
    
    if (nrhs == 1)
    {
        mxDestroyArray(Registry);
        Registry = mxDuplicateArray(prhs[0]);
        mexMakeArrayPersistent(Registry);
    }
    
    plhs[0] = mxDuplicateArray(Registry);
}
