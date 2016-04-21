/*
 * SCOMAWGNCHAN2 Communications Toolbox S-Function for additive white
 * gaussian noise channel. Used in combination with Simulink
 * built-in gaussian noise source.
 *
 *   Copyright 1996-2004 The MathWorks, Inc.
 *   $Revision: 1.10.4.3 $ $Date: 2004/04/20 23:15:46 $
 */

#define S_FUNCTION_NAME scomawgnchan2
#define S_FUNCTION_LEVEL 2

#define DATA_TYPES_IMPLEMENTED

#include "comm_defs.h"

/* List input & output ports*/
enum {INPORT_SIGNAL=0, INPORT_NOISE, INPORT_VARIANCE, NUM_INPORTS};
enum {OUTPORT_SIGNAL=0, NUM_OUTPORTS};

/* List Work Vectors */
enum {STD_IDX = 0, NUM_DWORK};

/* List Run-time parameters index values (at most 2 for a specific mode) */
#define EBNO_RTP_IDX  0 
#define ESNO_RTP_IDX  0 
#define SNR_RTP_IDX   0
#define SPOW_RTP_IDX  1
#define VAR_RTP_IDX   0

/* List the mask parameters*/
enum {
	MODEC=0,
	EBNO_DBC,
	ESNO_DBC,
	SNR_DBC,
	BITSPERSYMC,
	SIGNAL_POWERC,
	SYMBOL_PERIODC,
	FIELD_VARIANCEC,
	NUM_ARGS
};

#define MODE					ssGetSFcnParam(S, MODEC)
#define EBNO_DB                 ssGetSFcnParam(S, EBNO_DBC)
#define ESNO_DB					ssGetSFcnParam(S, ESNO_DBC)
#define SNR_DB					ssGetSFcnParam(S, SNR_DBC)
#define BITSPERSYM              ssGetSFcnParam(S, BITSPERSYMC)
#define SIGNAL_POWER			ssGetSFcnParam(S, SIGNAL_POWERC)
#define SYMBOL_PERIOD			ssGetSFcnParam(S, SYMBOL_PERIODC)
#define FIELD_VARIANCE			ssGetSFcnParam(S, FIELD_VARIANCEC)

/*Define variables representing parameter values*/
enum {EbNo_Mode=1, EsNo_Mode, SNR_Mode, MaskVar_Mode, InVar_Mode};

#define OPERATION_MODE			(uint8_T)mxGetPr(MODE)[0]

#define Is_EbNo_Mode            (OPERATION_MODE == EbNo_Mode)
#define Is_EsNo_Mode			(OPERATION_MODE == EsNo_Mode)
#define Is_SNR_Mode				(OPERATION_MODE == SNR_Mode)
#define Is_MaskVar_Mode			(OPERATION_MODE == MaskVar_Mode)
#define Is_InVar_Mode			(OPERATION_MODE == InVar_Mode)

/* --- Function prototypes --- */
static void setNoiseStdDev(SimStruct *S);

/* Function: mdlCheckParameters ===============================================*/
#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S)
{
    /*---Check the mode Parameter-----------*/
    if (!IS_FLINT_IN_RANGE(MODE,1,5))
    {
        THROW_ERROR(S,"Mode parameter is outside of expected range.");
    }

    /*---Check for Signal Power parameter in modes 1, 2 and 3----*/
    if (Is_EbNo_Mode || Is_EsNo_Mode || Is_SNR_Mode)
    {
        if (OK_TO_CHECK_VAR(S,SIGNAL_POWER))
        {
            int_T iPsp;

            if (mxIsComplex(SIGNAL_POWER))
            {
                THROW_ERROR(S, "Input signal power parameter needs to be a real value.");
            }
            for (iPsp = 0; iPsp < mxGetNumberOfElements(SIGNAL_POWER); iPsp++)
            {
                if (mxGetPr(SIGNAL_POWER)[iPsp] < 0.0)
                {
                    THROW_ERROR(S, "Input signal power parameter needs to be a positive value.");
                }
            }
        }
    }

	/* Check Symbol Period parameter in modes 1 & 2 */
	if (Is_EbNo_Mode || Is_EsNo_Mode) {
	  if (OK_TO_CHECK_VAR(S, SYMBOL_PERIOD)) {
		int_T iTs;
		if (mxIsComplex(SYMBOL_PERIOD)) {
		  THROW_ERROR(S, "Symbol period parameter needs to be a real value.");
		}
		for (iTs = 0; iTs < mxGetNumberOfElements(SYMBOL_PERIOD); iTs++) {
		  if (mxGetPr(SYMBOL_PERIOD)[iTs] < 0.0) {
			THROW_ERROR(S, "Symbol period parameter needs to be a positive value.");
		  }
		}
	  }
	}

    /*---Check Parameters when Eb/No mode is selected-----*/
	if (Is_EbNo_Mode) {
	  if (OK_TO_CHECK_VAR(S, EBNO_DB)) {
		if (mxIsComplex(EBNO_DB)) {
		  THROW_ERROR(S, "Signal to noise ratio parameter must be a real value.");
		}
	  }
	  if (OK_TO_CHECK_VAR(S, BITSPERSYM)) {
		if (mxIsComplex(BITSPERSYM)) {
		  THROW_ERROR(S, "Number of bits per symbol parameter must be a real value.");
		} else {
		  int_T iTs;
		  for (iTs = 0; iTs < mxGetNumberOfElements(SYMBOL_PERIOD); iTs++) {
			if (mxGetPr(BITSPERSYM)[iTs] < 0.0) {
			  THROW_ERROR(S, "Number of bits per symbol parameter must be positive.");
			}
		  }
		}
	  }
	}

    /*---Check Parameters when Es/No mode is selected-----*/
    if (Is_EsNo_Mode)
    {
        /*---Check for Es/No parameter value-----*/
        if (OK_TO_CHECK_VAR(S,ESNO_DB))
        {
            if (mxIsComplex(ESNO_DB))
            {
                THROW_ERROR(S, "Signal to noise ratio parameter needs to be a real value.");
            }
        }
    }

    /*---Check for parameter values when the SNR mode is selected---------*/
    if (Is_SNR_Mode)
    {
        /*---Check the SNR parameter value----*/
        if (OK_TO_CHECK_VAR(S,SNR_DB))
        {
            if (mxIsComplex(SNR_DB))
            {
                THROW_ERROR(S,"Signal to noise ratio parameter needs to be a real value.");
            }
        }
    }

    /*---Check for parameter values in the variance from mask mode---*/
    if (Is_MaskVar_Mode)
    {
        /*---Check the variance from mask parameter value---*/
        if (OK_TO_CHECK_VAR(S,FIELD_VARIANCE))
        {
            int_T iMvar;

            if (mxIsComplex(FIELD_VARIANCE))
            {
                THROW_ERROR(S," Variance parameter needs to be a real value.");
            }
            for (iMvar = 0; iMvar < mxGetNumberOfElements(FIELD_VARIANCE); iMvar++)
            {
                if (mxGetPr(FIELD_VARIANCE)[iMvar] < 0.0)
                {
                    THROW_ERROR(S," Variance parameter needs to be a positive value.");
                }
            }
        }
    }

    /*---Check for parameter values in the variance from port mode---*/
    if (Is_InVar_Mode)
    {
        /*---No parameter values to be check in this mode---*/
    }

/* end mdlCheckParameters */
}
#endif

