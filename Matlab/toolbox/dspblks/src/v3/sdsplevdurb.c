/*
 *  SDSPLEVDURB - Levinson-Durbin solver for real correlation functions.
 *  DSP Blockset S-Function to solve a symmetric Toeplitz system of
 *  equations using the Levinson-Durbin recursion.  Input is a vector
 *  of autocorrelation coefficients, starting with lag 0 as the first
 *  element.  Recursion order is length(input)-1.
 *
 *  Copyright 1995-2002 The MathWorks, Inc.
 *  $Revision: 1.19 $ $Date: 2002/04/14 20:43:58 $
 */
#define S_FUNCTION_NAME sdsplevdurb
#define S_FUNCTION_LEVEL 2

#include "dsp_sim.h"

enum {ACOEF_IDX=0};
enum {INPORT_R=0};
typedef enum {fcnAandK=1, fcnA, fcnK} FcnType;

enum {FCN_TYPE_ARGC=0, OUT_TYPE_ARGC, NUM_ARGS};

#define FCN_TYPE_ARG (ssGetSFcnParam(S,FCN_TYPE_ARGC))
#define OUT_TYPE_ARG (ssGetSFcnParam(S,OUT_TYPE_ARGC))


#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S) {

    if(!IS_FLINT_IN_RANGE(FCN_TYPE_ARG,1,3)) {
        THROW_ERROR(S, "Function parameter must be a scalar in the range [1,3].");
    }
 
    if(!IS_FLINT_IN_RANGE(OUT_TYPE_ARG,0,1)) {
        THROW_ERROR(S, "Output type parameter must be a scalar (0 or 1).");
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

    /* Output type is not tunable because it changes the number of output ports. */
    ssSetSFcnParamNotTunable(S, OUT_TYPE_ARGC);
    ssSetSFcnParamNotTunable(S, FCN_TYPE_ARGC);

    /* Inputs: */
    if (!ssSetNumInputPorts(S, 1)) return;
    ssSetInputPortWidth(            S, INPORT_R, DYNAMICALLY_SIZED);
    ssSetInputPortDirectFeedThrough(S, INPORT_R, 1);
    ssSetInputPortComplexSignal(    S, INPORT_R, COMPLEX_INHERITED);
    ssSetInputPortReusable(        S, INPORT_R, 1);
    ssSetInputPortOverWritable(     S, INPORT_R, 0);  /* revisits inputs multiple times */

    /* Outputs: */
    {
        const FcnType ftype = (FcnType)((int_T)mxGetPr(FCN_TYPE_ARG)[0]);

        if (ftype == fcnAandK) {
            /* 2 outputs (both polynomial and reflection coefficients:
             * Set the 2nd port properties now:
             */
            if (!ssSetNumOutputPorts(S,2)) return;
            ssSetOutputPortWidth(        S, 1, DYNAMICALLY_SIZED);
            ssSetOutputPortComplexSignal(S, 1, COMPLEX_INHERITED); 
            ssSetOutputPortReusable(    S, 1, 1);

        } else {
            /* 1 Output (either polynomial or reflection coefficients) */
            if (!ssSetNumOutputPorts(S,1)) return;
        }

        /* Set the first port (same for any mode) */
        ssSetOutputPortWidth(        S, 0, DYNAMICALLY_SIZED);
        ssSetOutputPortComplexSignal(S, 0, COMPLEX_INHERITED); 
        ssSetOutputPortReusable(    S, 0, 1);
    }

    if(!ssSetNumDWork(S, DYNAMICALLY_SIZED)) return;

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
    const boolean_T c0    = (boolean_T)(ssGetInputPortComplexSignal(S,INPORT_R) == COMPLEX_YES);
    const FcnType   ftype = (FcnType)((int_T)mxGetPr(FCN_TYPE_ARG)[0]);
    const boolean_T otype = (boolean_T)mxGetPr(OUT_TYPE_ARG)[0];

    if (!c0) {
        /* 
         * Real input:
         */
        InputRealPtrsType  uptr = ssGetInputPortRealSignalPtrs(S,INPORT_R);
        const int_T        N    = ssGetInputPortWidth(S,INPORT_R);
        real_T		  *y0   = ssGetOutputPortRealSignal(S,0);
         int_T              i;

        /* Special case when input starts with a 0: 
         * If option is selected then 
         * the block will output zeros instead of computing NaN's
         * First polynomial coefficient is always 1.
         */
        if (otype && (*uptr[0] == 0.0)) {

            /* 1st output port */
            i = (ftype == fcnK) ? N-1 : N;
            while (i-- > 0) {
                *y0++ = 0.0;
            }
            if (ftype != fcnK) {
                y0 = ssGetOutputPortRealSignal(S,0);
                y0[0] = 1.0;
            }

            /* 2nd output port */
            if (ftype == fcnAandK) {
                real_T *y1 = ssGetOutputPortRealSignal(S,1);
                
                i = N-1;
                while (i-- > 0) {
                    *y1++ = 0.0;
                }
            }

        } else {
            real_T *a = (ftype == fcnK) ? (real_T *)ssGetDWork(S,ACOEF_IDX) : y0;
            real_T  E = *uptr[0];

            for(i=1; i<N; i++) {
                int_T  j;
                real_T ki = *uptr[i];

                /* Update reflection coefficient: */
                for (j=1; j<i; j++) {
                    ki += a[j] * *uptr[i-j];
                }
                ki /= -E;
                E *= (1 - ki*ki);

                /* Update polynomial: */
                for (j=1; j<=(i-1)/2; j++) {
                    real_T t = a[j];
                    a[j]   += ki * a[i-j];
                    a[i-j] += ki * t;
                }

                if (i%2 == 0) {
                    a[i/2] *= 1+ki;
                }

                /* Record reflection coefficient */
                a[i] = ki;  

                if (ftype == fcnAandK) {
                    real_T	*y1   = ssGetOutputPortRealSignal(S,1);
                    y1[i-1] = ki;  
                }            

                if (ftype == fcnK) {
                    y0[i-1] = ki;
                }

            }
            a[0] = 1.0;
        }

   } else {
        /* 
         * Complex
         */
        InputPtrsType  uptr = ssGetInputPortSignalPtrs(S,INPORT_R);
        const int_T    N    = ssGetInputPortWidth(S,INPORT_R);
        creal_T	      *y0   = (creal_T *)ssGetOutputPortSignal(S,0); /* A */
        creal_T       *u    = (creal_T *)uptr[0];
        int_T          i;

        /* Special case when input starts with a 0: 
         * If option is selected then 
         * the block will output zeros instead of computing NaN's
         * First polynomial coefficient is always 1.
         */
        if ((otype) && (u->re == 0.0) && (u->im == 0.0)) {

            /* 1st output port */
            i = (ftype == fcnK) ? N-1 : N;
            while (i-- > 0) {
                y0->re     = 0.0;
                (y0++)->im = 0.0;
            }
            if (ftype != fcnK) {
                y0     = (creal_T *)ssGetOutputPortSignal(S,0);
                y0->re = 1.0;
            }

            /* 2nd output port */
            if (ftype == fcnAandK) {
                creal_T *y1 = (creal_T *)ssGetOutputPortSignal(S,1);
                
                i = N-1;
                while (i-- > 0) {
                    y1->re     = 0.0;
                    (y1++)->im = 0.0;
                }
            }

        } else {
            creal_T *a = (ftype == fcnK) ? (creal_T *)ssGetDWork(S,ACOEF_IDX) : y0;
            real_T   E = u->re;  /* Only use the real part of the 1st element*/

            for(i=1; i<N; i++) {
                const creal_T *ui = (creal_T *)uptr[i];
                creal_T        k  = *ui;
                int_T          j;

                for (j=1; j<i; j++) {
                    /* k = y * r[reverse order] */
                    const creal_T *ui = (creal_T *)uptr[i-j];
                    creal_T        u = *ui;

                    k.re += CMULT_RE(u,a[j]);
                    k.im += CMULT_IM(u,a[j]);
                }

                k.re /= -E;
                k.im /= -E;
                E *= (1 - CMAGSQ(k));

                /* Update polynomial: */
                for (j=1; j<=(i-1)/2; j++) {
                    creal_T t = a[j];

                    /*
                     * ynew = yold + conj(yold[reverse order]) * k 
                     */
                    a[j].re += CMULT_XCONJ_RE(a[i-j], k);
                    a[j].im += CMULT_XCONJ_IM(a[i-j], k);

                    a[i-j].re += CMULT_XCONJ_RE(t,k);
                    a[i-j].im += CMULT_XCONJ_IM(t,k);
                }

                if (i%2 == 0) {
                    creal_T t   = a[i/2];

                    /* To compare to the real input case:
                     * y *= 1 + ki    <==>   y += k * conj(y)
                     *  (Real)                (Complex)
                     */
                    a[i/2].re += CMULT_XCONJ_RE(t,k);
                    a[i/2].im += CMULT_XCONJ_IM(t,k);
                } 

                /* Record reflection coefficient */
                a[i] = k;

                if (ftype == fcnAandK) {
                    creal_T *y1 = (creal_T *)ssGetOutputPortSignal(S,1); 

                    y1[i-1] = k;  
                }            

                if (ftype == fcnK) {
                    y0[i-1] = k;
                }
            }
            a[0].re = 1.0;
            a[0].im = 0.0;
        }
    }
}

