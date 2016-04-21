/*
 * File: sdspdmult.c
 *
 * Abstract:
 *      S-function for multiplying a diagonal matrix (stored as a vector)
 *      and a full matrix in either order.  This corresponds to row- or
 *      column-scaling of a matrix.
 *
 * March 1998
 * Copyright 1995-2002 The MathWorks, Inc.
 * $Revision: 1.13 $ $Date: 2002/04/14 20:42:29 $
 */
#define S_FUNCTION_NAME  sdspdmult
#define S_FUNCTION_LEVEL 2

#include "dsp_sim.h"

enum {MODE_DA=1, MODE_AD};   /* MODE arg popup values   */
enum {INPORT_A=0, INPORT_D}; /* Input port indices      */
enum {OUTPORT_Y=0};          /* Output port indices     */

/* Input argument indices  */
enum {MODE_ARGC=0, COLS_ARGC, NUM_PARAMS};

#define MODE_ARG (ssGetSFcnParam(S,MODE_ARGC))
#define COLS_ARG (ssGetSFcnParam(S,COLS_ARGC))


#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S) {

    if (!IS_FLINT_IN_RANGE(MODE_ARG, 1, 2)) {
	THROW_ERROR(S, "Mode must be 1=D*A or 2=A*D.");
    }

    if (OK_TO_CHECK_VAR(S, COLS_ARG)) {
        if (!IS_FLINT_GE(COLS_ARG, 1)) {
            THROW_ERROR(S, "Columns of input must be a scalar integer > 0.");
        }
    }
}
#endif


static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumSFcnParams(S, NUM_PARAMS);

#if defined(MATLAB_MEX_FILE)
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) return;
    mdlCheckParameters(S);
    if (ssGetErrorStatus(S) != NULL) return;