/* Function: mdlInitializeSizes ===============================================*/
static void mdlInitializeSizes(SimStruct *S)
{
    int_T i;

    ssSetNumSFcnParams(S, NUM_ARGS);

#if defined(MATLAB_MEX_FILE)
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) return;
    mdlCheckParameters(S);
    if (ssGetErrorStatus(S) != NULL) return;
#endif

    ssSetNumSampleTimes(S, 1); /* Block based sample times */

    /* Inputs: */
    if (!ssSetNumInputPorts(S, NUM_INPORTS)) return;
    for(i=0; i<NUM_INPORTS; i++) {
        if(!ssSetInputPortDimensionInfo( S, i, DYNAMIC_DIMENSION)) return;
        ssSetInputPortDataType(          S, i, SS_DOUBLE);
        ssSetInputPortDirectFeedThrough( S, i, true);
        ssSetInputPortRequiredContiguous(S, i, true);
        ssSetInputPortOptimOpts(         S, i, SS_REUSABLE_AND_LOCAL);
    }

    ssSetInputPortComplexSignal(    S, INPORT_SIGNAL, COMPLEX_INHERITED);
    ssSetInputPortComplexSignal(    S, INPORT_NOISE, COMPLEX_INHERITED);
    ssSetInputPortComplexSignal(    S, INPORT_VARIANCE, COMPLEX_NO);

    ssSetInputPortFrameData(        S, INPORT_SIGNAL, FRAME_INHERITED);
    ssSetInputPortFrameData(        S, INPORT_NOISE, FRAME_NO);
    ssSetInputPortFrameData(        S, INPORT_VARIANCE, FRAME_INHERITED);

    /* Outputs: */
    if (!ssSetNumOutputPorts(S,NUM_OUTPORTS)) return;

    if(!ssSetOutputPortDimensionInfo(S, OUTPORT_SIGNAL, DYNAMIC_DIMENSION)) return;
    ssSetOutputPortDataType(         S, OUTPORT_SIGNAL, SS_DOUBLE);
    ssSetOutputPortComplexSignal(    S, OUTPORT_SIGNAL, COMPLEX_INHERITED);
    ssSetOutputPortFrameData(        S, OUTPORT_SIGNAL, FRAME_INHERITED);

    /* Specify port to be non-persistent (=>REUSABLE) */
    ssSetOutputPortOptimOpts(        S, OUTPORT_SIGNAL, SS_REUSABLE_AND_LOCAL);
    
    if (!ssSetNumDWork(S, DYNAMICALLY_SIZED)) return;

    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE |
                    SS_OPTION_WORKS_WITH_CODE_REUSE |
                    SS_OPTION_USE_TLC_WITH_ACCELERATOR |
                    SS_OPTION_SFUNCTION_INLINED_FOR_RTW |
                    SS_OPTION_CALL_TERMINATE_ON_EXIT);

    /* Parameter Tunability  - set OFF for all parameters */
    for (i = 0; i< NUM_ARGS; i++)
        ssSetSFcnParamTunable(S, i, false);
    
    /* Turn on parameter tunability depending on the mode used */
    switch(OPERATION_MODE)
    {
        case EbNo_Mode:
            ssSetSFcnParamTunable(S, EBNO_DBC, true);
            ssSetSFcnParamTunable(S, SIGNAL_POWERC, true);
            break;
        case EsNo_Mode:
            ssSetSFcnParamTunable(S, ESNO_DBC, true);
            ssSetSFcnParamTunable(S, SIGNAL_POWERC, true);
            break;
        case SNR_Mode:
            ssSetSFcnParamTunable(S, SNR_DBC, true);
            ssSetSFcnParamTunable(S, SIGNAL_POWERC, true);
            break;
        case MaskVar_Mode:
            ssSetSFcnParamTunable(S, FIELD_VARIANCEC, true);
            break;
        default:
            break;
    }
}
/* End of mdlInitializeSizes(SimStruct *S) */


/* Function: mdlInitializeSampleTimes =========================================*/
static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, FIXED_IN_MINOR_STEP_OFFSET);

    ssSetModelReferenceSampleTimeInheritanceRule(S, DISALLOW_SAMPLE_TIME_INHERITANCE);
}

/* Function: mdlInitializeConditions ========================================*/
#define MDL_INITIALIZE_CONDITIONS
static void mdlInitializeConditions(SimStruct *S)
{
    /* --- Evaluate the parameters --- */
    setNoiseStdDev(S);
}

/* Function: mdlProcessParameters ===========================================*/
#define MDL_PROCESS_PARAMETERS   /* Change to #undef to remove function */
#if defined(MDL_PROCESS_PARAMETERS) && defined(MATLAB_MEX_FILE)
static void mdlProcessParameters(SimStruct *S)
{
    /* Update the RTP (no transformations done here) */
    switch(OPERATION_MODE)
    {
        case EbNo_Mode:
            UpdateRTPDirectlyFromSFcnParam(S, EBNO_RTP_IDX);
            UpdateRTPDirectlyFromSFcnParam(S, SPOW_RTP_IDX);
            break;
        case EsNo_Mode:
            UpdateRTPDirectlyFromSFcnParam(S, ESNO_RTP_IDX);
            UpdateRTPDirectlyFromSFcnParam(S, SPOW_RTP_IDX);
            break;
        case SNR_Mode:
            UpdateRTPDirectlyFromSFcnParam(S, SNR_RTP_IDX);
            UpdateRTPDirectlyFromSFcnParam(S, SPOW_RTP_IDX);
            break;
        case MaskVar_Mode:
            UpdateRTPDirectlyFromSFcnParam(S, VAR_RTP_IDX);
            break;
        default:
            break; /* NO RTP for the InVar_Mode */
    }

    /* --- Then re-evaluate the parameters --- */
    setNoiseStdDev(S);
}
#endif /* MDL_PROCESS_PARAMETERS */

