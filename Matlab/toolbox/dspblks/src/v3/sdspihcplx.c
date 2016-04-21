/*
 *  SDSPIHCPLX.c
 *  DSP Blockset S-Function input inherits complexity 
 *  of reference signal.
 *
 *  Copyright 1995-2002 The MathWorks, Inc.
 *  $Revision: 1.13 $ $Date: 2002/04/14 20:43:12 $
 */
#define S_FUNCTION_NAME sdspihcplx
#define S_FUNCTION_LEVEL 2

#include "dsp_sim.h"

enum {NUM_ARGS=0};
enum {INPORT_IN=0, INPORT_REF, NUM_INPORTS}; 
enum {OUTPORT=0, NUM_OUTPORTS}; 

static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumSFcnParams(S, NUM_ARGS);

    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) return;

    ssSetNumSampleTimes(S, 1);

    /* Inputs: */
    if (!ssSetNumInputPorts(S, NUM_INPORTS)) return;

    ssSetInputPortWidth(            S, INPORT_IN, DYNAMICALLY_SIZED);
    ssSetInputPortComplexSignal(    S, INPORT_IN, COMPLEX_INHERITED);
    ssSetInputPortDirectFeedThrough(S, INPORT_IN, 1);
    ssSetInputPortReusable(         S, INPORT_IN, 1); 
    ssSetInputPortOverWritable(     S, INPORT_IN, 1);

    ssSetInputPortWidth(            S, INPORT_REF, DYNAMICALLY_SIZED);
    ssSetInputPortComplexSignal(    S, INPORT_REF, COMPLEX_INHERITED);
    /* The value at the reference port is never used, 
     * only its (compile-time) complexity. Therefore, the fact that
     * this reference signal is used by this block should NOT create
     * any algebraic loops
     */
    ssSetInputPortDirectFeedThrough(S, INPORT_REF, 0);  


    /* Outputs: */
    if (!ssSetNumOutputPorts(S,NUM_OUTPORTS)) return;

    ssSetOutputPortWidth(        S, OUTPORT, DYNAMICALLY_SIZED);
    ssSetOutputPortComplexSignal(S, OUTPORT, COMPLEX_INHERITED);
    ssSetOutputPortReusable(     S, OUTPORT, 1);

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
    const boolean_T  c0        = (boolean_T)(ssGetInputPortComplexSignal(S,INPORT_IN)  == COMPLEX_YES);
    const boolean_T  c1        = (boolean_T)(ssGetInputPortComplexSignal(S,INPORT_REF) == COMPLEX_YES);
    int_T            N         = ssGetInputPortWidth(S,INPORT_IN);
    const boolean_T  need_copy = (boolean_T)(ssGetInputPortBufferDstPort(S, INPORT_IN) != OUTPORT);

    if (!c1) {
        /* Ref signal is real -> output real */
        real_T *y = ssGetOutputPortRealSignal(S,OUTPORT);

        if (!c0) {
            /* R->R */
            if (need_copy) {
                InputRealPtrsType uptr = ssGetInputPortRealSignalPtrs(S, INPORT_IN);
                while (N-- > 0) {
                    *y++ = **uptr++;
                }
            }

        } else {
            /* C->R */
            InputPtrsType uptr = ssGetInputPortSignalPtrs(S,INPORT_IN);
            while (N-- > 0) { 
                const creal_T *u = (creal_T *)(*uptr++);
                *y++ = u->re;
            }
        }

    } else {
        creal_T *y  = (creal_T *)ssGetOutputPortSignal(S,OUTPORT);

        if (!c0) {
            /* R->C */
            InputRealPtrsType uptr = ssGetInputPortRealSignalPtrs(S, INPORT_IN);
            while (N-- > 0) {
                y->re     = **uptr++;
                (y++)->im = 0.0;
            }

        } else {
            /* C->C */
            if (need_copy) {
                InputPtrsType uptr = ssGetInputPortSignalPtrs(S,INPORT_IN);
                while (N-- > 0) {
                    *y++ = *((creal_T *)(*uptr++));
                }
            }
        }
    }
}


static void mdlTerminate(SimStruct *S)
{
}


#if defined(MATLAB_MEX_FILE)
# define MDL_SET_INPUT_PORT_WIDTH
 static void mdlSetInputPortWidth(SimStruct *S, int_T port,
                                    int_T inputPortWidth)
{
    ssSetInputPortWidth(S,port,inputPortWidth);
    if (port == INPORT_IN) {
        ssSetOutputPortWidth(S,OUTPORT,inputPortWidth);
    }
}

# define MDL_SET_OUTPUT_PORT_WIDTH
static void mdlSetOutputPortWidth(SimStruct *S, int_T port,
                                     int_T outputPortWidth)
{
    ssSetOutputPortWidth(S,port,outputPortWidth);
    ssSetInputPortWidth(S,INPORT_IN,outputPortWidth);
}

#define MDL_SET_INPUT_PORT_COMPLEX_SIGNAL
static void mdlSetInputPortComplexSignal(SimStruct *S, int_T port, 
                                         CSignal_T iportComplex)
{
    ssSetInputPortComplexSignal(S, port, iportComplex);

    /* We can set the output port if we know the complexity
     * of the Reference input port 
     */
    if (port == INPORT_REF)  {
        if (ssGetOutputPortComplexSignal(S, OUTPORT) == COMPLEX_INHERITED) {
            ssSetOutputPortComplexSignal(S, OUTPORT, iportComplex);

        } else if (ssGetOutputPortComplexSignal(S, OUTPORT) != iportComplex) {
            ssSetErrorStatus(S,"Invalid input port complexity propagation");
        }
    }

}

#define MDL_SET_OUTPUT_PORT_COMPLEX_SIGNAL
static void mdlSetOutputPortComplexSignal(SimStruct *S, int_T port, 
                                          CSignal_T oportComplex)
{
    /* Set the output and reference ports to have the
     * same complexity
     */
    ssSetOutputPortComplexSignal(S, port, oportComplex);

    if (ssGetInputPortComplexSignal(S, INPORT_REF) == COMPLEX_INHERITED) {
        ssSetInputPortComplexSignal(S, INPORT_REF, oportComplex);
    
    } else if (ssGetInputPortComplexSignal(S, INPORT_REF) != oportComplex) {
        ssSetErrorStatus(S,"Invalid output port complexity propagation");
    }
}
#endif


#ifdef	MATLAB_MEX_FILE   
#include "simulink.c"     
#else
#include "cg_sfun.h"      
#endif

/* [EOF] sdspihcplx.c */
