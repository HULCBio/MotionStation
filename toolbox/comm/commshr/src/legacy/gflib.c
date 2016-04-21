/*
 * gflib.c: Galois Field library file which includes:
 *
 *   void bi2de(*pbi, np, mp, prim, *pde)
 *
 *   void fliplr(*pa, col_a, row_a)
 *    M_FILE: Y = FLIPLR(X)
 *    flips matrix in the left to right direction.
 *
 *   void pNumInv(*pp, np, mp, prim, *pNum, *pInv)
 *    M_CODE: tp_num = tp * prim.^[0 : tp_m-1]'; -- vector pNum
 *            tp_inv(tp_num+1) = 0:pow_dim; -- vector pInv
 *
 *   int_T isprime(p) 
 *    M_FILE: ISP = ISPRIME(X) 
 *    return TRUE for prime numbers.
 *
 *   void gfargchk(double *pa, ma, na, double *pb, mb, nb, double *p,
 *                  mp, np)
 *
 *   void gftrunc(*pa, *len_a, len_p)
 *    M_FILE: C = GFTRUNC(A)
 *    truncates the results of every GF's computation.
 *
 *   void gffilter(*pb, len_b, *pa, len_a, *px, len_x, p, *pOut)
 *    M_FILE: Y = GFFILTER(B,A,X,P)
 *    filters the data in GF(P).
 *
 *   void gfpadd(*pa, len_a, *pb, len_b, *pp, np, mp, *pc, *nc, *Iwork)
 *    M_FILE: C = GFADD(A,B,FIELD)
 *    computes A adds B in GF(P^M) when FIELD is a matrix, for extension
 *    fields.
 *
 *   void gfadd(*pa, len_a, *pb, len_b, pp, len, *pc, *nc)
 *    M_FILE: C = GFADD(A,B,P,LEN)
 *    computes A adds B in GF(P) when P is a scalar prime.
 *
 *   void gfplus(*pi, mi, ni, *pj, mj, nj, *alpha, len_alpha, *beta,
 *                len_beta, *pk)
 *    M_FILE: C = GFPLUS(A,B,ALPHA,BETA) 
 *    Galois Field addition (vectorized).
 *
 *   void gfminus(*pa, *pb, *pp, mp, np, *pc, *Iwork)
 *    Subtract B from A when P is a matrix, scalar inputs only.
 *    Used by gfpdeconv(). Can be vectorized if needed.
 * 
 *   void gfpmul(*pa, len_a, *pb, len_b, *pp, np, mp, *pc, *nc, *Iwork)
 *    M_FILE: C = GFMUL(A,B,FIELD)
 *    computes A multiply B in GF(P^M) when FIELD is a matrix, for 
 *    extension fields.
 *
 *   void gfmul(*pa, len_a, *pb, len_b, pp, *pc)
 *    M_FILE: C = GFMUL(A,B,P)
 *    computes A multiply B in GF(P) when P is a scalar prime.
 *
 *   void gfconv(*pa, len_a, *pb, len_b, pp, *pc, *Iwork)
 *    M_FILE: C = GFCONV(A,B,P)
 *    computes the convolution between two GF(P) polynomials when P is
 *    a scalar prime.
 *
 *   void gfpconv(*pa, len_a, *pb, len_b, *pp, np, mp, *pc, *Iwork)
 *    M_FILE: C = GFCONV(A,B,FIELD)
 *    computes the convolution between two GF(P^M) polynomials 
 *    when FIELD is a matrix, for extension fields. 
 *
 *   void gfdeconv(*pb, len_b, *pa, len_a, pp, *pq, len_q, *pr, *len_r,
 *                 *Iwork)
 *    M_FILE: [Q, R] = GFDECONV(B,A,P)
 *    computes the deconvolution between two GF(P) polynomials when P
 *    is a scalar prime.
 *
 *   void gfpdeconv(*pb, len_b, *pa, len_a, *pp, np, mp, *pq, *pr,
 *                  *len_r, *Iwork)
 *    M_FILE: [Q, R] = GFDECONV(B,A,FIELD)
 *    computes the deconvolution between two GF(P^M) polynomials when
 *    P is a matrix, for extension fields. 
 *
 *   void flxor(*px, mx, nx, *py, my, ny, *pz, *mz, *nz)  
 *    M_FILE: Z = FLXOR(X,Y) 
 *    exclusive OR computation.
 *
 *   void errlocp1(*syndr,t,*pNum,*pInv,pow_dim,err_In,*Iwork,
 *                 *sigma_Out ,*len_Out)
 *    M_FILE: [SIGMA, ERR] = ERRLOCP(SYNDROME,T,TP,POW_DIM,ERR,1);
 *
 *   void errlocp0(*syndr,t,*pNum,*pInv,pow_dim,err_In,*Iwork,
 *                 *sigma_Out, *len_Out)
 *    M_FILE: [SIGMA, ERR] = ERRLOCP(SYNDROME,T,TP,POW_DIM,ERR,0);
 *
 *   void bchcore(*code,pow_dim,dim,k,t,*pp,*Iwork,*msg,*err,*ccode)
 *    M_FILE: [SIGMA, ERR, CCODE] = BCHCORE(CODE,POW_DIM,DIM,K,T,P);
 *
 *   void rscore(*code,k,*pp,dim,pow_dim,*Iwork,*msg,*err,*ccode)
 *    M_FILE: [SIGMA, ERR, CCODE] = RSCORE(CODE,K,P,DIM,POW_DIM);
 *
 *      All parameters in these functions are integer types except
 *    where explicitly stated.
 *
 *  Copyright 1996-2002 The MathWorks, Inc.
 *  $Revision: 1.5 $ $Date: 2002/03/27 00:23:04 $ 
 */

#include "gflib.h"

/* bi2de() */
void bi2de(int_T *pbi, int_T np, int_T mp, int_T prim, int_T *pde)
{
    int_T     i, j, k, tmp;
    
    for(i=0; i<np; i++)
		pde[i] = 0;
	
    for (i=0; i<np; i++){
		for (j=0; j<mp; j++){
			if (pbi[i + j*np]) {
                tmp = 1;
                k = 0;
                while(k < j) {
					tmp = tmp * prim;
					k++;
				}
                pde[i] += pbi[i+j*np] * tmp;
			}
		}
    }
}
/* end bi2de() */

/* fliplr() */
void fliplr(int_T *pa, int_T col_a, int_T row_a)
{
    int_T i, j, tmp;
    
    if (row_a <= 1) {
		for (i=0; i<col_a/2; i++) {
			tmp = pa[i];
			pa[i] = pa[col_a - 1 - i];
			pa[col_a - 1 - i] = tmp;
		}
    } else {
		int_T nearr, farr;
		
		for (j=0; j<row_a; j++) {
			for (i=0; i<col_a/2; i++) {
				nearr = i * row_a + j;
				farr  = (col_a - 1 - i) * row_a + j;
				tmp = pa[nearr];
				pa[nearr] = pa[farr];
				pa[farr] = tmp;
			}
		}
    }
}
/* end fliplr() */

/* pNumInv() */
void pNumInv(int_T *p, int_T np, int_T mp, int_T prim, int_T *pNum, int_T *pInv)
{
    int_T i;
    
    bi2de(p, np, mp, prim, pNum);
    for (i=0; i<np; i++)
		pInv[pNum[i]] = i;
}
/* end pNumInv() */

/* isprime() */
int_T isprime(int_T p)
{
    int_T i;
    
	if(p == 2) return 1;
	
	if(p%2 == 0) return 0;
	
    for (i=3; i<sqrt(p)+1; i+=2){
		if(p%i == 0) return 0;
    }
	
    return(1);
}
/* end isprime() */

/* gfargchk() Validates the inputs. 
 * The function validates the field entry (scalar or matrix) and the inputs
 * A and B based on the field parameter.
 */