/* Function: setNoiseStdDev ===========================================*/
static void setNoiseStdDev(SimStruct *S)
{
    /* --- Re-evaluate the std based on the new parameters --- */
    real_T Ts    = ssGetSampleTime(S,0);
    real_T *std  = (real_T *)ssGetDWork(S, STD_IDX);
    int_T  i;

    const int_T  *InputDims        = ssGetInputPortDimensions(S, INPORT_SIGNAL);
    const int_T  IsFrame           = ssGetInputPortFrameData( S, INPORT_SIGNAL);
    const int_T  InPortWidth       = ssGetInputPortWidth(     S, INPORT_SIGNAL);
    const int_T  nChans            = (IsFrame) ? InputDims[1] : InPortWidth;
    const real_T NSamps            = (real_T)(InPortWidth/nChans);

	real_T EsNodB;
    int_T idxEbNodB, idxEsNodB, idxBitsPSym, idxSIGPOW, idxSYMPER, idxSNRdB, idxFVAR;

    for (i = 0; i < nChans; i++)
    {
        switch (OPERATION_MODE){
		case EbNo_Mode:
		{
            /* Dialog parameters - RTPs  and the number of elements*/
            real_T  *EbNo = (real_T *)GetRTPDataPtr(S, EBNO_RTP_IDX);
            int_T   numEbNo = GetRTPNumElements(S, EBNO_RTP_IDX);
        
            real_T  *SPow = (real_T *)GetRTPDataPtr(S, SPOW_RTP_IDX);
            int_T   numSPow = GetRTPNumElements(S, SPOW_RTP_IDX);

            idxEbNodB = (numEbNo==1) ? 0 : i;
            idxBitsPSym = (IS_SCALAR(BITSPERSYM)) ? 0 : i;
            idxSIGPOW = (numSPow==1) ? 0 : i;
  		    idxSYMPER = (IS_SCALAR(SYMBOL_PERIOD)) ? 0 : i;

            EsNodB = (real_T)( EbNo[idxEbNodB] + 10.0*log10(mxGetPr(BITSPERSYM)[idxBitsPSym]) );
    
            *std++ = sqrt(  (SPow[idxSIGPOW]* mxGetPr(SYMBOL_PERIOD)[idxSYMPER]) 
                            / ( (Ts/NSamps) * pow(10.0,(EsNodB/10.0)) )  );
        }
		break;

        case EsNo_Mode:
        {
            real_T  *EsNo = (real_T *)GetRTPDataPtr(S, ESNO_RTP_IDX);
            int_T   numEsNo = GetRTPNumElements(S, ESNO_RTP_IDX);
        
            real_T  *SPow = (real_T *)GetRTPDataPtr(S, SPOW_RTP_IDX);
            int_T   numSPow = GetRTPNumElements(S, SPOW_RTP_IDX);

            idxEsNodB = (numEsNo==1) ? 0 : i;
            idxSIGPOW = (numSPow==1) ? 0 : i;
            idxSYMPER = (IS_SCALAR(SYMBOL_PERIOD)) ? 0 : i;

            *std++ = sqrt( (SPow[idxSIGPOW] * mxGetPr(SYMBOL_PERIOD)[idxSYMPER])
                        / ( (Ts/NSamps) * pow(10.0, (EsNo[idxEsNodB]/10.0)) ) );
        }
        break;

        case SNR_Mode:
        {
            real_T  *SNR  = (real_T *)GetRTPDataPtr(S, SNR_RTP_IDX);
            int_T   numSNR  = GetRTPNumElements(S, SNR_RTP_IDX);
        
            real_T  *SPow = (real_T *)GetRTPDataPtr(S, SPOW_RTP_IDX);
            int_T   numSPow = GetRTPNumElements(S, SPOW_RTP_IDX);

            idxSNRdB =  (numSNR==1) ? 0 : i;
            idxSIGPOW = (numSPow==1) ? 0 : i;

            *std++ = sqrt( SPow[idxSIGPOW] / (pow(10.0, SNR[idxSNRdB]/10.0)) );
        }
        break;

        case MaskVar_Mode:
        {
            real_T  *VAR  = (real_T *)GetRTPDataPtr(S, VAR_RTP_IDX);
            int_T   numVar  = GetRTPNumElements(S, VAR_RTP_IDX);

            idxFVAR = (numVar==1) ? 0 : i;

            *std++ = sqrt(VAR[idxFVAR]);
        }
        break;

        default:
            *std = 0.0;
        } /* End switch */
    } /* End for loop */
} /* End function: setNoiseStdDev  */