static void mdlTerminate(SimStruct *S)
{
}


#if defined(MATLAB_MEX_FILE)
# define MDL_SET_INPUT_PORT_WIDTH
 static void mdlSetInputPortWidth(SimStruct *S, int_T port,
                                    int_T inputPortWidth)
{
    const FcnType ftype = (FcnType)((int_T)mxGetPr(FCN_TYPE_ARG)[0]);
    const boolean_T conn = (boolean_T)ssGetInputPortConnected(S,0);

    if (port != 0) {
        THROW_ERROR(S, "Invalid input port number for input width propagation.");
    }

    ssSetInputPortWidth(S,port,inputPortWidth);

    if (conn) {
        if ( ((ftype != fcnA) && (inputPortWidth <= 1))  ||
             ((ftype == fcnA) && (inputPortWidth < 1)) ) {
             THROW_ERROR(S, "Cannot output reflection coefficients when input is a scalar. "
                               "Set output mode to 'A' instead.");
        }

    }

    switch (ftype) {
        case fcnAandK:
        {
            ssSetOutputPortWidth(S,0,inputPortWidth);
            ssSetOutputPortWidth(S,1,MAX(inputPortWidth-1,1));
        }
        break;

        case fcnA:
        {
            ssSetOutputPortWidth(S,0,inputPortWidth);
        }
        break;

        case fcnK:
        {
            ssSetOutputPortWidth(S,0,MAX(inputPortWidth-1,1));
        }
        break;
    }
}


