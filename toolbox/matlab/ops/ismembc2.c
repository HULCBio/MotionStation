/*
 * ISMEMBC.MEX
 *
 * Helper function for ISMEMBER.M.
 *
 * This MEX-file handles the work for the ISMEMBER(A,S) syntax.
 * ISMEMBER must make sure that S has been converted to
 * double and sorted by real part before calling this function.
 * A must be a numeric or char array.
 *
 * MATLAB Usage:  B = ISMEMBC(A,S)
 *
 * Copyright 1984-2001 The MathWorks, Inc. 
 * $Revision: 1.1.4.1 $  $Date: 2003/12/26 18:08:57 $
 */

static char rcsid[] = "$Id: ismembc2.c,v 1.1.4.1 2003/12/26 18:08:57 batserve Exp $";

#include "mex.h"

void ValidateInputs(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[],
                    const mxArray **A, const mxArray **S)
{
    const int NumInputs = 2;
    const int NumOutputs = 1;

    if (nrhs > NumInputs) mexErrMsgIdAndTxt("MATLAB:ismembc2:TooManyInputs",
	"Too many input arguments.");  

    if (nrhs < NumInputs) mexErrMsgIdAndTxt("MATLAB:ismembc2:TooFewInputs",
	"Too few input arguments.");

    if (nlhs > NumOutputs) mexErrMsgIdAndTxt("MATLAB:ismembc2:TooManyOutputs",
	"Too many output arguments.");
    
    *A = prhs[0];
    if (!(mxIsNumeric(*A) || mxIsChar(*A)))
    {
       mexErrMsgIdAndTxt("MATLAB:ismembc2:InvalidA",
       "A must be a numeric or char array.");
    }
    
    *S = prhs[1];
    if (!mxIsDouble(*S))
    {
        mexErrMsgIdAndTxt("MATLAB:ismembc2:InvalidS",
        "The set S must be a double array sorted by real part.");
    }
}

/*
 * Where is the value (realPart + i*imagPart) found in the list of values in the
 * real-part and imaginary-part arrays prSet and piSet?
 */
double IsInSet(double realPart, double imagPart, double *prSet, double *piSet, int numelSet)
{
    double found = 0.0;
    int lower;
    int upper;
    int midpoint;
    int k;

    if (numelSet > 0)
    {
        if ((realPart >= prSet[0]) && (realPart <= prSet[numelSet-1]))
        {
            /* Initialize bounds */
            lower = 0;
            upper = numelSet - 1;
            while ((upper - lower) > 1)
            {
                /* Find middle of the current region */
                midpoint = (lower + upper) >> 1;
                
                /* 
                 * How we shrink the region depends on whether realPart is in
                 * the upper half or the lower half.
                 */
                if (realPart >= prSet[midpoint])
                {
                    lower = midpoint;
                }
                else
                {
                    upper = midpoint;
                }
            }
            
            /*
             * There may be more than one value in the Set that has the same real part,
             * so we have to loop over values in the Set until we've reached a Set
             * value whose real part is higher than realPart.
             */
            k = upper;
            while ((k >= 0) && (prSet[k] >= realPart))
            {
                if (realPart == prSet[k])
                {
                    if (piSet != NULL)
                    {
                        /* 
                         * The set is complex, so we have to check the imaginary
                         * part explicitly.
                         */
                        if (imagPart == piSet[k])
                        {
                            found = k+1;
                            break;
                        }
                    }
                    else
                    {
                        /*
                         * The set is real, so we just have to check see if imagPart is 0.
                         */
                        if (imagPart == 0.0)
                        {
                            found = k+1;
                            break;
                        }
                    }
                }
                k--;
            }
        }
    }
    

    return(found);
}

/*
 * Return as a double the value of the input array at the given
 * linear offset index.  The input array can be a char or any numeric
 * class, so its class has to be passed in as an input parameter.
 * If the input array is NULL, return 0.
 */
double GetDoubleValue(void *p, mxClassID classID, int index)
{
    double result = 0.0;

    if (p != NULL)
    {
        switch (classID)
        {
        case mxDOUBLE_CLASS:
            result = *( ((double *) p) + index);
            break;
            
        case mxSINGLE_CLASS:
            result = (double) *( ((float *) p) + index);
            break;
            
        case mxINT32_CLASS:
            result = (double) *( ((int32_T *) p) + index);
            break;
            
        case mxUINT32_CLASS:
            result = (double) *( ((uint32_T *) p) + index);
            break;
            
        case mxINT16_CLASS:
            result = (double) *( ((int16_T *) p) + index);
            break;
            
        case mxUINT16_CLASS:
            result = (double) *( ((uint16_T *) p) + index);
            break;
            
        case mxINT8_CLASS:
            result = (double) *( ((int8_T *) p) + index);
            break;
            
        case mxUINT8_CLASS:
            result = (double) *( ((uint8_T *) p) + index);
            break;
            
        case mxCHAR_CLASS:
            result = (double) *( ((mxChar *) p) + index);
            break;
            
        default:
            mexErrMsgIdAndTxt("MATLAB:ismembc2:InvalidInput","Invalid input.");
            break;
        }
    }
    
    return(result);
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    int numDimsA;
    const int *dimsA;
    int numelA;
    int numelS;
    int k;
    mxArray *B = NULL;
    const mxArray *A = NULL;
    const mxArray *S = NULL;
    double realPart;
    double imagPart;
    double *prS;
    double *piS;
    double *prB;
    void *prA;
    void *piA;
    mxClassID classA;
    
    ValidateInputs(nlhs, plhs, nrhs, prhs, &A, &S);

    numDimsA = mxGetNumberOfDimensions(A);
    dimsA = mxGetDimensions(A);

    B = mxCreateNumericArray(numDimsA, dimsA, mxDOUBLE_CLASS, mxREAL);
    prS = (double *) mxGetData(S);
    piS = (double *) mxGetImagData(S);
    numelS = mxGetNumberOfElements(S);
    numelA = mxGetNumberOfElements(A);
    prB = (double *) mxGetData(B);
    prA = mxGetData(A);
    piA = mxGetImagData(A);
    classA = mxGetClassID(A);
    
    for (k = 0; k < numelA; k++)
    {
        realPart = GetDoubleValue(prA, classA, k);
        imagPart = GetDoubleValue(piA, classA, k);
        prB[k] = IsInSet(realPart, imagPart, prS, piS, numelS);
    }
        
    plhs[0] = B;
}