/* Function: mdlStart =======================================================*/
#define MDL_START
static void mdlStart (SimStruct *S)
{
    int_T i;
    const int_T *InputDims        = ssGetInputPortDimensions(   S, INPORT_SIGNAL);
    const int_T IsFrame           = ssGetInputPortFrameData(    S, INPORT_SIGNAL);
    const int_T InPortWidth       = ssGetInputPortWidth(        S, INPORT_SIGNAL);
    const int_T nChans            = (IsFrame) ? InputDims[1] : InPortWidth;
    const int_T NSamps            = InPortWidth/nChans;

    /*----Check that if either SNR mode is selected, the sample time is not continuous*/
    if ((Is_EbNo_Mode || Is_EsNo_Mode || Is_SNR_Mode)
		&& (ssGetSampleTime(S, 0) == CONTINUOUS_SAMPLE_TIME))
    {
        THROW_ERROR(S,"In Signal to noise ratio mode, the block input and output "
                      "must have discrete sample times");
    }

    /*---------Check width of params in multichannel non-frame based case------------*/
    /*--Check Signal Power for modes 1, 2 & 3---*/
    if (Is_EbNo_Mode || Is_EsNo_Mode || Is_SNR_Mode)
    {
        if ((!IS_SCALAR(SIGNAL_POWER)) && (mxGetNumberOfElements(SIGNAL_POWER) != nChans))
        {
            THROW_ERROR(S,"Input Signal power parameter needs to be either a scalar value or "
                          "a vector whose length matches the number of channels of the input.");
        }
    }

	/* EbNo Mode */
	if (Is_EbNo_Mode) {
	  if ((!IS_SCALAR(EBNO_DB)) && (mxGetNumberOfElements(EBNO_DB) != nChans)) {
		THROW_ERROR(S, "Signal to noise ratio parameter needs to be either a"
					" scalar value or a vector whose length matches the "
					"number of channels of the input.");
	  }

	  if ((!IS_SCALAR(BITSPERSYM)) && (mxGetNumberOfElements(BITSPERSYM) != nChans)) {
		THROW_ERROR(S, "Bits per symbol parameter needs to be either a"
					" scalar value or a vector whose length matches the "
					"number of channels of the input.");
	  }

      if ((!IS_SCALAR(SYMBOL_PERIOD)) && (mxGetNumberOfElements(SYMBOL_PERIOD) != nChans)) {
		THROW_ERROR(S,"Symbol Period parameter needs to be either a scalar value or a "
					"vector whose length matches the number of channels of the input.");
	  }
	}

    /*----EsNo_Mode----*/
    if (Is_EsNo_Mode)
    {
        if ((!IS_SCALAR(ESNO_DB)) && (mxGetNumberOfElements(ESNO_DB) != nChans))
        {
            THROW_ERROR(S,"Signal to noise ratio parameter needs to be either a"
                          " scalar value or a vector whose length matches the "
                          "number of channels of the input.");
        }
        if ((!IS_SCALAR(SYMBOL_PERIOD)) && (mxGetNumberOfElements(SYMBOL_PERIOD) != nChans))
        {
            THROW_ERROR(S,"Symbol Period parameter needs to be either a scalar value or a "
                          "vector whose length matches the number of channels of the input.");
        }
    }

    /*---SNR_Mode---*/
    if (Is_SNR_Mode)
    {
        if ((!IS_SCALAR(SNR_DB)) && (mxGetNumberOfElements(SNR_DB) != nChans))
        {
            THROW_ERROR(S,"Signal to noise ratio parameter needs to be either a"
                          " scalar value or a vector whose length matches the "
                          "number of channels of the input.");
        }
    }
    /*----MaskVar_Mode----*/
    if (Is_MaskVar_Mode)
    {
        if ((!IS_SCALAR(FIELD_VARIANCE)) && (mxGetNumberOfElements(FIELD_VARIANCE) != nChans))
        {
            THROW_ERROR(S,"Variance parameter needs to be either a scalar value"
                          " or a vector whose length matches the number of channels"
                          " of the input.");
        }
    }

    /*-----------Check to see if Symbol time does not exceed sample time------------*/
    if ((Is_EbNo_Mode || Is_EsNo_Mode) && (ssGetSimMode(S) != SS_SIMMODE_SIZES_CALL_ONLY))
    {
        if (!IS_SCALAR(SYMBOL_PERIOD))
        {
            for ( i = 0; i < nChans; i++)
            {
                real32_T  symT = (real32_T)mxGetPr(SYMBOL_PERIOD)[i];
                real32_T sampT = (real32_T)(ssGetSampleTime(S, 0)/NSamps);
                if (symT < sampT)
                {
                    THROW_ERROR(S,"The Symbol period parameter value must exceed "
                                  "the inherited sample time of the block");
                }
            }
        }
        else
        {
            real32_T  symT = (real32_T)mxGetPr(SYMBOL_PERIOD)[0];
            real32_T sampT = (real32_T)(ssGetSampleTime(S, 0)/NSamps);
            if (symT < sampT)
            {
                THROW_ERROR(S,"The Symbol period parameter value should exceed "
                              "the inherited sample time of the block");
            }
        }
    }
}

/* Function: mdlOutputs =======================================================*/
static void mdlOutputs(SimStruct *S, int_T tid)
{
    real_T sqrtVar;
    const int_T     *InputDims      = ssGetInputPortDimensions(S, INPORT_SIGNAL);
    const int_T     IsFrame         = ssGetInputPortFrameData( S, INPORT_SIGNAL);
    const int_T     InPortWidth     = ssGetInputPortWidth(     S, INPORT_SIGNAL);
    const int_T     InPortVarWidth  = ssGetInputPortWidth(     S, INPORT_VARIANCE);
    const int_T     nChans          = (IsFrame) ? InputDims[1] : InPortWidth;
    const boolean_T cplx            = (ssGetInputPortComplexSignal(S, INPORT_SIGNAL) == COMPLEX_YES);
    const int_T     NSamps          = InPortWidth/nChans;

    real_T *workStd  = (real_T *)ssGetDWork(S, STD_IDX);

    const real_T *var = ssGetInputPortRealSignal(S, INPORT_VARIANCE);

    if (!cplx) { /* Real Gaussian Noise Channel*/
        int_T  i, j;
        const real_T *noise   = ssGetInputPortRealSignal( S, INPORT_NOISE);
        const real_T *uptr    = ssGetInputPortRealSignal( S, INPORT_SIGNAL);
              real_T *y       = ssGetOutputPortRealSignal(S, OUTPORT_SIGNAL);

        switch(OPERATION_MODE){
		    case EbNo_Mode:
            case EsNo_Mode:
                for (i = 0; i < nChans; i++)
                {
                    for (j = 0; j < NSamps; j++)
                    {
                        *y++ = (*uptr++) + (*workStd)*(*noise++)/sqrt(2);
                    }
                    workStd++;
                }
                break;

            case SNR_Mode:
			case MaskVar_Mode:
                for (i = 0; i < nChans; i++)
                {
                    for (j = 0; j < NSamps; j++)
                    {
                        *y++ = (*uptr++) + (*workStd)*(*noise++);
                    }
                    workStd++;
                }
                break;

            case InVar_Mode:
                for (i = 0; i < nChans; i++)
                {
#ifdef MATLAB_MEX_FILE
                    if (var[i] < 0.0)
                    {
                        THROW_ERROR(S,"Variance value must be positive.");
                    }
#endif
                    if (InPortVarWidth != 1)
                        sqrtVar = sqrt(var[i]);
                    else
                        sqrtVar = sqrt(var[0]);

                    for (j = 0; j < NSamps; j++)
                    {
                        *y++ = (*uptr++) + (sqrtVar)*(*noise++);
                    }
                }
                break;

            default:
                THROW_ERROR(S, "Invalid mode of operation.");
        } /* End Switch */
    }
    else { /* Complex Gaussian Noise Channel */
        int_T  i, j;
        const creal_T      *noisec = (creal_T *)ssGetInputPortSignal(S, INPORT_NOISE);
        const creal_T      *uptr   = (creal_T *)ssGetInputPortSignal(S, INPORT_SIGNAL);
              creal_T      *y      = (creal_T *)ssGetOutputPortSignal(S, OUTPORT_SIGNAL);

        switch(OPERATION_MODE){
		    case EbNo_Mode:
            case EsNo_Mode:
			case SNR_Mode:
			case MaskVar_Mode:
                for (i = 0; i < nChans; i++)
                {
                    for (j = 0; j < NSamps; j++)
                    {
                        (y)->re = (uptr->re) + (*workStd)*(noisec->re); 
                        (y)->im = (uptr->im) + (*workStd)*(noisec->im);
                        y++;
                        uptr++;
                        noisec++;
                    }
                    workStd++;
                }
                break;
            case InVar_Mode:
                for (i = 0; i < nChans; i++)
                {
#ifdef MATLAB_MEX_FILE
                    if (var[i] < 0.0)
                    {
                        THROW_ERROR(S,"Variance value must be positive.");
                    }
#endif
                    if (InPortVarWidth != 1)
                        sqrtVar = sqrt(var[i]);
                    else
                        sqrtVar = sqrt(var[0]);

                    for (j = 0; j < NSamps ; j++)
                    {
                        (y)->re = (uptr->re) + (sqrtVar)*(noisec->re);
                        (y)->im = (uptr->im) + (sqrtVar)*(noisec->im);
                        y++;
                        uptr++;
                        noisec++;
                    }
                }
                break;
            default:
                THROW_ERROR(S, "Invalid mode of operation.");
        } /* End Switch */
    }
}

