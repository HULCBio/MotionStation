/*
 *   SCOMRSENCODER Communications Blockset S-Function for Reed-Solomon encoder 
 *
 *   This S-function uses the gf2m object.
 *
 *    Copyright 1996-2004 The MathWorks, Inc.
 *    $Revision: 1.5.4.4 $  $Date: 2004/04/12 23:03:38 $
 */


#ifdef __cplusplus
extern "C" { // use the C fcn-call standard for all functions  
#endif       // defined within this scope 

#define S_FUNCTION_NAME scomrsencoder
#define S_FUNCTION_LEVEL 2

#include "simstruc.h"

#ifdef __cplusplus
}// use the C fcn-call standard for all functions  
#endif 

#include "simstruc.h"
#include "comm_mtrx.h"
#include "comm_defs.h"
#include "gf2m.h"

class encoderDummy { };
typedef _gf2m<encoderDummy> gf2m;
enum {INPORT_DATA=0};
enum {OUTPORT_CODE=0};
enum {GENPOLY=0, FIRSTPARITY, CURRMSG, B, MSGPAD, NUM_DWORK};

enum {N_ARGC = 0,       /* number of symbols per (shortened) codeword, n     */
      K_ARGC,           /* number of symbols per (shortened) message word, k */
      M_ARGC,           /* ceil(log2(n+1))                                   */
      PRIMPOLY_ARGC,    /* primitive polynomial of GF field                  */
      GENPOLY_ARGC,     /* generator polynomial                              */
      SHORTENED_ARGC,   /* shortened code - number of padded zeros           */
      NUM_ARGS}; 

#define N_ARG           (ssGetSFcnParam(S, N_ARGC))
#define K_ARG           (ssGetSFcnParam(S, K_ARGC))
#define M_ARG           (ssGetSFcnParam(S, M_ARGC))
#define PRIMPOLY_ARG    (ssGetSFcnParam(S, PRIMPOLY_ARGC))
#define GENPOLY_ARG     (ssGetSFcnParam(S, GENPOLY_ARGC))
#define SHORTENED_ARG   (ssGetSFcnParam(S, SHORTENED_ARGC))

#ifdef __cplusplus
extern "C" {   
#endif       // defined within this scope 


static void mdlInitializeSizes(SimStruct *S)
{
    int8_T numOutports = 1;
    int_T i;

    /* The S-function will take 6 parameters
    * n, k, m, primPoly, genpoly, shortened
    */
    ssSetNumSFcnParams(S,NUM_ARGS);

    /* Cannot change params while running: */
    for( i = 0; i < NUM_ARGS; ++i){
        ssSetSFcnParamNotTunable(S, i);
    }
    
    /* Inputs */
    /* 1 input port, can be any width */
    if (!ssSetNumInputPorts(S, 1)) return;

    if(!ssSetInputPortDimensionInfo( S, INPORT_DATA, DYNAMIC_DIMENSION)) return;
    ssSetInputPortFrameData(         S, INPORT_DATA, FRAME_YES);
    ssSetInputPortComplexSignal(     S, INPORT_DATA, COMPLEX_NO);
    ssSetInputPortReusable(          S, INPORT_DATA, 0);
    ssSetInputPortSampleTime(        S, INPORT_DATA, INHERITED_SAMPLE_TIME);
    ssSetInputPortDirectFeedThrough( S, INPORT_DATA, 1);
    ssSetInputPortRequiredContiguous(S, INPORT_DATA, 1);


    /* Outputs */
    if (!ssSetNumOutputPorts(S,numOutports)) return;

    if(!ssSetOutputPortDimensionInfo(S, OUTPORT_CODE, DYNAMIC_DIMENSION)) return;
    ssSetOutputPortFrameData(        S, OUTPORT_CODE, FRAME_YES);
    ssSetOutputPortComplexSignal(    S, OUTPORT_CODE, COMPLEX_NO);
    ssSetOutputPortReusable(         S, OUTPORT_CODE, 0);
    ssSetOutputPortSampleTime(       S, OUTPORT_CODE, INHERITED_SAMPLE_TIME);

    if (!ssSetNumDWork(S, DYNAMICALLY_SIZED)) return;

    /* One sample time*/
    ssSetNumSampleTimes(S, 1);

    /* Set the Pwork vector 
     *  Need 1 Pwork element for each GF2M object in the S-function.
     *  In this case, NUM_DWORK-1.
     */
    ssSetNumPWork(S,NUM_DWORK-1);

    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE         |
                    SS_OPTION_CAN_BE_CALLED_CONDITIONALLY );

}

static void mdlInitializeSampleTimes(SimStruct *S)
{
#if defined(MATLAB_MEX_FILE)
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);
    
    ssSetModelReferenceSampleTimeInheritanceRule(S, USE_DEFAULT_FOR_DISCRETE_INHERITANCE);

