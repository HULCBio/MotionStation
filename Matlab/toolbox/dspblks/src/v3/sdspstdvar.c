/*
* SDSPSTDVAR DSP Blockset S-Function for standard deviation 
* and variance computation. S-Function also computes the running 
* standard deviation and variance with reset input.
*
*  Copyright 1995-2002 The MathWorks, Inc.
*  $Revision: 1.27 $  $Date: 2002/04/14 20:42:59 $
*/
#define S_FUNCTION_NAME sdspstdvar
#define S_FUNCTION_LEVEL 2

#include "dsp_sim.h"

/* If running all dworks are needed, otherwise no dwork is needed. */
enum {ITER_IDX=0, SV_IDX, MAX_NUM_DWORKS};
enum {INPORT_DATA, INPORT_RESET};
enum {OUTPORT_DATA};

typedef enum {FcnVar=0, FcnStd} FcnType;

enum {FCN_ARGC=0, RUN_ARGC, FRAME_ARGC, NCHANS_ARGC, RESET_ARGC, NUM_ARGS};
#define FCN_ARG    (ssGetSFcnParam(S,FCN_ARGC))
#define RUN_ARG    (ssGetSFcnParam(S,RUN_ARGC))
#define FRAME_ARG  (ssGetSFcnParam(S,FRAME_ARGC))
#define NCHANS_ARG (ssGetSFcnParam(S,NCHANS_ARGC))
#define RESET_ARG  (ssGetSFcnParam(S,RESET_ARGC))

typedef struct {
    real_T sum; 
    real_T sqsum;
} sv_real;

typedef struct {
    creal_T sum; 
    real_T  sqsum;
} sv_cplx;


#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S) {

    if (!IS_FLINT_IN_RANGE(RUN_ARG, 0, 1)) {
        THROW_ERROR(S, "Parameter must be 0 (non-running) or 1 (running) only.");
    }

    if (!IS_FLINT_IN_RANGE(FCN_ARG, 0, 1)) {
        THROW_ERROR(S, "Fcn parameter must be 0 (variance) or 1 (standard deviation) only.");
    }

    if (!IS_FLINT_IN_RANGE(FRAME_ARG, 0, 1)) {
        THROW_ERROR(S, "Frame can be only 0 (non-frame based) or 1 (frame-based).");
    }

    if (!IS_FLINT_IN_RANGE(RESET_ARG, 0, 1)) {
        THROW_ERROR(S, "Reset inport flag must be 0 or 1.");
    }

    if (OK_TO_CHECK_VAR(S, NCHANS_ARG)) {
        if (!IS_FLINT_GE(NCHANS_ARG, 1)) {
            THROW_ERROR(S, "Number of channels must be a real, scalar, integer value > 0.");
        }
    }
}
#endif


static void mdlInitializeSizes(SimStruct *S)
    {
    ssSetNumSFcnParams(S, NUM_ARGS);
    
#if defined(MATLAB_MEX_FILE)
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) return;
    mdlCheckParameters(S);
    if (ssGetErrorStatus(S) != NULL) return;
