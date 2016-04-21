/*
 * SDSPMTOEP   A SIMULINK Toeplix matrix constructor.
 *
 * Generate a Toeplitz matrix having input Col as its 
 * first column and Row as its first row with the column 
 * winning the diagonal conflict  If Symmetric is checked, 
 * a symmetric (or Hermitian) Toeplitz matrix is generated 
 * with Row as its first row.
 * 
 * y = toeplitz(r)      % equivalent MATLAB code
 * y = toeplitz(c,r)    
 *
 *   
 *  Copyright 1995-2002 The MathWorks, Inc.
 *  $Revision: 1.14 $  $Date: 2002/04/14 20:42:23 $
 */

#define S_FUNCTION_NAME sdspmtoep
#define S_FUNCTION_LEVEL 2

#include "dsp_sim.h"

enum {INPORT_R=0, INPORT_C};
enum {OUTPORT_Y=0};
enum {SYMMETRIC_IDX=0, NUM_ARGS};

#define SYMMETRIC_ARG (ssGetSFcnParam(S,SYMMETRIC_IDX))


#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S) {
    static char *msg;
    msg = NULL;
    
    if (mxGetNumberOfElements(SYMMETRIC_ARG) != 1)  {
        msg  = "The SYMMETRIC parameter must be a scalar.";
        goto FCN_EXIT;
    }
    
    if(!mxIsDouble(SYMMETRIC_ARG)) {
        msg  = "The SYMMETRIC parameter must be a numeric scalar.";
        goto FCN_EXIT;
    }
    
FCN_EXIT:
    ssSetErrorStatus(S,msg);
}
#endif


static void mdlInitializeSizes(SimStruct *S)
{
    boolean_T symmetric;
    
    ssSetNumSFcnParams(S, NUM_ARGS);
    
#if defined(MATLAB_MEX_FILE)
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) return;
    mdlCheckParameters(S);
    if (ssGetErrorStatus(S) != NULL) return;
#endif
    
    symmetric = (boolean_T)(mxGetPr(SYMMETRIC_ARG)[0] != 0.0);
    
    if(symmetric) {
        
        /* One Input: */
        if (!ssSetNumInputPorts(S, 1)) return;	
        
        ssSetInputPortWidth(            S, INPORT_R, DYNAMICALLY_SIZED);  
        ssSetInputPortDirectFeedThrough(S, INPORT_R, 1);
        ssSetInputPortComplexSignal(    S, INPORT_R, COMPLEX_INHERITED);
        ssSetInputPortReusable(        S, INPORT_R, 1);
        ssSetInputPortOverWritable(     S, INPORT_R, 0);
        
    } else {
        
        /* Two Inputs: */
        if (!ssSetNumInputPorts(S, 2)) return;
        
        ssSetInputPortWidth(            S, INPORT_R, DYNAMICALLY_SIZED);  
        ssSetInputPortDirectFeedThrough(S, INPORT_R, 1);
        ssSetInputPortComplexSignal(    S, INPORT_R, COMPLEX_INHERITED);
        ssSetInputPortReusable(        S, INPORT_R, 1);
        ssSetInputPortOverWritable(     S, INPORT_R, 0);
        
        ssSetInputPortWidth(            S, INPORT_C, DYNAMICALLY_SIZED);  
        ssSetInputPortDirectFeedThrough(S, INPORT_C, 1);
        ssSetInputPortComplexSignal(    S, INPORT_C, COMPLEX_INHERITED);
        ssSetInputPortReusable(        S, INPORT_C, 1);
        ssSetInputPortOverWritable(     S, INPORT_C, 0);
    }	
    
    
    /* Outputs: */
    if (!ssSetNumOutputPorts(S,1)) return;
    
    ssSetOutputPortWidth(        S, OUTPORT_Y, DYNAMICALLY_SIZED);      
    ssSetOutputPortComplexSignal(S, OUTPORT_Y, COMPLEX_INHERITED);
    ssSetOutputPortReusable(    S, OUTPORT_Y, 1);
    
    ssSetSFcnParamNotTunable(S, SYMMETRIC_IDX);
    
    ssSetNumSampleTimes(S, 1);
    ssSetOptions(       S, SS_OPTION_EXCEPTION_FREE_CODE |
                        SS_OPTION_USE_TLC_WITH_ACCELERATOR);
}


static void mdlInitializeSampleTimes(SimStruct *S)
{
/*
* Blocks that are continuous in nature have a single
* sample time of 0.0
    */
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);
}


