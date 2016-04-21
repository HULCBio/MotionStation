/*
 *  dsp_ctrl_ts.c
 *
 *  Sample time "handshake" code for S-Functions with
 *  N-inputs (N>0) and N-outputs (N>0), where all input
 *  ports beyond the first one are"control" type inputs.
 *
 *  Output port rate(s) are set to the rate of input port 0.
 *  Second and subsequent input ports are "control" lines which must
 *   have rates that are integer multiples of input port 0.
 *
 *  Verify that sample times are discrete and discrete-offsets are zero.
 *
 *  Special cases for Costant sample times:
 *  --------------------------------------
 *  Any of the inputs can have constant sample time. If input port 0 has
 *  constant sample time, then the output ports are set to the first finite
 *  sample time available at the input. If all input ports have
 *  constant sample time then all output ports are set to constant sample time.
 *
 *  Optional defines which affect behavior:
 *    DSP_ALLOW_CONTINUOUS
 *      Allow continuous sample times; otherwise generate
 *      an error if sample time is not discrete.
 *    DSP_ALLOW_MULTIPLE_TS
 *      Allow input ports to have a sample time that are
 *      multiples of the sample time of input port 0.
 *      Otherwise, the inputs must all have identical sample times
 *      except those with constant sample times.
 *
 *
 *
 *  NOTE: S-function must use port-based sample times!
 *
 *  Typical usage:
 *    Instead of defining mdlInitializeSampleTimes(), etc., simply include:
 *
 *    #include "dsp_ctrl_ts.c"
 *
 *
 *   
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.22.4.3 $  $Date: 2004/04/12 23:11:13 $
 */

/*
 * Set all undefined ports to sampleTime and offsetTime.
 * Verify that all set output ports have sampleTime as the rate
 *   and offsetTime as the offset.
 */
static void setAllOutputPorts(SimStruct *S,
                       real_T sampleTime,
                       real_T offsetTime)
{
    const int_T numOutp = ssGetNumOutputPorts(S);
    int_T i;
    for (i=0; i<numOutp; i++) {
        if (ssGetOutputPortSampleTime(S, i) == INHERITED_SAMPLE_TIME) {
            ssSetOutputPortSampleTime(S, i, sampleTime);
            ssSetOutputPortOffsetTime(S, i, offsetTime);
        }
    }
}


/* Returns true if all input port sample times are set */
static boolean_T allInputSampleTimesSet(SimStruct *S) 
{
    const int_T numInp  = ssGetNumInputPorts(S);
    int_T i;
    
    for (i=0; i < numInp; i++) {
        if (ssGetInputPortSampleTime(S, i) == INHERITED_SAMPLE_TIME)
            return false;
    }
    return true;
}

/* Returns the first input port number with finite sample time
 * Returns 0 if all input sample times are inf. 
 */
static int_T getFiniteSampleTimePortNum(SimStruct *S)
{
    const int_T numInp  = ssGetNumInputPorts(S);
    int_T i;
    
    for (i=0; i < numInp; i++) {
        if (ssGetInputPortSampleTime(S, i) != mxGetInf())
            return i;
    }
    return 0;
}

