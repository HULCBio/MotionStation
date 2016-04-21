/*
 * SDSPMMULT   DSP Blockset matrix multiply block CMEX S-Function.
 *
 *  Asize = [rows cols] is the size of the FIRST (A) matrix.
 *  Bcols is the number of cols of the SECOND (B) matrix.
 *  The number of rows of B is determined by the input size.
 *
 *   
 *  Copyright 1995-2002 The MathWorks, Inc.
 *  $Revision: 1.16 $  $Date: 2002/04/14 20:44:37 $
 */
#define S_FUNCTION_NAME sdspmmult
#define S_FUNCTION_LEVEL 2

#include "dsp_sim.h"

enum {ASIZE_IDX=0, BCOLS_IDX, NUM_ARGS};
#define ASIZE (ssGetSFcnParam(S, ASIZE_IDX))
#define BCOLS (ssGetSFcnParam(S, BCOLS_IDX))

enum {INPORT_A=0, INPORT_B};
enum {OUTPORT_Y=0};

#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S) 
{
    if((mxGetNumberOfElements(ASIZE) !=2) || !IS_VECTOR_DOUBLE(ASIZE)) {
        THROW_ERROR(S, "Size of U must be specified as a 2-element row vector.");
    }

    if(!IS_IDX_FLINT_GE(ASIZE,0,1) || !IS_IDX_FLINT_GE(ASIZE,1,1)) {
        THROW_ERROR(S, "U size vector must contain integers greater than 0.");
    }

    if(OK_TO_CHECK_VAR(S, BCOLS)) {
        if (!IS_FLINT_GE(BCOLS, 1)) {
            THROW_ERROR(S, "Columns of input must be a scalar integer > 0.");
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
    
    /* Inputs: */
    if (!ssSetNumInputPorts(S, 2)) return;
    
    ssSetInputPortWidth(            S, INPORT_A, DYNAMICALLY_SIZED);
    ssSetInputPortDirectFeedThrough(S, INPORT_A, 1);
    ssSetInputPortComplexSignal(    S, INPORT_A, COMPLEX_INHERITED);
    ssSetInputPortReusable(         S, INPORT_A, 1);
    ssSetInputPortOverWritable(     S, INPORT_A, 0);
    
    ssSetInputPortWidth(            S, INPORT_B, DYNAMICALLY_SIZED);
    ssSetInputPortDirectFeedThrough(S, INPORT_B, 1);
    ssSetInputPortComplexSignal(    S, INPORT_B, COMPLEX_INHERITED);
    ssSetInputPortReusable(         S, INPORT_B, 1);
    ssSetInputPortOverWritable(     S, INPORT_B, 0);
    
    /* Outputs: */
    if (!ssSetNumOutputPorts(S,1)) return;
    
    ssSetOutputPortWidth(        S, OUTPORT_Y, DYNAMICALLY_SIZED);      
    ssSetOutputPortComplexSignal(S, OUTPORT_Y, COMPLEX_INHERITED);
    ssSetOutputPortReusable(     S, OUTPORT_Y, 1);
	
    /*
     * Parameters ASIZE_IDX and BCOLS_IDX are
     * not tunable because it affects output width
     */
    ssSetSFcnParamNotTunable(S, ASIZE_IDX);
    ssSetSFcnParamNotTunable(S, BCOLS_IDX);
    
    ssSetNumSampleTimes(S, 1);
    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE);	
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
    /* Inputs are u, Outputs are y */
    const int_T     ii     = (int_T)(mxGetPr(ASIZE)[0]);  /* Arows */
    const int_T     jj     = (int_T)(mxGetPr(ASIZE)[1]);  /* Acols = Brows */
    const int_T     kk     = (int_T)(mxGetPr(BCOLS)[0]);  /* Bcols */
    const boolean_T cA     = (boolean_T)(ssGetInputPortComplexSignal(S,INPORT_A) == COMPLEX_YES);
    const boolean_T cB     = (boolean_T)(ssGetInputPortComplexSignal(S,INPORT_B) == COMPLEX_YES);
    const int_T     widthA = ssGetInputPortWidth(S, INPORT_A);
    const int_T     widthB = ssGetInputPortWidth(S, INPORT_B);
            
    if(widthA==1) {

        /* A is a scalar: */

        if (!cA && !cB) {
            real_T             A = **ssGetInputPortRealSignalPtrs(S, INPORT_A);
            InputRealPtrsType  B = ssGetInputPortRealSignalPtrs(S, INPORT_B);
            real_T            *y = ssGetOutputPortRealSignal(S, OUTPORT_Y);
            int_T   i;
            
            for(i=0; i<widthB; i++) {								
                *y++ = A * (**B++);
            }
            
        } else if(cA && !cB) {
            creal_T            A = *(creal_T *)(*ssGetInputPortRealSignalPtrs(S, INPORT_A));
            InputRealPtrsType  B = ssGetInputPortRealSignalPtrs(S, INPORT_B);
            creal_T           *y = ssGetOutputPortSignal(S, OUTPORT_Y);
            int_T   i;
            
            for(i=0; i<widthB; i++) {
                y->re     =  A.re * (**B);
                (y++)->im =  A.im * (**B++);
            }
            
        } else if(!cA && cB) {
            real_T         A = *(real_T *)(*ssGetInputPortRealSignalPtrs(S, INPORT_A));
            InputPtrsType  B = ssGetInputPortSignalPtrs(S, INPORT_B);
            creal_T       *y = ssGetOutputPortSignal(S, OUTPORT_Y);
            int_T   i;
            
            for(i=0; i<widthB; i++) {
                creal_T B1 = *(creal_T *)*B++;
                y->re     = A * B1.re;
                (y++)->im = A * B1.im;
            }
            
        } else {
            creal_T       A = *(creal_T *)(*ssGetInputPortRealSignalPtrs(S, INPORT_A));
            InputPtrsType B = ssGetInputPortSignalPtrs(S, INPORT_B);
            creal_T      *y = ssGetOutputPortSignal(S, OUTPORT_Y);
            int_T   i;
            
            for(i=0; i<widthB; i++) {
                creal_T B1 = *(creal_T *)*B++;
                y->re     = CMULT_RE(A,B1);
                (y++)->im = CMULT_IM(A,B1);
            }
        }

    } else if(widthB==1) {

        /* B is scalar: */

        if (!cA && !cB) {
            InputRealPtrsType A = ssGetInputPortRealSignalPtrs(S, INPORT_A);
            real_T            B = **(ssGetInputPortRealSignalPtrs(S, INPORT_B));
            real_T           *y = ssGetOutputPortRealSignal(S, OUTPORT_Y);
            int_T   i;
            
            for(i=0; i<widthA; i++) {								
                *y++ = (**A++) * B;
            }
            
        } else if(cA && !cB) {
            InputPtrsType A = ssGetInputPortSignalPtrs(S, INPORT_A);
            real_T        B = **(ssGetInputPortRealSignalPtrs(S, INPORT_B));
            creal_T      *y = ssGetOutputPortSignal(S, OUTPORT_Y);
            int_T   i;
            
            for(i=0; i<widthA; i++) {
                creal_T A1 = *(creal_T *)*A++;
                y->re     = A1.re * B;
                (y++)->im = A1.im * B;
            }
            
        } else if(!cA && cB) {
            InputRealPtrsType A = ssGetInputPortRealSignalPtrs(S, INPORT_A);
            creal_T           B = *(creal_T *)(*ssGetInputPortRealSignalPtrs(S, INPORT_B));
            creal_T          *y = ssGetOutputPortSignal(S, OUTPORT_Y);
            int_T   i;
            
            for(i=0; i<widthA; i++) {
                y->re     = (**A) * B.re;
                (y++)->im = (**A++) * B.im;
            }
            
        } else {
            InputPtrsType A = ssGetInputPortSignalPtrs(S, INPORT_A);
            creal_T       B = *(creal_T *)(*ssGetInputPortRealSignalPtrs(S, INPORT_B));
            creal_T      *y = ssGetOutputPortSignal(S, OUTPORT_Y);
            int_T   i;
            
            for(i=0; i<widthA; i++) {
                creal_T A1 = *(creal_T *)*A++;
                y->re     = CMULT_RE(A1,B);
                (y++)->im = CMULT_IM(A1,B);
            }
        }

    } else {

        /* A and B are both NOT scalars: */

        if (!cA && !cB) {
            /* Real Only Inputs */
            
            InputRealPtrsType  A = ssGetInputPortRealSignalPtrs(S, INPORT_A);
            InputRealPtrsType  B = ssGetInputPortRealSignalPtrs(S, INPORT_B);
            real_T            *y = ssGetOutputPortRealSignal(S, OUTPORT_Y);
            int_T              k;
            
            /* Compute real matrix multiply.
            *  Algorithm initializes output memory to zero
            *  before adding to it.
            */
            for(k=kk; k-- > 0; ) {
                InputRealPtrsType A1 = A;
                int_T i;
                
                for(i=ii; i-- > 0; ) {
                    InputRealPtrsType A2 = A1++;
                    InputRealPtrsType B1 = B;
                    int_T   j;
                    real_T  acc = 0.0;    /* Clear multiply accumulator */
                    
                    for(j=jj; j-- > 0; ) {
                        acc += (**A2) * (**(B1++));
                        A2 += ii;
                    }
                    *y++ = acc;
                }
                B += jj;
            }
            
        } else if(cA && cB) {
            /* Both inputs are Complex */
            
            InputPtrsType  A = ssGetInputPortSignalPtrs(S, INPORT_A);
            InputPtrsType  B = ssGetInputPortSignalPtrs(S, INPORT_B);
            creal_T       *y = (creal_T *)ssGetOutputPortSignal(S, OUTPORT_Y);
            int_T          k;
            
            /* Compute real matrix multiply.
            *  Algorithm initializes output memory to zero
            *    before adding to it.
            */
            for(k=kk; k-- > 0; ) {
                InputPtrsType A1 = A;
                int_T     i;
                
                for(i=ii; i-- > 0; ) {
                    InputPtrsType A2 = A1++;
                    InputPtrsType B1 = B;	
                    int_T   j;
                    creal_T acc = {0.0, 0.0};
                    
                    for(j=jj; j-- > 0; ) {
                        const creal_T  A2_val = *((creal_T *)(*A2  ));
                        const creal_T  B1_val = *((creal_T *)(*B1++));
                        acc.re += CMULT_RE(A2_val, B1_val);
                        acc.im += CMULT_IM(A2_val, B1_val);
                        A2 += ii;
                    }
                    *y++ = acc;
                }
                B += jj;
            }
            
        } else if(cA && !cB) {
            /* A is Complex and B is Real */
            
            InputPtrsType      A = ssGetInputPortSignalPtrs(S,INPORT_A);
            InputRealPtrsType  B = ssGetInputPortRealSignalPtrs(S,INPORT_B);
            creal_T           *y = (creal_T *)ssGetOutputPortSignal(S,OUTPORT_Y);      
            int_T              k;
            
            /* Compute real matrix multiply.
            *  Algorithm initializes output memory to zero
            *    before adding to it.
            */
            for(k=kk; k-- > 0; ) {
                InputPtrsType A1 = A;
                int_T     i;
                
                for(i=ii; i-- > 0; ) {
                    InputPtrsType     A2 = A1++;
                    InputRealPtrsType B1 = B;
                    int_T   j;
                    creal_T acc = {0.0, 0.0};
                    
                    for(j=jj; j-- > 0; ) {
                        creal_T A2_val = *((creal_T *)(*A2));
                        real_T  B1_val = **B1++;
                        acc.re += B1_val * A2_val.re;
                        acc.im += B1_val * A2_val.im;
                        A2 += ii;
                    }
                    *y++ = acc;
                }
                B += jj;
            }		
            
        } else if(!cA && cB) {
            /* A is Real and B is Complex */
            InputRealPtrsType  A = ssGetInputPortRealSignalPtrs(S,INPORT_A);
            InputPtrsType      B = ssGetInputPortSignalPtrs(S,INPORT_B);
            creal_T           *y = (creal_T *)ssGetOutputPortSignal(S,OUTPORT_Y);      
            int_T              k;
            
            /* Compute real matrix multiply.
            *  Algorithm initializes output memory to zero
            *    before adding to it.
            */
            for(k=kk; k-- > 0; ) {
                InputRealPtrsType A1 = A;
                int_T     i;
                
                for(i=ii; i-- > 0; ) {
                    InputRealPtrsType  A2 = A1++;
                    InputPtrsType      B1 = B;
                    int_T   j;
                    creal_T acc = {0.0, 0.0};
                    
                    for(j=jj; j-- > 0; ) {
                        real_T  A2_val = **A2;
                        creal_T B1_val = *((creal_T *)(*B1++));
                        acc.re += A2_val * B1_val.re;
                        acc.im += A2_val * B1_val.im;
                        A2 += ii;
                    }
                    *y++ = acc;
                }
                B += jj;
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
    ssSetInputPortWidth(S, port, inputPortWidth);
    {
        const int_T     ii = (int_T)(mxGetPr(ASIZE)[0]);  /* Arows */
        const int_T     jj = (int_T)(mxGetPr(ASIZE)[1]);  /* Acols = Brows */
        const int_T     kk = (int_T)(mxGetPr(BCOLS)[0]);  /* Bcols */
        const int_T WidthA = ssGetInputPortWidth(S, INPORT_A);
        const int_T WidthB = ssGetInputPortWidth(S, INPORT_B);
        const int_T WidthY = ssGetOutputPortWidth(S, OUTPORT_Y);
        
        if(port==INPORT_A) {
            if(inputPortWidth != ii*jj) {
                THROW_ERROR(S, "Input port A width does not match sizes specified for the block.");
            }
            
            /* OUTPUT WIDTH */
            if((WidthY == DYNAMICALLY_SIZED) && (WidthB != DYNAMICALLY_SIZED)) {
                if(WidthB != 1) {
                    if(WidthA == 1) {
                        ssSetOutputPortWidth(S,OUTPORT_Y, WidthB);
                    } else {
                        ssSetOutputPortWidth(S,OUTPORT_Y, ii*kk);
                    }
                } else {
                    ssSetOutputPortWidth(S,OUTPORT_Y, ii*jj);  /* B is a scalar, so output width is same as A */
                } 
            }
            
        } else { /* (port==INPORT_B) */
			/* if B is a scaler matrix, column size (kk) must == 1 */
			if((WidthB == 1) && (kk != 1)) {
				THROW_ERROR(S, "Inport port B is a scaler and does not match column size specified for the block.");
			}
			/* if A and B are not scalers, cols(A)*rows(B) must == port width of B */
			if((WidthB != 1) && (WidthA != 1) && (WidthA != DYNAMICALLY_SIZED) && (inputPortWidth != jj*kk)) {
				THROW_ERROR(S, "Input port B width does not match sizes specified for the block.");
			}

            /* OUTPUT WIDTH */
            if((WidthY == DYNAMICALLY_SIZED) && (WidthA != DYNAMICALLY_SIZED)) {
                if(WidthB != 1) {
                    if(WidthA == 1) {
                        ssSetOutputPortWidth(S,OUTPORT_Y, WidthB);
                    } else {
                        ssSetOutputPortWidth(S,OUTPORT_Y, ii*kk);
                    }
                } else {
                    ssSetOutputPortWidth(S,OUTPORT_Y, ii*jj);  /* B is a scalar, so output width is same as A */
                } 
            }
        }
    }
}

# define MDL_SET_OUTPUT_PORT_WIDTH
static void mdlSetOutputPortWidth(SimStruct *S, int_T port,
                                  int_T outputPortWidth)
{
    const int_T ii     = (int_T)(mxGetPr(ASIZE)[0]);  /* Arows */
    const int_T jj     = (int_T)(mxGetPr(ASIZE)[1]);  /* Acols = Brows */
    const int_T kk     = (int_T)(mxGetPr(BCOLS)[0]);  /* Bcols */
    const int_T WidthA = ssGetInputPortWidth(S, INPORT_A);
    const int_T WidthB = ssGetInputPortWidth(S, INPORT_B);

    ssSetOutputPortWidth(S,port, outputPortWidth);
         
    if(WidthA == DYNAMICALLY_SIZED) {
        ssSetInputPortWidth(S,INPORT_A, ii*jj);
    }
    
    if(WidthB == DYNAMICALLY_SIZED) {
        if(outputPortWidth == ii*jj) {
            ssSetInputPortWidth(S,INPORT_B, 1);     /* B must be scalar */
        } else {
            ssSetInputPortWidth(S,INPORT_B, jj*kk);
        }
    }

    if(WidthB != DYNAMICALLY_SIZED) {
        if( (WidthB !=1 && (outputPortWidth != ii*kk && outputPortWidth != WidthB) )
            || (WidthB ==1) && (outputPortWidth != ii*jj)) {

            THROW_ERROR(S, "Output port width does not match sizes specified for the block.");
        }        
    }
}
#endif


/* Complex handshake */
#include "dsp_cplxhs21.c"  


#ifdef	MATLAB_MEX_FILE   
#include "simulink.c"      
#else
#include "cg_sfun.h"       
#endif

/* [EOF] sdspmmult.c */
