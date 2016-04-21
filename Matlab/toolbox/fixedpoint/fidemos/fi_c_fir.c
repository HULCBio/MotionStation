/*
  fi_c_fir:  Fixed-Point C implementation of an FIR filter.
 
  [Y, ZF] = fi_c_fir(B, X, ZI, accFractionLength, outFractionLength)
  filters the data in vector X with the FIR filter described by B
  using the intial conditions ZI to create the filtered data Y and
  final conditions ZF.  

  The accumulator fraction length is denoted by accFractionLength, and
  the fraction length of the output Y is denoted by outFractionLength.

  It is assumed that the accumulator word length is 32.
 
  Variables B, X, and ZI must be int16.

  Variables Y and ZF are returned as int16.


  To compile:

  Execute the following from the MATLAB command line.

    mex fi_c_fir.c


  Algorithm: 

  In the following M-code, B is a row vector, and Z is a column
  vector.  The kth output Y(k) is the inner product of B and Z,
  accumulated in full precision, then rounded-to-nearest and cast to
  int16.

    for k=1:length(X);
      Z = [X(k); Z(1:end-1)];
      Y(k) = B*Z;
    end

 
  This function is provided as a demo in the Fixed-Point Toolbox.
 
  Thomas A. Bryan, 5 April 2004
  Copyright 2004 The MathWorks, Inc.
  $Revision: 1.1.6.2 $ 

 */

#include "mex.h"

#define Y_OUT                plhs[0]
#define Z_OUT                plhs[1]

#define B_IN                 prhs[0]
#define X_IN                 prhs[1]
#define Z_IN                 prhs[2]
#define ACCFRACTIONLENGTH_IN prhs[3]
#define OUTFRACTIONLENGTH_IN prhs[4]

#define USAGE "\nUsage:  [Y, ZF] = fi_c_fir(B, X, ZI, accFractionLength, outputFractionLength)"

void fi_c_fir(int16_T *b, int16_T *x, int16_T *z, int16_T *y, 
                       int    nb, int    nx, int    nz,
            int32_T accOneHalfLSB, int accShift)
{ 
    int32_T acc;
    int k;
    int i;
    for (k=0; k<nx; k++) {
        /*
         *  z = [x(k);z(1:end-1)]; 
        */
        memmove(z+1,z,sizeof(int16_T)*nz);
        z[0] = x[k];
        /*   
         *  y(k) = b*z; 
         */
        acc = 0;
        for (i=0; i<nb; i++) {
            acc += (int32_T)b[i] * (int32_T)z[i];
        }
        /*
         *  Adding 1/2 LSB before right-shifting rounds the output to
         *  nearest.
         */
        y[k] = (acc  + accOneHalfLSB) >> accShift;
    }
}

void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{
    int nb, nx, nz;
    int accFractionLength, outFractionLength;
    int accShift;
    int16_T *y, *b, *x, *z;
    int32_T accOneHalfLSB;

    if (nrhs != 5) mexErrMsgTxt("Wrong number of input arguments." USAGE);
    if (nlhs > 2) mexErrMsgTxt("Too many output arguments." USAGE);

    if (!mxIsInt16(B_IN)) mexErrMsgTxt("B must be int16.");
    if (!mxIsInt16(X_IN)) mexErrMsgTxt("X must be int16.");
    if (!mxIsInt16(Z_IN)) mexErrMsgTxt("Z must be int16.");

    if (mxIsComplex(B_IN) || mxIsComplex(X_IN) || mxIsComplex(Z_IN) || 
        mxIsComplex(ACCFRACTIONLENGTH_IN) || mxIsComplex(OUTFRACTIONLENGTH_IN)) {
        mexErrMsgTxt("All input arguments must be real.");
    }
    nb = mxGetNumberOfElements(B_IN);
    nx = mxGetNumberOfElements(X_IN);
    nz = mxGetNumberOfElements(Z_IN);

    if (nz != nb) mexErrMsgTxt("length(ZI) must be equal to length(B).");

    b = (int16_T*)mxGetData(B_IN);
    x = (int16_T*)mxGetData(X_IN);
    z = (int16_T*)mxGetData(Z_IN);
    
    Y_OUT = mxCreateNumericArray(mxGetNumberOfDimensions(X_IN),
                                 mxGetDimensions(X_IN),
                                 mxINT16_CLASS, mxREAL);
    Z_OUT = mxDuplicateArray(Z_IN);
    
    b = (int16_T*)mxGetData(B_IN);
    x = (int16_T*)mxGetData(X_IN);
    y = (int16_T*)mxGetData(Y_OUT);
    z = (int16_T*)mxGetData(Z_OUT);

    accFractionLength = (int)mxGetScalar(ACCFRACTIONLENGTH_IN);
    outFractionLength = (int)mxGetScalar(OUTFRACTIONLENGTH_IN);

    accShift      = accFractionLength - outFractionLength;
    accOneHalfLSB = (int32_T)1 << (accShift - 1);

    fi_c_fir(b, x, z, y, nb, nx, nz, accOneHalfLSB, accShift);

}