#endif

    ssSetSFcnParamNotTunable(S, MODE_ARGC);
    ssSetSFcnParamNotTunable(S, COLS_ARGC);
    
    /* Define ports: */
    if (!ssSetNumInputPorts(S, 2)) return;

    ssSetInputPortWidth(            S, INPORT_D, DYNAMICALLY_SIZED);
    ssSetInputPortDirectFeedThrough(S, INPORT_D, 1);
    ssSetInputPortComplexSignal(    S, INPORT_D, COMPLEX_INHERITED);
    ssSetInputPortReusable(        S, INPORT_D, 1);
    ssSetInputPortOverWritable(     S, INPORT_D, 0);  /* revisits multiple times */

    ssSetInputPortWidth(            S, INPORT_A, DYNAMICALLY_SIZED);
    ssSetInputPortDirectFeedThrough(S, INPORT_A, 1);
    ssSetInputPortComplexSignal(    S, INPORT_A, COMPLEX_INHERITED);
    ssSetInputPortReusable(        S, INPORT_A, 1);
    ssSetInputPortOverWritable(     S, INPORT_A, 0); /* visited out of order wrt outputs */

    if (!ssSetNumOutputPorts(S,1)) return;

    ssSetOutputPortWidth(        S, OUTPORT_Y, DYNAMICALLY_SIZED);
    ssSetOutputPortComplexSignal(S, OUTPORT_Y, COMPLEX_INHERITED);
    ssSetOutputPortReusable(    S, OUTPORT_Y, 1);
        
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
    /*
     * MODE_DA: Scale rows of A
     * MODE_AD: Scale columns of A
     *
     * D and A can each be real or complex, allowing 4 combinations:
     *  D A -> Y
     *  - -    -
     *  R R    R    R=Real
     *  R C    C    C=Complex
     *  C R    C
     *  C C    C
     */
    const int_T     mode  = (int_T)(mxGetPr(MODE_ARG)[0]);
    const int_T     Acols = (int_T)(mxGetPr(COLS_ARG)[0]);
    const int_T     Arows = ssGetInputPortWidth(S, INPORT_A) / Acols;
    const boolean_T Ycplx = (boolean_T)(ssGetOutputPortComplexSignal(S, OUTPORT_Y) == COMPLEX_YES);

    if (mode == MODE_AD) {
	/* Scale columns of A */

	int_T cols = Acols;

	if (!Ycplx) {
	    /* Purely real */
	    InputRealPtrsType  pD   = ssGetInputPortRealSignalPtrs(S, INPORT_D);
	    InputRealPtrsType  pA   = ssGetInputPortRealSignalPtrs(S, INPORT_A);
	    real_T            *pY   = ssGetOutputPortRealSignal(   S, OUTPORT_Y);

	    while(cols-- > 0) {
		const real_T Dval = **pD++;
		int_T        rows = Arows;
		while(rows-- > 0) {
		    *pY++ = **pA++ * Dval;
		}
	    }

	} else {
	    /* Complex (and possibly real) inputs */
	    const boolean_T Dcplx = (boolean_T)(ssGetInputPortComplexSignal(S, INPORT_D) == COMPLEX_YES);
	    const boolean_T Acplx = (boolean_T)(ssGetInputPortComplexSignal(S, INPORT_A) == COMPLEX_YES);

	    if (Dcplx && Acplx) {
		InputPtrsType  pD = ssGetInputPortSignalPtrs(S, INPORT_D);
		InputPtrsType  pA = ssGetInputPortSignalPtrs(S, INPORT_A);
		creal_T       *pY = (creal_T *)ssGetOutputPortSignal(S, OUTPORT_Y);

		while(cols-- > 0) {
		    const creal_T Dval = *((creal_T *)(*pD++));
		    int_T         rows = Arows;
		    while(rows-- > 0) {
			const creal_T Aval = *((creal_T *)(*pA++));
			pY->re       = CMULT_RE(Aval, Dval);
			(pY++)->im   = CMULT_IM(Aval, Dval);
		    }
		}

	    } else if (Dcplx) {
		InputPtrsType     pD = ssGetInputPortSignalPtrs(S, INPORT_D);
		InputRealPtrsType pA = ssGetInputPortRealSignalPtrs(S, INPORT_A);
		creal_T          *pY = (creal_T *)ssGetOutputPortSignal(S, OUTPORT_Y);

		while(cols-- > 0) {
		    const creal_T Dval = *((creal_T *)(*pD++));
		    int_T         rows = Arows;
		    while(rows-- > 0) {
			const real_T Aval = **pA++;
			pY->re      = Aval * Dval.re;
			(pY++)->im  = Aval * Dval.im;
		    }
		}

	    } else {
		InputRealPtrsType pD = ssGetInputPortRealSignalPtrs(S, INPORT_D);
		InputPtrsType     pA = ssGetInputPortSignalPtrs(S, INPORT_A);
		creal_T          *pY = (creal_T *)ssGetOutputPortSignal(S, OUTPORT_Y);

		while(cols-- > 0) {
		    const real_T Dval = **pD++;
		    int_T        rows = Arows;
		    while(rows-- > 0) {
			const creal_T Aval = *((creal_T *)(*pA++));
			pY->re       = Dval * Aval.re;
			(pY++)->im   = Dval * Aval.im;
		    }
		}
	    }
	}

    } else {
	/* Scale rows of A */

	int_T cols = Acols;

	if (!Ycplx) {
	    /* Purely real */
	    InputRealPtrsType  pA = ssGetInputPortRealSignalPtrs(S, INPORT_A);
	    real_T            *pY = ssGetOutputPortRealSignal(   S, OUTPORT_Y);

	    while(cols-- > 0) {
		InputRealPtrsType pD   = ssGetInputPortRealSignalPtrs(S, INPORT_D);
		int_T             rows = Arows;
		while(rows-- > 0) {
		    *pY++ = (**pA++) * (**pD++);
		}
	    }

	} else {
	    /* Complex (and possibly real) inputs */
	    const boolean_T Dcplx = (boolean_T)(ssGetInputPortComplexSignal(S, INPORT_D) == COMPLEX_YES);
	    const boolean_T Acplx = (boolean_T)(ssGetInputPortComplexSignal(S, INPORT_A) == COMPLEX_YES);

	    if (Dcplx && Acplx) {
		InputPtrsType  pA = ssGetInputPortSignalPtrs(S, INPORT_A);
		creal_T       *pY = (creal_T *)ssGetOutputPortSignal(S, OUTPORT_Y);

		while(cols-- > 0) {
		    InputPtrsType pD   = ssGetInputPortSignalPtrs(S, INPORT_D);
		    int_T         rows = Arows;
		    while(rows-- > 0) {
			const creal_T Aval = *((creal_T *)(*pA++));
			const creal_T Dval = *((creal_T *)(*pD++));
			pY->re     = CMULT_RE(Aval, Dval);
			(pY++)->im = CMULT_IM(Aval, Dval);
		    }
		}

	    } else if (Dcplx) {
		InputRealPtrsType pA = ssGetInputPortRealSignalPtrs(S, INPORT_A);
		creal_T          *pY = (creal_T *)ssGetOutputPortSignal(S, OUTPORT_Y);

		while(cols-- > 0) {
		    InputPtrsType pD   = ssGetInputPortSignalPtrs(S, INPORT_D);
		    int_T         rows = Arows;
		    while(rows-- > 0) {
			const real_T  Aval = **pA++;
			const creal_T Dval = *((creal_T *)(*pD++));
			pY->re     = Aval * Dval.re;
			(pY++)->im = Aval * Dval.im;
		    }
		}

	    } else {
		InputPtrsType     pA = ssGetInputPortSignalPtrs(S, INPORT_A);
		creal_T          *pY = (creal_T *)ssGetOutputPortSignal(S, OUTPORT_Y);

		while(cols-- > 0) {
		    InputRealPtrsType pD   = ssGetInputPortRealSignalPtrs(S, INPORT_D);
		    int_T             rows = Arows;
		    while(rows-- > 0) {
			const real_T  Dval = **pD++;
			const creal_T Aval = *((creal_T *)(*pA++));
			pY->re     = Dval * Aval.re;
			(pY++)->im = Dval * Aval.im;
		    }
		}
	    }
	}
    }
}


