/*
 * File : sfun_multirate.c
 * Abstract:
 *      Multiple port, multi-rate S-function example. This S-function accepts
 *	two input signals and produces three outputs:
 *
 *				        .------------.
 *	   ---- enable signal    -----> |            |--- s / k1 ---->
 *	   ---- source signal, s -----> | S-function |--- s / k2 ---->
 *					|            |--- s / k3 ---->
 *				        `------------'
 *
 *	Three positive non-zero integer parameters must be supplied, k1, k2, k3.
 *	The source signal must be a multiple of the enable signal (otherwise
 *	the block won't function correctly in multitasking mode since we
 *	run the fastest tasks first). All signals are scalar. In addition
 *	the source signal must be discrete without an offset.
 *
 *	When enabled (i.e. enable signal is greater than zero), the output
 *	is the source signal decimated by the respective constant (k1, k2, or
 *	k3). If the constant is 1 for a given output port, then the output
 *	signal is equal to the source signal.
 *
 *	This block is designed to be used with fixed-step solvers (solver mode
 *	multitasking), thus there is no finding of the zero crossing location
 *	for the enable signal.
 *
 *  See simulink/src/sfuntmpl_doc.c
 *
 *  Copyright 1990-2004 The MathWorks, Inc.
 *  $Revision: 1.17.4.4 $
 */


/*
 * You must specify the S_FUNCTION_NAME as the name of your S-function.
 */

#define S_FUNCTION_NAME  sfun_multirate
#define S_FUNCTION_LEVEL 2

/*
 * Need to include simstruc.h for the definition of the SimStruct and
 * its associated macro definitions.
 */
#include <string.h>
#include <math.h>
#include "simstruc.h"

/*================*
 * Build checking *
 *================*/
#if !defined(MATLAB_MEX_FILE)
/*
 * This file cannot be used directly with the Real-Time Workshop. However,
 * this S-function does work with the Real-Time Workshop via
 * the Target Language Compiler technology. See 
 * matlabroot/toolbox/simulink/blocks/tlc_c/sfun_multirate.tlc   
 * for the C version
 * matlabroot/toolbox/simulink/blocks/tlc_ada/sfun_multirate.tlc 
 * for the Ada version
 */
# error This_file_can_be_used_only_during_simulation_inside_Simulink
#endif

/*=========*
 * Defines *
 *=========*/

#define K1_IDX 0
#define K1_PARAM(S) ssGetSFcnParam(S,K1_IDX)

#define K2_IDX 1
#define K2_PARAM(S) ssGetSFcnParam(S,K2_IDX)

#define K3_IDX 2
#define K3_PARAM(S) ssGetSFcnParam(S,K3_IDX)

#define NKPARAMS 3

#define OPTIONAL_TS_IDX 3
#define OPTIONAL_TS_PARAM(S) ssGetSFcnParam(S,OPTIONAL_TS_IDX)

#define NTOTALPARAMS 4


#define NINPUTS  2
#define NOUTPUTS 3


#define ENABLE_IPORT 0   /* port 1 */
#define SIGNAL_IPORT 1   /* port 2 */



/*====================*
 * S-function methods *
 *====================*/

#define MDL_CHECK_PARAMETERS
#if defined(MDL_CHECK_PARAMETERS) && defined(MATLAB_MEX_FILE)
  /* Function: mdlCheckParameters =============================================
   * Abstract:
   *    Validate our parameters to verify they are okay.
   */
  static void mdlCheckParameters(SimStruct *S)
  {
      int  i;
      bool badParam = false;

      /* All parameters must be positive non-zero integers */
      for (i = 0; i < ssGetSFcnParamsCount(S); i++) {
          const mxArray *m = ssGetSFcnParam(S,i);

          if (mxGetNumberOfElements(m) != 1 ||
              !mxIsNumeric(m) || !mxIsDouble(m) || mxIsLogical(m) ||
              mxIsComplex(m) || mxIsSparse(m) || !mxIsFinite(mxGetPr(m)[0])) {
              badParam = true;
              break;
          }
          if (i < NKPARAMS) {
              int ival;
              if (((ival=(int_T)mxGetPr(m)[0]) <= 0) ||
                  (real_T)ival != mxGetPr(m)[0]) {
                  badParam = true;
                  break;
              }
          } else if (mxGetPr(m)[0] <= 0.0) {
              badParam = true;
              break;
          }
      }

      if (badParam) {
          ssSetErrorStatus(S,"All parameters must be positive non-zero "
                           "values. First three must be integers and the "
                           "optional fourth must be a discrete sample "
                           "time");
          return;
      }
  }
#endif /* MDL_CHECK_PARAMETERS */



/* Function: mdlInitializeSizes ===============================================
 * Abstract:
 *    Call mdlCheckParameters to verify that the parameters are okay,
 *    then setup sizes of the various vectors.
 *
 *    We specify 2 input and 3 output ports with inherited port based sample 
 *    times.
 */
static void mdlInitializeSizes(SimStruct *S)
{
    int_T  i;
    real_T ts;

    /* See sfuntmpl_doc.c for more details on the macros below */

    /* Set number of expected parameters */
    if (ssGetSFcnParamsCount(S) == NKPARAMS ||
        ssGetSFcnParamsCount(S) == NTOTALPARAMS) {
        ssSetNumSFcnParams(S, ssGetSFcnParamsCount(S));
    } else {
        ssSetNumSFcnParams(S, NKPARAMS);
    }
#if defined(MATLAB_MEX_FILE)
    if (ssGetNumSFcnParams(S) == ssGetSFcnParamsCount(S)) {
        mdlCheckParameters(S);
        if (ssGetErrorStatus(S) != NULL) {
            return;
        }
    } else {
        return; /* Parameter mismatch will be reported by Simulink */
    }
#endif

    /* Parameters can't be tuned */
    ssSetSFcnParamNotTunable(S,K1_IDX);
    ssSetSFcnParamNotTunable(S,K2_IDX);
    ssSetSFcnParamNotTunable(S,K3_IDX);

    /* Load ts for input and output ports */
    if (ssGetNumSFcnParams(S) == NTOTALPARAMS) {
        ssSetSFcnParamNotTunable(S,OPTIONAL_TS_IDX);
        ts = mxGetPr(OPTIONAL_TS_PARAM(S))[0];
    } else {
        ts = INHERITED_SAMPLE_TIME;
    }

    ssSetNumSampleTimes(S, PORT_BASED_SAMPLE_TIMES);

    /* Two inputs */
    if (!ssSetNumInputPorts(S, NINPUTS)) return;

    for (i = 0; i < NINPUTS; i++) {
        ssSetInputPortWidth(S, i, 1);
        ssSetInputPortDirectFeedThrough(S, i, 1);
        ssSetInputPortSampleTime(S, i, ts);
        ssSetInputPortOffsetTime(S, i, 0.0);
        ssSetInputPortOverWritable(S, i, 0); /* Output is decimated! */
    }

    /*
     * We are always looking at the enable input in the correct task so we can
     * optimize away this entry from the block I/O.
     */
    ssSetInputPortOptimOpts(S, ENABLE_IPORT, SS_REUSABLE_AND_LOCAL);

    /*
     * We are always looking at the enable input in the correct task so we can
     * optimize away this entry from the block I/O.
     */
    ssSetInputPortOptimOpts(S, SIGNAL_IPORT, SS_REUSABLE_AND_LOCAL);

    /* Three outputs */
    if (!ssSetNumOutputPorts(S, NOUTPUTS)) return;
    for (i = 0; i < NOUTPUTS; i++) {
        ssSetOutputPortWidth(S, i, 1);
        ssSetOutputPortOptimOpts(S, i, SS_NOT_REUSABLE_AND_GLOBAL);
                                           /* Need to be persistent since the
                                              since we don't update the
                                              outputs at every sample hit
                                              for this block */
        if (ts == INHERITED_SAMPLE_TIME) {
            ssSetOutputPortSampleTime(S, i, ts);
        } else {
            ssSetOutputPortSampleTime(S, i, ts*mxGetPr(ssGetSFcnParam(S,i))[0]);
        }
        ssSetOutputPortOffsetTime(S, i, 0.0);
    }

    ssSetNumIWork(S, 1);

    /* Take care when specifying exception free code - see sfuntmpl_doc.c */
    ssSetOptions(S,
                 SS_OPTION_WORKS_WITH_CODE_REUSE |
                 SS_OPTION_EXCEPTION_FREE_CODE |
                 SS_OPTION_USE_TLC_WITH_ACCELERATOR);

} /* end mdlInitializeSizes */



#if defined(MATLAB_MEX_FILE)
/* Function CheckInputSampleTimes ==============================================
 * Abstract:
 *	We know both input sample times, now verify that the make sense
 *	(see top of file).
 */
static void CheckInputSampleTimes(SimStruct *S)
{
    real_T enableTs = ssGetInputPortSampleTime(S, ENABLE_IPORT);
    real_T signalTs = ssGetInputPortSampleTime(S, SIGNAL_IPORT);
    int   enableTid = ssGetInputPortSampleTimeIndex(S,ENABLE_IPORT);

    if (enableTs != CONTINUOUS_SAMPLE_TIME) {
        /* signal must be a multiple of the enable */
        real_T k        = floor(signalTs/enableTs+0.5);
        
        if (k < 1.0 ||
            fabs(k - signalTs/enableTs) > mxGetEps()*128.0) {
            ssSetErrorStatus(S, "Sample time of source signal (port 2) "
                             "must be a positive multiple of enable "
                             "(port 1) signal");
            return;
        }
    } 

    if (enableTid == CONSTANT_TID) {
        ssSetErrorStatus(S, "Constant sample time is not allowed "
                         "at enable port (port 1)");
        return;
    }

} /* end CheckInputSampleTimes */
#endif