#endif

    /* Cannot change params while running: */
    ssSetSFcnParamNotTunable(S, RUN_ARGC);
    ssSetSFcnParamNotTunable(S, FCN_ARGC);
    ssSetSFcnParamNotTunable(S, FRAME_ARGC);
    ssSetSFcnParamNotTunable(S, NCHANS_ARGC);
    ssSetSFcnParamNotTunable(S, RESET_ARGC);

    ssSetNumSampleTimes(S, PORT_BASED_SAMPLE_TIMES);

    {
        const boolean_T running = (boolean_T)(mxGetPr(RUN_ARG)[0] != 0.0);
        if (!running) {
           /* 
            * Standard deviation: 1 input, 1 output
            */
            /* Inputs: */
            if (!ssSetNumInputPorts(S, 1)) return;
            
            ssSetInputPortWidth(            S, INPORT_DATA, DYNAMICALLY_SIZED);
            ssSetInputPortDirectFeedThrough(S, INPORT_DATA, 1);
            ssSetInputPortComplexSignal(    S, INPORT_DATA, COMPLEX_INHERITED);
            ssSetInputPortReusable(         S, INPORT_DATA, 1);
            ssSetInputPortOverWritable(     S, INPORT_DATA, 0);
            ssSetInputPortSampleTime(       S, INPORT_DATA, INHERITED_SAMPLE_TIME);
            
            /* Outputs: */
            if (!ssSetNumOutputPorts(S,1)) return;
            
            ssSetOutputPortWidth(        S, OUTPORT_DATA, 1);
            ssSetOutputPortComplexSignal(S, OUTPORT_DATA, COMPLEX_NO);
            ssSetOutputPortReusable(     S, OUTPORT_DATA, 1);
            ssSetOutputPortSampleTime(   S, OUTPORT_DATA, INHERITED_SAMPLE_TIME);
            
        } else {
           /* 
            * Running standard deviation: 
            */
            /* Inputs: 2 input (data, reset)*/
            const boolean_T rstPort = (boolean_T)((int_T)(mxGetPr(RESET_ARG)[0]) != 0);
            int_T numInports = rstPort ? 2 : 1;

            if (!ssSetNumInputPorts(S, numInports)) return;

            ssSetInputPortWidth(            S, INPORT_DATA, DYNAMICALLY_SIZED);
            ssSetInputPortDirectFeedThrough(S, INPORT_DATA, 1);
            ssSetInputPortComplexSignal(    S, INPORT_DATA, COMPLEX_INHERITED);
            ssSetInputPortReusable(         S, INPORT_DATA, 1);
            ssSetInputPortOverWritable(     S, INPORT_DATA, 0);
            ssSetInputPortSampleTime(       S, INPORT_DATA, INHERITED_SAMPLE_TIME);

            if (rstPort) {
                ssSetInputPortWidth(            S, INPORT_RESET, 1);
                ssSetInputPortDirectFeedThrough(S, INPORT_RESET, 1);
                ssSetInputPortComplexSignal(    S, INPORT_RESET, COMPLEX_NO);
                ssSetInputPortReusable(         S, INPORT_RESET, 1);
                ssSetInputPortOverWritable(     S, INPORT_RESET, 0);
                ssSetInputPortSampleTime(       S, INPORT_RESET, INHERITED_SAMPLE_TIME);
            }

            /* Outputs: */
            if (!ssSetNumOutputPorts(S,1)) return;
            
            ssSetOutputPortWidth(        S, OUTPORT_DATA, DYNAMICALLY_SIZED);
            ssSetOutputPortComplexSignal(S, OUTPORT_DATA, COMPLEX_NO);
            ssSetOutputPortReusable(     S, OUTPORT_DATA, 1);
            ssSetOutputPortSampleTime(   S, OUTPORT_DATA, INHERITED_SAMPLE_TIME);
        }
    }
        
    if(!ssSetNumDWork(S, DYNAMICALLY_SIZED)) return;

    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE | 
                 SS_OPTION_USE_TLC_WITH_ACCELERATOR);
}


/* Set all ports to identical discrete rates: */
#include "dsp_ctrl_ts.c"


#define MDL_START
static void mdlStart(SimStruct *S)
{
#ifdef MATLAB_MEX_FILE
    const boolean_T running = (boolean_T)(mxGetPr(RUN_ARG)[0] != 0.0);
    const boolean_T frame   = (boolean_T)(mxGetPr(FRAME_ARG)[0] != 0.0);
    const int_T     nchans  = (int_T)(mxGetPr(NCHANS_ARG)[0]);
    const int_T     width   = ssGetInputPortWidth(S, INPORT_DATA);

    if (running) {
        if (ssGetSampleTime(S,0) == CONTINUOUS_SAMPLE_TIME) {
            THROW_ERROR(S,"Input to running variance and standard deviation blocks "
                               "must have a discrete sample time.");
        }
        if (frame && (width % nchans != 0)) {
            THROW_ERROR(S,"Size of input matrix does not match number of channels");
        }
    }
#endif
}


#define MDL_INITIALIZE_CONDITIONS
static void mdlInitializeConditions(SimStruct *S)
{
    const boolean_T running = (boolean_T)(mxGetPr(RUN_ARG)[0]);
    if (running) {
        real_T *iter_cnt = (real_T *)ssGetDWork(S, ITER_IDX);
        *iter_cnt = 0.0;
    }
}