/* Function: mdlSetWorkWidths ===============================================*/
#ifdef MATLAB_MEX_FILE
#define MDL_SET_WORK_WIDTHS
static void mdlSetWorkWidths(SimStruct *S)
{
    const int_T *InputDims    = ssGetInputPortDimensions(S, INPORT_SIGNAL);
    const int_T InPortWidth   = ssGetInputPortWidth(S,INPORT_SIGNAL);
    const int_T IsFrame       = ssGetInputPortFrameData(S, INPORT_SIGNAL);
    const int_T nChans        = (IsFrame) ? InputDims[1] : InPortWidth;

    ssSetNumDWork(S, NUM_DWORK);

    ssSetDWorkName(         S, STD_IDX, "STDDEV");
    ssSetDWorkWidth(        S, STD_IDX, nChans);
    ssSetDWorkDataType(     S, STD_IDX, SS_DOUBLE);
    ssSetDWorkComplexSignal(S, STD_IDX, COMPLEX_NO);

    /* Create the RT parameters - based on which ones are required in a mode */
    switch(OPERATION_MODE){
    case EbNo_Mode:
        /* Allocate the Run-time parameters*/
        if (!ssSetNumRunTimeParams(S, 2)) {
            THROW_ERROR(S, "Run-time parameter allocation failed.");
        }

        /* EBNO and SPow*/
        CreateRTPDirectlyFromSFcnParam(S, EBNO_DBC, EBNO_RTP_IDX, "EBNO", 
                                          SS_DOUBLE, COMPLEX_NO);
        CreateRTPDirectlyFromSFcnParam(S, SIGNAL_POWERC, SPOW_RTP_IDX, "SPOW", 
                                          SS_DOUBLE, COMPLEX_NO);
        break;
    case EsNo_Mode:
        /* Allocate the Run-time parameters*/
        if (!ssSetNumRunTimeParams(S, 2)) {
            THROW_ERROR(S, "Run-time parameter allocation failed.");
        }

        /* ESNO and SPow */
        CreateRTPDirectlyFromSFcnParam(S, ESNO_DBC, ESNO_RTP_IDX, "ESNO", 
                                          SS_DOUBLE, COMPLEX_NO);
        CreateRTPDirectlyFromSFcnParam(S, SIGNAL_POWERC, SPOW_RTP_IDX, "SPOW", 
                                          SS_DOUBLE, COMPLEX_NO);
        break;

    case SNR_Mode:
        /* Allocate the Run-time parameters*/
        if (!ssSetNumRunTimeParams(S, 2)) {
            THROW_ERROR(S, "Run-time parameter allocation failed.");
        }

        /* SNR and SPow*/
        CreateRTPDirectlyFromSFcnParam(S, SNR_DBC, SNR_RTP_IDX, "SNR", 
                                          SS_DOUBLE, COMPLEX_NO);
        CreateRTPDirectlyFromSFcnParam(S, SIGNAL_POWERC, SPOW_RTP_IDX, "SPOW", 
                                          SS_DOUBLE, COMPLEX_NO);
        break;

    case MaskVar_Mode:
        /* Allocate the Run-time parameters*/
        if (!ssSetNumRunTimeParams(S, 1)) {
            THROW_ERROR(S, "Run-time parameter allocation failed.");
        }

        /* MaskVar*/
        CreateRTPDirectlyFromSFcnParam(S, FIELD_VARIANCEC, VAR_RTP_IDX, "VAR", 
                                          SS_DOUBLE, COMPLEX_NO);
        break;
    default:
        break; /* NO RTP for the InVar_Mode */
    }

    RETURN_IF_ERROR(S);
}
#endif

/* Function: mdlTerminate ===============================================*/
static void mdlTerminate(SimStruct *S)
{
        ParamRecFreeAll(S);
}

