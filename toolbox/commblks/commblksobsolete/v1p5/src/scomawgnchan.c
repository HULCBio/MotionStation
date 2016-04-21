/*
* SCOMAWGNCHAN Communications Toolbox S-Function for additive white
* gaussian noise channel. Used in combination with Simulink
* built-in gaussian noise source.
*
* $Revision: 1.1.6.1 $  $Date: 2003/01/26 18:45:11 $
*  Copyright 1996-2002 The MathWorks, Inc.
*/

#define S_FUNCTION_NAME scomawgnchan
#define S_FUNCTION_LEVEL 2

#define DATA_TYPES_IMPLEMENTED

#include "simstruc.h"
#include "comm_defs.h"

enum {INPORT_SIGNAL=0, INPORT_NOISE, INPORT_VARIANCE, NUM_INPORTS};
enum {OUTPORT_SIGNAL=0, NUM_OUTPORTS};
enum {MODEC=0, ESNO_DBC, SNR_DBC, SIGNAL_POWERC, SYMBOL_PERIODC, FIELD_VARIANCEC, FRAME_BASEDC, NO_OF_CHANNELSC, NUM_ARGS};
enum {STD = 0, NUM_DWORK};

#define MODE			(ssGetSFcnParam(S,MODEC))
#define ESNO_DB			(ssGetSFcnParam(S,ESNO_DBC))
#define SNR_DB			(ssGetSFcnParam(S,SNR_DBC))
#define SIGNAL_POWER    (ssGetSFcnParam(S,SIGNAL_POWERC))
#define SYMBOL_PERIOD   (ssGetSFcnParam(S,SYMBOL_PERIODC))
#define FIELD_VARIANCE  (ssGetSFcnParam(S,FIELD_VARIANCEC))
#define FRAME_BASED		(ssGetSFcnParam(S,FRAME_BASEDC))
#define NO_OF_CHANNELS	(ssGetSFcnParam(S,NO_OF_CHANNELSC))


/* --- Function prototypes --- */
static void setNoiseStdDev(SimStruct *S);


/* Function: mdlCheckParameters ===============================================*/
#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S)
{
	const int_T ModeOfOperation =   (int_T)mxGetPr(MODE)[0];
	const int_T IsInputFrameBased = (int_T)mxGetPr(FRAME_BASED)[0];



	/*---Check for Frame_Based parameter vlaue---*/
	if (!IS_FLINT_IN_RANGE(FRAME_BASED,0,1))
	{
		THROW_ERROR(S,"Frame-based inputs parameter value needs to be either 0(Non Frame-based) or 1(Frame-based)");
	}

	/*---Check the mode Parameter-----------*/
	if (!IS_FLINT_IN_RANGE(MODE,1,4))
	{
		THROW_ERROR(S,"Mode parameter is outside of expected range.");
	}

		/*---Check for No. of Channels parameter---*/
	if ((OK_TO_CHECK_VAR(S,NO_OF_CHANNELS)) && (IsInputFrameBased == 1) && (!IS_FLINT_GE(NO_OF_CHANNELS,1)))
	{
		THROW_ERROR(S,"Number of channels parameter must be a scalar positive real integer value");
	}

	/*---Check for Signal Power parameter in both modes 1 & 2----*/
	if ((ModeOfOperation == 1) || (ModeOfOperation == 2))
	{
		if (OK_TO_CHECK_VAR(S,SIGNAL_POWER))
		{
			int_T iPsp;

			if (mxIsComplex(SIGNAL_POWER))
			{
				THROW_ERROR(S," Input signal power parameter needs to be a real value.");
			}
			for (iPsp = 0; iPsp < mxGetNumberOfElements(SIGNAL_POWER); iPsp++)
			{
				if (mxGetPr(SIGNAL_POWER)[iPsp] < 0.0)
				{
					THROW_ERROR(S," Input signal power parameter needs to be a positive value.");
				}
			}
		}
	}

	/*---Check Parameters when Es/No mode is selected-----*/
	if (ModeOfOperation == 1)
	{
		/*---Check for Es/No parameter value-----*/
		if (OK_TO_CHECK_VAR(S,ESNO_DB))
		{
			if (mxIsComplex(ESNO_DB))
			{
				THROW_ERROR(S,"Signal to noise ratio parameter needs to be a real value.");
			}
		}
		/*---Check the Symbol Time parameter value-----*/
		if (OK_TO_CHECK_VAR(S,SYMBOL_PERIOD))
		{
			int_T iTs;

			if (mxIsComplex(SYMBOL_PERIOD))
			{
				THROW_ERROR(S," Symbol period parameter needs to be a real value.");
			}
			for (iTs = 0; iTs < mxGetNumberOfElements(SYMBOL_PERIOD); iTs++)
			{
				if (mxGetPr(SYMBOL_PERIOD)[iTs] < 0.0)
				{
					THROW_ERROR(S," Symbol period parameter needs to be a positive value.");
				}
			}
		}
	}

	/*---Check for parameter values when the SNR mode is selected---------*/
	if (ModeOfOperation == 2)
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
	if (ModeOfOperation == 3)
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
	if (ModeOfOperation == 4)
	{
		/*---No parameter values to be check in this mode---*/
	}

/* end mdlCheckParameters */
}
#endif


