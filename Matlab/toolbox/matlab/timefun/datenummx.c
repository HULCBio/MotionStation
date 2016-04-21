/* DATENUMMX.  MEX file used by DATENUM.
 * Four possible calling sequences:
 *    t = datenummx([y, mo, d, h, mi, s]);
 *    t = datenummx(y, mo, d, h, mi, s);
 *    t = datenummx([y, mo, d]);
 *    t = datenummx(y, mo, d);
 * where the arguments are scalars, or vectors of the same length, with
 * y = year, mo = month, d = day, h = hour, mi = minute, s = second.
 * All four return the corresponding (vector of) serial date number(s).
 */

/* Copyright 1984-2002 The MathWorks, Inc.  */
/* $Revision: 1.7.4.1 $ $Date: 2004/01/02 18:05:56 $ */

#include <math.h>
#include "mex.h"

#if !defined(MAX)
#define	MAX(A, B)	((A) > (B) ? (A) : (B))
#endif

/* Cumulative days per month in a nonleap year. */

static double cdm[] = {0,31,59,90,120,151,181,212,243,273,304,334};

void mexFunction( int nlhs, mxArray *plhs[], 
		  int nrhs, const mxArray*prhs[] )
     
{ 
    double *t,*yp,*mo,*d,*h,*mi,*s; 
    double y;
    int hms,m,n,mn,k,iy,mon,yinc,moinc,dinc,hinc,miinc,sinc; 
    const int NumOutputs = 1;

    if (nlhs > 1) mexErrMsgIdAndTxt("MATLAB:datenummx:TooManyOutputs",
                "Too many output arguments.");

    if (nrhs == 1) {

        /* Input is a date vector, or a matrix of date vector rows. */

        if (!mxIsDouble(prhs[0])) {
            mexErrMsgIdAndTxt("MATLAB:datenummx:NonDoubleInput",
            "The datenummx function only accepts double arrays.");
        } else if ((mxGetN(prhs[0]) != 3) && (mxGetN(prhs[0]) != 6)) {
            mexErrMsgIdAndTxt("MATLAB:datenummx:InvalidInputSize",
            "Single argument should have three or six columns.");
        }
        m  = mxGetM(prhs[0]);
        yp = mxGetPr(prhs[0]); 
        mo = yp + m;
        d  = yp + 2*m;
        h  = yp + 3*m;
        mi = yp + 4*m;
        s  = yp + 5*m;
        yinc = moinc = dinc = hinc = miinc = sinc = 1;
        hms = (mxGetN(prhs[0]) == 6);
        n = 1;
        mn = m;

    } else if (nrhs == 3 || nrhs == 6) {
   
        /* Input is three or six components, or column vectors. */

        m = n = 0;
        for (k = 0; k < nrhs; k++) {
           if (mxIsEmpty(prhs[k])) {
               plhs[0] = mxCreateDoubleMatrix(0, 0, mxREAL); 
               return;
           }
           if (!mxIsDouble(prhs[k])) {
               mexErrMsgIdAndTxt("MATLAB:datenummx:NonDoubleInput",
               "The datenummx function only accepts double arrays.");
           }
           m = MAX(m,mxGetM(prhs[k]));
           n = MAX(n,mxGetN(prhs[k]));
        }
        mn = m*n;
        hms = (nrhs == 6);
    
        yp = mxGetPr(prhs[0]); 
        mo = mxGetPr(prhs[1]);
        d  = mxGetPr(prhs[2]);
        yinc  = mxGetNumberOfElements(prhs[0]) == mn; 
        moinc = mxGetNumberOfElements(prhs[1]) == mn; 
        dinc  = mxGetNumberOfElements(prhs[2]) == mn; 
        if (hms) {
            h  = mxGetPr(prhs[3]); 
            mi = mxGetPr(prhs[4]);
            s  = mxGetPr(prhs[5]);
            hinc  = mxGetNumberOfElements(prhs[3]) == mn; 
            miinc = mxGetNumberOfElements(prhs[4]) == mn; 
            sinc  = mxGetNumberOfElements(prhs[5]) == mn; 
        }

    } else {
        mexErrMsgIdAndTxt("MATLAB:datenummx:InvalidNumberOfInputs",
        "Expect one, three or six input arguments.");
    }

    plhs[0] = mxCreateDoubleMatrix(m, n, mxREAL); 
    t  = mxGetPr(plhs[0]);

    for (k = 0; k < mn; k++) {
        y = *yp;
        mon = (int) *mo;
        /* Make sure month is in the range 1 to 12. */
        if (mon < 1) {
            mon = 1;
        }
        if (mon > 12) {
            y += (mon-1)/12;
            mon = ((mon-1) % 12) + 1;
        }
        *t = 365.*y + ceil(y/4.) - ceil(y/100.) + ceil(y/400.) + 
            cdm[mon-1] + *d;
        if (mon > 2) {
            iy = (int) y;
            if ((iy%4 == 0) && (iy%100 != 0) || (iy%400 == 0)) {
                *t += 1.;
            }
        }
        yp += yinc; mo += moinc; d += dinc;
        if (hms) {
           *t += (*h*3600. + *mi*60. + *s)/86400.;
           h += hinc; mi += miinc; s += sinc;
        }
        t++;
    }
}
