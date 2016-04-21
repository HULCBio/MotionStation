/*
 *   SCOMGENMUXINT - Communications Blockset S-Function
 *   for general multiplexed interleaver and deinterleaver.
 *
 *   Copyright 1996-2004 The MathWorks, Inc.
 *   $Revision: 1.11.4.3 $
 *   $Date: 2004/04/12 23:03:25 $
*/

#define S_FUNCTION_LEVEL 2
#define S_FUNCTION_NAME scomgenmuxint

#include "simstruc.h"
#include "comm_defs.h"

enum {ARGC_DELAY=0, ARGC_ICRE, ARGC_ICIM, NUM_ARGS};

#define DLY_ARG       ssGetSFcnParam(S,ARGC_DELAY)  /* Delays */
#define IC_ARGRE      ssGetSFcnParam(S,ARGC_ICRE)   /* Initial conditions */
#define IC_ARGIM      ssGetSFcnParam(S,ARGC_ICIM)   /* Initial conditions */

/* Input and output ports */
enum {INPORT=0, NUM_INPORTS};
enum {OUTPORT=0, NUM_OUTPORTS};

/* DWork indices */
enum {DelayElems=0, BuffOffIdx, BuffLenIdx, BuffBgnIdx, RegSelIdx, NUM_DWORKS};


/* Function: validateICs =====================================================*/
static void validateInitCond(SimStruct *S)
{
    const boolean_T cplx = (boolean_T) (ssGetInputPortComplexSignal(S,INPORT)== COMPLEX_YES);
	const int_T     numIC = mxGetNumberOfElements(IC_ARGRE);
	boolean_T       cplx_ic = 0;
	int_T           i = 0;

	/* Determine if Iniyial Condition is complex */
	for (i = 0; i < numIC; i++)
	{
		cplx_ic = cplx_ic || mxGetPr(IC_ARGIM)[i];
	}

    if(!cplx && cplx_ic){
        THROW_ERROR(S,"Initial condition must be real if input is real.");
    }

} /* validateICs */

/* Function: validateInput =============================================================*/
static void validateInput(SimStruct *S)
{
    const int_T  isFrame        = ssGetInputPortFrameData(S, INPORT);
    const int_T *InputDims      = ssGetInputPortDimensions(S,INPORT);
    const int_T  dataPortWidth  = ssGetInputPortWidth(S, INPORT);
    const int_T *DelayDims      = mxGetDimensions(DLY_ARG);

    if(isFrame){ /* ensure that delay is [Dx1] and that input isn't row vector*/
    	if(InputDims[1]!=1){
        	THROW_ERROR(S,"Multichannel operation not supported.");
    	}
    	if(DelayDims[1]!=1){
        	THROW_ERROR(S,"Delay must be specified as scalar or column vector in frame-based mode.");
    	}
    }
    else { /* ensure that input is a scalar */
    	if(dataPortWidth!=1){
    		THROW_ERROR(S,"Input must be scalar in sample-based mode.");
    	}
    }

}