/* Function: mdlInitializeSizes ===============================================*/

static void mdlInitializeSizes(SimStruct *S)
{

	ssSetNumSFcnParams(S, NUM_ARGS);

#if defined(MATLAB_MEX_FILE)
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) return;
    mdlCheckParameters(S);
    if (ssGetErrorStatus(S) != NULL) return;
#endif

    if (!ssSetNumInputPorts(S, NUM_INPORTS)) return;

	ssSetNumSampleTimes(S, 1);

    ssSetInputPortWidth(            S, INPORT_SIGNAL, DYNAMICALLY_SIZED);
    ssSetInputPortDirectFeedThrough(S, INPORT_SIGNAL, 1);
    ssSetInputPortComplexSignal(    S, INPORT_SIGNAL, COMPLEX_INHERITED);
	ssSetInputPortReusable(		    S, INPORT_SIGNAL, 0);


    ssSetInputPortWidth(            S, INPORT_NOISE, DYNAMICALLY_SIZED);
    ssSetInputPortDirectFeedThrough(S, INPORT_NOISE, 1);
    ssSetInputPortComplexSignal(    S, INPORT_NOISE, COMPLEX_INHERITED);
	ssSetInputPortReusable(		    S, INPORT_NOISE, 0);

    ssSetInputPortWidth(            S, INPORT_VARIANCE, DYNAMICALLY_SIZED);
    ssSetInputPortDirectFeedThrough(S, INPORT_VARIANCE, 1);
    ssSetInputPortComplexSignal(    S, INPORT_VARIANCE, COMPLEX_NO);
	ssSetInputPortReusable(		    S, INPORT_VARIANCE, 0);

    /* Outputs: */

	if (!ssSetNumOutputPorts(S,NUM_OUTPORTS)) return;

    ssSetOutputPortWidth(        S, OUTPORT_SIGNAL, DYNAMICALLY_SIZED);
    ssSetOutputPortComplexSignal(S, OUTPORT_SIGNAL, COMPLEX_INHERITED);
	ssSetOutputPortReusable(	 S, OUTPORT_SIGNAL, 0);

	if (!ssSetNumDWork(S, DYNAMICALLY_SIZED)) return;

	ssSetOptions( S, SS_OPTION_EXCEPTION_FREE_CODE);

	ssSetSFcnParamNotTunable(S, MODEC);
	ssSetSFcnParamNotTunable(S, SYMBOL_PERIODC);
	ssSetSFcnParamNotTunable(S, FRAME_BASEDC);
	ssSetSFcnParamNotTunable(S, NO_OF_CHANNELSC);

}
 /* End of mdlInitializeSizes(SimStruct *S) */



/* Function: mdlInitializeSampleTimes =========================================*/

static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, FIXED_IN_MINOR_STEP_OFFSET);
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
	/* --- Evaluate the parameters --- */
	setNoiseStdDev(S);
}
#endif /* MDL_PROCESS_PARAMETERS */


/* Function: setNoiseStdDev ===========================================*/