static void mdlOutputs(SimStruct *S, int_T tid)
{
    const boolean_T  running = (boolean_T)(mxGetPr(RUN_ARG)[0] != 0.0);
    const FcnType    fcn     = (FcnType)((int_T)mxGetPr(FCN_ARG)[0]);
    const boolean_T  c0      = (ssGetInputPortComplexSignal(S, INPORT_DATA) == COMPLEX_YES);
    const int_T      N       = ssGetInputPortWidth(S, INPORT_DATA);
    real_T          *y       = ssGetOutputPortRealSignal(S, OUTPORT_DATA);

    if (!running) {
        /*
        * Non-running: 1 input, 1 output
        */
        
        if (N == 1) {
            /* Scalar input: */
            *y = 0.0;
            
        } else if (!c0) {
            /* 
            * Real input: 
            */
            InputRealPtrsType  uptr = ssGetInputPortRealSignalPtrs(S, INPORT_DATA);
            real_T             sx   = 0.0;  
            real_T             sx2  = 0.0;  
            int_T              i    = N;
            
            while (i-- > 0) {
                const real_T u = **(uptr++);
                sx  += u;     
                sx2 += u*u; 
            }
            
            *y = (sx2 - sx*sx/N) / (N-1);
            if (fcn == FcnStd) {
                *y = sqrt(*y);
            }
            
        } else {
            /* 
            * Complex input: 
            */
            InputPtrsType  uptr = ssGetInputPortSignalPtrs(S, INPORT_DATA);
            creal_T        sx   = {0.0, 0.0};
            real_T         sx2  = 0.0;
            int_T          i    = N;
            
            while (i-- > 0) {
                const creal_T *u = (creal_T *)(*uptr++);
                const creal_T  v = *u;
                sx.re += v.re;
                sx.im += v.im;
                sx2 += CMAGSQ(v);
            }
            
            {
                const real_T yp = (sx2 - CMAGSQ(sx) / N) / (N-1);
                *y = (fcn == FcnVar) ? yp : sqrt(yp);
            }
        }
        
    } else {
        /*
         * Running: 2 inputs (Val, Rst), 1 output
         */
        const int_T        width    = ssGetInputPortWidth(S, INPORT_DATA);
        const boolean_T    frame    = (boolean_T)(mxGetPr(FRAME_ARG)[0] != 0.0);
        const int_T        nchans   = (frame) ? (int_T)mxGetPr(NCHANS_ARG)[0] : width;
        const int_T        nsamps   = (frame) ? width /nchans : 1;
        real_T            *iter_cnt = (real_T *)ssGetDWork(S, ITER_IDX);
        
        /* If there is a reset port, and it is non-zero, all states are to be reset.
         * However, just because the reset input is zero doesn't mean we're
         * not going to reset ... we ALWAYS reset at the first time step
         * after initialization.  So check before setting the reset flag.
         */
        {
            const boolean_T rstPort = (boolean_T)((int_T)(mxGetPr(RESET_ARG)[0]) != 0);
            if (rstPort) {
                InputRealPtrsType pRstIn = ssGetInputPortRealSignalPtrs(S, INPORT_RESET);
                if (*pRstIn[0] != 0.0) {
                    *iter_cnt = 0.0;  /* Will reset on zero count */
                }
            }
        }

        if (!c0) {
           /* 
            * Real input: 
            */
            sv_real *sv_data = (sv_real *)ssGetDWork(S, SV_IDX);
            
            if (*iter_cnt == 0.0) {
                int_T i = nchans;

                if (nsamps == 1) {
                    /* Single time step - special case for output value: */
                    InputRealPtrsType uptr0 = ssGetInputPortRealSignalPtrs(S, INPORT_DATA);
                    while(i-- > 0) {
                        const real_T val   = **uptr0++;
                        sv_data->sum       = val;
                        (sv_data++)->sqsum = val*val;
                        *y++ = 0.0;
                    }
                    (*iter_cnt)++;
                    return;

                } else {
                    /* Multiple time steps - reset states and continue: */
                    while(i-- > 0) {
                        sv_data->sum       = 0.0;
                        (sv_data++)->sqsum = 0.0;
                    }
                    sv_data -= nchans;
                }
            }

            *iter_cnt += nsamps;

            {
                InputRealPtrsType uptr0 = ssGetInputPortRealSignalPtrs(S, INPORT_DATA);
                real_T            iter  = *iter_cnt;
                int_T             i     = nchans;

                while(i-- > 0) {
                    real_T sx  = sv_data->sum;
                    real_T sx2 = sv_data->sqsum;
                    int_T j = nsamps;
                        while(j-- > 0) {
                            const real_T val = **uptr0++;
                            sx  += val;
                            sx2 += val * val;
                        }
                    {
                        const real_T yp = (sx2 - sx*sx / iter) / (iter - 1);
                        *y++ = (fcn == FcnVar) ? yp : sqrt(yp);
                    }

                    /* Update state: */
                    sv_data->sum       = sx;
                    (sv_data++)->sqsum = sx2;
                }
            }
            
        } else {
            /* 
            * Complex input:
            */
            sv_cplx *sv_data = (sv_cplx *)ssGetDWork(S, SV_IDX);
            
            if (*iter_cnt == 0.0) {
                int_T i = nchans;

                if (nsamps == 1) {
                    /* Single time step - special case for output value: */
                    InputPtrsType uptr0 = ssGetInputPortSignalPtrs(S, INPORT_DATA);
                    while(i-- > 0) {
                        const creal_T val = *((creal_T *)(*uptr0++));
                        sv_data->sum       = val;
                        (sv_data++)->sqsum = CMAGSQ(val);
                        *y++ = 0.0;
                    }
                    (*iter_cnt)++;
                    return;

                } else {
                
                    static creal_T czero;
					czero.re = 0.0;
					czero.im = 0.0;
					while(i-- > 0) {
                        sv_data->sum       = czero;
                        (sv_data++)->sqsum = 0.0;
                    }
                    sv_data -= nchans;
                }
            }

            *iter_cnt += nsamps;

            {
                InputPtrsType uptr0 = ssGetInputPortSignalPtrs(S, INPORT_DATA);
                real_T        iter  = *iter_cnt;
                int_T         i     = nchans;
                
                while(i-- > 0) {
                    creal_T sx  = sv_data->sum;
                    real_T  sx2 = sv_data->sqsum;
                    int_T j = nsamps;
                    while(j-- > 0) {
                        const creal_T val = *((creal_T *)(*uptr0++));
                        sx.re += val.re;
                        sx.im += val.im;
                        sx2 += CMAGSQ(val);
                    }
                    {
                        const real_T yp = (sx2 - CMAGSQ(sx) / iter) / (iter - 1);
                        *y++ = (fcn == FcnVar) ? yp : sqrt(yp);
                    }

                    /* Update state: */
                    sv_data->sum       = sx;
                    (sv_data++)->sqsum = sx2;
                }
            }

        }  /* real vs complex input */
    } /* non-running vs running */
}


