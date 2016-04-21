/* $Revision: 1.4.4.1 $ */
/*
 * File: sfun_port_triggered.c
 * Abstract:
 *   A 'C' level 2 S-function that uses port based sample times
 *   and may be placed in a triggered subsystem. Note that triggered
 *   subsystem in this context includes all triggered-like subsystems
 *   for example, for, while, and function call subsystems.
 *
 *   This s-function has one integer parameter. It passes the input 
 *   through to its output every parameter inputs. 
 *   
 *   For example, if the parameter is 3 and the inputs are as shown:
 *
 *   time  input output
 *    0       0    0
 *    1     0.2      
 *    2     0.4        
 *    3     0.6    0.6
 *    4     0.8
 *    5     1.0
 *    6     1.2    1.2
 *
 */

#define S_FUNCTION_NAME  sfun_port_triggered
#define S_FUNCTION_LEVEL 2

#include <math.h>
#include "simstruc.h"

/*====================================================================*
 * Parameter handling methods. These methods are not supported by RTW *
 *====================================================================*/

#define MDL_CHECK_PARAMETERS
#if defined(MDL_CHECK_PARAMETERS) && defined(MATLAB_MEX_FILE)
/* Function: mdlCheckParameters =============================================
 * Abstract:
 *    Validate that the parameter is a positive finite integer scalar
 */
static void mdlCheckParameters(SimStruct *S)
{
    int ival;
    bool badParam = false;
    
    /* All parameters must be positive non-zero integers */
    const mxArray *m = ssGetSFcnParam(S,0);
    
    if (mxGetNumberOfElements(m) != 1 ||
        !mxIsNumeric(m) || !mxIsDouble(m) || mxIsLogical(m) ||
        mxIsComplex(m) || mxIsSparse(m) || !mxIsFinite(mxGetPr(m)[0])) {

        badParam = true;
    } else if (((ival=(int_T)mxGetPr(m)[0]) <= 0) ||
        (real_T)ival != mxGetPr(m)[0]) {
        badParam = true;
    }

    if (badParam) {
        ssSetErrorStatus(S,"The parameter must be a positive non-zero "
                         "integer value.");
        return;
    }
 }
#endif /* MDL_CHECK_PARAMETERS */

/*=====================================*
 * Configuration and execution methods *
 *=====================================*/

/* Function: mdlInitializeSizes ===============================================
 * Abstract:
 *
 *    This S-function has:
 *        - one input
 *        - one output
 *        - one parameter
 *        - one integer work vector 
 *        - no states
 *
 */
static void mdlInitializeSizes(SimStruct *S)
{
    int_T nInputPorts  = 1;  /* number of input ports  */
    int_T nOutputPorts = 1;  /* number of output ports */
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
    ssSetSFcnParamNotTunable(S,0); /* The parameter is not tunable */

    /* No continuous or discrete states */
    ssSetNumContStates(S,0);
    ssSetNumDiscStates(S,0);

    /* 
     * Configure the input port 
     */
    if (!ssSetNumInputPorts(S, nInputPorts)) return;    
    /* Simple S-function example only accepts scalar inputs */
    ssSetInputPortWidth(S, 0, 1);

    ssSetInputPortSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetInputPortOffsetTime(S, 0, 0.0);

    /* Need the input in mdlOutputs */
    ssSetInputPortDirectFeedThrough(S, 0, 1);

    /* Configure the scalar output port */
    if (!ssSetNumOutputPorts(S, nOutputPorts)) return;
    ssSetOutputPortWidth(S,0,1);
    ssSetOutputPortSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOutputPortOffsetTime(S, 0, 0.0);

    ssSetNumSampleTimes(S,PORT_BASED_SAMPLE_TIMES);

    /*
     * Need one IWork vector to keep track of how many times the block
     * has been triggered since the last output
     */
    ssSetNumRWork(         S, 0);   /* number of real work vector elements   */
    ssSetNumIWork(         S, 1);   /* number of integer work vector elements*/
    ssSetNumPWork(         S, 0);   /* number of pointer work vector elements*/
    ssSetNumModes(         S, 0);   /* number of mode work vector elements   */
    ssSetNumNonsampledZCs( S, 0);   /* number of nonsampled zero crossings   */

    /* The option SS_OPTION_ALLOW_PORT_SAMPLE_TIME_IN_TRIGSS lets simulink 
     * know that this port based sample time S-Function may be placed inside 
     * a triggered subsystem. If an s-function with port based sample times 
     * that does not specify this option is placed in a triggered subsystem 
     * an error will be reported.
     */
    ssSetOptions(S,
                 SS_OPTION_WORKS_WITH_CODE_REUSE |
                 SS_OPTION_EXCEPTION_FREE_CODE |
                 SS_OPTION_ALLOW_PORT_SAMPLE_TIME_IN_TRIGSS);

} /* end mdlInitializeSizes */

#define MDL_SET_INPUT_PORT_SAMPLE_TIME
#if defined(MDL_SET_INPUT_PORT_SAMPLE_TIME) && defined(MATLAB_MEX_FILE)
/* Function mdlSetInputPortSampleTime =========================================
 * Abstract:
 *    Set the input port sample time and then set the output port sample time
 *    to the appropriate slower rate or triggered.
 */