void gfargchk(double *pa, int_T ma, int_T na, double *pb, int_T mb, int_T nb, double *p, int_T mp, int_T np)
{    
#ifdef MATLAB_MEX_FILE

    int_T len_a, len_b, len_p, i, j, k;
    
    len_a = ma*na;
    len_b = mb*nb;
    len_p = mp*np;
    
    if (len_p == 1){ /* GF(P) */

        /* Check for P */
        if ( p[0] != floor(p[0]) || p[0] < 2.0 || (!isprime((int_T)p[0])) )
                mexErrMsgTxt("The field parameter must be a positive prime integer.");

        /* Check for A, B */
	    for (i=0; i < len_a; i++){
	        if (pa[i] < 0 || pa[i] != floor(pa[i]) || pa[i] >= p[0] ) {
	            if (p[0]==2){
    	            mexErrMsgTxt("The input elements must be binary.");
                } else {
	                mexErrMsgTxt("The input elements must be between 0 and P-1.");
                }
            }
	    }
	    for (i=0; i < len_b; i++){
	        if (pb[i] < 0 || pb[i] != floor(pb[i]) || pb[i] >= p[0]) {
	            if (p[0]==2) {
    	            mexErrMsgTxt("The input elements must be binary.");
                } else {
    	            mexErrMsgTxt("The input elements must be between 0 and P-1.");
                }
            }
	    }

    } else { /* GF(P^M) */
    
    	int_T actually_is, should_be, flag, prim;
    
        /* Checks for the FIELD matrix */

        /* Verify that FIELD elements are positive integers */
        for ( i = 0; i < len_p; i++) {
		    if( (p[i] < 0) || (floor(p[i]) != p[i]) )
			    mexErrMsgTxt("The field parameter values must be positive integers.");
	    }

		/* Verify that FIELD is based on a prime element */
        prim = -1;
		for ( i = 1; i < len_p; i++){
			if(prim < p[i])
				prim = (int_T)p[i];
		}
		prim++;
		if(!isprime(prim))
			mexErrMsgTxt("Field parameter is not valid. See GFTUPLE.");

		/* Verify that FIELD is of a valid size */
        /* pow(int_T,int_T) should return an floating int_T, but some implementations may cause
         * rounding errors (as seen on Hp700).
         */
        if ( ((int_T)pow(prim,np)) != mp )
			mexErrMsgTxt("Field parameter is not valid. See GFTUPLE.");

		/* Verify that the first row of FIELD is all zeros. */
		for (i=0; i < len_p ; i = i + mp) {	/* Cycle through 1st row. */
			if ( p[i] != 0 )
				mexErrMsgTxt("Field parameter is not valid. See GFTUPLE.");
		}

		/* Verify that the next np rows form identity matrix. */
		for (i=1; i <= np ; i++) {		/* Cycle through each column. */
			for (j=1; j <= np ; j++) {	/* Cycle from 2nd thru (n_p+1)th row. */
				if ( i == j ) {
					if ( p[(i-1)*mp+j] != 1 )
						mexErrMsgTxt("Field parameter is not valid. See GFTUPLE.");
				} else {
					if ( p[(i-1)*mp+j] != 0 )
						mexErrMsgTxt("Field parameter is not valid. See GFTUPLE.");
				}
			}
		}
		/* Cycle through all remaining rows. */
		for (i=np+1; i < mp ; i++) {

			/* Verify that all subsequent rows are formed from a primitive polynomial. */
			for (j=0; j < len_p ; j = j + mp) { /* Cycle through each column. */

				/* Get the current value in FIELD. */
				actually_is = (int_T)p[i+j];

				/* Calculate what the current value in FIELD should be based on the
				 * previous row and the primitive polynomial:
				 * p[ np+1+j ] : the corresponding element from the primitive polynomial row.
				 * p[ (i-1) + (len_p-mp) ] : the 'spill over' element from the previous row.
				 * p[ (i+j)-(mp+1) ] : the element, less one order, from the previous row. */ 
				
				should_be = (int_T) (p[ np+1+j ] * p[ (i-1) + (len_p-mp) ]);
				if ( j > 0 )
					should_be = should_be + (int_T) p[ (i+j)-(mp+1) ];
				should_be = should_be % prim;

				if ( actually_is != should_be )
					mexErrMsgTxt("Field parameter is not valid. See GFTUPLE.");
			}

			/* Verify that no rows are duplicates. */
			for (k = i-1; k >= 0 ; k--) {	/* Cycle through all rows above the current row. */
				flag = 1;
				j = 0;
				while ( ( flag == 1 ) && ( j < len_p ) ) {	/* Cycle through each column until */
	            											/* differing pairs are found. */
					if ( p[i+j] != p[k+j] )
						flag = 0;
					j = j + mp;
				}
				if ( flag == 1 )
					mexErrMsgTxt("Field parameter is not valid. See GFTUPLE.");
			}
		}

		/* Checks the input polynomials. */
		for (i=0; i < len_a; i++){
			if ( (pa[i] > mp-2) || (pa[i]!= floor(pa[i])) )
				mexErrMsgTxt("The input elements must be integers between -Inf and P^M-2 over an extension field.");
		}
		for (i=0; i < len_b; i++){
			if ( (pb[i] > mp-2) || (pb[i]!= floor(pb[i])) )
				mexErrMsgTxt("The input elements must be integers between -Inf and P^M-2 over an extension field.");
		}
    }
#endif

}
/* end gfargchk() */

/* gffilter() */
void gffilter(int_T *pb, int_T len_b, int_T *pa, int_T len_a, int_T *px, int_T len_x, int_T p, int_T *pOut)
{
    int_T  i, j, q, tmp_a;
	
	for(i=0; i < len_x; i++)
		pOut[i] = 0;
	
	q = 1;
    if (pa[0] == 0){
#ifdef MATLAB_MEX_FILE
		mexErrMsgTxt("First denominator filter coefficient must be non-zero.");
#endif
    } else if (pa[0] != 1){
		tmp_a = 0;
		while (tmp_a < p-2) {
			q = (q*pa[0]) % p;
			tmp_a++;
		}
    }

	for (i=0; i < len_x; i++){
		for (j=0; j<len_b; j++){
			if (i-j >= 0)
				pOut[i] += pb[j]*px[i-j];
		}
		if (len_a > 1){
			for (j=1; j<len_a; j++){
				if (i-j >= 0)
					pOut[i] -= pa[j]*pOut[i-j];
			}
		}
		pOut[i] = ((q*pOut[i]) % p);
		if (pOut[i]<0)
			pOut[i] += p;
	}
}
/* end gffilter() */

/* gftrunc() */
void gftrunc(int_T *pa, int_T *len_a, int_T len_p)
{
    int_T     i, ind;
    bool    decimal_coeffs;
    
    if (len_p > 1){
		decimal_coeffs = 0;
    } else {
		decimal_coeffs = 1;
    }
    		
    /*
     *  This function simply finds the proper length to which the input
     *  vector should be truncated and stores the value in len_a[0]
     */	
    ind = -1;
    if ( decimal_coeffs){  /* decimal representation, find positive values */   
		for (i=0; i < len_a[0]; i++){
			if ( pa[i] != 0 ) ind = i;
		}
    } else {     /* power representation, find non-negative values */                   
		for (i=0; i < len_a[0]; i++){  
			if ( pa[i] >= 0 ) ind = i;
		}
    }
    /*
     *  The value of ind is one less than the number of elements to be
     *  preserved.  If the value of ind is -1, then return a scalar zero value
     */	
    if (ind >= 0){
		len_a[0] = ind + 1;
    } else {
		if(decimal_coeffs){
			pa[0] = 0;
		} else {
			pa[0] = -Inf;		
        }
		len_a[0] = 1;
	}
}
/* end gftrunc() */

/* gfpadd() adds two GF(P^M) polynomials when P is a matrix.
 *      Iwork --- nc+nc*mp+np
 *      Iwork = indx
 *          + *nc = tmp
 *              + (*nc)*mp = sum
 *                  + np = bottom of Iwork
 */
