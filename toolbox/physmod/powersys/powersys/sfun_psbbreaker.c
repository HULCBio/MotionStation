/*
 * File : sfun_psbbreaker.c
 * Abstract:
 *       A C-file S-function which implements the logic for the
 *       breaker block in the Power System Blockset.
 *       The logic is implemented as a simple state machine of the following form:
 *
 *       *
 *       | initial >= 0.5
 *       V
 *   /------------------\                    /---------------------------\
 *   |CLOSED_BREAKER    |    gate < 0.5      |CLOSED_BREAKER_SEARCHING   |
 *   |entry:state = 1   |------------------->|entry:state = 1; u_old = u |
 *   |                  |    gate >= 0.5     |                           |
 *   |                  |<-------------------|                           |
 *   \------------------/                    \---------------------------/
 *           ^                                    |         |      ^
 *           |                                    |         |      |
 *           | gate >= 0.5                        |         \------/
 *           |                                    |
 *           |        /---------------------\     |
 *           |        |OPEN_BREAKER         |     | u * u_old <= 0
 *           \--------|entry:state = 0      |<----/
 *                    |                     |
 *                    |                     |
 *                    \---------------------/ 
 *                          ^
 *                          | initial < 0.5
 *                          *
 *
 * Where:
 *     initial: is the initial state of the breaker.
 *     state:   is the output state of the block
 *     gate:    is the input gate value
 *     u:       is the input voltage
 *     u_old:   is the voltage during the previous time step
 *
 * The breaker has three modes:
 *     CLOSED_BREAKER:  current flows.  To leave the CLOSED_BREAKER mode
 *     the gate value must drop below 0.5.
 *
 *     CLOSED_BREAKER_SEARCHING: current still flows, but now the voltage
 *     zero crossing is searced for.  To leave the CLOSED_BREAKER_SEARCHING
 *     the gate value can rise above 0.5 or the voltage can cross zero.
 *
 *     OPEN_BREAKER: no current flows.  To leave the OPEN_BREAKER mode,
 *     the gate value must rise above 0.5.
 *
 * Note:
 *     The gate threshold is selected to be 0.5.  However, for zero crossing
 *     detection, the gate signal by itself is used.  It is assumed that users
 *     will use discrete signals that move cleanly from 1.0 to 0.0 for the gate
 *     signal.  If a continuous signal is used as the gate signal, proper zero
 *     crossing detection will not occur.
 */

/*
 * Copyright 1990-2002 The MathWorks, Inc.
 * $Revision: 1.1.6.1.4.1 $
 */


#define S_FUNCTION_NAME  sfun_psbbreaker
#define S_FUNCTION_LEVEL 2

#include "simstruc.h"

#define WIDTH(S)    ssGetOutputPortWidth(S, 0)
#define V_OLD(S)    ssGetRealDiscStates(S) + WIDTH(S)
#define MODE(S)     ssGetRealDiscStates(S)
#define INITIAL_IDX (0)
#define INITIAL(S)  ssGetSFcnParam(S, INITIAL_IDX)

#define GATE_THRESHOLD (0.5)

typedef enum BreakerMode_tag
{
    CLOSED_BREAKER,           /* current flows, gate >  GATE_THRESHOLD  */ 
    CLOSED_BREAKER_SEARCHING, /* current flows, gate <= GATE_THRESHOLD  */
    OPEN_BREAKER              /* no current,    gate <= GATE_THRESHOLD  */
} BreakerMode;

/*================*
 * Build checking *
 *================*/
#if !defined(MATLAB_MEX_FILE) && !defined(NRT)
/*
 * This file cannot be used directly with the Real-Time Workshop. However,
 * this S-function does work with the Real-Time Workshop via
 * the Target Language Compiler technology. See 
 * matlabroot/toolbox/simulink/blocks/tlc_c/timestwo.tlc   for the C version
 * matlabroot/toolbox/simulink/blocks/tlc_ada/timestwo.tlc for the Ada version
 */
# error This_file_can_be_used_only_during_simulation_inside_Simulink
#endif


