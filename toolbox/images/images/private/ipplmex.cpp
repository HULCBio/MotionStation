/*
 * IPPLMEX.CPP
 *
 * [A B] = IPPLMEX()
 * A is logical and it is true if IPPL is present and functioning 
 * properly, otherwise it is set to false.  B is a cell array
 * of strings describing each of the IPPL libraries used by the
 * Image Processing Toolbox.
 *
 * $Revision: 1.1.6.1 $
 * Copyright 1993-2003 The MathWorks, Inc. All Rights Reserved.
 */

static char rcsid[] = "$Id: ipplmex.cpp,v 1.1.6.1 2003/05/03 17:52:06 batserve Exp $";

#include "mex.h"
#include "mwippl.h"

extern "C"
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    MwIppl mwIppl;  //Instantiate the class for handling IPPL

    bool status = true;

    mxArray *B = NULL;
    if (nlhs > 1) //If return variable B is requested
    {
        int ndims = 2; int dims[2] = {(int)ippEnd-1, 1};
        B = mxCreateCellArray(ndims, dims);
    }

    for(int i = ippStart+1; i < ippEnd; i++)
    {
        mxArray *mxInfo = NULL;

        bool isPresent = mwIppl.getLibraryInfo((libindex_T)i, &mxInfo);
        if(!isPresent)
            status = false;

        if (B)
            mxSetCell(B,i-1,mxInfo);
        else
            mxDestroyArray(mxInfo); //free up the info array
    }

    mxArray *A = mxCreateLogicalScalar(status);

    if(nlhs == 1)
    {
        plhs[0] = A;
    }
    else
    {
        plhs[0] = A;
        plhs[1] = B;
    }
}

