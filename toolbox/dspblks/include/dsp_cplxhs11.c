/*
 * dsp_cplxhs11.c (Complex HandShake 1 input 1 output)
 *
 * DSP Blockset helper function.
 *
 * Include this file for complex port handshake
 * Handshake for port complexity for the case where
 *   there is 1 input port and 1 output port,
 *   and the computation is similar to "Y = X".
 *
 * In other words,
 *  - the output is complex if the input is complex
 *  - the output is real if the input is real
 *
 *  
 *  Copyright 1995-2002 The MathWorks, Inc.
 * $Revision: 1.12 $ $Date: 2002/04/14 20:35:21 $
 */

static void CheckandSetPortComplexity(
    SimStruct *S,
    int_T      port,
    CSignal_T  portComplex,
    int_T      caller
)
{
    CSignal_T Inport0, Outport0;

    if (ssGetNumOutputPorts(S) < 1) {
        ssSetErrorStatus(S, "There must be at least one output port when including dsp_cplxhs11.");
        return;
    }
    if (ssGetNumInputPorts(S) < 1) {
        ssSetErrorStatus(S, "There must be at least one input port when including dsp_cplxhs11.");
        return;
    }

    {
        CSignal_T temp = portComplex ? COMPLEX_YES : COMPLEX_NO;
        if (caller == 0) {
            ssSetInputPortComplexSignal(S, port, temp);
        } else {
            ssSetOutputPortComplexSignal(S, port, temp);
        }
    }

    Inport0  = ssGetInputPortComplexSignal(S, 0);
    Outport0 = ssGetOutputPortComplexSignal(S, 0);

    /* At this point, at least one of the ports is known */

    if (Inport0 == COMPLEX_INHERITED) {
        ssSetInputPortComplexSignal(S, 0, Outport0);

    } else if (Outport0 == COMPLEX_INHERITED) {
        ssSetOutputPortComplexSignal(S, 0, Inport0);

    } else {
        /* Both ports known */
        if (Inport0 != Outport0) {
            static const char *msg;
            if (Inport0 == COMPLEX_NO) {
                msg = "Output must be real if input is real.";
            } else {
                msg = "Output must be complex if input is complex.";
            }
            ssSetErrorStatus(S, msg);
        }
    }
}

#define MDL_SET_INPUT_PORT_COMPLEX_SIGNAL
#ifdef __cplusplus
static void cppmdlSetInputPortComplexSignal( SimStruct *S,
                                             int_T port,
                                             CSignal_T portComplex)
#else
static void mdlSetInputPortComplexSignal(    SimStruct *S,
                                             int_T port,
                                             CSignal_T portComplex)
#endif
{
    CheckandSetPortComplexity(S, port, portComplex, 0);
}

#define MDL_SET_OUTPUT_PORT_COMPLEX_SIGNAL
#ifdef __cplusplus
static void cppmdlSetOutputPortComplexSignal(SimStruct *S,
                                             int_T port,
                                             CSignal_T portComplex)
#else
static void mdlSetOutputPortComplexSignal(   SimStruct *S,
                                             int_T port,
                                             CSignal_T portComplex)
#endif
{
    CheckandSetPortComplexity(S, port, portComplex, 1);
}
/* [EOF] dsp_cplxhs11.c */
