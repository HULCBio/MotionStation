/*
 * SDSPPERM Permute a vector or a matrix.
 * Permutation is done by rows or by columns.
 *
 *  MODE: 1=Rows, 2=Columns
 *
 *   
 *  Copyright 1995-2002 The MathWorks, Inc.
 *  $Revision: 1.13 $  $Date: 2002/04/14 20:42:27 $
 */
#define S_FUNCTION_NAME sdspperm
#define S_FUNCTION_LEVEL 2

#include "dsp_sim.h"

enum {MODE_ROWS=1, MODE_COLS};                 /* MODE arg popup values   */
enum {BADIDX_CLIP=1, BADIDX_WARN, BADIDX_ERR}; /* BADIDX arg popup values */
enum {INPORT_MATRIX=0, INPORT_PERM};           /* Input port indices      */
enum {OUTPORT_MATRIX=0};                       /* Output port indices     */

/* Input argument indices  */
enum {MODE_ARGC=0, BADIDX_ARGC, COLS_ARGC, NUM_PARAMS};

#define MODE_ARG   (ssGetSFcnParam(S,MODE_ARGC))
#define BADIDX_ARG (ssGetSFcnParam(S,BADIDX_ARGC))
#define COLS_ARG   (ssGetSFcnParam(S,COLS_ARGC))


#ifdef MATLAB_MEX_FILE
static char *getErrMsg(SimStruct *S, int_T idx)
{
    static char msg[256];
    static char header[] = "Invalid permutation index (%d) in block '%s'.";

    int_T num_digits = (int_T)(1 + ceil(log10((real_T)idx)));
    if (strlen(header)-4 + strlen(ssGetPath(S)) + num_digits > 255) {
	strcpy(msg, "Invalid permutation index.");
    } else {
        sprintf(msg, header, idx, ssGetPath(S));
    }
    return(msg);
}
#endif


/*
 * NOTE: Macro assumes S is defined in the caller context
 */
#ifdef MATLAB_MEX_FILE
#define HANDLE_BADIDX_MODE(N, i_idx, badidx)          \
{                                                     \
    switch (badidx) {                                 \
      case BADIDX_ERR:                                \
	/* Error out if index is invalid */           \
	if ((i_idx) < 0) {                            \
            THROW_ERROR(S, getErrMsg(S, i_idx+1)); \
	} else if ((i_idx) > (N)-1) {                 \
            THROW_ERROR(S, getErrMsg(S, i_idx+1)); \
	}                                             \
	break;                                        \
      case BADIDX_WARN:                               \
	/* Clip permutation indices to row limits */  \
	if ((i_idx) < 0) {                            \
	    mexWarnMsgTxt(getErrMsg(S, i_idx+1));     \
	    (i_idx) = 0;                              \
	} else if ((i_idx) > (N)-1) {                 \
	    mexWarnMsgTxt(getErrMsg(S, i_idx+1));     \
	    (i_idx) = (N)-1;                          \
	}                                             \
	break;                                        \
      case BADIDX_CLIP:                               \
	/* Clip permutation indices to row limits */  \
	if ((i_idx) < 0) {                            \
	    (i_idx) = 0;                              \
	} else if ((i_idx) > (N)-1) {                 \
	    (i_idx) = (N)-1;                          \
	}                                             \
	break;                                        \
    }                                                 \
}
#else
#define HANDLE_BADIDX_MODE(N, i_idx, badidx)          \
/* Always clip permutation indices: */                \
if ((i_idx) < 0) {                                    \
    (i_idx) = 0;                                      \
} else if ((i_idx) > (N)-1) {                         \
    (i_idx) = (N)-1;                                  \
}
#endif