void gfpadd(int_T *pa, int_T len_a, int_T *pb, int_T len_b, int_T *pp, int_T np, int_T mp, int_T *pc, int_T *nc, int_T *Iwork)
{
    int_T     prim, cal_len;
    int_T     i, j, k, minus_a, minus_b, len_indx;
    int_T     *indx, *tmp, *sum;
    
    indx = Iwork;
    tmp = indx + nc[0];
    sum = tmp + nc[0]*mp;

    /* GF(Q^M) field calculation.
	 * The first row of P is -Inf, second is 1 and so on.
	 */
	/*  handle vector case
	*    indx = find(a > n_p - 2);
	*    if ~isempty(indx)
	*        a(indx) = rem(a(indx), n_p - 1);
	*    end;
	*    indx = find(b > n_p - 2);
	*    if ~isempty(indx)
	*        b(indx) = rem(b(indx), n_p - 1);
	*    end;
	*/
    for(i=0; i<len_a; i++){
		if(pa[i] > np-2)
			pa[i] = pa[i] % (np - 1);    
    }
    for(i=0; i < len_b; i++){
		if(pb[i] > np-2)
			pb[i] = pb[i] % (np - 1);
    }
    /*    if (a < 0)
	*        c = b;
	*    elseif (b < 0)
	*        c = a;
	*    else
	*/
    minus_a = 0;
    minus_b = 0;
    for(i=0; i < len_a; i++){                 
		if(pa[i] < 0)                         
			minus_a++;                                          
    }
    for(i=0; i < len_b; i++){             
		if(pb[i] < 0)
			minus_b++;
    }
    if( minus_a == len_a ){
		nc[0] = len_b;
		for(i=0; i < len_b; i++)
			pc[i] = pb[i];
    } else if(minus_b == len_b){
		nc[0] = len_a;
		for(i=0; i < len_a; i++)
			pc[i] = pa[i];
    } else {
   /*        prim = max(max(p)) + 1;
	*        indx = find(~(a >= 0));
	*        a(indx) = - ones(1, length(indx));
	*        indx = find(~(b >= 0));
	*        b(indx) = - ones(1, length(indx));
	*        len_a = length(a);
	*        len_b = length(b);
		*/
		prim = 0;
		for(i=0; i < np*mp; i++){
			if(prim <= pp[i])                              
				prim = pp[i] + 1;           
		}
		
		for(i=0; i < len_a; i++){
			if(pa[i] < 0)
				pa[i] = -1;
		}
		for(i=0; i < len_b; i++){
			if(pb[i] < 0)
				pb[i] = -1;
		}
		/*        if (len_a == len_b) 
		*            tmp = rem(p(a + 2, :) + p(b + 2, :), prim);
		*            cal_len = len_a;
		*        elseif  (len_a == 1)
		*            tmp = rem(ones(len_b,1)*p(a + 2, :) + p(b + 2, :), prim);
		*            cal_len = len_b;
		*        elseif  (len_b == 1)
		*            tmp = rem(p(a + 2, :) + ones(len_a, 1)*p(b + 2, :), prim);
		*            cal_len = len_a;
		*        else
		*            cal_len = min(len_a, len_b);
		*            tmp = rem(p(a(1:cal_len) + 2, :) + p(b(1:cal_len) + 2, :), prim);
		*        end;
		*/
		if( len_a == len_b && len_a != 1){
			for(i=0; i < len_a; i++){
				for(j=0; j < mp; j++){
					tmp[i+j*nc[0]] = (pp[j*np+pa[i]+1] + pp[j*np+pb[i]+1]) % prim;
					cal_len = len_a;
				}
			}
		}else if( len_a ==1 && len_b != 1){
			for(i=0; i < len_b; i++){   
				for(j=0; j < mp; j++){ 
					tmp[i+j*nc[0]] = (pp[j*np+pa[0]+1]+pp[j*np+pb[i]+1]) % prim;
					cal_len = len_b;
				}
			}
		}else if(len_b == 1 && len_a != 1){
			for(i=0; i < len_a; i++){
				for(j=0; j < mp; j++){
					tmp[i+j*nc[0]] = (pp[j*np+pa[i]+1]+pp[j*np+pb[0]+1]) % prim;
					cal_len = len_a;             
				}
			}
		}else if( len_b == len_a && len_a == 1){
			for(j=0; j < mp; j++){
				tmp[j*nc[0]] = (pp[j*np+pa[0]+1]+pp[j*np+pb[0]+1]) % prim;
				cal_len = 1;
			}
		}else{
			if (len_a >= len_b)
				cal_len = len_b;                
			else
				cal_len = len_a;
			for(i=0; i < cal_len; i++){
				for(j=0; j < mp; j++)                   
					tmp[i+j*nc[0]] =(pp[j*np+pa[i] + 1] + pp[j*np + pb[i] + 1]) % prim;
			}
		}
		for(i=0; i < cal_len; i++){
			len_indx = 0;
			for(j=0; j < np; j++){
				sum[j] = 0;
				for(k=0; k < mp; k++){
				    if ((pp[j+k*np]+prim-tmp[i+k*nc[0]]) % prim>0){
				        sum[j] = 1;
				        break;
				    }
				}
								
				if( sum[j]==0 ){
					indx[len_indx] = j;
					len_indx++;
					break;
				}
			}
			if (len_indx == 1){
				pc[i] = indx[0] - 1;
			} else {
#ifdef MATLAB_MEX_FILE
				if( len_indx == 0 )
					mexWarnMsgTxt("The list of Galois field is not a complete one.");
				else
					mexWarnMsgTxt("The list of Galois field has a repeated element.");
#endif
			}
		}
		if( cal_len < len_a ){
			for(i=0; i<cal_len; i++)                
				pc[i] = pc[i];
			for(i=cal_len; i < len_a; i++)
				pc[i] = pa[i];
		}else if(cal_len < len_b){
			for(i=0; i<cal_len; i++)
				pc[i] = pc[i];                      
			for(i=cal_len; i < len_b; i++)
				pc[i] = pb[i];                      
		}
    }
    /*    indx = find(c < 0);
	*    if ~isempty(indx)
	*        c(indx) = indx - Inf;
	*    end;
	*    c = c(:)';
	*    if cal_len < len_a
	*        c = [c a(cal_len + 1 : len_a)];
	*    elseif cal_len < len_b
	*        c = [c b(cal_len + 1 : len_b)];
	*    end;
	*end;
	*/
    for(i=0; i < nc[0]; i++){
		if( pc[i] < 0 )
			pc[i] = -Inf;
    }
}
/* end gfpadd() */

/*
 * gfadd() adds two GF(P) polynomials. 
 *  gfadd(a, b, p) adds two polynomials A and B in GF(P) when P is a scalar
 *  prime number.
 */
void gfadd(int_T *pa, int_T len_a, int_T *pb, int_T len_b, int_T *pc, int_T len_c, int_T pp)
{
    int_T i;
    
    if (len_a > len_b){
		for (i=0; i < len_b; i++)    pc[i] = (pa[i]+pb[i]) % pp;
		for (i=len_b; i <len_a; i++) pc[i] = pa[i];
    } else if (len_b > len_a){
		for (i=0; i < len_a; i++)    pc[i] = (pa[i]+pb[i]) % pp;       
		for (i=len_a; i <len_b; i++) pc[i] = pb[i];
    } else {
		for(i=0; i < len_a;  i++)    pc[i] = (pa[i]+pb[i]) % pp;
    }
	
}
/* end gfadd() */

/* gfplus() Galois Field addition (vectorized) */
void gfplus(int_T *pi, int_T mi, int_T ni, int_T *pj, int_T mj, int_T nj, int_T *alpha, int_T len_alpha, int_T *beta, int_T len_beta, int_T *pk)
{
	int_T     i, r, inci, incj, indi, indj, len_k;
	
	len_alpha = len_alpha - 1;
	if ((mi == 1) && (ni == 1) && (mj == 1) && (nj == 1)) {
		len_k = 1;
		inci = 0;
		incj = 0;
	} else if ((mi == mj) && (ni == nj)) {
		len_k = mi*ni;
		inci = 1;
		incj = 1;
	} else if ((mj == 1) && (nj == 1)) {
		len_k = mi*ni;
		inci = 1;
		incj = 0;
	} else if ((mi == 1) && (ni == 1)) {
		len_k = mj*nj;
		inci = 0;
		incj = 1;
	} else {
#ifdef MATLAB_MEX_FILE
		mexWarnMsgTxt("Matrix dimensions must be the same.");
#endif
	}
	for (i = 0; i < len_k; i++) {
		indi = (*pi < 0) ? 0 : *pi % len_alpha + 1;
		indj = (*pj < 0) ? 0 : *pj % len_alpha + 1;
		r = alpha[indi] ^ alpha[indj];
		pk[i] = beta[r]-1;
		pi += inci;
		pj += incj;
	}
}
/* end gfplus() */

/* gfminus()
 * Subtract B from A when P is a matrix, scalar inputs only.
 * Used by gfpdeconv(). Can be vectorized if needed.
 */
void gfminus(int_T *pa, int_T *pb, int_T *pp, int_T mp, int_T np, int_T *pc, int_T *Iwork)
{
    int_T   *pola, *polb, *polc;
    int_T   i, j, prim, temp;
    
    pola = Iwork;
    polb = pola + np;
    polc = polb + np;
    
    /* Get the base prime */
    prim = 0;
	for(i=0; i < mp*np; i++){
		if(prim <= pp[i])    
			prim = pp[i] + 1;           
	}
		
    if (pa[0] < 0)
        pa[0] = -1;
    if (pb[0] < 0)
        pb[0] = -1;
       
    /* Convert inputs to polynomial form and then subtract */
    for (i=0; i < np; i++) {
        pola[i] = pp[pa[0]+1+i*mp];
        polb[i] = pp[pb[0]+1+i*mp];
    }

    for (i=0; i < np; i++) {
        polc[i] = pola[i] - polb[i];
        if (polc[i] < 0)
            polc[i] += prim;
    }
    
    /* Determine the row index of the field for the resulting polynomial */ 
    for (i=0; i < mp; i++) {
        temp = 0;
        for (j=0; j<np; j++) {
            if ( polc[j] == pp[i+j*mp] ) {
                temp++;
            }
        }
        if (temp == np) {
            pc[0] = i-1;
            break;
        }
    }
}
/* end gfminus() */

/* gfpmul() multiply for matrix P. 
 *      Iwork --- 2*nc+nc*mp+np
 *      Iwork = indx
 *          + *nc = sum_ab
 *              + *nc = tmp
 *                  +(*nc)*mp = sum
 *                      + np = bottom of Iwork
 */
