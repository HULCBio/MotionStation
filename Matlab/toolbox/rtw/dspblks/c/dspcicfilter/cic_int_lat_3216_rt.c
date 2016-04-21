/* File CIC_INT_LAT_3216_RT.C
 *
 * CIC Interpolation Nonzero-Latency Filter algorithm
 *
 * Copyright 1995-2003 The MathWorks, Inc.
 * $Revision: 1.1.6.3 $ $Date: 2003/12/06 15:54:07 $
 */

#include "dsp_rt.h"
#include "dspciccircbuff_rt.h" /* needed in mwdsp_cic_int_lat_tplt.c code  */
#include "dspintsignext_rt.h"  /* needed in mwdsp_cic_int_lat_tplt.c code  */

/* Nonzero Latency Interpolator
 * 
 * (see header file dspcicfilter_rt.h
 *  for details regarding fcn arguments)
 */
EXPORT_FCN void MWDSP_CICIntLat3216(
    int            R,
    int            N,
    int            nChans,
    int            nFrames,
    const int32_T *inp,
    int16_T       *out,
    int32_T       *states,
    int            statesPerChanSize,
    const int32_T *stgInpWLs,
    int32_T        finalOutShiftVal,
    int            phase,
    int            ioStride)
{

#define MWDSP_CIC_INPTYPE int32_T
#define MWDSP_CIC_OUTTYPE int16_T
#include "mwdsp_cic_int_lat_tplt.c"

}

/* [EOF] */