/* Function: mdlInitializeSizes ===============================================
 * Abstract:
 *   Setup sizes of the various vectors.
 */
static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumSFcnParams(S, 1);
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        return; /* Parameter mismatch will be reported by Simulink */
    }
    ssSetSFcnParamTunable(S, INITIAL_IDX, false);

    /* This block has two inports, dynamically sized */
    if (!ssSetNumInputPorts(S, 2)) return;
    ssSetInputPortWidth(S, 0, DYNAMICALLY_SIZED);
    ssSetInputPortWidth(S, 1, DYNAMICALLY_SIZED);

    /*
     * Set the number of zero-crossing signals to variable here.
     * Later in mdlSetWorkWidths we will explicitly set the number
     * of zero-crossing signals. This must be done because Simulink
     * doesn't have explicit support for setting the number of
     * zero-crossing signals for multi-port s-functions.
     */
    ssSetNumNonsampledZCs(S, DYNAMICALLY_SIZED);

    /* Both ports have direct feedthrough */
    ssSetInputPortDirectFeedThrough(S, 0, 1);
    ssSetInputPortDirectFeedThrough(S, 1, 1);

    /* This block has one outport, dynamically sized */
    if (!ssSetNumOutputPorts(S,1)) return;
    ssSetOutputPortWidth(S, 0, DYNAMICALLY_SIZED);

    ssSetNumSampleTimes(S, 1);

    /* Take care when specifying exception free code - see sfuntmpl_doc.c */
    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE);

    ssSetNumDiscStates(S, DYNAMICALLY_SIZED);
}


/* Function: mdlInitializeSampleTimes =========================================
 * Abstract:
 *    Specifiy that we inherit our sample time from the driving block.
 */
static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, CONTINUOUS_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, FIXED_IN_MINOR_STEP_OFFSET);
}


#define MDL_SET_WORK_WIDTHS   /* Change to #undef to remove function */
#if defined(MDL_SET_WORK_WIDTHS) && defined(MATLAB_MEX_FILE)
/* Function: mdlSetWorkWidths ===============================================
 * Abstract:
 *      Set the correct number of zero-crossing signals and discrete states.
 */
static void mdlSetWorkWidths(SimStruct *S)
{
    /*
     * Set the number of zero-crossing signals to
     * the sum of the width of the first and second inports.
     */
    ssSetNumNonsampledZCs(S, ( ssGetInputPortWidth(S, 0) + 
			       ssGetInputPortWidth(S, 1) ));
    /*
     * There are two discrete states for each element in the output port.
     * The first is the mode of the breaker.  The second, is the voltage
     * history, used to determine zero crossing.
     */
    ssSetNumDiscStates(S, ssGetOutputPortWidth(S, 0) * 2 );
}
#endif /* MDL_SET_WORK_WIDTHS */


#define MDL_START
#if defined(MDL_START)
/* Function: mdlStart ======================================================
 * Abstract:
 *      Initialize the breaker mode to be CLOSED_BREAKER.
 */
static void mdlStart(SimStruct *S)
{
    real_T          *mode       = MODE(S);
    int_T            width      = WIDTH(S);
    int_T            nInitial   = mxGetNumberOfElements(INITIAL(S));
    real_T          *initial    = mxGetPr(INITIAL(S));
    int_T            i;

    for (i = 0; i < width; i++, mode++) {
	BreakerMode breakerMode = CLOSED_BREAKER;
	if (i < nInitial && initial[i] < 0.5) {
	    breakerMode = OPEN_BREAKER;
	}	
	*mode=(double) breakerMode;
    }
}
#endif /* MDL_START */


#if defined(MATLAB_MEX_FILE) || defined(NRT)
/* Function: mdlZeroCrossings =================================================
 * Abstract:
 *    Zero crossing signal to track is the input signal.  For each element in
 *    the output port there are two zero-crossing signals:  One for the gate
 *    input signal, and another for the voltage input signal.  Only track
 *    the voltage signal for zero-crossings when we are in searching mode.
 */