#define MDL_SET_INPUT_PORT_SAMPLE_TIME
#if defined(MDL_SET_INPUT_PORT_SAMPLE_TIME) && defined(MATLAB_MEX_FILE)
/* Function: mdlSetInputPortSampleTime =========================================
 * Abstract:
 *	When asked by Simulink, set the sample time of the enable or
 *	signal port. If we know both sample times, also set the output
 *	port sample times.
 */
static void mdlSetInputPortSampleTime(SimStruct *S,
                                      int_T     portIdx,
                                      real_T    sampleTime,
                                      real_T    offsetTime)
{

    /*************************************
     * Check for valid input sample time *
     *************************************/

    if (portIdx == ENABLE_IPORT) {
        /*
         * Enable signal port
         */
        if (offsetTime != 0.0) {
            ssSetErrorStatus(S,"Enable (port 1) signal must be fed by a signal "
                             "with a sample time that doesn't have an offset");
            return;
        }

    } else {
        /*
         * source signal port (i.e. signal to be decimated). The sample time
         * of this signal must be discrete (constant equates to inf,
         * continuous equates to zero).
         */

        if (sampleTime <= 0.0) {
            ssSetErrorStatus(S,"Source signal (port 2) must be fed by a "
                             "discrete signal");
            return;
        }

        if (offsetTime != 0.0) {
            ssSetErrorStatus(S,"Source signal (port 2) must be fed by a siganl "
                             "with a sample time that doesn't have an offset");
            return;
        }

        /*
         * Set output port sample times. Note, we are assured that all output
         * port sample times are unknown since when the output port sample
         * time routine is called, all sample times will be set.
         *
         * (note offset is already zero for inherited sample time)
         */

        {
            int_T  i;
            real_T k[NOUTPUTS];

            k[0] = mxGetPr(K1_PARAM(S))[0];
            k[1] = mxGetPr(K2_PARAM(S))[0];
            k[2] = mxGetPr(K3_PARAM(S))[0];

            for (i = 0; i < NOUTPUTS; i++) {
                ssSetOutputPortSampleTime(S, i, sampleTime*k[i]);
                ssSetOutputPortOffsetTime(S, i, 0.0);
            }
        }
    }

    ssSetInputPortSampleTime(S, portIdx, sampleTime);
    ssSetInputPortOffsetTime(S, portIdx, offsetTime);

    if (ssGetInputPortSampleTime(S, (portIdx+1) % 2) != INHERITED_SAMPLE_TIME) {
        CheckInputSampleTimes(S);
    }

} /* end mdlSetInputPortSampleTime */
#endif



#define MDL_SET_OUTPUT_PORT_SAMPLE_TIME
#if defined(MDL_SET_OUTPUT_PORT_SAMPLE_TIME) && defined(MATLAB_MEX_FILE)
/* Function: mdlSetOutputPortSampleTime ========================================
 * Abstract:
 *	When asked by Simulink, set the sample time of the specified output
 *	port. This occurs when back propagating sample times (see sfuntmpl_doc.c).
 *
 *	When called to set one sample time, we set them all. 
 *	We also verify that the 
 */
static void mdlSetOutputPortSampleTime(SimStruct *S,
                                      int_T     portIdx,
                                      real_T    sampleTime,
                                      real_T    offsetTime)
{

    /***********************************************************************
     * Output sample time must be discrete and we don't support discrete " *
     * offsets.								   *
     ***********************************************************************/

    if (sampleTime <= 0.0 || offsetTime != 0.0) {
        ssSetErrorStatus(S,"This block must back-inherit to the output ports "
                           "a discrete (zero-offset) signal");
        return;
    }

    /*******************************************************************
     * Set all output and input sample times. Note enable port is only *
     * port which may have a known sample time.                        *
     *******************************************************************/
    {
        real_T k[NOUTPUTS];
        real_T signalTs;
        int_T  i;

        k[0] = mxGetPr(K1_PARAM(S))[0];
        k[1] = mxGetPr(K2_PARAM(S))[0];
        k[2] = mxGetPr(K3_PARAM(S))[0];

        signalTs = sampleTime/k[portIdx];

        for (i = 0; i < NOUTPUTS; i++) {
            ssSetOutputPortSampleTime(S, i, signalTs*k[i]);
            ssSetOutputPortOffsetTime(S, i, 0.0);
        }

        ssSetInputPortSampleTime(S, SIGNAL_IPORT, signalTs);
        ssSetInputPortOffsetTime(S, SIGNAL_IPORT, offsetTime);

        if (ssGetInputPortSampleTime(S, ENABLE_IPORT) == INHERITED_SAMPLE_TIME){
            ssSetInputPortSampleTime(S, ENABLE_IPORT, signalTs);
        } else {
            CheckInputSampleTimes(S);
        }
    }
    

} /* end mdlSetOutputPortSampleTime */
#endif


