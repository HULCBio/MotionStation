/*
 * SDSPMPCLK Multiphase clock generator C-MEX S-Function
 *           for the DSP Blockset.
 *
 *   CLKFREQ: Frequency of clock in Hz
 *   NPHASES: Number of clock phases to generate
 *   TRIGGER: 1=rising edge, 2=falling edge
 *    DCYCLE: Number of sample intervals that clock remains high
 *  DATATYPE: 1=boolean, 2=double precision
 *    SPHASE: Starting phase, from 1 to NPHASES
 *
 *  Copyright 1995-2002 The MathWorks, Inc.
 *  $Revision: 1.14 $  $Date: 2002/04/14 20:44:04 $
 */

#define S_FUNCTION_NAME sdspmpclk
#define S_FUNCTION_LEVEL 2

#define DATA_TYPES_IMPLEMENTED

#include "dsp_sim.h"

enum {OUTPORT_Y=0};
enum {CLKFREQ_ARG_IDX=0, NPHASES_ARG_IDX, TRIGGER_ARG_IDX, DCYCLE_ARG_IDX,
      SPHASE_ARG_IDX,  NUM_PARAMS};

#define CLKFREQ_ARG  ssGetSFcnParam(S, CLKFREQ_ARG_IDX)
#define NPHASES_ARG  ssGetSFcnParam(S, NPHASES_ARG_IDX)
#define TRIGGER_ARG  ssGetSFcnParam(S, TRIGGER_ARG_IDX)
#define DCYCLE_ARG   ssGetSFcnParam(S, DCYCLE_ARG_IDX)
#define SPHASE_ARG   ssGetSFcnParam(S, SPHASE_ARG_IDX)

/* There are NPHASES number of entries in the circular
 * buffers, pointed to by CIRCBUF
 */
enum {CIRCBUF_DBL_IDX=0};
enum {TRIG_RISING=1, TRIG_FALLING};
enum {CLKPHASE_IDX=0, NUM_IWORKS};
enum {CIRCBUF_IDX=0, NUM_DWORKS};


#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S) {
    static char *msg;
    real_T d;
    int_T  i, N;

    msg = NULL;

    if (ssGetSimMode(S) == SS_SIMMODE_SIZES_CALL_ONLY) {
        goto FCN_EXIT;
    }

    if ((mxGetNumberOfElements(CLKFREQ_ARG) != 1) ||
	(mxGetPr(CLKFREQ_ARG)[0] <= 0.0)  ) {
	msg = "Clock frequency must be a scalar > 0";
	goto FCN_EXIT;
    }

    if (mxGetNumberOfElements(NPHASES_ARG) != 1) {
	msg = "Number of phases must be a scalar";
	goto FCN_EXIT;
    }
    d = mxGetPr(NPHASES_ARG)[0];
    i = (int_T)d;
    N = i;
    if ( (d!=i) || (i<1) ) {
	msg = "Number of phases must be an integer >= 1";
	goto FCN_EXIT;
    }

    if (mxGetNumberOfElements(TRIGGER_ARG) != 1) {
	msg = "Trigger must be a scalar";
	goto FCN_EXIT;
    }
    d = mxGetPr(TRIGGER_ARG)[0];
    i = (int_T)d;
    if ( (d!=i) || ((i<1) && (i>2)) ) {
	msg = "Trigger must be 1=Rising or 2=Falling";
	goto FCN_EXIT;
    }

    if (mxGetNumberOfElements(DCYCLE_ARG) != 1) {
	msg = "Number of phase intervals must be a scalar";
	goto FCN_EXIT;
    }
    d = mxGetPr(DCYCLE_ARG)[0];
    i = (int_T)d;
    if ( (d!=i) ||
	 ((N>1) && ((i<1) || (i>=N))) ||
	 ((N==1) && (i!=1))
       ) {
	msg = "Number of phase intervals must be an integer in range "
	      "[1, N-1], where N is the number of clock phases. "
	      "If N=1, the number of phase intervals must be 1.";
	goto FCN_EXIT;
    }

    if (mxGetNumberOfElements(SPHASE_ARG) != 1) {
	msg = "Starting phase must be a scalar";
	goto FCN_EXIT;
    }
    d = mxGetPr(SPHASE_ARG)[0];
    i = (int_T)d;
    if ( (d!=i) || 
	 ((N>1) && ((i<1) || (i>N))) ||
	 ((N==1) && (i!=1))
       ) {
	msg = "Starting phase must be an integer in range "
	      "[1, N], where N is the number of clock phases. "
	      "If N=1, the starting phase must be 1.";
	goto FCN_EXIT;
    }

FCN_EXIT:
    ssSetErrorStatus(S, msg);
}
#endif


static void mdlInitializeSizes(SimStruct *S)
{
    real_T *ptr_nphases;
    int_T   nphases;

    ssSetNumSFcnParams(S, NUM_PARAMS);

#if defined(MATLAB_MEX_FILE)
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) return;
    mdlCheckParameters(S);
    if (ssGetErrorStatus(S) != NULL) return;
