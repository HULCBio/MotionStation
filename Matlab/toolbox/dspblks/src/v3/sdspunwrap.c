/*
 * SDSPUNWRAP Unwrap a vector of radian phase angles.
 *
 * The Unwrap block unwraps radian phases in the input 
 * vector by replacing absolute jumps greater than the 
 * specified Tolerance with their 2 complement. 
 *
 *   
 *  Copyright 1995-2002 The MathWorks, Inc.
 *  $Revision: 1.13 $  $Date: 2002/04/14 20:43:09 $
 */
#define S_FUNCTION_NAME sdspunwrap
#define S_FUNCTION_LEVEL 2

#include "dsp_sim.h"

enum {INPORT=0};
enum {OUTPORT=0};

enum {CUTOFF_IDX=0, NUM_ARGS};
#define CUTOFF (ssGetSFcnParam(S,CUTOFF_IDX))

#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S) 
{
    static char *msg;
    msg = NULL;

    if ((mxGetNumberOfElements(CUTOFF) != 1 ) || mxIsComplex(CUTOFF) || !mxIsNumeric(CUTOFF)) {
        msg = "Tolerance must be a scalar.";
        goto FCN_EXIT;
    }

FCN_EXIT:
    ssSetErrorStatus(S,msg);
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
    
    /* Cutoff is not tunable in RTW generated code. */
    if ((ssGetSimMode(S) == SS_SIMMODE_EXTERNAL) || 
        (ssGetSimMode(S) == SS_SIMMODE_RTWGEN)) {    
        
        ssSetSFcnParamNotTunable(S, CUTOFF_IDX);
    }

    /* Inputs: */
    if (!ssSetNumInputPorts(S, 1)) return;
    
    ssSetInputPortWidth(            S, INPORT, DYNAMICALLY_SIZED);  
    ssSetInputPortComplexSignal(    S, INPORT, COMPLEX_NO);
    ssSetInputPortDirectFeedThrough(S, INPORT, 1);
    ssSetInputPortReusable(        S, INPORT, 1);
    ssSetInputPortOverWritable(     S, INPORT, 1);
    
    /* Outputs: */
    if (!ssSetNumOutputPorts(S,1)) return;
    
    ssSetOutputPortWidth(        S, OUTPORT, DYNAMICALLY_SIZED);
    ssSetOutputPortComplexSignal(S, OUTPORT, COMPLEX_NO);
    ssSetOutputPortReusable(    S, OUTPORT, 1);

    ssSetNumSampleTimes(S, 1);
    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE | 
                 SS_OPTION_USE_TLC_WITH_ACCELERATOR);
}


static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);
}


