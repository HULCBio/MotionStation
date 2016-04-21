/*
 * $Revision: 1.20.4.5 $
 * $RCSfile: fcncallgen.c,v $
 *
 * Abstract:
 *   Function-call generator/iterator block executes function-call subsystems
 *   ntimes at the designated rate (sample time).
 *
 *  Authors:
 *     Pete Szpak,    29 Jul 1998
 *     Mojdeh Shakeri,29 Oct 1999
 *
 *  Copyright 1990-2004 The MathWorks, Inc.
 */

#define S_FUNCTION_NAME  fcncallgen
#define S_FUNCTION_LEVEL 2


#include "simstruc.h"

/* use utility function IsRealMatrix() */
#if defined(MATLAB_MEX_FILE)
#include "sfun_slutils.h"
#endif

enum {SAMPLE_TIME_ARGC, COUNTS_ARGC, NUM_ARGS};

#define SAMPLE_TIME (ssGetSFcnParam(S,SAMPLE_TIME_ARGC))
#define COUNTS_ARG  (ssGetSFcnParam(S, COUNTS_ARGC))

#ifndef MATLAB_MEX_FILE
/*
 * This file cannot be used directly with the Real-Time Workshop. However,
 * this S-function does work with the Real-Time Workshop via
 * the Target Language Compiler technology. See
 * matlabroot/toolbox/simulink/blocks/tlc_c/fcncallgen.tlc.
 */
# error This_file_can_be_used_only_during_simulation_inside_Simulink
#endif

/*====================*
 * S-function methods *
 *====================*/

#define EDIT_OK(S, ARG) \
       (!((ssGetSimMode(S) == SS_SIMMODE_SIZES_CALL_ONLY) && mxIsEmpty(ARG)))

#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S)
{
    /* Note, when the sample time parameter is specified as a variable and
     * it doesn't exist, then the parameter will be []. We don't error
     * out if we are doing a "sizes call only". This is compatible with
     * Simulink.
     */

    if (EDIT_OK(S, SAMPLE_TIME)){
        real_T sampleTime;
        /* Sample time must be a real scalar value. */
        if (IsRealMatrix(SAMPLE_TIME) &&
            mxGetM(SAMPLE_TIME) == 1  &&
            mxGetN(SAMPLE_TIME) == 1) {
            sampleTime = (real_T) (*(mxGetPr(SAMPLE_TIME)));
        } else {
            sampleTime = -10.0; /* force error */
        }

        /* sampleTime == -1  : triggered
         * sampleTime == 0   : continuous
         * sampleTime > 0    : discrete
         */
        if (sampleTime < 0.0 && sampleTime != -1.0) {
            ssSetErrorStatus(S, "Invalid sample time.");
            return;
        }
    }

    /* Check count value. It must be a scalar integer value */
    if (EDIT_OK(S, COUNTS_ARG)){
        boolean_T isOk = IsRealMatrix(COUNTS_ARG);
        if (isOk) {
            int_T  num     = mxGetNumberOfElements(COUNTS_ARG);
            real_T *counts = mxGetPr(COUNTS_ARG);
            int_T  i;
            for (i = 0 ; i < num; ++i){
                isOk = (((real_T)((int_T)counts[i]) - counts[i] ) == 0);
                if (!isOk) break;

                isOk = (counts[i] > 0);
                if (!isOk) break;
            }
        }
        if (!isOk) {
            ssSetErrorStatus(S, "Invalid number of iterations. "
                             "Number of iterations must be a matrix with "
                             "positive integer elements.");
            return;
        }
    }
}


static void mdlInitializeSizes(SimStruct *S)
{
    int i;
    ssSetNumSFcnParams(S, NUM_ARGS);

#if defined(MATLAB_MEX_FILE)
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) return;
    mdlCheckParameters(S);
    if (ssGetErrorStatus(S) != NULL) return;