#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S) {

    if(!IS_FLINT_IN_RANGE(MODE_ARG,1, 2)) {
	THROW_ERROR(S, "Mode must be 1=Rows or 2=Cols.");
    }

    if(!IS_FLINT_IN_RANGE(BADIDX_ARG,1, 3)) {
	THROW_ERROR(S, "Bad Index must be 1=Clip, 2=Warn, or 3=Error.");
    }

    if (OK_TO_CHECK_VAR(S, COLS_ARG)) {        
        if (!IS_FLINT_GE(COLS_ARG,1)) {
            THROW_ERROR(S, "Columns of input must be a scalar integer.");
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

    /* Enable this code when TLC is present */
    ssSetSFcnParamNotTunable(S, MODE_ARGC);
    ssSetSFcnParamNotTunable(S, COLS_ARGC);

    /* Not tunable in RTW generated code. */
    if ((ssGetSimMode(S) == SS_SIMMODE_EXTERNAL) || 
        (ssGetSimMode(S) == SS_SIMMODE_RTWGEN)) {    
        
        ssSetSFcnParamNotTunable(S, BADIDX_ARGC);
    }

    ssSetNumSampleTimes(S, PORT_BASED_SAMPLE_TIMES);

    /* Inputs: */
    if (!ssSetNumInputPorts(S, 2)) return;

    ssSetInputPortWidth(            S, INPORT_MATRIX, DYNAMICALLY_SIZED);
    ssSetInputPortDirectFeedThrough(S, INPORT_MATRIX, 1);
    ssSetInputPortComplexSignal(    S, INPORT_MATRIX, COMPLEX_INHERITED);
    ssSetInputPortReusable(         S, INPORT_MATRIX, 1);
    ssSetInputPortOverWritable(     S, INPORT_MATRIX, 0);
    ssSetInputPortSampleTime(       S, INPORT_MATRIX, INHERITED_SAMPLE_TIME);
    

    ssSetInputPortWidth(            S, INPORT_PERM, DYNAMICALLY_SIZED);
    ssSetInputPortDirectFeedThrough(S, INPORT_PERM, 1);
    ssSetInputPortComplexSignal(    S, INPORT_PERM, COMPLEX_NO);
    ssSetInputPortReusable(         S, INPORT_PERM, 1);
    ssSetInputPortOverWritable(     S, INPORT_PERM, 0);
    ssSetInputPortSampleTime(       S, INPORT_PERM, INHERITED_SAMPLE_TIME);


    /* Outputs: */
    if (!ssSetNumOutputPorts(S,1)) return;

    ssSetOutputPortWidth(        S, OUTPORT_MATRIX, DYNAMICALLY_SIZED);
    ssSetOutputPortComplexSignal(S, OUTPORT_MATRIX, COMPLEX_INHERITED);
    ssSetOutputPortReusable(     S, OUTPORT_MATRIX, 1);
    ssSetOutputPortSampleTime(   S, OUTPORT_MATRIX, INHERITED_SAMPLE_TIME);

    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE |
                 SS_OPTION_USE_TLC_WITH_ACCELERATOR);
}

/* Set all ports to the identical, discrete rates: */
#define DSP_ALLOW_CONTINUOUS
#include "dsp_ctrl_ts.c"

