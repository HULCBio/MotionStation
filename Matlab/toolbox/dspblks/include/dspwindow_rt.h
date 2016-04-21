/*
 *  dspwindow_rt.h
 *
 *  Copyright 1995-2004 The MathWorks, Inc.
 *  $Revision: 1.14.4.3 $ $Date: 2004/04/12 23:12:21 $
 */

#ifndef dspwindow_rt_h
#define dspwindow_rt_h

#include "dsp_rt.h"

#ifdef DSPWINDOW_EXPORTS
#define DSPWINDOW_EXPORT EXPORT_FCN
#else
#define DSPWINDOW_EXPORT extern
#endif

#ifdef __cplusplus
extern "C" {
#endif


/* 
 * List of individual window functions:
 *
 * Note that individual functions are classified according to 
 * Single and Multi channel rather than Frame and Non-Frame.
 * (Even for Non-Frame multi channel case, we were using the function
 * for Frame-based, hence the change)
 */
DSPWINDOW_EXPORT void MWDSP_Window1chD(int_T nRows, real_T   *y, const real_T   *u, real_T   *w);    /* double  out, Single Channel Real Double in */
DSPWINDOW_EXPORT void MWDSP_Window1chR(int_T nRows, real32_T *y, const real32_T *u, real32_T *w);    /* single  out, Single Channel Real single in */

DSPWINDOW_EXPORT void MWDSP_Window1chZ(int_T nRows, creal_T   *y, const creal_T   *u, real_T   *w);  /* double  out, Single Channel Complex Double in */
DSPWINDOW_EXPORT void MWDSP_Window1chC(int_T nRows, creal32_T *y, const creal32_T *u, real32_T *w);  /* single  out, Single Channel Complex single in */

DSPWINDOW_EXPORT void MWDSP_WindowNchD(int_T nRows, int_T nChans, real_T   *y, const real_T   *u, real_T   *winPtr); /* double  out, Multi Channel Real in */
DSPWINDOW_EXPORT void MWDSP_WindowNchR(int_T nRows, int_T nChans, real32_T *y, const real32_T *u, real32_T *winPtr); /* single  out, Multi Channel Real in */

DSPWINDOW_EXPORT void MWDSP_WindowNchZ(int_T nRows, int_T nChans, creal_T   *y, const creal_T   *u, real_T   *winPtr);    /* double  out, Multi Channel Complex in */
DSPWINDOW_EXPORT void MWDSP_WindowNchC(int_T nRows, int_T nChans, creal32_T *y, const creal32_T *u, real32_T *winPtr);    /* single  out, Multi Channel Complex in */


/* -----------------------------
 * Common copy macro source code
 * -----------------------------
 */

/* SChan:- Single Channel, real */
#define SChan_REAL               \
    int_T i = nRows;             \
    while(i-- > 0) {             \
        *y++ = (*u++) * (*w++);  \
    }



/* SChan:- Single Channel, complex */
#define SChan_COMPLEX                 \
    int_T i = nRows;                  \
    while(i-- > 0) {                  \
        y->re     = u->re     * *w;   \
        (y++)->im = (u++)->im * *w++; \
    }                                           


/* MChan:- Multi Channel, real */
#define MChan_REAL(wintype)          \
    int_T nchans = nChans;           \
    while(nchans-- > 0) {            \
        wintype *w = winPtr;         \
        int_T     i = nRows;         \
        while(i-- > 0) {             \
            *y++ = (*u++) * (*w++);  \
        }                            \
    }

/* MChan:- Multi Channel, complex */
#define MChan_COMPLEX(wintype)            \
    int_T       nchans = nChans;          \
    while(nchans-- > 0) {                 \
        wintype *w = winPtr;              \
        int_T    i = nRows;               \
        while(i-- > 0) {                  \
            y->re     = u->re     * *w;   \
            (y++)->im = (u++)->im * *w++; \
        }                                 \
    }




#ifdef __cplusplus
}
#endif


#endif /* dspwindow_rt_h */


