/* Copyright 1993-2003 The MathWorks, Inc. */

/* $Revision: 5.19.4.1 $  $Date: 2003/01/26 05:59:42 $ */

static char rcsid[] = "$Id: imhistc.c,v 5.19.4.1 2003/01/26 05:59:42 batserve Exp $";

/*
 *	imhistc.c
 *
 *	Y = IMHISTC( A, N, ISSCALED, TOP ) makes an N bin histogram of 
 *      the image matrix A.  This function is written as an auxiliary to 
 *      the M-file IMHIST.M.
 *
 *	This is a MEX file for MATLAB.
 *
 */

#include <math.h>
#include "mex.h"
#include "iptutil.h"

void ScaledHistDouble(double *a, 
                double top,
                int n, 
                int length, 
                double *y);

void HistDouble(double *a, 
                int n, 
                int length, 
                double *y);

void HistUint8(uint8_T *a, 
                int n, 
                int length, 
                double *y);

void ScaledHistUint8(uint8_T *a, 
                double top,
                int n, 
                int length, 
                double *y);

void HistUint16(uint16_T *a, 
                int n, 
                int length, 
                double *y);

void ScaledHistUint16(uint16_T *a, 
                double top,
                int n, 
                int length, 
                double *y);

void ValidateInputs(int nlhs, 
               const mxArray *prhs[], 
               int nrhs, 
               const mxArray **A, 
               int *n, 
               bool *isScaled, 
               double *top);


void ScaledHistDouble(double *a, 
                double top,
                int n, 
                int length, 
                double *y) {
    int i;
    double scale;
    double z;
    int warnNanFlag = 0;

    scale = (double) (n-1) / top;

    for (i = 0; i < length; i++) {

	if(mxIsNaN(a[i])) {
	    warnNanFlag = 1;
	    z = 0;
	}
	else {
	    z = floor(a[i] * scale + .5);
	}

        if (z < 0.0) {
            y[0]++;
        } else if (z > (n-1)) {
            y[n-1]++;
        } else {
            y[(int) z]++;
        }
    }

    if (warnNanFlag == 1)
    {
        mexWarnMsgIdAndTxt("Images:imhistc:inputHasNaNs",
			   "Converting NaN inputs to 0.");
    }

}
/**************************************************************/
/* WJ  This code is entered only when a color MAP is supplied */
/*     Normally, for doubles, ScaledHistDouble would be       */
/*     invoked instead of this routine.                       */
/**************************************************************/
void HistDouble(double *a, 
                int n, 
                int length, 
                double *y) 
{
    int i;
    int idx;
    int warnRngFlag = 0;
    int warnNanFlag = 0;

    for (i = 0; i < length; i++) {

	if(mxIsNaN(a[i])) {
	    warnNanFlag = 1;
	    idx = 0; /* Treat NaNs like zeros */
	}
	else {
	    idx = (int) a[i] - 1;
	}

        if (idx < 0) {
            warnRngFlag = 1;
            y[0]++;
        } else if (idx >= n) {
            warnRngFlag = 1;
            y[n-1]++;
        } else {
            y[idx]++;
        }
    }

    if (warnRngFlag == 1)
    {
        mexWarnMsgIdAndTxt("Images:imhistc:outOfRange",
			   "Input has out-of-range values");
    }
    else if (warnNanFlag == 1)
    {
        mexWarnMsgIdAndTxt("Images:imhistc:inputHasNaNs",
			   "Converting NaN inputs to 0.");
    }
    
}

void HistUint8(uint8_T *a, 
                int n, 
                int length, 
                double *y) {
    int i;
    int idx;
    int warnFlag = 0;

    if(n==256) {
        for (i = 0; i < length; i++) {
            y[a[i]]++;
        }
    }
    else {
        for (i = 0; i < length; i++) {
            idx = a[i];
            if (idx > (n-1)) {
                warnFlag = 1;
                y[n-1]++;
            } else {
                y[idx]++;
            }
        }
    }
    
    if (warnFlag == 1)
    {
        mexWarnMsgIdAndTxt("Images:imhistc:outOfRange",
			   "Input has out-of-range values");
    }
    
}

void ScaledHistUint8(uint8_T *a, 
                double top,
                int n, 
                int length, 
                double *y) {
    int i;
    double scale;
    int z;

    scale = (double) (n-1) / top;

    for (i = 0; i < length; i++) {
        z = (int)(a[i] * scale + 0.5);
        
	if (z > (n-1)) {
            y[n-1]++;
        } else {
            y[z]++;
        }
    }

}

void HistUint16(uint16_T *a, 
                int n, 
                int length, 
                double *y) {
    int i;
    int idx;
    int warnFlag = 0;

    if(n==65536) {
        for (i = 0; i < length; i++) {
            y[a[i]]++;
        }
    }
    else
    {
	for (i = 0; i < length; i++) {
	    idx = a[i];
	    if (idx > (n-1)) {
		warnFlag = 1;
		y[n-1]++;
	    } else {
		y[idx]++;
	    }
	}
    }

    if (warnFlag == 1)
    {
        mexWarnMsgIdAndTxt("Images:imhistc:outOfRange", 
			   "Input has out-of-range values");
    }
    
}

void ScaledHistUint16(uint16_T *a, 
                double top,
                int n, 
                int length, 
                double *y) {
    int i;
    double scale;
    int z;

    scale = (double) (n-1) / top;

    for (i = 0; i < length; i++) {
        z = (int)(a[i] * scale + 0.5);

        if (z > (n-1)) {
            y[n-1]++;
        } else {
            y[z]++;
        }
    }
}