static void mdlSetInputPortSampleTime(SimStruct *S,
                                      int_T     portIdx,
                                      real_T    sampleTime,
                                      real_T    offsetTime)
{
    ssSetInputPortSampleTime(S,portIdx,sampleTime);
    ssSetInputPortOffsetTime(S,portIdx,offsetTime);

    /* If the sample and offset are triggered then the block is being 
     * triggered and all of the sample times can be set to triggered.
     *
     * Note that in a different s-function it may be desirable for one
     * or more ports to have constant sample time. That is also permissible. 
     * See the "Constant sample time on ports" demo for information about
     * having a constant port sample time.
     */
    if (ssSampleAndOffsetAreTriggered(sampleTime,offsetTime)) {
        ssSetOutputPortSampleTime(S,0,sampleTime);
        ssSetOutputPortOffsetTime(S,0,offsetTime);
    } else {
        /* The block is not in a triggered context and so we set the 
         * output port sample time to be a multiple of the input port 
         * sample time
         */
        ssSetOutputPortSampleTime(S,0,sampleTime 
                                  * mxGetPr(ssGetSFcnParam(S,0))[0]);
        ssSetOutputPortOffsetTime(S,0,offsetTime);
    }
}
#endif /* MDL_SET_INPUT_PORT_SAMPLE_TIME */


#define MDL_SET_OUTPUT_PORT_SAMPLE_TIME
#if defined(MDL_SET_OUTPUT_PORT_SAMPLE_TIME) && defined(MATLAB_MEX_FILE)
/* Function mdlSetOutputPortSampleTime =========================================
 * Abstract:
 *    Set the output port sample time and then set the input port sample time
 *    to the appropriate faster rate or triggered.
 */
static void mdlSetOutputPortSampleTime(SimStruct *S,
                                       int_T     portIdx,
                                       real_T    sampleTime,
                                       real_T    offsetTime)
{
    ssSetOutputPortSampleTime(S,portIdx,sampleTime);
    ssSetOutputPortOffsetTime(S,portIdx,offsetTime);

    /* If the sample and offset are triggered then the block is being 
     * triggered and all of the sample times can be set to triggered 
     */
    if (ssSampleAndOffsetAreTriggered(sampleTime,offsetTime)) {
        ssSetInputPortSampleTime(S,portIdx,sampleTime);
        ssSetInputPortOffsetTime(S,portIdx,offsetTime);
    } else {
        ssSetInputPortSampleTime(S,portIdx,sampleTime
                                 /(mxGetPr(ssGetSFcnParam(S,0))[0]));
        ssSetInputPortOffsetTime(S,portIdx,offsetTime);
    }
}
#endif /* MDL_SET_OUTPUT_PORT_SAMPLE_TIME */


/* Function: mdlInitializeSampleTimes =========================================
 * Abstract:
 *    The sample times have already been set. This function performs a check.
 */
static void mdlInitializeSampleTimes(SimStruct *S)
{
    real_T sample_in = ssGetInputPortSampleTime(S,0);
    real_T sample_out = ssGetOutputPortSampleTime(S,0);

    real_T offset_in = ssGetInputPortOffsetTime(S,0);
    real_T offset_out = ssGetOutputPortOffsetTime(S,0);

    if(ssSampleAndOffsetAreTriggered(sample_in,offset_in) &&
       ssSampleAndOffsetAreTriggered(sample_out,offset_out)) {
        return;
    }

    if( sample_in  == CONTINUOUS_SAMPLE_TIME || 
        sample_out == CONTINUOUS_SAMPLE_TIME)  {
        ssSetErrorStatus(S,"All sample times must be discrete.");
    }
    
    if(  offset_in != 0 || offset_out != 0 ){
        ssSetErrorStatus(S,"All sample time offsets must be zero.");
    }
    ssSetModelReferenceSampleTimeDefaultInheritance(S);    
} /* end mdlInitializeSampleTimes */

#define MDL_START  /* Change to #undef to remove function */
#if defined(MDL_START)
  /* Function: mdlStart =======================================================
   * Abstract:
   *    This function is called once at start of model execution.
   *    Initialize the IWOrk counter to zero.
   */
static void mdlStart(SimStruct *S)
{
    int_T * IWork = ssGetIWork(S);
    IWork[0] = 0;

}
#endif /*  MDL_START */

/* Function: mdlOutputs =======================================================
 * Abstract:
 *    This block has the same outward behavior regardless of whether it is 
 *    triggered or not. If it is triggered, it internally counts to determine
 *    if it should pass the input through. If it is not triggered, the sample 
 *    time of the output port determines when to pass through the input.
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
    /* Use ssGetPortBasedSampleTimeBlockIsTriggered to determine if the 
     * S-function has been placed in a triggered context. If it is being 
     * triggered, then anytime the mdlOutputs or mdlUpdate are called 
     * there is a sample hit. It is incorrect to check if there is a sample 
     * hit if the block is being triggered. 
     */
    if ( ssGetPortBasedSampleTimeBlockIsTriggered(S)) {
        /* Here we use the triggered algorithm */
        int_T * IWork = ssGetIWork(S);
        int_T maxCount = mxGetPr(ssGetSFcnParam(S,0))[0];

        if (IWork[0] == 0) {
            InputRealPtrsType port0Inputs = ssGetInputPortRealSignalPtrs(S,0);
            real_T inputSignal = *port0Inputs[0];
            real_T *y = ssGetOutputPortSignal(S,0);

            y[0] = inputSignal;
        }
        IWork[0] = (IWork[0] +1) % maxCount;

    } else { 
        /* Here we make use of the port based sample time algorithm
         * including ssIsSampleHit
         */
        int outputTid = ssGetOutputPortSampleTimeIndex(S,0);
        if (ssIsSampleHit(S, outputTid, tid)) {
            InputRealPtrsType port0Inputs = 
                ssGetInputPortRealSignalPtrs(S,0);
            real_T inputSignal = *port0Inputs[0];
            real_T *y = ssGetOutputPortSignal(S,0);

            y[0] = inputSignal;
        }
    }
} /* end mdlOutputs */

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