static void setControlRates(SimStruct *S,
                   int_T     portType,
                   int_T     portIdx,
                   real_T    sampleTime,
                   real_T    offsetTime)
{
    const int_T numInp  = ssGetNumInputPorts(S);
    const int_T numOutp = ssGetNumOutputPorts(S);

    if (ssGetNumSampleTimes(S) != PORT_BASED_SAMPLE_TIMES) {
        THROW_ERROR(S, "S-Function must use PORT_BASED_SAMPLE_TIMES in order "
                    "to be able to include dsp_ctrl_ts.");
    }
    if (numInp<1) {
        THROW_ERROR(S, "Must have at least 1 input port to use 'dsp_ctrl_ts.c'.");
    }
    if (numOutp<1) {
        THROW_ERROR(S, "Must have at least 1 output port to use 'dsp_ctrl_ts.c'.");
    }
    
    /* If this PORT_BASED_SAMPLE_TIMES block is in a triggered subsystem
     * we need to catch it and set ALL ports to the given sampleTime and
     * offsetTime
     * This assumes that we do NOT want any of the ports to be CONSTANT
     * sample time
     * If it's NOT OK for a block to be in a triggered subsystem, this 
     * error will be caught by the engine (because the block won't set
     * SS_OPTION_ALLOW_PORT_SAMPLE_TIME_IN_TRIGSS)
     */
    if (ssSampleAndOffsetAreTriggered(sampleTime,offsetTime)) {
        int_T ind;
        /*Check whether sample time is already set before setting triggered
         * sample time. Because constant sample times are set before triggered
         * sample times. */
        for (ind = 0;ind < numInp;ind++) {
            if (ssGetInputPortSampleTime(S,ind) == INHERITED_SAMPLE_TIME) {
                ssSetInputPortSampleTime(S, ind, sampleTime);
                ssSetInputPortOffsetTime(S, ind, offsetTime);
            }
        }
        for (ind = 0;ind < numOutp;ind++) {
            if (ssGetOutputPortSampleTime(S,ind) == INHERITED_SAMPLE_TIME) {
                ssSetOutputPortSampleTime(S, ind, sampleTime);
                ssSetOutputPortOffsetTime(S, ind, offsetTime);
            }
        }
    } else {
        /*
         * Rules:
         *
         *  Outport rate = first finite input port rate
         *  Inport #2 rate must be an integer multiple of
         *     inport #1 rate.
         */
        if (portType==0) { /* Inport */
            ssSetInputPortSampleTime(S, portIdx, sampleTime);
            ssSetInputPortOffsetTime(S, portIdx, offsetTime);

        } else {          /* Outport */
            ssSetOutputPortSampleTime(S, portIdx, sampleTime);
            ssSetOutputPortOffsetTime(S, portIdx, offsetTime);
        }
        /*
          For sample time propagation debugging
          mexPrintf(ssGetPath(S));
          mexPrintf("\nporttype=%d, portidx=%d, sampletime=%f\n", portType,
                                portIdx, sampleTime);
        */

        if (numInp>1) {
            /* If it is input port 0 and is finite then set all output ports also.
             * This case is needed, because in some models the control port may be
             * connected to a source set to inherit sample time. Here simulink
             * tries to set the output port itself before finishing with all input ports. */
            if (portType == 0 && portIdx == 0 && sampleTime != mxGetInf()) {
                setAllOutputPorts(S, sampleTime, offsetTime);
            }

            /* This case is needed when an input port gets constant sample time */
            if (allInputSampleTimesSet(S)) {
                int_T inputPortNum = getFiniteSampleTimePortNum(S);
                setAllOutputPorts(S, ssGetInputPortSampleTime(S,inputPortNum),
                                     ssGetInputPortOffsetTime(S,inputPortNum));
            }
            if (portType == 1) {
                /* If being called for an output port, set all output ports
                 * and input port 0 if it is not already set. */
                real_T sampleTime0 = ssGetInputPortSampleTime(S, 0);
                setAllOutputPorts(S, sampleTime, offsetTime);
                if (sampleTime0 == INHERITED_SAMPLE_TIME) {
                    ssSetInputPortSampleTime(S, 0, sampleTime);
                    ssSetInputPortOffsetTime(S, 0, offsetTime);
                }
            }
        } else {
            /* 1-input only:
             * Set all output ports to the same input0 rate as appropriate.
             */
            setAllOutputPorts(S, sampleTime, offsetTime);
        }
    }
}


#define MDL_SET_INPUT_PORT_SAMPLE_TIME
#ifdef __cplusplus
static void cppmdlSetInputPortSampleTime(SimStruct *S,
                                         int_T     portIdx,
                                         real_T    sampleTime,
                                         real_T    offsetTime)
#else
static void mdlSetInputPortSampleTime(SimStruct *S,
                                      int_T     portIdx,
                                      real_T    sampleTime,
                                      real_T    offsetTime)
#endif
{
    setControlRates(S, 0, portIdx, sampleTime, offsetTime);
}


#define MDL_SET_OUTPUT_PORT_SAMPLE_TIME
#ifdef __cplusplus
static void cppmdlSetOutputPortSampleTime(SimStruct *S,
                                          int_T     portIdx,
                                          real_T    sampleTime,
                                          real_T    offsetTime)
#else
static void mdlSetOutputPortSampleTime(SimStruct *S,
                                       int_T     portIdx,
                                       real_T    sampleTime,
                                       real_T    offsetTime)
#endif
{
    setControlRates(S, 1, portIdx, sampleTime, offsetTime);
}

