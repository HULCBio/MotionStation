/*
 *  dspfilterbank_rt.h
 *
 *  Abstract: Header file for DSP run-time library helper functions
 *  for DWT/IDWT and other filter bank blocks.
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.4.4.3 $ $Date: 2004/04/12 23:11:49 $ */

#ifndef dspfilterbank_rt_h
#define dspfilterbank_rt_h

#include "dsp_rt.h"

#ifdef DSPFILTERBANK_EXPORTS
#define DSPFILTERBANK_EXPORT EXPORT_FCN
#else
#define DSPFILTERBANK_EXPORT MWDSP_IDECL
#endif

/* FILTER BANK BLOCKS IMPLEMENTATION
 * Description: 
 * Implements a DWT or IDWT filter bank.
 *
 * The runtime functions are:
 * - MWDSP_2ChA[S]Bank_Fr_DF_DD[RR]
 * - MWDSP_2ChA[S]Bank_Fr_DF_ZD[CR]
 * - MWDSP_2ChA[S]Bank_Fr_DF_ZZ[CC]
 *
 * Their naming conventions are:
 * A[S]Bank = Analysis / Synthesis Bank
 * Fr = frame-based inputs
 * DF = implements Direct Form FIR
 *
 * Based on the data-types, we have:-
 * D = double-precision real data-type.
 * R = single-precision real data-type
 * Z = double-precision complex data-type.
 * C = single-precision complex data-type. 
 * The first letter refers to the input port data type.
 * The second letter refers to filter coefficient data type.
 *
 * The input arguments to these functions are: 
 * - *u :  
 *   Pointer to input frame data
 * - *filtLongOutput and *filtShorOutput : 
 *   Two pointers to memory stacks for storing results 
 *   produced by filtLong and filtShort, both stacks of size half of the input data frame.
 * - *tap0 :
 *   This is implemented as a circular buffer to hold input sample (for each channel).
 *   Its per channel length is equal to max(high-pass FIR length, low-pass FIR length). 
 * - *sums :
 *   There are two scalar partial sums per channel stored in the partialSums buffer.
 *   They are used for holding the intermediate sums in FIR direct form implementation
 *   of the low-pass and high-pass filters.
 * - *filtLong and *filtShort :
 *   Two filter coefficient pointers *filtLong and *filtShort corresponding to
 *   a high and low pass filters.  The coefficients are assumed to be arranged
 *   into the correct phase order (refer to dspfirdn_rt.h for explanation).
 * plus other self-explaining arguments. 
 *
 * These run-time functions are implemented using direct form FIR polyphase 
 * implementations.  For implementation details, refer to the fully commented
 * functions MWDSP_2ChABank_Fr_DF_DD and MWDSP_2ChSBank_Fr_DF_DD.
 *
 */

/* Two channel analysis subband filter */
DSPFILTERBANK_EXPORT void MWDSP_2ChABank_Fr_DF_DD(
    const real_T        *u,      
          real_T        *filtLongOutput,
          real_T        *filtShortOutput,            
          real_T        *tap0,              
          real_T        *sums,              
    const real_T *const  filtLong,  
    const real_T *const  filtShort,          
          int32_T         *tapIdx,            
          int32_T         *phaseIdx,
    const int_T          numChans,
    const int_T          inFrameSize,
    const int_T          polyphaseFiltLenLong,
    const int_T          polyphaseFiltLenShort
);

DSPFILTERBANK_EXPORT void MWDSP_2ChABank_Fr_DF_RR(
    const real32_T        *u,      
          real32_T        *filtLongOutput,
          real32_T        *filtShortOutput,            
          real32_T        *tap0,              
          real32_T        *sums,              
    const real32_T *const  filtLong,  
    const real32_T *const  filtShort,          
          int32_T          *tapIdx,            
          int32_T          *phaseIdx,
    const int_T           numChans,
    const int_T           inFrameSize,
    const int_T           polyphaseFiltLenLong,
    const int_T           polyphaseFiltLenShort
);


DSPFILTERBANK_EXPORT void MWDSP_2ChABank_Fr_DF_ZD(
    const creal_T       *u,      
          creal_T       *filtLongOutput,
          creal_T       *filtShortOutput,            
          creal_T       *tap0,              
          creal_T       *sums,              
    const real_T *const  filtLong,  
    const real_T *const  filtShort,          
          int32_T         *tapIdx,            
          int32_T         *phaseIdx,
    const int_T          numChans,
    const int_T          inFrameSize,
    const int_T          polyphaseFiltLenLong,
    const int_T          polyphaseFiltLenShort
);

DSPFILTERBANK_EXPORT void MWDSP_2ChABank_Fr_DF_ZZ(
    const creal_T        *u,      
          creal_T        *filtLongOutput,
          creal_T        *filtShortOutput,            
          creal_T        *tap0,              
          creal_T        *sums,              
    const creal_T *const  filtLong,  
    const creal_T *const  filtShort,          
          int32_T          *tapIdx,            
          int32_T          *phaseIdx,
    const int_T           numChans,
    const int_T           inFrameSize,
    const int_T           polyphaseFiltLenLong,
    const int_T           polyphaseFiltLenShort
);


DSPFILTERBANK_EXPORT void MWDSP_2ChABank_Fr_DF_CR(
    const creal32_T       *u,      
          creal32_T       *filtLongOutput,
          creal32_T       *filtShortOutput,            
          creal32_T       *tap0,              
          creal32_T       *sums,              
    const real32_T *const  filtLong,  
    const real32_T *const  filtShort,          
          int32_T          *tapIdx,            
          int32_T          *phaseIdx,
    const int_T           numChans,
    const int_T           inFrameSize,
    const int_T           polyphaseFiltLenLong,
    const int_T           polyphaseFiltLenShort
);

