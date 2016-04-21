/* $Revision: 1.15 $ */
/*============================================================================
 *  function out = vitshort(fst_in, snd_in, n_sta, mima)
 *   VITSHORT makes the two step expense of transferring into a one step expense.
 *   OUT = VITSHORT(FST_IN SCD_IN, N_STA, MIMA)
 *   FST_IN, step one
 *   SND_IN, step two
 *   N_STA,  number of state
 *   MIMA,   ==1 to find the minimum, == 0 to find the maximum
 *   OUT, FST_IN, and SND_IN are size 2^n_sta row vectors which recorded the 
 *      data of [d00, d10, d20, ..., dn0, d01, d11, d21,..., dn1, ...., d0n, 
 *                                          d1n, d2n, ...., dnn]
 *   where dij means the cost of transferring state i to state j.
 *   dij = NaN means that there is no transferring between the two states.
 *
 *   Used by viterbi.
 *============================================================================
 *
 *  Jun Wu, Jan 2nd, 1996
 *  Revised Wes Wang Jan. 9, 1996
 *  Copyright 1996-2002 The MathWorks, Inc.
 *==========================================================================*/
#include <math.h>
#ifdef MATLAB_MEX_FILE
#include <stdio.h>
#include "mex.h"
#endif

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray*prhs[])
{
  int i;
  for (i=0; i < nrhs; i++){
      if (mxIsEmpty(prhs[i]))
	mexErrMsgTxt("Empty variables are passed into VITSHORT; Use 'help vitshort' to get started."); 
      if (mxIsChar(prhs[i]))
	mexErrMsgTxt("String is not correct input type! Use 'help vitshort' to get started."); 
  }

  if ((nrhs != 4) || (nlhs != 1)) {
#ifdef MATLAB_MEX_FILE
     printf("Error calling VITSHORT.\n");
     printf("Number of input / output number is incorrect when calling VITSHORT.\n");
     printf("The function is designed for calling by function VITERBI only.\n\n");
#endif
    return;
  }else{
      int     j, k, nsta, pow_sta, aft_indx, len_indx, len, indx;
      int     *wei_indx, *sub_indx;
      double  max, min;
      double  *wei_mat_fst, *wei_sum;
      double  wei_mat_snd;    
      double  *FstIn, *SndIn, *NSta, *MiMa, *Out;
      double  NaN  = mxGetNaN();
  
  FstIn = mxGetPr(prhs[0]);
  SndIn = mxGetPr(prhs[1]);
  NSta =  mxGetPr(prhs[2]);
  MiMa =  mxGetPr(prhs[3]);
  
  /*pow_sta = length(fst_in);*/
  pow_sta = mxGetM(prhs[0])*mxGetN(prhs[0]);
  
  Out = mxGetPr(plhs[0] = mxCreateDoubleMatrix(1,pow_sta, mxREAL));
  nsta = (int)NSta[0];
  wei_mat_fst = (double *)mxCalloc(nsta, sizeof(double));
  wei_sum     = (double *)mxCalloc(nsta, sizeof(double));
  wei_indx    = (int *)mxCalloc(nsta, sizeof(int));
  sub_indx    = (int *)mxCalloc(nsta, sizeof(int));
  
  /*for i = 1 : n_sta
   *    aft_indx = i * n_sta - n_sta;
   */
  for(i=1; i <= nsta; i++){
    aft_indx = i * nsta - nsta;
    /* for j = 1 : n_sta
     *   wei_mat = [fst_in(j : n_sta : pow_sta);...
     *   snd_in(aft_indx+1 : aft_indx + n_sta)];
     *   wei_sum = sum(wei_mat);
     *   wei_indx = find(~isnan(wei_sum));
     */
    for(j=1; j <= nsta; j++){
      for(k=0; k < nsta; k++)
	wei_mat_fst[k] =FstIn[k * nsta + j - 1];
      len_indx = 0;
      for(k=0; k < nsta; k++){                
	wei_mat_snd = SndIn[aft_indx + k];
	if (mxIsNaN(wei_mat_fst[k]) || mxIsNaN(wei_mat_snd)) {
	  wei_sum[k] = NaN;
	} else {
	  wei_sum[k] = wei_mat_fst[k] + wei_mat_snd;
	  wei_indx[len_indx] = k;
	  len_indx++;
	}
      }
      
      /* if mima
       *    sub_indx = find(wei_sum == max(sum(wei_mat(:, wei_indx))));
       *    if length(sub_indx) > 1
       *        sub_indx = find(wei_mat(1,:) == max(wei_mat(1, sub_indx)));
       *    end;
       * else
       *    sub_indx = find(wei_sum == min(sum(wei_mat(:, wei_indx))));
       *    if length(sub_indx) > 1
       *        sub_indx = find(wei_mat(1,:) == min(wei_mat(1, sub_indx)));
       *    end;
       * end;
       */
      if (len_indx > 0) {
	len = 0;
	if(MiMa[0] != 0 ){
	  max = wei_sum[wei_indx[0]];
	  sub_indx[0] = wei_indx[0];                    
	  k = 1;
	  while (k < len_indx) {
	    if ( max < wei_sum[wei_indx[k]] ) {
	      max = wei_sum[wei_indx[k]];
	      sub_indx[0] = wei_indx[k];
	    }
	    k++;
	  }
	  for(k=0; k < len_indx; k++){
	    if (wei_sum[wei_indx[k]] == max ){
	      sub_indx[len] = wei_indx[k];
	      len++;
	    }
	  }
	  indx = sub_indx[0];                        
	  if (len > 1){
	    max = wei_mat_fst[sub_indx[0]];
	    k = 1;
	    while(k < len){
	      if( max < wei_mat_fst[sub_indx[k]] ) {
		max = wei_mat_fst[sub_indx[k]];
		indx = sub_indx[k];
	      }
	      k++;
	    }
	  }
	} else {
	  min = wei_sum[wei_indx[0]];
	  sub_indx[0] = wei_indx[0];
	  k = 1;
	  while (k < len_indx){
	    if ( min > wei_sum[wei_indx[k]] ) {
	      min = wei_sum[wei_indx[k]];
	      sub_indx[0] = wei_indx[k];                            
	    }
	    k++;
	  }
	  for(k=0; k < len_indx; k++){
	    if (wei_sum[wei_indx[k]] == min ){
	      sub_indx[len] = wei_indx[k];
	      len++;
	    }
	  }
	  indx = sub_indx[0];
	  if ( len > 1 ){
	    min = wei_mat_fst[sub_indx[0]];
	    k = 1;
	    while (k < len){
	      if( min > wei_mat_fst[sub_indx[k]] ) {
		min = wei_mat_fst[sub_indx[k]];
		indx = sub_indx[k];
	      }
	      k++;
	    }
	  } else {
	    indx = sub_indx[0];
	  }
	}
	/*        if ~isempty(sub_indx)
	 *            out(aft_indx + j) = wei_sum(sub_indx(1));
	 *        else
	 *            out(aft_indx + j) = NaN;
	 *        end;
	 *    end;
	 *end;
	 */
	Out[aft_indx + j - 1] = wei_sum[indx];    
      } else {
	Out[aft_indx + j - 1] = NaN;
      }
    }
  }
  return;
  }
}

