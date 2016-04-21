/*
* File: sdspfsub.c
*
* Abstract:
*      S-function for solving Lx=b by forward substitution.
*      L is a lower (or unit lower) triangular full matrix.
*      The entries in the upper triangle are ignored.
*
* Copyright 1995-2002 The MathWorks, Inc.
* $Revision: 1.15 $ $Date: 2002/04/14 20:43:52 $
*/
#define S_FUNCTION_NAME  sdspfsub
#define S_FUNCTION_LEVEL 2

#include "dsp_sim.h"

enum {INPORT_L=0, INPORT_B, NUM_INPORTS};
enum {OUTPORT_X=0, NUM_OUTPORTS};
enum {UNIT_ARGC=0, NUM_PARAMS};

#define UNIT_ARG (ssGetSFcnParam(S,UNIT_ARGC))


#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S) {

    if (!IS_FLINT_IN_RANGE(UNIT_ARG,0,1)) {
        THROW_ERROR(S, "Unit lower override option must be 0 or 1.");
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
    
    /* Define ports: */
    if (!ssSetNumInputPorts(S, NUM_INPORTS)) return;
    
    ssSetInputPortWidth(            S, INPORT_L, DYNAMICALLY_SIZED);
    ssSetInputPortDirectFeedThrough(S, INPORT_L, 1);
    ssSetInputPortComplexSignal(    S, INPORT_L, COMPLEX_INHERITED);
    ssSetInputPortReusable(        S, INPORT_L, 1);
    
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
/* Solve LX = B
*   Inputs: L, B
*   Output: X
    */
    const boolean_T cB         = (boolean_T)(ssGetInputPortComplexSignal(S,INPORT_B) == COMPLEX_YES);
    const boolean_T cL         = (boolean_T)(ssGetInputPortComplexSignal(S,INPORT_L) == COMPLEX_YES);
    const int_T     N2         = ssGetInputPortWidth(S,INPORT_L);
    const int_T     N          = (int_T)sqrt((real_T)N2);
    const int_T     NP         = ssGetInputPortWidth(S,INPORT_B);
    const int_T     P          = (int_T)(((real_T)NP) / ((real_T)N)); /* number of right hand sides in B */
    const boolean_T unit_lower = (boolean_T)(mxGetPr(UNIT_ARG)[0] == 1.0);
    
    if (!cB && !cL) {
        /* Real inputs: */
        
        InputRealPtrsType  pb = ssGetInputPortRealSignalPtrs(S,INPORT_B);
        InputRealPtrsType  pL = ssGetInputPortRealSignalPtrs(S,INPORT_L);
        real_T            *x  = (real_T *)(ssGetOutputPortSignal(S, OUTPORT_X));
        int_T              i, k;
        
        for(k=0; k<P; k++) {
            InputRealPtrsType  pLcol    = pL;
            for(i=0; i<N; i++) {
                real_T           *xj    = x + k*N;
                real_T            s     = 0.0;
                InputRealPtrsType pLrow = pLcol++;  /* access current row of L */
                
                {
                    int_T j = i;
                    while(j-- > 0) {
                        s += **pLrow * *xj++;
                        pLrow += N;
                    }
                }
                
                if (unit_lower) {
                    *xj++ = **pb++ - s;
                } else {
                    *xj++ = (**pb++ - s) / **pLrow;
                }
            }
        }
        
    } else if (cB && !cL) {
        /* B is complex, L is real */
        
        InputRealPtrsType  pL = ssGetInputPortRealSignalPtrs(S,INPORT_L);
        InputPtrsType      pb = ssGetInputPortSignalPtrs(    S,INPORT_B);
        creal_T           *x  = (creal_T *)ssGetOutputPortSignal(S,OUTPORT_X);
        int_T              i, k;
        
        for(k=0; k<P; k++) {
            InputRealPtrsType  pLcol    = pL;
            for(i=0; i<N; i++) {
                creal_T          *xj    = x + k*N;
                creal_T           s     = {0.0, 0.0};
                InputRealPtrsType pLrow = pLcol++;  /* access current row of L */
                
                {
                    int_T j = i;
                    while(j-- > 0) {
                        s.re += **pLrow * xj->re;
                        s.im += **pLrow * (xj++)->im;
                        pLrow += N;
                    }
                }
                
                if (unit_lower) {
                    const creal_T cb = *((creal_T *)(*pb++));
                    xj->re     = cb.re - s.re;
                    (xj++)->im = cb.im - s.im;
                } else {
                    const creal_T cb = *((creal_T *)(*pb++));
                    xj->re     = (cb.re - s.re) / **pLrow;
                    (xj++)->im = (cb.im - s.im) / **pLrow;
                }
            }
        }
        
    } else if (!cB && cL) {
        /* B is real, L is complex */
        
        InputPtrsType     pL = ssGetInputPortSignalPtrs(    S,INPORT_L);
        InputRealPtrsType pb = ssGetInputPortRealSignalPtrs(S,INPORT_B);
        creal_T          *x  = (creal_T *)ssGetOutputPortSignal(S,OUTPORT_X);
        int_T             i, k;
        
        for(k=0; k<P; k++) {
            InputPtrsType     pLcol = pL;
            for(i=0; i<N; i++) {
                creal_T       *xj    = x + k*N;
                creal_T        s     = {0.0, 0.0};
                InputPtrsType  pLrow = pLcol++;
                
                {
                    int_T j = i;
                    while(j-- > 0) {
                        /* Compute: s += L * xj, in complex */
                        const creal_T cL = *((creal_T *)(*pLrow));
                        pLrow += N;
                        
                        s.re += CMULT_RE(cL, *xj);
                        s.im += CMULT_IM(cL, *xj);
                        xj++;
                    }
                }
                
                if (unit_lower) {
                    const real_T cb = **pb++;
                    xj->re     = cb - s.re;
                    (xj++)->im = -s.im;
                    
                } else {
                    /* Complex divide: *xj = cdiff / *cL */
                    const real_T  cb = **pb++;
                    const creal_T cL = *((creal_T *)(*pLrow));
                    creal_T        cdiff;
                    cdiff.re = cb - s.re;
                    cdiff.im = -s.im;
                    
                    CDIV(cdiff, cL, *xj);
                    xj++;
                }
            }
        }
        
    } else {
        /* Complex inputs: */
        
        InputPtrsType  pL = ssGetInputPortSignalPtrs(S,INPORT_L);
        InputPtrsType  pb = ssGetInputPortSignalPtrs(S,INPORT_B);
        creal_T       *x  = (creal_T *)ssGetOutputPortSignal(S,OUTPORT_X);
        int_T          i, k;
        
        for (k=0; k<P; k++) {
            InputPtrsType  pLcol = pL;
            for(i=0; i<N; i++) {
                creal_T       *xj    = x + k*N;
                creal_T        s     = {0.0, 0.0};
                InputPtrsType  pLrow = pLcol++;
                
                {
                    int_T j = i;
                    while(j-- > 0) {
                        /* Compute: s += L * xj, in complex */
                        const creal_T cL = *((creal_T *)(*pLrow));
                        pLrow += N;
                        
                        s.re += CMULT_RE(cL, *xj);
                        s.im += CMULT_IM(cL, *xj);
                        xj++;
                    }
                }
                
                if (unit_lower) {
                    const creal_T cb = *((creal_T *)(*pb++));
                    xj->re     = cb.re - s.re;
                    (xj++)->im = cb.im - s.im;
                    
                } else {
                    /* Complex divide: *xj = cdiff / *cL */
                    const creal_T cb = *((creal_T *)(*pb++));
                    const creal_T cL = *((creal_T *)(*pLrow));
                    creal_T        cdiff;
                    cdiff.re = cb.re - s.re;
                    cdiff.im = cb.im - s.im;
                    
                    CDIV(cdiff, cL, *xj);
                    xj++;
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
    
    if (port == INPORT_L) {
        N = (int_T)(sqrt((real_T)inputPortWidth));
        if (N*N == inputPortWidth) {
            ssSetInputPortWidth(S, port, inputPortWidth);
        } else {
            THROW_ERROR(S, "Invalid port widths.");
        }
        if ((NP = ssGetInputPortWidth(S, INPORT_B)) != DYNAMICALLY_SIZED) {
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
        if ((NP = ssGetOutputPortWidth(S, OUTPORT_X)) == DYNAMICALLY_SIZED) {
            ssSetOutputPortWidth(S, OUTPORT_X, inputPortWidth);
        } else {
            if (NP != inputPortWidth) {
                THROW_ERROR(S, "Invalid port widths.");
            }
        }
        if ((N2 = ssGetInputPortWidth(S, INPORT_L)) != DYNAMICALLY_SIZED) {
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
        if ((NP = ssGetInputPortWidth(S, INPORT_B)) == DYNAMICALLY_SIZED) {
            ssSetInputPortWidth(S, INPORT_B, outputPortWidth);
        } else if (NP != outputPortWidth) {
            THROW_ERROR(S, "Invalid port widths.");
        }
        if ((N2 = ssGetInputPortWidth(S, INPORT_L)) != DYNAMICALLY_SIZED) {
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

/* EOF: sdspfsub.c */