static void mdlTerminate(SimStruct *S)
{
}


#if defined(MATLAB_MEX_FILE)
# define MDL_SET_INPUT_PORT_WIDTH
static void mdlSetInputPortWidth(SimStruct *S, int_T port,
                                 int_T inputPortWidth)
{
    const boolean_T running = (boolean_T)(mxGetPr(RUN_ARG)[0] != 0.0);
    
    if (running) {
        /* 2 inputs, 1 output */
        if (port != 0) {  /* Input port 1 is not dynamic */
            THROW_ERROR(S, "Invalid input port number for running case");
        }
        ssSetInputPortWidth(S, port, inputPortWidth);

        {
            const boolean_T  frame    = (boolean_T)mxGetPr(FRAME_ARG)[0];
            const int_T      nchans   = (frame) ? (int_T)mxGetPr(NCHANS_ARG)[0] : inputPortWidth ;
            ssSetOutputPortWidth(S, OUTPORT_DATA, nchans);   
        }

    } else {
        /* 1 input, 1 output */
        if (port != 0) {
            THROW_ERROR(S, "Invalid input port number for non-running case");
        }
        ssSetInputPortWidth(S, port, inputPortWidth);
    }
}


# define MDL_SET_OUTPUT_PORT_WIDTH
static void mdlSetOutputPortWidth(SimStruct *S, int_T port,
                                  int_T outputPortWidth)
    {
    const boolean_T running = (boolean_T)(mxGetPr(RUN_ARG)[0] != 0.0);
    
    if (running) {
        if (port != 0) {
            THROW_ERROR(S, "Invalid output port number for width "
                "propagation in the running case.");
        }
        ssSetOutputPortWidth(S,port,outputPortWidth);

        {
            const boolean_T frame = (boolean_T)mxGetPr(FRAME_ARG)[0];
        
            if (frame) {
                if (outputPortWidth != (int_T)mxGetPr(NCHANS_ARG)[0])  {
                    THROW_ERROR(S,"Invalid output port width propagation for frame-based"
                                       "running variance or standard deviation");
                }
                /* Samples per frame unknown so we can't set the input port width */
            } else {
                /* Not frame based */
                ssSetInputPortWidth(S, INPORT_DATA, outputPortWidth);
            }
        }

    } else {
        /* Output port is a scalar (not dynamic) */
        THROW_ERROR(S, "Error propagating output port width info for non-running case");
    }
}