#endif
}


#ifdef MATLAB_MEX_FILE
#define MDL_SET_INPUT_PORT_DIMENSION_INFO
static void mdlSetInputPortDimensionInfo(SimStruct        *S, 
                                         int_T            portIdx,
                                         const DimsInfo_T *dimsInfo)
{
    const int32_T n  = (int32_T)(mxGetPr(N_ARG)[0]);
    const int32_T k  = (int32_T)(mxGetPr(K_ARG)[0]);

    int_T outCols1 = 0;
    int_T outRows1 = 0;

    if(!ssSetInputPortDimensionInfo(S, portIdx, dimsInfo)) return;
    
    if( ssGetInputPortConnected(S,INPORT_DATA) )
    {
        switch (portIdx)
        {
            case INPORT_DATA:
            {
                /* Port info */
                const boolean_T framebased     = (boolean_T)ssGetInputPortFrameData(S,INPORT_DATA);
                const int_T     inRows         = dimsInfo->dims[0];
                const int_T     inCols         = dimsInfo->dims[1];
                const int_T     dataPortWidth  = ssGetInputPortWidth(S, INPORT_DATA);
                const int_T     numDims        = ssGetInputPortNumDimensions(S, INPORT_DATA);

                if ((numDims != 1) && (numDims != 2)) {
                    ssSetErrorStatus(S, COMM_ERR_INVALID_N_D_ARRAY);
                    goto EXIT_POINT;
                }

                if (!framebased) {
                    ssSetErrorStatus(S, COMM_ERR_NO_FRAME_BASED);
                    goto EXIT_POINT;
                }
                else { /* Frame-based */
                    if (inCols != 1) {
                        ssSetErrorStatus(S, COMM_ERR_INVALID_MULTI_CHANNEL);
                        goto EXIT_POINT;
                    }
                    if ( (dataPortWidth % k) !=0) {
                        ssSetErrorStatus(S, COMM_ERR_PORT_DIMS_NOT_MATCH_WORD_SIZE);
                        goto EXIT_POINT;
                    }
                    outCols1 = inCols;
                    outRows1 = inRows/k*n;
                }

                /* Determine if Output ports need setting */
                if (ssGetOutputPortWidth(S,OUTPORT_CODE) == DYNAMICALLY_SIZED) {
                    if(!ssSetOutputPortMatrixDimensions(S, OUTPORT_CODE, outRows1, outCols1)) return;
		}
                else { /* Output has been set, so do error checking. */
                    const int_T *outDims1    = ssGetOutputPortDimensions(S, OUTPORT_CODE);
                    const int_T  outRowsSet1 = outDims1[0];

                    if( outRowsSet1 != outRows1 ) {
			ssSetErrorStatus(S, "Port width propagation failed. ");
                        goto EXIT_POINT;
                    }
                }
                break;
            }

            default:
                ssSetErrorStatus(S, "Invalid port index for port width propagation. ");
                goto EXIT_POINT;

        } /* End of Switch */
    }

 EXIT_POINT:
    return;
}
#endif

#define MDL_SET_OUTPUT_PORT_DIMENSION_INFO
static void mdlSetOutputPortDimensionInfo(SimStruct        *S,
                                          int_T            portIdx,
                                          const DimsInfo_T *dimsInfo)
{
    const int32_T n  = (int32_T)(mxGetPr(N_ARG)[0]);
    const int32_T k  = (int32_T)(mxGetPr(K_ARG)[0]);

    int_T inCols   = 0;
    int_T inRows   = 0;

    if(!ssSetOutputPortDimensionInfo(S, portIdx, dimsInfo)) return;

    if(ssGetOutputPortConnected(S,OUTPORT_CODE))
    {
        switch (portIdx)
        {
            case OUTPORT_CODE:
            {
                /* Port info */
                const int_T     outRows1       = dimsInfo->dims[0];
                const int_T     outCols1       = dimsInfo->dims[1];
                const int_T     dataPortWidth  = ssGetOutputPortWidth(S, OUTPORT_CODE);

                const boolean_T framebased     = (boolean_T)(ssGetInputPortFrameData(S,INPORT_DATA) == FRAME_YES);
                const int_T     numDims        = ssGetOutputPortNumDimensions(S, OUTPORT_CODE);

                if ((numDims != 1) && (numDims != 2)) {
                    ssSetErrorStatus(S, COMM_ERR_INVALID_N_D_ARRAY);
                    goto EXIT_POINT;
                }

                if (!framebased) {
                    ssSetErrorStatus(S, COMM_ERR_NO_FRAME_BASED);
                    goto EXIT_POINT;
                }
                else { /* Frame-based */
                    if (outCols1 != 1) {
                        ssSetErrorStatus(S, COMM_ERR_INVALID_MULTI_CHANNEL);
                        goto EXIT_POINT;
                    }
                    if ( (dataPortWidth % n) !=0) {
                        ssSetErrorStatus(S, COMM_ERR_PORT_DIMS_NOT_MATCH_WORD_SIZE);
                        goto EXIT_POINT;
                    }
                    inCols   = outCols1;
                    inRows   = outRows1/n*k;
                }

                /* Determine if inport needs setting */
                if (ssGetInputPortWidth(S,INPORT_DATA) == DYNAMICALLY_SIZED) {
                    if(!ssSetInputPortMatrixDimensions(S, INPORT_DATA, inRows, inCols)) return;
                }
                else {/* Input has been set, so do error checking. */
                    const int_T *inDims    = ssGetInputPortDimensions(S, INPORT_DATA);
                    const int_T  inRowsSet = inDims[0];

                    if (inRowsSet != inRows) {
                        ssSetErrorStatus(S, "Port width propagation failed.");
                        goto EXIT_POINT;
                    }
                }
                break;
            }

            default:
                ssSetErrorStatus(S, "Invalid port index for port width propagation. ");
                goto EXIT_POINT;

        } /* End of switch */
    }

 EXIT_POINT:
    return;

}

    
#define MDL_START

