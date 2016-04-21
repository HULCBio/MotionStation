/* Copyright 1993-2003 The MathWorks, Inc. */

/* $Revision: 1.13.4.3 $  $Date: 2003/08/01 18:11:24 $ */

/*
 * 
 * RADONC.C .MEX file
 * Implements Radon transform.
 *
 * Syntax  [P, r] = radon(I, theta)
 *
 * evaluates the Radon transform P, of I along the angles
 * specified by the vector THETA.  THETA values measure 
 * angle counter-clockwise from the horizontal axis.  
 * THETA defaults to [0:179] if not specified.
 *
 * The output argument r is a vector giving the
 * values of r corresponding to the rows of P.
 *
 * The origin of I is computed in the same way as origins
 * are computed in filter2:  the origin is the image center
 * rounded to the upper left.
 *
 * Algorithm
 * The Radon transform of a point-mass is known, and the Radon
 * transform is linear (although not shift-invariant).  So
 * we use superposition of the Radon transforms of each
 * image pixel.  The dispersion of each pixel (point mass)
 * along the r-axis is a nonlinear function of theta and the
 * pixel location, so to improve the accuracy, we divide
 * each pixel into 4 submasses located to the NE, NW, SE, 
 * and SW of the original location.  Spacing of the submasses
 * is 0.5 in the x- and y-directions.  We also smooth 
 * the result in the r-direction by a triangular smoothing 
 * window of length 2.
 * 
 * Reference
 * Ronald N. Bracewell, Two-Dimensional Imaging, Prentice-Hall,
 * 1995, pp. 518-525.
 *
 * S. Eddins 1-95
 */

#include <math.h>
#include "mex.h"

static void radon(double *pPtr, double *iPtr, double *thetaPtr, int M, int N, 
		  int xOrigin, int yOrigin, int numAngles, int rFirst, 
		  int rSize);

static char rcs_id[] = "$Revision: 1.13.4.3 $";

#define MAXX(x,y) ((x) > (y) ? (x) : (y))

/* Input Arguments */
#define I      (prhs[0])
#define THETA  (prhs[1])
#define OPTION (prhs[2])

/* Output Arguments */
#define	P      (plhs[0])
#define R      (plhs[1])

void 
mexFunction(int nlhs, mxArray  *plhs[], int nrhs, const mxArray  *prhs[])
{
    int numAngles;          /* number of theta values */
    double *thetaPtr;       /* pointer to theta values in radians */
    double *pr1, *pr2;      /* double pointers used in loop */
    double deg2rad;         /* conversion factor */
    double temp;            /* temporary theta-value holder */
    int k;                  /* loop counter */
    int M, N;               /* input image size */
    int xOrigin, yOrigin;   /* center of image */
    int temp1, temp2;       /* used in output size computation */
    int rFirst, rLast;      /* r-values for first and last row of output */
    int rSize;              /* number of rows in output */
  
    /* Check validity of arguments */
    if (nrhs < 2) 
    {
        mexErrMsgIdAndTxt("Images:radonc:tooFewInputs",
                          "Too few input arguments");
    }
    if (nrhs > 2)
    {
        mexErrMsgIdAndTxt("Images:radonc:tooManyInputs",
                          "Too many input arguments");
    }
    if (nlhs > 2)
    {
        mexErrMsgIdAndTxt("Images:radonc:tooManyOutputs",
                          "Too many output arguments to RADON");
    }

    if (mxIsSparse(I) || mxIsSparse(THETA))
    {
        mexErrMsgIdAndTxt("Images:radonc:inputsMustBeNonsparse",
                          "Sparse inputs not supported");
    }

    if (!mxIsDouble(I) || !mxIsDouble(THETA))
    {
        mexErrMsgIdAndTxt("Images:radonc:inputsIAndThetaMustBeDouble",
                          "I and THETA must be double");
    }
    
    /* Get THETA values */
    deg2rad = 3.14159265358979 / 180.0;
    numAngles = mxGetM(THETA) * mxGetN(THETA);
    thetaPtr = (double *) mxCalloc(numAngles, sizeof(double));
    pr1 = mxGetPr(THETA);
    pr2 = thetaPtr;
    for (k = 0; k < numAngles; k++)
        *(pr2++) = *(pr1++) * deg2rad;
  
    M = mxGetM(I);
    N = mxGetN(I);

    /* Where is the coordinate system's origin? */
    xOrigin = MAXX(0, (N-1)/2);
    yOrigin = MAXX(0, (M-1)/2);

    /* How big will the output be? */
    temp1 = M - 1 - yOrigin;
    temp2 = N - 1 - xOrigin;
    rLast = (int) ceil(sqrt((double) (temp1*temp1+temp2*temp2))) + 1;
    rFirst = -rLast;
    rSize = rLast - rFirst + 1;

    if (nlhs == 2) {
        R = mxCreateDoubleMatrix(rSize, 1, mxREAL);
        pr1 = mxGetPr(R);
        for (k = rFirst; k <= rLast; k++)
            *(pr1++) = (double) k;
    }

    /* Invoke main computation routines */
    if (mxIsComplex(I)) {
        P = mxCreateDoubleMatrix(rSize, numAngles, mxCOMPLEX);
        radon(mxGetPr(P), mxGetPr(I), thetaPtr, M, N, xOrigin, yOrigin, 
              numAngles, rFirst, rSize); 
        radon(mxGetPi(P), mxGetPi(I), thetaPtr, M, N, xOrigin, yOrigin, 
              numAngles, rFirst, rSize);
    } else {
        P = mxCreateDoubleMatrix(rSize, numAngles, mxREAL);
        radon(mxGetPr(P), mxGetPr(I), thetaPtr, M, N, xOrigin, yOrigin, 
              numAngles, rFirst, rSize);
    }
}

