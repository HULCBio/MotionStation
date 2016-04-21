/*
 * SDSPSREG  Shift register S-function.
 * DSP Blockset S-Function to shift contents of a memory register
 * and store input samples into start of register. Vector inputs
 * are stored into independent shift register.
 *
 *  Copyright 1995-2002 The MathWorks, Inc.
 *  $Revision: 1.21 $  $Date: 2002/04/14 20:44:22 $
 */
#define S_FUNCTION_NAME sdspsreg
#define S_FUNCTION_LEVEL 2

#include "dsp_sim.h"

enum { INPORT=0,   NUM_INPORTS };
enum { OUTPORT=0,  NUM_OUTPORTS };
enum { BUFF_IDX=0, NUM_DWORKS };

enum { REG_SIZE_ARGC=0, IC_ARGC, NUM_ARGS };
#define REG_SIZE_ARG ssGetSFcnParam(S, REG_SIZE_ARGC)
#define IC_ARG       ssGetSFcnParam(S, IC_ARGC)

#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S) {
    if OK_TO_CHECK_VAR(S, REG_SIZE_ARG) {
        if ( (mxGetM(REG_SIZE_ARG) != 1) || (mxGetN(REG_SIZE_ARG) != 1) ) {
            THROW_ERROR(S, "The register size must be a scalar.");
        }
        else if ( !IS_FLINT_GE(REG_SIZE_ARG, 1) ) {
            THROW_ERROR(S, "The register size must be a real, scalar integer > 0.");
        }
    }

    if OK_TO_CHECK_VAR(S, IC_ARG) {
        if (!mxIsNumeric(IC_ARG)) {
            THROW_ERROR(S, "Initial conditions must be numeric.");
        }
    }
}
#endif


static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumSFcnParams(S, NUM_ARGS);

#if defined(MATLAB_MEX_FILE)
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) return;
    mdlCheckParameters(S);
    if (ssGetErrorStatus(S) != NULL) return;
#endif

    ssSetSFcnParamNotTunable(S, REG_SIZE_ARGC);
    ssSetSFcnParamNotTunable(S, IC_ARGC);

    if (!ssSetNumInputPorts(S, NUM_INPORTS)) return;
    ssSetInputPortWidth(            S, INPORT, DYNAMICALLY_SIZED);
    ssSetInputPortComplexSignal(    S, INPORT, COMPLEX_INHERITED);
    ssSetInputPortDirectFeedThrough(S, INPORT, 1);
    ssSetInputPortReusable(         S, INPORT, 1);
    ssSetInputPortOverWritable(     S, INPORT, 0);

    if (!ssSetNumOutputPorts(    S, NUM_OUTPORTS)) return;
    ssSetOutputPortWidth(        S, OUTPORT, DYNAMICALLY_SIZED);
    ssSetOutputPortComplexSignal(S, OUTPORT, COMPLEX_INHERITED);
    ssSetOutputPortReusable(     S, OUTPORT, 1);

    if(!ssSetNumDWork(  S, DYNAMICALLY_SIZED)) return;

    ssSetNumSampleTimes(S, 1);
    ssSetOptions(       S, SS_OPTION_EXCEPTION_FREE_CODE | 
                        SS_OPTION_USE_TLC_WITH_ACCELERATOR);
}


static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, FIXED_IN_MINOR_STEP_OFFSET);
}