/* Function: mdlCheckParameters =============================================================*/
#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S) {

    if(OK_TO_CHECK_VAR(S, IC_ARGRE)){
        if (mxIsEmpty(IC_ARGRE)) {
            THROW_ERROR(S, "The initial condition must be real or complex.");
        }
    }

	if(OK_TO_CHECK_VAR(S, IC_ARGIM)){
        if (mxIsEmpty(IC_ARGIM)) {
            THROW_ERROR(S, "The initial condition must be real or complex.");
        }
    }

    if (OK_TO_CHECK_VAR(S, DLY_ARG)) {
        const int_T  delayLen       = mxGetNumberOfElements(DLY_ARG);
        const int_T  DelayNumDims   = mxGetNumberOfDimensions(DLY_ARG);
        const int_T *DelayDims      = mxGetDimensions(DLY_ARG);

        if (DelayNumDims>2) {
            THROW_ERROR(S, "Delay must be 1-D or 2-D.");
        }

        if (DelayDims[0]!=1 && DelayDims[1]!=1){
            THROW_ERROR(S, "Delay must be scalar, row vector (sample-based mode only), or column vector.");
        }

        if (delayLen >= 1) {
            int_T i;
            for (i=0; i < delayLen; i++) {
                if (!IS_IDX_FLINT_GE(DLY_ARG,i,0)) {
                    THROW_ERROR(S, "The delay argument must contain integer values >= 0.");
                }
            }
        }
        if (OK_TO_CHECK_VAR(S, IC_ARGRE)) {
            const int_T      IC_numEle = mxGetNumberOfElements(IC_ARGRE);

            /* Note: Scalar IC always OK */
            if (IC_numEle > 1) {
                const int_T *IC_dims  = mxGetDimensions(IC_ARGRE);
                const int_T  IC_nDims = mxGetNumberOfDimensions(IC_ARGRE);

                if (IC_nDims > 2) {
                    THROW_ERROR(S,"Initial condition must be 1-D or 2-D.");
                }

                if (IC_dims[0]!=DelayDims[0] || IC_dims[1]!=DelayDims[1]) {
                    THROW_ERROR(S,"Initial condition must be scalar or vector with same dimensions as delay.");
                }
            }
        }
    }
}
#endif

/* Function: mdlInitializeSizes =============================================================*/
static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumSFcnParams(S, NUM_ARGS);

    #if defined(MATLAB_MEX_FILE)
        if (ssGetNumSFcnParams(S)!=ssGetSFcnParamsCount(S)) return;
        mdlCheckParameters(S);
        if (ssGetErrorStatus(S)!=NULL) return;
    #endif

    ssSetSFcnParamNotTunable(S,ARGC_DELAY);
    ssSetSFcnParamNotTunable(S,ARGC_ICRE);
	ssSetSFcnParamNotTunable(S,ARGC_ICIM);

    if (!ssSetNumInputPorts(         S, NUM_INPORTS)) return;
    ssSetInputPortComplexSignal(     S, INPORT, COMPLEX_INHERITED);
    if (!ssSetInputPortDimensionInfo(S, INPORT, DYNAMIC_DIMENSION)) return;
    ssSetInputPortFrameData(         S, INPORT, FRAME_INHERITED);
    ssSetInputPortReusable(          S, INPORT, 0);
    ssSetInputPortOverWritable(      S, INPORT, 0);
    ssSetInputPortRequiredContiguous(S, INPORT, 1);
    ssSetInputPortDirectFeedThrough( S, INPORT, 1);

    if (!ssSetNumOutputPorts(        S, NUM_OUTPORTS)) return;
    if(!ssSetOutputPortDimensionInfo(S, OUTPORT, DYNAMIC_DIMENSION)) return;
    ssSetOutputPortFrameData(        S, OUTPORT, FRAME_INHERITED);
    ssSetOutputPortComplexSignal(    S, OUTPORT, COMPLEX_INHERITED);
    ssSetOutputPortReusable(         S, OUTPORT, 0);

    if(!ssSetNumDWork(S, DYNAMICALLY_SIZED)) return;

    ssSetNumSampleTimes(S, 1);
    ssSetOptions(       S, SS_OPTION_EXCEPTION_FREE_CODE         |
                           SS_OPTION_CAN_BE_CALLED_CONDITIONALLY );
}

/* Function: mdlInitializeSampleTimes =================================================*/
static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, FIXED_IN_MINOR_STEP_OFFSET);
    
    ssSetModelReferenceSampleTimeInheritanceRule(S, USE_DEFAULT_FOR_DISCRETE_INHERITANCE);
}

