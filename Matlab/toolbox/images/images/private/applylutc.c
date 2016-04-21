/* Copyright 1993-2003 The MathWorks, Inc.  */

/*

   applylutc.c  .MEX file
               Applies a 16-by-1 lookup table to 2-by-2 sliding
               neighborhoods in a binary image; or applies a
               512-by-1 lookup table to 3-by-3 sliding neighborhoods
               in a binary image.

               For 2-by-2 neighborhoods, the neighborhood examined
               for each pixel is the lower right one, and lookup
               indices are determined by applying this mask:

                        1 4
                        2 8

               For 3-by-3 neighborhoods, the lookup indices are
               determined by applying this mask:

                        1  8  64
                        2 16 128
                        4 32 256

               A = APPLYLUTC(BW, LUT)

               BW can be either numeric or logical.  BW must be real, 
               two-dimensional, and nonsparse.

               LUT can be either numeric or logical.  LUT must be a real 
               vector. 

               BW and LUT and be either numeric double or numeric
               uint8.  BW and LUT must be real.

               Case 1: LUT is uint8
                 Output will be uint8

               Case 2: LUT is double
                 If all LUT values are integers between 0 and 255,
                 output will be uint8; otherwise output will be
                 double.           

               If output contains only 0's and 1's, it will be logical.

               Steven L. Eddins
               March 1996

*/

static char rcsid[] = "$Revision: 1.1.6.1 $";

#include <math.h>
#include "mex.h"

#define MATRIX_REF(PR, NUMROWS, R, C) \
   (*((PR) + (NUMROWS)*(C) + (R)))

static int16_T weights2[2][2] = {1, 4, 2, 8};

int16_T Nhood2Offset(mxLogical *pBWin, int numRows, int numCols, 
                     int r, int c) {

    int maxR, maxC;
    int rr, cc;
    int16_T result = 0;

    /* Figure out the neighborhood extent that does not go past */
    /* image boundaries */
    if (r == (numRows-1)) {
        maxR = 0;
    } else {
        maxR = 1;
    }
    if (c == (numCols-1)) {
        maxC = 0;
    } else {
        maxC = 1;
    }

    for (rr = 0; rr <= maxR; rr++) {
        for (cc = 0; cc <= maxC; cc++) {
            result += weights2[rr][cc] *
              (MATRIX_REF(pBWin, numRows, r+rr, c+cc) != 0);
        }
    }

    return(result);
}

static int16_T weights3[3][3] = {1, 8, 64, 2, 16, 128, 4, 32, 256};

int16_T Nhood3Offset(mxLogical *pBWin, int numRows, int numCols,
                     int r, int c) {

    int minR, maxR, minC, maxC;
    int rr, cc;
    int16_T result = 0;
    
    /* Figure out the neighborhood extent that does not go past */
    /* image boundaries */
    if (r == 0) {
        minR = 1;
    } else {
        minR = 0;
    }
    if (r == (numRows-1)) {
        maxR = 1;
    } else {
        maxR = 2;
    }
    if (c == 0) {
        minC = 1;
    } else {
        minC = 0;
    }
    if (c == (numCols-1)) {
        maxC = 1;
    } else {
        maxC = 2;
    }

    for (rr = minR; rr <= maxR; rr++) {
        for (cc = minC; cc <= maxC; cc++) {
            result += weights3[rr][cc] * 
              (MATRIX_REF(pBWin, numRows, r + rr - 1, c + cc - 1) != 0);
        }
    }

    return(result);
}

void Compute2by2DoubleResult(mxArray *BWout, 
                             mxArray *BWin, 
                             mxArray *lut) {
    
    int numRows, numCols;
    int r, c;
    mxLogical *pBWin;
    double *plut;
    double *pBWout;

    pBWin = mxGetLogicals(BWin);
    plut = (double *) mxGetData(lut);
    pBWout = (double *) mxGetData(BWout);

    numRows = mxGetM(BWin);
    numCols = mxGetN(BWin);

    for (c = 0; c < numCols; c++) {
        for (r = 0; r < numRows; r++) {
            MATRIX_REF(pBWout, numRows, r, c) =
              *(plut + Nhood2Offset(pBWin, numRows, numCols, r, c));
        }
    }
}


