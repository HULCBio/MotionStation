/*
 * dsp_ts_sim.c 
 *
 * DSP Blockset helper function.
 *
 * Check input/output port sample time information. 
 *
 * NOTE: This is a query on the port sample time information. Therefore, 
 * the information must already be set for the port.
 *
 *
 * Copyright 1995-2003 The MathWorks, Inc.
 * $Revision: 1.1.6.2 $ $Date: 2004/04/12 23:13:02 $
 */

#include "dsp_ts_sim.h"

/*--------------------------------------------------------------*/
/* BLOCK: SAMPLE TIME INHERITED
 */
EXPORT_FCN boolean_T isBlockTsInherited(SimStruct *S, int_T sti) {
  return((boolean_T)(ssGetSampleTime(S,sti) == INHERITED_SAMPLE_TIME));
}


/*--------------------------------------------------------------*/
/* BLOCK: CONTINUOUS SAMPLE TIME
 * Includes continuous (0) and variable sample times (-2). 
 */
EXPORT_FCN boolean_T isBlockContinuous(SimStruct *S, int_T sti) {
  return((boolean_T)(!isBlockTsInherited(S, sti) && (ssGetSampleTime(S,sti) <= CONTINUOUS_SAMPLE_TIME)));
}

/*--------------------------------------------------------------*/
/* BLOCK: DISCRETE SAMPLE TIME
 */
EXPORT_FCN boolean_T isBlockDiscrete(SimStruct *S, int_T sti) {
  return((boolean_T)(!isBlockTsInherited(S, sti) && (ssGetSampleTime(S,sti) > CONTINUOUS_SAMPLE_TIME)));
}

/*--------------------------------------------------------------*/
/* PORT-BASED:
 */
EXPORT_FCN boolean_T areAllInputPortsDiscreteSampleTime(SimStruct *S) {
    boolean_T      retVal     = true;
    const int_T    numInPorts = ssGetNumInputPorts(S);
    register int_T i;

    for (i=0; i<numInPorts; i++) {
        /* Only set return value false if input samp time IS NOT discrete */
        if (ssGetInputPortSampleTime(S, i) <= CONTINUOUS_SAMPLE_TIME) {
            retVal = false;
            break; /* EARLY BREAK OUT OF LOOP */
        }
    }
    return(retVal);
}

EXPORT_FCN boolean_T areAllInputPortsContOrConstSampleTime(SimStruct *S) {
    boolean_T      retVal     = true;
    const int_T    numInPorts = ssGetNumInputPorts(S);
    register int_T i;

    for (i=0; i<numInPorts; i++) {
        /* Only set return value false if input samp time IS discrete */
        if (ssGetInputPortSampleTime(S, i) > CONTINUOUS_SAMPLE_TIME) {
            retVal = false;
            break; /* EARLY BREAK OUT OF LOOP */
        }
    }
    return(retVal);
}

EXPORT_FCN boolean_T areAllInputPortsSameBehaviorSampleTime(SimStruct *S) {
    if ( areAllInputPortsDiscreteSampleTime(S) )
        return(true);
    else if ( areAllInputPortsContOrConstSampleTime(S) )
        return(true);
    else
        return(false);
}

/*--------------------------------------------------------------*/
/* OFFSET
 */


/* [EOF] dsp_ts_sim.c */
