/*=================================================================
 *
 * YPRIME.C	Sample .MEX file corresponding to YPRIME.M
 *	        Solves simple 3 body orbit problem 
 *		Modified function to demonstrate shared library calling
 *
 * The calling syntax for the mex funcion is:
 *
 *		[yp] = yprime(t, y)
 *
 *  You may also want to look at the corresponding M-code, yprime.m.
 *
 * This is a MEX-file for MATLAB.  
 * Copyright 1984-2002 The MathWorks, Inc.
 *
 *=================================================================*/
/* $Revision: 1.1.6.2 $ */
#include <math.h>
#include "mex.h"
#define EXPORT_FCNS
#include "shrhelp.h"


/* Input Arguments */

#define	T_IN	prhs[0]
#define	Y_IN	prhs[1]


/* Output Arguments */

#define	YP_OUT	plhs[0]

#if !defined(MAX)
#define	MAX(A, B)	((A) > (B) ? (A) : (B))
#endif

#if !defined(MIN)
#define	MIN(A, B)	((A) < (B) ? (A) : (B))
#endif

#define PI 3.14159265

static	double	mu = 1/82.45;
static	double	mus = 1 - 1/82.45;


EXPORTED_FUNCTION void yprimefcn(
		   double	yp[],
		   double	*t,
 		   double	y[]
		   )
{
    double	r1,r2;
    
    r1 = sqrt((y[0]+mu)*(y[0]+mu) + y[2]*y[2]); 
    r2 = sqrt((y[0]-mus)*(y[0]-mus) + y[2]*y[2]);

    /* Print warning if dividing by zero. */    
    if (r1 == 0.0 || r2 == 0.0 ){
	mexWarnMsgTxt("Division by zero!\n");
    }
    
    yp[0] = y[1];
    yp[1] = 2*y[3]+y[0]-mus*(y[0]+mu)/(r1*r1*r1)-mu*(y[0]-mus)/(r2*r2*r2);
    yp[2] = y[3];
    yp[3] = -2*y[1] + y[2] - mus*y[2]/(r1*r1*r1) - mu*y[2]/(r2*r2*r2);
    return;
}

EXPORTED_FUNCTION mxArray* better_yprime(
		   double	t,
 		   mxArray* y_in)
{
    double *yp; 
    double *y; 
    unsigned int m,n;
    mxArray* yp_out;
     
    m = mxGetM(y_in); 
    n = mxGetN(y_in);
    if (!mxIsDouble(y_in) || mxIsComplex(y_in) || 
	(MAX(m,n) != 4) || (MIN(m,n) != 1)) { 
	mexErrMsgTxt("YPRIME requires that Y be a 4 x 1 vector."); 
    } 
    /* Create a matrix for the return argument */ 
    yp_out = mxCreateDoubleMatrix(m, n, mxREAL); 
    
    /* Assign pointers to the various parameters */ 
    yp = mxGetPr(yp_out);
    
    y = mxGetPr(y_in);
        
    /* Do the actual computations in a subroutine */
    yprimefcn(yp,&t,y); 
    return yp_out;
}

void mexFunction( int nlhs, mxArray *plhs[], 
		  int nrhs, const mxArray*prhs[] )
     
{ 
    double *yp; 
    double *t,*y; 
    unsigned int m,n; 
    
    /* Check for proper number of arguments */
    
    if (nrhs != 2) { 
	mexErrMsgTxt("Two input arguments required."); 
    } else if (nlhs > 1) {
	mexErrMsgTxt("Too many output arguments."); 
    } 
    
    /* Check the dimensions of Y.  Y can be 4 X 1 or 1 X 4. */ 
    
    m = mxGetM(Y_IN); 
    n = mxGetN(Y_IN);
    if (!mxIsDouble(Y_IN) || mxIsComplex(Y_IN) || 
	(MAX(m,n) != 4) || (MIN(m,n) != 1)) { 
	mexErrMsgTxt("YPRIME requires that Y be a 4 x 1 vector."); 
    } 
    
    /* Create a matrix for the return argument */ 
    YP_OUT = mxCreateDoubleMatrix(m, n, mxREAL); 
    
    /* Assign pointers to the various parameters */ 
    yp = mxGetPr(YP_OUT);
    
    t = mxGetPr(T_IN); 
    y = mxGetPr(Y_IN);
        
    /* Do the actual computations in a subroutine */
    yprimefcn(yp,t,y); 
    return;
    
}


