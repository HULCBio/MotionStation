/*
 *  dsppoly2lsp_rt.h
 *
 *  Copyright 1995-2004 The MathWorks, Inc.
 *  $Revision: 1.2.4.3 $ $Date: 2004/04/12 23:12:08 $
 */

#ifndef dsppoly2lsp_rt_h
#define dsppoly2lsp_rt_h

#include "dsp_rt.h"

#ifdef DSPPOLY2LSF_EXPORTS
#define DSPPOLY2LSF_EXPORT EXPORT_FCN
#else
#define DSPPOLY2LSF_EXPORT extern
#endif

/* 
 * List of individual Poly2Lsp functions:-
 */

DSPPOLY2LSF_EXPORT int_T MWDSP_Poly2Lsp_D( real_T   *lsp, real_T   *G1, real_T   *G2, const int_T NSteps, const int_T NBisects, const int_T M1, const int_T M2,real_T   *bptr               );
DSPPOLY2LSF_EXPORT int_T MWDSP_Poly2Lsfr_D(real_T   *lsp, real_T   *G1, real_T   *G2, const int_T NSteps, const int_T NBisects, const int_T M1, const int_T M2,real_T   *bptr, const int_T P);
DSPPOLY2LSF_EXPORT int_T MWDSP_Poly2Lsfn_D(real_T   *lsp, real_T   *G1, real_T   *G2, const int_T NSteps, const int_T NBisects, const int_T M1, const int_T M2,real_T   *bptr, const int_T P);
DSPPOLY2LSF_EXPORT int_T MWDSP_Poly2Lsp_R( real32_T *lsp, real32_T *G1, real32_T *G2, const int_T NSteps, const int_T NBisects, const int_T M1, const int_T M2,real32_T *bptr               );
DSPPOLY2LSF_EXPORT int_T MWDSP_Poly2Lsfr_R(real32_T *lsp, real32_T *G1, real32_T *G2, const int_T NSteps, const int_T NBisects, const int_T M1, const int_T M2,real32_T *bptr, const int_T P);
DSPPOLY2LSF_EXPORT int_T MWDSP_Poly2Lsfn_R(real32_T *lsp, real32_T *G1, real32_T *G2, const int_T NSteps, const int_T NBisects, const int_T M1, const int_T M2,real32_T *bptr, const int_T P);


#endif /* dsppoly2lsp_rt_h */

/* [EOF] dsppoly2lsp_rt.h */
