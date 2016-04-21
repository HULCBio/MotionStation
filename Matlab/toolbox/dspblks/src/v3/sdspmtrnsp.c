/*
 * SDSPMTRNSP  A SIMULINK matrix transpose block.
 *
 *  The Matrix Transpose block transposes the M-by-N input
 *  matrix such that the output matrix has size N-by-M.
 * 
 *  Syntax:  [sys, x0] = sdspmtrnsp(t,x,u,flag,Asize)
 *
 *   
 *   
 *  Copyright 1995-2002 The MathWorks, Inc.
 *  $Revision: 1.18 $  $Date: 2002/04/14 20:42:25 $
 */
#define S_FUNCTION_NAME sdspmtrnsp
#define S_FUNCTION_LEVEL 2

#include "dsp_sim.h"

enum {ASIZE_IDX=0, HERMIT_IDX, NUM_PARAMS};
enum {INPORT=0};
enum {OUTPORT=0};


#define ASIZE_ARG   ssGetSFcnParam(S,ASIZE_IDX)
#define HERMIT_ARG  ssGetSFcnParam(S,HERMIT_IDX)

#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S) {

    if (OK_TO_CHECK_VAR(S, ASIZE_ARG)) {
        if (!IS_FLINT(ASIZE_ARG)) {
            THROW_ERROR(S, "Columns of input must be a scalar integer.");
        }
    }

    if (!IS_FLINT_IN_RANGE(HERMIT_ARG,0,1)) {
        THROW_ERROR(S, "Hermitian flag must be 0 or 1.");
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
    ssSetInputPortDirectFeedThrough(S, INPORT, 1);
    ssSetInputPortComplexSignal(    S, INPORT, COMPLEX_INHERITED);
    ssSetInputPortReusable(         S, INPORT, 1);
    /*
     * There is not an in-place transpose in mdlOutputs, so the 
     * inputs are not overwritaable.  We may implement an in-place 
     * algorithm a future update of this block.
     */
    ssSetInputPortOverWritable(     S, INPORT, 0);
    
     /* Outputs: */
    if (!ssSetNumOutputPorts(S,1)) return;
    ssSetOutputPortWidth(        S, OUTPORT, DYNAMICALLY_SIZED);
    ssSetOutputPortComplexSignal(S, OUTPORT, COMPLEX_INHERITED);
    ssSetOutputPortReusable(     S, OUTPORT, 1);

    /*
     * Parameter ASIZE_IDX is not tunable
     * because it effects output width
     */
    ssSetSFcnParamNotTunable(S, ASIZE_IDX);

    /* Not tunable in RTW generated code. */
    if ((ssGetSimMode(S) == SS_SIMMODE_EXTERNAL) || 
        (ssGetSimMode(S) == SS_SIMMODE_RTWGEN)) {    
        
        ssSetSFcnParamNotTunable(S, HERMIT_IDX);
    }

    ssSetNumSampleTimes(S, 1);
    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE |
                 SS_OPTION_USE_TLC_WITH_ACCELERATOR);
}


static void mdlInitializeSampleTimes(SimStruct *S)
{
    /*
     * Note, blocks that are continuous in nature should have
     * a single sample time of 0.0
     */
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);
}


#define MDL_START
static void mdlStart(SimStruct *S)
{
#ifdef MATLAB_MEX_FILE
    const int_T width = ssGetInputPortWidth(S,ASIZE_IDX);
    const int_T cols  = (int_T)mxGetPr(ASIZE_ARG)[0];
    
    /* The columns argument should divide evenly into the width of the port */
    if((width % cols) !=0) {
        ssSetErrorStatus(S, "Size of input is not consistent with block parameter.");
        return;
    }    
#endif
}


static void mdlOutputs(SimStruct *S, int_T tid)
{
    const boolean_T  need_copy = (boolean_T)(ssGetInputPortBufferDstPort(S, INPORT) != OUTPORT);
    
    if (need_copy) {   
        const boolean_T c0    = (boolean_T)(ssGetInputPortComplexSignal(S,INPORT) == COMPLEX_YES);
        const int_T     width = ssGetInputPortWidth(S,INPORT);
        const int_T     cols  = (int_T)(mxGetPr(ASIZE_ARG)[0]); 
        const int_T     rows  = width/cols;                    
        int_T           j     = cols;
        
        if (!c0) {
            /* Real Input */
            
            InputRealPtrsType  uptr = ssGetInputPortRealSignalPtrs(S,0);
            real_T            *y    = ssGetOutputPortRealSignal(S,OUTPORT);       
            
            /* 
            * Transpose matrix:  Walk the inputs in order down 
            * the columns and write the outputs across the rows 
            */
            while(j-- > 0) {
                real_T *yy = y++;
                int_T   i  = rows;
                while(i-- > 0) {
                    *yy = **uptr++;
                    yy += cols;
                }
            }
            
        } else {
            /* Complex Input */
            
            InputPtrsType   uptr      = ssGetInputPortSignalPtrs(S,INPORT);
            creal_T        *y         = (creal_T *)ssGetOutputPortSignal(S,OUTPORT);
            const boolean_T hermitian = (boolean_T)(mxGetPr(HERMIT_ARG)[0] == 1);
            const real_T    sgn       = (hermitian) ? -1.0 : 1.0;
            
            /* Walk the inputs in order and write the outputs transposed */
            while(j-- > 0) {
                creal_T *yy = y++;
                int_T    i   = rows;
                while(i-- > 0) {
                    creal_T *u  = (creal_T *)(*uptr++);  /* increment the input in order */
                    yy->re = u->re;
                    yy->im = u->im * sgn;  /* possible conjugate */
                    yy += cols;            /* jump the output to the next column */
                }
            }
            
        }
    } else {

        /* In-place algorithm to go here. */
        THROW_ERROR(S,"In-place tranpose algorithm not implemented.");

    }
}


#if defined(MATLAB_MEX_FILE)
# define MDL_SET_INPUT_PORT_WIDTH
  static void mdlSetInputPortWidth(SimStruct *S, int_T port,
                                    int_T inputPortWidth)
{
      ssSetInputPortWidth(S, port, inputPortWidth);
      ssSetOutputPortWidth(S, 0, inputPortWidth);   
}

# define MDL_SET_OUTPUT_PORT_WIDTH
  static void mdlSetOutputPortWidth(SimStruct *S, int_T port,
                                    int_T outputPortWidth)
{
      ssSetOutputPortWidth(S,port,outputPortWidth);
      ssSetInputPortWidth(S,0,outputPortWidth);
}
#endif

static void mdlTerminate(SimStruct *S)
{
}


/* Complex handshake */
#include "dsp_cplxhs11.c"    


#ifdef	MATLAB_MEX_FILE    
#include "simulink.c"      
#else
#include "cg_sfun.h"       
#endif

/* [EOF] sdspmtrnsp.c */
