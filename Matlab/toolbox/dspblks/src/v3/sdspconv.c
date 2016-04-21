/*
 *  SDSPCONV.c - buffered convolution.
 *  DSP Blockset S-Function to convolve two vectors.
 *  This SIMULINK S-function computes the convolution of the two input 
 *  vectors; 
 *
 *  Copyright 1995-2002 The MathWorks, Inc.
 *  $Revision: 1.9 $ $Date: 2002/04/14 20:43:05 $
 */

#define S_FUNCTION_NAME sdspconv
#define S_FUNCTION_LEVEL 2

#define DATA_TYPES_IMPLEMENTED

#include "dsp_sim.h"

enum {NUM_ARGS=0};
enum {INPORT_0=0, INPORT_1}; 
enum {OUTPORT_0=0}; 

static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumSFcnParams(S, NUM_ARGS);
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) return;

    /* Inputs: */
    if (!ssSetNumInputPorts(S, 2)) return;

    ssSetInputPortWidth(            S, INPORT_0, DYNAMICALLY_SIZED);
    ssSetInputPortDirectFeedThrough(S, INPORT_0, 1);
    ssSetInputPortComplexSignal(    S, INPORT_0, COMPLEX_INHERITED);
    ssSetInputPortReusable(        S, INPORT_0, 1);
    ssSetInputPortOverWritable(     S, INPORT_0, 0);  /* revisits inputs multiple times */

    ssSetInputPortWidth(            S, INPORT_1, DYNAMICALLY_SIZED);
    ssSetInputPortDirectFeedThrough(S, INPORT_1, 1);
    ssSetInputPortComplexSignal(    S, INPORT_1, COMPLEX_INHERITED);
    ssSetInputPortReusable(        S, INPORT_1, 1);
    ssSetInputPortOverWritable(     S, INPORT_1, 0);  /* revisits inputs multiple times */

    /* Outputs: */
    if (!ssSetNumOutputPorts(S,1)) return;

    ssSetOutputPortWidth(        S, OUTPORT_0, DYNAMICALLY_SIZED);
    ssSetOutputPortComplexSignal(S, OUTPORT_0, COMPLEX_INHERITED);
    ssSetOutputPortReusable(    S, OUTPORT_0, 1);

    ssSetNumSampleTimes(S, 1);
    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE);
}


static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);
}


static void mdlOutputs(SimStruct *S, int_T tid)
{
    const int_T     M  = ssGetInputPortWidth(S,INPORT_0);
    const int_T	    N  = ssGetInputPortWidth(S,INPORT_1);
    const int_T	    L  = ssGetOutputPortWidth(S,OUTPORT_0);
    const boolean_T c0 = (boolean_T)(ssGetInputPortComplexSignal(S,INPORT_0) == COMPLEX_YES);
    const boolean_T c1 = (boolean_T)(ssGetInputPortComplexSignal(S,INPORT_1) == COMPLEX_YES);

    if (!c0 && !c1) {
        /*
         * Both ports are real:
         */
        InputRealPtrsType  uptr0 = ssGetInputPortRealSignalPtrs(S,INPORT_0);
        InputRealPtrsType  uptr1 = ssGetInputPortRealSignalPtrs(S,INPORT_1);
        real_T            *y     = ssGetOutputPortRealSignal(S,OUTPORT_0);
        int_T              i;

        for (i = 0; i < L; i++) {

            const int_T j_end = MIN(i, M-1);
            real_T      sum   = 0.0;
            int_T       j;
	        
	    for (j = MAX(0, i-N+1); j <= j_end; j++) {
                sum += *uptr0[j] * *uptr1[i-j];
	    }
	    *y++ = sum;
        }

    } else if (c0 && c1) {
        /*
         * Both ports are complex:
         */
        InputPtrsType  uptr0 = ssGetInputPortSignalPtrs(S,INPORT_0);
        InputPtrsType  uptr1 = ssGetInputPortSignalPtrs(S,INPORT_1);
        creal_T	      *y     = (creal_T *)ssGetOutputPortSignal(S,OUTPORT_0);
        int_T          i;
	    
	for (i = 0; i < L; i++) {
            const int_T j_end = MIN(i, M-1);
            creal_T     sum   = {0.0, 0.0};
            int_T       j;

	    for (j = MAX(0, i-N+1); j <= j_end; j++) {
                const creal_T val0 = *((creal_T *)uptr0[j]);
                const creal_T val1 = *((creal_T *)uptr1[i-j]);
                sum.re += CMULT_RE(val0, val1);
		sum.im += CMULT_IM(val0, val1);
	    }
            *y++ = sum;
	}

    } else {
        /*
         * Mixed case (one port is complex, the other port is real)
         */

        /* Two possible cases here:
         *  if c0 -> First port complex, second port real
         *  if c1 -> First port real,    second port complex
         *
         *  uptr0 will always point to the complex input
         *  uptr1 will always point to the real input
         */

        InputPtrsType      uptr0;
        InputRealPtrsType  uptr1;
        creal_T           *y = (creal_T *)ssGetOutputPortSignal(S,OUTPORT_0);
        int_T              i, MM, NN;

        if (c0) {
            /* First input is complex, second is real: */
            uptr0 = ssGetInputPortSignalPtrs(S,INPORT_0);        /* Complex input */
       	    uptr1 = ssGetInputPortRealSignalPtrs(S,INPORT_1);    /* Real input    */
            MM = M;
            NN = N;
        } else {
            /* Second input is complex, first is real: */
            uptr0 = ssGetInputPortSignalPtrs(S,INPORT_1);        /* Complex input */
       	    uptr1 = ssGetInputPortRealSignalPtrs(S,INPORT_0);    /* Real input */
            MM = N;
            NN = M;
        }

	for (i = 0; i < L; i++) {
	    const int_T j_end = MIN(i, MM-1);
            creal_T     sum   = {0.0, 0.0};
	    int_T       j;

	    for (j = MAX(0, i-NN+1); j <= j_end; j++) {
		const creal_T *u0 = (creal_T *)uptr0[j];
		const real_T   u1 = *uptr1[i-j];
		sum.re += u0->re * u1;
		sum.im += u0->im * u1;
	    }
	    *y++ = sum;
	}
    }
}