#endif

    /* Cannot change params while running: */
    for( i = 0; i < NUM_ARGS; ++i){
        ssSetSFcnParamNotTunable(S, i);
    }

    if(!ssSetNumInputPorts(S, 0)) return;

    if(!ssSetNumOutputPorts(S, 1)) return;

    if(EDIT_OK(S, COUNTS_ARG) &&
        !(mxGetM(COUNTS_ARG) == 1 && mxGetN(COUNTS_ARG) == 1)){

        int_T m = mxGetM(COUNTS_ARG);
        int_T n = mxGetN(COUNTS_ARG);
        if( m == 1 || n == 1){
            int width = m * n;
            if(!ssSetOutputPortVectorDimension(S, 0, width)) return;
        }else{
            if(!ssSetOutputPortMatrixDimensions(S, 0, m, n)) return;
        }
    }else{
        if(!ssSetOutputPortDimensionInfo(S, 0, DYNAMIC_DIMENSION)) return;
    }

    ssSetNumSampleTimes(S, 1);
    ssSetOptions(S, (SS_OPTION_EXCEPTION_FREE_CODE |
                     SS_OPTION_PROPAGATE_COMPOSITE_SYSTEM |
                     SS_OPTION_WORKS_WITH_CODE_REUSE |
                     SS_OPTION_USE_TLC_WITH_ACCELERATOR));
    ssSetEnableFcnIsTrivial(S,1);
    ssSetDisableFcnIsTrivial(S,1);
    ssSetExplicitFCSSCtrl(S,1);


}

static void mdlInitializeSampleTimes(SimStruct *S)
{
    int_T i;
    real_T sampleTime = (real_T) (*(mxGetPr(SAMPLE_TIME)));

    ssSetSampleTime(S, 0, sampleTime);
    ssSetOffsetTime(S, 0, (sampleTime == CONTINUOUS_SAMPLE_TIME?
                           FIXED_IN_MINOR_STEP_OFFSET: 0.0));

    for(i = 0; i < ssGetOutputPortWidth(S,0); i++) {
        ssSetCallSystemOutput(S,i);
    }
    ssSetModelReferenceSampleTimeDefaultInheritance(S);
}

static void mdlOutputs(SimStruct *S, int_T tid)
{
    int_T  i, j;
    int_T  width   = ssGetOutputPortWidth(S,0);
    real_T *counts = mxGetPr(COUNTS_ARG);
    int_T  cInc    = (mxGetNumberOfElements(COUNTS_ARG) == 1)? 0 : 1;

    for(i = 0; i < width; i++, counts += cInc) {
        for(j = 0; j < (int_T)(*counts); ++j){
            if (!ssCallSystemWithTid(S,i,tid)) {
                return; /* error handled by Simulink */
            }
        }

    }
}

static void mdlTerminate(SimStruct *S) {}

#if defined(MATLAB_MEX_FILE)
#define MDL_RTW
static void mdlRTW(SimStruct *S)
{
    real_T  *counts = mxGetPr(COUNTS_ARG);
    int_T   numElms = mxGetNumberOfElements(COUNTS_ARG);
    if(!ssWriteRTWParamSettings(S, 1,
                                SSWRITE_VALUE_VECT,
                                "Counter",
                                counts,
                                numElms)) {
        return; /* error handled by Simulink */
    }
}
#endif

#define MDL_ENABLE
static void mdlEnable(SimStruct *S)
{
    int_T  i, j;
    int_T  width   = ssGetOutputPortWidth(S,0);

    for(i = 0; i < width; i++) {
        if (!ssEnableSystemWithTid(S,i,0)) {
            return; /* error handled by Simulink */
        }
    }
}

#define MDL_DISABLE
static void mdlDisable(SimStruct *S)
{
    int_T  i, j;
    int_T  width   = ssGetOutputPortWidth(S,0);

    for(i = 0; i < width; i++) {
        if (!ssDisableSystemWithTid(S,i,0)) {
            return; /* error handled by Simulink */
        }
    }
}

#ifdef  MATLAB_MEX_FILE
#include "simulink.c"
#else
#include "cg_sfun.h"
#endif

/* EOF: fcncallgen.c */