void Compute3by3DoubleResult(mxArray *BWout, 
                             mxArray *BWin, 
                             mxArray *lut) {
    
    int numRows, numCols;
    int r, c;
    mxLogical *pBWin;
    double *plut;
    double *pBWout;

    pBWin = mxGetLogicals(BWin);
    plut = (double *) mxGetData(lut);
    pBWout = (double *) mxGetData(BWout);

    numRows = mxGetM(BWin);
    numCols = mxGetN(BWin);

    for (c = 0; c < numCols; c++) {
        for (r = 0; r < numRows; r++) {
            MATRIX_REF(pBWout, numRows, r, c) =
              *(plut + Nhood3Offset(pBWin, numRows, numCols, r, c));
        }
    }
}

void Compute2by2Uint8Result(mxArray *BWout, 
                            mxArray *BWin, 
                            mxArray *lut) {
    
    int numRows, numCols;
    int r, c;
    mxLogical *pBWin;
    double *plut;
    uint8_T *pBWout;

    pBWin = mxGetLogicals(BWin);
    plut = (double *) mxGetData(lut);
    pBWout = (uint8_T *) mxGetData(BWout);

    numRows = mxGetM(BWin);
    numCols = mxGetN(BWin);

    for (c = 0; c < numCols; c++) {
        for (r = 0; r < numRows; r++) {
            MATRIX_REF(pBWout, numRows, r, c) = (uint8_T)
              *(plut + Nhood2Offset(pBWin, numRows, numCols, r, c));
        }
    }
}

void Compute3by3Uint8Result(mxArray *BWout, 
                            mxArray *BWin, 
                            mxArray *lut) {
    
    int numRows, numCols;
    int r, c;
    mxLogical *pBWin;
    double *plut;
    uint8_T *pBWout;

    pBWin = mxGetLogicals(BWin);
    plut = (double *) mxGetData(lut);
    pBWout = (uint8_T *) mxGetData(BWout);

    numRows = mxGetM(BWin);
    numCols = mxGetN(BWin);

    for (c = 0; c < numCols; c++) {
        for (r = 0; r < numRows; r++) {
            MATRIX_REF(pBWout, numRows, r, c) = (uint8_T)
              *(plut + Nhood3Offset(pBWin, numRows, numCols, r, c));
        }
    }
}

void Compute2by2LogicalResult(mxArray *BWout, 
                              mxArray *BWin, 
                              mxArray *lut) {
    
    int numRows, numCols;
    int r, c;
    mxLogical *pBWin;
    double *plut;
    mxLogical *pBWout;

    pBWin = mxGetLogicals(BWin);
    plut = (double *) mxGetData(lut);
    pBWout = mxGetLogicals(BWout);

    numRows = mxGetM(BWin);
    numCols = mxGetN(BWin);

    for (c = 0; c < numCols; c++) {
        for (r = 0; r < numRows; r++) {
            MATRIX_REF(pBWout, numRows, r, c) = (mxLogical)
              *(plut + Nhood2Offset(pBWin, numRows, numCols, r, c));
        }
    }
}

void Compute3by3LogicalResult(mxArray *BWout, 
                              mxArray *BWin, 
                              mxArray *lut) {
    
    int numRows, numCols;
    int r, c;
    mxLogical *pBWin;
    double *plut;
    mxLogical *pBWout;

    pBWin = mxGetLogicals(BWin);
    plut = (double *) mxGetData(lut);
    pBWout = mxGetLogicals(BWout);

    numRows = mxGetM(BWin);
    numCols = mxGetN(BWin);

    for (c = 0; c < numCols; c++) {
        for (r = 0; r < numRows; r++) {
            MATRIX_REF(pBWout, numRows, r, c) = (mxLogical)
              *(plut + Nhood3Offset(pBWin, numRows, numCols, r, c));
        }
    }
}

#define BW_IN  (prhs[0])
#define LUT_IN (prhs[1])