#ifdef __cplusplus
static void cppmdlInitializeSampleTimes(SimStruct *S)
#else
static void mdlInitializeSampleTimes(SimStruct *S)
#endif
{
#ifdef MATLAB_MEX_FILE
    /* Check for consistency with pre-set sample time: */
    int_T  numOutPorts  = ssGetNumOutputPorts(S);
    int_T  numInPorts   = ssGetNumInputPorts(S);
    
    if (numInPorts > 0) {
        int_T inputPortNum = getFiniteSampleTimePortNum(S);
        real_T sampleTime_i0 = ssGetInputPortSampleTime(S,inputPortNum);
        real_T offsetTime_i0 = ssGetInputPortOffsetTime(S,inputPortNum);
    
        {
            /*
             * Check sample time of first finite sample in the input
             * is same as all output ports. If there is no finite sample
             * time all ports should be infinite.
             */
            int_T  i;
            
            for (i=0; i<numOutPorts; i++) {
                if ((sampleTime_i0 != ssGetOutputPortSampleTime(S,i)) ||
                    (offsetTime_i0 != ssGetOutputPortOffsetTime(S,i))) {
                    if (inputPortNum == 0) {
                        THROW_ERROR(S, "Sample time of first input port and all output ports must be identical.");
                    } else {   /* Input port 0 is not finite */
                        THROW_ERROR(S, "Sample time of first input port with non-constant sample time and all output ports must be identical.");
                    }
                }
            }
            
#ifdef DSP_ALLOW_MULTIPLE_TS
            /* Check to make sure all ports have continuous */
            /* and/or all port have discrete sample times.  */
            if ( !(areAllInputPortsSameBehaviorSampleTime(S) ) ) {
                THROW_ERROR(S, "Input ports must all have discrete sample times or continuous sample times.  Mixed sample-time behavior is not currently supported.");
            }
#endif

            /* 
            * Check that all inputs with finite sample times have
            * either identical discrete sample times, or all additional ports have
            * discrete sample times which are integer multiples first input port with finite sample time.
            */
            if ( areAllInputPortsDiscreteSampleTime(S) ) {
#ifdef DSP_ALLOW_MULTIPLE_TS
                for (i=1; i<numInPorts; i++) {
                    real_T sampleTime = ssGetInputPortSampleTime(S,i);
                    real_T ratio = floor(sampleTime/sampleTime_i0 + 0.5);
                    if (sampleTime == mxGetInf()) continue;
                    /* The control port can be const even if the input #1 is not const.*/
                    
                    if ((ratio < 1.0) || (fabs(ratio - sampleTime/sampleTime_i0) > mxGetEps()*128.0)) {
                        THROW_ERROR(S, "Sample time of control inputs (input port 2 and higher) "
                            "must be positive multiples of the sample time "
                            "of the signal input (port 1).");
                    }
                }
#else

                for (i=0; i<numInPorts; i++) {
                    real_T sampleTime = ssGetInputPortSampleTime(S,i);
                    /* Ignore infinite sample times */
                    if (sampleTime == mxGetInf()) continue;
                    if ((sampleTime_i0 != ssGetInputPortSampleTime(S,i)) ||
                        (offsetTime_i0 != ssGetInputPortOffsetTime(S,i))) {
                        THROW_ERROR(S, "Sample times of all input ports which are not constant should be identical.");
                    }
                }
#endif
            }
        }
    }
#endif
}

/* DEAD CODE BELOW */
#if 0
static void CheckSampleTimes(SimStruct *S,
                      real_T sampleTime,
                      real_T offsetTime)
{
#ifdef MATLAB_MEX_FILE
    /* Check for continuous sample times: */
#ifndef DSP_ALLOW_CONTINUOUS
    if (sampleTime <= CONTINUOUS_SAMPLE_TIME) {
        THROW_ERROR(S, "Continuous and constant sample times not permitted.");
    }
#endif

    /* Check that offset=0 for discrete sample times: */
    if (sampleTime > CONTINUOUS_SAMPLE_TIME) {
        if (offsetTime != 0.0) {
            THROW_ERROR(S, "Non-zero offsets for discrete sample times not permitted.");
        }
    }
#endif /* MATLAB_MEX_FILE */
}
#endif /* 0 */
/* DEAD CODE ABOVE */


/* Undefine optional behavior flags: */
#ifdef DSP_ALLOW_CONTINUOUS
#   undef DSP_ALLOW_CONTINUOUS
#endif

#ifdef DSP_ALLOW_MULTIPLE_TS
#   undef DSP_ALLOW_MULTIPLE_TS
#endif


/* [EOF] dsp_control_ts.c */
