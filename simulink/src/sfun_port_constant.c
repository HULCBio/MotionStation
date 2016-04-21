/*
 * File: sfun_port_constant.c
 * Abstract:
 *       A 'C' level 2 S-function that uses port based sample times with
 *       constant sample time. There are two outputs. The first is
 *       the input times the parameter. The second output is the parameter.
 *       The sample time of the second output is constant if inline parameters
 *       is on in the model, and is the input rate otherwise. The sample time of 
 *       the first output matches the input and may be constant.
 *
 *  Copyright 1990-2004 The MathWorks, Inc.
 *  $Revision: 1.4.4.3 $
 */

#define S_FUNCTION_NAME  sfun_port_constant
#define S_FUNCTION_LEVEL 2

#include "simstruc.h"

/*====================*
 * S-function methods *
 *====================*/

#define MDL_CHECK_PARAMETERS
#if defined(MDL_CHECK_PARAMETERS) && defined(MATLAB_MEX_FILE)
/* Function: mdlCheckParameters =============================================
 * Abstract:
 *    Validate that the parameter is a finite real scalar
 */
static void mdlCheckParameters(SimStruct *S)
{
    const mxArray *m = ssGetSFcnParam(S,0);
    
    if (mxGetNumberOfElements(m) != 1 ||
        !mxIsNumeric(m) || !mxIsDouble(m) || mxIsLogical(m) ||
        mxIsComplex(m) || mxIsSparse(m) || !mxIsFinite(mxGetPr(m)[0])) {
        ssSetErrorStatus(S,"The parameter must be a real scalar value.");
        return;
     }
 }
#endif /* MDL_CHECK_PARAMETERS */


/* Function: mdlInitializeSizes ===============================================
 * Abstract:
 *
 *    This S-function has:
 *        - one input
 *        - two outputs 
 *        - one parameter
 *        - no work vectors or states
 *
 */
static void mdlInitializeSizes(SimStruct *S)
{
    int_T nInputPorts  = 1;  /* number of input ports  */
    int_T nOutputPorts = 2;  /* number of output ports */
    int_T needsInput   = 1;  /* direct feed through    */

    ssSetNumSFcnParams(S, 1);  /* Number of expected parameters */
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

    /* Register the number and type of states the S-Function uses */
    ssSetNumContStates(    S, 0);   /* number of continuous states           */
    ssSetNumDiscStates(    S, 0);   /* number of discrete states             */

    /*
     * Configure the input ports. First set the number of input ports. 
     */
    if (!ssSetNumInputPorts(S, nInputPorts)) return;    
    
    /* Simple S-function example only accepts scalar inputs */
    ssSetInputPortWidth(S, 0, 1);

    ssSetInputPortSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetInputPortOffsetTime(S, 0, 0.0);

    /* Need the input in mdlOutputs */
    ssSetInputPortDirectFeedThrough(S, 0, 1);

    /*
     * Configure the output ports. First set the number of output ports.
     */
    if (!ssSetNumOutputPorts(S, nOutputPorts)) return;

    /*
     * Set output port dimensions for each output port index starting at 0.
     * See comments for setting input port dimensions.
     */
    ssSetOutputPortWidth(S,0,1);
    ssSetOutputPortSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOutputPortOffsetTime(S, 0, 0.0);

    ssSetOutputPortWidth(S,1,1);
    /* If inline parameters is on in the model, then the second output port 
     * will have a constant sample time otherwise the second output port will 
     * inherit a sample time. This way the value on the second output port 
     * will be able to keep up with changes in the parameter. We could have set
     * the sample time to be constant and output the initial parameter value.
     */
    if (ssGetInlineParameters(S)) {
        ssSetSFcnParamNotTunable(S,0); /* The parameter isn't tunable if 
                                        * inline params is on */
        ssSetOutputPortSampleTime(S,1,mxGetInf());
        ssSetOutputPortOffsetTime(S,1,0);
    } else {
        ssSetSFcnParamTunable( S, 0, 1 );

        ssSetOutputPortSampleTime(S, 1, INHERITED_SAMPLE_TIME);
        ssSetOutputPortOffsetTime(S, 1, 0.0);
    }

    ssSetNumSampleTimes(S,PORT_BASED_SAMPLE_TIMES);

    /* No work vectors */
    ssSetNumRWork(         S, 0);
    ssSetNumIWork(         S, 0);
    ssSetNumPWork(         S, 0);
    ssSetNumModes(         S, 0);
    ssSetNumNonsampledZCs( S, 0);

    /* Want to be able to use constant sample time on the ports 
     * so specify the option.
     *
     * Note that this will also allow a constant sample time to
     * be propagated to the s-function. If that is not desired it
     * must be caught in mdlSetInputPOrtSampleTime and 
     * mdlSetOutputPortSampleTime.
     */
    ssSetOptions(S,
                 SS_OPTION_WORKS_WITH_CODE_REUSE |
                 SS_OPTION_EXCEPTION_FREE_CODE | 
                 SS_OPTION_ALLOW_CONSTANT_PORT_SAMPLE_TIME);

} /* end mdlInitializeSizes */

