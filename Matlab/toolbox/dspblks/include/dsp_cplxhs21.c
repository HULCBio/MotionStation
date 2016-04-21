/*
 * dsp_cplxhs1121.c (Complex HandShake for 1-in/1-out OR 2-in 1-out situations)
 *
 * DSP Blockset helper function.
 *
 * Include this file for complex port handshake
 * Handshake for port complexity for the case where
 *   there are 2 input ports and 1 output port,
 *   and the computation is similar to "Y = A*B".
 *
 * In other words,
 *  - the inport ports are independent and can be either real or complex
 *  - the output port is complex if either input is complex
 *  - the output port is real if and only if both inputs are real
 *  - otherwise, the output is unknown until both inputs are known.
 *
 * A and B can each be real or complex, allowing 4 combinations:
 *  A B -> Y
 *  - -    -
 *  R R    R  R=Real
 *  R C    C  C=Complex
 *  C R    C
 *  C C    C
 *
 *  
 *  Copyright 1995-2002 The MathWorks, Inc.
 * $Revision: 1.13 $ $Date: 2002/04/14 20:35:23 $
 */

static void CheckandSetPortComplexity(
    SimStruct *S,
    int_T      port,
    CSignal_T  portComplex,
    int_T      caller)
{
    CSignal_T Inport[2], Outport[1];
    CSignal_T OutportMustBe = COMPLEX_INHERITED;
    int_T num_inputs = ssGetNumInputPorts(S);
    int_T num_outputs = ssGetNumOutputPorts(S);

    if (num_outputs < 1) {
        ssSetErrorStatus(S, "There must be at least one output port when including dsp_cplxhs1121.");
        return;
    }
    if (num_inputs < 1) {
        ssSetErrorStatus(S, "There must be at least one input port when including dsp_cplxhs1121.");
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

    Inport[0]  = ssGetInputPortComplexSignal(S, 0);
    if (num_inputs>1) {
        Inport[1]  = ssGetInputPortComplexSignal(S, 1);
    }

    Outport[0] = ssGetOutputPortComplexSignal(S, 0);

    /* At this point, at least one of the ports is known */

    if (num_inputs == 1) {
        /* One input - algorithm copied from dsp_cplxhs11.c: */

        if (Inport[0] == COMPLEX_INHERITED) {
            ssSetInputPortComplexSignal(S, 0, Outport[0]);

        } else if (Outport[0] == COMPLEX_INHERITED) {
            ssSetOutputPortComplexSignal(S, 0, Inport[0]);

        } else {
            /* Both ports known */
            if (Inport[0] != Outport[0]) {
                static const char *msg;
                if (Inport[0] == COMPLEX_NO) {
                    msg = "Output must be real if input is real.";
                } else {
                    msg = "Output must be complex if input is complex.";
                }
                ssSetErrorStatus(S, msg);
            }
        }

    } else {
        /* Two inputs: */

        if ((Inport[0] == COMPLEX_YES) || (Inport[1] == COMPLEX_YES)) {
	    /* 1 or 2 inputs are complex:
	     * Output must be complex.
	     * Other input unknown if not already specified.
	     */
	    OutportMustBe = COMPLEX_YES;

        } else if ((Inport[0] == COMPLEX_NO) && (Inport[1] == COMPLEX_NO)) {
	    /* 2 inputs are real:
	     * Output must be complex.
	     * Other input is unknown.
	     */
	    OutportMustBe = COMPLEX_NO;
        }


        if (Outport[0] == COMPLEX_INHERITED) {
            /* Outport has not been set */

	    ssSetOutputPortComplexSignal(S, 0, OutportMustBe);

        } else {
            /* Outport has already been set */

            if ((OutportMustBe != COMPLEX_INHERITED) &&
                (Outport[0] != OutportMustBe)) {
	        static const char *msg;

	        if (OutportMustBe == COMPLEX_YES) {
	            msg = "Output port must be complex if either input port is complex.";
	        } else {
	            msg = "Output port must be real if both input ports are real.";
	        }
	        ssSetErrorStatus(S, msg);
	        return;
            }

            {
                int_T num_inports; /* number of ports which have complexity set */

                if ((Inport[0] == COMPLEX_INHERITED) && (Inport[1] == COMPLEX_INHERITED)) {
                    num_inports = 0;
                } else if ((Inport[0] != COMPLEX_INHERITED) && (Inport[1] != COMPLEX_INHERITED)) {
                    num_inports = 2;
                } else {
                    num_inports = 1;
                }

                if (num_inports == 1) {
                    /* There is one unknown input port */

                    int_T known_inport   = (Inport[0] != COMPLEX_INHERITED) ? 0 : 1;
                    CSignal_T known_inport_complexity =
                                    ssGetInputPortComplexSignal(S, known_inport);

                    int_T unknown_inport = 1 - known_inport;
                    CSignal_T unknown_inport_complexity = COMPLEX_INHERITED;

                    /* Can only set the unknown inport if the output is
                     * complex, and the one known input is real:
                     */
                    if ((Outport[0] == COMPLEX_YES) && (known_inport_complexity == COMPLEX_NO)) {
                        unknown_inport_complexity = COMPLEX_YES;
                    } else if (Outport[0] == COMPLEX_NO) {
                        unknown_inport_complexity = COMPLEX_NO;
                    }
                    ssSetInputPortComplexSignal(S, unknown_inport, unknown_inport_complexity);
                }
            }
        }
    }
}

#define MDL_SET_INPUT_PORT_COMPLEX_SIGNAL
#ifdef __cplusplus
static void cppmdlSetInputPortComplexSignal(SimStruct *S,
					 int_T port,
					 CSignal_T portComplex)
#else
static void mdlSetInputPortComplexSignal(SimStruct *S,
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
static void mdlSetOutputPortComplexSignal(SimStruct *S,
					  int_T port,
					  CSignal_T portComplex)
#endif
{
    CheckandSetPortComplexity(S, port, portComplex, 1);
}

/* [EOF] dsp_cplxhs1121.c */