static void mdlStart(SimStruct *S)
{
    /* Get n, k, m, primPoly, b from the Mask parameters */
    const int_T n        = (int_T)  mxGetPr(N_ARG)[0];
    const int_T k        = (int_T)  mxGetPr(K_ARG)[0];
    const int_T m        = (int_T)  mxGetPr(M_ARG)[0];
    const int_T primPoly = (int_T)  mxGetPr(PRIMPOLY_ARG)[0];
    real_T * genPoly     = (real_T *) mxGetPr(GENPOLY_ARG);

    /* Error-correcting capability t */
    int_T t=(n-k)/2;
    int_T t2 = 2*t;

    /* create the GF2M objects */
    
    /* Genpoly - 1st element always 1, not passed in; so length reduced to 2t */
    gf2m *gGenpoly = new gf2m(t2,m,primPoly);
    gGenpoly->setX(genPoly);

    /* Firstparity value (1 value expanded to length 2t) */
    gf2m *gFirstparity = new gf2m(t2,m,primPoly);

    /* Current message symbol (1 value expanded to length 2t) */
    gf2m *gCurrmsg = new gf2m(t2,m,primPoly);

    /* Parity register */
    gf2m *gB = new gf2m(t2,m,primPoly);

    /* Store the gf objects in the Pwork vector */
    void **PWork = ssGetPWork(S);

    PWork[GENPOLY]     = gGenpoly;
    PWork[FIRSTPARITY] = gFirstparity;
    PWork[CURRMSG]     = gCurrmsg;
    PWork[B]           = gB;
}


static void mdlOutputs(SimStruct *S, int_T tid)
{
    /* Get mask parameters */
    const int_T n         = (int_T)  mxGetPr(N_ARG)[0];
    const int_T k         = (int_T)  mxGetPr(K_ARG)[0];
    const int_T shortened = (int_T)  mxGetPr(SHORTENED_ARG)[0];
    real_T * genPoly      = (real_T *) mxGetPr(GENPOLY_ARG);

    real_T *u0      = (real_T *) ssGetInputPortRealSignal(S,INPORT_DATA);
    const int_T inWidth   = ssGetInputPortWidth(S, INPORT_DATA);

    /* Check to make sure the input array elements are integers, not decimals */
    for(int idx = 0; idx < inWidth; idx++){
        if(floor(u0[idx]) != u0[idx]) ssSetErrorStatus(S, "Input must be integer values.");
    }
    /* Number of words in each input frame */
    int_T numWords       = inWidth / k;

    /* Output port */
    real_T * Output0     = (real_T *)ssGetOutputPortSignal(S,OUTPORT_CODE);
    int_T i;

    /* Error-correcting capability t */
    int_T t = (n-k)/2;
    int_T t2 = 2*t;

    /* Full codeword and message word lengths */
    int_T kfull = k+shortened;

    real_T *firstparity = (real_T *) ssGetDWork(S, FIRSTPARITY);
    real_T *currmsg     = (real_T *) ssGetDWork(S, CURRMSG);
    real_T *b           = (real_T *) ssGetDWork(S, B);
    real_T *msgpad      = (real_T *) ssGetDWork(S, MSGPAD);

    gf2m *gGenpoly;
    gf2m *gFirstparity;
    gf2m *gCurrmsg;
    gf2m *gB;
    
    /* get the pointers to the GF2M objects */
    void **PWork = ssGetPWork(S);
    gGenpoly     = (gf2m *)PWork[GENPOLY];
    gFirstparity = (gf2m *)PWork[FIRSTPARITY];
    gCurrmsg     = (gf2m *)PWork[CURRMSG];
    gB           = (gf2m *)PWork[B];

    gGenpoly->setX(genPoly);

    /* Process each message word in input independently */
    for (int_T currWordIdx=0; currWordIdx<numWords; currWordIdx++){

        /* 
         * The first (kfull-k=shortened) elements were initialized to 0 and will never change.
         * Populate last k elements of msgpad with current word in u0.
         */
        for(i=shortened; i<k+shortened; i++){
            msgpad[i] = u0[currWordIdx*k+i-shortened];
        }

	/* Initialize parity register to 0 */
	for(int_T idx=0; idx<t2; idx++)
	    b[idx] = 0;
	gB->setX(b);

	/* Encoding */
	for (int_T col=0; col<kfull; col++)
	{
	    /* Get current message symbol; expand to length 2t */
	    for (i=0;i<t2;i++) {
		currmsg[i] = (real_T) msgpad[col];
	    }
	    gCurrmsg->setX(currmsg);

	    /* Get first parity symbol; expand to length 2t */
	    b = gB->getX();
	    for (i=0;i<t2;i++) {
		firstparity[i] = b[0];
	    }
	    gFirstparity->setX(firstparity);
	    
	    /* Shift contents in b register to the "left" */
	    for (i=0;i<t2-1;i++) {
		b[i] = b[i+1];
	    }
	    b[2*t-1] = 0;
	    gB->setX(b);    

	    /* Key equation */
	    (*gB) = (*gB) + ((*gCurrmsg)+(*gFirstparity)) * (*gGenpoly);	

	}/* end Encoding */

	/* Get final content of parity register */
	b = gB->getX();

	/* Set the output port */
	/* Assign original message symbols as first part of this output code */
	for(i=0;i<k;i++){
	    Output0[currWordIdx*n + i] = u0[currWordIdx*k + i];
	}

	/* Assign parity symbols as second part of this output code */
	for(i=k;i<n;i++){
	    Output0[currWordIdx*n + i] = b[i-k];
	}

    }/* End current word */

}/* end mdlOutputs */


static void mdlTerminate(SimStruct *S)
{
    /* delete the pointers */
    void **PWork = ssGetPWork(S);
    for (int_T pidx = 0; pidx<(NUM_DWORK-1); pidx++){
       delete(gf2m *)PWork[pidx];
    }
}

#define MDL_SET_WORK_WIDTHS
static void mdlSetWorkWidths(SimStruct *S)
{        
    /*  
     *  Allocate work variables
     */

    /* Get n, k, primPoly from the Mask parameters */
    const int_T n         = (int_T) mxGetPr(N_ARG)[0];
    const int_T k         = (int_T) mxGetPr(K_ARG)[0];
    const int_T shortened = (int_T) mxGetPr(SHORTENED_ARG)[0];
   
    /* Error-correcting capability t */
    const int_T t  = (n-k)/2;

    ssSetNumDWork(S, NUM_DWORK);
    
    ssSetDWorkWidth(        S, GENPOLY, 2*t);
    ssSetDWorkDataType(     S, GENPOLY, SS_DOUBLE);
    ssSetDWorkComplexSignal(S, GENPOLY, COMPLEX_NO);

    ssSetDWorkWidth(        S, FIRSTPARITY, 2*t);
    ssSetDWorkDataType(     S, FIRSTPARITY, SS_DOUBLE);
    ssSetDWorkComplexSignal(S, FIRSTPARITY, COMPLEX_NO);

    ssSetDWorkWidth(        S, CURRMSG, 2*t);
    ssSetDWorkDataType(     S, CURRMSG, SS_DOUBLE);
    ssSetDWorkComplexSignal(S, CURRMSG, COMPLEX_NO);

    ssSetDWorkWidth(        S, B, 2*t);
    ssSetDWorkDataType(     S, B, SS_DOUBLE);
    ssSetDWorkComplexSignal(S, B, COMPLEX_NO);

    ssSetDWorkWidth(        S, MSGPAD, k+shortened);
    ssSetDWorkDataType(     S, MSGPAD, SS_DOUBLE);
    ssSetDWorkComplexSignal(S, MSGPAD, COMPLEX_NO);

/* EXIT_POINT:
    return;
*/
}

#ifdef  MATLAB_MEX_FILE
#include "simulink.c"
#else
#include "cg_sfun.h"
#endif

#ifdef __cplusplus
} // use the C fcn-call standard for all functions  
#endif       // defined within this scope    