/*  Equivalent MATLAB code for unwrap:
 *
 *   function q = unwrap(p,cutoff)
 *
 *   if(nargin<2)
 *     cutoff = pi;
 *   end
 *
 *   pmin = min(p);  
 *   p = rem(p - pmin, 2 .* pi) + pmin;       % Phases modulo 2*pi.
 *
 *   if length(p) > 1
 *     b = [p(1); diff(p)];                   % Differentiate phases.
 *   else
 *     b = p(1);
 *   end
 *   c = -(b > cutoff); d = (b < -cutoff);    % Locations of jumps.
 *   e = (c + d) .* 2 .* pi;                  % Array of 2*pi jumps.
 *   f = cumsum(e);                           % Integrate to get corrections.
 * 
 *   q = p + f;                               % q is the output   
 *
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
    static const real_T two_pi  = 6.283185307179586476925286766559005768394;  /* from fft.c */

    const boolean_T inplace = (boolean_T)(ssGetInputPortBufferDstPort(S, INPORT) == OUTPORT);
    const int_T     inwidth = ssGetInputPortWidth(S, INPORT);
    const real_T    cutoff  = fabs(mxGetPr(CUTOFF)[0]);  /* take absolute value of cutoff */

    if (inplace) {
        /* Contiguous, in-place: */

        real_T  *y = ssGetOutputPortRealSignal(S,OUTPORT);
        int_T    w;
        real_T   umin;

        /* Find the minimum */
        umin = *y++;
        for(w=inwidth; --w > 0; ) {
            real_T val = *y++;
            if (val < umin) {
                umin = val;
            }
        }

        {
            real_T f = 0.0;   /* clear cumsum       */
            real_T a = 0.0;   /* 1st previous value */

            y -= inwidth;          /* reset input pointer */
            for(w=inwidth; w-- > 0; ) { 
                /* Implement this, without the aprev variable:
                 *   a     = (new value);
                 *   b     = a - aprev;
                 *   aprev = a;
                 */
                real_T b = -a;                      /* use old a value */
                a = fmod(*y - umin, two_pi) + umin; /* get new a value */
                b += a;                             /* finish with b   */

                if (b > cutoff) {
                    f -= two_pi;
                } else if (-b > cutoff) {
                    f += two_pi;
                }
                *y++ = a + f;
            }  
        }
        

    } else {
        /* Discontiguous: */

        real_T           *y       = ssGetOutputPortRealSignal(S,OUTPORT);
        InputRealPtrsType u       = ssGetInputPortRealSignalPtrs(S,INPORT);        
        int_T             w;
        real_T            umin;

        /* Find the minimum */
        umin = **(u++);
        for(w=inwidth; --w >0; ) {
            real_T val = **(u++);
            if (val < umin) {
                umin = val;
            }
        }

        {
            real_T f = 0.0;   /* clear cumsum       */
            real_T a = 0.0;   /* 1st previous value */

            u -= inwidth;          /* reset input pointer */
            w = inwidth;           /* reset loop counter  */
            while(w-- > 0) { 
                /* Implement this, without the aprev variable:
                 *   a     = (new value);
                 *   b     = a - aprev;
                 *   aprev = a;
                 */
                real_T b = -a;                           /* use old a value */
                a = fmod(**(u++) - umin, two_pi) + umin; /* get new a value */
                b += a;                                  /* finish with b   */

                if (b > cutoff) {
                    f -= two_pi;
                } else if (-b > cutoff) {
                    f += two_pi;
                }
                *y++ = a + f;
            }  
        }
    }
}


static void mdlTerminate(SimStruct *S)
{
}


#if defined(MATLAB_MEX_FILE)
#define MDL_SET_INPUT_PORT_WIDTH
static void mdlSetInputPortWidth(SimStruct *S, int_T port, int_T inputPortWidth)
{
    int_T outputPortWidth = ssGetOutputPortWidth(S,OUTPORT);
    
    ssSetInputPortWidth(S, port, inputPortWidth);
    
    if (outputPortWidth == DYNAMICALLY_SIZED) {
        ssSetOutputPortWidth(S, port, inputPortWidth);
    } else {
        /* Verify that input port width matches output port width */
        if (inputPortWidth != outputPortWidth) {
            ssSetErrorStatus(S, "Input port width does not match output port width.");
        }
    }
    
}

# define MDL_SET_OUTPUT_PORT_WIDTH
static void mdlSetOutputPortWidth(SimStruct *S, int_T port, int_T outputPortWidth)
{
    int_T inputPortWidth = ssGetInputPortWidth(S, INPORT);
    
    ssSetOutputPortWidth(S,port,outputPortWidth);
    
    if (inputPortWidth == DYNAMICALLY_SIZED) {                       
        ssSetInputPortWidth(S,port,outputPortWidth);  
    } else {
        /* Input port width must match the output width! */
        if (inputPortWidth != outputPortWidth) {
            ssSetErrorStatus(S, "Output port width does not match input port width.");
        }
        
    }
}
#endif


#ifdef	MATLAB_MEX_FILE   
#include "simulink.c"      
#else
#include "cg_sfun.h"       
#endif