#define MDL_INITIALIZE_CONDITIONS
static void mdlInitializeConditions(SimStruct *S)
{
    const int_T  numIC  = mxGetNumberOfElements(IC_ARG);
    const int_T  nChans = ssGetInputPortWidth(S, INPORT);
    const int_T  regsiz = (int_T)(mxGetPr(REG_SIZE_ARG)[0]);
    const int_T  reglen = nChans * regsiz;
    int_T        i;
    int_T        j;

    /* Preset output buffers to initial conditions: */

    if (ssGetInputPortComplexSignal(S, INPORT) == COMPLEX_YES) {
        /* Complex input port signal: */
        real_T  *prIC   = mxGetPr(IC_ARG);
        real_T  *piIC   = mxGetPi(IC_ARG);
        creal_T *outBuf = (creal_T *)ssGetDWork(S, BUFF_IDX);

        const boolean_T ic_cplx = (boolean_T)(piIC != NULL);

        if (numIC <= 1) {
            /* Scalar expansion, or no IC's given: */
            creal_T ic;

            if (numIC == 0) {
                ic.re = 0.0;
                ic.im = 0.0;
            }
            else {
                ic.re = *prIC;
                ic.im = (ic_cplx) ? *piIC : 0.0;
            }

            for(i = 0; i < reglen; i++) {
                *outBuf++ = ic;
            }
        }
        else if (numIC == regsiz) {
            /* Same IC's for all channels: */
            if (ic_cplx) {
                for (i=0; i<nChans; i++) {
                    for (j=0; j<regsiz; j++) {
                        outBuf->re     = *prIC++;
                        (outBuf++)->im = *piIC++;
                    }

                    prIC -= regsiz;
                    piIC -= regsiz;
                }
            }
            else {
                for(i = 0; i < nChans; i++) {
                    for(j=0; j<regsiz; j++) {
                        outBuf->re     = *prIC++;
                        (outBuf++)->im = 0.0;
                    }

                    prIC -= regsiz;
                }
            }
        }
        else {
            /* Matrix of IC's: */
            if (ic_cplx) {
                for(i = 0; i < reglen; i++) {
                    outBuf->re     = *prIC++;
                    (outBuf++)->im = *piIC++;
                }
            }
            else {
                for(i = 0; i < reglen; i++) {
                    outBuf->re     = *prIC++;
                    (outBuf++)->im = 0.0;
                }
            }
        }
    }
    else {
        /* Real input port signal: */
        real_T *pIC    = (real_T *)mxGetPr(IC_ARG);
        real_T *outBuf = (real_T *)ssGetDWork(S, BUFF_IDX);

        if (numIC <= 1) {
            /* Scalar expansion, or no IC's given: */
            real_T ic = (numIC == 0) ? 0.0 : *pIC;

            for(i = 0; i < reglen; i++) {
                *outBuf++ = ic;
            }
        }
        else if (numIC == regsiz) {
            /* Same IC's for all channels: */	
            for(i = 0; i < nChans; i++) {
                memcpy(outBuf, pIC, regsiz*sizeof(real_T));
                outBuf += regsiz;
            }
        }
        else {
            /* Matrix of IC's: */
            memcpy(outBuf, pIC, reglen*sizeof(real_T));
        }
    }
}


static void mdlOutputs(SimStruct *S, int_T tid)
{
    const int_T     nChans  = ssGetInputPortWidth(S, INPORT);
    const int_T     regsiz  = (int_T)(mxGetPr(REG_SIZE_ARG)[0]);
    const int_T     reglen  = regsiz * nChans;
    const boolean_T cplx    = (ssGetInputPortComplexSignal(S, INPORT) == COMPLEX_YES);

    if (cplx) {
        /* Complex input port data: */
        creal_T *outBuf = (creal_T *)ssGetDWork(S, BUFF_IDX);

        /* shift all but the last sample in each buffer column up by one
         * For simplicity, we move ALL samples up by one
         */
        {
            creal_T *p0 = outBuf;
            creal_T *p1 = p0 + 1;
            int_T    i;

            for(i=0; i++ < reglen-1; ) {
                *p0++ = *p1++;
            }
        }

        /* Place input in last element of register for each channel*/
        {
            creal_T      *p0   = outBuf - 1;
            InputPtrsType uptr = ssGetInputPortSignalPtrs(S, INPORT);
            int_T         i;

            for (i = 0; i++ < nChans; ) {
                *(p0+=regsiz) = *((creal_T *)(*uptr++));
            }
        }

        /* Copy contents of buffer to the output */
        {
            creal_T *y = (creal_T *)ssGetOutputPortSignal(S, OUTPORT);

            memcpy((char_T *)y, (char_T *)outBuf, reglen*sizeof(creal_T));
        }

    }

    else {
        /* Real input port data: */
        real_T *outBuf = (real_T *)ssGetDWork(S, BUFF_IDX);

        /* shift all but the last sample in each buffer column up by one
         * For simplicity, we move ALL samples up by one
         */
        {
            real_T *p0 = outBuf;
            real_T *p1 = p0 + 1;
            int_T   i;

            for(i=0; i++ < reglen-1; ) {
                *p0++ = *p1++;
            }
        }

        /* Place input in last element of register for each channel*/
        {
            real_T            *p0   = outBuf - 1;
            InputRealPtrsType  uptr = ssGetInputPortRealSignalPtrs(S, INPORT);
            int_T              i;

            for (i = 0; i++ < nChans; ) {
                *(p0+=regsiz) = **uptr++;
            }
        }

        /* Copy contents of buffer to the output */
        {
            real_T *y = ssGetOutputPortRealSignal(S, OUTPORT);
            memcpy((char_T *)y, (char_T *)outBuf, reglen*sizeof(real_T));
        }
    }
}


