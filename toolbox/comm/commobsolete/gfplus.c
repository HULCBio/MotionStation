/* 
 * C-mex function. 
 * GFPLUS  Element-by-element multiplication in GF(2^M).
 * Calling format: C = gfplus(A, B, ALPHA, BETA) 
 *                 A & B are scalars or (vectors or matrices of the same size).
 *                 ALPHA and BETA are vectors defining the field.
 *                 C is the result.
 *
 * Copyright 1996-2002 The MathWorks, Inc.
 * $Revision: 1.15 $  $Date: 2002/03/27 00:19:28 $
 */

#include <math.h>
#ifdef MATLAB_MEX_FILE
#include "mex.h"
#endif

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	int		m_a, n_a, len_a, m_b, n_b, len_b, m_alpha, n_alpha, len_alpha, m_beta, n_beta, len_beta;
	int		i, j, len, idx_a, idx_b, idx_c, tmp_a, tmp_b;
	int		m, q;
	int		p = 2;
	int		cnt = 0;
	double	fctr;
	double	*a, *b, *c, *alpha, *beta;

    /* Error checking. */
    if ( nrhs < 4 )	{
		mexErrMsgTxt("Not enough input arguments.");
    }
    if ( nrhs > 4 )	{
		mexErrMsgTxt("Too many input arguments.");
    }
    for (i=0; i < nrhs; i++) {
		if ( mxIsEmpty(prhs[i]) || mxIsChar(prhs[i]) || mxIsComplex(prhs[i]) )
			mexErrMsgTxt("All inputs must be real integers."); 
    }

    /* Get inputs */
	a = mxGetPr(prhs[0]);
	m_a = mxGetM(prhs[0]);
	n_a = mxGetN(prhs[0]);
	len_a = m_a * n_a;
	
	b = mxGetPr(prhs[1]);
	m_b = mxGetM(prhs[1]);
	n_b = mxGetN(prhs[1]);
	len_b = m_b * n_b;
	
	alpha = mxGetPr(prhs[2]);
	m_alpha = mxGetM(prhs[2]);
	n_alpha = mxGetN(prhs[2]);
	len_alpha = m_alpha * n_alpha;

	beta = mxGetPr(prhs[3]);
	m_beta = mxGetM(prhs[3]);
	n_beta = mxGetN(prhs[3]);
	len_beta = m_beta * n_beta;

	/* Error checking - size. */
	if ( ( m_alpha>1 && n_alpha>1 ) || ( m_beta>1 && n_beta>1 ) || ( len_alpha!=len_beta ) ) {
		mexErrMsgTxt("FVEC and IVEC must be vectors of the same length.");
	}
	
    /* Determine the output length based on inputs */
    if ( (len_a!= 1) && (len_b!=1) ) { /* Both A and B are not scalars */
		if ( ( m_a != m_b ) || ( n_a != n_b ) )	{
			mexErrMsgTxt("If both A and B are vectors or matrices, then they must have the same size.");
		}
		len = len_a;
	} else if ( ( len_a==1 ) && (len_b!=1 ) ) {/* A is a scalar, B is a vector or matrix. */
		len = len_b;
		m_a = m_b;
		n_a = n_b;
	} else if ( ( len_a!=1 ) && (len_b==1 ) ) { /* B is a scalar, A is a vector or matrix. */
		len = len_a;
	} else if ( (len_a== 1) && (len_b==1) ) { /* Both A and B are scalars. */
	    len = len_a;
	}

	/* P is assumed to be 2, determine M and Q. */
	fctr = len_alpha;
	while (fctr >= p) {
		fctr = fctr / p;
		cnt++;
	}
	if ( fctr != 1 ) {
		mexErrMsgTxt("FVEC and IVEC have invalid length.");
	}
	m = cnt;
	q = (int) pow(p,m);

	/* Error checking - ALPHA => FVEC. */
	for ( i=0 ; i<len_alpha ; i++ )	{
		if ( ( alpha[i] != floor(alpha[i]) ) || ( alpha[i] < 0 ) || ( alpha[i] > q-1 ) ) {
			mexErrMsgTxt("Elements in FVEC must be integers between 0 and 2^M-1.");
		}
		for ( j=i-1 ; j>=0 ; j-- )	{
			if ( alpha[i] == alpha[j] ) {
				mexErrMsgTxt("Invalid FVEC, repeated elements.");
			}
		}
	}
		
	/* Error checking - BETA => IVEC. */
	for ( i=0 ; i<len_beta ; i++ ) {
		if ( ( beta[i] != floor(beta[i]) ) || ( beta[i] < 0 ) || ( beta[i] > q-1 ) ) {
			mexErrMsgTxt("Elements in IVEC must be integers between 0 and 2^M-1.");
		}
		for ( j=i-1 ; j>=0 ; j-- ) {
			if ( beta[i] == beta[j] ) {
				mexErrMsgTxt("Invalid IVEC, repeated elements.");
			}
		}
	}
		
	/* Error checking - A. */
	for ( i=0 ; i<len_a ; i++ ) {
		if ( ( a[i] != floor(a[i]) ) || ( a[i] > q-2 ) ) {
			mexErrMsgTxt("Elements in A must be integers between -Inf and 2^M-2.");
		}
	}
		
	/* Error checking - B. */
	for ( i=0 ; i<len_b ; i++ ) {
		if ( ( b[i] != floor(b[i]) ) || ( b[i] > q-2 ) ) {
			mexErrMsgTxt("Elements in B must be integers between -Inf and 2^M-2.");
		}
	}
		
	/* Allocate space for the output. */
	c = mxGetPr(plhs[0] = mxCreateDoubleMatrix(m_a, n_a, mxREAL));

	/* The actual computation, cycle through each element. */
	for ( i=0 ; i<len ; i++ ) {

		/* If A or B is a scalar index into just the first element.
		 * If A and/or B are vectors or matrices, then index into their ith element.
		 * This is where the 'scalar expansion' is performed. */
		idx_a = ( len_a == 1 ) ? 0 : i;
		idx_b = ( len_b == 1 ) ? 0 : i;
		
		/* Set all negative inputs to -1. */
		tmp_a = ( a[idx_a] < 0 ) ? -1 : (int) a[idx_a];
		tmp_b = ( b[idx_b] < 0 ) ? -1 : (int) b[idx_b];

		idx_c = ((int) alpha[tmp_a+1]) ^ ((int) alpha[tmp_b+1]);

		c[i] = beta[idx_c]-1;

		/* Set all negative outputs to -Inf. */
		if ( c[i] < 0 ) {
			c[i] = -mxGetInf();
		}
	}
	
}
/* [EOF] */
