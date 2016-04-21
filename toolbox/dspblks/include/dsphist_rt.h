/*
 *  dsphist_rt.h
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.4.4.3 $ $Date: 2004/04/12 23:11:55 $
 */

#ifndef dsphist_rt_h
#define dsphist_rt_h

#include "dsp_rt.h"

#ifdef DSPHIST_EXPORTS
#define DSPHIST_EXPORT EXPORT_FCN
#else
#define DSPHIST_EXPORT MWDSP_IDECL
#endif

DSPHIST_EXPORT void MWDSP_HistC(
            const creal32_T *u_data,
            real32_T *y,
            int_T nChans,
            int_T nSamps,
            real32_T umin,
            real32_T umax, 
            int_T Nbins,
            real32_T idelta);

DSPHIST_EXPORT void MWDSP_HistD(
            const real_T *u_data,
            real_T *y,
            int_T nChans,
            int_T nSamps,
            real_T umin,
            real_T umax, 
            int_T Nbins,
            real_T idelta);

DSPHIST_EXPORT void MWDSP_HistR(
            const real32_T *u_data,
            real32_T *y,
            int_T nChans,
            int_T nSamps,
            real32_T umin,
            real32_T umax, 
            int_T Nbins,
            real32_T idelta);

DSPHIST_EXPORT void MWDSP_HistZ(
            const creal_T *u_data,
            real_T *y,
            int_T nChans,
            int_T nSamps,
            real_T umin,
            real_T umax, 
            int_T Nbins,
            real_T idelta);

/* The binary search functions must be called with 
 * [1] lastBin > firstBin 
 * [2] bin boundaries arranged in ascending order
 * Arguments:
 * firstBin : index of first histogram bin
 * lastBin  : index of last histogram bin
 * data     : to be assigned into bins indexed between first and last inclusive
 * bin      : array of histogram bin boundaries (for a total of NBin-1 entries,
 *            excluding minimum and maximum values).
 * hist     : array for storing histogram results 
 */
DSPHIST_EXPORT void MWDSP_Hist_BinSearch_S32(       int_T       firstBin, 
                                                    int_T       lastBin, 
                                                    int32_T     data, 
                                              const int32_T     *bin,
                                                    uint32_T    *hist   );

DSPHIST_EXPORT void MWDSP_Hist_BinSearch_S16(       int_T       firstBin, 
                                                    int_T       lastBin, 
                                                    int16_T     data, 
                                              const int16_T     *bin,
                                                    uint32_T    *hist   );

DSPHIST_EXPORT void MWDSP_Hist_BinSearch_S08(       int_T       firstBin, 
                                                    int_T       lastBin, 
                                                    int8_T      data, 
                                              const int8_T      *bin,
                                                    uint32_T    *hist   );

DSPHIST_EXPORT void MWDSP_Hist_BinSearch_U32(       int_T       firstBin, 
                                                    int_T       lastBin, 
                                                    uint32_T    data, 
                                              const uint32_T    *bin,
                                                    uint32_T    *hist   );

DSPHIST_EXPORT void MWDSP_Hist_BinSearch_U16(       int_T       firstBin, 
                                                    int_T       lastBin, 
                                                    uint16_T    data, 
                                              const uint16_T    *bin,
                                                    uint32_T    *hist   );

DSPHIST_EXPORT void MWDSP_Hist_BinSearch_U08(       int_T       firstBin, 
                                                    int_T       lastBin, 
                                                    uint8_T     data, 
                                              const uint8_T     *bin,
                                                    uint32_T    *hist   );

#ifdef MWDSP_INLINE_DSPRTLIB
#include "dsphist/hist_c_rt.c"
#include "dsphist/hist_d_rt.c"
#include "dsphist/hist_r_rt.c"
#include "dsphist/hist_z_rt.c"
#include "dsphist/hist_binsearch_s32_rt.c"
#include "dsphist/hist_binsearch_s16_rt.c"
#include "dsphist/hist_binsearch_s08_rt.c"
#include "dsphist/hist_binsearch_u32_rt.c"
#include "dsphist/hist_binsearch_u16_rt.c"
#include "dsphist/hist_binsearch_u08_rt.c"
#endif

#endif /* dsphist_rt_h */

/* [EOF] dsphist_rt.h */