static void setNoiseStdDev(SimStruct *S)
{
	/* --- Re-evaluate the std based on the new parameters --- */
	real_T Ts    = ssGetSampleTime(S,0);
	real_T *std  = (real_T *)ssGetDWork(S, STD);
	int_T  i;

	const int_T ModeOfOperation   = (int_T)mxGetPr(MODE)[0];
	const int_T IsInputFrameBased = (int_T)mxGetPr(FRAME_BASED)[0];
	const int_T InPortWidth       = ssGetInputPortWidth(S, INPORT_SIGNAL);
	const int_T nChans            = (IsInputFrameBased) ? (int_T)mxGetPr(NO_OF_CHANNELS)[0] : InPortWidth;

	const real_T      SamplesPerInputFrame  = (real_T)(InPortWidth/nChans);


	int_T idxEsNodb, idxSIGPOW, idxSYMPER, idxSNRdb, idxFVAR;

	for (i = 0; i < nChans; i++)
	{
		if (ModeOfOperation == 1)
		{
			idxEsNodb = (IS_SCALAR(ESNO_DB)) ? 0 : i;
			idxSIGPOW = (IS_SCALAR(SIGNAL_POWER)) ? 0 : i;
			idxSYMPER = (IS_SCALAR(SYMBOL_PERIOD)) ? 0 : i;

			*std++ = sqrt((mxGetPr(SIGNAL_POWER)[idxSIGPOW]*mxGetPr(SYMBOL_PERIOD)[idxSYMPER])/((Ts/SamplesPerInputFrame)*pow(10.0,(mxGetPr(ESNO_DB)[idxEsNodb]/10.0))));
		}

		else if (ModeOfOperation == 2)
		{
			idxSNRdb =  (IS_SCALAR(SNR_DB)) ? 0 : i;
			idxSIGPOW = (IS_SCALAR(SIGNAL_POWER)) ? 0 : i;

			*std++ = sqrt((mxGetPr(SIGNAL_POWER)[idxSIGPOW])/(pow(10.0,(mxGetPr(SNR_DB)[idxSNRdb]/10.0))));
		}

		else if (ModeOfOperation == 3)
		{
			idxFVAR = (IS_SCALAR(FIELD_VARIANCE)) ? 0 : i;

			*std++ = sqrt(mxGetPr(FIELD_VARIANCE)[idxFVAR]);
		}

		else
		{
			*std = 0.0;
		}

	}
}



/* Function: mdlStart =======================================================*/