static void mdlOutputs(SimStruct *S, int_T tid)
{
    const int_T	      mode   = (int_T)(mxGetPr(MODE_ARG)[0]);
    const int_T       badidx = (int_T)(mxGetPr(BADIDX_ARG)[0]);
    const int_T	      N      = ssGetInputPortWidth(S, INPORT_MATRIX);
    InputRealPtrsType P      = ssGetInputPortRealSignalPtrs(S, INPORT_PERM);

    /* Determine Matrix size: */
    const int_T Nc = (int_T)(mxGetPr(COLS_ARG)[0]);
    const int_T Nr = N / Nc;
    const int_T Np = ssGetInputPortWidth(S, INPORT_PERM);

    /* Determine size of input data: */
    const boolean_T c0 = 
	(ssGetInputPortComplexSignal(S, INPORT_MATRIX) == COMPLEX_YES);

    if (mode == MODE_COLS) {
	/* Permute cols */

	if (!c0) {
	    /* Real */

	    InputRealPtrsType A = ssGetInputPortRealSignalPtrs(S, INPORT_MATRIX);
	    real_T           *y = ssGetOutputPortRealSignal(S, OUTPORT_MATRIX);
	    int_T             i;

	    for (i=0; i<Np; i++) {
		int_T i_idx = (int_T)(**P++ - 1);  /* Convert from MATLAB indices to C */

		HANDLE_BADIDX_MODE(Nc, i_idx, badidx);

		{
		    InputRealPtrsType Ap = A + i_idx*Nr;
		    int_T j = Nr;
		    while(j-- > 0) {
			*y++ = **Ap++;
		    }
		}
	    }

	} else {
	    /* Complex */

	    InputPtrsType A = ssGetInputPortSignalPtrs(S, INPORT_MATRIX);
	    creal_T      *y = ssGetOutputPortSignal(S, OUTPORT_MATRIX);
	    int_T i;

	    for (i=0; i<Np; i++) {
		int_T    i_idx = (int_T)(**P++ - 1);

		HANDLE_BADIDX_MODE(Nc, i_idx, badidx);

		{
		    InputPtrsType Ap = A + i_idx*Nr;
		    int_T j = Nr;
		    while(j-- > 0) {
                        *y++ = *((creal_T *)(*Ap++));
		    }
		}
	    }
	}

    } else {
	/* Permute rows */

	if (!c0) {
	    /* Real */

	    InputRealPtrsType A = ssGetInputPortRealSignalPtrs(S, INPORT_MATRIX);
	    real_T           *y = ssGetOutputPortRealSignal(S, OUTPORT_MATRIX);
	    int_T i;

	    for (i=0; i<Np; i++) {
		int_T i_idx = (int_T)(**P++ - 1);

		HANDLE_BADIDX_MODE(Nr, i_idx, badidx);

		{
		    InputRealPtrsType Ap = A + i_idx;
		    int_T j   = Nc;
		    int_T jNp = 0;
		    while(j-- > 0) {
			/* # rows in output = length of perm vector */
			y[jNp] = **Ap;
			Ap  += Nr;
			jNp += Np;
		    }
		    y++; /* Next row */
		}
	    }

	} else {
	    /* Complex */

	    InputPtrsType A = ssGetInputPortSignalPtrs(S, INPORT_MATRIX);
	    creal_T      *y = ssGetOutputPortSignal(S, OUTPORT_MATRIX);
	    int_T i;

	    for (i=0; i<Np; i++) {
		int_T    i_idx = (int_T)(**P++ - 1);

		HANDLE_BADIDX_MODE(Nr, i_idx, badidx);

		{
		    InputPtrsType Ap = A + i_idx;
		    int_T j   = Nc;   /* # rows in output = length of perm vector */
		    int_T jNp = 0;
		    while(j-- > 0) {
                        y[jNp] = *((creal_T *)(*Ap));
			Ap  += Nr;
			jNp += Np;
		    }
		    y++; /* Next row */
		}
	    }
	}
    }
}


static void mdlTerminate(SimStruct *S)
{
}


#if defined(MATLAB_MEX_FILE)
/*
 * Check port width information as it is sequentially obtained
 * and set the unknown port widths when possible.
 * Input and output port widths become known in arbitrary order. 
 */
