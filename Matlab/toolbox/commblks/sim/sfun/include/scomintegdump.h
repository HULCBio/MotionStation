#ifndef _SCOM_INTEG_DUMP_
#define _SCOM_INTEG_DUMP_

/* SCOMINTEGDUMP.h Header file for scomintegdump sfunction
 * Defines block port, parameters, complex pointer setting 
 * helper macros and helper function declarations.
 * Copyright 1996-2004 The MathWorks, Inc.
 * $Revision: 1.1.6.5 $ $Date: 2004/04/20 23:15:45 $
 */

#include "comm_defs.h"
#include "comm_hs_defs.h"
#include "comm_algo_defs.h"

#include <math.h> /*for fmod*/

/* List input & output ports*/
enum {INPORT=0, NUM_INPORTS=1};
enum {OUTPORT=0, NUM_OUTPORTS=1};

/* List the mask parameters*/
enum {  INTEG_SAMPLES_ARGC =0, 
        OFFSET_SAMPLES_ARGC, 
        OUTPUT_INTER_VALS_ARGC, 
        NUM_ARGS=3};


/* List DWork Variables */
enum { CUMSUM =0, 
       INTEG_CTR, 
       LAST_INTEGRAL,
       OFFSET_CTR, 
       FRAMES_OFFSET, 
       SAMPLES_OFFSETS, 
       CHANNEL_OFFSETS
    };

#define  INTEG_SAMPLES_ARG_PTR(S)	    (ssGetSFcnParam(S,INTEG_SAMPLES_ARGC))
#define  OFFSET_SAMPLES_ARG_PTR(S)     (ssGetSFcnParam(S,OFFSET_SAMPLES_ARGC))
#define  OUTPUT_INTER_VALS_ARG_PTR(S)  (ssGetSFcnParam(S,OUTPUT_INTER_VALS_ARGC))


#define  INTEG_SAMPLES_ARG(S)   	((int_T)mxGetPr(INTEG_SAMPLES_ARG_PTR(S))[0])
#define  OFFSET_SAMPLES_ARG(S)     ((int_T)mxGetPr(OFFSET_SAMPLES_ARG_PTR(S))[0])
#define  OUTPUT_INTER_VALS(S)      ((int_T)mxGetPr(OUTPUT_INTER_VALS_ARG_PTR(S))[0])

#define NOT_TUNABLE 0

#define IS_DUMP_OUTPUT (OUTPUT_INTER_VALS(S) == false)



/* Helper Functions/Macros for Sample based processing
 */

/* Function/Macro   : INTEG_CMPLX_INPUT
 * Description      : *Integrates the complex input sample.
 *                    *Increments the samples integrated counter.
 */

#define INTEG_CMPLX_INPUT(smplsInteg, cumSumCmplx, inSigCmplx) \
{ \
cumSumCmplx->re  += inSigCmplx->re; \
cumSumCmplx->im  += inSigCmplx->im; \
(*smplsInteg)++; \
}

/* Function/Macro   : INTEG_REAL_INPUT
 * Description      : *Integrates the real input sample.
 *                    *Increments the samples integrated counter.
 */

#define INTEG_REAL_INPUT(smplsInteg, cumSumReal, inSigReal) \
{ \
    *cumSumReal += *inSigReal; \
    (*smplsInteg)++; \
}


/* Function/Macro   : RESET_CMPLX_INTEG
 * Description      : Resets the integration in Sample based mode.
 *                    In order to accomodate the one sample delay in multirate 
 *                    mode, the integral at the time of dump 
 *                    is stored in cumSumCmplx[1] and is used in the next 
 *                    outputhit. Is true only for SB dump mode(Multirate mode)
 */
#define RESET_CMPLX_INTEG(cumSumCmplx, lastIntegralCmplx, smplsInteg ) \
{ \
    lastIntegralCmplx->re  = cumSumCmplx->re; \
    lastIntegralCmplx->im  = cumSumCmplx->im; \
    RESET_CREAL_PTR(cumSumCmplx); \
    *smplsInteg = 0; \
}

/* Function/Macro   : RESET_REAL_INTEG
 * Description      : Resets the integration in Sample based mode.
 *                    Inorder to accomodate the one sample delay in multirate
 *                    mode, the integral at the time of dump is  
 *                    stored in cumSumCmplx[1] and is used in the next outputhit. 
 *                    is true only for SB dump mode(Multirate mode)
 */
#define RESET_REAL_INTEG(cumSumReal, lastIntegralReal, smplsInteg) \
{ \
    *lastIntegralReal = *cumSumReal; \
    *cumSumReal = 0.0; \
    *smplsInteg = 0; \
}

/* Function/Macro   : PROCESS_CMPLX_OUTPUT
 * Description      : Sets the output for complex signals based on
 *                    the idx to the cumSum variable.
 *       
 */
#define PROCESS_CMPLX_OUTPUT(cmplxVar, outSigCmplx) \
{ \
    outSigCmplx->re = cmplxVar->re; \
    outSigCmplx->im = cmplxVar->im; \
}

/* Function/Macro   : PROCESS_REAL_OUTPUT
 * Description      : Sets the output for real signals based on
 *                    the idx to the cumSum variable.
 *                    
 */
#define PROCESS_REAL_OUTPUT(realVar, outSigReal) \
{ \
    *outSigReal = *realVar; \
}



/* Helper functions for Frame based work vector initializations
 */

static void initFbCmplxWorkVecs(SimStruct *S, int_T cumSumWidth, int_T numChannels);
static void initFbRealWorkVecs(SimStruct *S, int_T cumSumWidth, int_T numChannels);

/* Helper functions for Frame based real and complex input signal processing.
 */

static void fbCmplxProcess(int_T* smplsInteg, int_T integPeriod, 
                           int_T inRows, int_T offset, 
                           boolean_T dumpOutput, creal_T *cumSum,
                           creal_T *prevFrameIntegral, creal_T *inSig, 
                           creal_T *outSig
                          );

static void fbRealProcess( int_T* smplsInteg, int_T integPeriod, 
                           int_T inRows, int_T offset, 
                           boolean_T dumpOutput, real_T *cumSum,  
                           real_T *prevFrameIntegral, real_T *inSig, 
                           real_T *outSig
                         );

#endif
