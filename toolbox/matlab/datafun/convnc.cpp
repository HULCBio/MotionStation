/*

   CONVNC.CPP   .MEX file 
   Implements full N-D convolution.
   Inputs must be real, numeric, and float.

   Only one syntax is supported:
     C = CONVNC(A,B)

   Copyright 1984-2004 The MathWorks, Inc. 
*/

#include "mex.h"

static char rcsid[] = "$Revision $";

/* Input and output arguments */
#define A (prhs[0])
#define B (prhs[1])
#define C (plhs[0])

/* Increment subscripts */
/* Increment subscript vector by one element */
/* in the direction of linear indexing. */
/* The subscript vector is assumed to be zero-based. */

inline void INCREMENT_SUBSCRIPTS(int *subs, const int*size, int ndims) {
  subs[0] += 1;
  for (int p = 0; p < (ndims-1); p++) {
    if (subs[p] > (size[p]-1)) {
      subs[p] = 0;
      subs[p+1] += 1;
    }
  }
}

/* Convert a zero-based subscript vector to a linear index. */

inline void SUBSCRIPTS_TO_LINEAR(const int *subs, int ndims, const int *pdims, 
                                 int *index)
{
  int i = ndims; 
  int factor = 1; 
                  
  *index = 0; 
             
  while (i--) { 
    *index += *subs++ * factor; 
    factor *= *pdims++; 
  } 
}

