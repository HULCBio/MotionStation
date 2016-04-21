/* $Revision: 1.1.6.1 $ */
/* Copyright 1984-2001 The MathWorks, Inc.  */

/*
 * PCXDRLE.MEX
 *
 * [X,IDX] = PCXDRLE(BUFFER, HEIGHT, WIDTH) decompresses the RLE-encoded
 * byte-stream contained in the uint8 vector BUFFER.  X is a uint8 array
 * containing the decompressed result.  Note that the dimensions of
 * X will be WIDTH-by-HEIGHT.  This is not a mistake; this reflects the
 * way pixels are ordered in a PCX file.  IDX is the 1-based index 
 * of the last BUFFER element processed.  The reason that all the
 * elements of BUFFER might not be processed is that BUFFER may contain
 * colormap data at the end.
 *
 * Reference:  Murray and vanRyper, Encyclopedia of Graphics File Formats,
 * 2nd ed, O'Reilly, 1996.
 */


static char rcsid[] = "$Id: pcxdrle.c,v 1.1.6.1 2003/12/13 03:00:54 batserve Exp $";

#include "mex.h"

#define CHK_IN_BUFFER \
if (nIn >= nInMax) { \
    mexWarnMsgTxt("RLE decoding failure; input appears to be truncated"); \
    nIn--; \
    break; \
}
    
#define CHK_OUT_BUFFER \
if (nOut >= nOutMax) { \
    mexWarnMsgTxt("buffer overflow in RLE decoder; input may be corrupt"); \
    break; \
}
    
void mexFunction(int nlhs, 
                 mxArray *plhs[], 
                 int nrhs, 
                 const mxArray *prhs[] )
{
    uint8_T *prIn, *prOut;
    int     nXMax, nYMax, nOutMax;
    int     nnn, nIn, nOut;
    int     nInMax;
    int     outputSize[2];
    uint8_T nCount, nValue, nByte;
    uint8_T upper2 = 192;
    uint8_T lower6 = 63;
    int k;
    
    if (nrhs < 3)
    {
        mexErrMsgTxt("Too few input arguments");
    }
    if (nrhs > 3)
    {
        mexErrMsgTxt("Too many input arguments");
    }
    
    if (!mxIsUint8(prhs[0]))
    {
        mexErrMsgTxt("First input argument must be uint8");
    }
    for (k = 1; k < nrhs; k++)
    {
        if (mxIsEmpty(prhs[k]))
        {
            mexErrMsgTxt("All inputs except the first must be nonempty");
        }
        if (!mxIsDouble(prhs[k]))
        {
            mexErrMsgTxt("All inputs except the first must be double");
        }
    }
    
    prIn = (uint8_T *) mxGetData(prhs[0]);
    nInMax = mxGetM(prhs[0]) * mxGetN(prhs[0]);
    nYMax = (int) mxGetScalar(prhs[1]);
    nXMax = (int) mxGetScalar(prhs[2]);
    nOutMax = nYMax*nXMax;
    
    outputSize[0] = nXMax;
    outputSize[1] = nYMax;
    plhs[0] = mxCreateNumericArray(2, outputSize, mxUINT8_CLASS, mxREAL);
    prOut = (uint8_T *) mxGetData(plhs[0]);
    
    nIn=0;
    nOut=0;
    while (nOut < nOutMax)
    {
        CHK_IN_BUFFER;
        nByte = prIn[nIn++];
        if ((nByte & upper2) == upper2)
        {
            nCount=nByte & lower6;
            CHK_IN_BUFFER;
            nValue=prIn[nIn++];
        } 
        else 
        {
            nCount=1;
            nValue=nByte;
        }
        for (nnn = 0; nnn < (int) nCount; nnn++)
        {
            CHK_OUT_BUFFER;
            prOut[nOut++] = nValue;
        }
        
    }
    
    if (nlhs > 1)
    {
        /* ending input buffer index (one-based) */
        plhs[1] = mxCreateDoubleScalar(nIn);
    }
    
}
