/*
 * @(#)rc2lpc_d_rt.h    generated by: makeheader 4.21  Tue Mar 30 16:43:35 2004
 *
 *		built from:	rc2lpc_d_rt.c
 */

#ifndef rc2lpc_d_rt_h
#define rc2lpc_d_rt_h

#ifdef __cplusplus
    extern "C" {
#endif

EXPORT_FCN void MWDSP_Rc2Lpc_D(
        const real_T *rc,       /* pointer to input port which contains the reflection coefficients */
        real_T       *lpc,      /* pointer to output port holding the LP coefficients */
        const int_T   P         /* Order of LPC polynomial */
       );

#ifdef __cplusplus
    }	/* extern "C" */
#endif

#endif /* rc2lpc_d_rt_h */