#define MDL_START
static void mdlStart (SimStruct *S)
	{
	int_T i;

	const int_T ModeOfOperation   = (int_T)mxGetPr(MODE)[0];
	const int_T IsInputFrameBased = (int_T)mxGetPr(FRAME_BASED)[0];
	const int_T InPortWidth       = ssGetInputPortWidth(S, INPORT_SIGNAL);
	const int_T nChans            = (IsInputFrameBased) ? (int_T)mxGetPr(NO_OF_CHANNELS)[0] : InPortWidth;

	const int_T SamplesPerInputFrame  = InPortWidth/nChans;

	/* ---	Check that if either SNR mode is selected, the sample time is not continuous*/

	if (((ModeOfOperation == 1) || (ModeOfOperation == 2))
		 && (ssGetSampleTime(S, 0) == CONTINUOUS_SAMPLE_TIME))
	{
	    THROW_ERROR(S,"In Signal to noise ratio mode, the block input and output must have discrete sample times");
	}

	/*--------------To see input signal width is integer multiple of nChans----------------*/
	if ((InPortWidth % nChans) != 0)
	{
		THROW_ERROR(S,"The size of the input signal vector is not an integer multiple of the Number of channels parameter value.");
	}

	/*---------------To see if input variance width is scalar or matches nChans---------------*/
	if ((ModeOfOperation == 4) && (IsInputFrameBased == 1))
	{
		if ((ssGetInputPortWidth(S,INPORT_VARIANCE) != 1) && (ssGetInputPortWidth(S,INPORT_VARIANCE) != nChans))
		{
			THROW_ERROR(S,"The size of the input variance vector must either be '1' or must match the Number of channels parameter value.");
		}
	}
	if ((ModeOfOperation == 4) && (IsInputFrameBased == 0))
	{
		if ((ssGetInputPortWidth(S,INPORT_VARIANCE) != 1) && (ssGetInputPortWidth(S,INPORT_VARIANCE) != nChans))
		{
			THROW_ERROR(S,"The size of the input variance vector must either be '1' or must match the width of the input signal.");
		}
	}


	/*---------Check width of params in multichannel non-frame based case------------*/
		/*--Check Signal Power for both modes 1 & 2---*/
	if ((ModeOfOperation == 1) || (ModeOfOperation == 2))
	{
		if ((!IS_SCALAR(SIGNAL_POWER)) && (mxGetNumberOfElements(SIGNAL_POWER) != nChans))
		{
			THROW_ERROR(S,"Input Signal power parameter needs to be either a scalar value or a vector whose length matches the number of channels of the input.");
		}
	}
	/*----Mode == 1----*/
	if (ModeOfOperation == 1)
	{
		if ((!IS_SCALAR(ESNO_DB)) && (mxGetNumberOfElements(ESNO_DB) != nChans))
		{
			THROW_ERROR(S,"Signal to noise ratio parameter needs to be either a scalar value or a vector whose length matches the number of channels of the input.");
		}
		if ((!IS_SCALAR(SYMBOL_PERIOD)) && (mxGetNumberOfElements(SYMBOL_PERIOD) != nChans))
		{
			THROW_ERROR(S,"Symbol Period parameter needs to be either a scalar value or a vector whose length matches the number of channels of the input.");
		}
	}
	/*---Mode == 2---*/
	if (ModeOfOperation == 2)
	{
		if ((!IS_SCALAR(SNR_DB)) && (mxGetNumberOfElements(SNR_DB) != nChans))
		{
			THROW_ERROR(S,"Signal to noise ratio parameter needs to be either a scalar value or a vector whose length matches the number of channels of the input.");
		}
	}
	/*----Mode == 3----*/
	if (ModeOfOperation == 3)
	{
		if ((!IS_SCALAR(FIELD_VARIANCE)) && (mxGetNumberOfElements(FIELD_VARIANCE) != nChans))
		{
			THROW_ERROR(S,"Variance parameter needs to be either a scalar value or a vector whose length matches the number of channels of the input.");
		}
	}

	/*----------Check to see if Number of channels parameter has been defined in the non Frame-based mode------*/


	/*-----------Check to see if Symbol time does not exceed sample time------------*/
	if ((ModeOfOperation == 1) && (ssGetSimMode(S) != SS_SIMMODE_SIZES_CALL_ONLY))
	{
		if (!IS_SCALAR(SYMBOL_PERIOD))
		{
			for ( i = 0; i < nChans; i++)
			{
				real32_T  symT = mxGetPr(SYMBOL_PERIOD)[i];
				real32_T sampT = ssGetSampleTime(S, 0)/SamplesPerInputFrame;
				if (symT < sampT)
				{
					THROW_ERROR(S,"The Symbol period parameter value must exceed the inherited sample time of the block");
				}
			}
		}
		else
		{
			real32_T  symT = mxGetPr(SYMBOL_PERIOD)[0];
			real32_T sampT = ssGetSampleTime(S, 0)/SamplesPerInputFrame;
			if (symT < sampT)
			{
				THROW_ERROR(S,"The Symbol period parameter value should exceed the inherited sample time of the block");
			}
		}
	}
}


/* Function: mdlOutputs =======================================================*/

