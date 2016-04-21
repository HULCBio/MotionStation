/* $Revision: 1.18 $ */
/*  P.S: This is a data processing function called by viterbi.m     */
/*-------------------------------------------------------------------
 *  Originally Designed by Wes Wang
 *
 *  Jun Wu
 *  Mar-3rd, 1996          
 *
 *  Copyright 1996-2002 The MathWorks, Inc.
 *------------------------------------------------------------------*/
#include <stdio.h>
#include <math.h>

#ifdef MATLAB_MEX_FILE
#include "mex.h"
#endif

#include "vitlib.c"
#define Inf     mxGetInf()
#define one 1
/*
 * the main function
 */
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  int    i, j, ii, jj, j2, j_k, j_pre, l, indx_j, num_N, num_K, NaN;
  int    n_code, m_code, colFunc, rowFunc, n_tran_prob, m_tran_prob, n_codd, n_msg, len_expen;
  int    N, M, K, num_state, n_std_sta, PowPowM, K2; 
  int    leng, len_C, len_pre_state, len_aft_state, len_plot_flag;
  int    expen_flag, trace_num, trace_eli, trace_pre, tran_indx, nex_sta_de, cur_sta_num;
  int    starter, dec, numnotnan, loc_exp1, loca_exp1, tmp, lenIndx0, lenIndx1;
  double max, loca_exp, loc_exp;

  int    *A, *B, *C, *D, *expense1, *solution1, *solu, *sol1, *TRAN_A, *TRAN_B;  
  int    *inp_pre, *cur_sta_pre, *expen_work, *expen_tmp1, *pre_state, *cur_sta, *inp;
  int    *nex_sta, *out, *expenOut, *aft_state, *tmpIwork, *IWork; 
  double *code, *tran_func, *tran_prob, *Tran_prob, *plot_flag;
  double *msg, *expen, *codd;
  double *expense, *expen_tmp, *sol, *solution, *tmpRwork, *RWork;
  double *p_v5_out;

  for (i=0; i < nrhs; i++){
      if (mxIsChar(prhs[i]))
	mexErrMsgTxt("String is not correct input type! Use 'help vitcore' to get started."); 
  }

  /*% routine check.
   *if nargin < 2
   *    error('Not enough input variable for VITERBI.');
   *elseif nargin < 3
   *    leng = 0;
   *end;
   *
   *% the case of unlimited delay and memory.
   *[n_code, m_code] = size(code);
   *if (leng <= 0) | (n_code <= leng)
   *    leng = n_code;
   *end;
   *if leng <= 1
   *    leng = 2;
   *end;
   *
   *if nargin < 4
   *    expen_flag = 0;     % expense_flag == 0 for BSC code;  == 1, with TRAN_PROB.
   *else
   *    [N, K] = size(tran_prob);
   *    if N < 3
   *        expen_flag = 0;
   *    else
   *        expen_flag = 1;
   *        expen_work = zeros(1, N); % work space.
   *        tran_prob(2:3, :) = log10(tran_prob(2:3, :));
   *    end;
   *end;
   *
   *if nargin < 5
   *    plot_flag(1) = 0;
   *else
   *    if (plot_flag(1) <= 0)
   *        plot_flag(1) = 0;
   *    elseif floor(plot_flag(1)) ~= plot_flag(1)
   *        plot_flag(1) = 0;
   *    end;
   *end;
   */

  /* deal properly with all kinds of input. */
  if ( nrhs < 2 ){
#ifdef MATLAB_MEX_FILE
      printf("Error calling VITCORE.\n");
      printf("Number of input/output number is incorrect when calling VITCORE.\n");
      printf("The function is designed for calling by function VITERBI only.\n\n");
#endif
      return;
  }

  /* get the input(code, tran_func) of function */
  n_code = mxGetM(prhs[0]);
  m_code = mxGetN(prhs[0]);
  code = mxGetPr(prhs[0]);

  rowFunc = mxGetM(prhs[1]);
  colFunc = mxGetN(prhs[1]);
  tran_func = mxGetPr(prhs[1]);
  for(i=0; i < rowFunc*colFunc; i++){
    if( tran_func[i] < 0 )
      tran_func[i] = -Inf;
  }

  if( tran_func[rowFunc*colFunc-1] == -Inf ){
    /* this kind of tran_func has A, B, C, D */ 
    N = (int)tran_func[ rowFunc*(colFunc-1) ];
    K = (int)tran_func[ rowFunc*(colFunc-1)+1 ];
    M = (int)tran_func[ rowFunc*(colFunc-1)+2 ];
    len_C = M*N;
  }else{
    /* this kind of tran_func is a two columns matrix */ 
    N = (int)tran_func[rowFunc];
    K = (int)tran_func[rowFunc+1];
    M = (int)tran_func[1];
    len_C = 0;
  }

  if(nrhs<3){
    leng = 0;
    expen_flag = 0;
    NaN = -1;
    len_plot_flag = 0;
  } else {
    leng = (int)mxGetScalar(prhs[2]);  
    if( nrhs < 4 ){
      expen_flag = 0;
      NaN = -1;
      len_plot_flag = 0;
    } else {
      /* deal properly with all kinds of 'tran_prob' */
      n_tran_prob = mxGetM(prhs[3]);
      m_tran_prob = mxGetN(prhs[3]);
      Tran_prob = mxGetPr(prhs[3]);
      if(n_tran_prob < 3){
        expen_flag = 0;
        NaN = -1;
      }else{
        expen_flag = 1;
        NaN = 1;
        tran_prob = (double *)mxCalloc(m_tran_prob*n_tran_prob, sizeof(double));
        for(i=0; i < m_tran_prob; i++){
          tran_prob[i*n_tran_prob] = Tran_prob[i*n_tran_prob];
          tran_prob[i*n_tran_prob+1] = log10(Tran_prob[i*n_tran_prob+1]);
          tran_prob[i*n_tran_prob+2] = log10(Tran_prob[i*n_tran_prob+2]);
        }
      }

      /* deal properly with all kinds of 'plot_flag' */
      if( nrhs < 5 ){
        len_plot_flag = 0;
      }else{
        len_plot_flag = mxGetM(prhs[4])*mxGetN(prhs[4]);
		plot_flag = (double *)mxCalloc(len_plot_flag, sizeof(double));
        plot_flag = mxGetPr(prhs[4]);
        if( plot_flag[0] <= 0 )
          len_plot_flag = 0;
        else if ( (int)plot_flag[0] != plot_flag[0] )
          len_plot_flag = 0;
      }
    }
  }

  if( leng <= 0 || n_code <= leng )
    leng = n_code;
  if( leng <= 1 )
    leng = 2;
    
  /*if isstr(tran_func)
   *    tran_func = sim2tran(tran_func);
   *end;
   *% initial parameters.
   *[A, B, C, D, N, K, M] = gen2abcd(tran_func);
   */
  num_state = M;
  n_std_sta = 1;
  for(i=0; i < num_state; i++)
    n_std_sta = n_std_sta * 2;
  PowPowM = n_std_sta * n_std_sta;

  K2 = 1;
  for(i=0; i < K; i++)
    K2 = K2*2;

  if( expen_flag == 1 ){
    RWork =(double *)mxCalloc( (leng+4)*PowPowM+2*n_std_sta, sizeof(double));
                /* the number of real working space
                 * expense -------- leng*PowPowM
                 * solution ------- PowPowM
                 * sol ------------ PowPowM
                 * expen_tmp ------ PowPowM
                 * tmpRwork ------- 2*n_std_sta+PowPowM
                 */
    if( len_C != 0 )
      IWork =(int *)mxCalloc((M+N)*(M+K)+leng*PowPowM+K*(K2+1)+(4+M)*n_std_sta+3*N+2*M, sizeof(int));
                    /* A -------------- M*M
                     * B -------------- M*K
                     * C -------------- N*M
                     * D -------------- N*K
                     * solu ----------- leng*PowPowM
                     * inp_pre -------- K*K2
                     * cur_sta_pre ---- M*n_std_sta
                     * expen_work ----- N
                     * pre_state ------	n_std_sta
                     * cur_sta -------- M
                     * inp ------------ K
                     * nex_sta -------- M
                     * out ------------ N
                     * expenOut ------- N
                     * aft_state ------	n_std_sta
                     * tmpIwork ------- 2*n_std_sta
                     */
    else
      IWork = (int *)mxCalloc((rowFunc-2)*(M+N+2)+leng*PowPowM+K*(K2+1)+(4+M)*n_std_sta+3*N+2*M, sizeof(int));
                    /* TRAN_A --------- rowFunc-2
                     * TRAN_B --------- rowFunc-2
                     * A -------------- (rowFunc-2)*M
                     * B -------------- (rowFunc-2)*N
                     * same as above from *solu
                     */
  }else{
    /* no real working space */
    if( len_C != 0 )
      IWork =(int *)mxCalloc((M+N)*(M+K)+(2*leng+4)*PowPowM+K*(K2+1)+(6+M)*n_std_sta+2*N+2*M, sizeof(int));
                    /* A -------------- M*M
                     * B -------------- M*K
                     * C -------------- N*M
                     * D -------------- N*K
                     * expense1 ------- leng*PowPowM
                     * solution1 ------ PowPowM
                     * solu ----------- leng*PowPowM
                     * inp_pre -------- K*2^K
                     * cur_sta_pre ---- M*2^M
                     * pre_state ------	n_std_sta
                     * cur_sta -------- M
                     * inp ------------ K
                     * nex_sta -------- M
                     * out ------------ N
                     * expenOut ------- N
                     * aft_state ------	n_std_sta
                     * sol1 ----------- PowPowM
                     * expen_tmp1 ----- PowPowM
                     * tmpIwork ------- 4*n_std_sta+PowPowM
                     */
    else
      IWork = (int *)mxCalloc((rowFunc-2)*(M+N+2)+(2*leng+4)*PowPowM+K*(K2+1)+(6+M)*n_std_sta+2*N+2*M, sizeof(int));
                    /* TRAN_A --------- rowFunc-2
                     * TRAN_B --------- rowFunc-2
                     * A -------------- (rowFunc-2)*M
                     * B -------------- (rowFunc-2)*N
                     * same as above from *expense1
                     */
  }

  if( len_C != 0 ){
    A = IWork;
    B = A + M*M;
    C = B + M*K;
    D = C + M*N;
        
    /* Get the input Matrix A, B, C, D */
    for( i=0; i < M+N; i++ ){
      for( j=0; j < M+K; j++ ){
	if( i<M   && j<M )
          A[i+j*M] = (int)tran_func[i+j*(M+N)];
        if( i>M-1 && j<M )
          C[i+j*N-M] = (int)tran_func[i+j*(M+N)];
        if( i<M   && j>M-1 )
          B[i+j*M-M*M] = (int)tran_func[i+j*(M+N)];
        if( i>M-1 && j>M-1 )
          D[i+j*N-M*(N+1)] = (int)tran_func[i+j*(M+N)];
      }
    }
  }else{
    /* Assignment */
    TRAN_A = IWork;
    TRAN_B = TRAN_A + rowFunc-2;
    A = TRAN_B + rowFunc-2;
    B = A + M*(rowFunc-2);

    /* Get the input Matrix A, B */
    for(i=0; i < rowFunc-2; i++){
      TRAN_A[i] = (int)tran_func[i+2];
      TRAN_B[i] = (int)tran_func[rowFunc+i+2];
    }
    de2bi(TRAN_A, M, rowFunc-2, A);
    de2bi(TRAN_B, N, rowFunc-2, B);
  }
  /* end of Input Segment */

  if( expen_flag != 0 ){
    expense     = RWork;
    solution    = expense + leng*PowPowM;
    sol         = solution + PowPowM;
    expen_tmp   = sol + PowPowM;
    tmpRwork    = expen_tmp + PowPowM;

    if( len_C != 0 )
      solu = D + N*K;
    else
      solu = B + N*(rowFunc-2);

    inp_pre = solu + leng*PowPowM;        
    cur_sta_pre = inp_pre + K2*K;
    expen_work = cur_sta_pre + M*n_std_sta;
    pre_state = expen_work + N;
    cur_sta = pre_state + n_std_sta;
    inp = cur_sta + M;
    nex_sta = inp + K;
    out = nex_sta + M;
    expenOut = out + N;
    aft_state = expenOut + N;
    tmpIwork = aft_state + n_std_sta;
  }else{ /* tran_prob is not 3-row matrix */
    if( len_C != 0 )
      expense1 = D + N*K;
    else
      expense1 = B + N*(rowFunc-2);

    solu = expense1 + leng*PowPowM;    
    solution1 = solu + leng*PowPowM;
    inp_pre = solution1 + PowPowM;
    cur_sta_pre = inp_pre+ K2*K;
    pre_state =  cur_sta_pre + M*n_std_sta;
    cur_sta = pre_state + n_std_sta;
    inp = cur_sta + M;
    nex_sta = inp + K;
    out = nex_sta + M;
    expenOut = out + N;
    aft_state = expenOut + N;
    sol1 = aft_state + n_std_sta;
    expen_tmp1 = sol1 + PowPowM;
    tmpIwork = expen_tmp1 + PowPowM;
  }  

  /*if m_code ~= N
   *    if n_code == 1
   *        code = code';
   *        [n_code, m_code] = size(code);
   *    else
   *        error('CODE length does not match the TRAN_FUNC dimension in VITERBI.')
   *    end;
   *end;
   */

  if( m_code != N ){
    if(n_code == 1 ){
      n_code = m_code;
      m_code = 1;
    } else {
      mexErrMsgTxt("Code length does not match the TRAN_FUNC dimension in VITERBI.");
    }
  }

  /*% state size
   *if isempty(C)
   *    states = zeros(tran_func(2,1), 1);
   *else
   *    states = zeros(length(A), 1);
   *end;
   *num_state = length(states);
   */
  /* num_state has been set by the different TRAN_FUNC */

  /*% The STD state number reachiable is
   *n_std_sta = 2^num_state;
   *
   *PowPowM = n_std_sta^2;
   *
   *% at the very begining, the current state number is 1, only the complete zeros.
   *cur_sta_num = 1;
   *
   *% the variable expense is divided into n_std_sta section of size n_std_sta
   *% length vector for each row. expense(k, (i-1)*n_std_sta+j) is the expense of
   *% state j transferring to be state i
   *expense = ones(leng, PowPowM) * NaN;
   *expense(leng, [1:n_std_sta]) = zeros(1, n_std_sta);
   *solu = zeros(leng, PowPowM);
   *solution = expense(1,:);
   *
   *K2 = 2^K;
   */
  cur_sta_num = 1;  

  /* considering the different type of variable 'expense' */
  if(expen_flag != 0){
    for(i=0; i < leng*PowPowM; i++){
      expense[i] = NaN;
      solu[i] = 0;
    }
    for(i=0; i < n_std_sta; i++)
      expense[leng-1+i*leng] = 0;
    for(i=0; i < PowPowM; i++)
      solution[i] = expense[i*leng];

  } else {
    for(i=0; i < leng*PowPowM; i++){
      expense1[i] = NaN;
      solu[i] = 0;
    }
    for(i=0; i < n_std_sta; i++)
      expense1[leng-1+i*leng] = 0;
    for(i=0; i < PowPowM; i++)
      solution1[i] = expense1[i*leng];
  }

  /*pre_state = 1;
   *inp_pre = de2bi([0:K2-1]', K);
   *cur_sta_pre = de2bi([0:n_std_sta-1], M);
   *starter = 0;
   *msg = [];
   *expen = [];
   *codd = [];
   */
  len_pre_state = 1;
  pre_state[0] = 1;

  inp_pre[0] = -1;
  cur_sta_pre[0] = -1;
  de2bi(inp_pre, K, K2, inp_pre);
  de2bi(cur_sta_pre, M, n_std_sta, cur_sta_pre);

  starter = 0;
  msg = mxGetPr(plhs[0]=mxCreateDoubleMatrix(n_code, K, mxREAL));
  expen = mxGetPr(plhs[1]=mxCreateDoubleMatrix(n_code, 1, mxREAL));
  codd = mxGetPr(plhs[2]=mxCreateDoubleMatrix(n_code, N, mxREAL));
  n_msg = 0;
  len_expen = 0;
  n_codd = 0;
  /*for i = 1 : n_code
   *    % make room for one more storage.
   *    trace_pre = rem(i-2+leng, leng) + 1;  % previous line of the trace.
   *    trace_num = rem(i-1, leng) + 1;       % current line of the trace.
   *    expense(trace_num,:) = solution;
   */
  for(ii=1; ii <= n_code; ii++){
    trace_pre = (ii-2+leng) % leng + 1; /* previous line of the trace. */
    trace_num = (ii-1) % leng + 1;      /* current line of the trace. */
    for( i=0; i < PowPowM; i++){
      if ( expen_flag != 0 )
        expense[trace_num-1+i*leng] = solution[i];
      else
        expense1[trace_num-1+i*leng] = solution1[i];
    }
    /*if expen_flag
     *    for j = 1 : length(pre_state)
     *        jj = pre_state(j) - 1;           % index number - 1 is the state.
     *        cur_sta = cur_sta_pre(pre_state(j),:)';
     *        indx_j = (pre_state(j) - 1) * n_std_sta;
     *        for num_N = 1 : N
     *            expen_work(num_N) = max(find(tran_prob(1,:) <= code(i, num_N)));
     *        end;
     *        for num_k = 1 : K2
     *            inp = inp_pre(num_k, :)';
     *            if isempty(C)
     *                tran_indx = pre_state(j) + (num_k -1) * K2;
     *                nex_sta = A(tran_indx, :)';
     *                out = B(tran_indx, :)';
     *            else
     *                out = rem(C * cur_sta + D * inp,2);
     *                nex_sta = rem(A * cur_sta + B * inp, 2);
     *            end;
     *            nex_sta_de = bi2de(nex_sta') + 1;
     *            % find the expense by the transfer probability
     *            expen_0 = find(out' <= 0.5);
     *            expen_1 = find(out' > 0.5);
     *            loca_exp = sum([tran_prob(2,expen_work(expen_0)) 0])...
     *                                    +sum([tran_prob(3,expen_work(expen_1)) 0]);
     *            tmp = (nex_sta_de-1)*n_std_sta + pre_state(j);
     *            if isnan(expense(trace_num, tmp))
     *                expense(trace_num, tmp) = loca_exp;
     *                solu(trace_num, nex_sta_de + indx_j) = num_k;
     *            elseif expense(trace_num, tmp) < loca_exp
     *                expense(trace_num, tmp) = loca_exp;
     *                solu(trace_num, nex_sta_de + indx_j) = num_k;
     *            end;
     *        end;
     *    end;
     */
    if( expen_flag != 0){
      for(j=0; j < len_pre_state; j++){
    	jj = pre_state[j] - 1;
    	for(i=0; i < M; i++)
    	  cur_sta[i] = cur_sta_pre[jj + i*n_std_sta];
        indx_j = jj * n_std_sta;
    	for(num_N=0; num_N < N; num_N++){
          max = 0;
          for(i=0; i < m_tran_prob; i++){
            if( tran_prob[i*n_tran_prob] <= code[ii-1 + num_N*n_code] )
              max = i+1;
          }
	      expen_work[num_N] = max;
	    }
        for(num_K=0; num_K < K2; num_K++){
          for(i=0; i < K; i++)
            inp[i] = inp_pre[num_K+i*K2];
          if( len_C == 0 ){
            tran_indx = pre_state[j] + num_K*n_std_sta;
    	    for(i=0; i < M; i++)
    	      nex_sta[i] = A[tran_indx-1+i*(rowFunc-2)];
    	    for(i=0; i < N; i++)
    	      out[i] = B[tran_indx-1+i*(rowFunc-2)];
    	  }else{
    	    for(i=0; i < N; i++){
    	      out[i] = 0;   
	          for(l=0; l < M; l++)
		        out[i] = out[i] + C[i+l*N] * cur_sta[l];
	          for(l=0; l < K; l++)    
		        out[i] = out[i] + D[i+l*N]*inp[l];
	          out[i] = out[i] % 2;
	        }    
	        for(i=0; i < M; i++){
              nex_sta[i] = 0;  
	          for(l=0; l < M; l++)
		        nex_sta[i] = nex_sta[i] + A[i+l*M] * cur_sta[l];
	          for(l=0; l < K; l++)    
		        nex_sta[i] = nex_sta[i] + B[i+l*M]*inp[l];
	          nex_sta[i] = nex_sta[i] % 2;
	        }
          }
          bi2de(nex_sta,1, M, &nex_sta_de);
          nex_sta_de = nex_sta_de + 1;
          lenIndx0= 0;
          for(i=0; i < N; i++){
            if( out[i] <= 0.5 ){
              expenOut[lenIndx0] = i;
              lenIndx0++;
            }
          }
          lenIndx1 = 0;
          for(i=0; i < N; i++){
            if( out[i] > 0.5 ){
              expenOut[lenIndx1+lenIndx0] = i;
              lenIndx1++;
            }
          }
          loca_exp = 0;
          for(i=0; i < lenIndx0; i++)
            loca_exp = loca_exp + tran_prob[1 + n_tran_prob*(expen_work[ expenOut[i] ]-1) ];
          for(i=0; i < lenIndx1; i++)
            loca_exp = loca_exp + tran_prob[2 + n_tran_prob*(expen_work[expenOut[i+lenIndx0]]-1)];
          tmp = (nex_sta_de - 1) * n_std_sta + pre_state[j] - 1; /* minus 1 for index shift */
          if( expense[trace_num - 1 + tmp*leng] > 0 ){
            expense[trace_num - 1 + tmp*leng] = loca_exp;
            solu[trace_num - 1 + leng*(nex_sta_de+indx_j-1)] = num_K + 1;
          }else if( expense[trace_num - 1 + tmp*leng] < loca_exp ){
            expense[trace_num - 1 + tmp*leng] = loca_exp;
            solu[trace_num - 1 + leng*(nex_sta_de+indx_j-1)] = num_K + 1;
          }
        }
      }

    /*    else
     *        for j = 1 : length(pre_state)
     *            jj = pre_state(j) - 1;           % index number - 1 is the state.
     *            cur_sta = cur_sta_pre(pre_state(j),:)';
     *            indx_j = (pre_state(j) - 1) * n_std_sta;
     *            for num_k = 1 : K2
     *                inp = inp_pre(num_k, :)';
     *                if isempty(C)
     *                    tran_indx = pre_state(j) + (num_k -1) * K2;
     *                    nex_sta = A(tran_indx, :)';
     *                    out = B(tran_indx, :)';
     *                else
     *                    out = rem(C * cur_sta + D * inp,2);
     *                    nex_sta = rem(A * cur_sta + B * inp, 2);
     *                end;
     *                nex_sta_de = bi2de(nex_sta') + 1;
     *                loca_exp = sum(rem(code(i, :) + out', 2));
     *                tmp = (nex_sta_de-1)*n_std_sta + pre_state(j);
     *                if isnan(expense(trace_num, tmp))
     *                    expense(trace_num, tmp) = loca_exp;
     *                    solu(trace_num, nex_sta_de + indx_j) = num_k;
     *                elseif expense(trace_num, tmp) > loca_exp
     *                    expense(trace_num, tmp) = loca_exp;
     *                    solu(trace_num, nex_sta_de + indx_j) = num_k;
     *                end;
     *            end;
     *        end;
     *    end;
     */
    } else {
      for(j=0; j < len_pre_state; j++){
        jj = pre_state[j] - 1;
        for(i=0; i < M; i++)
          cur_sta[i] = cur_sta_pre[jj + i*n_std_sta];
        indx_j = jj * n_std_sta;
        for(num_K=0; num_K < K2; num_K++){
          for(i=0; i < K; i++)
            inp[i] = inp_pre[num_K+i*K2];
          if( len_C == 0 ){
            tran_indx = pre_state[j] + num_K*n_std_sta;
            for(i=0; i < M; i++)
              nex_sta[i] = A[tran_indx-1+i*(rowFunc-2)];
            for(i=0; i < N; i++)
              out[i] = B[tran_indx-1+i*(rowFunc-2)];
          }else{
            for(i=0; i < N; i++){
              out[i] = 0;  
              for(l=0; l < M; l++)
                out[i] = out[i] + C[i+l*N] * cur_sta[l];
              for(l=0; l < K; l++)    
                out[i] = out[i] + D[i+l*N]*inp[l];
              out[i] = out[i] % 2;
            }    
            for(i=0; i < M; i++){
              nex_sta[i] = 0;  
              for(l=0; l < M; l++)
                nex_sta[i] = nex_sta[i] + A[i+l*M]*cur_sta[l];
              for(l=0; l < K; l++)
                nex_sta[i] = nex_sta[i] + B[i+l*M]*inp[l];
              nex_sta[i] = nex_sta[i] % 2;
            }
          }
          bi2de(nex_sta, 1, M, &nex_sta_de);
          nex_sta_de = nex_sta_de + 1;
          loca_exp1 = 0;
          for(i=0; i < N; i++)
            loca_exp1 = loca_exp1 + ((int)code[ii-1+i*n_code] + out[i]) % 2;
          tmp = (nex_sta_de - 1) * n_std_sta + pre_state[j] - 1;
          if( expense1[trace_num - 1 + tmp*leng] < 0 ){
            expense1[trace_num - 1 + tmp*leng] = loca_exp1;
            solu[trace_num - 1 + leng*(nex_sta_de+indx_j-1)] = num_K + 1;
          }else if( expense1[trace_num - 1 + tmp*leng] > loca_exp1 ){
            expense1[trace_num - 1 + tmp*leng] = loca_exp1;
            solu[trace_num - 1 + leng*(nex_sta_de+indx_j-1)] = num_K + 1;
          }
        }
      }
	}
	
    /*    aft_state = [];
     *    for j2 = 1 : n_std_sta
     *        if max(~isnan(expense(trace_num, [1-n_std_sta : 0] + j2*n_std_sta)))
     *            aft_state = [aft_state, j2];
     *        end
     *    end;
     *    % go back one step to re-arrange the lines.
     */
    len_aft_state = 0;
    for(j2=0; j2 < n_std_sta; j2++){
      numnotnan = 0;
      for(i=0; i < n_std_sta; i++){
        if ( expen_flag != 0 ){
          if( expense[trace_num-1+i*leng+j2*leng*n_std_sta] <=0 )
            numnotnan ++;
        } else {
          if( expense1[trace_num-1+i*leng+j2*leng*n_std_sta] >= 0 )
            numnotnan ++;
        }
      }
      if(numnotnan != 0){
        aft_state[len_aft_state] = j2 + 1;
        len_aft_state++;
      }
    }

    if( len_plot_flag > 0 ){
      mxArray *lhs1[1], *rhs1[4];

      rhs1[0] = mxCreateDoubleMatrix(4, 1, mxREAL);
      ((double *)(mxGetPr(rhs1[0])))[0] = num_state;
      ((double *)(mxGetPr(rhs1[0])))[1] = ii;
      ((double *)(mxGetPr(rhs1[0])))[2] = expen_flag;
      ((double *)(mxGetPr(rhs1[0])))[3] = n_code;
      rhs1[1] = mxCreateDoubleMatrix(1, PowPowM, mxREAL);
      for(i=0; i < PowPowM; i++){
        if(expen_flag != 0){
          if ( expense[trace_num-1 + i*leng] > 0 )
            ((double *)(mxGetPr(rhs1[1])))[i] = mxGetNaN();
          else
            ((double *)(mxGetPr(rhs1[1])))[i] = expense[trace_num-1 + i*leng];
        }else{
          if ( expense1[trace_num-1 + i*leng] < 0 )
            ((double *)(mxGetPr(rhs1[1])))[i] = mxGetNaN();
          else
            ((double *)(mxGetPr(rhs1[1])))[i] = expense1[trace_num-1 + i*leng];
        }
      }
      rhs1[2] = mxCreateDoubleMatrix(1, len_aft_state, mxREAL);
      for(i=0; i < len_aft_state; i++)
        ((double *)(mxGetPr(rhs1[2])))[i] = aft_state[i];
      rhs1[3] = mxCreateDoubleMatrix(1, len_plot_flag, mxREAL);
      for(i=0; i<len_plot_flag; i++)
        ((double *)(mxGetPr(rhs1[3])))[i] = plot_flag[i];
        
      mexCallMATLAB(1, lhs1, 4, rhs1, "vitplot1");

      mxDestroyArray(lhs1[0]);
    }
    /*    sol = expense(trace_num,:);
     *    % decision making.
     *    if i >= leng
     *        trace_eli = rem(trace_num, leng) + 1;
     *        % strike out the unnecessary.
     *        for j_k = 1 : leng - 2
     *            j_pre = rem(trace_num - j_k - 1 + leng, leng) + 1;
     *            sol = vitshort(expense(j_pre, :), sol, n_std_sta, expen_flag);
     *        end;
     *
     *        tmp = (ones(n_std_sta,1) * expense(trace_eli, [starter+1:n_std_sta:PowPowM]))';
     *        sol = sol + tmp(:)';
     */
    if( expen_flag != 0 ){
      for( i=0; i < PowPowM; i++)
        sol[i] = expense[trace_num-1 + i*leng];
    } else {
      for( i=0; i < PowPowM; i++)
        sol1[i] = expense1[trace_num-1 + i*leng];
    }
        
    if( ii >= leng ){
      trace_eli = trace_num % leng + 1;
	  if( expen_flag != 0 ){
        for( i=0; i < PowPowM; i++)
          sol[i] = expense[trace_num-1 + i*leng];
        for( j_k=1; j_k <= leng-2; j_k++){
          j_pre =(trace_num -j_k -1 + leng) % leng + 1;
          for( i=0; i < PowPowM; i++)
            expen_tmp[i] = expense[j_pre-1 + i*leng];
          shortdbl(expen_tmp, sol, n_std_sta, tmpRwork, tmpIwork);
        }
        for(j=0; j < n_std_sta; j++){
          for(i=0; i < n_std_sta; i++){
            if( expense[trace_eli-1+(starter+i*n_std_sta)*leng] > 0 )
              sol[i+j*n_std_sta] = 1;
            else
              sol[i+j*n_std_sta] = sol[i+j*n_std_sta] + expense[trace_eli-1+(starter+i*n_std_sta)*leng];
          }
        }
      } else {
        for( i=0; i < PowPowM; i++)
          sol1[i] = expense1[trace_num-1 + i*leng];
        for( j_k=1; j_k <= leng-2; j_k++){
          j_pre =(trace_num - j_k -1 + leng) % leng + 1;
          for( i=0; i < PowPowM; i++)
            expen_tmp1[i] = expense1[j_pre-1 + i*leng];
          shortint(expen_tmp1, sol1, n_std_sta, tmpIwork);
        }
        for(j=0; j < n_std_sta; j++){
          for(i=0; i < n_std_sta; i++){
            if( expense1[trace_eli-1+(starter+i*n_std_sta)*leng] < 0 )
              sol1[i+j*n_std_sta] = -1;
            else
              sol1[i+j*n_std_sta] = sol1[i+j*n_std_sta] + expense1[trace_eli-1+(starter+i*n_std_sta)*leng];
          }
        }
      }

      /*        if expen_flag
       *            loc_exp =  max(sol(find(~isnan(sol))));   
       *        else
       *            loc_exp =  min(sol(find(~isnan(sol))));
       *        end
       *        dec = find(sol == loc_exp);
       *        dec = dec(1);
       *        dec = rem((dec - 1), n_std_sta);
       *
       *        inp = de2bi(solu(trace_eli, starter*n_std_sta+dec+1)-1, K);
       *        if isempty(C)
       *            tran_indx = starter + 1 + (num_k -1) * n_std_sta;
       *            out = B(tran_indx, :)';
       *        else
       *            cur_sta = cur_sta_pre(starter+1, :)';
       *            out = rem(C * cur_sta + D * inp(:),2);
       *        end;
       */
      if ( expen_flag != 0 ){  /* here, expen_flag != 0 */ 
        for(i=0; i < PowPowM; i++){
          if( sol[i] <= 0 ){
            loc_exp = sol[i];
            i = PowPowM;
          }
        }
        for(i=0; i < PowPowM; i++){
          if( sol[i] <= 0 && loc_exp < sol[i])
            loc_exp = sol[i];
        }
        for(i=0; i < PowPowM; i++){
          if( sol[i] == loc_exp ){
            dec = i;
            i = PowPowM;
          }
        }
        dec = dec % n_std_sta;
      } else {
        for(i=0; i < PowPowM; i++){
          if( sol1[i] >= 0 ){
            loc_exp1 = sol1[i];
            i = PowPowM;
          }
        }
        for(i=0; i < PowPowM; i++){
          if( sol1[i] >= 0 && loc_exp1 > sol1[i])
            loc_exp1 = sol1[i];
        }
        for(i=0; i < PowPowM; i++){
          if( sol1[i] == loc_exp1 ){
            dec = i;
            i = PowPowM;
          }
        }
        dec = dec % n_std_sta;
      }
      num_K = solu[trace_eli-1+leng*(starter*n_std_sta+dec)] - 1;
      de2bi(&num_K, K, one, inp);

      if( len_C == 0 ){
        tran_indx = starter + 1 + num_K*n_std_sta;
        for(i=0; i < N; i++)
          out[i] = B[tran_indx-1+i*(rowFunc-2)];
      } else {
        for(i=0; i < M; i++)
          cur_sta[i] = cur_sta_pre[starter + i*n_std_sta];
        for(i=0; i < N; i++){
          out[i] = 0;
          for(l=0; l < M; l++)
            out[i] = out[i] + C[i+l*N]*cur_sta[l];
          for(l=0; l < K; l++)
            out[i] = out[i] + D[i+l*N]*inp[l];
          out[i] = out[i] % 2;
        }
      }

      /*        msg = [msg; inp];
       *        codd = [codd; out'];
       *        [n_msg, m_msg] = size(msg);
       *        if nargout > 1
       *            if expen_flag
       *                % find the expense by the transfer probability
       *                expen_0 = find(out' <= 0.5);
       *                expen_1 = find(out' > 0.5);
       *                loc_exp = sum([tran_prob(2,expen_work(expen_0)) 0])...
       *                          +sum([tran_prob(3,expen_work(expen_1)) 0]);
       *            else
       *                loc_exp = sum(rem(code(n_msg, :) + out', 2));
       *            end
       *            expen = [expen; loc_exp];
       *        end;
       */
      for( i=0; i < K; i++)
        msg[n_msg+i*n_code] = inp[i];
      n_msg++ ;
      for( i=0; i < N; i++)
        codd[n_codd+i*n_code] = out[i];
      n_codd++ ;

      /* calculate the second output 'expen' */
      if( expen_flag != 0 ){
        lenIndx0= 0;
        for(i=0; i < N; i++){
          if( out[i] <= 0.5 ){
            expenOut[lenIndx0] = i;
            lenIndx0++;
          }
        }
        lenIndx1 = 0;
        for(i=0; i < N; i++){
          if( out[i] > 0.5 ){
            expenOut[lenIndx1+lenIndx0] = i;
            lenIndx1++;
          }
        }
        loc_exp = 0;
        for(i=0; i < lenIndx0; i++)
          loc_exp = loc_exp + tran_prob[1+n_tran_prob*(expen_work[expenOut[i]]-1)];
        for(i=0; i < lenIndx1; i++)
          loc_exp = loc_exp + tran_prob[2+n_tran_prob*(expen_work[expenOut[i+lenIndx0]]-1)];
        expen[len_expen] = loc_exp;
      }else{
        loca_exp1 = 0;
        for(i=0; i < N; i++)
          loca_exp1 = loca_exp1 + ((int)code[n_msg-1+i*n_code] + out[i]) % 2;
        expen[len_expen] = loca_exp1;
      }
      len_expen++;

      if( len_plot_flag > 0 ){
        mxArray *lhs2[1], *rhs2[1];

        rhs2[0] = mxCreateDoubleMatrix(5, 1, mxREAL);
        ((double *)(mxGetPr(rhs2[0])))[0] = n_msg;
        ((double *)(mxGetPr(rhs2[0])))[1] = starter;
        ((double *)(mxGetPr(rhs2[0])))[2] = dec;
        ((double *)(mxGetPr(rhs2[0])))[3] = plot_flag[0];
        ((double *)(mxGetPr(rhs2[0])))[4] = M;

        mexCallMATLAB(1, lhs2, 1, rhs2, "vitplot2");

        mxDestroyArray(lhs2[0]);
      }
      /*        starter = dec;
       *    end; %(if i >= leng)
       *    pre_state = aft_state;
       *    aft_state = [];
       *end;
       */
      starter = dec;
    } /* the end of  (if i >= leng) */
    for( i=0; i < len_aft_state; i++ )
      pre_state[i] = aft_state[i];
    len_pre_state = len_aft_state;  
    len_aft_state = 0;
  }

  /*for i =  1 : leng-1
   *    sol = solution;
   *    trace_eli = rem(trace_num + i, leng) + 1;
   *    if i < leng-1
   *        sol(1:n_std_sta) = expense(trace_num, 1:n_std_sta);
   *        for j_k = 1 : leng - 2 - i
   *            j_pre = rem(trace_num - j_k - 1 + leng, leng) + 1;
   *            sol = vitshort(expense(j_pre, :), sol, n_std_sta, expen_flag);
   *        end;
   *        tmp = (ones(n_std_sta,1) * expense(trace_eli, [starter+1:n_std_sta:PowPowM]))';
   *        sol = sol + tmp(:)';
   *        if expen_flag
   *            loc_exp =  max(sol(find(~isnan(sol))));   
   *        else
   *            loc_exp =  min(sol(find(~isnan(sol))));
   *        end
   *        dec = find(sol == loc_exp);
   *        dec = dec(1);
   *        dec = rem((dec - 1), n_std_sta);
   *    else
   *        dec = 0;
   *    end;
   */
  for(ii=1; ii <= leng-1; ii++){
    if( expen_flag != 0 ){        /* here, expen_flag != 0 */ 
      for(i=0; i < PowPowM; i++)
        sol[i] = solution[i];
    } else {    
      for(i=0; i < PowPowM; i++)
        sol1[i] = solution1[i];
    }
    trace_eli = (trace_num + ii) % leng + 1;

    if( ii < leng-1 ){
      if( expen_flag != 0 ){        /* here, expen_flag != 0 */ 
        for(i=0; i < n_std_sta; i++)
          sol[i] = expense[trace_num-1 + i*leng];
        for(j_k=1; j_k <= leng-2-ii; j_k++){
          j_pre = (trace_num - j_k - 1 + leng) % leng + 1;  
          for( i=0; i < PowPowM; i++)
            expen_tmp[i] = expense[j_pre-1 + i*leng];
          shortdbl(expen_tmp, sol, n_std_sta, tmpRwork, tmpIwork);
        }
        for(j=0; j < n_std_sta; j++){
          for(i=0; i < n_std_sta; i++){
            if( expense[trace_eli-1+(starter+i*n_std_sta)*leng] > 0 || sol[i+j*n_std_sta] > 0 )
              sol[i+j*n_std_sta] = 1;
            else
              sol[i+j*n_std_sta] = sol[i+j*n_std_sta] + expense[trace_eli-1+(starter+i*n_std_sta)*leng];
          }
        }
        for(i=0; i < PowPowM; i++){
          if( sol[i] <= 0 ){
            loc_exp = sol[i];
            i = PowPowM;
          }
        }
        for(i=0; i < PowPowM; i++){
          if( sol[i] <= 0 && loc_exp < sol[i])
            loc_exp = sol[i];
        }
        for(i=0; i < PowPowM; i++){
          if( sol[i] == loc_exp ){
            dec = i;
            i = PowPowM;
          }
        }
      } else {
        for(i=0; i < n_std_sta; i++)
          sol1[i] = expense1[trace_num-1 + i*leng];
        for(j_k=1; j_k <= leng-2-ii; j_k++){
          j_pre = (trace_num - j_k - 1 + leng) % leng + 1;  
          for( i=0; i < PowPowM; i++)
            expen_tmp1[i] = expense1[j_pre-1 + i*leng];
          shortint(expen_tmp1, sol1, n_std_sta, tmpIwork);
        }
        for(j=0; j < n_std_sta; j++){
          for(i=0; i < n_std_sta; i++){
            if( expense1[trace_eli-1+(starter+i*n_std_sta)*leng] < 0 || sol1[i+j*n_std_sta] < 0)
              sol1[i+j*n_std_sta] = -1;
            else
              sol1[i+j*n_std_sta] = sol1[i+j*n_std_sta] + expense1[trace_eli-1+(starter+i*n_std_sta)*leng];
          }
        }
        
        for(i=0; i < PowPowM; i++){
          if( sol1[i] >= 0 ){
            loc_exp1 = sol1[i];
            i = PowPowM;
          }
        }
        for(i=0; i < PowPowM; i++){
          if( sol1[i] >= 0 && loc_exp1 > sol1[i])
            loc_exp1 = sol1[i];
        }
        for(i=0; i < PowPowM; i++){
          if( sol1[i] == loc_exp1 ){
            dec = i;
            i = PowPowM;
          }
        }
      }
      dec = dec % n_std_sta;
    } else {
      dec = 0;
	} /* end -- if( ii < leng-1 ) */

    /*    inp = de2bi(solu(trace_eli, starter*n_std_sta+dec+1)-1, K);
     *    cur_sta = de2bi(starter, num_state);
     *    out = rem(C*cur_sta' + D * inp', 2);
     *    msg = [msg; inp];
     *    codd = [codd; out'];
     *    [n_msg, m_msg] = size(msg);
     */
    num_K = solu[trace_eli-1+leng*(starter*n_std_sta+dec)] - 1;
    de2bi(&num_K, K, one, inp);
    de2bi(&starter, num_state, one, cur_sta);

    if( len_C == 0 ){
      tran_indx = starter + 1 + num_K*n_std_sta;
      for(i=0; i < N; i++)
        out[i] = B[tran_indx-1+i*(rowFunc-2)];
    } else {
      for(i=0; i < N; i++){
        out[i] = 0;
        for(l=0; l < M; l++)
          out[i] = out[i] + C[i+l*N]*cur_sta[l];
        for(l=0; l < K; l++)
          out[i] = out[i] + D[i+l*N]*inp[l];
        out[i] = out[i] % 2;
      }
    }
    for( i=0; i < K; i++)
      msg[n_msg+i*n_code] = inp[i];
    n_msg++ ;
    for( i=0; i < N; i++)
      codd[n_codd+i*n_code] = out[i];
    n_codd++ ;

    /*    if nargout > 1
     *        if expen_flag
     *            % find the expense by the transfer probability
     *            expen_0 = find(out' <= 0.5);
     *            expen_1 = find(out' > 0.5);
     *            loc_exp = sum([tran_prob(2,expen_work(expen_0)) 0])...
     *                      +sum([tran_prob(3,expen_work(expen_1)) 0]);
     *        else
     *            loc_exp = sum(rem(code(n_msg, :) + out', 2));
     *        end
     *        expen = [expen; loc_exp];
     *    end;
     */
    if(expen_flag != 0){
      lenIndx0= 0;
      for(i=0; i < N; i++){
        if( out[i] <= 0.5 ){
          expenOut[lenIndx0] = i;
          lenIndx0++;
        }
      }
      lenIndx1 = 0;
      for(i=0; i < N; i++){
        if( out[i] > 0.5 ){
          expenOut[lenIndx1+lenIndx0] = i;
          lenIndx1++;
        }
      }
      loc_exp = 0;
      for(i=0; i < lenIndx0; i++)
        loc_exp = loc_exp + tran_prob[1+n_tran_prob*(expen_work[expenOut[i]]-1)];
      for(i=0; i < lenIndx1; i++)
        loc_exp = loc_exp + tran_prob[2+n_tran_prob*(expen_work[expenOut[i+lenIndx0]]-1)];
      expen[len_expen] = loc_exp;
      len_expen ++;
    } else {
      loca_exp1 = 0;
      for(i=0; i < N; i++)
        loca_exp1 = loca_exp1 + ((int)code[n_msg-1 + i*n_code] + out[i]) % 2;
      expen[len_expen] = loca_exp1;
      len_expen ++;
    }

    if( len_plot_flag > 0 ){
      mxArray *lhs2[1], *rhs2[1];

      rhs2[0] = mxCreateDoubleMatrix(5, 1, mxREAL);
      ((double *)(mxGetPr(rhs2[0])))[0] = n_msg;
      ((double *)(mxGetPr(rhs2[0])))[1] = starter;
      ((double *)(mxGetPr(rhs2[0])))[2] = dec;
      ((double *)(mxGetPr(rhs2[0])))[3] = plot_flag[0];
      ((double *)(mxGetPr(rhs2[0])))[4] = M;
        
      mexCallMATLAB(1, lhs2, 1, rhs2, "vitplot2");

      mxDestroyArray(lhs2[0]);
    }
    /*    starter = dec;
     *end;
     */
    starter = dec;
  }

  /*% cut the extra message length
   *[n_msg, m_msg] = size(msg);
   *msg(n_msg-M+1:n_msg, :) = [];
   *if plot_flag(1)
   *    set(xx,'Color',[0 1 1]);
   * hold off
   *end;
   *% end of VITERBI.M
   */
  mxSetM(plhs[0], n_msg-M);
  mxSetN(plhs[0], K);
  p_v5_out = (double *)mxCalloc(K*(n_msg-M), sizeof(double));
  p_v5_out = mxGetPr(plhs[0]);
  for(i=0; i < n_msg-M; i++){
    for(j=0; j < K; j++)
      p_v5_out[i + j*(n_msg-M)] = msg[i + j*n_code];
  }
  return;
}
/*--end of VITERBI.C --*/
     