# define MDL_SET_OUTPUT_PORT_WIDTH
static void mdlSetOutputPortWidth(SimStruct *S, int_T port,
                                     int_T outputPortWidth)
{
    const FcnType ftype = (FcnType)((int_T)mxGetPr(FCN_TYPE_ARG)[0]);
    const boolean_T conn = (boolean_T)ssGetInputPortConnected(S,0);

    if ((port != 0) && (ftype == fcnAandK)) {
        THROW_ERROR(S, "Invalid input port number for output width propagation.");
    }


    if (conn) {
        if ( ((ftype != fcnA) && (outputPortWidth <= 1))  ||
             ((ftype == fcnA) && (outputPortWidth < 1)) ) {
            THROW_ERROR(S, "Cannot output reflection coefficients when input is a scalar. "
                               "Set output mode to 'A' instead.");
        }
    } 

    ssSetOutputPortWidth(S,port,outputPortWidth);

    switch (ftype) {
        case fcnAandK:
        {
            if (port == 0) {
                ssSetOutputPortWidth(S,1, MAX(outputPortWidth-1,1));
                ssSetInputPortWidth(S,INPORT_R,outputPortWidth);

            } else {
                ssSetOutputPortWidth(S,1,outputPortWidth+1);
                ssSetInputPortWidth(S,INPORT_R,outputPortWidth+1);
            }
        }
        break;

        case fcnA:
        {
            ssSetInputPortWidth(S,INPORT_R,outputPortWidth);
        }
        break;

        case fcnK:
        {
            ssSetInputPortWidth(S,INPORT_R,outputPortWidth+1);
        }
        break;
    }
}


#define MDL_SET_INPUT_PORT_COMPLEX_SIGNAL
static void mdlSetInputPortComplexSignal(SimStruct *S, int_T portIdx,
                                         CSignal_T      iPortComplexSignal)
{
    const FcnType ftype = (FcnType)((int_T)mxGetPr(FCN_TYPE_ARG)[0]);

    ssSetInputPortComplexSignal(S, portIdx, iPortComplexSignal);  
    ssSetOutputPortComplexSignal(S, 0, iPortComplexSignal);  

    if (ftype == fcnAandK) {
        ssSetOutputPortWidth(S,1,iPortComplexSignal);
    } 
}


#define MDL_SET_OUTPUT_PORT_COMPLEX_SIGNAL
static void mdlSetOutputPortComplexSignal(SimStruct *S, int_T portIdx, 
                                          CSignal_T oPortComplexSignal)
{
    const FcnType ftype = (FcnType)((int_T)mxGetPr(FCN_TYPE_ARG)[0]);

    if ((portIdx == 1) && (ftype != fcnAandK)) {
        THROW_ERROR(S, "Invalid input port number for output complex propagation.");
    }

    ssSetOutputPortComplexSignal(S,portIdx,oPortComplexSignal);
    ssSetInputPortComplexSignal(S,INPORT_R,oPortComplexSignal);

    if (ftype == fcnAandK) {
        if (portIdx == 0) {
            ssSetOutputPortComplexSignal(S,1,oPortComplexSignal);
        } else {
            ssSetInputPortComplexSignal(S,INPORT_R,oPortComplexSignal);
        }
    }
}


#define MDL_SET_WORK_WIDTHS
static void mdlSetWorkWidths(SimStruct *S)
{
    const boolean_T c0      = (ssGetInputPortComplexSignal(S,INPORT_R) == COMPLEX_YES);
    const FcnType   ftype   = (FcnType)((int_T)mxGetPr(FCN_TYPE_ARG)[0]);
    const int_T     N       = ssGetInputPortWidth(S,INPORT_R);
    int             width   = (ftype == fcnK) ? N : 0;
    int             nDWorks = (width > 0)? 1 : 0;
 
    if(!ssSetNumDWork(S, nDWorks)) return;
    if(nDWorks > 0){
        ssSetDWorkWidth(        S, ACOEF_IDX, width);
        ssSetDWorkComplexSignal(S, ACOEF_IDX, (c0) ? COMPLEX_YES : COMPLEX_NO);
    }
}

#endif


#ifdef	MATLAB_MEX_FILE
#include "simulink.c"
#else
#include "cg_sfun.h"
#endif

/* [EOF] sdsplevdurb.c */