/* Function: mdlInitializeConditions ==================================================*/
#define MDL_INITIALIZE_CONDITIONS
static void mdlInitializeConditions(SimStruct *S)
{
    real_T          *delays     = (real_T *) mxGetPr(DLY_ARG);
    const int_T      numDelays  = mxGetNumberOfElements(DLY_ARG);
    int_T           *bufLen     = (int_T *) ssGetDWork(S, BuffLenIdx);
    int_T           *bufOff     = (int_T *) ssGetDWork(S, BuffOffIdx);
    int_T           *bufBgn     = (int_T *) ssGetDWork(S, BuffBgnIdx);
    int_T           *RegSel     = (int_T *) ssGetDWork(S, RegSelIdx);
    int_T            i,j;
    const int_T      numElements= ssGetDWorkWidth(S, DelayElems);
    const int_T      IC_numEle  = mxGetNumberOfElements(IC_ARGRE);
    const boolean_T  cplx       = (boolean_T) (ssGetInputPortComplexSignal(S,INPORT)== COMPLEX_YES);

    bufBgn[0]= 0;
    bufLen[0]= (int_T) delays[0];
    bufOff[0]= bufLen[0] - 1;

    for(i=1; i<numDelays;i++) {
        bufLen[i]= (int_T) delays[i];
        bufOff[i]= bufLen[i] - 1;
        bufBgn[i]= bufBgn[i-1] + bufLen[i-1];
    }

    *RegSel=0;

    if(cplx){ /* complex */
        creal_T *buff = (creal_T *) ssGetDWork(S, DelayElems);
        creal_T ic;

        if (IC_numEle == 1) {

            ic.re=(mxGetPr(IC_ARGRE)==NULL)?(real_T) 0.0:mxGetPr(IC_ARGRE)[0];
            ic.im=(mxGetPr(IC_ARGIM)==NULL)?(real_T) 0.0:mxGetPr(IC_ARGIM)[0];

            for(j=0;j<numElements;j++) *buff++=ic;

        } /*IC_numEle = 1 */
        else { /* IC and delay have same dimensions */

            real_T  *re   =  (real_T *)mxGetPr(IC_ARGRE);
            real_T  *im   =  (real_T *)mxGetPr(IC_ARGIM);

            for(i=0;i<numDelays;i++ ) {
                ic.re=(re==NULL)?(real_T)0.0:*re++;
                ic.im=(im==NULL)?(real_T)0.0:*im++;
                for(j=bufBgn[i];j<bufBgn[i]+bufLen[i];j++ ){
                    *buff++=ic;
                }
            }
        } /* IC_numEle != 1 */
    } /* complex */
    else {/* real*/
        real_T  *buff = (real_T *) ssGetDWork(S, DelayElems);
        real_T  *ic   = (real_T *) mxGetPr(IC_ARGRE);

        if (IC_numEle == 1) {
            for(j=0;j<numElements;j++) *buff++=*ic;
        }
        else { /* IC and delay have same dimensions */
            for(i=0;i<numDelays;i++ ) {
                for(j=bufBgn[i];j<bufBgn[i]+bufLen[i];j++ ){
                    *buff++=*(ic+i);
                }
            }
        }
    } /* real */
}

/* Function: mdlStart ========================================================*/
#define MDL_START
static void mdlStart(SimStruct *S)
{
    #ifdef  MATLAB_MEX_FILE
	const real_T     Ts = ssGetSampleTime(S,0);

    if (Ts == CONTINUOUS_SAMPLE_TIME) {
        THROW_ERROR(S, "Continuous sample times not allowed.");
    }

    validateInput(S);
    validateInitCond(S);
    #endif
}