void gfpmul(int_T *pa, int_T len_a, int_T *pb, int_T len_b, int_T *pp, int_T np, int_T mp, int_T *pc, int_T *nc, int_T *Iwork)
{
    int_T     i, j, k, prim, len_indx;
    int_T     *sum_ab, *indx, *tmp, *sum;
    
    indx = Iwork;
    sum_ab = indx + nc[0];
    tmp = sum_ab + nc[0];
    sum = tmp + nc[0]*mp;
    
    /* prim = max(max(p))+1; */
    prim = 0;
    for(i=0; i < np*mp; i++){
		if(prim <= pp[i])                              
			prim = pp[i] + 1;           
    }
    /* find input elements less than zero and change them to -Inf */
    /* indx = [find(sum_ab < 0)  find(isnan(sum_ab))];*/
    for(i=0; i < len_a; i++){
		if(pa[i] < 0)
			pa[i] = -Inf;
    }
    for(i=0; i < len_b; i++){
		if(pb[i] < 0)
			pb[i] = -Inf;
    }
    if (len_a == len_b || len_a == 1 || len_b == 1){
		if ( len_a == len_b ){
			for (i = 0; i < nc[0]; i++){
				if (pa[i] == -Inf || pb[i] == -Inf)
					sum_ab[i] = -1;
				else
					sum_ab[i] =(pa[i] + pb[i]) % (np - 1);
			}
		}else{
			if(len_a == 1 && len_b != 1){
				for (i = 0; i < len_b; i++){
					if (pa[0] < 0 || pb[i] < 0)
						sum_ab[i] = -1;
					else
						sum_ab[i] = (pa[0] + pb[i]) % (np - 1);
				}
			}
			if (len_b == 1 && len_a != 1){
				for (i = 0; i < len_a; i++){
					if (pb[0] < 0 || pa[i] < 0)
						sum_ab[i] = -1;
					else
						sum_ab[i] = (pa[i] + pb[0]) % (np - 1);
				}
			}
		}
    } else {
		if (len_a <= len_b)
			nc[0] = len_a;
		else
			nc[0] = len_b;
		
		for (i=0; i < nc[0]; i++){
			if (pa[i] < 0 || pb[i] < 0)
				sum_ab[i] = -1;
			else
				sum_ab[i] =(pa[i] + pb[i]) % (np - 1);
		}
    }
    /* tmp = p(sum_ab +2, :); */
    for(i=0; i < nc[0]; i++){
		for(j=0; j < mp; j++)
			tmp[i+j*nc[0]] = pp[j*np+sum_ab[i]+1];
    }
    for(i=0; i < nc[0]; i++){ 
		len_indx = 0;
		for(j=0; j < np; j++){
			sum[j] = 0;
			for(k=0; k < mp; k++){
			    if ((pp[j+k*np]+prim-tmp[i+k*nc[0]]) % prim>0){
			        sum[j] = 1;
			        break;
			    }
			}
			
			if( sum[j] == 0 ){
				indx[len_indx] = j;
				len_indx++;
				break;
			}
		}
		if (len_indx == 1){
			pc[i] = indx[0] - 1;
		}else{
#ifdef MATLAB_MEX_FILE
			if( len_indx == 0 ){
				mexWarnMsgTxt("The list of Galois field is not a complete one.");
			}else{
				mexWarnMsgTxt("The list of Galois field has a repeated element.");
			}
#endif	    
		}
    }
    len_indx = 0;
    for(i=0; i < nc[0]; i++){
		if( pc[i] < 0 ){
			indx[len_indx] = i;
			len_indx++;
		}
    }
    if(len_indx != 0){
		for(i=0; i < len_indx; i++)
			pc[indx[i]] = -Inf;
    }
}
/* end gfpmul() */

/* gfmul() multiply for scalar p */
void gfmul(int_T *pa, int_T len_a, int_T *pb, int_T len_b, int_T pp, int_T *pc)
{
    int_T     i;
    
    if (len_a == len_b) {
		for (i=0; i < len_a; i++)
			pc[i] = (pa[i]*pb[i]) % pp;
    } else if(len_b == 1){
		for (i=0; i < len_a; i++)
			pc[i] = (pa[i]*pb[0]) % pp;
    } else if (len_a == 1){
		for (i=0; i < len_b; i++)
			pc[i] = (pb[i]*pa[0]) % pp;
    } else if (len_a > len_b){ 
		for (i=len_b; i < len_a; i++)
			pc[i] = pa[i];
		for (i=0; i < len_b; i++)
			pc[i] = (pa[i]*pb[i]) % pp;
    } else {
        for (i=len_a; i < len_b; i++)
			pc[i] = pb[i] ;
		for (i=0; i < len_a; i++)
			pc[i] = (pb[i]*pa[i]) % pp;
    }
}   
/* end gfmul() */

/* gfconv() when P is a scalar. */
void gfconv(int_T *pa, int_T len_a, int_T *pb, int_T len_b, int_T pp, int_T *pc, int_T *Iwork)
{
    int_T     i, nc, One;
    int_T     *pf;    /* working pointer */
    
    nc = len_a+len_b-1;
    One = 1;
    pf = Iwork;
    
    /* Convolution computation
     * Filter B (zero-padded to output size) thru FIR filter A.
     */
	for(i=0; i < nc; i++){
		if(i<len_b){
			pf[i] = pb[i];
		} else {
			pf[i] = 0;
        }
	}
	gffilter(pa, len_a, &One, 1, pf, nc, pp, pc);
}
/* end gfconv() */

/* gfpconv() when the computation is in GF(P^M) field.
 *  Iwork --- 5+3*(np+mp)
 *  Iwork = Iwork for gfpmul()
 *      + 2+mp+np = Iwork for gfpadd()
 *          + 1+mp+np = Iwork for gfpmul()
 *              + 2+mp+np = bottom of Iwork in gfpconv()
 */
void gfpconv(int_T *pa, int_T len_a, int_T *pb, int_T len_b, int_T *pp, int_T np, int_T mp, int_T *pc, int_T *Iwork)
{
    int_T     i, j, prim, tmp[1], One;
    
    prim = 0;
    for(i=0; i < np*mp; i++){
		if(prim <= pp[i])
			prim = pp[i] + 1;           
    }

    for (i=0; i < len_a+len_b-1; i++)
		pc[i] = -Inf;
    
    One = 1;
    for (i=0; i < len_a; i++){
		for (j=0; j < len_b; j++){
			if (pc[i+j] >= 0){
				gfpmul(&pa[i],1,&pb[j],1,pp,np,mp,tmp,&One,Iwork);
				gfpadd(&pc[i+j],1,tmp,1,pp,np,mp,&pc[i+j],&One,Iwork+2+mp+np);
			} else {
				gfpmul(&pa[i],1,&pb[j],1,pp,np,mp,&pc[i+j],&One,Iwork+3+2*mp+2*np);
			}
		}
    }
}
/* end gfpconv() */

/* gfdeconv() when P is a prime scalar. */
void gfdeconv(int_T *pb, int_T len_b, int_T *pa, int_T len_a, int_T pp, int_T *pq, int_T len_q, int_T *pr, int_T *len_r, int_T *Iwork)
{
    int_T  i, len_x;
    int_T  *pfb, *pfa, *px;
    
    if (len_a > len_b) {
		*pq = 0;
		for(i=0; i < len_b; i++)
			pr[i] = pb[i];
    } else {
		len_x = len_b-len_a+1;
		
		pfb = Iwork;
		for(i=0; i<len_b; i++)
			pfb[i] = pb[len_b-1-i]; 
		pfa = pfb + len_b;
		for(i=0; i<len_a; i++)
			pfa[i] = pa[len_a-1-i]; 

		px = pfa+len_a;
		px[0] = 1;
        for (i=1; i < len_x; i++)
            px[i] = 0;

        /* Quotient = impulse thru a filter [b,a]*/		
   		gffilter(pfb, len_b, pfa, len_a, px, len_x, pp, pq);
		fliplr(pq, len_q, 1);

		px = Iwork;
		len_x = len_b;
		for (i=0; i < len_x; i++)
			px[i] = 0;

		/* Remainder,  R = b - Q*a */
		gfconv(pq, len_q, pa, len_a, pp, px, px+len_x);
		
		for (i=0; i < len_x; i++){
			px[i] = (pp-px[i]) % pp;
			if (px[i]<0)
				px[i] += pp;
		}

		gfadd(pb, len_b, px, len_x, pr, len_r[0], pp);
		gftrunc(pr,len_r,1);
	}
}
/* end gfdeconv() */

/* gfpdeconv() when P is a matrix.
 *  Iwork -- 3*np for gfminus()
 */
void gfpdeconv(int_T *pb, int_T len_b, int_T *pa, int_T len_a, int_T *pp, int_T np, int_T mp, int_T *pq, int_T *pr, int_T *len_r, int_T *Iwork)
{
	int_T     i, j, len_q, prim, pow_dim, tmp, flag, factor;
	
	if (len_a > len_b){
		pq[0] = -Inf;
		for(i=0; i < len_b; i++)
			pr[i] = pb[i];
	} else { 
		prim = 0;
		for(i=0; i < np*mp; i++){
			if(prim <= pp[i])    
				prim = pp[i] + 1;           
		}
		
		pow_dim = (int_T) pow(prim, mp);
		pow_dim--;
		
		flag = 0;
		if( pa[len_a-1] != 0 ){
			factor = pow_dim-pa[len_a-1];
			for (i=0; i < len_a; i++){
				if(pa[i] < 0){
					pa[i] = -1;
				} else {
					pa[i] =(pa[i] + factor) % pow_dim;
				}
			}
			for (i=0; i < len_b; i++){
				if(pb[i] < 0){
					pb[i] = -1;
				} else {
					pb[i] =(pb[i] + factor) % pow_dim;
				}
			}
			flag = 1;
		}

		len_q = len_b - len_a + 1; 
		for(i=0; i < len_q; i++){
			for(j=0; j < len_a-1; j++){
				if(pb[len_b-1-i] < 0 || pa[len_a-2-j] < 0) {
					tmp = -1;
				} else {
					tmp = (pb[len_b-1-i] + pa[len_a-2-j]) % pow_dim;
                }
				gfminus(&pb[len_b-2-i-j], &tmp, pp, np, mp, &pb[len_b-2-i-j], Iwork);
			}
		}

		/* Sets the quotient Q */ 
		for (i=len_a-1; i < len_b ; i++)
			pq[i-len_a+1] = pb[i];

		/* computes the remainder R */ 
		if (len_a > 1){
			len_r[0] = len_a-1;
			for(i=0; i <len_r[0]; i++)
				pr[i] = pb[i];
			gftrunc(pr, len_r, np*mp);
			
			if ( flag != 0 ){
				for(i=0; i < len_r[0]; i++) {
                    if (pr[i]>=0)
    					pr[i] = (pr[i] + pow_dim - factor) % pow_dim;
	            }    
			}
		} else {
			pr[0] = -Inf;
			len_r[0] = 1;
		}
    }
}
/* end gfpdeconv() */

