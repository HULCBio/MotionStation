/*  Simulation support header file for QR Solver block which computes 
 *  a minimum norm residual solution x to a*x=b
 * 
 *  Copyright 1995-2002 The MathWorks, Inc.
 *  $Revision: 1.1 $  $Date: 2002/01/16 20:37:35 $
 */
#ifndef dsp_qreslv_sim_h
#define dsp_qreslv_sim_h

#include "dsp_sim.h"
#include "dspqrdc_rt.h"

/*
 * Argument and function pointer caches:
 */
typedef union  {real_T D; real32_T R;} DblSgl;

typedef struct {
    int_T	    m;     /* Number of rows of input signal A*/
    int_T	    n;     /* Number of columns of input signal A */
    int_T       p;     /* Number of columns of input signal B */
    int_T       mn;    /* Product of n and m */
    int_T       NminusM; /* MAX((n-m),0) */
    const void *ain;    /* Pointer to input port A */
    const void *bin;    /* Pointer to input port B */
    void       *xout;   /* Pointer to output port X*/ 
    void       *qraux; /* Pointer to DWork QRAux */
    void       *qr;     /* Pointer to DWork QR */
    void	   *bx;    /* Pointer to DWork BX */
    void	   *work;  /* Pointer to DWork Work */
    int_T	   *jpvt;  /* Pointer to IWork */
    DblSgl      epsVal; /* Value of epselon*/
} QreslvArgsCache;  


typedef void (*QreslvFcn)(QreslvArgsCache *args);

typedef struct {
    QreslvArgsCache Args;
    QreslvFcn       QreslvFcnPtr;    /* Pointer to function */
} SFcnCache;

/* 
 * Simulation support functions for the QR Solver block. 
 * cpy  -> Same memory space is utilized by input port B and output port X.
 * nocpy -> Different memory space is utlized by input port B and output port X.
 * Datatype is denoted by D -> double precision real
 *                        R -> single precision real
 *                        Z -> double precision complex
 *                        C -> single precision complex
 * In the sequence "RC" , the first datatype symbol "R" represent datatype of Input Port A 
 * and                    the second datatype symbol "C" represent datatype of Input Port B          
 */
extern void Qreslv_nocpy_DD(QreslvArgsCache *args);     
extern void Qreslv_nocpy_RR(QreslvArgsCache *args);
extern void Qreslv_nocpy_DZ(QreslvArgsCache *args);     
extern void Qreslv_nocpy_RC(QreslvArgsCache *args);
extern void Qreslv_nocpy_ZD(QreslvArgsCache *args);     
extern void Qreslv_nocpy_CR(QreslvArgsCache *args);
extern void Qreslv_nocpy_ZZ(QreslvArgsCache *args);     
extern void Qreslv_nocpy_CC(QreslvArgsCache *args);

extern void Qreslv_cpy_DD(QreslvArgsCache *args);       
extern void Qreslv_cpy_RR(QreslvArgsCache *args);
extern void Qreslv_cpy_DZ(QreslvArgsCache *args);      
extern void Qreslv_cpy_RC(QreslvArgsCache *args);
extern void Qreslv_cpy_ZD(QreslvArgsCache *args);      
extern void Qreslv_cpy_CR(QreslvArgsCache *args);       
extern void Qreslv_cpy_ZZ(QreslvArgsCache *args);      
extern void Qreslv_cpy_CC(QreslvArgsCache *args);

#endif /* dsp_qreslv_sim.h */

/* [EOF] dsp_qreslv_sim.h  */

