/*
 * File: sdspbsub.c
 *
 * Abstract:
 *      S-function for solving Ux=b by backward substitution.
 *      U is an upper (or unit upper) triangular full matrix.
 *      The entries in the lower triangle are ignored.
 *
 * Copyright 1995-2002 The MathWorks, Inc.
 * $Revision: 1.17 $ $Date: 2002/04/14 20:43:43 $
 */
#define S_FUNCTION_NAME  sdspbsub
#define S_FUNCTION_LEVEL 2

#include "dsp_sim.h"

enum {INPORT_U=0, INPORT_B, NUM_INPORTS};
enum {OUTPORT_X=0, NUM_OUTPORTS};
enum {UNIT_ARGC=0, NUM_ARGS};

#define UNIT_ARG (ssGetSFcnParam(S,UNIT_ARGC))

#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S) {
    
    if (!IS_FLINT_IN_RANGE(UNIT_ARG,0,1)) {
        THROW_ERROR(S, "Unit upper override option must be 0 or 1.");
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

    /* Define ports: */
    if (!ssSetNumInputPorts(S, NUM_INPORTS)) return;
    
    ssSetInputPortWidth(            S, INPORT_U, DYNAMICALLY_SIZED);
    ssSetInputPortDirectFeedThrough(S, INPORT_U, 1);
    ssSetInputPortComplexSignal(    S, INPORT_U, COMPLEX_INHERITED);
    ssSetInputPortReusable(        S, INPORT_U, 1);
    
    ssSetInputPortWidth(            S, INPORT_B, DYNAMICALLY_SIZED);
    ssSetInputPortDirectFeedThrough(S, INPORT_B, 1);
    ssSetInputPortComplexSignal(    S, INPORT_B, COMPLEX_INHERITED);
    ssSetInputPortReusable(        S, INPORT_B, 1);
    ssSetInputPortOverWritable(     S, INPORT_B, 1);  /* Can overwrite OUTPORT_X */
    
    if (!ssSetNumOutputPorts(S, NUM_OUTPORTS)) return;
    
    ssSetOutputPortWidth(        S, OUTPORT_X, DYNAMICALLY_SIZED);
    ssSetOutputPortComplexSignal(S, OUTPORT_X, COMPLEX_INHERITED);
    
    ssSetNumSampleTimes(S, 1);
    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE);
}


static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);
}


