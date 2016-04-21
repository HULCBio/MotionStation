/*
 * SDSPMSUM Matrix sum block.
 *
 *  The Matrix Sum block sums along the rows or columns
 *  of the input matrix.
 *
 *   
 *  Copyright 1995-2002 The MathWorks, Inc.
 *  $Revision: 1.12 $  $Date: 2002/04/14 20:42:37 $
 */
#define S_FUNCTION_NAME  sdspmsum
#define S_FUNCTION_LEVEL 2

#include "dsp_sim.h"

enum {COL_ARGC, DIM_ARGC, NUM_PARAMS};
enum {
      ROW_DIM=1, /* Sum along the rows    */
      COL_DIM    /* Sum along the columns */
      };

enum {INPORT};
enum {OUTPORT};

#define COL_ARG ssGetSFcnParam(S,COL_ARGC)
#define DIM_ARG ssGetSFcnParam(S,DIM_ARGC)

#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S) {

    if (OK_TO_CHECK_VAR(S, COL_ARG)) {      

        if (!IS_FLINT(COL_ARG)) {
            THROW_ERROR(S, "Columns of input must be a scalar integer.");
        }
    }    

    if (!IS_FLINT_IN_RANGE(DIM_ARG, 1, 2)) {
        THROW_ERROR(S, "Matrix sum dimensions must be 1=rows or 2=columns.");
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

    /* Inputs: */
    if (!ssSetNumInputPorts(S, 1)) return;
    ssSetInputPortWidth(            S, INPORT, DYNAMICALLY_SIZED);
    ssSetInputPortComplexSignal(    S, INPORT, COMPLEX_INHERITED);
    ssSetInputPortDirectFeedThrough(S, INPORT, 1);
    ssSetInputPortReusable(         S, INPORT, 1);

    /*
     * The output could be the same size as the input
     * in two important (degenerate) cases:
     *  - sum across rows, but input is a column
     *  - sum down columns, but input is a row
     * In these cases, we can perform an in-place algorithm
     * for which output = input, i.e., do nothing!
     */
    ssSetInputPortOverWritable(     S, INPORT, 1);
    
     /* Outputs: */
    if (!ssSetNumOutputPorts(S,1)) return;
    ssSetOutputPortWidth(        S, OUTPORT, DYNAMICALLY_SIZED);
    ssSetOutputPortComplexSignal(S, OUTPORT, COMPLEX_INHERITED);
    ssSetOutputPortReusable(    S, OUTPORT, 1);

    ssSetSFcnParamNotTunable(S, COL_ARGC);
    ssSetSFcnParamNotTunable(S, DIM_ARGC);

    ssSetNumSampleTimes(S, 1);
    ssSetOptions(       S, SS_OPTION_EXCEPTION_FREE_CODE |
                        SS_OPTION_USE_TLC_WITH_ACCELERATOR);
}


static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);
}


#define MDL_START
static void mdlStart(SimStruct *S)
{
#ifdef MATLAB_MEX_FILE
    const int_T width = ssGetInputPortWidth(S,INPORT);
    const int_T cols  = (int_T)mxGetPr(COL_ARG)[0];
    if(width % cols != 0) {
        THROW_ERROR(S, "Size of input is not consistent with number "
		     "of column specified in block dialog.");
    }
#endif
}