static void mdlTerminate(SimStruct *S)
{
}


#ifdef MATLAB_MEX_FILE

static void CheckandSetPortWidth(
    SimStruct *S,
    int_T      port,
    int_T      PortWidth,
    int_T      caller
)
{
    const int_T mode = (int_T)(mxGetPr(MODE_ARG)[0]);
    const int_T Acols = (int_T)(mxGetPr(COLS_ARG)[0]);
    int_T Dwidth, Awidth, Ywidth, YMustBe;

    if (caller == 0) {
	ssSetInputPortWidth(S,port,PortWidth);
    } else {
	ssSetOutputPortWidth(S,port,PortWidth);
    }

    Dwidth = ssGetInputPortWidth(S, INPORT_D);
    Awidth = ssGetInputPortWidth(S, INPORT_A);
    Ywidth = ssGetOutputPortWidth(S, OUTPORT_Y);

    if (Awidth != DYNAMICALLY_SIZED) {
	/* A known.
	 * We know what dimension D should be (based on mult order)
	 * We also know what dimension Y should be
	 */
	int_T Arows = Awidth / Acols;
	if (Arows*Acols != Awidth) {
	    THROW_ERROR(S, "Number of columns does not correspond "
		    		"to size of A matrix.");
	}

	/* At this point, size(A) is known */

	if (Dwidth == DYNAMICALLY_SIZED) {
	    Dwidth = (mode == MODE_DA) ? Arows : Acols ;
	    ssSetInputPortWidth(S, INPORT_D, Dwidth);
	} else {
	    if (Dwidth != ((mode == MODE_DA) ? Arows : Acols)) {
		THROW_ERROR(S, "Length of diagonal D is not compatible "
				    "with size of input matrix A.");
	    }
	}

	/* At this point, size(D) is known */

	YMustBe = ((mode == MODE_DA) ? Dwidth * Acols : Dwidth * Arows);
	if (Ywidth == DYNAMICALLY_SIZED) {
	    Ywidth = YMustBe;
	    ssSetOutputPortWidth(S, OUTPORT_Y, Ywidth);
	} else {
	    if (Ywidth != YMustBe) {
		THROW_ERROR(S, "Size of Y matrix is not compatible "
				    "with length of diagonal D and size of A matrix.");
	    }
	}

	/* At this point, Ywidth is known */
	return;
    }

    /* If D is known,
     *   if D*A, we can guess Ar=Dr, and we know Ac, so A is known.
     *   then Yr=Dr and Yc=Ac, so we can solve everything.
     *
     *   if A*D, we can verify Acols=Dwidth, but we still do not know
     *   Ar unless Y is known.  If Y is known, then Ar=Yr and Dwidth=Yc.
     *   Ac is known (as usual).  To get Yc from Ywidth, recall Yr=Ar.
     *
     * We know Awidth is NOT known, since the above case did not execute.
     */
    if (Dwidth != DYNAMICALLY_SIZED) {
	if (mode==MODE_DA) {
	    int_T Arows = Dwidth;

	    Awidth = Arows*Acols;
	    ssSetInputPortWidth(S, INPORT_A, Awidth);

	    if (Ywidth == DYNAMICALLY_SIZED) {
		Ywidth = Dwidth * Acols;  /* DrxDr * ArxAc = YrxYc, e.g., Yr=Dr and Yc=Ac */
		ssSetOutputPortWidth(S, OUTPORT_Y, Ywidth);
	    } else {
		if (Ywidth != Dwidth * Acols) {
		    THROW_ERROR(S, "Size of Y is not compatible with length "
					"of diagonal D and size of matrix A.");
		}
	    }
	} else {
	    /* mode == MODE_AD: */
	    if (Acols != Dwidth) {
		THROW_ERROR(S, "Number of columns in A must equal length of diagonal D.");
	    }
	    if (Ywidth != DYNAMICALLY_SIZED) {
		int_T Ycols = Dwidth;          /* ArxAc * DnxDn = YrxYc  ->  Yr=Ar, Yc=Dn */
		int_T Yrows = Ywidth / Ycols;  /* Validate this assumption below */
		int_T Arows = Yrows;

		if (Ycols*Yrows!=Ywidth) {
		    THROW_ERROR(S, "Size of output matrix Y not compatible "
					"with length of diagonal D.");
		}

		Awidth = Arows*Acols;
		ssSetInputPortWidth(S, INPORT_A, Awidth);
	    }
	}
    }

    /* Ywidth must be known if we got here.
     * By itself, we can do nothing more.
     * If D is known,
     *    then we know DrxDr * ArxAc = YrxYc  -> therefore, Yr=Dr and Yc=Ac
     *    and Ar must be Dr, so we know everything.
     *
     * If A is known,
     *    then Ar and Ac are known, hence Yc is known, and Dr=Ar=Yr - all are known.
     * HOWEVER! We know A is not known, otherwise the case above would have executed.
     *          Ditto for D.
     */
}

#define MDL_SET_INPUT_PORT_WIDTH
static void mdlSetInputPortWidth(SimStruct *S, int_T port,
                                    int_T inputPortWidth)
{
    CheckandSetPortWidth(S,port,inputPortWidth,0);
}

#define MDL_SET_OUTPUT_PORT_WIDTH
static void mdlSetOutputPortWidth(SimStruct *S, int_T port,
                                     int_T outputPortWidth)
{
    CheckandSetPortWidth(S,port,outputPortWidth,1);
}

#endif /* MATLAB_MEX_FILE */


#include "dsp_cplxhs21.c"  /* Complex handshake */


#ifdef  MATLAB_MEX_FILE
#include "simulink.c"   /* MEX Interface Mechanism   */
#else
#include "cg_sfun.h"    /* RTW Registration Function */
#endif


/* [EOF] sdspdmult.c */