void incrementRadon(double *pr, double pixel, double r)
{
    int r1;
    double delta;

    r1 = (int) r;
    delta = r - r1;
    pr[r1] += pixel * (1.0 - delta);
    pr[r1+1] += pixel * delta;
}

static void 
radon(double *pPtr, double *iPtr, double *thetaPtr, int M, int N, 
      int xOrigin, int yOrigin, int numAngles, int rFirst, int rSize)
{
    int k, m, n;              /* loop counters */
    double angle;             /* radian angle value */
    double cosine, sine;      /* cosine and sine of current angle */
    double *pr;               /* points inside output array */
    double *pixelPtr;         /* points inside input array */
    double pixel;             /* current pixel value */
    double *ySinTable, *xCosTable;
    /* tables for x*cos(angle) and y*sin(angle) */
    double x,y;
    double r, delta;
    int r1;

    /* Allocate space for the lookup tables */
    xCosTable = (double *) mxCalloc(2*N, sizeof(double));
    ySinTable = (double *) mxCalloc(2*M, sizeof(double));

    for (k = 0; k < numAngles; k++) {
        angle = thetaPtr[k];
        pr = pPtr + k*rSize;  /* pointer to the top of the output column */
        cosine = cos(angle); 
        sine = sin(angle);   

        /* Radon impulse response locus:  R = X*cos(angle) + Y*sin(angle) */
        /* Fill the X*cos table and the Y*sin table.                      */
        /* x- and y-coordinates are offset from pixel locations by 0.25 */
        /* spaced by intervals of 0.5. */
        for (n = 0; n < N; n++)
        {
            x = n - xOrigin;
            xCosTable[2*n]   = (x - 0.25)*cosine;
            xCosTable[2*n+1] = (x + 0.25)*cosine;
        }
        for (m = 0; m < M; m++)
        {
            y = yOrigin - m;
            ySinTable[2*m] = (y - 0.25)*sine;
            ySinTable[2*m+1] = (y + 0.25)*sine;
        }

        pixelPtr = iPtr;
        for (n = 0; n < N; n++)
        {
            for (m = 0; m < M; m++)
            {
                pixel = *pixelPtr++;
                if (pixel != 0.0)
                {
                    pixel *= 0.25;

                    r = xCosTable[2*n] + ySinTable[2*m] - rFirst;
                    incrementRadon(pr, pixel, r);

                    r = xCosTable[2*n+1] + ySinTable[2*m] - rFirst;
                    incrementRadon(pr, pixel, r);

                    r = xCosTable[2*n] + ySinTable[2*m+1] - rFirst;
                    incrementRadon(pr, pixel, r);

                    r = xCosTable[2*n+1] + ySinTable[2*m+1] - rFirst;
                    incrementRadon(pr, pixel, r);
                }
            }
        }
    }
                
    mxFree((void *) xCosTable);
    mxFree((void *) ySinTable);
}

	