/* Function: mdlOutputs ======================================================*/
static void mdlOutputs(SimStruct *S, int_T tid)
{
    const int_T      nSamps     = ssGetInputPortWidth(S,INPORT);
    int_T           *bufOff     = (int_T *) ssGetDWork(S, BuffOffIdx);
    int_T           *bufLen     = (int_T *) ssGetDWork(S, BuffLenIdx);
    int_T           *bufBgn     = (int_T *) ssGetDWork(S, BuffBgnIdx);
    int_T           *RegSel     = (int_T *) ssGetDWork(S, RegSelIdx);
    int_T            buffind    = 0;
    int_T            buffadj    = 0;
    const int_T      numDelays  = mxGetNumberOfElements(DLY_ARG);
    int_T            i;
    const boolean_T  cplx       = (boolean_T) (ssGetInputPortComplexSignal(S,INPORT)== COMPLEX_YES);

    if(cplx){ /* complex */
        creal_T         *y      = (creal_T *) ssGetOutputPortSignal(S, OUTPORT);
        creal_T         *buff   = (creal_T *) ssGetDWork(S, DelayElems);
        const creal_T   *u      = (const creal_T *)ssGetInputPortSignal(S,INPORT);

        for(i=0; i<nSamps; i++)
        {
            buffind=RegSel[0];
            if(bufLen[buffind]==0){
                *y++=*u++;
            }
            else { /* partition length is nonzero */
                if(++bufOff[buffind]==bufLen[buffind]){
                    bufOff[buffind]=0;
                }
                *y++=*(buff+bufBgn[buffind]+bufOff[buffind]);
                *(buff+bufBgn[buffind]+bufOff[buffind])=*u++;
            }
            if(++RegSel[0]==numDelays){
                RegSel[0]=0;
            }
        } /* nSamps */
    } /* complex */
    else { /* real */
        real_T        *y    = (real_T *) ssGetOutputPortRealSignal(S, OUTPORT);
        real_T        *buff = (real_T *) ssGetDWork(S, DelayElems);
        const real_T  *u    = (const real_T *)ssGetInputPortSignal(S,INPORT);

        for(i=0; i<nSamps; i++)
        {
            buffind=RegSel[0];
            if(bufLen[buffind]==0){
                *y++=*u++;
            }
            else { /* partition length is nonzero */
                if(++bufOff[buffind]==bufLen[buffind]){
                    bufOff[buffind]=0;
                }
                *y++=*(buff+bufBgn[buffind]+bufOff[buffind]);
                *(buff+bufBgn[buffind]+bufOff[buffind])=*u++;
            }
            if(++RegSel[0]==numDelays){
                RegSel[0]=0;
            }
        } /* nSamps */
    } /* real */
} /* mdlOutputs */

/* Function: mdlTerminate =============================================================*/
static void mdlTerminate(SimStruct *S)
{
}

/* Function: mdlSetWorkWidths =============================================================*/
#ifdef MATLAB_MEX_FILE
#define MDL_SET_WORK_WIDTHS
static void mdlSetWorkWidths(SimStruct *S)
{
    const int_T      inPortWidth        = ssGetInputPortWidth(S, INPORT);
    const real_T    *delays             = (real_T *) mxGetPr(DLY_ARG);
    const int_T      delayLen           = mxGetNumberOfElements(DLY_ARG);
    int_T            buffsize           = 0;
    int_T            i;

    for (i=0; i < delayLen; i++) {
        buffsize = buffsize + (int_T) delays[i];
    }

    /* DWorks: */
    if(!ssSetNumDWork( S, NUM_DWORKS)) return;

    ssSetDWorkWidth(        S, DelayElems, buffsize+1); /* added one in case all zero delays */
    ssSetDWorkDataType(     S, DelayElems, SS_DOUBLE);
    ssSetDWorkComplexSignal(S, DelayElems, ssGetInputPortComplexSignal(S,INPORT));

    ssSetDWorkWidth(        S, BuffOffIdx, delayLen);
    ssSetDWorkDataType(     S, BuffOffIdx, SS_INT32);

    ssSetDWorkWidth(        S, BuffLenIdx, delayLen);
    ssSetDWorkDataType(     S, BuffLenIdx, SS_INT32);

    ssSetDWorkWidth(        S, BuffBgnIdx, delayLen);
    ssSetDWorkDataType(     S, BuffBgnIdx, SS_INT32);

    ssSetDWorkWidth(        S, RegSelIdx, 1);
    ssSetDWorkDataType(     S, RegSelIdx, SS_INT32);

}
#endif

#ifdef  MATLAB_MEX_FILE
#include "simulink.c"
#else
#include "cg_sfun.h"
#endif

/* [EOF] scomgenmuxint.c */
