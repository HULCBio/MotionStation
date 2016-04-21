/* DATEVECMX.  MEX file used by DATEVEC.
 * Possible calling sequences:
 *    c               = datevecmx(t,{rf})
 *    [y,mo,d]        = datevecmx(t,{rf})
 *    [y,mo,d,h,mi,s] = datevecmx(t,{rf})
 * where t is a serial date number, or a vector of date numbers, and
 * y = year, mo = month, d = day, h = hour, mi = minute, s = second.
 * The optional second input argument, rf, is a flag indicating that
 * seconds should be rounded to an integer value.  All other output
 * components are always integers.
 */

/* Copyright 1984-2002 The MathWorks, Inc.  */
/* $Revision: 1.5.4.1 $ $Date: 2004/01/02 18:05:58 $ */

#include <math.h>
#include "mex.h"

/* Cumulative days per month in both nonleap and leap years. */

static double cdm0[] = {0,31,59,90,120,151,181,212,243,273,304,334,365};
static double cdml[] = {0,31,60,91,121,152,182,213,244,274,305,335,366};

void mexFunction( int nlhs, mxArray *plhs[], 
		  int nrhs, const mxArray*prhs[] )
{ 
    int m,n,mn,k,leap,iy,mon,hms,rf;
    double *cdm,*tp,*yp,*mo,*d,*h,*mi,*s; 
    double t,ts,y,tmax = 1.2884901888e+11;  /* tmax = 30*2^32 */
    
    const int MaxNumInputs = 2;
    const int MinNumInputs = 1;

    if (nrhs > MaxNumInputs) mexErrMsgIdAndTxt("MATLAB:datevecmx:TooManyInputs",
    "Too many input arguments.");
    if (nrhs < MinNumInputs) mexErrMsgIdAndTxt("MATLAB:datevecmx:TooFewInputs",
    "Not enough input arguments.");

    for (k = 0; k < nrhs; k++) {
    if (!mxIsDouble(prhs[k])) mexErrMsgIdAndTxt("MATLAB:datevecmx:NonDoubleInput",
         "The datevecmx function only accepts double arrays.");
    }

    m = mxGetM(prhs[0]);
    n = mxGetN(prhs[0]);
    mn = m*n;
    tp = mxGetPr(prhs[0]);
    rf = ((nrhs > 1) && (*mxGetPr(prhs[1]) == 1.));    /* Round flag */

    if (nlhs <= 1) {
        plhs[0] = mxCreateDoubleMatrix(mn, 6, mxREAL); 
        yp = mxGetPr(plhs[0]); 
        mo = yp+mn;
        d  = yp+2*mn;
        h  = yp+3*mn;
        mi = yp+4*mn;
        s  = yp+5*mn;
        hms = 1;
    } else if (nlhs == 3 || nlhs == 6) {
        for (k = 0; k < nlhs; k++) {
           plhs[k] = mxCreateDoubleMatrix(m, n, mxREAL); 
        }
        yp  = mxGetPr(plhs[0]); 
        mo  = mxGetPr(plhs[1]); 
        d   = mxGetPr(plhs[2]); 
        hms = (nlhs == 6);
        if (hms) {
           h  = mxGetPr(plhs[3]); 
           mi = mxGetPr(plhs[4]); 
           s  = mxGetPr(plhs[5]); 
        }
    } else {
        mexErrMsgIdAndTxt("MATLAB:datevecmx:IncorrectNumberofOutputs",
         "Expect one, three or six output arguments.");
    }

    for (k = 0; k < mn; k++) {
        t = *tp++;
        if (!mxIsFinite(t) || fabs(t) > tmax) {
            mexErrMsgIdAndTxt("MATLAB:datevecmx:InvalidInput",
             "Date number out of range.");
        }
        if (hms) {
            if (t == floor(t)) {
                *s++ = *mi++ = *h++ = 0.;
            } else {
                t = 86400*t;
                if (rf) {
                   t = floor(t+0.5);
                }
                ts = t;
                t = floor(t/60.);
                *s++ = ts - 60.*t;
                ts = t;
                t = floor(t/60.);
                *mi++ = ts - 60.*t;
                ts = t;
                t = floor(t/24.);
                *h++ = ts - 24.*t;
            }
        }
        t = floor(t);
        if (t == 0) {
            *yp++ = *mo++ = *d++ = 0;
        } else {
            y = floor(t/365.2425);
            ts = t - (365.0*y + ceil(0.25*y)-ceil(0.01*y)+ceil(0.0025*y));
            if (ts <= 0) {
                y = y - 1.;
                t = t - (365.0*y + ceil(0.25*y)-ceil(0.01*y)+ceil(0.0025*y));
            } else {
                t = ts;
            }
            *yp++ = y;
            iy = (int) y;
            leap = ((iy%4 == 0) && (iy%100 != 0) || (iy%400 == 0));
            cdm = (leap ? cdml : cdm0);
            mon = (int) t/29.-1;
            if (t > cdm[mon+1]) mon++;
            *mo++ = mon+1;
            t = t - cdm[mon];
            *d++ = t;
        }
    }
}