static void mdlOutputs(SimStruct *S, int_T tid)
{
	const int_T ModeOfOperation   = (int_T)mxGetPr(MODE)[0];
	const int_T IsInputFrameBased = (int_T)mxGetPr(FRAME_BASED)[0];
	const int_T InPortWidth       = ssGetInputPortWidth(S, INPORT_SIGNAL);
	const int_T InPortVarWidth    = ssGetInputPortWidth(S,INPORT_VARIANCE);
	const int_T nChans            = (IsInputFrameBased) ? (int_T)mxGetPr(NO_OF_CHANNELS)[0] : InPortWidth;

    const boolean_T    cplx      = (ssGetInputPortComplexSignal(S, INPORT_SIGNAL) == COMPLEX_YES);
	const int_T      SamplesPerInputFrame  = InPortWidth/nChans;

	real_T *workStd  = (real_T *)ssGetDWork(S, STD);


    InputRealPtrsType  var     = ssGetInputPortRealSignalPtrs(S, INPORT_VARIANCE);

	real_T *in_var;
	int_T  i, j;

	if (!cplx)
	{
        /*
        * Real Gaussian Noise Channel
        */

		int_T  i, j;
		InputRealPtrsType  noise   = ssGetInputPortRealSignalPtrs(S, INPORT_NOISE);
		InputRealPtrsType  uptr = ssGetInputPortRealSignalPtrs(S, INPORT_SIGNAL);
		real_T            *y    = ssGetOutputPortRealSignal(S, OUTPORT_SIGNAL);

		if (ModeOfOperation == 1)
		{
			for (i = 0; i < nChans; i++)
			{
				for (j = 0; j < SamplesPerInputFrame; j++)
				{
					*y++ = (**uptr++) + (*workStd)*(**noise++)/sqrt(2);
				}
				workStd++;
			}
		}

		if ((ModeOfOperation == 2) || (ModeOfOperation == 3))
		{
			for (i = 0; i < nChans; i++)
			{
				for (j = 0; j < SamplesPerInputFrame; j++)
				{
					*y++ = (**uptr++) + (*workStd)*(**noise++);
				}
				workStd++;
			}
		}
		if (ModeOfOperation == 4)
		{
			for (i = 0; i < nChans; i++)
			{
				if (**var < 0.0)
				{
					THROW_ERROR(S,"Variance value must be positive.");
				}
				for (j = 0; j < SamplesPerInputFrame; j++)
				{
					*y++ = (**uptr++) + (sqrt(**var))*(**noise++);
				}
				if (InPortVarWidth != 1){*var++;}
			}
		}
	}
	else
	{
        /*
         * Complex Gaussian Noise Channel
         */
		int_T  i, j;
		InputPtrsType	   noisec = ssGetInputPortSignalPtrs(S, INPORT_NOISE);
        InputPtrsType      uptr = ssGetInputPortSignalPtrs(S, INPORT_SIGNAL);
        creal_T           *y    = (creal_T *)ssGetOutputPortSignal(S, OUTPORT_SIGNAL);



		if (ModeOfOperation != 4)
		{
			for (i = 0; i < nChans; i++)
			{
				for (j = 0; j < SamplesPerInputFrame; j++)
				{
					const creal_T *u  = (creal_T *)(*uptr++);
					const creal_T *n  = (creal_T *)(*noisec++);
					(y)->re = (u->re) + (*workStd)*(n->re);
					(y)->im = (u->im) + (*workStd)*(n->im);
					y++;
				}
				workStd++;
			}
		}

		if (ModeOfOperation == 4)
		{
			for (i = 0; i < nChans; i++)
			{
					if (**var < 0.0)
					{
						THROW_ERROR(S,"Variance value must be positive.");
					}
					{
						const real_T sqrt_var = sqrt(**var);
						for (j = 0; j < SamplesPerInputFrame ; j++)
						{
							const creal_T     *u    = (creal_T *)(*uptr++);
							const creal_T *n    = (creal_T *)(*noisec++);
							(y)->re = (u->re) + (sqrt_var)*(n->re);
							(y)->im = (u->im) + (sqrt_var)*(n->im);
							y++;
						}
					}
					if (InPortVarWidth != 1){*var++;}
			}
		}
	}
}


/* Function: mdlSetWorkWidths ===============================================*/

#ifdef MATLAB_MEX_FILE
#define MDL_SET_WORK_WIDTHS
static void mdlSetWorkWidths(SimStruct *S)
{
	const int_T InPortWidth       = ssGetInputPortWidth(S,INPORT_SIGNAL);
	const int_T IsInputFrameBased = (int_T)mxGetPr(FRAME_BASED)[0];
	const int_T nChans            = (IsInputFrameBased) ? (int_T)mxGetPr(NO_OF_CHANNELS)[0] : InPortWidth;

	ssSetNumDWork(S, NUM_DWORK);

	ssSetDWorkWidth(        S, STD, nChans);
    ssSetDWorkDataType(     S, STD, SS_DOUBLE);
    ssSetDWorkComplexSignal(S, STD, COMPLEX_NO);
}
#endif




