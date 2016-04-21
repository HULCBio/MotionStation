/*
 *  Syntax: [sigma, err] = errlocp(syndrome, t, tp, pow_dim, err, type_flag)
 *  ERRLOCP Computes the error-location polynomial.
 *       [SIGMA, ERR] = ERRLOCP(SYNDROME, T, TP, ERR, FLAG) computes the
 *       error-location polynomial from length 2*T input vector SYNDROME.
 *       T is the error-correction capability. Tp is the complete tuple list
 *       of all elements in GF(2^M). POW_DIM = 2^M-1, which is the dimension
 *       of GF(2^M).  ERR contains the error information in the computation.
 *       FLAG indicates the method to be used in the computation.
 *       FLAG = 1, uses normal method.
 *       FLAG = 0, use simplified method. The simplified method can be
 *                      used for binary code only. 
 *
 *       Warning: This function does not provide error-check. Make sure
 *                the parameters are signed correctly.
 *
 *  Copyright 1996-2002 The MathWorks, Inc.
 *  $Revision: 1.17 $ $Date: 2002/03/27 00:05:27 $
 */

#include "gflib.h"

void mexFunction(int_T nlhs, mxArray *plhs[], int_T nrhs, const mxArray *prhs[])
{
    int_T     i, t, np, mp, pow_dim, prim, Flag, err_In[1], len_Out[1];
    int_T     *syndr, *pp, *Iwork, *pNum, *pInv, *sigma_Out;
    double  *sigma, *errOut, *syndrome, *T, *p, *Pow_dim, *err, *flag;

    for (i=0; i < nrhs; i++){
    	if ( mxIsEmpty(prhs[i]) || mxIsChar(prhs[i]) || mxIsComplex(prhs[i]) )
	        mexErrMsgTxt("Invalid input arguments."); 
    }
    if ( nrhs < 6 ){
      mexErrMsgTxt("Not enough input arguments.");
      return;
    }

    syndrome = mxGetPr(prhs[0]);
    T   = mxGetPr(prhs[1]);
    p   = mxGetPr(prhs[2]);
    Pow_dim = mxGetPr(prhs[3]);
    err = mxGetPr(prhs[4]);
    flag = mxGetPr(prhs[5]);

    np = mxGetM(prhs[2]);
    mp = mxGetN(prhs[2]);
    if ( *T < 0 || *Pow_dim < np-1 || *err<0 || *flag<0 || mxGetM(prhs[0])*mxGetN(prhs[0])<2*(*T) ){
        mexErrMsgTxt("Invalid input arguments.");        
        return;
    }
    /* converting the type of variables to integer.*/
    t = (int_T)*T;
    Flag = (int_T)*flag;
    err_In[0] = (int_T)*err;
    pow_dim = (int_T)*Pow_dim;
    syndr = (int_T *)mxCalloc(2*t,sizeof(int_T));
    len_Out[0] = 0;
    for(i=0; i<2*t; i++)
        syndr[i] = (int_T) syndrome[i];
    pp = (int_T *)mxCalloc(np*mp,sizeof(int_T));
    for(i=0; i<np*mp; i++)
        pp[i] = (int_T) p[i];
    /* set up a integer working space (int_T *)Iwork for functions. */
    if( Flag ){
        t=2*t;
        Iwork = (int_T *)mxCalloc((2+mp)*np+5*(t+2)+(t+5)*(t+1), sizeof(int_T));
    } else {
        Iwork = (int_T *)mxCalloc((2+mp)*np+5*(t+2)+(t+5)*(t+1), sizeof(int_T));
    }
    pNum = Iwork;
    pInv = Iwork + np;
    prim = 2;
    pNumInv(pp, np, mp, prim, pNum, pInv);
    if ( Flag ){
        sigma_Out = Iwork+(2+mp)*np;
        errlocp1(syndr,t,pNum,pInv,pow_dim,err_In,sigma_Out+(t+1),sigma_Out,len_Out);
    }else{
        sigma_Out = Iwork+(2+mp)*np;
        errlocp0(syndr,t,pNum,pInv,pow_dim,err_In,sigma_Out+(t+1),sigma_Out,len_Out);
    }

    /* output parameters list */
    sigma = mxGetPr(plhs[0] = mxCreateDoubleMatrix(1, len_Out[0], mxREAL));
    for(i=0; i < len_Out[0]; i++)
      sigma[i] = (double)sigma_Out[i];
    errOut = mxGetPr(plhs[1] = mxCreateDoubleMatrix(1, 1, mxREAL));
    if ( err_In[0] != 0 )
      errOut[0] = 1;
    else
      errOut[0] = 0;
    return;
}

/* [EOF] */
