/* $Revision: 1.1.6.1 $ */
/* Copyright 1984-2001 The MathWorks, Inc.  */

/*
 * B = BITSLICE(A, STARTBIT, ENDBIT)
 *
 * "slice" bits out the values in A, shifting them down.  STARTBIT is LSB,
 * ENDBIT is MSB.  For example, bitslice(uint8(255),5,8) is 15, and 
 * bitslice(uint8(128),7,8) is 2.
 *
 * A must be a uint8 or uint16 array, and STARTBIT and ENDBIT must be double.
 *
 * B is an array that is the same size and data type as A.
 *
 */

static char rcsid[] = "$Id: bitslice.c,v 1.1.6.1 2003/12/13 02:58:41 batserve Exp $";

#include <math.h>
#include "mex.h"

void slicebits16(const mxArray *A,int startBit,int endBit,mxArray **B);
void slicebits8(const mxArray *A,int startBit,int endBit,mxArray **B);

/*
 * ValidateInput --- input argument checking
 *
 * Inputs:   nlhs     --- number of left-side arguments
 *           nrhs     --- number of right-side arguments
 *           prhs     --- array of right-side arguments
 *
 * Outputs:  startBit --- least-significant bit of the slice
 *           endBit   --- most-significant bit of the slice
 *
 * Return:   none
 */
void ValidateInput(int nlhs, int nrhs, const mxArray *prhs[],
                    int *startBit, int *endBit)
{
    int i;

    if (nrhs > 3)
    {
        mexErrMsgTxt("Too many input arguments");
    }
    if (nrhs < 3)
    {
        mexErrMsgTxt("Too few input arguments");
    }
    if (nlhs > 1)
    {
        mexErrMsgTxt("Too many output arguments");
    }

    /* first arg must be uint8 or uint16, others must be double */
    if (!mxIsUint8(prhs[0]) && !mxIsUint16(prhs[0]))
    {
        mexErrMsgTxt("First input must be uint8 or uint16");
    }
    if (!mxIsDouble(prhs[1]))
    {
        mexErrMsgTxt("Second input must be double");
    }
    if (!mxIsDouble(prhs[2]))
    {
        mexErrMsgTxt("Third input must be double");
    }

    for (i = 0; i < nrhs; i++) 
    {
        if (mxIsComplex(prhs[0]))
        {
            mexWarnMsgTxt("Ignoring imaginary part of input");
        }
    }

    if ((mxGetM(prhs[1]) * mxGetN(prhs[1])) > 1)
    {
        mexWarnMsgTxt("Second input should be a scalar");
    }

    if ((mxGetM(prhs[2]) * mxGetN(prhs[2])) > 1)
    {
        mexWarnMsgTxt("Third input should be a scalar");
    }

    *startBit = (int) floor(mxGetScalar(prhs[1]));
    *endBit = (int) floor(mxGetScalar(prhs[2]));

    if (mxGetClassID(prhs[0])==mxUINT8_CLASS)
        {
            
            if ((*startBit < 1) || (*startBit > 8) ||
                (*endBit < 1) || (*endBit > 8))
                {
                    mexErrMsgTxt("STARTBIT and ENDBIT should be integers "
                                 "1 and 8");
                }
        }
    else if (mxGetClassID(prhs[0])==mxUINT16_CLASS)
        {
            
            if ((*startBit < 1) || (*startBit > 16) ||
                (*endBit < 1) || (*endBit > 16))
                {
                    mexErrMsgTxt("STARTBIT and ENDBIT should be integers "
                                 "1 and 16");
                }
        }
    
    if (*endBit < *startBit)
    {
        mexErrMsgTxt("ENDBIT must be greater than STARTBIT");
    }
}



void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
    int startBit, endBit;
    const mxArray *A;
    mxArray *B;

    ValidateInput(nlhs, nrhs, prhs, &startBit, &endBit);

    A = prhs[0];

    switch(mxGetClassID(prhs[0]))
           {
             case mxUINT8_CLASS:
                 {
                     slicebits8(A,startBit,endBit,&B);
                     break;
                 }
             case mxUINT16_CLASS:
                 {
                     slicebits16(A,startBit,endBit,&B);
                     break;
                 }
           }
             
    plhs[0] = B;
}

void slicebits8(const mxArray *A,int startBit,int endBit,mxArray **B)
{

    int length;
    int shift;
    int i;
    uint8_T mask;
    uint8_T *prA;
    uint8_T *prB;
    
    
    *B = mxCreateNumericArray(mxGetNumberOfDimensions(A),
                             mxGetDimensions(A),
                             mxUINT8_CLASS,
                             mxREAL);
                     
    prA = (uint8_T *) mxGetData(A);
    prB = (uint8_T *) mxGetData(*B);
 
    mask = 0;
    for (i = startBit; i <= endBit; i++)
        {
            mask += 1 << (i-1);
        }
    shift = startBit - 1;

    length = mxGetM(A) * mxGetN(A);
    
    for (i = 0; i < length; i++)
        {
            *prB = (*prA & mask) >> shift;
            prB++;
            prA++;
        }

}


void slicebits16(const mxArray *A,int startBit,int endBit,mxArray **B)
{

    int length;
    int i;
    int shift;
    uint16_T mask;
    uint16_T *prA;
    uint16_T *prB;
    
    
    *B = mxCreateNumericArray(mxGetNumberOfDimensions(A),
                             mxGetDimensions(A),
                             mxUINT16_CLASS,
                             mxREAL);
                     
    prA = (uint16_T *) mxGetData(A);
    prB = (uint16_T *) mxGetData(*B);
 
    mask = 0;
    for (i = startBit; i <= endBit; i++)
        {
            mask += 1 << (i-1);
        }
    shift = startBit - 1;

    length = mxGetM(A) * mxGetN(A);
    
    for (i = 0; i < length; i++)
        {
            *prB = (*prA & mask) >> shift;
            prB++;
            prA++;
        }
}