#define MDL_SET_WORK_WIDTHS
static void mdlSetWorkWidths(SimStruct *S)
    {
    const boolean_T running = (boolean_T)(mxGetPr(RUN_ARG)[0] != 0.0);
    const int_T     nDWorks = (running)? MAX_NUM_DWORKS : 0;

    if(!ssSetNumDWork(S, nDWorks)) return;

    if (running) {
        /* Running var/std */
        const int_T      N      = ssGetInputPortWidth(S, INPORT_DATA);
        const boolean_T  frame  = (boolean_T)mxGetPr(FRAME_ARG)[0];
        const int_T      nchans = (frame) ? (int_T)mxGetPr(NCHANS_ARG)[0] : N;
        const boolean_T  c0     = (ssGetInputPortComplexSignal(S, INPORT_DATA) == COMPLEX_YES);
        int_T            cache_siz;
        
        if (c0) {
            cache_siz = nchans * sizeof(sv_cplx) / sizeof(real_T);
        } else {
            cache_siz = nchans * sizeof(sv_real) / sizeof(real_T);
        }
        
        ssSetDWorkWidth(        S, SV_IDX, cache_siz);
        ssSetDWorkDataType(     S, SV_IDX, SS_DOUBLE);
        ssSetDWorkComplexSignal(S, SV_IDX, COMPLEX_NO);
        ssSetDWorkName(         S, SV_IDX, "StdVarData");
        /* ssSetDWorkUsedAsDState( S, SV_IDX, 1); */
        
        ssSetDWorkWidth(        S, ITER_IDX, 1);
        ssSetDWorkDataType(     S, ITER_IDX, SS_DOUBLE);
        ssSetDWorkComplexSignal(S, ITER_IDX, COMPLEX_NO);
        ssSetDWorkName(         S, ITER_IDX, "Iteration");
        /* ssSetDWorkUsedAsDState( S, ITER_IDX, 1); */

        
    } 
}


#define MDL_SET_INPUT_PORT_COMPLEX_SIGNAL
static void mdlSetInputPortComplexSignal(SimStruct *S, int_T portIdx,
                                         CSignal_T iPortComplexSignal)
{
    if (portIdx != 0) {
        THROW_ERROR(S,"Invalid port index for running mode complex propagation.");
    }
    ssSetInputPortComplexSignal(S, portIdx, iPortComplexSignal);  
}

#define MDL_SET_OUTPUT_PORT_COMPLEX_SIGNAL
static void mdlSetOutputPortComplexSignal(SimStruct *S, int_T portIdx, 
                                          CSignal_T oPortComplexSignal)
{
    THROW_ERROR(S,"Invalid complex output port propagation call.");
}
#endif


#ifdef  MATLAB_MEX_FILE    
#include "simulink.c"      
#else
#include "cg_sfun.h"       
#endif

/* [EOF] sdspstdvar.c */
