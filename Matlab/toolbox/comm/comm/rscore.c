/*
 *  Syntax: [msg, err, ccode] = rscore(code, k, tp, dim, pow_dim)
 *  RSCORE The core function in Reed-Solomon decode.
 *      MSG = RSCORE(CODE, K, TP, M, POW_M, T2) decodes a single codeword
 *      vector CODE using Reed-Solomon decoding technique. The message length
 *      is K. The complete (and correct) list of all members in GF(2^M) is
 *      in TP. The code word length is provided in POW_M, which equals to
 *      2^M - 1. The decoding result is provided in the output variable MSG.
 *
 *      [MSG, ERR] = RSCORE(CODE, K, TP, M, POW_M, T2) outputs the error 
 *      detected in the decoding.
 *
 *      [MSG, ERR, CCODE] = RSCORE(CODE, K, TP, M, POW_M, T2) outputs the
 *      corrected codeword in CCODE.
 *
 *      NOTE. Different from all of the other encoding/decoding functions,
 *      This function takes the exponential input instead of regular input for
 *      processing. For example [-Inf, 0, 1, 2, ...] represents
 *      [0 1 alpha, alpha^2, ...] in GF(2^m). There are 2^M elements in
 *      GF(2^M). Hence, the input CODE represents 2^M * (2^M - 1) bits of
 *      information. The decoded MSG represents 2^M * K bits of information.
 *      For speeding computation, no error-check is placed in this function,
 *      all input variables must be presented.
 *
 *  See also: errlocp, bchcore
 *
 *  Copyright 1996-2002 The MathWorks, Inc.
 *  $Revision: 1.18 $ $Date: 2002/04/14 20:12:25 $
 */

#include "gflib.h"

void mexFunction(int_T nlhs, mxArray *plhs[], int_T nrhs, const mxArray *prhs[])
{
    int_T     i, np, mp, pow_dim, dim, k;
    int_T     *code, *pp, *Iwork, *ccode, *err;
    double  *Msg, *Err, *CCode, *Code, *PP;
    
    /* Error checking */
    for (i=0; i < nrhs; i++){
        if ( mxIsChar(prhs[i]) || mxIsEmpty(prhs[i]) || mxIsComplex(prhs[i]) )      
	        mexErrMsgTxt("Invalid input arguments."); 
    }
    if ( nrhs < 5 )
      mexErrMsgTxt("Not enough input arguments.");

    /* Get parameters */
    Code = mxGetPr(prhs[0]);
    k = (int_T)mxGetScalar(prhs[1]);
    np = mxGetM(prhs[2]);
    mp = mxGetN(prhs[2]);
    PP = mxGetPr(prhs[2]);
    pp = (int_T *)mxCalloc(np*mp,sizeof(int_T));
    for(i=0; i< np*mp; i++)
      pp[i] = (int_T)PP[i];

    dim = (int_T)mxGetScalar(prhs[3]);
    pow_dim = (int_T)mxGetScalar(prhs[4]);

    code = (int_T *)mxCalloc(pow_dim,sizeof(int_T));
    for(i=0; i<pow_dim; i++){
        if (Code[i]<0){
            code[i] = -1;
        } else {
            code[i] = (int_T)Code[i];
        }
    }

    if ( k <= 0 || dim != mp || pow_dim < (np-1) || mxGetM(prhs[0])*mxGetN(prhs[0]) != pow_dim )
      mexErrMsgTxt("Invalid input arguments.");
    
    /* set up a integer working space (int_T *)Iwork. */
    Iwork = (int_T *)mxCalloc( (pow_dim-2*k+5*dim+19)*pow_dim+3*dim+k*(k-13)+28+3*mp, sizeof(int_T));
    err = Iwork;
    err[0] = 0;
    ccode = Iwork + 1;
    for(i=0; i<pow_dim; i++)
      ccode[i] = 0;
    rscore(code, k, pp, dim, pow_dim, Iwork+1+pow_dim, err, ccode);
    
    /* Outputs */
    Msg = mxGetPr(plhs[0] = mxCreateDoubleMatrix(1, k, mxREAL));
    Err = mxGetPr(plhs[1] = mxCreateDoubleMatrix(1, 1, mxREAL));
    CCode = mxGetPr(plhs[2] = mxCreateDoubleMatrix(1, pow_dim, mxREAL));
    for(i=0; i < pow_dim; i++){
        if(ccode[i] < 0) {
	        CCode[i] = -mxGetInf();
	    } else {
	        CCode[i] = (double)ccode[i];
        }
    }
    for(i=pow_dim-k; i < pow_dim; i++)
      Msg[i-pow_dim+k] = CCode[i];
    Err[0] = (double)err[0];

    return;
}

/* [EOF] */