#define MDL_SET_INPUT_PORT_SAMPLE_TIME
/*#define MDL_SET_INPUT_PORT_SAMPLE_TIME*/
#if defined(MDL_SET_INPUT_PORT_SAMPLE_TIME) && defined(MATLAB_MEX_FILE)
  /* Function: mdlSetInputPortSampleTime =======================================
   * Abstract:
   *     Set the first output port sample time to be the same as the input 
   *     port sample time. If the model does not have inline parameters, then
   *     also set the second output port sample time. 
   */
static void mdlSetInputPortSampleTime(SimStruct *S,
                                      int_T     portIdx,
                                      real_T    sampleTime,
                                      real_T    offsetTime)
{
    ssSetInputPortSampleTime(S,portIdx,sampleTime);
    ssSetInputPortOffsetTime(S,portIdx,offsetTime);

    ssSetOutputPortSampleTime(S,0,sampleTime);
    ssSetOutputPortOffsetTime(S,0,offsetTime);

    if (!ssGetInlineParameters(S)) {
        ssSetOutputPortSampleTime(S,1,sampleTime);
        ssSetOutputPortOffsetTime(S,1,offsetTime);
    }
} /* end mdlSetInputPortSampleTime */
#endif /* MDL_SET_INPUT_PORT_SAMPLE_TIME */


#define MDL_SET_OUTPUT_PORT_SAMPLE_TIME
/*#define MDL_SET_OUTPUT_PORT_SAMPLE_TIME*/
#if defined(MDL_SET_OUTPUT_PORT_SAMPLE_TIME) && defined(MATLAB_MEX_FILE)
  /* Function: mdlSetOutputPortSampleTime ======================================
   * Abstract:
   *     Set the input port sample time to be the same as the first output
   *     port sample time. If the model does not have inline parameters, then
   *     also set the second output port sample time. 
   */
static void mdlSetOutputPortSampleTime(SimStruct *S,
                                       int_T     portIdx,
                                       real_T    sampleTime,
                                       real_T    offsetTime)
{
    ssSetOutputPortSampleTime(S,portIdx,sampleTime);
    ssSetOutputPortOffsetTime(S,portIdx,offsetTime);

    if (portIdx == 0) {
        ssSetInputPortSampleTime(S,0,sampleTime);
        ssSetInputPortOffsetTime(S,0,offsetTime);
    }

    if (!ssGetInlineParameters(S)) {
        ssSetOutputPortSampleTime(S,(portIdx+1)%2,sampleTime);
        ssSetOutputPortOffsetTime(S,(portIdx+1)%2,offsetTime);
    }

} /* end mdlSetOutputPortSampleTime */
#endif /* MDL_SET_OUTPUT_PORT_SAMPLE_TIME */


/* Function: mdlInitializeSampleTimes =========================================
 * Abstract:
 *      Port based sample times have already been configured, therefore this
 *	method doesn't need to perform any action
 */