DSPFILTERBANK_EXPORT void MWDSP_2ChABank_Fr_DF_CC(
    const creal32_T        *u,      
          creal32_T        *filtLongOutput,
          creal32_T        *filtShortOutput,            
          creal32_T        *tap0,              
          creal32_T        *sums,              
    const creal32_T *const  filtLong,  
    const creal32_T *const  filtShort,          
          int32_T           *tapIdx,            
          int32_T           *phaseIdx,
    const int_T            numChans,
    const int_T            inFrameSize,
    const int_T            polyphaseFiltLenLong,
    const int_T            polyphaseFiltLenShort
);

/* Two channel synthesis bank */

DSPFILTERBANK_EXPORT void MWDSP_2ChSBank_DF_DD(
    const real_T        *inputToLongFilt, 
    const real_T        *inputToShortFilt, 
          real_T        *out,
          real_T        *longFiltTap,
          real_T        *shortFiltTap,              
    const real_T *const  longFilt,  
    const real_T *const  shortFilt,          
          int32_T         *longFiltTapIdx, 
          int32_T         *shortFiltTapIdx, 
    const int_T          numChans,
    const int_T          inFrameSize,          
    const int_T          polyphaseLongFiltLen,
    const int_T          polyphaseShortFiltLen
);

DSPFILTERBANK_EXPORT void MWDSP_2ChSBank_DF_ZD(
    const creal_T       *inputToLongFilt, 
    const creal_T       *inputToShortFilt, 
          creal_T       *out,
          creal_T       *longFiltTap,
          creal_T       *shortFiltTap,              
    const real_T *const  longFilt,  
    const real_T *const  shortFilt,          
          int32_T         *longFiltTapIdx, 
          int32_T         *shortFiltTapIdx, 
    const int_T          numChans,
    const int_T          inFrameSize,          
    const int_T          polyphaseLongFiltLen,
    const int_T          polyphaseShortFiltLen
);

DSPFILTERBANK_EXPORT void MWDSP_2ChSBank_DF_ZZ(
    const creal_T        *inputToLongFilt, 
    const creal_T        *inputToShortFilt, 
          creal_T        *out,
          creal_T        *longFiltTap,
          creal_T        *shortFiltTap,              
    const creal_T *const  longFilt,  
    const creal_T *const  shortFilt,          
          int32_T          *longFiltTapIdx, 
          int32_T          *shortFiltTapIdx, 
    const int_T           numChans,
    const int_T           inFrameSize,          
    const int_T           polyphaseLongFiltLen,
    const int_T           polyphaseShortFiltLen
);

DSPFILTERBANK_EXPORT void MWDSP_2ChSBank_DF_RR(
    const real32_T        *inputToLongFilt, 
    const real32_T        *inputToShortFilt, 
          real32_T        *out,
          real32_T        *longFiltTap,
          real32_T        *shortFiltTap,              
    const real32_T *const  longFilt,  
    const real32_T *const  shortFilt,          
          int32_T           *longFiltTapIdx, 
          int32_T           *shortFiltTapIdx, 
    const int_T            numChans,
    const int_T            inFrameSize,          
    const int_T            polyphaseLongFiltLen,
    const int_T            polyphaseShortFiltLen
);

DSPFILTERBANK_EXPORT void MWDSP_2ChSBank_DF_CR(
    const creal32_T       *inputToLongFilt, 
    const creal32_T       *inputToShortFilt, 
          creal32_T       *out,
          creal32_T       *longFiltTap,
          creal32_T       *shortFiltTap,              
    const real32_T *const  longFilt,  
    const real32_T *const  shortFilt,          
          int32_T           *longFiltTapIdx, 
          int32_T           *shortFiltTapIdx, 
    const int_T            numChans,
    const int_T            inFrameSize,          
    const int_T            polyphaseLongFiltLen,
    const int_T            polyphaseShortFiltLen
);

DSPFILTERBANK_EXPORT void MWDSP_2ChSBank_DF_CC(
    const creal32_T        *inputToLongFilt, 
    const creal32_T        *inputToShortFilt, 
          creal32_T        *out,
          creal32_T        *longFiltTap,
          creal32_T        *shortFiltTap,              
    const creal32_T *const  longFilt,  
    const creal32_T *const  shortFilt,          
          int32_T            *longFiltTapIdx, 
          int32_T            *shortFiltTapIdx, 
    const int_T             numChans,
    const int_T             inFrameSize,          
    const int_T             polyphaseLongFiltLen,
    const int_T             polyphaseShortFiltLen
);

#ifdef MWDSP_INLINE_DSPRTLIB
#include "dspfilterbank/2chabank_fr_df_cc_rt.c"
#include "dspfilterbank/2chabank_fr_df_cr_rt.c"
#include "dspfilterbank/2chabank_fr_df_dd_rt.c"
#include "dspfilterbank/2chabank_fr_df_rr_rt.c"
#include "dspfilterbank/2chabank_fr_df_zd_rt.c"
#include "dspfilterbank/2chabank_fr_df_zz_rt.c"
#include "dspfilterbank/2chsbank_df_cc_rt.c"
#include "dspfilterbank/2chsbank_df_cr_rt.c"
#include "dspfilterbank/2chsbank_df_dd_rt.c"
#include "dspfilterbank/2chsbank_df_rr_rt.c"
#include "dspfilterbank/2chsbank_df_zd_rt.c"
#include "dspfilterbank/2chsbank_df_zz_rt.c"
#endif

#endif  /* dspfilterbank_rt_h */

/* [EOF] dspfilterbank_rt.h */
