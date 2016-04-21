/*  Simulation support header file for Economy-sized QR factorization 
 *  block with column pivoting
 * 
 *  Copyright 1995-2002 The MathWorks, Inc.
 *  $Revision: 1.2 $  $Date: 2002/04/14 20:34:58 $
 */
#ifndef dsp_qre_sim_h
#define dsp_qre_sim_h

#include "dsp_sim.h"
#include "dspqrdc_rt.h"

/*
 * Argument and function pointer caches:
 */

typedef struct {
    int_T	    m;     /* Number of rows of input signal*/
    int_T	    n;     /* Number of columns/channels of input signal*/
    const void *a;     /* Pointer to the input signal A*/
    void       *q;     /* Pointer to output signal Q */
    void	   *r;     /* Pointer to output signal R */
    void	   *e;     /* Pointer to output signal E */
    void       *qraux; /* Pointer to DWork QRAux */
    void	   *work;  /* Pointer to DWork Work */
    int_T	   *jpvt;  /* Pointer to IWork */
    void	   *s;     /* Pointer to DWork S */
} QreArgsCache;  


typedef void (*QreFcn)(QreArgsCache *args);

typedef struct {
    QreArgsCache Args;
    QreFcn       QreFcnPtr;    /* Pointer to function */
} SFcnCache;

/* 
 * Simulation support functions for the QR Factorization block. 
 * MGN -> Dimension M is greater than dimension N, 
 *         where M = # of rows of input
 *           and N = # of columns/channels of input.
 * NGEM -> Dimension M is NOT greater than N.
 * cpy  -> Same memory space is utilized by input port A and output port R.
 * nocpy -> Different memory space is utlized by input port A and output port R.
 * Datatype is denoted by D -> double precision real
 *                        R -> single precision real
 *                        Z -> double precision complex
 *                        C -> single precision complex
 */

extern void Qre_NGEM_cpy_D(QreArgsCache *args);
extern void Qre_NGEM_cpy_R(QreArgsCache *args);
extern void Qre_NGEM_cpy_Z(QreArgsCache *args);
extern void Qre_NGEM_cpy_C(QreArgsCache *args);
extern void Qre_MGN_cpy_D(QreArgsCache *args);
extern void Qre_MGN_cpy_R(QreArgsCache *args);
extern void Qre_MGN_cpy_Z(QreArgsCache *args);
extern void Qre_MGN_cpy_C(QreArgsCache *args);
extern void Qre_NGEM_nocpy_D(QreArgsCache *args);
extern void Qre_NGEM_nocpy_R(QreArgsCache *args);
extern void Qre_NGEM_nocpy_Z(QreArgsCache *args);
extern void Qre_NGEM_nocpy_C(QreArgsCache *args);
extern void Qre_MGN_nocpy_D(QreArgsCache *args);
extern void Qre_MGN_nocpy_R(QreArgsCache *args);
extern void Qre_MGN_nocpy_Z(QreArgsCache *args);
extern void Qre_MGN_nocpy_C(QreArgsCache *args);

#endif /* dsp_qre_sim.h */

/* [EOF] dsp_qre_sim.h  */