static void mdlOutputs(SimStruct *S, int_T tid)
{
   /* Solve UX = B
    *   Inputs: U, B
    *   Output: X
    */
    const boolean_T cB         = (boolean_T)(ssGetInputPortComplexSignal(S,INPORT_B) == COMPLEX_YES);
    const boolean_T cU         = (boolean_T)(ssGetInputPortComplexSignal(S,INPORT_U) == COMPLEX_YES);
    const int_T     N2         = ssGetInputPortWidth(S,INPORT_U);
    const int_T     N          = (int_T)sqrt((real_T)N2);
    const int_T     NP         = ssGetInputPortWidth(S,INPORT_B);
    const int_T     P          = (int_T)(((real_T)NP) / ((real_T)N)); /* Num cols in B */
    const boolean_T unit_upper = (boolean_T)(mxGetPr(UNIT_ARG)[0] == 1.0);
    
    if (!cB && !cU) {
        /* Real inputs: */
        
        InputRealPtrsType  pU = ssGetInputPortRealSignalPtrs(S, INPORT_U)  + N2-1;
        InputRealPtrsType  pb = ssGetInputPortRealSignalPtrs(S, INPORT_B)  + NP-1;
        real_T            *x  = ssGetOutputPortRealSignal(   S, OUTPORT_X);
        int_T              i,k;
        
        for(k=P; k>0; k--) {
            InputRealPtrsType     pUcol = pU;
            for(i=0; i<N; i++) {
                real_T           *xj    = x + k*N-1;
                real_T            s     = 0.0;
                InputRealPtrsType pUrow = pUcol--;  /* access current row of U */
                
                {
                    int_T j = i;
                    while(j-- > 0) {
                        s += **pUrow * *xj--;
                        pUrow -= N;
                    }
                }
                
                if (unit_upper) {
                    *xj-- = **pb-- - s;
                } else {
                    *xj-- = (**pb-- - s) / **pUrow;
                }
            }
        }
        
    } else if (cB && !cU) {
        /* B is complex, U is real */
        
        InputRealPtrsType  pU = ssGetInputPortRealSignalPtrs(    S, INPORT_U)  + N2-1;
        InputPtrsType      pb = ssGetInputPortSignalPtrs(        S, INPORT_B)  + NP-1;
        creal_T           *x  = (creal_T *)ssGetOutputPortSignal(S, OUTPORT_X);
        int_T              i,k;
        
        for(k=P; k>0; k--) {
            InputRealPtrsType     pUcol = pU;
            for(i=0; i<N; i++) {
                creal_T          *xj    = x + k*N-1;
                creal_T           s     = {0.0, 0.0};
                InputRealPtrsType pUrow = pUcol--;  /* access current row of U */
                
                {
                    int_T j = i;
                    while(j-- > 0) {
                        s.re += **pUrow * xj->re;
                        s.im += **pUrow * (xj--)->im;
                        pUrow -= N;
                    }
                }
                
                if (unit_upper) {
                    const creal_T cb = *((creal_T *)(*pb--));
                    xj->re     = cb.re - s.re;
                    (xj--)->im = cb.im - s.im;
                } else {
                    const creal_T cb = *((creal_T *)(*pb--));
                    xj->re     = (cb.re - s.re) / **pUrow;
                    (xj--)->im = (cb.im - s.im) / **pUrow;
                }
            }
        }
        
    } else if (!cB && cU) {
        /* B is real, U is complex */
        
        InputPtrsType     pU = ssGetInputPortSignalPtrs(        S,INPORT_U)  + N2-1;
        InputRealPtrsType pb = ssGetInputPortRealSignalPtrs(    S,INPORT_B) + NP-1;
        creal_T          *x  = (creal_T *)ssGetOutputPortSignal(S,OUTPORT_X);
        int_T             i, k;
        
        for(k=P; k>0; k--) {
            InputPtrsType      pUcol = pU;
            for(i=0; i<N; i++) {
                creal_T       *xj    = x + k*N-1;
                creal_T        s     = {0.0, 0.0};
                InputPtrsType  pUrow = pUcol--;
                
                {
                    int_T j = i;
                    while(j-- > 0) {
                        /* Compute: s += U * xj, in complex */
                        const creal_T cU = *((creal_T *)(*pUrow));
                        pUrow -= N;
                        
                        s.re += CMULT_RE(cU, *xj);
                        s.im += CMULT_IM(cU, *xj);
                        xj--;
                    }
                }
                
                if (unit_upper) {
                    const real_T cb = **pb--;
                    xj->re     = cb - s.re;
                    (xj--)->im = cb - s.im;
                    
                } else {
                    /* Complex divide: *xj = cdiff / *cU */
                    const real_T  cb = **pb--;
                    const creal_T cU = *((creal_T *)(*pUrow));
                    creal_T       cdiff;
                    cdiff.re = cb - s.re;
                    cdiff.im = -s.im;
                    
                    CDIV(cdiff, cU, *xj);
                    xj--;
                }
            }
        }
        
    } else {
        /* Complex inputs: */
        
        InputPtrsType  pU = ssGetInputPortSignalPtrs(        S,INPORT_U)  + N2-1;
        InputPtrsType  pb = ssGetInputPortSignalPtrs(        S,INPORT_B)  + NP-1;
        creal_T       *x  = (creal_T *)ssGetOutputPortSignal(S,OUTPORT_X);
        int_T          i, k;
        
        for(k=P; k>0; k--) {
            InputPtrsType      pUcol = pU;
            for(i=0; i<N; i++) {
                creal_T       *xj    = x + k*N-1;
                creal_T        s     = {0.0, 0.0};
                InputPtrsType  pUrow = pUcol--;
                
                {
                    int_T j = i;
                    while(j-- > 0) {
                        /* Compute: s += L * xj, in complex */
                        const creal_T cU = *((creal_T *)(*pUrow));
                        pUrow -= N;
                        
                        s.re += CMULT_RE(cU, *xj);
                        s.im += CMULT_IM(cU, *xj);
                        xj--;
                    }
                }
                
                if (unit_upper) {
                    const creal_T cb = *((creal_T *)(*pb--));
                    xj->re     = cb.re - s.re;
                    (xj--)->im = cb.im - s.im;
                    
                } else {
                    /* Complex divide: *xj = cdiff / *cL */
                    const creal_T cb = *((creal_T *)(*pb--));
                    const creal_T cU = *((creal_T *)(*pUrow));
                    creal_T       cdiff;
                    cdiff.re = cb.re - s.re;
                    cdiff.im = cb.im - s.im;
                    
                    CDIV(cdiff, cU, *xj);
                    xj--;
                }
            }
        }
    }
}


