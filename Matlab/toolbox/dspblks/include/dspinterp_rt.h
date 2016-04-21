/*
 *  dspinterp_rt.h
 *
 *  Copyright 1995-2004 The MathWorks, Inc.
 *  $Revision: 1.6.4.3 $ $Date: 2004/04/12 23:11:57 $
 */

#ifndef dspinterp_rt_h
#define dspinterp_rt_h

#include "dsp_rt.h"

#ifdef DSPINTERP_EXPORTS
#define DSPINTERP_EXPORT EXPORT_FCN
#else
#define DSPINTERP_EXPORT extern
#endif

/* 
 * Function naming glossary 
 * --------------------------- 
 * 
 * MWDSP = MathWorks DSP Blockset 
 * 
 * Data types - (describe inputs to functions, not outputs) 
 * R = real single-precision 
 * D = real double-precision 
 */ 
 
/* Function naming convention 
 * -------------------------- 
 * 
 * MWDSP_Interp_<MehodUsed>_<DataType> 
 * 
 *    1) MWDSP_ is a prefix used with all Mathworks DSP runtime library 
 *       functions. 
 *    2) The second field indicates that this function is implementing the 
 *       Interpolation algorithm. 
 *    3) The third field is a string indicating the method used for interpolation:
 *       Lin  - Linear interpolation. 
 *       FIR  - FIR  interpolation. 
 *    4) The last field enumerates the data type from the above list. 
 *       Single/double precision are specified within a single letter. 
 *       The data types of the input and output are the same. 
 * 
 *    Examples: 
 *       MWDSP_Interp_Lin_D is the Interpolation run time function for  
 *       double precision inputs using Linear interpolation. 
 */ 
/* Description of the arguments taken by the following functions:-
 * y = pointer to output values at the interpolation points. 
 * u = pointer to input data which is interpolated. 
 * iptr = pointer to interplation points 
 * nSamps = Number of samples in each channel for the input data (u)
 * nChans = Number of channels in input data (u)
 * nSampsI = Number of samples in each channel in the interpolation points input. (iptr) 
 * nChansI = Number of channels in the interpolation points input (iptr)
 * filt    = This argument is used only in the case of FIR interpolation. It is a pointer
             to the FIR filter which is being used for FIR interpolation. 
 * filtlen = Length of filter used in FIR interpolation.
 * nphases = Number of phases of the filter used in FIR interpolation. 
 */
/* datatype double, Linear interpolation */
DSPINTERP_EXPORT void MWDSP_Interp_Lin_D(real_T *y, const real_T * const u, const real_T *iptr,
                               const int_T nSamps, int_T nChans, 
                               const int_T nSampsI, const int_T nChansI);

/* datatype single, Linear interpolation */
DSPINTERP_EXPORT void MWDSP_Interp_Lin_R(real32_T *y, const real32_T * const u, const real32_T *iptr,
                               const int_T nSamps, int_T nChans,
                               const int_T nSampsI, const int_T nChansI);

/* datatype double, FIR interpolation */
DSPINTERP_EXPORT void MWDSP_Interp_FIR_D(real_T *y, const real_T * const u, const real_T *iptr,
                               const int_T nSamps, int_T nChans, const int_T nSampsI, 
                               const int_T nChansI, const real_T * const filt, 
                               const int_T filtlen, const int_T nphases);
/* datatype single, FIR interpolation */
DSPINTERP_EXPORT void MWDSP_Interp_FIR_R(real32_T *y, const real32_T * const u, const real32_T *iptr,
                               const int_T nSamps, int_T nChans, const int_T nSampsI,
                               const int_T nChansI, const real32_T * const filt,
                               const int_T filtlen, const int_T nphases);


#endif /* dspinterp_rt_h */

/* [EOF] dspinterp_rt.h */
