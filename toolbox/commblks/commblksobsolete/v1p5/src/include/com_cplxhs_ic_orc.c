/*
 *    Complex HandShake 1 input 2 output
 *
 *    Copyright 1996-2002 The MathWorks, Inc.
 *    $Revision: 1.1.6.1 $  $Date: 2003/01/26 18:45:04 $
 */

#if defined(MATLAB_MEX_FILE)

static void CheckandSetPortComplexity(
    SimStruct *S,
    int_T      port,
    CSignal_T  portComplex,
    int_T      caller
)
{
    CSignal_T Inport0, Outport0;

    if (ssGetNumOutputPorts(S) < 1) {
        ssSetErrorStatus(S, "There must be at least one output port when including com_cplxhs_ic_orc.c.");
        return;
    }
    if (ssGetNumInputPorts(S) < 1) {
        ssSetErrorStatus(S, "There must be at least one input port when including com_cplxhs_ic_orc.c.");
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

	/* --- This is where the port specific selection is performed */
    Inport0  = ssGetInputPortComplexSignal(S, INPORT_SIGNAL);
    Outport0 = ssGetOutputPortComplexSignal(S, OUTPORT_SIGNAL);

    /* At this point, at least one of the ports is known */

    if (Inport0 == COMPLEX_INHERITED) {
        ssSetInputPortComplexSignal(S, INPORT_SIGNAL, Outport0);

    } else if (Outport0 == COMPLEX_INHERITED) {
        ssSetOutputPortComplexSignal(S, OUTPORT_SIGNAL, Inport0);

    } else {
        /* Both ports known */
        if (Inport0 != Outport0) {
            static char *msg;
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
static void mdlSetInputPortComplexSignal(SimStruct *S,
					 int_T port,
					 CSignal_T portComplex)
{
    CheckandSetPortComplexity(S, port, portComplex, 0);
}

#define MDL_SET_OUTPUT_PORT_COMPLEX_SIGNAL
static void mdlSetOutputPortComplexSignal(SimStruct *S,
					  int_T port,
					  CSignal_T portComplex)
{
    CheckandSetPortComplexity(S, port, portComplex, 1);
}

#endif

/* [EOF] com_cplxhs_ic_orc.c */