template <class Tout, class Tin1, class Tin2> 
void convolve(Tout *c, const Tin1 *a, const Tin2 *b,
                     const int *sizeA, const int *sizeB, const int *sizeC,
                     int ndimsA, int ndimsB, int ndimsC)
{
  /* Input sanity checking */
  /* Any of the following error messages indicates that */
  /* something went seriously wrong in mexFunction().   */
  /* I would use utAssert() if the API had it.  -sle    */
  if (a==NULL || b==NULL || c==NULL) {
    mexErrMsgIdAndTxt("MATLAB:convnc:InternalError1",
    "Internal consistency error in convolve().");
  }
  if (sizeA==NULL || sizeB==NULL || sizeC==NULL) {
    mexErrMsgIdAndTxt("MATLAB:convnc:InternalError1",
    "Internal consistency error in convolve().");
  }
  if ((ndimsA != ndimsB) || (ndimsA != ndimsC)) {
    mexErrMsgIdAndTxt("MATLAB:convnc:InternalError1",
    "Internal consistency error in convolve().");
  } 

  /* Compute the number of elements in inputs a and b */
  int lengthA = 1;     /* length of input A */
  for (int p = 0; p < ndimsA; p++) {
    lengthA *= sizeA[p];
  }
  int lengthB = 1;     /* length of input B */
  for (int p = 0; p < ndimsB; p++) {
    lengthB *= sizeB[p];
  }

  /* Initialize subscript vectors */
  int *subsA = (int *) mxCalloc(ndimsA, sizeof(int)); /* subscript vector for A */
  int *subsB = (int *) mxCalloc(ndimsB, sizeof(int)); /* subscript vector for B */
  int *subsC = (int *) mxCalloc(ndimsC, sizeof(int)); /* subscript vector for C */
  if (subsA==NULL || subsB==NULL || subsC==NULL) {
    if (subsA != NULL) {
      mxFree(subsA);
    }
    if (subsB != NULL) {
      mxFree(subsB);
    }
    if (subsC != NULL) {
      mxFree(subsC);
    }
    mexErrMsgIdAndTxt("MATLAB:convnc:InternalError2",
    "Memory allocation failure.");
  }

  /* Initialize subscript array for a to be a(-1,0,0,...,0) */
  /* This is ok since subscripts will be incremented once before use. */
  subsA[0] = -1;
  for (int p = 1; p < ndimsA; p++) {
    subsA[p] = 0;
  }

  /* Core computation loops */
  int linearIndexC=0;  /* linear index into output array */
  for (int p = 0; p < lengthA; p++) {
    /* Increment subscript vector for A */
    INCREMENT_SUBSCRIPTS(subsA, sizeA, ndimsA);

    /* Initialize subscript array for a to be b(-1,0,0,...,0) */
    /* This is ok since subscripts will be incremented once before use. */
    subsB[0] = -1; 
    for (int r = 1; r < ndimsA; r++) {
      subsB[r] = 0;
    }
    for (int q = 0; q < lengthB; q++) {
      /* Increment subscript vector for B */
      INCREMENT_SUBSCRIPTS(subsB, sizeB, ndimsB);
      
      /* Where should the next partial product go in the output array? */
      /* Answer: subsC = subsA + subsB */
      for (int r = 0; r < ndimsA; r++) {
        subsC[r] = subsA[r] + subsB[r];
      }

      /* But we need the answer as a linear index rather than a */
      /* subscript array */
      SUBSCRIPTS_TO_LINEAR(subsC, ndimsC, sizeC, &linearIndexC);
  
      /* Accumulate partial product */
      c[linearIndexC] += a[p] * b[q];
    }
  }

  /* Clean up and go home */
  mxFree(subsA);
  mxFree(subsB);
  mxFree(subsC);
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  const int NumInputs = 2;

  /* Sanity check input */
  if (nrhs != NumInputs) mexErrMsgIdAndTxt("MATLAB:convnc:WrongNumInputs",
    "Two input arguments required.");

  bool singleA = mxIsSingle(A);
  bool singleB = mxIsSingle(B);
  
  if ((!mxIsDouble(A) && !singleA) || mxIsComplex(A) ||
      (!mxIsDouble(B) && !singleB) || mxIsComplex(B)) {
     mexErrMsgIdAndTxt("MATLAB:convnc:UnsupportedDataType",
    "Inputs must be real and float (double or single).");
  }
  
  mxClassID outputClass = (singleA || singleB ? mxSINGLE_CLASS : mxDOUBLE_CLASS);

  /* If either A or B is empty, return an empty matrix and go home. */
  if (mxIsEmpty(A) || mxIsEmpty(B)) {
    C = mxCreateNumericMatrix(0,0, outputClass, mxREAL);
    return;
  }

  int ndimsA = mxGetNumberOfDimensions(A); /* Dimensionality of first input */
  int ndimsB = mxGetNumberOfDimensions(B); /* Dimensionality of second input */
  const int *sizeA = mxGetDimensions(A);   /* Size of first input */
  const int *sizeB = mxGetDimensions(B);   /* Size of second input */

  /* Make dimensionality of A and B conform */
  int *adjustedSizeA=NULL;  /* Adjusted size of first input */
  int *adjustedSizeB=NULL;  /* Adjusted size of second input */
  int adjustedNDimsA=0;     /* Adjusted dimensionality of first input */
  int adjustedNDimsB=0;     /* Adjusted dimensionality of second input */
  if (ndimsA != ndimsB) {
    if (ndimsA > ndimsB) {
      adjustedNDimsA = ndimsA;
      adjustedNDimsB = ndimsA;
      adjustedSizeB = (int *) mxCalloc(adjustedNDimsB, sizeof(int));
      adjustedSizeA = (int *) mxCalloc(adjustedNDimsA, sizeof(int));
      if (adjustedSizeB == NULL || adjustedSizeA == NULL) {
        if (adjustedSizeB != NULL) mxFree((void *) adjustedSizeB);
        if (adjustedSizeA != NULL) mxFree((void *) adjustedSizeA);
        mexErrMsgIdAndTxt("MATLAB:convnc:InternalError2",
                          "Memory allocation failure.");
      }
      for (int p = 0; p < ndimsB; p++) {
        adjustedSizeB[p] = sizeB[p];
        adjustedSizeA[p] = sizeA[p];
      }
      for (int p = ndimsB; p < adjustedNDimsB; p++) {
        adjustedSizeB[p] = 1;
        adjustedSizeA[p] = sizeA[p];
      }
    } else {
      adjustedNDimsA = ndimsB;
      adjustedNDimsB = ndimsB;
      adjustedSizeA = (int *) mxCalloc(adjustedNDimsA, sizeof(int));
      adjustedSizeB = (int *) mxCalloc(adjustedNDimsB, sizeof(int));
      if (adjustedSizeA == NULL || adjustedSizeB == NULL) {
        if (adjustedSizeA != NULL) mxFree((void *) adjustedSizeA);
        if (adjustedSizeB != NULL) mxFree((void *) adjustedSizeB);
        mexErrMsgIdAndTxt("MATLAB:convnc:InternalError2",
                          "Memory allocation failure.");
      }
      for (int p = 0; p < ndimsA; p++) {
        adjustedSizeA[p] = sizeA[p];
        adjustedSizeB[p] = sizeB[p];
      }
      for (int p = ndimsA; p < adjustedNDimsA; p++) {
        adjustedSizeA[p] = 1;
        adjustedSizeB[p] = sizeB[p];
      }
    }
  } else {
    adjustedNDimsA = ndimsA;
    adjustedNDimsB = ndimsB;
    adjustedSizeA = (int *) mxCalloc(adjustedNDimsA, sizeof(int));
    adjustedSizeB = (int *) mxCalloc(adjustedNDimsB, sizeof(int));
    if (adjustedSizeA == NULL || adjustedSizeB == NULL) {
      if (adjustedSizeA != NULL) mxFree((void *) adjustedSizeA);
      if (adjustedSizeB != NULL) mxFree((void *) adjustedSizeB);
    mexErrMsgIdAndTxt("MATLAB:convnc:InternalError2",
                      "Memory allocation failure.");
    }
    for (int p = 0; p < adjustedNDimsA; p++) {
      adjustedSizeA[p] = sizeA[p];
      adjustedSizeB[p] = sizeB[p];
    }
  }

  /* Initialize output */
  int *sizeC = (int *) mxCalloc(adjustedNDimsA, sizeof(int));
  if (sizeC == NULL) {
    mxFree((void *) adjustedSizeA);
    mxFree((void *) adjustedSizeB);
    mexErrMsgIdAndTxt("MATLAB:convnc:InternalError2",
                      "Memory allocation failure.");
  }
  for (int p = 0; p < adjustedNDimsA; p++) {
    sizeC[p] = adjustedSizeA[p] + adjustedSizeB[p] - 1;
  }
  C = mxCreateNumericArray(adjustedNDimsA, sizeC, outputClass, mxREAL);
  if (C == NULL) {
    mxFree((void *) adjustedSizeA);
    mxFree((void *) adjustedSizeB);
    mxFree((void *) sizeC);
    mexErrMsgIdAndTxt("MATLAB:convnc:InternalError2",
                      "Memory allocation failure.");
  }

  if (singleA && singleB) {   

    real32_T *sA = (real32_T *) mxGetData(A);
    real32_T *sB = (real32_T *) mxGetData(B);
    real32_T *sC = (real32_T *) mxGetData(C);
    convolve(sC, sA, sB, 
           adjustedSizeA, adjustedSizeB, sizeC, 
           adjustedNDimsA, adjustedNDimsB, adjustedNDimsB);

  } else  if (singleA && !singleB) {

    real32_T *sA = (real32_T *) mxGetData(A);
    double   *dB = (double   *) mxGetData(B); 
    real32_T *sC = (real32_T *) mxGetData(C);
    convolve(sC, sA, dB, 
             adjustedSizeA, adjustedSizeB, sizeC, 
             adjustedNDimsA, adjustedNDimsB, adjustedNDimsB);

  } else if (!singleA && singleB) {

    double   *dA = (double   *) mxGetData(A);
    real32_T *sB = (real32_T *) mxGetData(B);
    real32_T *sC = (real32_T *) mxGetData(C);
    convolve(sC, dA, sB, 
           adjustedSizeA, adjustedSizeB, sizeC, 
           adjustedNDimsA, adjustedNDimsB, adjustedNDimsB);

  } else {    /* both inputs are double */

    double *dA = (double *) mxGetData(A);
    double *dB = (double *) mxGetData(B);   
    double *dC = (double *) mxGetData(C);
    convolve(dC, dA, dB, 
           adjustedSizeA, adjustedSizeB, sizeC, 
           adjustedNDimsA, adjustedNDimsB, adjustedNDimsB);

  }
}