static void mdlTerminate(SimStruct *S)
{
}


#ifdef MATLAB_MEX_FILE
#define MDL_SET_INPUT_PORT_WIDTH
static void mdlSetInputPortWidth(SimStruct *S, int_T port,
                                 int_T inputPortWidth)
{
    int_T NP, N2, N, P;
    
    if (port == INPORT_U) {
        N = (int_T)(sqrt((real_T)inputPortWidth));
        if (N*N == inputPortWidth) {
            ssSetInputPortWidth(S, port, inputPortWidth);
        } else {
            THROW_ERROR(S, "Invalid port widths.");
        }

        NP = ssGetInputPortWidth(S, INPORT_B);
        if (NP != DYNAMICALLY_SIZED) {
            P = (int_T)(((real_T)NP) / ((real_T)N));
            if (N*P != NP) {
                THROW_ERROR(S, "Invalid port widths.");
            }
        }
        if ((NP = ssGetOutputPortWidth(S, OUTPORT_X)) != DYNAMICALLY_SIZED) {
            P = (int_T)(((real_T)NP) / ((real_T)N));
            if (N*P != NP) {
                THROW_ERROR(S, "Invalid port widths.");
            }
        }

    } else if (port == INPORT_B) {
        ssSetInputPortWidth(S, port, inputPortWidth);

        NP = ssGetOutputPortWidth(S, OUTPORT_X);
        if (NP == DYNAMICALLY_SIZED) {
            ssSetOutputPortWidth(S, OUTPORT_X, inputPortWidth);
        } else {
            if (NP != inputPortWidth) {
                THROW_ERROR(S, "Invalid port widths.");
            }
        }
        N2 = ssGetInputPortWidth(S, INPORT_U);
        if (N2 != DYNAMICALLY_SIZED) {
            N = (int_T)(sqrt((real_T)N2));
            P = (int_T)(((real_T)inputPortWidth) / ((real_T)N));
            if (N*P != inputPortWidth) {
                THROW_ERROR(S, "Invalid port widths.");
            }
        }
    } else {
        THROW_ERROR(S, "Invalid port number for output port width propagation.");
    }
}

#define MDL_SET_OUTPUT_PORT_WIDTH
static void mdlSetOutputPortWidth(SimStruct *S, int_T port,
                                  int_T outputPortWidth)
{
    int_T NP, N2, N, P;
    
    if (port == OUTPORT_X) {
        ssSetOutputPortWidth(S, port, outputPortWidth);
        NP = ssGetInputPortWidth(S, INPORT_B);
        if (NP == DYNAMICALLY_SIZED) {
            ssSetInputPortWidth(S, INPORT_B, outputPortWidth);
        } else if (NP != outputPortWidth) {
            THROW_ERROR(S, "Invalid port widths.");
        }
        N2 = ssGetInputPortWidth(S, INPORT_U);
        if (N2 != DYNAMICALLY_SIZED) {
            N = (int_T)(sqrt((real_T)N2));
            P = (int_T)(((real_T)outputPortWidth) / ((real_T)N));
            if (N*P != outputPortWidth) {
                THROW_ERROR(S, "Invalid port widths.");
            }
        }
    } else {
        THROW_ERROR(S, "Invalid port number for output port width propagation.");
    }
}
#endif /* MATLAB_MEX_FILE */


#include "dsp_cplxhs21.c"

#include "dsp_trailer.c"

/* EOF: sdspbsub.c */