static void CheckandSetPorts(
    SimStruct *S,
    int_T      port,
    int_T      PortWidth,
    int_T      caller
)
{
    /*
     *  INPORT_MATRIX: Matrix or vector, length NA = Nr*Nc
     *    INPORT_PERM: Permutation vector P, length Np
     * OUTPORT_MATRIX: Matrix or vector, length NO
     *
     * If mode=rows,   NO=Np x Nc
     * If mode=cols,   NO=Nr x Np
     */
    const int_T mode = (int_T)(mxGetPr(MODE_ARG)[0]);
    const int_T Nc   = (int_T)(mxGetPr(COLS_ARG)[0]);
    int_T       Nr   = -1;
    int_T InWidth, PermWidth, OutWidth;

    if (caller == 0) {
	ssSetInputPortWidth(S,port,PortWidth);
    } else {
	ssSetOutputPortWidth(S,port,PortWidth);
    }

    InWidth   = ssGetInputPortWidth( S, INPORT_MATRIX);
    PermWidth = ssGetInputPortWidth( S, INPORT_PERM);
    OutWidth  = ssGetOutputPortWidth(S, OUTPORT_MATRIX);

    /*
     * If width of INPORT_MATRIX is known,
     * check that its size is Nr x Nc
     */
    if (InWidth != DYNAMICALLY_SIZED) {
	Nr = InWidth / Nc;  /* Integer division */

	if (Nr*Nc != InWidth) {
	    THROW_ERROR(S,"Size of input matrix does not match "
                               "number of columns parameter.");
	}

        if (OutWidth != DYNAMICALLY_SIZED) {
            /*
             * Output matrix size is also known.
             * Check that output array size is compatible with input
             * Set Permutation length.
             */
            if (mode == MODE_ROWS) {
	        /* rows, NO = Np*Nc -> Np=NO/Nc */
	        real_T d = OutWidth / (real_T)Nc;
	        PermWidth = (int_T)d;
	        if (d != PermWidth) {
		    THROW_ERROR(S,"Number of columns in input matrix does "
				       "not equal number of columns in output.");
	        }

	    } else {
		/* cols, NO=Nr*Np -> Np=NO/Nr*/
		real_T d = OutWidth / (real_T)Nr;
		PermWidth = (int_T)d;
		if (d != PermWidth) {
		    THROW_ERROR(S,"Number of rows in input matrix does "
				       "not equal number of rows in output.");
		}
	    }

            /* Set permutation width */
	    ssSetInputPortWidth(S, INPORT_PERM, PermWidth);

        } else if (PermWidth != DYNAMICALLY_SIZED) {
            /*
             * Permutation vector is also known.
             * Nothing else can be checked.
             * Set output matrix size.
             */
            const int_T Np = PermWidth;
	    OutWidth = (mode == MODE_COLS) ? Nr*Np : Np*Nc;
            ssSetOutputPortWidth(S, OUTPORT_MATRIX, OutWidth);
        }
    }

    /*
     * If output AND permutation widths are known,
     * check that its size is Np x Nc (MODE_ROWS) or Nr x Np (MODE_COLS)
     */
    if ((PermWidth != DYNAMICALLY_SIZED) &&
	(OutWidth  != DYNAMICALLY_SIZED)) {
        const int_T Np = PermWidth;
	real_T      d;

        if (mode == MODE_COLS) {
            d = OutWidth / (real_T)Np;
            Nr = (int_T)d;
            if ((Nr != d) || (OutWidth != Nr * Np)) {
        	THROW_ERROR(S,"Size of output matrix does not match "
				   "number of columns parameter or size of "
				   "permutation input port.");
            }

            /* Set input array size as Nr x Nc */
            InWidth = Nr*Nc;
            ssSetInputPortWidth(S, INPORT_MATRIX, InWidth);

        } else {
            if (OutWidth != Np * Nc) {
        	THROW_ERROR(S,"Size of output matrix does not match "
				   "number of columns parameter or size of "
				   "permutation input port.");
            }
            /* Don't know Nr */
        }
    }
}


#define MDL_SET_INPUT_PORT_WIDTH
static void mdlSetInputPortWidth(SimStruct *S, int_T port,
				    int_T inputPortWidth)
{
    CheckandSetPorts(S,port,inputPortWidth,0);
}

#define MDL_SET_OUTPUT_PORT_WIDTH
static void mdlSetOutputPortWidth(SimStruct *S, int_T port,
				     int_T outputPortWidth)
{
    CheckandSetPorts(S,port,outputPortWidth,1);
}

#endif /* MATLAB_MEX_FILE */


/* Complex handshake:
 *
 * NOTE: Even though we have 2 input ports, we perform the handshake as if
 *       we have 1 input and 1 output (dsp_cplxhs11.c).  This is because
 *       the second input port is a "fixed" complexity (it is purely real).
 */
#include "dsp_cplxhs21.c"


#ifdef	MATLAB_MEX_FILE  
#include "simulink.c"	 
#else
#include "cg_sfun.h"	 
#endif

/* [EOF] sdspperm.c */