#ifdef  MATLAB_MEX_FILE
/* Function: mdlSetInputPortComplexSignal============================================*/
#define MDL_SET_INPUT_PORT_COMPLEX_SIGNAL
static void mdlSetInputPortComplexSignal(SimStruct *S, int_T portIdx,
                                         int_T InputPortComplexSignal)
{
    switch(portIdx){
        case INPORT_SIGNAL:
            if (ssGetOutputPortComplexSignal(S,OUTPORT_SIGNAL) != DYNAMICALLY_SIZED)
            {
                THROW_ERROR(S,"The input and output signals must have the same complexity.");
            }

            ssSetInputPortComplexSignal( S, INPORT_SIGNAL, InputPortComplexSignal);
            ssSetInputPortComplexSignal( S, INPORT_NOISE, InputPortComplexSignal);
            ssSetOutputPortComplexSignal(S, OUTPORT_SIGNAL, InputPortComplexSignal);
            break;

        case INPORT_NOISE:

            ssSetInputPortComplexSignal(S, INPORT_NOISE, InputPortComplexSignal);

            if (ssGetInputPortComplexSignal(S,INPORT_NOISE) != ssGetInputPortComplexSignal(S,INPORT_SIGNAL))
            {
                THROW_ERROR(S,"The complexity of the noise signal must be the same as the input signal");
            }
            break;

        default:
            THROW_ERROR(S,"Invalid port index for complex propagation.");
    } /* End Switch */
}

/* Function: mdlSetOutputPortComplexSignal============================================*/
#define MDL_SET_OUTPUT_PORT_COMPLEX_SIGNAL
static void mdlSetOutputPortComplexSignal(SimStruct *S, int_T portIdx,
                                          int_T OutputPortComplexSignal)
{
    if (portIdx != OUTPORT_SIGNAL)
    {
        THROW_ERROR(S,"Invalid port index for complex propagation.");
    }

    if (ssGetInputPortComplexSignal(S,INPORT_SIGNAL) != DYNAMICALLY_SIZED)
    {
        THROW_ERROR(S,"The input and output signal must have the same complexity.");
    }

    ssSetOutputPortComplexSignal(S, OUTPORT_SIGNAL, OutputPortComplexSignal);
    ssSetInputPortComplexSignal( S, INPORT_SIGNAL, OutputPortComplexSignal);
    ssSetInputPortComplexSignal( S, INPORT_NOISE, OutputPortComplexSignal);
}

/* Function: mdlSetInputPortDimensionInfo============================================*/
#define MDL_SET_INPUT_PORT_DIMENSION_INFO
static void mdlSetInputPortDimensionInfo(SimStruct *S, int_T portIdx,
                                         const DimsInfo_T *dimsInfo)
{
    int_T       inRows, inCols, nChans, nSamps;
    const int_T IsFrame         = ssGetInputPortFrameData(S, INPORT_SIGNAL);
    const int_T IsVarFrame      = ssGetInputPortFrameData(S, INPORT_VARIANCE);

    if(!ssSetInputPortDimensionInfo(S, portIdx, dimsInfo)) return;

    if(ssGetInputPortConnected(S, INPORT_SIGNAL)) {

    {
    const int_T InPortWidth       = ssGetInputPortWidth(        S, INPORT_SIGNAL);
    const int_T InVarWidth        = ssGetInputPortWidth(        S, INPORT_VARIANCE);
    const int_T *InputVarDims     = ssGetInputPortDimensions(   S, INPORT_VARIANCE);
    const int_T numVarDims        = ssGetInputPortNumDimensions(S, INPORT_VARIANCE);
    const int_T numDims           = ssGetInputPortNumDimensions(S, INPORT_SIGNAL);

    switch(portIdx){
    case INPORT_SIGNAL:
    {
        inRows            = dimsInfo->dims[0];
        if(numDims==2){
            inCols        = dimsInfo->dims[1];
        }
        nChans            = (IsFrame) ? inCols : InPortWidth;
        nSamps            = InPortWidth/nChans;

        if(numDims>2){
            THROW_ERROR(S, "Input must be 1-D or 2-D.");
        }

        if(!IsFrame && numDims==2 && inRows!=1 && inCols!=1){
            THROW_ERROR(S,"Matrix input not allowed in sample-based operation.");
        }

        if(ssGetInputPortWidth(S, INPORT_NOISE)==DYNAMICALLY_SIZED)
        {
            if(!ssSetInputPortMatrixDimensions(S, INPORT_NOISE, nSamps, nChans)) return;
        }
        else { /* check to ensure that inport_noise is set properly */
            const int_T *InputNoiseDims = ssGetInputPortDimensions(S, INPORT_NOISE);
            if(nSamps!=InputNoiseDims[0] || nChans!=InputNoiseDims[1]){
                THROW_ERROR(S, "Port width propagation failed.");
            }
        }

        if(ssGetInputPortWidth(S, INPORT_VARIANCE)==DYNAMICALLY_SIZED)
        {
            if (Is_InVar_Mode) {
                /* DO NOTHING - WANT TO ALLOW SCALAR OR VECTOR OF LENGTH nChans */
            }
            else {
                if(numDims==1){
                    if(!ssSetInputPortVectorDimension(S, INPORT_VARIANCE, nChans)) return;
                }
                else { /* numDims!=1 */
                    if(!ssSetInputPortMatrixDimensions(S, INPORT_VARIANCE, 1, nChans)) return;
                };
            }
         }
         else { /* variance port was hit first - check to ensure proper settings */

            /* Variance must be sample-based if input is sample-based */
            if(IsVarFrame && !IsFrame){
                THROW_ERROR(S,"Input must be frame-based if variance is frame-based.");
            }

            if (Is_InVar_Mode){
                /* Unless input is sample-based and variance is frame-based,
                scalar variance always accepted */
                if(InVarWidth!=1) {

                    /* Make sure that variance isn't column vector with dimensions
                    [nChansx1] if input is frame-based */
                    if(IsVarFrame && nChans!=InputVarDims[1]) {
                        THROW_ERROR(S, "Variance must be scalar or row vector with"
                                       " length equal to number of input channels"
                                       " if input and variance are each frame-based.");
                    }

                    /* Make sure that variance is scalar or vector with width equal
                    to nChans */
                    if ((InVarWidth != nChans)) {
                        THROW_ERROR(S,"The size of the input variance vector must"
                                      " either be '1' or must match the number of"
                                      " channels.");
                    }

                    if(numVarDims==2){
                        /* Make sure that variance is not a matrix with width
                        equal to nChans */
                        if(InputVarDims[0]!=1 && InputVarDims[1]!=1){
                            THROW_ERROR(S,"Variance must be scalar or vector with length"
                                          " equal to number of input channels.");
                        }
                    }
                } /* InVarWidth!=1 */
            } /* Is_InVar_Mode */
            else{ /* !Is_InVar_Mode */

                if(numDims==1){
                    if(InputVarDims[0]!=nChans){
                        THROW_ERROR(S, "Port width propagation failed");
                    }
                }
                else { /* numDims!=1 */
                    if(InputVarDims[0]!=1 || InputVarDims[1]!=nChans){
                        THROW_ERROR(S, "Port width propagation failed");
                    }
                }
            }
        }

        if(ssGetOutputPortWidth(S, OUTPORT_SIGNAL)==DYNAMICALLY_SIZED)
        {
            /* OUTPORT_SIGNAL matches dimensions of input */
            if(numDims==1){
                if(!ssSetOutputPortVectorDimension(S, OUTPORT_SIGNAL, inRows)) return;
            }
            else { /* numDims!=1 */
                if(!ssSetOutputPortMatrixDimensions(S, OUTPORT_SIGNAL, inRows, inCols)) return;
            }
        }
        else { /* check to ensure that outport_signal is set properly */
            const int_T *OutputDims = ssGetOutputPortDimensions(S, OUTPORT_SIGNAL);
            if(inRows!=OutputDims[0] || inCols!=OutputDims[1]){
                THROW_ERROR(S, "Port width propagation failed.");
            }
        }

        break;
    }
    case INPORT_NOISE:
        /* don't try to set other ports */
        break;

    case INPORT_VARIANCE:
        /* don't try to set other ports */
        /* If input port hit first, make sure that settings of variance port are correct */
        if(ssGetInputPortWidth(S,INPORT_SIGNAL)!=DYNAMICALLY_SIZED){
            const int_T *InputDims = ssGetInputPortDimensions(   S, INPORT_SIGNAL);
            inRows = InputDims[0];
            if(numDims==2){
                inCols = InputDims[1];
            }
            nChans = (IsFrame) ? inCols : InPortWidth;
            nSamps = InPortWidth/nChans;

            /* Variance must be sample-based if input is sample-based */
            if(IsVarFrame && !IsFrame){
                THROW_ERROR(S,"Input must be frame-based if variance is frame-based.");
            }

            if (Is_InVar_Mode){
                /* Unless input is sample-based and variance is frame-based,
                scalar variance always accepted */
                if(InVarWidth!=1) {

                    /* Make sure that variance isn't column vector with dimensions
                    [nChansx1] if input is frame-based */
                    if(IsVarFrame && nChans!=InputVarDims[1]) {
                        THROW_ERROR(S, "Variance must be scalar or row vector with"
                                       " length equal to number of input channels"
                                       " if input and variance are each frame-based.");
                    }

                    /* Make sure that variance is scalar or vector with width equal
                    to nChans */
                    if ((InVarWidth != nChans)) {
                        THROW_ERROR(S,"The size of the input variance vector must"
                                      " either be '1' or must match the number of"
                                      " channels.");
                    }

                    if(numVarDims==2){
                        /* Make sure that variance is not a matrix with width
                        equal to nChans */
                        if(InputVarDims[0]!=1 && InputVarDims[1]!=1){
                            THROW_ERROR(S,"Variance must be scalar or vector with length"
                                          " equal to number of input channels.");
                        }
                    }
                } /* InVarWidth!=1 */
            } /* Is_InVar_Mode */
            else{ /* !Is_InVar_Mode */

                if(numDims==1){
                    if(InputVarDims[0]!=nChans){
                        THROW_ERROR(S, "Port width propagation failed");
                    }
                }
                else { /* numDims!=1 */
                    if(InputVarDims[0]!=1 || InputVarDims[1]!=nChans){
                        THROW_ERROR(S, "Port width propagation failed");
                    }
                }
            }
        }
        break;

    default:
        THROW_ERROR(S,"Invalid port index.");
    } /* End of switch */

    }
    }
}

/* Function: mdlSetOutputPortDimensionInfo============================================*/
#define MDL_SET_OUTPUT_PORT_DIMENSION_INFO
static void mdlSetOutputPortDimensionInfo(SimStruct *S, int_T portIdx,
                                          const DimsInfo_T *dimsInfo)
{
    int_T       outRows, outCols, nChans, nSamps;
    const int_T IsFrame         = ssGetInputPortFrameData(S, INPORT_SIGNAL);

    if(!ssSetOutputPortDimensionInfo(S, portIdx, dimsInfo)) return;

    if(ssGetOutputPortConnected(S, OUTPORT_SIGNAL)) {

    if (portIdx == OUTPORT_SIGNAL){
        const int_T OutPortWidth = ssGetOutputPortWidth(        S, OUTPORT_SIGNAL);
        const int_T numDims      = ssGetOutputPortNumDimensions(S, OUTPORT_SIGNAL);
        outRows = dimsInfo->dims[0];
        if(numDims==2){
            outCols = dimsInfo->dims[1];
        }
        nChans = (IsFrame) ? outCols : OutPortWidth;
        nSamps = OutPortWidth/nChans;

        if(numDims>2){
            THROW_ERROR(S, "Input must be 1-D or 2-D.");
        }

        if(!IsFrame && outRows!=1 && numDims==2 && outCols!=1){
            THROW_ERROR(S,"Matrix input not allowed in sample-based operation.");
        }

        if(ssGetInputPortWidth(S, INPORT_SIGNAL)==DYNAMICALLY_SIZED)
        {
        /* OUTPORT_SIGNAL matches dimensions of input */
            if(numDims==1){
                if(!ssSetInputPortVectorDimension(S, INPORT_SIGNAL, outRows)) return;
            }
            else { /* numDims!=1 */
                if(!ssSetInputPortMatrixDimensions(S, INPORT_SIGNAL, outRows, outCols)) return;
            }
        }
        else{ /* Check to see if input port is set correctly*/
            const int_T *InputDims = ssGetOutputPortDimensions(S, OUTPORT_SIGNAL);
            if(outRows!=InputDims[0] || outCols!=InputDims[1]){
                THROW_ERROR(S, "Port width propagation failed.");
            }
        }

        if(ssGetInputPortWidth(S, INPORT_NOISE)==DYNAMICALLY_SIZED)
        {
            if(!ssSetInputPortMatrixDimensions(S, INPORT_NOISE, nSamps, nChans)) return;
        }

        if(ssGetInputPortWidth(S, INPORT_VARIANCE)==DYNAMICALLY_SIZED)
        {
            if (Is_InVar_Mode) {
                /* DO NOTHING - WANT TO ALLOW SCALAR OR VECTOR OF LENGTH nChans*/
            }
            else {
                if(!ssSetInputPortVectorDimension(S, INPORT_VARIANCE, nChans)) return;
            }
        }

        else { /* variance port was hit first - check to ensure proper settings */
            const int_T IsVarFrame     = ssGetInputPortFrameData(    S, INPORT_VARIANCE);
            const int_T *InputVarDims  = ssGetInputPortDimensions(   S, INPORT_VARIANCE);
            const int_T numVarDims     = ssGetInputPortNumDimensions(S, INPORT_VARIANCE);
            const int_T InVarWidth     = ssGetInputPortWidth(        S, INPORT_VARIANCE);
            const int_T InPortWidth    = ssGetInputPortWidth(        S, INPORT_SIGNAL);

            /* Variance must be sample-based if input is sample-based */
            if(IsVarFrame && !IsFrame){
                THROW_ERROR(S,"Input must be frame-based if variance is frame-based.");
            }

            if (Is_InVar_Mode){
                /* Unless input is sample-based and variance is frame-based,
                scalar variance always accepted */
                if(InVarWidth!=1) {

                    /* Make sure that variance isn't column vector with dimensions
                    [nChansx1] if input is frame-based */
                    if(IsVarFrame && nChans!=InputVarDims[1]) {
                        THROW_ERROR(S, "Variance must be scalar or row vector with"
                                       " length equal to number of input channels"
                                       " if input and variance are each frame-based.");
                    }

                    /* Make sure that variance is scalar or vector with width equal
                    to nChans */
                    if ((InVarWidth != nChans)) {
                        THROW_ERROR(S,"The size of the input variance vector must"
                                      " either be '1' or must match the number of"
                                      " channels.");
                    }

                    if(numVarDims==2){
                        /* Make sure that variance is not a matrix with width
                        equal to nChans */
                        if(InputVarDims[0]!=1 && InputVarDims[1]!=1){
                            THROW_ERROR(S,"Variance must be scalar or vector with length"
                                          " equal to number of input channels.");
                        }
                    }
                } /* InVarWidth!=1 */
            } /* Is_InVar_Mode */
            else{ /* !Is_InVar_Mode */
                if(numDims==1){
                    if(InputVarDims[0]!=nChans){
                        THROW_ERROR(S, "Port width propagation failed");
                    }
                }
                else { /* numDims!=1 */
                    if(InputVarDims[0]!=1 || InputVarDims[1]!=nChans){
                        THROW_ERROR(S, "Port width propagation failed");
                    }
                }
            }
        }
    }
    else { /* portIdx!=OUTPORT_SIGNAL */
        THROW_ERROR(S,"Invalid port index for width propagation.");
    }

    }
}

/* Function: mdlSetInputPortFrameData============================================*/
#define MDL_SET_INPUT_PORT_FRAME_DATA
static void mdlSetInputPortFrameData(SimStruct *S, int_T port,
                                     Frame_T frameData)
{
    ssSetInputPortFrameData(S, port, frameData);
    if(port == INPORT_SIGNAL) {
        ssSetOutputPortFrameData(S, OUTPORT_SIGNAL, frameData);
    }
}

#endif /* Matches #ifdef for Function: mdlSetInputPortComplexSignal */

#define MDL_RTW
static void mdlRTW(SimStruct *S)
{
    int_T numBitsPerSym, numSymPeriod;
    
    const uint8_T mode        = (uint8_T)(mxGetPr(MODE)[0]);
    const real_T *bitsPerSym  = (real_T *)mxGetPr(BITSPERSYM); 
    const real_T *symPeriod   = (real_T *)mxGetPr(SYMBOL_PERIOD); 

    /* Determine the length of the parameters */
    const int_T     InPortWidth = ssGetInputPortWidth(S, INPORT_SIGNAL);
    const boolean_T IsFrame     = (ssGetInputPortFrameData(S, INPORT_SIGNAL) == 1);
    const int_T     *InputDims  = ssGetInputPortDimensions(S, INPORT_SIGNAL);
    const int_T     nChans      = (IsFrame) ? InputDims[1] : InPortWidth;

    numBitsPerSym = (IS_SCALAR(BITSPERSYM)) ? 1 : nChans;
    numSymPeriod  = (IS_SCALAR(SYMBOL_PERIOD)) ? 1 : nChans;
    
    switch(OPERATION_MODE)
    {
        case EbNo_Mode:
            if (!ssWriteRTWParamSettings(S, 3,
                
                 /* Mode - popup */
                 SSWRITE_VALUE_DTYPE_NUM, "mode", &mode, DTINFO(SS_UINT8, COMPLEX_NO),
                 /* BitsPerSymbol */
                 SSWRITE_VALUE_DTYPE_VECT, "bitspersymbol", bitsPerSym, 
                 numBitsPerSym, DTINFO(SS_DOUBLE, COMPLEX_NO),
                 /* SymbolPeriod */
                 SSWRITE_VALUE_DTYPE_VECT, "symbolperiod", symPeriod,
                 numSymPeriod, DTINFO(SS_DOUBLE, COMPLEX_NO)
               ) ) { 
                return;
            }            
            break;
        case EsNo_Mode:
            if (!ssWriteRTWParamSettings(S, 2,
                
                 /* Mode - popup */
                 SSWRITE_VALUE_DTYPE_NUM, "mode", &mode, DTINFO(SS_UINT8, COMPLEX_NO),
                         
                 /* SymbolPeriod */
                 SSWRITE_VALUE_DTYPE_VECT, "symbolperiod", symPeriod,
                 numSymPeriod, DTINFO(SS_DOUBLE, COMPLEX_NO)
               ) ) { 
                return;
            }            
            break;
        case SNR_Mode:
        case MaskVar_Mode:
        case InVar_Mode:
            if (!ssWriteRTWParamSettings(S, 1,
                 /* Mode - popup */
                 SSWRITE_VALUE_DTYPE_NUM, "mode", &mode, DTINFO(SS_UINT8, COMPLEX_NO)
               ) ) { 
                return;
            }            
            break;
        default:
            break;
    }
}
 
#ifdef  MATLAB_MEX_FILE
#include "simulink.c"
#else
#include "cg_sfun.h"
#endif
