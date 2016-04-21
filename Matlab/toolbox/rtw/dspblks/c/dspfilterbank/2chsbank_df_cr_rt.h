/*
 * @(#)2chsbank_df_cr_rt.h    generated by: makeheader 4.21  Tue Mar 30 16:43:23 2004
 *
 *		built from:	2chsbank_df_cr_rt.c
 */

#ifndef 2chsbank_df_cr_rt_h
#define 2chsbank_df_cr_rt_h

#ifdef __cplusplus
    extern "C" {
#endif

EXPORT_FCN void MWDSP_2ChSBank_DF_CR(
    const creal32_T       *inputToLongFilt, 
    const creal32_T       *inputToShortFilt, 
          creal32_T       *out,
          creal32_T       *longFiltTapBuf,
          creal32_T       *shortFiltTapBuf,              
    const real32_T *const  longFilt,  
    const real32_T *const  shortFilt,          
          int32_T         *longFiltTapIdx, 
          int32_T         *shortFiltTapIdx, 
    const int_T          numChans,
    const int_T          inFrameSize,          
    const int_T          polyphaseLongFiltLen,
    const int_T          polyphaseShortFiltLen
);

#ifdef __cplusplus
    }	/* extern "C" */
#endif

#endif /* 2chsbank_df_cr_rt_h */