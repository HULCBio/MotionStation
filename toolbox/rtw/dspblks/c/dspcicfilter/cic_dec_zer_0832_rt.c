/* File CIC_DEC_ZER_0832_RT.C
 *
 * CIC Decimation Zero-Latency Filter algorithm
 *
 * Copyright 1995-2003 The MathWorks, Inc.
 * $Revision: 1.1.6.2 $ $Date: 2003/07/10 19:55:29 $
 */

#include "dsp_rt.h"
#include "dspciccircbuff_rt.h" /* needed in mwdsp_cic_dec_zer_tplt.c code  */
#include "dspintsignext_rt.h"  /* needed in mwdsp_cic_dec_zer_tplt.c code  */

/* Zero-Latency Decimator
 * 
 * (see header file dspcicfilter_rt.h
 *  for details regarding fcn arguments)
 */
EXPORT_FCN void MWDSP_CICDecZer0832(
    int            R,
    int            N,
    int            nChans,
    int            nFrames,
    const int8_T  *inp,
    int32_T       *out,
    int32_T       *states,
    int            statesPerChanSize,
    const int32_T *stgInpWLs,
    const int32_T *stgShifts,
    int            phase,
    int            ioStride)
{

#define MWDSP_CIC_INPTYPE int8_T
#define MWDSP_CIC_OUTTYPE int32_T
#include "mwdsp_cic_dec_zer_tplt.c"

}

/* [EOF] */