static void mdlInitializeSampleTimes(SimStruct *S)
{
#if 0   /* set to 1 to see port sample times */
    const char_T *bpath = ssGetPath(S);
    int_T        i;

    ssPrintf("%s input port %d sample time = [%g, %g]\n", bpath, 0,
             ssGetInputPortSampleTime(S,0),
             ssGetInputPortOffsetTime(S,0));
    
    for (i = 0; i < 2; i++) {
        ssPrintf("%s output port %d sample time = [%g, %g]\n", bpath, i,
                 ssGetOutputPortSampleTime(S,i),
                 ssGetOutputPortOffsetTime(S,i));
    }
#endif
    ssSetModelReferenceSampleTimeDefaultInheritance(S);
} /* end mdlInitializeSampleTimes */

/* Function: mdlOutputs =======================================================
 * Abstract:
 *   The mdlOutputs function will be called once with a tid == CONSTANT_TID
 *   if any of the sample times are constant. (Note that only blocks with 
 *   a constant sample time on one or more ports will have the mdlOutputs
 *   function called with tid == CONSTANT_TID.)
 *
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
    if (tid == CONSTANT_TID) {

        /* If the tid == CONSTANT_TID, we know that for this s-function 
         * the second output port must have a constant sample time
         */
        real_T *y = ssGetOutputPortSignal(S,1);
        y[0] = mxGetPr(ssGetSFcnParam(S,0))[0];

        /* Check if the input port (and so first output) are constant */
        if (ssGetInputPortSampleTimeIndex(S,0) == CONSTANT_TID ) {
            InputRealPtrsType port0Inputs = ssGetInputPortRealSignalPtrs(S,0);
            real_T inputSignal = *port0Inputs[0];
            real_T *y = ssGetOutputPortSignal(S,0);
            y[0] =  mxGetPr(ssGetSFcnParam(S,0))[0] * inputSignal;
        }

    } else {

        /* We know that if we get here the inpout port cannot have 
         * a constant sample time 
         */
        if (ssGetInputPortSampleTime(S,0)==CONTINUOUS_SAMPLE_TIME &&
            ssGetInputPortOffsetTime(S,0)==0.0) {
            if (ssIsMajorTimeStep(S) && ssIsContinuousTask(S,tid)) {
                InputRealPtrsType port0Inputs = 
                    ssGetInputPortRealSignalPtrs(S,0);
                real_T inputSignal = *port0Inputs[0];
                real_T *y = ssGetOutputPortSignal(S,0);
                y[0] =  mxGetPr(ssGetSFcnParam(S,0))[0] * inputSignal;
            }
        } else {
            int inputTid = ssGetInputPortSampleTimeIndex(S,0);
            if (ssIsSampleHit(S, inputTid, tid)) {
                InputRealPtrsType port0Inputs = 
                    ssGetInputPortRealSignalPtrs(S,0);
                real_T inputSignal = *port0Inputs[0];
                real_T *y = ssGetOutputPortSignal(S,0);
                y[0] =  mxGetPr(ssGetSFcnParam(S,0))[0] * inputSignal;
            }
        }

        /* Just as when the sample time is continuous,
         * it is not valid to call ssGetInputPortSampleTimeIndex 
         * if the sample time is constant */
        if (ssGetOutputPortSampleTimeIndex(S,1) != CONSTANT_TID) {
            if (ssGetOutputPortSampleTime(S,1)==CONTINUOUS_SAMPLE_TIME &&
                ssGetOutputPortOffsetTime(S,1)==0.0) {
                if (ssIsMajorTimeStep(S) && ssIsContinuousTask(S,tid)) {
                    real_T *y = ssGetOutputPortSignal(S,1);
                    y[0] =  mxGetPr(ssGetSFcnParam(S,0))[0];
                }
            } else {
                int outputTid = ssGetOutputPortSampleTimeIndex(S,1);
                if (ssIsSampleHit(S, outputTid, tid)) {
                    real_T *y = ssGetOutputPortSignal(S,1);
                    y[0] =  mxGetPr(ssGetSFcnParam(S,0))[0];
                }
            }
        }

    }
} /* end mdlOutputs */

/* Function: mdlTerminate =====================================================
 * Abstract:
 *    Nothing to be done here. 
 */
static void mdlTerminate(SimStruct *S)
{
}


/*=============================*
 * Required S-function trailer *
 *=============================*/

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