static void mdlTerminate(SimStruct *S)
{
}


/*
 * Check port width information as it is sequentially obtained
 * and set the only unknown port when the other two become known.
 * Input and output port widths become known in arbitrary order. 
 */
static void CheckandSetPorts(SimStruct *S,int_T port,
                               int_T PortWidth, int_T caller)
{
    int_T w[3];	    /* port widths, [input0 input1 output0]       */
    int_T idx = -1; /* index of remaining unknown port width, 0-2 */
    int_T cnt = 0;  /* unknown width counter                      */
    int_T i;

    if (caller == 0) {
        ssSetInputPortWidth(S,port,PortWidth);
    } else {
        ssSetOutputPortWidth(S,port,PortWidth);	
    }

    w[0] = ssGetInputPortWidth(S,INPORT_0);
    w[1] = ssGetInputPortWidth(S,INPORT_1);
    w[2] = ssGetOutputPortWidth(S,OUTPORT_0);

    for (i=0; i<3; i++) {
        if (w[i] == DYNAMICALLY_SIZED) {
	    idx = i;
	    cnt++;
        }
    }

    if (cnt != 1) return;

    /* Have one unknown, solve for it 
     *  In general, input 0 has length L
     *	            input 1 has length M
     * 	            output 0 has length P 
     *	w = [L M P]
     */
    
    if (idx == 0) {
        /* L = P-M+1 */
        w[0] = w[2] - w[1] + 1;

    } else if (idx == 1) {
	/* M = P-L+1 */
	w[1] = w[2] - w[0] + 1;

    } else {
	/* P = L+M-1 */
	w[2] = w[0] + w[1] - 1;
    }

    /* Check that the LHS > 0 */
    if (w[idx] <= 0) {
        ssSetErrorStatus(S,"Inconsistent port widths");
        return;
    }

    /* Set the idx port width */
    if (idx < 2) {
	ssSetInputPortWidth(S,idx,w[idx]);
    } else {
        ssSetOutputPortWidth(S,OUTPORT_0,w[idx]);	/* idx = 2 */
    }
}


#if defined(MATLAB_MEX_FILE)
# define MDL_SET_INPUT_PORT_WIDTH
 static void mdlSetInputPortWidth(SimStruct *S, int_T port,
                                    int_T inputPortWidth)
{
    CheckandSetPorts(S,port,inputPortWidth,0);
}

# define MDL_SET_OUTPUT_PORT_WIDTH
static void mdlSetOutputPortWidth(SimStruct *S, int_T port,
                                     int_T outputPortWidth)
{
    CheckandSetPorts(S,port,outputPortWidth,1);
}
#endif


#include "dsp_cplxhs21.c"   

#ifdef	MATLAB_MEX_FILE   
#include "simulink.c"     
#else
#include "cg_sfun.h"      
#endif