/* flxor() Exclusive OR computation. */
void flxor(int_T *px, int_T mx, int_T nx, int_T *py, int_T my, int_T ny, int_T *pz, int_T *mz, int_T *nz)  
{
    int_T     i, incx, incy;
    
    if ((mx == 1) && (nx == 1) && (my == 1) && (ny == 1)){
		*mz = 1;
		*nz = 1;        
		incx = 0;
		incy = 0;
    }else if ((mx == my) && (nx == ny)) {
		*mz = mx;
		*nz = nx;
		incx = 1;
		incy = 1;
    } else if ((my == 1) && (ny == 1)) {
		*mz = mx;
		*nz = nx;
		incx = 1;
		incy = 0;
    } else if ((mx == 1) && (nx == 1)) {
		*mz = my;
		*nz = ny;
		incx = 0;
		incy = 1;
    } else {
#ifdef MATLAB_MEX_FILE
		mexWarnMsgTxt("Matrix dimensions must agree.");
#endif
    }
    for (i = 0; i < (*mz)*(*nz); i++) {
		pz[i] =  *px ^ *py;
		px += incx;
		py += incy;
    }
}
/* end flxor() */

/* errlocp1() 
 *  Iwork --- 5*(t+2)+(t+4)*(t+1)
 *  Iwork = mu
 *      + t+2 = sigma_mu
 *          + (t+2)*(t+1) = d_mu
 *              + t+2 = l_mu
 *                  + t+2 = mu_l_mu
 *                      + t+2 = indx
 *                          + t+2 = shifted
 *                              + t+1 = tmpRoom
 *                                  + t+1 = bottom of iwork in errlocp1() 
 */
void errlocp1(int_T *syndr, int_T t, int_T *pNum, int_T *pInv, int_T pow_dim, int_T *err_In, int_T *Iwork, int_T *sigma_Out, int_T *len_Out)
{
    int_T     i, j, de_i, de_j, de_k, de_j_tmp;
    int_T     len_indx, len_tmp, maxx, rho, shifting, tmp;
    int_T     *mu, *sigma_mu, *d_mu, *l_mu, *mu_l_mu, *tmpRoom, *indx, *shifted;
    
    /* M-file
	 *if type_flag
	 * % use the berlekamp's algorithm
	 *   t = 2 * t;
	 *   mu = [-1, 0:t]';
	 *   sigma_mu = [zeros(t+2,1), -ones(t+2, t)];
	 *   d_mu = [0; syndrome(1); zeros(t, 1)];
	 *   l_mu = [0 0 [1:t]]';
	 *   mu_l_mu = mu - l_mu;
	 */
    /* allocate (t+2) for *mu */
    mu = Iwork;
    for(i=0; i < t+2; i++)
		mu[i] = i - 1;
    
    /* allocate (t+2)*(t+1) for *sigma_mu */    
    sigma_mu = mu + (t + 2);
    for(i=0; i < (t+2)*(t+1); i++){
		if( i > t+1 )
			sigma_mu[i] = -1;
		else
			sigma_mu[i] = 0;
    }
    
    /* allocate (t+2) for *d_mu */
    d_mu = sigma_mu + (t+1)*(t+2);
    for (i = 0; i< t+1; i++)
		d_mu[i] = 0;
    d_mu[1] = syndr[0];
    
    /* allocate (t+2) for *l_mu */
    l_mu = d_mu + (t+2);
    l_mu[0] = 0;
    l_mu[1] = 0;
    for(i=0; i < t; i++)
		l_mu[i+2] = i + 1;
    
    /* allocate (t+2) for *mu_l_mu */
    mu_l_mu = l_mu + (t+2);
    for(i=0; i < t+2; i++)
		mu_l_mu[i] = mu[i] - l_mu[i];
    
    /* allocate (t+2) for *indx */
    /* allocate (t+1) for *shifted */
    /* allocate (t+1) for *tmpRoom */
    indx = mu_l_mu + (t+2);
    shifted = indx + (t+2);
    tmpRoom = shifted+(t+1);

    /* M-file
	 * %iteratiev start with row three. The first two rows are filled.
	 * for de_i = 3:t+2
	 */	
    for(de_i=2; de_i < t+2; de_i++){
	/* M-file
	 * % no more effort to failed situation
	 *if (d_mu(de_i - 1) < 0) | err
	 *    sigma_mu(de_i, :) = sigma_mu(de_i-1, :);
	 *    l_mu(de_i) = l_mu(de_i - 1);
	 */
		if( d_mu[de_i-1] < 0 || err_In[0] != 0 ){
			for(j=0; j < t+1; j++)
				sigma_mu[de_i+j*(t+2)] = sigma_mu[de_i-1+j*(t+2)];
			l_mu[de_i] = l_mu[de_i-1];
		   /*M-file
			*  else
			*      % find another row proceeding to row de_i -1
			*      % d_mu equals to zero
			*      % and mu - l_mu is the largest.
			*      indx = find(d_mu(1:de_i - 2) >= 0);
			*      rho  = find(mu_l_mu(indx) == max(mu_l_mu(indx)));
			*      rho = indx(rho(1));
			*/
		} else {
			len_indx = 0;
			for(j=0; j < de_i-1; j++){
				if(d_mu[j] >= 0){
					indx[len_indx] = j;
					len_indx++;
				}
			}
			rho = indx[0];
			maxx = mu_l_mu[indx[0]];
			for(j=0; j < len_indx; j++){
				if(mu_l_mu[indx[j]] >= maxx) {
					maxx = mu_l_mu[indx[j]];
					rho = indx[j];
				}
			}

		   /* M-file
			*    % by (6.25)
			*    % shifted = gfmul(d_mu(de_i - 1), pow_dim - d_mu(rho), tp);
			*    % shifted = gfmul(shifted, sigma_mu(rho, :), tp)';
			*    % multiply inreplace the above two lines.
			*    shifted = -ones(1, t+1);
			*    if (d_mu(de_i - 1) >= 0) & (pow_dim - d_mu(rho) >= 0)
			*        tmp = rem(pow_dim - d_mu(rho) + d_mu(de_i - 1), pow_dim);
			*        indx = find(sigma_mu(rho,:) >= 0);
			*        for de_k = 1 : length(indx)
			*            shifted(indx(de_k)) = rem(tmp + sigma_mu(rho, indx(de_k)), pow_dim);
			*        end;            
			*    end;
			*    % end multiply
			*/			
			for(j=0; j < t+1; j++)
				shifted[j] = -1;
			
			if( d_mu[de_i-1]>=0 && (pow_dim-d_mu[rho])>=0 ){
				tmp = (pow_dim - d_mu[rho] + d_mu[de_i-1]) % pow_dim;
				/* take advantage of the memory of *indx */
				len_indx = 0;
				for(j=0; j < t+1; j++){
					if( sigma_mu[rho+j*(t+2)] >= 0 ){
						indx[len_indx] = j;
						len_indx++;
					}
				}
				for(de_k=0; de_k < len_indx; de_k++)
					shifted[indx[de_k]] = (tmp + sigma_mu[rho+indx[de_k]*(t+2)]) % pow_dim;
			}
			shifting = mu[de_i-1] - mu[rho];
			
		   /* M-file
			*  % calculate new sigma_mu
			*  if ~isempty(find(shifted(t-shifting+2 : t+1) >= 0))
			*      % more than t errors, BCH code fails.
			*        err = 1;
			*  else
			*      % calculate the new sigma
			*      shifted = [-ones(1, shifting) shifted(1:t-shifting+1)];
			*      sigma_mu(de_i, :) = gfplus(sigma_mu(de_i-1,:), shifted, tp_num, tp_inv);
			*  end;
			*  l_mu(de_i) = max(l_mu(de_i-1), l_mu(rho) + (de_i - 1) - rho);
			*end;
			*/
			/* calculate new sigma_mu */
			len_tmp = 0;
			for(j=t-shifting+1; j < t+1; j++){
				if( shifted[j] >= 0 )
					len_tmp++;
			}
			
			if (len_tmp != 0){
				err_In[0] = 1;
			}else{
				/* calculate the new sigma */
				for(j=0;j<t+1;j++)
					tmpRoom[j]=shifted[j];
				
				for(j=0; j < shifting; j++)
					shifted[j] = -1;
				if(shifting < t+1){
					for(j=shifting; j < t+1; j++)
						shifted[j] = tmpRoom[j-shifting];
				}
				for(j=0; j < t+1; j++)
					gfplus(&sigma_mu[de_i-1+j*(t+2)],1,1, &shifted[j],1,1, pNum,pow_dim+1,pInv,pow_dim+1, &sigma_mu[de_i+j*(t+2)]);
			}
			if( l_mu[de_i-1] < l_mu[rho]+de_i-rho-1 )
				l_mu[de_i] = l_mu[rho]+de_i-rho-1;
			else
				l_mu[de_i] = l_mu[de_i-1];
		}

	   /*M-file
		*% calculate d_mu. It is not necessary to do so if mu(de_i) == t
		*if de_i < t+2
		*    % the constant term
		*    d_mu(de_i) = syndrome(mu(de_i) + 1);
		*    indx = find(sigma_mu(de_i, 2:t) >= 0);
		*/		
		if( de_i < t+1 ){
			d_mu[de_i] = syndr[mu[de_i]];
			len_indx = 0;
			for(j=1; j < t; j++){
				if( sigma_mu[de_i+j*(t+2)] >= 0 ){
					indx[len_indx] = j-1;
					len_indx++;
				}
			}

		   /*M-file
			*for de_j = 1 : length(indx)
			*    de_j_tmp = indx(de_j);
			*        % Before the "end", it is equivalent to
			*        % d_mu(de_i) = gfadd(d_mu(de_i), ...
			*        %              gfmul(sigma_mu(de_i + 1, de_j_tmp+1), ...
			*        %              syndrome(mu(de_i) * 2 - de_j_tmp + 1), tp), tp);
			*    tmp = syndrome(mu(de_i) - de_j_tmp + 1);
			*    if (tmp < 0) | (sigma_mu(de_i, de_j_tmp + 1) < 0)
			*        tmp = -1;
			*    else
			*        tmp = rem(tmp + sigma_mu(de_i, de_j_tmp + 1), pow_dim);
			*    end;
			*    d_mu(de_i) = gfplus(d_mu(de_i), tmp, tp_num, tp_inv);
			*end;
			*end;--- this 'end' for 'if de_i < t+2
			*/
			for(de_j=0; de_j < len_indx; de_j++){
				de_j_tmp = indx[de_j];
				tmp = syndr[ mu[de_i] - de_j_tmp -1];
				if( tmp < 0 || sigma_mu[de_i + (de_j_tmp+1)*(t+2)] < 0 )
					tmp = -1;
				else
					tmp = (tmp + sigma_mu[de_i+(de_j_tmp+1)*(t+2)] ) % pow_dim;
				
				gfplus(&d_mu[de_i],1,1,&tmp,1,1,pNum,pow_dim+1,pInv,pow_dim+1, &d_mu[de_i]);
			}
		}
	   /*M-file
		*% calculate mu-l_mu
		*mu_l_mu(de_i) = mu(de_i) - l_mu(de_i);
		*end;
		*/
		mu_l_mu[de_i] = mu[de_i] - l_mu[de_i];
    }
	
    /* truncate the reduancy */
    len_Out[0] = 0;
    for(i=0; i < t+1; i++){
		if ( sigma_mu[(t+1) + i*(t+2)] >= 0 )
			len_Out[0] = i;
    }
    len_Out[0] = len_Out[0] + 1;
    for(i=0; i < len_Out[0]; i++)
		sigma_Out[i] = sigma_mu[(t+1)+i*(t+2)];
}
/* end errlocp1() */

/* errlocp0()
 *  Iwork --- 5*(t+2)+(t+4)*(t+1)
 *  Iwork = mu
 *      + t+2 = sigma_mu
 *          + (t+2)*(t+1) = d_mu
 *              + t+2 = l_mu
 *                  + t+2 = mu2_l_mu
 *                      + t+2 = indx
 *                          + t+2 = shifted
 *                              + t+1 = tmpRoom
 *                                  + t+1 = bottom of iwork in errlocp0() 
 */
void errlocp0(int_T *syndr, int_T t, int_T *pNum, int_T *pInv, int_T pow_dim, int_T *err_In, int_T *Iwork, int_T *sigma_Out, int_T *len_Out)
{
    int_T     i, j, de_i, de_j, de_k, de_j_tmp;
    int_T     len_indx, len_tmp, max, rho, shifting, tmp;
    int_T     *mu, *sigma_mu, *d_mu, *l_mu, *mu2_l_mu, *tmpRoom, *indx, *shifted;
    
    /*M-file
	 *% use simplified algorithm
	 *mu = [-1/2, 0:t]';
	 *sigma_mu = [zeros(t+2,1), -ones(t+2, t)];
	 *d_mu = [0; syndrome(1); zeros(t, 1)];
	 *l_mu = [0 0 2*(1:t)]';
	 *mu2_l_mu = 2*mu - l_mu;
	 */
    /* allocate (t+2) for *mu
	 * this *mu is different with M-file, *mu = 2*mu
	 */ 
    mu = Iwork ;
    mu[0] = -1;
    for(i=0; i < t+1; i++)
		mu[i+1] = 2*i;
    
    /* allocate (t+2)*(t+1) for *sigma_mu */    
    sigma_mu = mu + (t+2);
    for(i=0; i < (t+2)*(t+1); i++){
		if( i > t+1 )
			sigma_mu[i] = -1;
		else
			sigma_mu[i] = 0;     
    }
    
    /* allocate (t+2) for *d_mu */
    d_mu = sigma_mu + (t+2)*(t+1);
    d_mu[1] = syndr[0];
    
    /* allocate (t+2) for *l_mu */
    l_mu = d_mu + (t+2);
    for(i=0; i < t; i++)
		l_mu[i+2] = 2*(i + 1);
    
    /* allocate (t+2) for *mu2_l_mu */
    mu2_l_mu = l_mu + (t+2);
    for(i=0; i < t+2; i++)
		mu2_l_mu[i] = mu[i] - l_mu[i];
    
    /* allocate (t+2) for *indx */
    /* allocate (t+1) for *shifted */
    /* allocate (t+1) for *tmpRoom */
    indx = mu2_l_mu + (t+2);
    shifted = indx + (t+2);
    tmpRoom = shifted+(t+1);

    /* M-file
	 *% iteratiev start with row three. The first two rows are filled.
	 *for de_i = 3:t+2
	 */
    for(de_i=2; de_i < t+2; de_i++){
	/*M-file
	 *% no more effort to failed situation
	 *if (d_mu(de_i - 1) < 0) | err
	 *    sigma_mu(de_i, :) = sigma_mu(de_i-1, :);
	 */
		if( d_mu[de_i-1] < 0 || err_In[0] != 0 ){
			for(j=0; j < t+1; j++)
				sigma_mu[de_i+j*(t+2)] = sigma_mu[de_i-1+j*(t+2)];
			   /*M-file
				*  else
				*      % find another row proceeding to row de_i-1
				*      % d_mu equals to zero
				*      % and 2*mu - l_mu is the largest.
				*      indx = find(d_mu(1:de_i - 2) >= 0);
				*      rho  = find(mu2_l_mu(indx) == max(mu2_l_mu(indx)));
				*      rho = indx(rho(1));
			    */
		} else {
			len_indx = 0;
			for(j=0; j < de_i-1; j++){
				if(d_mu[j] >= 0){
					indx[len_indx] = j;
					len_indx++;
				}
			}
			max = mu2_l_mu[0];
			for(j=0; j < len_indx; j++){
				if(mu2_l_mu[indx[j]] > max)
					max = mu2_l_mu[indx[j]];
			}
			for(j=0; j < len_indx; j++){
				if(mu2_l_mu[indx[j]] == max)
					rho = indx[j];
			}

		   /* M-file
			*    % by (6.28)
			*    % shifted = gfmul(d_mu(de_i - 1), pow_dim - d_mu(rho), tp);
			*    % shifted = gfmul(shifted, sigma_mu(rho, :), tp)';
			*    % multiply inreplace the above two lines.
			*    shifted = -ones(1, t+1);
			*    if (d_mu(de_i - 1) >= 0) & (pow_dim - d_mu(rho) >= 0)
			*        tmp = rem(pow_dim - d_mu(rho) + d_mu(de_i - 1), pow_dim);
			*        indx = find(sigma_mu(rho,:) >= 0);
			*        for de_k = 1 : length(indx)
			*            shifted(indx(de_k)) = rem(tmp + sigma_mu(rho, indx(de_k)), pow_dim);
			*        end;            
			*    end;
			*    % end multiply
			*/
			for(j=0; j < t+1; j++)
				shifted[j] = -1;
			
			if( d_mu[de_i-1]>=0 && (pow_dim-d_mu[rho])>=0 ){
				tmp = (pow_dim - d_mu[rho] + d_mu[de_i-1]) % pow_dim;
				
				/* take advantage of the memory of *indx */
				len_indx = 0;
				for(j=0; j < t+1; j++){
					if( sigma_mu[rho+j*(t+2)] >= 0 ){
						indx[len_indx] = j;
						len_indx++;
					}
				}
				for(de_k=0; de_k < len_indx; de_k++)
					shifted[indx[de_k]] = (tmp + sigma_mu[rho+indx[de_k]*(t+2)]) % pow_dim;
			}
			/*M-file
			 *shifting = (mu(de_i - 1) - mu(rho))*2;
			 */
			shifting = mu[de_i-1] - mu[rho];
			
		   /*M-file
			*if ~isempty(find(shifted(max(t-shifting+2, 1) : t+1) >= 0))
			*    % more than t errors, BCH code fails.
			*    err = 1;
			*else
			*    % calculate the new sigma
			*    shifted = [-ones(1, shifting) shifted(1:t-shifting+1)];
			*    sigma_mu(de_i, :) = gfplus(sigma_mu(de_i-1,:), shifted, tp_num, tp_inv);
			*end;
			*end;--this end for "if (d_mu(de_i - 1) < 0) | err"
			*l_mu(de_i) = max(find(sigma_mu(de_i,:) >= 0)) - 1;
			*/
			/* calculate new sigma_mu */
			len_tmp = 0;
			for(j=max; j < t+1; j++){
				if( shifted[j] >= 0 )
					len_tmp++;
			}
			if (len_tmp > 0){
				err_In[0] = 1;
			}else{
				for(j=0;j<t+1;j++)
					tmpRoom[j]=shifted[j];
				
				for(j=0; j < shifting; j++)
					shifted[j] = -1;
				if(shifting < t+1){
					for(j=shifting; j < t+1; j++)
						shifted[j] = tmpRoom[j-shifting];
				}
				for(j=0; j < t+1; j++)
					gfplus(&sigma_mu[de_i-1+j*(t+2)],1,1, &shifted[j],1,1, pNum,pow_dim+1,pInv,pow_dim+1, &sigma_mu[de_i+j*(t+2)]);
			}
	}
	for(j=0; j < t+1; j++){
		if(sigma_mu[de_i+j*(t+2)] >= 0)
			l_mu[de_i] = j-1;
	}

	/*M-file
	 *% calculate d_mu. It is not necessary to do so if mu(de_i) == t
	 *if de_i < t+2
	 *    % the constant term
	 *    d_mu(de_i) = syndrome(mu(de_i)*2 + 1);
	 *    indx = find(sigma_mu(de_i, 2:t) >= 0);
	 */
	if( de_i < t+1 ){
		d_mu[de_i] = syndr[mu[de_i]];
		len_indx = 0;
		for(j=1; j < t; j++){
			if( sigma_mu[de_i+j*(t+2)] >= 0 ){
				indx[len_indx] = j-1;
				len_indx++;
			}
		}
		
		for(de_j=0; de_j < len_indx; de_j++){
			de_j_tmp = indx[de_j];
			tmp = syndr[ mu[de_i] - de_j_tmp - 1 ];
			if( tmp < 0 || sigma_mu[de_i+(de_j_tmp+1)*(t+2)] < 0 )
				tmp = -1;
			else
				tmp = (tmp + sigma_mu[de_i+(de_j_tmp+1)*(t+2)] ) % pow_dim;
			
			gfplus(&d_mu[de_i],1,1,&tmp,1,1,pNum,pow_dim+1,pInv,pow_dim+1, &d_mu[de_i]);
		}
	}
	mu2_l_mu[de_i] = mu[de_i] - l_mu[de_i];
    }
    /* truncate the reduancy */
    len_Out[0] = 0;
    for(i=0; i < t+1; i++){
		if ( sigma_mu[(t+1) + i*(t+2)] >= 0 )
			len_Out[0] = i+1;
    }
    for(i=0; i < len_Out[0]; i++)
		sigma_Out[i] = sigma_mu[(t+1)+i*(t+2)];
}
/* end errlocp0() */

/* bchcore() 
 *  Integer Working Space list:
 *  total for function: Iwork = (2+dim)*(2*pow_dim+1)+t*t+15*t+16;
 *  Iwork = pNum
 *      + pow_dim+1 = pInv
 *          + pow_dim+1 = Iwork for pNumInv()
 *              + (pow_dim+1)*dim = non_zeros_itm
 *                  + pow_dim = syndrome
 *                      + 2*t = tmpRoom
 *                          + 2*t = sigma 
 *                              + (t+1) = len_sigma
 *                                  + 1 = Iwork for errlocp0()
 *                                      + (pow_dim-k)*(pow_dim-k)+10*(pow_dim-k)+14 = loc_err
 *                                          + pow_dim = pos_err
 *                                              + pow_dim*dim = bottom of Iwork
 */
void bchcore(int_T *code, int_T pow_dim, int_T dim, int_T k, int_T t, int_T *pp, int_T *Iwork, int_T *err, int_T *ccode)
{
    int_T     i, prim, np, mp, nk, tmp, er_j;
    int_T     *loc_err, num_err, cnt_err, er_i, test_flag;
    int_T     *non_zeros_itm, len_non_z_itm, *tmpRoom, *len_sigma;
    int_T     *pNum, *pInv, *sigma, *pos_err, *syndrome;
    
    np = pow_dim + 1;
    mp = dim;
   /*  code = code(:)';
	*  err = 0;
	*  tp_num = tp * 2.^[0:dim-1]';
	*  tp_inv(tp_num+1) = 0:pow_dim;
	*/
    err[0] = 0; 
    pNum = Iwork;
    pInv = Iwork + np;
    prim = 2;
    pNumInv(pp, np, mp, prim, pNum, pInv);
	
   /*  % **(1)** syndrome computation.
	*  % initialization, find all non-zeros to do the calculation
	*  non_zero_itm = find(code > 0) - 1;
	*  len_non_z_itm = length(non_zero_itm);
	*  syndrome = -ones(1, 2*t);
	*/	
    /* allocate pow_dim for *non_zeros_itm */
    non_zeros_itm = pInv + (dim+1)*np;    
    for(i=0; i < pow_dim; i++)
		non_zeros_itm[i] = 0;
    len_non_z_itm = 0;    
    for(i=0; i < pow_dim; i++){
		if(code[i] > 0 ){
			non_zeros_itm[len_non_z_itm] = i;
			len_non_z_itm++;
		}
    }
    /* allocate 2*t for *syndrome */
    syndrome = non_zeros_itm + pow_dim;
    for(i=0; i < 2*t; i++)
		syndrome[i] = -1;

	   /*  % syndrome number is 2*t where t is error correction capability
		*  if len_non_z_itm > 0
		*      tmp = 1:2*t;
		*      syndrome(tmp) = non_zero_itm(1) * tmp;
		*      if len_non_z_itm > 1
		*          for n_k = 2 : len_non_z_itm
		*              syndrome(tmp) = gfplus(syndrome(tmp), non_zero_itm(n_k) * tmp, tp_num, tp_inv);
		*          end;
		*      end;
		*  end;
		*  % complete syndrome computation
	    */     
    tmpRoom = syndrome + 2*t; /* size is 2*t */
    if( len_non_z_itm > 0 ){
		for(i=0; i < 2*t; i++)
			syndrome[i] = non_zeros_itm[0]*(i+1); 
		if( len_non_z_itm > 1 ){
			for( nk=1; nk < len_non_z_itm; nk++ ){
				for(i=0; i < 2*t; i++)
					tmpRoom[i] = non_zeros_itm[nk]*(i+1);
				gfplus(syndrome,2*t,1,tmpRoom,2*t,1,pNum,np,pInv,np,syndrome);
			}
		}
    }
    /* complete syndrome computation */  
    /*  % **(2)** determine the error-location polynomial.
	*  % This step is the most complicated part in the BCH decode.
	*  % reference to p158 of Shu Lin's Error Control Coding,
	*  % the simplified algorithm for finding sigma_x.
	*  % the maximum degree of the error-location polynomial is t
	*  % if the degree is larger than t, there are more than t errors and
	*  % the algorithm cannot find a solution to correct the errors.
	*
	*  % for BCH code, use simplified method. Note that when you call
	*  % errlocp, the parameter should be exact.
	*  [sigma, err] = errlocp(syndrome, t, tp, pow_dim, err, 0);
	*/
    /* allocate (t+1) for sigma*/
    sigma = tmpRoom+2*t;
    for(i=0; i<t+1;i++)
		sigma[i] = 0;
    len_sigma = sigma+(t+1);
    errlocp1(syndrome, 2*t, pNum, pInv, pow_dim, err, len_sigma+1, sigma, len_sigma);
    /* need (pow_dim-k)*(pow_dim-k)+10*(pow_dim-k)+14 for errlocp1() */
	
    /*  % ***(3)*** computation of error-location numbers.
	 *  loc_err = zeros(1, pow_dim);
	 */
    /* allocate pow_dim for loc_err
	 * it is automatically initialized as zero.
	 */ 
	 	
    loc_err = len_sigma+1+(pow_dim-k)*(pow_dim-k)+10*(pow_dim-k)+14;
    /*    loc_err = len_sigma+1+5*(t+2)+(t+4)*(t+1);;
	 */  
    for(i=0; i<pow_dim; i++)
		loc_err[i] = 0;
    num_err = len_sigma[0] - 1;
   /*  if (~err) & (num_err > 0)
	*      cnt_err = 0;
	*      pos_err = [];
	*      er_i = 0;
	*/
    /* allocating pow_dim*dim for pos_err */
    pos_err = loc_err + pow_dim;
    if( err[0] == 0 && num_err > 0 ){
		cnt_err = 0;
		er_i = 0;
		/*      while (cnt_err < num_err) & (er_i < pow_dim * dim)
		*          test_flag = sigma(1);
		*          for er_j = 1 : num_err
		*/
		while( cnt_err < num_err && er_i < pow_dim* dim ){
			test_flag = sigma[0];
			for( er_j=0; er_j < num_err; er_j++){
			/*              if sigma(er_j + 1) >= 0
			*                  % The following 6 lines is equivelent to
			*                  % tmp = gfmul(er_i * er_j, sigma(er_j+1), tp);
			*                  tmp = er_i * er_j;
			*                  if (tmp < 0) | (sigma(er_j+1) < 0)
			*                      tmp = -1;
			*                  else
			*                      tmp = rem(tmp + sigma(er_j + 1), pow_dim);
			*                  end;
			*                  test_flag = gfplus(test_flag, tmp, tp_num, tp_inv);
			*              end;
			*          end;
			*/
				if(sigma[er_j + 1] >= 0){
					tmp = er_i * (er_j+1);
					if( tmp < 0 || sigma[er_j+1] < 0 )
						tmp = -1;
					else
						tmp = (tmp + sigma[er_j+1]) % pow_dim;
					
					gfplus(&test_flag,1,1,&tmp,1,1,pNum,np,pInv,np,&test_flag);
				}
			}
			/*          if test_flag < 0
			*              cnt_err = cnt_err + 1;
			*              pos_err = [pos_err, rem(pow_dim-er_i, pow_dim)];
			*          end;
			*          er_i = er_i + 1;
			*      end;
			*/
			if ( test_flag < 0 ){
				pos_err[cnt_err] = (pow_dim - er_i) % pow_dim;
				cnt_err++;
			}
			er_i++;
		}
		/*      pos_err = rem(pow_dim+pos_err, pow_dim);
		*      pos_err = pos_err + 1; % shift one location because power zero is one.
		*      loc_err(pos_err) = ones(1, cnt_err);
		*      err = num_err;
		*/
		for(i=0; i < cnt_err; i++)
			pos_err[i] = (pow_dim + pos_err[i]) % pow_dim;
		for(i=0; i < cnt_err; i++)
			loc_err[pos_err[i]] = 1;
		err[0] = num_err;
    }else{
    /*  else
	*      if err
	*          err = -1;
	*      end;
	*  end;
	*  % completed error location detection
	*/
		if( err[0] != 0 )
			err[0] = -1;
    }
	
    /* completed error location detection */
    /*  % correct the error
	*  ccode = rem(code + loc_err, 2);
	*  msg = ccode(pow_dim-k+1 : pow_dim);
	*  %-- end of bchcore---
	*/
    for(i=0; i < pow_dim; i++)
		ccode[i] = (code[i] + loc_err[i]) % 2;
}
/* end bchcore() */

