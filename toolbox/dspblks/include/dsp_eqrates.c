/*
 *  dsp_eqrates.c
 *
 *  Set all input and output ports to the same sample time.
 *  Verify that sample time is discrete and offset is zero.
 *
 *  Optional defines which affect behavior:
 *    DSP_ALLOW_CONTINUOUS
 *          Allow continuous sample times; otherwise generate
 *          an error if sample time is not discrete.
 *
 *  Copyright 1995-2002 The MathWorks, Inc.
 *  $Revision: 1.11 $  $Date: 2002/04/14 20:35:29 $
 */

static void setEqualRates(
    SimStruct *S,
    int_T      portIdx,
    real_T     sampleTime,
    real_T     offsetTime)
{
#ifndef DSP_ALLOW_CONTINUOUS
    if (sampleTime == CONTINUOUS_SAMPLE_TIME) {
        THROW_ERROR(S, "Continuous sample times not permitted.");
    }
#endif
    if ((sampleTime != CONTINUOUS_SAMPLE_TIME) && (offsetTime != 0.0)) {
        THROW_ERROR(S, "Non-zero sample time offsets not permitted.");
    }

    {
	int_T i, num;
		
	num = ssGetNumInputPorts(S);
	for (i=0; i<num; i++) {
	    ssSetInputPortSampleTime(S, i, sampleTime);
	    ssSetInputPortOffsetTime(S, i, offsetTime);
	}
	
	num = ssGetNumOutputPorts(S);
	for (i=0; i<num; i++) {
	    ssSetOutputPortSampleTime(S, i, sampleTime);
	    ssSetOutputPortOffsetTime(S, i, offsetTime);
	}
    }
}


#define MDL_SET_INPUT_PORT_SAMPLE_TIME
static void mdlSetInputPortSampleTime(SimStruct *S,
                                      int_T     portIdx,
                                      real_T    sampleTime,
                                      real_T    offsetTime)
{
    setEqualRates(S, portIdx, sampleTime, offsetTime);
}


#define MDL_SET_OUTPUT_PORT_SAMPLE_TIME
static void mdlSetOutputPortSampleTime(SimStruct *S,
                                       int_T     portIdx,
                                       real_T    sampleTime,
                                       real_T    offsetTime)
{
    setEqualRates(S, portIdx, sampleTime, offsetTime);
}


static void mdlInitializeSampleTimes(SimStruct *S)
{
    /* This function intentionally left blank. */
}

#ifdef DSP_ALLOW_CONTINUOUS
#   undef DSP_ALLOW_CONTINUOUS
#endif

/* [EOF] dsp_eqrates.c */