static void mdlOutputs(SimStruct *S, int_T tid)
{
    const boolean_T symmetric = (boolean_T)(mxGetPr(SYMMETRIC_ARG)[0] == 1);
    const boolean_T cR        = (boolean_T)(ssGetInputPortComplexSignal(S,INPORT_R) == COMPLEX_YES);
    const int_T     LengthR   = ssGetInputPortWidth(S, INPORT_R);
    int_T i;
    
    if(symmetric) {
        
        if(!cR) {
            /* Real */
            
            InputRealPtrsType  row = ssGetInputPortRealSignalPtrs(S,INPORT_R);
            real_T            *y   = ssGetOutputPortRealSignal(S,OUTPORT_Y);
            
            for(i=0; i<LengthR; i++) {
                InputRealPtrsType  u1  = row++;
                int_T              idx = i;
                int_T              j   = LengthR;
                while(j-- > 0) {
                    if ((--idx) < 0) {
                        *y++ = **u1++;
                    } else {
                        *y++ = **u1--;
                    }
                }
            }
            
        } else {
            /* Complex */
            
            InputPtrsType  row = ssGetInputPortSignalPtrs(S,INPORT_R);
            creal_T       *y   = ssGetOutputPortSignal(S,OUTPORT_Y);
            
            for(i=0; i<LengthR; i++, row++) {
                InputPtrsType u1  = row;
                int_T         idx = i;
                int_T         j;
                
                for(j=0; j<LengthR; j++) {
                    creal_T u1c;
                    
                    if ((--idx) < 0) {
                        u1c = *((creal_T *)(*u1++));
                    } else {
                        u1c = *((creal_T *)(*u1--));
                    }
                    
                    y->re     = u1c.re;
                    (y++)->im = (i<j) ? -u1c.im : u1c.im;   /* Hermitian */
                }
            }
        }
    } else {
        
        /* ASYMMETRIC */
        const boolean_T cC      = (boolean_T)(ssGetInputPortComplexSignal(S,INPORT_C) == COMPLEX_YES);
        const int_T     LengthC = ssGetInputPortWidth(S, INPORT_C);
        
        if (!cC && !cR) {
            /* Real and Real */
            InputRealPtrsType  row = ssGetInputPortRealSignalPtrs(S,INPORT_R);
            InputRealPtrsType  col = ssGetInputPortRealSignalPtrs(S,INPORT_C);
            real_T            *y   = ssGetOutputPortRealSignal(S,OUTPORT_Y);
            
            /* row only effects the upper triangle of the matrix 
            * col wins the diagonal conflict if row(1) ~= col(1)
            * so we can ignore the first element of row 
            */
            
            for(i=0; i<LengthC; i++) {
                InputRealPtrsType  c1  = col++;/* reset to start at next element of col */
                InputRealPtrsType  r1  = row;  /* reset to start row */
                int_T              j;
                
                for(j=0; j<LengthR; j++) {
                    *y++ = (i <= j) ? **r1++ : **c1--;
                }
            }
        } else if (!cC && cR) {
            /* Complex and Real */
            InputPtrsType      row  = ssGetInputPortSignalPtrs(S,INPORT_R);
            InputRealPtrsType  col  = ssGetInputPortRealSignalPtrs(S,INPORT_C);
            creal_T           *y    = ssGetOutputPortSignal(S,OUTPORT_Y);
            
            /* row only effects the upper triangle of the matrix 
            * col wins the diagonal conflict if row(1) ~= col(1)
            * so we can ignore the first element of row 
            */
            
            for(i=0; i<LengthC; i++) {
                InputRealPtrsType  c1  = col++;/* reset to start at next element of col */
                InputPtrsType      r1  = row;  /* reset to start of row */
                int_T              j;
                
                for(j=0; j<LengthR; j++) {
                    
                    if(i<=j) {
                        *y++ = *((creal_T *)(*r1++));
                        
                    } else {
                        y->re     = **c1--;
                        (y++)->im = 0.0;      /* Real only */
                    }
                }
            }
            
        } else if(cC && !cR) {
            /* Real and Complex */
            InputRealPtrsType  row  = ssGetInputPortRealSignalPtrs(S,INPORT_R);
            InputPtrsType      col  = ssGetInputPortSignalPtrs(S,INPORT_C);
            creal_T           *y    = ssGetOutputPortSignal(S,OUTPORT_Y);
            
            /* row only effects the upper triangle of the matrix 
            * col wins the diagonal conflict if row(1) ~= col(1)
            * so we can ignore the first element of row 
            */
            
            for(i=0; i<LengthC; i++) {
                InputPtrsType      c1  = col++;/* reset to start at next element of col */
                InputRealPtrsType  r1  = row;  /* reset to start of row */
                int_T              j;
                
                for(j=0; j<LengthR; j++) {
                    
                    if(i<=j) {
                        y->re     = **r1++;
                        (y++)->im = 0.0;       /* Real only */
                        
                    } else {
                        *y++ = *((creal_T *)(*c1--));
                    }
                }
            }
            
        } else {      /* if(cC && cR) */
            /* Complex and Complex */
            InputPtrsType  row  = ssGetInputPortSignalPtrs(S,INPORT_R);
            InputPtrsType  col  = ssGetInputPortSignalPtrs(S,INPORT_C);
            creal_T       *y    = ssGetOutputPortSignal(S,OUTPORT_Y);
            
            /* row only effects the upper triangle of the matrix 
            * col wins the diagonal conflict if row(1) ~= col(1)
            * so we can ignore the first element of row 
            */
            
            for(i=0; i<LengthC; i++) {
                InputPtrsType  c1  = col++; /* reset to start at next element of col */
                InputPtrsType  r1  = row;   /* reset to start of row */
                int_T              j;
                
                for(j=0; j<LengthR; j++) {
                    
                    if(i<=j) {
                        *y++ = *((creal_T *)(*r1++));
                    } else {
                        *y++ = *((creal_T *)(*c1--));
                    }
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
    const boolean_T symmetric = (boolean_T)(mxGetPr(SYMMETRIC_ARG)[0] == 1);
    int_T outputPortWidth = ssGetOutputPortWidth(S,OUTPORT_Y);
    
    ssSetInputPortWidth(S, port, inputPortWidth);  /* Set the given port */
    
    if(symmetric) {
        /* Set input width
         * If output is set, it must equal the inputwidth squared
         * If output is not set, then set it to the inputwidth squared
         */		
        
        if(outputPortWidth != DYNAMICALLY_SIZED) {
            if(outputPortWidth != inputPortWidth * inputPortWidth) {
                ssSetErrorStatus(S, "Output matrix size not compatible with size of input vector.");
            }
        } else {
            /* Output a square N by N matrix with N = width of input */
            ssSetOutputPortWidth(S, OUTPORT_Y, inputPortWidth*inputPortWidth);
        }
    } else {
        /* ASYMMETRIC and there are two input ports */
        int_T OtherInWidth = ssGetInputPortWidth(S, 1-port);  /* get the other inport */
        
        if(OtherInWidth == DYNAMICALLY_SIZED) {
            return;
        } else {
            if(outputPortWidth != DYNAMICALLY_SIZED) {
                if(outputPortWidth != inputPortWidth * OtherInWidth) {
                    ssSetErrorStatus(S, "Output matrix size not compatible with size of input vector.");
                }
            } else {			
                ssSetOutputPortWidth(S, OUTPORT_Y, inputPortWidth*OtherInWidth);
            }
        }
    }
}

# define MDL_SET_OUTPUT_PORT_WIDTH
static void mdlSetOutputPortWidth(SimStruct *S, int_T port,
                                  int_T outputPortWidth)
{
    const boolean_T symmetric = (boolean_T)(mxGetPr(SYMMETRIC_ARG)[0] == 1);
    int_T RinWidth = ssGetInputPortWidth(S, INPORT_R);
    
    ssSetOutputPortWidth(S,port,outputPortWidth);  /* Set to given width */
    
    if(symmetric) {
        /* Set the output width
         * 
         * If the input width is set,it must equal the square 
         * root of the output width 
         *
         * If the input width is not set, then set it to the
         * square root of the output width
      x   */
        if(RinWidth != DYNAMICALLY_SIZED) {
            if(outputPortWidth != RinWidth * RinWidth) {
                ssSetErrorStatus(S, "Output matrix size not compatible with size of input vector.");
            }
        } else {		
            /* Intput width is square root of output width */
            real_T rVecWidth = sqrt((real_T)outputPortWidth);
            int_T  iVecWidth = (int_T)rVecWidth;
            
            if (rVecWidth != iVecWidth) {
                ssSetErrorStatus(S, "Size of output matrix must be square.");
            }
            
            ssSetInputPortWidth(S, INPORT_R, iVecWidth);
        }
    } else {
        
        /* ASYMMETRIC */
        int_T CinWidth = ssGetInputPortWidth(S, INPORT_C);
        
        if(RinWidth != DYNAMICALLY_SIZED && CinWidth == DYNAMICALLY_SIZED) {
            ssSetInputPortWidth(S, INPORT_C, outputPortWidth/RinWidth);
        }
        
        if(RinWidth == DYNAMICALLY_SIZED && CinWidth != DYNAMICALLY_SIZED) {
            ssSetInputPortWidth(S, INPORT_R, outputPortWidth/CinWidth);
        }
        
        if(RinWidth != DYNAMICALLY_SIZED && CinWidth != DYNAMICALLY_SIZED) {
            if(outputPortWidth != RinWidth * CinWidth) {
                ssSetErrorStatus(S, "Size of output matrix must be square.");
            }
        }
        
        /* If both input widths are not set, then return because we don't know enough */
    }
}
#endif

#include "dsp_cplxhs21.c"

#ifdef	MATLAB_MEX_FILE    
#include "simulink.c"      
#else
#include "cg_sfun.h"      
#endif
