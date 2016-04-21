/* $Revision: 1.11 $ */
/*-------------------------------------------------------------------
 * This is a library file for vitcore.c
 * Jun Wu
 * Mar-01, 1996
 * Copyright 1996-2002 The MathWorks, Inc.
 *------------------------------------------------------------------*/

#define Prim 2
static void de2bi(int *pde, int dim, int pow_dim, int *pbi)
{
  int     i,j, tmp;

  if( pde[0] < 0 ){
      /* the first part is for converting the decimal numbers(from 0 to pow_dim)
       * to binary.
       */ 
 
    for(i=0; i < pow_dim; i++){
      tmp = i;
      for(j=0; j < dim; j++){
        pbi[i+j*pow_dim] = tmp % Prim;
        if(j < dim-1)
          tmp = (int)(tmp/Prim);
      }
    }
  }else{
    /* the second part is for converting the decimal numbers(setting by user)
     * to binary.
     */  
    for(i=0; i < pow_dim; i++){
      tmp = pde[i];
      for(j=0; j < dim; j++){
        pbi[i+j*pow_dim] = tmp % Prim;
        if(j < dim-1)
          tmp = (int)(tmp/Prim);
      }
    }
  }
}
static void bi2de(int *pbi, int pow_dim, int dim, int *pde)
{
  int     i, j, k;
  
  for(i=0; i<pow_dim; i++)
    pde[i] = 0;
  
  for (i=0; i < pow_dim; i++){
    for (j=0; j < dim; j++){
      if (pbi[i+j*pow_dim] != 0){
        if(j > 0){
          for (k=0; k < j; k++)
            pbi[i+j*pow_dim] = pbi[i+j*pow_dim]*Prim;
        }
      }
      pde[i] = pde[i] + (int)pbi[i+j*pow_dim];
    }
  }
}
/*
 * See also vitshort.c and vitshort.m for the two functions following.
 */
static void shortdbl(double *expense, double *sol, int n_std_sta, double *Rwork, int *Iwork)
{        
  int     i, j, k, PowPowM, aft_indx, len_indx, len, indx;
  int     *wei_indx, *sub_indx;
  double  max;
  double  *wei_mat_exp, *wei_sum, *sol_tmp;
  double  wei_mat_sol;    
  
  wei_mat_exp = Rwork;
  wei_sum     = Rwork + n_std_sta;
  sol_tmp     = Rwork + 2*n_std_sta;
  wei_indx    = Iwork;
  sub_indx    = Iwork + n_std_sta;
  
  PowPowM = n_std_sta * n_std_sta;
  for(i=0; i < PowPowM; i++)
    sol_tmp[i] = sol[i];
  for(i=1; i <= n_std_sta; i++){
    aft_indx = i * n_std_sta - n_std_sta;
    for(j=1; j <= n_std_sta; j++){
      for(k=0; k < n_std_sta; k++)
        wei_mat_exp[k] = expense[k * n_std_sta + j - 1];
      len_indx = 0;
      for(k=0; k < n_std_sta; k++){
        wei_mat_sol = sol_tmp[aft_indx + k];
        if ( wei_mat_exp[k] > 0 || wei_mat_sol > 0 ) {
          wei_sum[k] = 1;
	    }else{
          wei_sum[k] = wei_mat_exp[k] + wei_mat_sol;
          wei_indx[len_indx] = k;
          len_indx++;
	    }
      }
      
      if (len_indx > 0) {
        len = 0;
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
          max = wei_mat_exp[sub_indx[0]];
          k = 1;
          while(k < len){
            if( max < wei_mat_exp[sub_indx[k]] ) {
              max = wei_mat_exp[sub_indx[k]];
              indx = sub_indx[k];
            }
            k++;
          }
        }
        sol[aft_indx + j - 1] = wei_sum[indx];
      }else{
        sol[aft_indx + j - 1] = 1;
      }
    }
  }
}
static void shortint(int *expense, int *sol, int n_std_sta, int *Iwork)
{
  int     i, j, k, PowPowM, aft_indx, len_indx, len, indx;
  int     min;
  int     wei_mat_sol;    
  int     *wei_mat_exp, *wei_sum, *sol_tmp, *wei_indx, *sub_indx;
  
  wei_mat_exp = Iwork; 
  wei_sum     = Iwork + n_std_sta;
  wei_indx    = Iwork + 2*n_std_sta;
  sub_indx    = Iwork + 3*n_std_sta;
  sol_tmp     = Iwork + 4*n_std_sta;
  
  PowPowM = n_std_sta * n_std_sta;
  for(i=0; i < PowPowM; i++)
    sol_tmp[i] = sol[i];
  for(i=1; i <= n_std_sta; i++){
    aft_indx = i * n_std_sta - n_std_sta;
    for(j=1; j <= n_std_sta; j++){
      for(k=0; k < n_std_sta; k++)
	    wei_mat_exp[k] =expense[k * n_std_sta + j - 1];
      len_indx = 0;
      for(k=0; k < n_std_sta; k++){                
	    wei_mat_sol = sol_tmp[aft_indx + k];
	    if ( wei_mat_exp[k] < 0 || wei_mat_sol < 0 ) {
	       wei_sum[k] = -1;
	    }else{
	       wei_sum[k] = wei_mat_exp[k] + wei_mat_sol;
	       wei_indx[len_indx] = k;
	       len_indx++;
	    }
      }
      
      if (len_indx > 0) {
	     len = 0;
	     min = wei_sum[wei_indx[0]];
	     sub_indx[0] = wei_indx[0];                    
	     k = 1;
	     while (k < len_indx) {
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
	     if (len > 1){
	       min = wei_mat_exp[sub_indx[0]];
	       k = 1;
	       while(k < len){
	         if( min > wei_mat_exp[sub_indx[k]] ) {
	           min = wei_mat_exp[sub_indx[k]];
	           indx = sub_indx[k];
	         }
	         k++;
	       }
	     }
	     sol[aft_indx + j - 1] = wei_sum[indx];
      }else{
	     sol[aft_indx + j - 1] = -1;
      }
    }
  }
}
/* the end of vitlib.c */