#endif

    ptr_nphases = mxGetPr(NPHASES_ARG);

    /* In case NPHASES is empty or not assigned: */

    if (ptr_nphases != NULL) {
        nphases = (int_T)ptr_nphases[0];
    } else {
        nphases = 1;
        /* mexPrintf("Number of phases in %s is invalid; defaulting to 1.", ssGetPath(S)); */
    }

    /*
     * Set non-tunable params:
     * During Simulation, RTW, and EXTERNAL modes:
     *   nphases         (affects output port width)
     *   clock frequency (set once at beginning of simulation)
     */
    ssSetSFcnParamNotTunable(S, NPHASES_ARG_IDX);
    ssSetSFcnParamNotTunable(S, CLKFREQ_ARG_IDX);

    /* Tunable params are:
     *                      TRIGGER_ARG_IDX
     *                      DCYCLE_ARG_IDX
     *                      SPHASE_ARG_IDX
     */

    /* Inputs: */
    if (!ssSetNumInputPorts(S, 0)) return;

    /* Outputs: */
    if (!ssSetNumOutputPorts(S,1)) return;
    ssSetOutputPortWidth(S, OUTPORT_Y, nphases);

    /* Set output port data type: */
    ssSetOutputPortDataType(S, OUTPORT_Y, SS_DOUBLE);

    /* Allocate NPHASES number of double DWork,
     * and one integer IWork.
     */
    if (!ssSetNumDWork(S, NUM_DWORKS)) return;
    ssSetDWorkWidth(S, CIRCBUF_IDX, nphases);
    ssSetDWorkDataType(S, CIRCBUF_IDX, SS_DOUBLE);

    /*
     * Set last few items:
     */
    ssSetNumIWork(S, NUM_IWORKS);
    ssSetNumSampleTimes(S, 1);
    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE);
}


static void mdlInitializeSampleTimes(SimStruct *S)
{
    const real_T clk = mxGetPr(CLKFREQ_ARG)[0];
    int_T  N   = (int_T)(mxGetPr(NPHASES_ARG)[0]);

    if (N==1) {
	/* Single-phase clock - need to generate sample time
	* twice the clock frequency, i.e., as if there were
	* 2 clock phases
	*/
	N++;
    }

    ssSetSampleTime(S, 0, 1.0/(N*clk));
    ssSetOffsetTime(S, 0, 0.0);
}


#define MDL_INITIALIZE_CONDITIONS
static void mdlInitializeConditions(SimStruct *S)
{
    /* Initialize HI constant:
     * Hi is defined as:
     *    1 if polarity is rising
     *    0 if polarity is falling
     */
    const int_T trig = (int_T)(mxGetPr(TRIGGER_ARG)[0]);
    const int_T hi   = (trig == TRIG_RISING) ? 1 : 0;

    /*
     * Preset circular buffer so outputs are what they would
     * be at phase=N-1 (time 0 is phase=0).
     */
    {
	const int_T N      = (int_T)(mxGetPr(NPHASES_ARG)[0]);
	const int_T dcycle = (int_T)(mxGetPr(DCYCLE_ARG)[0]);
	const int_T sphase = (int_T)(mxGetPr(SPHASE_ARG)[0]) - 1;

        /*
         * Doubles and Bools in simulation mode are both real_T data types.
         * Output is DOUBLE or BOOL, but internal representation is real_T.
         */
	real_T *circbuf = (real_T *)ssGetDWork(S, CIRCBUF_IDX);
	int_T   i;

	/* First fill in all LOW: */
	for (i=0; i<N; i++) {
	    circbuf[i] = 1-hi;  /* low = 1 - hi */
	}

	/* Fill a 1 in the "starting phase-1" index,
	 * then continue filling in 1's backwards
	 * until dcycle expires
	 */
	for (i=0; i<dcycle; i++) {
	    int_T idx = sphase-1-i;
	    if (idx<0) idx += N;
	    circbuf[idx] = hi;
	}
    }

    /* Reset clock to 1 before starting phase: */
    ssSetIWorkValue(S, CLKPHASE_IDX, 0);
}

#define MDL_PROCESS_PARAMETERS
static void mdlProcessParameters(SimStruct *S)
{
    /* We need to have mdlProcessParameters defined
     * so the three tunable paramters will change the
     * circular buffer when they are modified.  The work 
     * is done in mdlInitializeConditions.
     */
    mdlInitializeConditions(S);
}



static void mdlOutputs(SimStruct *S, int_T tid)
{
    const int_T   N     = (int_T)(mxGetPr(NPHASES_ARG)[0]);

    /*
     * We are in the clk_phase phase of the clock
     * - the primary clock output is high if
     *   dcycle > clk_phase
     */
    real_T *y       = ssGetOutputPortRealSignal(S,0);
    real_T *circbuf = (real_T *)ssGetDWork(S, CIRCBUF_IDX);

    if (N > 1) {
	/* Multiphase clock: */
	int_T       *clk_phase = ssGetIWork(S) + CLKPHASE_IDX;
	const int_T  phase     = *clk_phase;
	const int_T  idx       = N-1-phase;
	const int_T  n1        = N - idx;  /* # entries in latter part */
	const int_T  n2        = idx;      /* # entries in early part  */

	/* Copy circular buffer into output: */
        {
	    /* memcpy(y, circbuf+idx, n1*sizeof(real_T)); */
            int_T i = n1;
            real_T *x = circbuf+idx;
            while(i-- > 0) {
                *y++ = *x++;
            }

	    /* memcpy(y+n1, circbuf, n2*sizeof(real_T)); */
            x = circbuf;
            i = n2;
            while(i-- > 0) {
                *y++ = *x++;
            }
        }

	/* Increment the clock phase: */
	*clk_phase = (phase+1) % N;

    } else {
	/* Single-phase clock: */
	*y = circbuf[0];
	circbuf[0] = 1 - circbuf[0];
    }
}


static void mdlTerminate(SimStruct *S)
{
}


#ifdef	MATLAB_MEX_FILE  
#include "simulink.c"    
#else
#include "cg_sfun.h"     
#endif

/* [EOF] sdspmpclk.c */
