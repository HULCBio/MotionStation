/*
 * File: gflib.h
 *       Header file for Galois Field functions.
 *
 * Copyright 1996-2002 The MathWorks, Inc.
 * $Revision: 1.3 $ $Date: 2002/03/27 00:23:19 $
 */

#ifdef MATLAB_MEX_FILE
#include "mex.h"
#endif

#include <math.h>
#include "tmwtypes.h"

#define Inf 32766

/* Function prototypes */
void bi2de(int_T *pbi, int_T np, int_T mp, int_T prim, int_T *pde);

void fliplr(int_T *pa, int_T col_a, int_T row_a);

void pNumInv(int_T *p, int_T np, int_T mp, int_T prim, int_T *pNum, int_T *pInv);

int_T isprime(int_T p);

void gfargchk(double *pa, int_T ma, int_T na, double *pb, int_T mb, int_T nb, double *p, int_T mp, int_T np);

void gffilter(int_T *pb, int_T len_b, int_T *pa, int_T len_a, int_T *px, int_T len_x, int_T p, int_T *pOut);

void gftrunc(int_T *pa, int_T *len_a, int_T len_p);

void gfpadd(int_T *pa, int_T len_a, int_T *pb, int_T len_b, int_T *pp, int_T np, int_T mp, int_T *pc, int_T *nc, int_T *Iwork);

void gfadd(int_T *pa, int_T len_a, int_T *pb, int_T len_b, int_T *pc, int_T len_c, int_T pp);

void gfplus(int_T *pi, int_T mi, int_T ni, int_T *pj, int_T mj, int_T nj, int_T *alpha, int_T len_alpha, int_T *beta, int_T len_beta, int_T *pk);

void gfminus(int_T *pa, int_T *pb, int_T *pp, int_T mp, int_T np, int_T *pc, int_T *Iwork);

void gfpmul(int_T *pa, int_T len_a, int_T *pb, int_T len_b, int_T *pp, int_T np, int_T mp, int_T *pc, int_T *nc, int_T *Iwork);

void gfmul(int_T *pa, int_T len_a, int_T *pb, int_T len_b, int_T pp, int_T *pc);

void gfconv(int_T *pa, int_T len_a, int_T *pb, int_T len_b, int_T pp, int_T *pc, int_T *Iwork);

void gfpconv(int_T *pa, int_T len_a, int_T *pb, int_T len_b, int_T *pp, int_T np, int_T mp, int_T *pc, int_T *Iwork);

void gfdeconv(int_T *pb, int_T len_b, int_T *pa, int_T len_a, int_T pp, int_T *pq, int_T len_q, int_T *pr, int_T *len_r, int_T *Iwork);

void gfpdeconv(int_T *pb, int_T len_b, int_T *pa, int_T len_a, int_T *pp, int_T np, int_T mp, int_T *pq, int_T *pr, int_T *len_r, int_T *Iwork);

void flxor(int_T *px, int_T mx, int_T nx, int_T *py, int_T my, int_T ny, int_T *pz, int_T *mz, int_T *nz);

void errlocp1(int_T *syndr, int_T t, int_T *pNum, int_T *pInv, int_T pow_dim, int_T *err_In, int_T *Iwork, int_T *sigma_Out, int_T *len_Out);

void errlocp0(int_T *syndr, int_T t, int_T *pNum, int_T *pInv, int_T pow_dim, int_T *err_In, int_T *Iwork, int_T *sigma_Out, int_T *len_Out);

void bchcore(int_T *code, int_T pow_dim, int_T dim, int_T k, int_T t, int_T *pp, int_T *Iwork, int_T *err, int_T *ccode);

void rscore(int_T *code, int_T k, int_T *pp, int_T dim, int_T pow_dim, int_T *Iwork, int_T *err, int_T *ccode);

/* [EOF] */
