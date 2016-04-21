/* 
* C-mex function. 
* GFADD  Add two GF(P) polynomials or two GF(P^M) elements.
* Calling format: C = gfadd(A, B, P) 
*                 A & B are scalars, vectors or matrices of the same size.
*                 P is a scalar or a matrix defining the field over which
*                 the addition is to be performed.  C is the result.
*                 C = gfadd(A, B, P, LEN)
*                 LEN is a scalar specifying the desired length of the output.
*                 When LEN is negative, the length of C equals degree(C) + 1.
*
* Copyright 1996-2002 The MathWorks, Inc.
* $Revision: 1.15 $ $Date: 2002/03/27 00:07:11 $
*/

#include "gflib.h"

void mexFunction(int_T nlhs, mxArray *plhs[], int_T nrhs, const mxArray *prhs[])
{
    int_T     i, j, maxrow, maxcol;
    int_T     m_a, n_a, m_b, n_b, m_c, n_c, m_p, n_p;
    int_T     len, len_a, len_b, len_c;
    int_T     *aa, *bb, *cc, *pp, *Iwork;
    double  *a, *b, *c, *p, tlen;
	
    for (i=0; i < nrhs; i++) {
        if ( mxIsEmpty(prhs[i]) || mxIsChar(prhs[i]) || mxIsComplex(prhs[i]) )
            mexErrMsgTxt("All inputs must be real integers."); 
    }
    if ( nrhs < 2 ) {
        mexErrMsgTxt("Not enough input arguments.");
    }
    if ( nrhs > 4 ) {
        mexErrMsgTxt("Too many input arguments.");
    }
	
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
	
    a = mxGetPr(prhs[0]);
    b = mxGetPr(prhs[1]);
    m_a = mxGetM(prhs[0]);
    n_a = mxGetN(prhs[0]);
    m_b = mxGetM(prhs[1]);
    n_b = mxGetN(prhs[1]);
    len_a = m_a*n_a;
    len_b = m_b*n_b;
    
    if( m_a == 1 && m_b == 1) {
		/* inputs are row vectors */
        m_c = 1;
        if ( n_a >= n_b )
            n_c = n_a;
        else
            n_c = n_b;
    } else if (n_a == 1 && n_b == 1) {
		/* inputs are column vectors */
        n_c = 1;
        if ( m_a >= m_b )
            m_c = m_a;
        else
            m_c = m_b;          
    } else if (m_a == m_b && n_a == n_b) {
		/* inputs are matrices of the same size */
        m_c = m_a;
        n_c = n_a;
    } else {
		/* inputs are not compatible */
        mexErrMsgTxt("Input matrices must be the same size.");   
    }
    
    gfargchk(a, m_a, n_a, b, m_b, n_b, p, m_p, n_p);
	
    len_c = m_c*n_c;
    
    /* allocate memory for passing field information into gflib.c routines */    
    pp  = (int_T *)mxCalloc(n_p*m_p, sizeof(int_T));
    
    /* store field information in allocated memory */    
    for (i=0; i < n_p*m_p; i++) pp[i] = (int_T) p[i];
    
    /* input checking is complete - start computation */    
    if (n_p*m_p == 1){  
        /* operation is over a base field (addition modulo a prime number) */
        
        /* the fourth input parameter defines the output size */
        if ( nrhs == 4 ) {
            tlen = mxGetScalar(prhs[3]);
            if(tlen != floor(tlen)){
                mexErrMsgTxt("The LEN argument must be an integer.");
            }
            
            if ( tlen > 0 ) {
                /* output vector size has been specified as a parameter */
                n_c = (int_T) tlen;
                len_c = n_c * m_c;
                aa = (int_T *)mxCalloc(len_c, sizeof(int_T));
                bb = (int_T *)mxCalloc(len_c, sizeof(int_T));
                cc = (int_T *)mxCalloc(len_c, sizeof(int_T));
                for (i=0; i < len_c; i++){
                    aa[i] = 0;
                    if (i<len_a) aa[i] = (int_T)a[i];
                }
                for (i=0; i < len_c; i++){
                    bb[i] = 0;
                    if (i<len_b) bb[i] = (int_T)b[i];
                }
                gfadd(aa, len_c, bb, len_c, cc, len_c, pp[0]);
            } else {
                if ( tlen < 0 ) {
                    /* output vector size depends on computation results (gftrunc) */
                    aa = (int_T *)mxCalloc(len_a, sizeof(int_T));
                    bb = (int_T *)mxCalloc(len_b, sizeof(int_T));
                    cc = (int_T *)mxCalloc(len_c, sizeof(int_T));
                    for (i=0; i < len_a; i++){
                        aa[i] = (int_T)a[i];
                    }
                    for (i=0; i < len_b; i++){
                        bb[i] = (int_T)b[i];
                    }           
                    gfadd(aa, len_a, bb, len_b, cc, len_c, pp[0]);
                    if(m_c == 1) {
                        gftrunc(cc, &len_c, 1);
                        n_c = len_c;
                    } else {
                        mexErrMsgTxt("LEN must be positive when the inputs are matrices.");
                    }
                } else {
                    /* LEN is zero, output a null vector*/
                    n_c = (int_T) tlen;
                    len_c = n_c * m_c;  
                }                  
            }
        } else {
            /* output vector size is based on the input vector sizes */
            aa = (int_T *)mxCalloc(len_a, sizeof(int_T));
            bb = (int_T *)mxCalloc(len_b, sizeof(int_T));
            cc = (int_T *)mxCalloc(len_c, sizeof(int_T));
            for (i=0; i < len_a; i++){
                aa[i] = (int_T)a[i];
            }
            for (i=0; i < len_b; i++){
                bb[i] = (int_T)b[i];
            }           
            gfadd(aa, len_a, bb, len_b, cc, len_c, pp[0]);
        }

        
    } else {
        /* operation is over an extension field */
        if ( m_a >= m_b )
            maxrow = m_a;
        else
            maxrow = m_b;
        
        if ( n_a >= n_b )
            maxcol = n_a;
        else
            maxcol = n_b;
		
        n_c = maxrow*maxcol;
        len_a = n_c;
        len_b = n_c;
        
        /* allocate memory for call to gfpadd() in gflib.c */
        aa = (int_T *)mxCalloc(len_a, sizeof(int_T));
        bb = (int_T *)mxCalloc(len_b, sizeof(int_T));
		
        for (i=0; i < maxrow; i++){
            for(j=0; j < maxcol; j++){
                if( i >= m_a || j >= n_a ){
                    aa[i+j*maxrow] = -1;
                } else {
                    if ( a[i+j*maxrow] < 0 ){
                        aa[i+j*maxrow] = -1;
                    } else {
                        aa[i+j*maxrow] = (int_T)a[i+j*m_a];
                    }
                }
            }
        }
        for (i=0; i < maxrow; i++){
            for(j=0; j < maxcol; j++){
                if( i >= m_b || j >= n_b ){
                    bb[i+j*maxrow] = -1;
                } else {
                    if ( b[i+j*maxrow] < 0 ){
                        bb[i+j*maxrow] = -1;
                    } else {
                        bb[i+j*maxrow] = (int_T)b[i+j*m_b];
                    }
                }
            }
        }
        cc = (int_T *)mxCalloc(n_c, sizeof(int_T));             
        Iwork = (int_T *)mxCalloc(n_c+n_c*m_p+n_p+1, sizeof(int_T));
        Iwork[0] = n_c;
        gfpadd(aa, len_a, bb, len_b, pp, m_p, n_p, cc, Iwork, Iwork+1);
    }
	
    /* Create workspace arrays and pass results back to MATLAB */   
    if (n_p*m_p == 1) {
        /* operation is over a base field (addition modulo a prime number) */
        c = mxGetPr(plhs[0]=mxCreateDoubleMatrix(m_c, n_c, mxREAL));
        for(i=0; i < len_c; i++){
            if( cc[i] < 0 )
                c[i] = -mxGetInf();
            else
                c[i] = (double)cc[i];
        }
    } else {
        /* operation is over an extension field */
        c = mxGetPr(plhs[0]=mxCreateDoubleMatrix(maxrow, maxcol, mxREAL));
        for(i=0; i < maxrow*maxcol; i++){
            if( cc[i] < 0 )
                c[i] = -mxGetInf();
            else
                c[i] = (double)cc[i];
        }
    }
    return;
}

/* [EOF] */