/* Function: mdlInitializeSampleTimes =========================================
 * Abstract:
 *      Port based sample times have already been configured, therefore this
 *	method doesn't need to perform any action (you can check the
 *	current port sample times).
 */
static void mdlInitializeSampleTimes(SimStruct *S)
{
#if 0   /* set to 1 to see port sample times */
    const char_T *bpath = ssGetPath(S);
    int_T        i;

    for (i = 0; i < NINPUTS; i++) {
        ssPrintf("%s input port %d sample time = [%g, %g]\n", bpath, i,
                 ssGetInputPortSampleTime(S,i),
                 ssGetInputPortOffsetTime(S,i));
    }

    for (i = 0; i < NOUTPUTS; i++) {
        ssPrintf("%s output port %d sample time = [%g, %g]\n", bpath, i,
                 ssGetOutputPortSampleTime(S,i),
                 ssGetOutputPortOffsetTime(S,i));
    }
#endif
    ssSetModelReferenceSampleTimeDefaultInheritance(S); 
} /* end mdlInitializeSampleTimes */



/* Function: mdlOutputs =======================================================
 * Abstract:
 *
 *      y1 = "sum" * "gain" where sum operation is defined by a list of
 *           '+' and '-' characters.
 *      y2 = "modified" average of the input signals (i.e. sum/nInputPorts).
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
    InputRealPtrsType enablePtrs;
    int               *enabled = ssGetIWork(S);
    int enableTid = ssGetInputPortSampleTimeIndex(S,ENABLE_IPORT);
    int signalTid = ssGetInputPortSampleTimeIndex(S,SIGNAL_IPORT);
    real_T enableTs       = ssGetInputPortSampleTime(S,ENABLE_IPORT);
    real_T enableTsOffset = ssGetInputPortOffsetTime(S,ENABLE_IPORT);
    if (enableTs == CONTINUOUS_SAMPLE_TIME && enableTsOffset == 0.0) {
        if (ssIsMajorTimeStep(S) && ssIsContinuousTask(S,tid)) {
            if (signalTid == enableTid ||
                ssIsSpecialSampleHit(S, signalTid, enableTid, tid)) {
                enablePtrs = ssGetInputPortRealSignalPtrs(S,ENABLE_IPORT);
                *enabled = (*enablePtrs[0] > 0.0);
            }
        }
    } else {
        int enableTid = ssGetInputPortSampleTimeIndex(S,ENABLE_IPORT);
        if (ssIsSampleHit(S, enableTid, tid)) {
            if (enableTid == signalTid || 
                ssIsSpecialSampleHit(S, signalTid, enableTid, tid)) {
                enablePtrs = ssGetInputPortRealSignalPtrs(S,ENABLE_IPORT);
                *enabled = (*enablePtrs[0] > 0.0);
            }
        }
    }

    if (ssIsSampleHit(S, signalTid, tid) && (*enabled)) {
        InputRealPtrsType uPtrs  = ssGetInputPortRealSignalPtrs(S,SIGNAL_IPORT);
        real_T            signal = *uPtrs[0];
        int               i;
        
        for (i = 0; i < NOUTPUTS; i++) {
            int outTid = ssGetOutputPortSampleTimeIndex(S,i);
            if (outTid==signalTid || 
                ssIsSpecialSampleHit(S, outTid, signalTid, tid)) {
                real_T *y = ssGetOutputPortRealSignal(S,i);
                *y = signal;
            }
        }
    }

} /* end mdlOutputs */



/* Function: mdlTerminate =====================================================
 * Abstract:
 *      Free the user data.
 */
static void mdlTerminate(SimStruct *S)
{
}



#if defined(MATLAB_MEX_FILE)
#define MDL_RTW
/* Function: mdlRTW ===========================================================
 * Abstract:
 *	Since we've declared all are parameters as non-tunable, we need
 *	only provide this routine so that they aren't written to the model.rtw
 *	file. The values of the parameters are implicitly encoded in the
 *	sample times.
 */
static void mdlRTW(SimStruct *S)
{
}
#endif /* MDL_RTW */


/*=============================*
 * Required S-function trailer *
 *=============================*/

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