#define MDL_ZERO_CROSSINGS
static void mdlZeroCrossings(SimStruct *S)
{
    int_T              i;
    real_T            *zcSignals  = ssGetNonsampledZCs(S);
    InputRealPtrsType  voltInPtr  = ssGetInputPortRealSignalPtrs(S,0);
    InputRealPtrsType  gateInPtr  = ssGetInputPortRealSignalPtrs(S,1);
    real_T            *mode       = MODE(S);
    int_T              width      = WIDTH(S);
    real_T            *uZc        = zcSignals;
    real_T            *gateZc     = zcSignals + width;
    
    /* 
     * Loop through the number of elements in the inports
     */
    for (i=0; i<width; i++, mode++, uZc++, gateZc++) {
        BreakerMode breakerMode = (BreakerMode) *mode;
	real_T      gate        = *gateInPtr[i];
	real_T      u           = *voltInPtr[i];

        /*
	 * detect each gate crossing.
	 */
        *gateZc = gate;
        
	switch (breakerMode) {
	  case CLOSED_BREAKER:
	  case OPEN_BREAKER:
	    /*
	     * while not searching for the voltage crossing, use
	     * a flat non-zero signal.
	     */
	    *uZc = 1.0;
	    break;
	  case CLOSED_BREAKER_SEARCHING:
	    /*
	     * while searching for a voltage crossing use the input
	     * voltage.
	     */
	    *uZc = u;
	    break;
	}
    }
}
#endif

/* Function: mdlOutputs =======================================================
 * Abstract:
 *    For each element in the output port, there are three stages.  First,
 *    the breaker mode is updated based on the gate value.  Second, the breaker 
 *    mode is updated based on the input voltage.  Finally, the state of the output
 *    is updated and any necessary history is recored.
 *
 *    Three distinct stages are used because it is conceivable that the gate signal
 *    could drop below GATE_THRESHOLD during the same time step that the voltage is
 *    exactly zero.
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
    int_T              i;
    InputRealPtrsType  voltInPtr   = ssGetInputPortRealSignalPtrs(S,0);
    InputRealPtrsType  gateInPtr   = ssGetInputPortRealSignalPtrs(S,1);
    real_T            *state       = ssGetOutputPortRealSignal(S,0);

    real_T            *mode        = MODE(S);
    real_T            *u_old       = V_OLD(S); 
    int_T              width       = WIDTH(S);

    for (i=0; i < width; i++, mode++, u_old++, state++) {
        BreakerMode breakerMode = (BreakerMode) *mode;
	real_T      gate        = *gateInPtr[i];
	real_T      u           = *voltInPtr[i];
	/*
	 * first update mode based on gate status
	 */
	switch (breakerMode) {
	  case CLOSED_BREAKER:
	    if (gate <= GATE_THRESHOLD) {
		breakerMode = CLOSED_BREAKER_SEARCHING;
		/*
		 * provide some value for u_old.  the only time
		 * this is really important is when u is exactly 
		 * zero
		 */
		*u_old = u;
	    }
	    break;
	  case CLOSED_BREAKER_SEARCHING:
	  case OPEN_BREAKER:
	    if (gate > GATE_THRESHOLD) {
		breakerMode = CLOSED_BREAKER;
	    }
	    break;
	}

	/*
	 * now adjust mode based on voltage
	 */
	switch (breakerMode) {
	  case CLOSED_BREAKER:
	  case OPEN_BREAKER:
	    break;
	  case CLOSED_BREAKER_SEARCHING:
	    if (*u_old * u <= 0.0) {
		breakerMode = OPEN_BREAKER;
	    }
	    break;
	}

	/*
	 * now set the output and record any history.
	 */
	*mode = (double) breakerMode;
	switch (breakerMode) {
	  case OPEN_BREAKER:
	    *state = 0.0;
	    break;
	  case CLOSED_BREAKER:
	    *state = 1.0;
	    break;
	  case CLOSED_BREAKER_SEARCHING:
	    *state = 1.0;
	    *u_old = u;
	    break;
	}
    }
}

/* Function: mdlTerminate =====================================================
 * Abstract:
 *    No termination needed, but we are required to have this routine.
 */
static void mdlTerminate(SimStruct *S)
{
}

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif







