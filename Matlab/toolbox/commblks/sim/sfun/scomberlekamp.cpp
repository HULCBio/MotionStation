/*
 *   SCOMBERLEKAMP Communications Blockset S-Function Berlekamp-Massey algorithm 
 *
 *   This S-function is used by the Reed-Solmon and BCH decoder blocks.
 *   It uses the gf2m object.
 *
 *    Copyright 1996-2004 The MathWorks, Inc.
 *    $Revision: 1.1.6.5 $  $ $    
 */

/* disable meaninless warning about strings and exception handling */
#pragma warning(disable:4530)    
                 
#ifdef __cplusplus
extern "C" { // use the C fcn-call standard for all functions  
#endif       // defined within this scope    

#define S_FUNCTION_NAME scomberlekamp
#define S_FUNCTION_LEVEL 2

#include "simstruc.h"

#ifdef __cplusplus
}// use the C fcn-call standard for all functions  
#endif       // defined within this scope    


#include "gf2m.h"
#include "comm_mtrx.h"
#include "comm_defs.h"


class decoderDummy{};
typedef _gf2m<decoderDummy> gf2m;
enum {INPORT_DATA=0};
enum {OUTPORT_DECODED=0, OUTPORT_CNUMERR};
enum {SYNDROME=0, LAMBDAX, LAMBDAX_TEMP, LAMBDAXACTUAL, TX, DELTA, ERRLOC, OMEGAX, OMEGAXACTUAL, TEMP1, TEMP2, TEMP3, TEMP4, TEMPVEC2T1, CCODE, LAMBDAX_DERIV, NUM_DWORK};

enum {N_ARGC = 0,       /* number of symbols per (shortened) codeword, n     */
      K_ARGC,           /* number of symbols per (shortened) message word, k */
      M_ARGC,           /* ceil(log2(n+1))                                   */
      T_ARGC,            /* number of errors the code can correct */
      PRIMPOLY_ARGC,    /* primitive polynomial of GF field                  */
      B_ARGC,           /* b associated with the generator polynomial        */
      SHORTENED_ARGC,   /* shortened code - number of padded zeros           */
      SHOWNUMERR_ARGC,  /* flag for optional 2nd output port                 */
      NUM_ARGS}; 

#define N_ARG           (ssGetSFcnParam(S, N_ARGC))
#define K_ARG           (ssGetSFcnParam(S, K_ARGC))
#define M_ARG           (ssGetSFcnParam(S, M_ARGC))
#define T_ARG          (ssGetSFcnParam(S, T_ARGC))
#define PRIMPOLY_ARG    (ssGetSFcnParam(S, PRIMPOLY_ARGC))
#define B_ARG           (ssGetSFcnParam(S, B_ARGC))
#define SHORTENED_ARG   (ssGetSFcnParam(S, SHORTENED_ARGC))
#define SHOWNUMERR_ARG  (ssGetSFcnParam(S, SHOWNUMERR_ARGC))


#ifdef __cplusplus
extern "C" {   
#endif       // defined within this scope    

void correctCode(real_T * Output0, real_T * Output1, real_T * CCode, int_T n, int_T k, int_T shortened, int_T currWordIdx, int_T cnumerr, boolean_T showNumErr);

#ifdef __cplusplus
}// use the C fcn-call standard for all functions  
#endif       // defined within this scope    

                 
#ifdef __cplusplus
extern "C" { // use the C fcn-call standard for all functions  
#endif       // defined within this scope    

static void mdlInitializeSizes(SimStruct *S)
{
    const boolean_T showNumErr = (boolean_T)(mxGetPr(SHOWNUMERR_ARG)[0]);
    int8_T numOutports = showNumErr ? 2 : 1;
    
    int_T i;

    /* The S-function takes 7 parameters
     * n, k, m, primPoly, b, shortened, showNumErr
     */
    ssSetNumSFcnParams(S,NUM_ARGS);

    /* Cannot change params while running: */
    for(i = 0; i < NUM_ARGS; ++i){
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

    if(!ssSetOutputPortDimensionInfo(S, OUTPORT_DECODED, DYNAMIC_DIMENSION)) return;
    ssSetOutputPortFrameData(        S, OUTPORT_DECODED, FRAME_YES);
    ssSetOutputPortComplexSignal(    S, OUTPORT_DECODED, COMPLEX_NO);
    ssSetOutputPortReusable(         S, OUTPORT_DECODED, 0);
    ssSetOutputPortSampleTime(       S, OUTPORT_DECODED, INHERITED_SAMPLE_TIME);

    if (showNumErr) {
        if(!ssSetOutputPortDimensionInfo(S, OUTPORT_CNUMERR, DYNAMIC_DIMENSION)) return;
        ssSetOutputPortFrameData(        S, OUTPORT_CNUMERR, FRAME_YES);
        ssSetOutputPortComplexSignal(    S, OUTPORT_CNUMERR, COMPLEX_NO);
        ssSetOutputPortReusable(         S, OUTPORT_CNUMERR, 0);
        ssSetOutputPortSampleTime(       S, OUTPORT_CNUMERR, INHERITED_SAMPLE_TIME);
    }

    if (!ssSetNumDWork(S, DYNAMICALLY_SIZED)) return;

    /* One sample time */
    ssSetNumSampleTimes(S, 1);

    /* Set the Pwork vector 
     *  Need 1 Pwork element for each GF2M object in the S-function.
     *  In this case, NUM_DWORK-2.
     */
    ssSetNumPWork(S,NUM_DWORK-2);

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
    const int32_T n  = (int_T)(mxGetPr(N_ARG)[0]);
    const int32_T k  = (int_T)(mxGetPr(K_ARG)[0]);

    const boolean_T showNumErr = (boolean_T)(mxGetPr(SHOWNUMERR_ARG)[0]);
    
    int_T outCols1 = 0;
    int_T outRows1 = 0;
    int_T outCols2 = 0;
    int_T outRows2 = 0;

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
                    if ( (dataPortWidth % n) !=0) {
                        ssSetErrorStatus(S, COMM_ERR_PORT_DIMS_NOT_MATCH_WORD_SIZE);
                        goto EXIT_POINT;
                    }
                    outCols1 = inCols;
                    outCols2 = inCols;
                    outRows1 = inRows/n*k;
                    outRows2 = inRows/n;
                }

                /* Determine if Output ports need setting */
                if (ssGetOutputPortWidth(S,OUTPORT_DECODED) == DYNAMICALLY_SIZED) {
                    if(!ssSetOutputPortMatrixDimensions(S, OUTPORT_DECODED, outRows1, outCols1)) return;
                    if (showNumErr) {
                        if(!ssSetOutputPortMatrixDimensions(S, OUTPORT_CNUMERR, outRows2, outCols2)) return;
                    }
                }
                else if (showNumErr) {
                    if (ssGetOutputPortWidth(S,OUTPORT_CNUMERR) == DYNAMICALLY_SIZED) {
                        if(!ssSetOutputPortMatrixDimensions(S, OUTPORT_CNUMERR, outRows2, outCols2)) return;
                        if(!ssSetOutputPortMatrixDimensions(S, OUTPORT_DECODED, outRows1, outCols1)) return;
                    }
                }
                else { /* Output has been set, so do error checking. */
                    const int_T *outDims1    = ssGetOutputPortDimensions(S, OUTPORT_DECODED);
                    const int_T  outRowsSet1 = outDims1[0];

                    if( outRowsSet1 != outRows1 ) {
                        ssSetErrorStatus(S, "Port width propagation failed. ");
                        goto EXIT_POINT;
                    }

                    if (showNumErr) {
                        const int_T *outDims2    = ssGetOutputPortDimensions(S, OUTPORT_CNUMERR);
                        const int_T  outRowsSet2 = outDims2[0];

                        if( outRowsSet2 != outRows2 ) {
                            ssSetErrorStatus(S, "Port width propagation failed. ");
                            goto EXIT_POINT;
                        }
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
    const int32_T n  = (int_T)(mxGetPr(N_ARG)[0]);
    const int32_T k  = (int_T)(mxGetPr(K_ARG)[0]);

    const boolean_T showNumErr = (boolean_T)(mxGetPr(SHOWNUMERR_ARG)[0]);
    boolean_T outputConnected;
    
    int_T inCols   = 0;
    int_T inRows   = 0;
    int_T outCols1 = 0;
    int_T outRows1 = 0;
    int_T outCols2 = 0;
    int_T outRows2 = 0;


    if (showNumErr) {
        outputConnected = ssGetOutputPortConnected(S,OUTPORT_DECODED) && ssGetOutputPortConnected(S,OUTPORT_CNUMERR) ;
    } else {
        outputConnected = ssGetOutputPortConnected(S,OUTPORT_DECODED) ;
    }

    if(!ssSetOutputPortDimensionInfo(S, portIdx, dimsInfo)) return;

    if(outputConnected)
    {
        switch (portIdx)
        {
            case OUTPORT_DECODED:
            {
                /* Port info */
                outRows1       = dimsInfo->dims[0];
                outCols1       = dimsInfo->dims[1];
                const int_T     dataPortWidth  = ssGetOutputPortWidth(S, OUTPORT_DECODED);

                const boolean_T framebased     = (boolean_T)(ssGetInputPortFrameData(S,INPORT_DATA) == FRAME_YES);
                const int_T     numDims        = ssGetOutputPortNumDimensions(S, OUTPORT_DECODED);

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
                    if ( (dataPortWidth % k) !=0) {
                        ssSetErrorStatus(S, COMM_ERR_PORT_DIMS_NOT_MATCH_WORD_SIZE);
                        goto EXIT_POINT;
                    }
                    inCols   = outCols1;
                    outCols2 = outCols1;
                    inRows   = outRows1/k*n;
                    outRows2 = outRows1/k;
                }

                /* Set or check 2nd output port if it exists */
                if (showNumErr) {
                    /* Set the second output port */
                    if (ssGetOutputPortWidth(S, OUTPORT_CNUMERR) == DYNAMICALLY_SIZED) {
                        if(!ssSetOutputPortMatrixDimensions(S, OUTPORT_CNUMERR, outRows2, outCols2)) return;
                    }
                    else { /* Dimensions have been set.  Check for correct dimensions being set */
                        const int_T *outDims2    = ssGetOutputPortDimensions(S, OUTPORT_CNUMERR);
                        const int_T  outRowsSet2 = outDims2[0];
                        if (outRowsSet2 != outRows2) {
                            ssSetErrorStatus(S, "Port width propagation failed.");
                            goto EXIT_POINT;
                        }
                    }
                }

                /* Determine if inport needs setting */
                if (ssGetInputPortWidth(S,INPORT_DATA) == DYNAMICALLY_SIZED) {
                    if(!ssSetInputPortMatrixDimensions(S, INPORT_DATA, inRows, inCols)) return;
                }
                else {/* Input has been set, so do error checking. */
                    const int_T *inDims = ssGetInputPortDimensions(S, INPORT_DATA);
                    const int_T  inRowsSet = inDims[0];

                    if (inRowsSet != inRows) {
                        ssSetErrorStatus(S, "Port width propagation failed.");
                        goto EXIT_POINT;
                    }
                }
                break;
            }

            case OUTPORT_CNUMERR:
            {
                /* Port info */
                outRows2       = dimsInfo->dims[0];
                outCols2       = dimsInfo->dims[1];

                const boolean_T framebased     = (boolean_T)(ssGetInputPortFrameData(S,INPORT_DATA) == FRAME_YES);
                const int_T     numDims        = ssGetOutputPortNumDimensions(S, OUTPORT_CNUMERR);

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

                    inCols   = outCols2;
                    outCols1 = outCols2;
                    inRows   = outRows2*n;
                    outRows1 = outRows2*k;
                }

                /* Set the second output port */
                if (ssGetOutputPortWidth(S, OUTPORT_DECODED) == DYNAMICALLY_SIZED) {
                    if(!ssSetOutputPortMatrixDimensions(S, OUTPORT_DECODED, outRows1, outCols1)) return;
                }
                else { /* Dimensions have been set.  Check for correct dimensions being set */
                    const int_T *outDims1    = ssGetOutputPortDimensions(S, OUTPORT_DECODED);
                    const int_T  outRowsSet1 = outDims1[0];
                    if (outRowsSet1 != outRows1) {
                        ssSetErrorStatus(S, "Port width propagation failed.");
                    goto EXIT_POINT;
                    }
                }

                /* Determine if inport needs setting */
                if (ssGetInputPortWidth(S,INPORT_DATA) == DYNAMICALLY_SIZED) {
                    if(!ssSetInputPortMatrixDimensions(S, INPORT_DATA, inRows, inCols)) return;
                }
                else {/* Input has been set, so do error checking. */
                    const int_T *inDims = ssGetInputPortDimensions(S, INPORT_DATA);
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
    /* Get mask parameters */
    const int_T m        = (int_T) mxGetPr(M_ARG)[0];
    const int_T primPoly = (int_T) mxGetPr(PRIMPOLY_ARG)[0];

    /* Error-correcting capability t */

    int_T t = (int_T) mxGetPr(T_ARG)[0];
    int_T t2 = 2*t;

    /* create the GF2M objects */
    
    gf2m *gSyndrome      = new gf2m(t2,m,primPoly); /* Syndrome */
    gf2m *gLambdaX       = new gf2m(t2+1,m,primPoly);   /* Lambda(X) */
    gf2m *gLambdaXTemp   = new gf2m(t2+1,m,primPoly);   /* Temp Lambda(X) */
    gf2m *gLambdaXActual = new gf2m(t+1,m,primPoly);    /* Actual Lambda(X) truncated to actual length */
    gf2m *gTx            = new gf2m(t2+1,m,primPoly);   /* T(X) */
    gf2m *gDelta         = new gf2m(1,m,primPoly);  /* Delta */
    gf2m *gErrloc        = new gf2m(t,m,primPoly);  /* Errloc */
    gf2m *gOmegaX        = new gf2m(3*t+1,m,primPoly);  /* Omega(X) */
    gf2m *gOmegaXActual  = new gf2m(t2+1,m,primPoly);   /* Omega(X) truncated */
    gf2m *gTemp1         = new gf2m(1,m,primPoly);  /* Temp scalar 1 */
    gf2m *gTemp2         = new gf2m(1,m,primPoly);  /* Temp scalar 2 */
    gf2m *gTemp3         = new gf2m(1,m,primPoly);  /* Temp scalar 3 */
    gf2m *gTemp4         = new gf2m(1,m,primPoly);  /* Temp scalar 4 */
    gf2m *gTempVec2t1    = new gf2m(t2+1,m,primPoly);   /* Temp vector of length 2t+1 */

    /* Store the gf objects in the Pwork vector */
    void **PWork = ssGetPWork(S);

    PWork[SYNDROME]       = gSyndrome;
    PWork[LAMBDAX]        = gLambdaX;
    PWork[LAMBDAX_TEMP]   = gLambdaXTemp;
    PWork[LAMBDAXACTUAL]  = gLambdaXActual;
    PWork[TX]             = gTx;
    PWork[DELTA]          = gDelta;
    PWork[ERRLOC]         = gErrloc;
    PWork[OMEGAX]         = gOmegaX;
    PWork[OMEGAXACTUAL]   = gOmegaXActual;
    PWork[TEMP1]          = gTemp1;
    PWork[TEMP2]          = gTemp2;
    PWork[TEMP3]          = gTemp3;
    PWork[TEMP4]          = gTemp4;
    PWork[TEMPVEC2T1]     = gTempVec2t1;

}

static void mdlOutputs(SimStruct *S, int_T tid)
{
/*  This is the main body of the Reed-Solomon Decoder,
 *  using the Berlekamp-Massey algorithm
 *
 *  The algorithm has two main parts:
 *      I.   Error locator polynomial computation
 *      II.  Error magnitude computation
 *
 */
    /* Get n, k, m from the Mask parameters */
    const int_T n         = (int_T) mxGetPr(N_ARG)[0];
    const int_T k         = (int_T) mxGetPr(K_ARG)[0];
    const int_T b         = (int_T) mxGetPr(B_ARG)[0];
    const int_T shortened = (int_T) mxGetPr(SHORTENED_ARG)[0];

    const real_T *u0      = (real_T *) ssGetInputPortRealSignal(S,INPORT_DATA);
    const int_T inWidth   = ssGetInputPortWidth(S, INPORT_DATA);

    /* Check to make sure the input array elements are integers, not decimals */
    for(int idx = 0; idx < inWidth; idx++){
        if(floor(u0[idx]) != u0[idx]) ssSetErrorStatus(S, "Input must be integer values.");
    }
    /* Number of words in each input frame */
    int_T numWords        = inWidth / n;
     
    const boolean_T showNumErr = (boolean_T)(mxGetPr(SHOWNUMERR_ARG)[0]);

    /* output ports */
    real_T * Output0    = (real_T *)ssGetOutputPortSignal(S,OUTPORT_DECODED);
    real_T * Output1    = 0;

    int_T cnumerr;    /* Number of corrected errors */
    int_T i,j;
    int_T iter, degLambdaX;

    /* Error-correcting capability t */
    int_T t = (int_T) mxGetPr(T_ARG)[0];
    int_T t2 = 2*t;

    /* Full codeword and message word lengths */
    int_T nfull = n+shortened;


    /* Length of linear feedback shift register (LFSR) */
    int_T L;

    /* Flag to indicate no error detected */
    int_T noErrorStatus = 1;

    real_T *Syndrome      = (real_T *) ssGetDWork(S, SYNDROME);
    real_T *LambdaX       = (real_T *) ssGetDWork(S, LAMBDAX);
    real_T *LambdaXTemp   = (real_T *) ssGetDWork(S, LAMBDAX_TEMP);
    real_T *LambdaXActual = (real_T *) ssGetDWork(S, LAMBDAXACTUAL);
    real_T *Tx            = (real_T *) ssGetDWork(S, TX);
    real_T *Delta         = (real_T *) ssGetDWork(S, DELTA);
    real_T *Errloc        = (real_T *) ssGetDWork(S, ERRLOC);
    real_T *OmegaX        = (real_T *) ssGetDWork(S, OMEGAX);
    real_T *OmegaXActual  = (real_T *) ssGetDWork(S, OMEGAXACTUAL);
    real_T *Temp1         = (real_T *) ssGetDWork(S, TEMP1);
    real_T *Temp2         = (real_T *) ssGetDWork(S, TEMP2);
    real_T *Temp3         = (real_T *) ssGetDWork(S, TEMP3);
    real_T *Temp4         = (real_T *) ssGetDWork(S, TEMP4);
    real_T *TempVec2t1    = (real_T *) ssGetDWork(S, TEMPVEC2T1);
    real_T *CCode         = (real_T *) ssGetDWork(S, CCODE);
    real_T *LambdaXDeriv  = (real_T *) ssGetDWork(S, LAMBDAX_DERIV);

    gf2m *gSyndrome;
    gf2m *gLambdaX;
    gf2m *gLambdaXTemp;
    gf2m *gLambdaXActual;
    gf2m *gTx;
    gf2m *gDelta;
    gf2m *gErrloc;
    gf2m *gOmegaX;
    gf2m *gOmegaXActual;
    gf2m *gTemp1;
    gf2m *gTemp2;
    gf2m *gTemp3;
    gf2m *gTemp4;
    gf2m *gTempVec2t1;

    /* get the pointers to the GF2M objects */
    void **PWork = ssGetPWork(S);
    gSyndrome      = (gf2m *)PWork[SYNDROME];
    gLambdaX       = (gf2m *)PWork[LAMBDAX];
    gLambdaXTemp   = (gf2m *)PWork[LAMBDAX_TEMP];
    gLambdaXActual = (gf2m *)PWork[LAMBDAXACTUAL];
    gTx            = (gf2m *)PWork[TX];
    gDelta         = (gf2m *)PWork[DELTA];
    gErrloc        = (gf2m *)PWork[ERRLOC];
    gOmegaX        = (gf2m *)PWork[OMEGAX];
    gOmegaXActual  = (gf2m *)PWork[OMEGAXACTUAL];
    gTemp1         = (gf2m *)PWork[TEMP1];
    gTemp2         = (gf2m *)PWork[TEMP2];
    gTemp3         = (gf2m *)PWork[TEMP3];
    gTemp4         = (gf2m *)PWork[TEMP4];
    gTempVec2t1    = (gf2m *)PWork[TEMPVEC2T1];

    /* Pointer to 2nd output if it is required */
    if (showNumErr) {
        Output1 = (real_T *)ssGetOutputPortSignal(S,OUTPORT_CNUMERR);
    }

    /* PART I - ERROR LOCATOR POLYNOMIAL COMPUTATION  */

    /* Step 1 -- Compute syndrome series : length = 2*t */

    for (int_T currWordIdx=0; currWordIdx<numWords; currWordIdx++){

        /* Reset for each word */
        noErrorStatus = 1;

        /* Prepend current input word with zeros to form CCode */
        for(i=0; i<shortened; i++){
            CCode[i] = 0;
        }

        /* Initialize latter part of current word in CCode to input word */
        for(i=shortened; i<n+shortened; i++){
            CCode[i] = u0[currWordIdx*n+i-shortened];
        }

        for (i=0; i<t2; i++){
            Temp3[0] = 0;       /* temp storage for sum */
            gTemp3->setX(Temp3);

            for (j=nfull-1; j>-1; j--){
                /* current input code symbol */
                Temp1[0] = CCode[nfull-1-j];
                gTemp1->setX(Temp1);

                /* alpha */
                Temp2[0] = 2;
                gTemp2->setX(Temp2);
                *gTemp2 = (*gTemp2)^((b+i)*j);
        
                /* sum so far */
                *gTemp3 = (*gTemp3) + (*gTemp1)*(*gTemp2);
            }

            Temp3 = gTemp3->getX();
            Syndrome[i] = Temp3[0];
            if (noErrorStatus && Syndrome[i]){
                noErrorStatus = 0;
            }
        }/* end of Syndrome calculation */
        gSyndrome->setX(Syndrome);

        /* Stop if all syndromes == 0 (i.e. input word is already a valid RS codeword) */
        if(noErrorStatus){
            cnumerr = 0;
            correctCode(Output0, Output1, CCode, n, k, shortened, currWordIdx, cnumerr,showNumErr);

        }else{

            /* Step 2 -- Initializations */

            /* Initialize Lambda(X) = 1 : ASCENDING ORDER.  length = 2t+1 */
            LambdaX[0] = 1;
            for(i=1; i<t2+1; i++){
                LambdaX[i] = 0;
            }
            gLambdaX->setX(LambdaX);

            /* Initialize L */
            L = 0;

            /* Initialize T(X) = X : ASCENDING ORDER.  length = 2t+1 */
            Tx[0] = 0;
            Tx[1] = 1;
            for(i=2; i<t2+1; i++){
                Tx[i] = 0;
            }
            gTx->setX(Tx);

            /* 2*t iterations */
            for(iter=0; iter<t2; iter++){

                /* Temporary storage for Connection polynomial from last iteration */
                /* length = 2t+1 */
                LambdaX = gLambdaX->getX();

                for(i=0;i<t2+1;i++){
                    LambdaXTemp[i]=LambdaX[i];
                }
                gLambdaXTemp->setX(LambdaXTemp);

                /* Step 3 -- Discrepancy */
                Delta[0] = 0;
                gDelta->setX(Delta);

                /* sum of lambda*syndrome */
                Temp3[0] = 0;   /* Initialize sum */
                gTemp3->setX(Temp3);
                for(i=1; i<L+1; i++){

                    if((iter-i) >= 0){   /* such that syndrome position is valid */
                        /* get current lambda coeff */
                        Temp1[0] = LambdaXTemp[i];
                        gTemp1->setX(Temp1);

                        /* get (iter-L)-th syndrome */
                        Temp2[0] = Syndrome[iter-i];
                        gTemp2->setX(Temp2);

                        /* Update sum */
                        *gTemp3 = *gTemp3 + (*gTemp1)*(*gTemp2);
                    }
                }/* end of sum of lambda*syndrome */

                /* Sk-sum */
                Temp1[0] = Syndrome[iter];  /* get current syndrome */
                gTemp1->setX(Temp1);
                *gDelta = *gTemp1 + *gTemp3;

                Delta = gDelta->getX();

                /* Step 4 -- Continue if Delta not equal to zero */
                if(Delta[0]){

                    /* Step 5 -- Connection polynomial */
                    /* scalar expansion of Delta[0] */
                    for (i=0;i<t2+1;i++){
                        TempVec2t1[i] = Delta[0];
                    }
                    gTempVec2t1->setX(TempVec2t1);

                    *gLambdaX = *gLambdaXTemp + (*gTempVec2t1)*(*gTx);
                    LambdaX = gLambdaX->getX();

                    /* Step 6 */
                    if((2*L) < (iter+1)){

                        /* Step 7 -- Correction polynomial */
                        L = iter+1-L;
                        *gTx = (*gLambdaXTemp)/(*gTempVec2t1);
                        Tx = gTx->getX();
                    }
                }

                /* Step 8 -- Correction polynomial */
                Tx = gTx->getX();
                for(i=t2;i>0;i--){
                    Tx[i]=Tx[i-1];
                }
                Tx[0] = 0;
                gTx->setX(Tx);

            }/* end of 2*t iterations */

            /* FIND ERROR LOCATIONS */

            /* At this point, error locator polynomial has been found, */
            /* which is LambdaX                                    */

            /* Find degree of Lambda(X) */
            degLambdaX = 0;
            for(i=t2;i>-1;i--){
                if(LambdaX[i]>0){
                    degLambdaX = i;
                    break;
                }
            }

            /* Degree of Lambda(X) must be <= t and larger than 0 (i.e. cannot be a constant) */
            if(degLambdaX>t || degLambdaX<1){
                cnumerr = -1;
                correctCode(Output0, Output1, CCode, n, k, shortened, currWordIdx, cnumerr,showNumErr);
            }else{

            /* Truncate LambdaX to its actual length.  If not filled up to length t, the empty trailing ones are just 0 */
            for(i=0;i<degLambdaX+1;i++){
                LambdaXActual[i] = LambdaX[i];
            }
            for(i=degLambdaX+1;i<t+1;i++){
                LambdaXActual[i] = 0;
            }
            gLambdaXActual->setX(LambdaXActual);

            /* Initialize gf object gErrloc */
/*            gErrloc->setX(NULL);*/

            /* Initialize contents at pointer Errloc */
            for(i=0;i<t;i++) 
            {
                Errloc[i]=0;
            }

            /* Integer values.  need to change to power form to get error locations */
            *gErrloc = gLambdaXActual->gf2mRoots();

            /* Get number of roots */
            cnumerr = gErrloc->getWidth();
            if (cnumerr){
                Errloc  = gErrloc->getX();
            }

            /* 
             * Decoding failure if one of the following conditions is met:
             * (1) Lambda(X) has no roots in this field
             * (2) Number of roots not equal to degree of LambdaX
             */
            if(cnumerr!=degLambdaX){
                cnumerr = -1;
                correctCode(Output0, Output1, CCode, n, k, shortened, currWordIdx, cnumerr,showNumErr);
            }else{

                /* Test if the error locations are unique */
                int_T isunique  = 1;
                for(i=0; (i<cnumerr-1 && isunique); i++){
                    for(j=i+1; (j<cnumerr && isunique); j++){
                        if (Errloc[i]==Errloc[j]){
                            isunique = 0;
                        }
                    }
                }

                if(!isunique){
                    cnumerr = -1;
                    correctCode(Output0, Output1, CCode, n, k, shortened, currWordIdx, cnumerr,showNumErr);
                }else{
                    /* PART II - FIND ERROR MAGNITUDES AT EACH OF THE ERROR LOCATIONS */

                    LambdaXActual = gLambdaXActual->getX();

                    /* Error magnitude polynomial */
                    /* Get [1 S] */
                    TempVec2t1[0] = 1;
                    for(i=1;i<t2+1;i++){
                        TempVec2t1[i] = Syndrome[i-1];
                    }
                    gTempVec2t1->setX(TempVec2t1);

                    for(i=0;i<3*t+1;i++) 
                    {   
                        OmegaX[i]=0;
                    } /* Initialize for each word */
                    gOmegaX->setX(OmegaX);

                    gOmegaX->conv(*gLambdaXActual,*gTempVec2t1);
                    OmegaX = gOmegaX->getX();

                    /* Disregard terms of x^(2t+1) and higher in Omega(X)  */
                    /* because we have no knowledge of such terms in S(X). */
                    /* That is, retain terms up to x^(2t)               */
                    for(i=0;i<t2+1;i++){
                        OmegaXActual[i] = OmegaX[i];
                    }
                    gOmegaXActual->setX(OmegaXActual);

                    /* Compute Derivative of LambdaXActual */
                    if(t%2 == 0){ /* t even */
                        for(i=0;i<t;i+=2){
                            LambdaXDeriv[i]   = LambdaXActual[i+1];
                            LambdaXDeriv[i+1] = 0;
                        }
                    }else{ /* t odd */
                        for(i=0;i<t-1;i+=2){
                            LambdaXDeriv[i]   = LambdaXActual[i+1];
                            LambdaXDeriv[i+1] = 0;
                        }
                        LambdaXDeriv[t-1]   = LambdaXActual[t];
                    }

                    /* Find error magnitude at each error location */
                    for(j=0;j<cnumerr;j++){

                        /* Dot product for numerator */
                        Temp3[0] = 0;   /* Initialize temp sum */
                        gTemp3->setX(Temp3);
                        for(i=0;i<t2+1;i++){
                            Temp1[0] = Errloc[j];
                            gTemp1->setX(Temp1);
                            int_T Apower = 1-b-i+1;
                            *gTemp1 = (*gTemp1)^(Apower);

                            Temp2[0] = OmegaXActual[i];
                            if (Temp2[0]>0){
                                gTemp2->setX(Temp2);
                                *gTemp3 = *gTemp3 + (*gTemp2)*(*gTemp1);
                            }
                        }
                        /* Dot product for denominator */
                        Temp4[0] = 0;   /* Initialize temp sum */
                        gTemp4->setX(Temp4);
                        for(i=0;i<t;i++){
                            Temp1[0] = Errloc[j];
                            gTemp1->setX(Temp1);
			*gTemp1 = (*gTemp1)^(-i);
                            Temp2[0] = LambdaXDeriv[i];
                            if (Temp2[0]>0){
                                gTemp2->setX(Temp2);
                                *gTemp4 = *gTemp4 + (*gTemp2)*(*gTemp1);
                            }
                        }    

                        /* Re-use space in gTemp1 */
                        (*gTemp1) = (*gTemp3) / (*gTemp4);

                        Temp2[0] = Errloc[j];
                        gTemp2->setX(Temp2);

                        /* Find exponent representations of Errloc ==> get actual error locations */
			Temp2[0] = gTemp2->log();
                        /* Correct the current error */
                        Temp3[0] = CCode[nfull-1-((int_T)Temp2[0])];
                        gTemp3->setX(Temp3);
                        *gTemp3 = (*gTemp3) + (*gTemp1);
                        Temp3 = gTemp3->getX();

                        CCode[nfull-1-((int_T)Temp2[0])] = Temp3[0];

                    }/* end each error location */

                    /* Assign outputs */
                    correctCode(Output0, Output1, CCode, n, k, shortened, currWordIdx, cnumerr,showNumErr);
                    }
                }
            }
        }

    }/* end each word */

}/* end mdlOutputs */


void correctCode(real_T * Output0, real_T * Output1, real_T * CCode, int_T n, int_T k, int_T shortened, int_T currWordIdx, int_T cnumerr, boolean_T showNumErr)
{
/*
 * CORRECTCODE  For the current word indexed by currWordIdx, 
 *              assign the decoded symbol as the first output Output0,
 *              and the number of errors as an optional second output Output1.
 */
    int_T i;
    /* 
     * Assign decoded symbols as output0
     * (without padded zeros at front and parity at end) 
     * That is, take [shortened]th to [shortened+k-1]th symbols among 
     *   the (n+shortened) symbols, creating a k-symbol decoded word.
     */
    for(i=0;i<k;i++){
        Output0[currWordIdx*k + i] = CCode[i+shortened];
    }

    /* Optional output1 */
    if (showNumErr){
        /* Assign number of corrected symbols (or -1 if decoding failure) as output1 */
        Output1[currWordIdx] = cnumerr;
    }
}/* end correctCode */

static void mdlTerminate(SimStruct *S)
{
    /* delete the pointers */
    void **PWork = ssGetPWork(S);
    for (int_T pidx = 0; pidx<(NUM_DWORK-2); pidx++){
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
    int_T t=(n-k)/2;

    ssSetNumDWork(S, NUM_DWORK);
    
    ssSetDWorkWidth(        S, SYNDROME, 2*t);
    ssSetDWorkDataType(     S, SYNDROME, SS_DOUBLE);
    ssSetDWorkComplexSignal(S, SYNDROME, COMPLEX_NO);

    ssSetDWorkWidth(        S, LAMBDAX, 2*t+1);
    ssSetDWorkDataType(     S, LAMBDAX, SS_DOUBLE);
    ssSetDWorkComplexSignal(S, LAMBDAX, COMPLEX_NO);

    ssSetDWorkWidth(        S, LAMBDAX_TEMP, 2*t+1);     /* only the first L elements are use.  all others disregarded */
    ssSetDWorkDataType(     S, LAMBDAX_TEMP, SS_DOUBLE);
    ssSetDWorkComplexSignal(S, LAMBDAX_TEMP, COMPLEX_NO);

    ssSetDWorkWidth(        S, LAMBDAXACTUAL, t+1);
    ssSetDWorkDataType(     S, LAMBDAXACTUAL, SS_DOUBLE);
    ssSetDWorkComplexSignal(S, LAMBDAXACTUAL, COMPLEX_NO);

    ssSetDWorkWidth(        S, TX, 2*t+1);
    ssSetDWorkDataType(     S, TX, SS_DOUBLE);
    ssSetDWorkComplexSignal(S, TX, COMPLEX_NO);

    ssSetDWorkWidth(        S, DELTA, 1);
    ssSetDWorkDataType(     S, DELTA, SS_DOUBLE);
    ssSetDWorkComplexSignal(S, DELTA, COMPLEX_NO);

    ssSetDWorkWidth(        S, ERRLOC, t);
    ssSetDWorkDataType(     S, ERRLOC, SS_DOUBLE);
    ssSetDWorkComplexSignal(S, ERRLOC, COMPLEX_NO);

    ssSetDWorkWidth(        S, OMEGAX, 3*t+1);
    ssSetDWorkDataType(     S, OMEGAX, SS_DOUBLE);
    ssSetDWorkComplexSignal(S, OMEGAX, COMPLEX_NO);

    ssSetDWorkWidth(        S, OMEGAXACTUAL, 2*t+1);
    ssSetDWorkDataType(     S, OMEGAXACTUAL, SS_DOUBLE);
    ssSetDWorkComplexSignal(S, OMEGAXACTUAL, COMPLEX_NO);

    ssSetDWorkWidth(        S, TEMP1, 1);
    ssSetDWorkDataType(     S, TEMP1, SS_DOUBLE);
    ssSetDWorkComplexSignal(S, TEMP1, COMPLEX_NO);

    ssSetDWorkWidth(        S, TEMP2, 1);
    ssSetDWorkDataType(     S, TEMP2, SS_DOUBLE);
    ssSetDWorkComplexSignal(S, TEMP2, COMPLEX_NO);

    ssSetDWorkWidth(        S, TEMP3, 1);
    ssSetDWorkDataType(     S, TEMP3, SS_DOUBLE);
    ssSetDWorkComplexSignal(S, TEMP3, COMPLEX_NO);

    ssSetDWorkWidth(        S, TEMP4, 1);
    ssSetDWorkDataType(     S, TEMP4, SS_DOUBLE);
    ssSetDWorkComplexSignal(S, TEMP4, COMPLEX_NO);

    ssSetDWorkWidth(        S, TEMPVEC2T1, 2*t+1);
    ssSetDWorkDataType(     S, TEMPVEC2T1, SS_DOUBLE);
    ssSetDWorkComplexSignal(S, TEMPVEC2T1, COMPLEX_NO);

    ssSetDWorkWidth(        S, CCODE, n+shortened);
    ssSetDWorkDataType(     S, CCODE, SS_DOUBLE);
    ssSetDWorkComplexSignal(S, CCODE, COMPLEX_NO);

    ssSetDWorkWidth(        S, LAMBDAX_DERIV, t);
    ssSetDWorkDataType(     S, LAMBDAX_DERIV, SS_DOUBLE);
    ssSetDWorkComplexSignal(S, LAMBDAX_DERIV, COMPLEX_NO);

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