static void mdlTerminate(SimStruct *S)
{
}


#if defined(MATLAB_MEX_FILE)
#define MDL_SET_INPUT_PORT_WIDTH
static void mdlSetInputPortWidth(SimStruct *S, int_T port,
                                  int_T inputPortWidth)
{
    const int_T regsiz = (int_T)(mxGetPr(REG_SIZE_ARG)[0]);

    ssSetInputPortWidth( S, INPORT,  inputPortWidth);
    ssSetOutputPortWidth(S, OUTPORT, inputPortWidth * regsiz);
}


#define MDL_SET_OUTPUT_PORT_WIDTH
static void mdlSetOutputPortWidth(SimStruct *S, int_T port,
                                   int_T outputPortWidth)
{
    const int_T regsiz = (int_T)(mxGetPr(REG_SIZE_ARG)[0]);
    int_T       inWidth = outputPortWidth / regsiz;

    ssSetOutputPortWidth(S, OUTPORT, outputPortWidth);

    if (inWidth * regsiz != outputPortWidth) {
        ssSetErrorStatus(S, "Output vector width inconsistent with buffer size and number of channels.");
        return;
    }
    ssSetInputPortWidth(S, INPORT, inWidth);
}


#define MDL_SET_WORK_WIDTHS
static void mdlSetWorkWidths(SimStruct *S)
{
    const CSignal_T cplx   = ssGetInputPortComplexSignal(S, INPORT);
    const int_T     nChans = ssGetInputPortWidth(S, INPORT);
    const int_T     regsiz = (int_T)(mxGetPr(REG_SIZE_ARG)[0]);
    const int_T     reglen = nChans * regsiz;
    const int_T     numIC  = mxGetNumberOfElements(IC_ARG);

    if(!ssSetNumDWork(      S, NUM_DWORKS)) return;
    ssSetDWorkWidth(        S, BUFF_IDX, reglen);
    ssSetDWorkDataType(     S, BUFF_IDX, SS_DOUBLE);
    ssSetDWorkComplexSignal(S, BUFF_IDX, cplx);
    ssSetDWorkName(         S, BUFF_IDX, "Buff");
    ssSetDWorkUsedAsDState( S, BUFF_IDX, 1);


    /* Can finally check the initial conditions argument: */
    if ((numIC != 0) && (numIC != 1)	/* scalar */
	     && (numIC != regsiz)	/* vector */
	     && (numIC != reglen)) {    /* matrix */
        ssSetErrorStatus(S, "Initial condition vector has incorrect dimensions.");
	return;
    }
    if (!cplx && mxIsComplex(IC_ARG)) {
        ssSetErrorStatus(S, "Complex initial conditions are not allowed with real shift register block inputs.");
        return;
    }
}

#endif


#define MDL_RTW
#if defined(MATLAB_MEX_FILE) || defined(NRT)
static void mdlRTW(SimStruct *S)
{
    int_T   numIC   = mxGetNumberOfElements(IC_ARG);
    real_T *ICr     = mxGetPr(IC_ARG);
    real_T *ICi     = mxGetPi(IC_ARG);
    real_T  dummy   = 0.0;
    int32_T regSiz  = (int32_T)mxGetPr(REG_SIZE_ARG)[0];

    if (numIC == 0) {
        /* SSWRITE_VALUE_*_VECT does not support empty vectors */
        numIC = 1;
        ICr = ICi = &dummy;
    }
     
    if (!ssWriteRTWParamSettings(S, 2, 
                                 SSWRITE_VALUE_DTYPE_NUM,"RegSiz",
                                 &regSiz,
                                 DTINFO(SS_INT32,0),
                                 
                                 SSWRITE_VALUE_DTYPE_ML_VECT, "IC", ICr, ICi, 
                                 numIC, 
                                 DTINFO(SS_DOUBLE, mxIsComplex(IC_ARG)))) {
        return;
    }
}
#endif


/* Complex handshake: */
#include "dsp_cplxhs11.c"

#ifdef	MATLAB_MEX_FILE
#include "simulink.c"
#else
#include "cg_sfun.h" 
#endif