static void mdlOutputs(SimStruct *S, int_T tid)
{
    /*
     * We won't need to make a copy of the input data ONLY IF the output
     * width = input width, in which case there's nothing to be done!
     */
    const boolean_T  need_copy = (boolean_T)(ssGetInputPortBufferDstPort(S, INPORT) != OUTPORT);

    if (need_copy) {

	const boolean_T c0     = (ssGetInputPortComplexSignal(S,INPORT) == COMPLEX_YES);
	const boolean_T rowSum = (boolean_T)(mxGetPr(DIM_ARG)[0] == ROW_DIM);
	const int_T	cols   = (int_T)(mxGetPr(COL_ARG)[0]); 
	const int_T	rows   = ssGetInputPortWidth(S,INPORT) / cols;
	
	if (!c0) {
	    /* Real Input */
	    
	    InputRealPtrsType  uptr = ssGetInputPortRealSignalPtrs(S,INPORT);
	    real_T	      *y    = ssGetOutputPortRealSignal(   S,OUTPORT);
	    
	    if (rowSum) {
		/*
		 * ROW SUM
		 */
#if 1
		/* Visits inputs in-order - can roll over discontiguous inputs: */
		/* Copy first column input output area: */
		int_T i;
		for(i=0; i<rows; i++) {
		    y[i] = **(uptr++);
		}
		/* Add subsequent columns to output: */
		for (i=1; i++ < cols; ) {
		    int_T j;
		    for (j=0; j<rows; j++) {
			y[j] += **(uptr++);
		    }
		}
#else
		/* Visits inputs out-of-order - not for use with loop-roller: */
		int_T j;
		for (j=0; j<rows; j++) {
		    real_T s = **uptr;
		    for (i=1; i<cols; i++) {
			s += *uptr[i*rows];
		    }
		    *y++ = s;
		    uptr++;
		}
#endif
	    } else {
		/*
		 * COLUMN SUM
		 */
		int_T j = cols;
		while(j-- > 0) {
		    real_T s = **(uptr++);
		    int_T i  = rows-1;
		    while(i-- > 0) {
			s += **(uptr++);
		    }
		    *y++ = s;
		}
	    }
	    
	} else {
	    /* Complex Input */
	    
	    InputPtrsType  uptr = ssGetInputPortSignalPtrs(S,INPORT);
            creal_T	      *y    = (creal_T *)ssGetOutputPortSignal(S,OUTPORT);
            
            if (rowSum) {
                /*
                 * ROW SUM
                 */
#if 1
                /* Visits inputs in-order */
                /* Copy first column input output area: */
                int_T i;
                for(i=0; i<rows; i++) {
                    y[i] = *((creal_T *)(*uptr++));
                }
                /* Add subsequent columns to output: */
                for (i=1; i++ < cols; ) {
                    int_T j;
                    for (j=0; j<rows; j++) {
                        y[j].re += ((creal_T *)(*uptr  ))->re;
                        y[j].im += ((creal_T *)(*uptr++))->im;
                    }
                }
#else
                /* Visits inputs out-of-order */
                int_T j;
                for (j=0; j<rows; j++) {
                    creal_T s = *((creal_T *)(*uptr));
                    for (i=1; i<cols; i++) {
                        s.re += ((creal_T *)uptr[i+rows])->re;
                        s.im += ((creal_T *)uptr[i+rows])->im;
                    }
                    *y++ = s;
                    uptr++;
                }
#endif
            } else {
                /*
                 * COLUMN SUM
                 */
                int_T j = cols;
                while(j-- > 0) {
                    creal_T s = *((creal_T *)(*uptr++));
                    int_T	i = rows-1;
                    while(i-- > 0) {
                        s.re += ((creal_T *)(*uptr	))->re;
                        s.im += ((creal_T *)(*uptr++))->im;
                    }
                    *y++ = s;
                }
            }
        }
    }
}

static void mdlTerminate(SimStruct *S)
{
}


#if defined(MATLAB_MEX_FILE)
#define MDL_SET_INPUT_PORT_WIDTH
static void mdlSetInputPortWidth(SimStruct *S, int_T port,
                                    int_T inputPortWidth)
{
    const boolean_T rowSum          = (boolean_T)(mxGetPr(DIM_ARG)[0] == ROW_DIM);
    const int_T     cols            = (int_T)(mxGetPr(COL_ARG)[0]); 
    const int_T     rows            = inputPortWidth / cols;
    const int_T     outputPortWidth = (rowSum) ? rows : cols;

    ssSetInputPortWidth( S, INPORT,  inputPortWidth);
    ssSetOutputPortWidth(S, OUTPORT, outputPortWidth);

    /* Can cross-check COL_ARG with output width: */
    if ( (!rowSum && (cols != outputPortWidth))  ||
	 ( rowSum && (rows != outputPortWidth))   ) {

	THROW_ERROR(S, "Input port width not consistent with number "
		     "of columns specified in block dialog.");
    }
}

#define MDL_SET_OUTPUT_PORT_WIDTH
static void mdlSetOutputPortWidth(SimStruct *S, int_T port,
                                     int_T outputPortWidth)
{
    const boolean_T rowSum = (boolean_T)(mxGetPr(DIM_ARG)[0] == ROW_DIM);
    const int_T     cols   = (int_T)(mxGetPr(COL_ARG)[0]); 
    const int_T     rows   = (rowSum) ? outputPortWidth : -1;

    ssSetOutputPortWidth(S, OUTPORT, outputPortWidth);

    /* Can cross-check COL_ARG with output width: */
    if ( (!rowSum && (cols != outputPortWidth))  ||
	 ( rowSum && (rows != outputPortWidth))   ) {

	THROW_ERROR(S, "Output port width not consistent with number "
		     "of columns specified in block dialog.");
    }

    /* Cannot determine input width from output width if row sum is selected: */
    if (rows != -1) {
	ssSetInputPortWidth(S, INPORT,  rows * cols);
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

/* [EOF] sdspmsum.c */
