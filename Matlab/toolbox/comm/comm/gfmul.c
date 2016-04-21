/* 
 * C-mex function. 
 * GFMUL  Element-by-element multiplication in GF(P) or GF(P^M).
 * Calling format: C = gfmul(A, B, P) 
 *                 A & B are scalars, vectors or matrices of the same size.
 *                 P is a scalar or a mtrix defining the field over which
 *                 the multiplication is to be performed.  C is the result.
 *
 * Copyright 1996-2002 The MathWorks, Inc.
 * $Revision: 1.18 $ $Date: 2002/03/27 00:07:47 $
 */

#include "gflib.h"

void mexFunction(int_T nlhs, mxArray *plhs[], int_T nrhs, const mxArray *prhs[])
{
    int_T     m_a, n_a, m_b, n_b, m_p, n_p, len, i;
    int_T     *aa, *bb, *cc, *pp, *Iwork;
    double  *a, *b, *c, *p;
    
	/* Error checking. */
    for (i=0; i < nrhs; i++) {
		if ( mxIsEmpty(prhs[i]) || mxIsChar(prhs[i]) || mxIsComplex(prhs[i]) )
			mexErrMsgTxt("All inputs must be real integers."); 
    }
    if ( nrhs < 2 )	{
		mexErrMsgTxt("Not enough input arguments.");
    }
    if ( nrhs > 3 )	{
		mexErrMsgTxt("Too many input arguments.");
    }

    /* Get input arguments */
 	if ( nrhs == 2 ) {
	    p = (double *)mxCalloc(1, sizeof(double));
   	    p[0] = 2;
		m_p = 1;
		n_p = 1;
    } else if ( nrhs > 2 ) {
		p = mxGetPr(prhs[2]);
		m_p= mxGetM(prhs[2]);
		n_p= mxGetN(prhs[2]);
    }

    /* Get remaining input arguments. */
    a = mxGetPr(prhs[0]);
    b = mxGetPr(prhs[1]);
    m_a = mxGetM(prhs[0]);
    n_a = mxGetN(prhs[0]);
    m_b = mxGetM(prhs[1]);
    n_b = mxGetN(prhs[1]);
    len = m_a*n_a;
    
   	/* Validate inputs */
	if( (m_a != m_b) || (n_a != n_b) ) {
		mexErrMsgTxt("The inputs must have the same size and orientation.");
	}

    gfargchk(a, m_a, n_a, b, m_b, n_b, p, m_p, n_p);

    /* Input variable type conversion */
    aa = (int_T *)mxCalloc(len, sizeof(int_T));
    bb = (int_T *)mxCalloc(len, sizeof(int_T));
	for (i=0; i < len; i++)	{
		if (a[i] < 0) {
			aa[i] = -1;
		} else {
			aa[i] = (int_T) a[i];
		}
		if (b[i] < 0) {
			bb[i] = -1;
		} else {
			bb[i] = (int_T) b[i];
		}
	}    
    pp = (int_T *)mxCalloc(m_p*n_p, sizeof(int_T));
	for (i=0; i < m_p*n_p; i++) {
			pp[i] = (int_T) p[i];
	}

    /* Computation. */
	cc = (int_T *)mxCalloc(len, sizeof(int_T));
    if(m_p*n_p == 1) { /* GF(P) */
		/* call gfmul in gflib.c */
		gfmul(aa, len, bb, len, *pp, cc);
    } else { /* GF(P^M) */
		/* call gfpmul in gflib.c */
		Iwork = (int_T *)mxCalloc(2*len+len*n_p+m_p+1, sizeof(int_T));
		Iwork[0] = len;
		gfpmul(aa, len, bb, len, pp, m_p, n_p, cc, Iwork, Iwork+1);
    }

    /* Output variable type conversion */
	c = mxGetPr(plhs[0]=mxCreateDoubleMatrix(m_a, n_a, mxREAL));
	for(i=0; i < len; i++) {
		if(cc[i] == -Inf) {
			c[i] = -mxGetInf();
		} else {
			c[i] = (double)cc[i];
		}
	}
}

/* [EOF] */