/* rscore()
 * Integer Working Space list:
 *  total for function: Iwork = (pow_dim-2*k+5*dim+18)*pow_dim+3*dim+k*(k-13)+27;
 *  Iwork = pNum
 *      + pow_dim+1 = pInv
 *          + pow_dim+1 = Iwork for pNumInv()
 *              + dim*(pow_dim+1)= tmpRoom
 *                  + pow_dim = syndrome
 *                      + pow_dim-k = sy
 *                          + 2 = Iworkgfdec
 *                              + (2+dim)*pow_dim+3+dim = sigma
 *                                  + pow_dim-k+1 = len_sigma
 *                                      + 1 = Iworkerr
 *                                          + (pow_dim-k)^2+10*(pow_dim-k)+14 = loc_err
 *                                              + pow_dim = pos_err
 *                                                  + pow_dim*dim = Z
 *                                                      + pow_dim-k+1 = IworkMul
 *                                                          + 3+pow_dim+dim = er_loc
 *                                                              + pow_dim*dim = bottom of Iwork
 */
void rscore(int_T *code, int_T k, int_T *pp, int_T dim, int_T pow_dim, int_T *Iwork, int_T *err, int_T *ccode)
{
    int_T     i, np, mp, sy_i, er_i, er_j, am_i, am_j;
    int_T     t, t2, prim, tmp, test_flag, len_sy, len, zero;
    int_T     num, den, num_err, cnt_err, pos_err_inv;
    int_T     *pNum, *pInv, *tmpRoom, *syndrome, *sy, *sigma, *loc_err, *pos_err, *Z, *er_loc;
    int_T     *Iworkgfdec, *Iworkerr, *IworkMul, *len_sigma, len_syndrome[1];
    int_T     *ignored; /* <-- added for call to gfpdeconv, AK */
    
    np = pow_dim + 1;
    mp = dim;
    t2 = pow_dim - k;
    t =(int_T)(t2/2);
    
    prim = 2;
    /* allocate 2*np for both of *pNum and *pInv */
    pNum = Iwork;
    pInv = Iwork + np;
    pNumInv(pp, np, mp, prim, pNum, pInv);
    /*
	 * allocate pow_dim for *tmpRoom, t2 for *syndrome and 2 for *sy; 
	 */
    tmpRoom = pInv + np +np*dim;
    syndrome = tmpRoom + pow_dim ;
    sy = syndrome + pow_dim - k;
    Iworkgfdec = sy + 2;
    ignored = Iworkgfdec + 3*mp; /* <-- added for call to gfpdeconv, AK */
    len_syndrome[0] = 1;
    for( sy_i=0; sy_i < t2; sy_i++){
		sy[0] = sy_i+1;
		sy[1]=0;
		len_sy = 2;
		for(i=0; i < pow_dim; i++)
			tmpRoom[i] = code[i];
		gfpdeconv(tmpRoom, pow_dim, sy, len_sy, pp, np, mp, ignored, &syndrome[sy_i], len_syndrome, Iworkgfdec);
    }
    /* (2) find error location polynomial
	 * allocate pow_dim-k+1 for *sigma, and (pow_dim-k)*(pow_dim-k)+10*(pow_dim-k)+14 for errlocp1(); 
	 */
    sigma = ignored+1+(dim+2)*(pow_dim+1);
    for(i=0; i<pow_dim-k+1; i++)
		sigma[i] = 0;
    len_sigma = sigma+pow_dim-k+1;
    Iworkerr = len_sigma + 1;
    err[0] = 0;
    errlocp1(syndrome, 2*t, pNum, pInv, pow_dim, err, Iworkerr, sigma, len_sigma);
    
    /* (3) find solution for the polynomial
	 * allocate pow_dim for *loc_err
	 */
    loc_err = Iworkerr+(pow_dim-k)*(pow_dim-k)+10*(pow_dim-k)+14;
    for(i=0; i<pow_dim; i++)
		loc_err[i] = -Inf;
    num_err = len_sigma[0] - 1;
    
    if( num_err > t)
		err[0] = 1;
    
    pos_err = loc_err + pow_dim;
    if( err[0] == 0 && num_err > 0 ){
		cnt_err = 0;
		/* allocating pow_dim*dim for pos_err */
		er_i = 0;
		while( cnt_err < num_err && er_i < pow_dim*dim ){
			test_flag = sigma[0];
			for( er_j=0; er_j < num_err; er_j++){
				if(sigma[er_j + 1] >= 0){
					tmp = er_i * (er_j+1);
					if( tmp < 0 || sigma[er_j+1]<0 )
						tmp = -1;
					else
						tmp = (tmp + sigma[er_j+1]) % pow_dim;
					
					gfplus(&test_flag,1,1,&tmp,1,1,pNum,np,pInv,np,&test_flag);
				}
			}
			if ( test_flag < 0 ){
				pos_err[cnt_err] = (pow_dim - er_i) % pow_dim;
				cnt_err++;
			}
			er_i++;
		}
		for(i=0; i < cnt_err; i++)
			pos_err[i] = (pow_dim + pos_err[i]) % pow_dim;
		err[0] = num_err;
    }else{
		if( err[0] != 0 )
			err[0] = -1;
    }
    
    /* allocate 2*t+1 */
    /* allocate 2+np+mp for IworkMul of gfpmul() */
    /* allocate Pow_dim*dim for *er_loc */
    Z = pos_err+ dim*pow_dim;
    IworkMul = Z + pow_dim - k + 1;
    er_loc = IworkMul + 2+np+mp;
    if( err[0] > 0 ){
		Z[0] = 1;
		for( am_i=1; am_i<=num_err; am_i++){
			gfplus(&syndrome[am_i-1],1,1,&sigma[am_i],1,1,pNum,np,pInv,np,&Z[am_i]);
			if( am_i > 1 ){
				len = 1;
				for(am_j=1; am_j <= am_i-1; am_j++){
					gfpmul(&sigma[am_j],1,&syndrome[am_i-am_j-1],1,pp,np,mp,&tmpRoom[0],&len,IworkMul);
					gfplus(&Z[am_i],1,1,&tmpRoom[0],1,1,pNum,np,pInv,np,&Z[am_i]);
				}
			}
		}
		for(am_i=0; am_i < cnt_err; am_i++){
			num = 0;
			den = 0;
			pos_err_inv = (pow_dim - pos_err[am_i]) % pow_dim;
			for(am_j=1; am_j <= num_err; am_j++){
				tmp = pos_err_inv * am_j;
				
				if( tmp < 0 || Z[am_j] < 0 )
					tmp = -1;
				else
					tmp = (tmp + Z[am_j]) % pow_dim;    
				
				gfplus(&num,1,1,&tmp,1,1,pNum,np,pInv,np,&num);
				
				if ( am_i != am_j-1 ){
					if ( den < 0 ){
						den = -1;
					}else{
						if( (pos_err[am_j-1]) < 0 || pos_err_inv < 0 )
							tmp = -1;
						else
							tmp = ( pos_err[am_j-1]+pos_err_inv ) % pow_dim;
						
						zero = 0;
						gfplus(&zero,1,1,&tmp,1,1,pNum,np,pInv,np, &tmp);
						
						if ( tmp < 0 )
							den = -1;
						else
							den = ( den + tmp ) % pow_dim;
					}
				}
			}
			tmp = pow_dim - den;
			if( tmp < 0 || num < 0 )
				er_loc[am_i] = -1;
			else
				er_loc[am_i] = ( tmp + num ) % pow_dim;
		} 
		for(i=0; i < cnt_err; i++)
			loc_err[ pos_err[i] ] = er_loc[i];
    }
    /* calculate *ccode
	 *  and don't have to calculate *msg since it just is the part of *ccode.
	 */
    gfplus(loc_err,pow_dim,1,code,pow_dim,1,pNum,np,pInv,np,ccode);
}

/* [EOF] */