void mexFunction(int nlhs, 
                 mxArray *plhs[], 
                 int nrhs, 
                 const mxArray *prhs[])
{
    int length;
    const mxArray *A;
    int n;
    bool isScaled;
    double top;
    double *a_real;
    uint8_T *a_int8;
    uint16_T *a_int16;
    double *y;
    mxArray *Y;

    ValidateInputs(nlhs, prhs, nrhs, &A, &n, &isScaled, &top);
    length = mxGetM(A) * mxGetN(A);

    Y = mxCreateDoubleMatrix(n, 1, mxREAL);
    y = (double *) mxGetData(Y);

    if (mxIsDouble(A)) {
        a_real = (double *) mxGetData(A);
        if (isScaled) {
            ScaledHistDouble(a_real, top, n, length, y);
        } else {
            HistDouble(a_real, n, length, y);
        }

    } else if (mxIsUint8(A)) {
        a_int8 = (uint8_T *) mxGetData(A);
        if (isScaled) {
            if ((n == 256) && (top == 255.0)) {
                HistUint8(a_int8, n, length, y);
            } else {
                ScaledHistUint8(a_int8, top, n, length, y);
            }
        } else {
            HistUint8(a_int8, n, length, y);
        }
    } else if (mxIsUint16(A)) {
        a_int16 = (uint16_T *) mxGetData(A);
        if (isScaled) {
            if ((n == 65536) && (top == 65535.0)) {
                HistUint16(a_int16, n, length, y);
            } else {
                ScaledHistUint16(a_int16, top, n, length, y);
            }
        } else {
            HistUint16(a_int16, n, length, y);
        }
    }
        
    /* Done! Give the answer back */
    plhs[0] = Y;
}


void ValidateInputs(int nlhs, 
               const mxArray *prhs[], 
               int nrhs, 
               const mxArray **A, 
               int *n, 
               bool *isScaled, 
               double *top)
{
    int i;
    int length;
    double n_real;
    double isScaled_real;

    if(nrhs != 4){
        mexErrMsgIdAndTxt("Images:imhistc:invalidNumOfInputs",
			  "Four inputs are required");
    }

    for (i = 0; i < nrhs; i++) {
        if (mxIsComplex(prhs[i])) {
            mexWarnMsgIdAndTxt("Images:imhistc:ignoreImaginaryPart",
			       "Ignoring imaginary part of complex inputs");
        }
        if (!mxIsNumeric(prhs[i])) {
            mexErrMsgIdAndTxt("Images:imhistc:mustBeNumeric",
			      "Inputs to IMHISTC must be numeric");
        }
    }

    *A = prhs[0];

    for (i = 1; i < nrhs; i++) {
        if (!mxIsDouble(prhs[i])) {
            mexErrMsgIdAndTxt("Images:imhistc:mustBeDouble",
			      "IMHISTC inputs 2, 3, and 4 must be DOUBLE");
        }
    }

    length = mxGetM(prhs[1]) * mxGetN(prhs[1]);
    if (length == 0) {
        mexErrMsgIdAndTxt("Images:imhistc:invalidSecondInput",
			  "Second input to IMHISTC must not be empty");
    } else if (length == 1) {
        n_real = *((double *) mxGetData(prhs[1]));
    } else {
        mexWarnMsgIdAndTxt("Images:imhistc:invalidSecondInput",
			   "Second input to IMHISTC should be a scalar");
        n_real = *((double *) mxGetData(prhs[1]));
    }
    *n = (int) n_real;
    if (((double) *n) != n_real) {
        mexWarnMsgIdAndTxt("Images:imhistc:invalidSecondInput",
			   "Second input to IMHISTC should be an integer");
    }
    if (*n <= 0) {
        mexErrMsgIdAndTxt("Images:imhistc:invalidSecondInput",
			  "Second input to IMHISTC should be positive");
    }

    length = mxGetM(prhs[2]) * mxGetN(prhs[2]);
    if (length == 0) {
        mexErrMsgIdAndTxt("Images:imhistc:invalidThirdInput",
			  "Third input to IMHISTC must not be empty");
    } else if (length == 1) {
        isScaled_real = *((double *) mxGetData(prhs[2]));
    } else {
        mexWarnMsgIdAndTxt("Images:imhistc:invalidThirdInput",
			   "Third input to IMHISTC should be a scalar");
        isScaled_real = *((double *) mxGetData(prhs[2]));
    }
    if (isScaled_real != 0.0) {
        *isScaled = true;
    } else {
        *isScaled = false;
    }

    length = mxGetM(prhs[3]) * mxGetN(prhs[3]);
    if (length == 0) {
        mexErrMsgIdAndTxt("Images:imhistc:invalidFourthInput",
			  "Fourth input to IMHISTC must not be empty");
    } else if (length == 1) {
        *top = *((double *) mxGetData(prhs[3]));
    } else {
        mexWarnMsgIdAndTxt("Images:imhistc:invalidFourthInput",
			   "Fourth input to IMHISTC should be a scalar");
        *top = *((double *) mxGetData(prhs[3]));
    }
    if (*top <= 0.0) {
        mexErrMsgIdAndTxt("Images:imhistc:invalidFourthInput",
			  "Fourth input to IMHISTC must be positive");
    }

}    