/* In addition to validating the inputs, this function */
/* converts the input BW array to uint8 and the input LUT */
/* array to double if necessary. */
void ValidateInputs(int nlhs, int nrhs, const mxArray *prhs[],
                    mxArray **BW, bool *freeBW, mxArray **lut, 
                    bool *freelut, mxClassID *outputClass, 
                    int *nhoodSize) {

    int i;
    double *plut;   /* pointer to lut array */
    bool outputCanBeLogical;

    if (nrhs != 2)
    {
        mexErrMsgIdAndTxt("Images:applylutc:invalidNumInputs",
                          "%s",
                          "APPLYLUTC needs two input arguments.");
    }

    /*
     * assign BW
     */
    *BW = (mxArray *) BW_IN;
    *freeBW = false;


    /*
     * assign lut
     */
    *lut = (mxArray *) LUT_IN;
    *freelut = false;

    /*
     * What should the output class be?
     * Start by assuming it will be uint8.
     */
    *outputClass = mxUINT8_CLASS;

    /*
     * Now check to see if it must be double.
     */
    if (mxIsDouble(LUT_IN)) {
        plut = (double *) mxGetData(LUT_IN);
        for (i = 0; i < mxGetNumberOfElements(LUT_IN); i++) {
            if (!mxIsFinite(*plut) || (*plut != floor(*plut)) ||
                (*plut < 0.0) || (*plut > 255.0)) {
                *outputClass = mxDOUBLE_CLASS;
                 break;
            }
            plut++;
        }
    }

    /*
     * Now check to see if it can be logical.
     */
    outputCanBeLogical = true;
    plut = (double *) mxGetData(*lut);
    for (i = 0; i < mxGetNumberOfElements(LUT_IN); i++) {
        if ((*plut != 0.0) && (*plut != 1.0)) {
            outputCanBeLogical = false;
            break;
        }
        plut++;
    }
    if (outputCanBeLogical)
    {
        *outputClass = mxLOGICAL_CLASS;
    }

    switch (mxGetNumberOfElements(*lut))
    {
    case 16:
        *nhoodSize = 2;
        break;
        
    case 512:
        *nhoodSize = 3;
        break;
        
    default:
        mexErrMsgIdAndTxt("Images:applylut:invalidLUTLength", "%s", 
                          "Expected LUT (argument 2) to have 16 or 512 elements.");
    }

}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    mxClassID outputClass;      /* output array class */
    bool freeBW;                /* Free BW at the end? */
    bool freelut;               /* Free lut at the end? */
    mxArray *BW;                /* Input image */
    mxArray *lut;               /* Input lookup table */
    mxArray *BW2;               /* Output image */
    int nhoodSize;              /* Neighborhood size; 2 or 3 */

    /* ValidateInputs always returns a logical BW and a double lut */
    ValidateInputs(nlhs, nrhs, prhs, &BW, &freeBW, &lut, &freelut, 
                   &outputClass, &nhoodSize);

    if (outputClass == mxLOGICAL_CLASS) {
	BW2 = mxCreateLogicalArray(mxGetNumberOfDimensions(BW),
                                   mxGetDimensions(BW));
    } else {
	BW2 = mxCreateNumericArray(mxGetNumberOfDimensions(BW),
                                   mxGetDimensions(BW), outputClass, mxREAL);
    }
    
    if (! mxIsEmpty(BW2)) {
        /* Output is not empty, so we actually have to do some work. */

        if (nhoodSize == 2) {
            if (outputClass == mxDOUBLE_CLASS) {
                Compute2by2DoubleResult(BW2, BW, lut);
            } else if (outputClass == mxLOGICAL_CLASS) {
                Compute2by2LogicalResult(BW2, BW, lut);
            } else {
                Compute2by2Uint8Result(BW2, BW, lut);
            }
        } else {
            if (outputClass == mxDOUBLE_CLASS) {
                Compute3by3DoubleResult(BW2, BW, lut);
            } else if (outputClass == mxLOGICAL_CLASS) {
                Compute3by3LogicalResult(BW2, BW, lut);
            } else {
                Compute3by3Uint8Result(BW2, BW, lut);
            }
        }

    }

    /* If we made it this far, all is OK.  Might as well let the */
    /* left-hand side have it. */

    plhs[0] = BW2;

    if (freeBW) {
        mxDestroyArray(BW);
    }
    if (freelut) {
        mxDestroyArray(lut);
    }
}



