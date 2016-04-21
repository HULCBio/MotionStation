/*
 *     Syntax: [msg, err, ccode] = bchcore(code, pow_dim, dim, k, t, tp)
 *     BCHCORE The core part of the BCH decode.
 *     [MSG, ERR, CCODE] = BCHCORE(CODE, POW_DIM, DIM, K, T, TP) decodes
 *     a BCH code, in which CODE is a code word row vector,  with its column
 *     size being POW_DIM. POW_DIM equals 2^DIM -1. K is the message length,
 *     T is the error correction capability. TP is a complete list of the
 *     elements in GF(2^DIM).
 *
 *     This function can share the information between a SIMULINK file and
 *     MATLAB functions. It is not designed to be called directly. There is
 *     no error check in order to eliminate overhead.
 *
 *     Copyright 1996-2002 The MathWorks, Inc.
 *     $Revision: 1.16 $ $Date: 2002/03/27 00:06:03 $
 */

#include "gflib.h"

void mexFunction(int_T nlhs, mxArray *plhs[], int_T nrhs, const mxArray *prhs[])
{
    int_T     i, np, mp;
    int_T     pow_dim, dim, k, t;
    int_T     *code, *pp, *ccode, *err, *Iwork;
    double  *Msg, *Err, *CCode, *Code, *PP;

    for (i=0; i < nrhs; i++){
    	if ( mxIsEmpty(prhs[i]) || mxIsChar(prhs[i]) || mxIsComplex(prhs[i]) )
	        mexErrMsgTxt("Invalid input arguments."); 
    }
    if ( nrhs != 6 )
      mexErrMsgTxt("Incorrect number of input arguments.");
    
    np = mxGetM(prhs[5]);
    mp = mxGetN(prhs[5]);
    Code = mxGetPr(prhs[0]);
    pow_dim = (int_T)mxGetScalar(prhs[1]);
    dim = (int_T)mxGetScalar(prhs[2]);
    k = (int_T)mxGetScalar(prhs[3]);
    t = (int_T)mxGetScalar(prhs[4]);
    PP = mxGetPr(prhs[5]);

    code = (int_T *)mxCalloc(pow_dim,sizeof(int_T));
    for( i=0; i < pow_dim; i++)
      code[i] = (int_T)Code[i];
    pp = (int_T *)mxCalloc(np*mp,sizeof(int_T));
    for(i=0; i < np*mp; i++)
      pp[i] = (int_T)PP[i];
    
    /* set up a integer working space (int_T *)Iwork. */
    Iwork = (int_T *)mxCalloc( (2+dim)*(2*pow_dim+1)+5*t+(pow_dim-k)*(pow_dim-k)+10*(pow_dim-k)+17, sizeof(int_T));
    
    ccode= (int_T *)mxCalloc(pow_dim,sizeof(int_T));
    err = Iwork;
    bchcore(code,pow_dim,dim,k,t,pp,Iwork+1,err,ccode);   

    Msg = mxGetPr(plhs[0] = mxCreateDoubleMatrix(1, k, mxREAL));
    Err = mxGetPr(plhs[1] = mxCreateDoubleMatrix(1, 1, mxREAL));
    CCode = mxGetPr(plhs[2] = mxCreateDoubleMatrix(1, pow_dim, mxREAL));
    for(i=0; i < pow_dim; i++)
      CCode[i] = (double)ccode[i];
    for(i=pow_dim-k; i < pow_dim; i++)
      Msg[i-pow_dim+k] = CCode[i];
    Err[0] = (double)err[0];
    return;
}

/* [EOF] */
