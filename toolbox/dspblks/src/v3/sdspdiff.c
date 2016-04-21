/*
 * SDSPDIFF DSP Blockset vector difference.
 *
 * Computes the difference between successive vector elements,
 * leaving one fewer outputs than inputs.
 *
 *  The implementation of the DIFF block has both this S-function AND
 *  a demux block.  This S-function generates AS MANY outputs as inputs,
 *  leaving the first output element with a copy of the first input element.
 *  This first element is subsequently discarded by the second block, a demux.
 *
 *  This strategy allows the S-function to have an equal width on the input
 *  and output port width, allowing the block to potentially perform an in-place
 *  computation.  The demux simply removes the first element before the user gets
 *  the result.
 *
 *  This ability to perform in-place computations results in potentially
 *  significant memory savings.
 *
 *  % overall equivalent MATLAB code:
 *  y = diff(u);                % for a vector, u
 *  y = u(2:end) - u(1:end-1);  % alternative
 *
 *   
 *  Copyright 1995-2002 The MathWorks, Inc.
 *  $Revision: 1.12 $  $Date: 2002/04/14 20:43:07 $
 */
#define S_FUNCTION_NAME sdspdiff
#define S_FUNCTION_LEVEL 2

#define DATA_TYPES_IMPLEMENTED

#include "dsp_sim.h"

enum {INPORT=0};
enum {OUTPORT=0};


static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumSFcnParams(S, 0);    

#if defined(MATLAB_MEX_FILE)
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) return;
#endif

    /* Inputs: */
    if (!ssSetNumInputPorts(S, 1)) return;
    
    ssSetInputPortWidth(            S, INPORT, DYNAMICALLY_SIZED);  
    ssSetInputPortComplexSignal(    S, INPORT, COMPLEX_INHERITED);
    ssSetInputPortDirectFeedThrough(S, INPORT, 1);
    ssSetInputPortReusable(        S, INPORT, 1);
    ssSetInputPortOverWritable(     S, INPORT, 1);
    
    /* Outputs: */
    if (!ssSetNumOutputPorts(S,1)) return;
    
    ssSetOutputPortWidth(           S, OUTPORT, DYNAMICALLY_SIZED);      
    ssSetOutputPortComplexSignal(   S, OUTPORT, COMPLEX_INHERITED);
    ssSetOutputPortReusable(       S, OUTPORT, 1);
    
    ssSetNumSampleTimes(S, 1);
    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE |
                 SS_OPTION_USE_TLC_WITH_ACCELERATOR);
}


static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);
}


static void mdlOutputs(SimStruct *S, int_T tid)
{
    const boolean_T inplace = (boolean_T)(ssGetInputPortBufferDstPort(S, INPORT) == OUTPORT);
    const boolean_T c0      = (boolean_T)(ssGetInputPortComplexSignal(S,INPORT) == COMPLEX_YES);
    int_T           N       = ssGetInputPortWidth(S, INPORT);

    if (inplace) {
        if (!c0) {
            /* Real */
            real_T *y1 = ssGetOutputPortRealSignal(S, OUTPORT)+N-1;
            real_T *y  = y1-1;
            while(--N > 0) {     /* reverse roll through data */
                *y1-- -= *y--;
            }

        } else {
            /* Complex */        
            creal_T      *y1 = (creal_T *)ssGetOutputPortSignal(S, OUTPORT)+N-1;
            creal_T      *y  = y1-1;
            while(--N > 0) {
                y1->re     -= y->re;
                (y1--)->im -= (y--)->im;
            }
        }

    } else {
        /* Discontiguous, or just not in-place: */

        if (!c0) {
            /* Real */
            InputRealPtrsType u1 = ssGetInputPortRealSignalPtrs(S, INPORT)+N-1;
            InputRealPtrsType u  = u1-1;
            real_T           *y  = ssGetOutputPortRealSignal(S, OUTPORT)+N-1;

            while(--N > 0) {
                *y-- = **u1-- - **u--;
            }

        } else {
            /* Complex */        
            InputPtrsType u1 = ssGetInputPortSignalPtrs(S, INPORT)+N-1;
            InputPtrsType u  = u1-1;
            creal_T      *y  = (creal_T *)ssGetOutputPortSignal(S, OUTPORT)+N-1;
            while(--N > 0) {
                y->re     = ((creal_T *)(*u1))->re   - ((creal_T *)(*u))->re;
                (y--)->im = ((creal_T *)(*u1--))->im - ((creal_T *)(*u--))->im;
            }
        }
    }
}


static void mdlTerminate(SimStruct *S)
{
}


#if defined(MATLAB_MEX_FILE)
#define MDL_SET_INPUT_PORT_WIDTH
static void mdlSetInputPortWidth(SimStruct *S, int_T port, int_T inputPortWidth)
{
    int_T outputPortWidth = ssGetOutputPortWidth(S, OUTPORT);
    ssSetInputPortWidth(S, port, inputPortWidth);

    /* A diff of one number does not make sense */
    if (inputPortWidth < 2) {
        ssSetErrorStatus(S, "Input port width must be at least 2.");
    }
    if (outputPortWidth == DYNAMICALLY_SIZED) {
        ssSetOutputPortWidth(S, port, inputPortWidth);
    } else {
        /* Verify that input port width matches output port width */
        if (inputPortWidth != outputPortWidth) {
            ssSetErrorStatus(S, "Input port width must be equal to the output port width plus 1");
        }
    }
    
}

# define MDL_SET_OUTPUT_PORT_WIDTH
static void mdlSetOutputPortWidth(SimStruct *S, int_T port, int_T outputPortWidth)
{
    int_T inputPortWidth = ssGetInputPortWidth(S, INPORT);
    ssSetOutputPortWidth(S,port,outputPortWidth);
    
    if (inputPortWidth == DYNAMICALLY_SIZED) {
        ssSetInputPortWidth(S,port,outputPortWidth);
    } else {
        /* Input port width must match the output width! */
        if (inputPortWidth != outputPortWidth) {
            ssSetErrorStatus(S, "Output port width must be equal to the input port width minus 1");
        }
    }
}
#endif

/* Complex handshake */
#include "dsp_cplxhs11.c"


#ifdef	MATLAB_MEX_FILE   
#include "simulink.c"      
#else
#include "cg_sfun.h"       
#endif

/* [EOF] sdspdiff.c */