static void mdlTerminate(SimStruct *S)
{
}




#ifdef  MATLAB_MEX_FILE
#define MDL_SET_INPUT_PORT_COMPLEX_SIGNAL
static void mdlSetInputPortComplexSignal(SimStruct *S, int_T portIdx,
                                         int_T InputPortComplexSignal)
{
    if (portIdx == INPORT_SIGNAL)
	{
		if (ssGetOutputPortComplexSignal(S,OUTPORT_SIGNAL) != DYNAMICALLY_SIZED)
		{
			THROW_ERROR(S,"The input and output signals must have the same complexity.");
		}


		ssSetInputPortComplexSignal(S, INPORT_SIGNAL, InputPortComplexSignal);
		ssSetInputPortComplexSignal(S, INPORT_NOISE, InputPortComplexSignal);
		ssSetOutputPortComplexSignal(S, OUTPORT_SIGNAL, InputPortComplexSignal);
	}
	else if (portIdx == INPORT_NOISE)
	{
		ssSetInputPortComplexSignal(S, INPORT_NOISE, InputPortComplexSignal);

		if (ssGetInputPortComplexSignal(S,INPORT_NOISE) != ssGetInputPortComplexSignal(S,INPORT_SIGNAL))
		{
			THROW_ERROR(S,"The complexity of the noise signal must be the same as the input signal");
		}

	}
	else
	{
		THROW_ERROR(S,"Invalid port index for complex propagation.");
	}
}


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
    ssSetInputPortComplexSignal(S, INPORT_SIGNAL, OutputPortComplexSignal);
	ssSetInputPortComplexSignal(S, INPORT_NOISE, OutputPortComplexSignal);
}


#define MDL_SET_INPUT_PORT_WIDTH
static void mdlSetInputPortWidth(SimStruct *S, int_T portIdx,
								 int_T width)
{
	if ((portIdx == INPORT_SIGNAL))
	{

		if (ssGetOutputPortWidth(S,OUTPORT_SIGNAL) != DYNAMICALLY_SIZED)
		{
			THROW_ERROR(S,"The input and output signals must be the same width.");
		}


		ssSetInputPortWidth(S, INPORT_SIGNAL, width);
		ssSetInputPortWidth(S, INPORT_NOISE, width);
		ssSetOutputPortWidth(S, OUTPORT_SIGNAL, width);
	}
	else if ((portIdx == INPORT_NOISE))
	{
		ssSetInputPortWidth(S, INPORT_NOISE, width);


		if ((ssGetInputPortWidth(S,INPORT_NOISE) != ssGetInputPortWidth(S,INPORT_SIGNAL)))
		{
			THROW_ERROR(S,"The width of the noise signal must be the same width as the input signal.");
		}

	}
	else if ((portIdx == INPORT_VARIANCE))
	{
		ssSetInputPortWidth(S, INPORT_VARIANCE, width);
	}
	else
	{
		THROW_ERROR(S,"Invalid port index for width propagation.");
	}
}


#define MDL_SET_OUTPUT_PORT_WIDTH
static void mdlSetOutputPortWidth(SimStruct *S, int_T portIdx,
								  int_T width)
{
	if (portIdx != OUTPORT_SIGNAL)
	{
		THROW_ERROR(S,"Invalid port index for width propagation.");
	}

	if (ssGetInputPortWidth(S,INPORT_SIGNAL) != DYNAMICALLY_SIZED)
	{
		THROW_ERROR(S,"The input signal and the output signal must have the same widths.");
	}


	ssSetInputPortWidth(S, INPORT_SIGNAL, width);
	ssSetInputPortWidth(S, INPORT_NOISE, width);
	ssSetOutputPortWidth(S, OUTPORT_SIGNAL, width);
}
#endif



#ifdef  MATLAB_MEX_FILE
#include "simulink.c"
#else
#include "cg_sfun.h"
#endif
