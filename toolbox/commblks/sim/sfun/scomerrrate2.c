/*
 * SCOMERRRATE2 Communications Toolbox S-Function for error rate calculation.
 *
 *  Copyright 1996-2003 The MathWorks, Inc.
 *  $Revision: 1.21.4.4 $  $Date: 2004/01/09 17:36:28 $
 */

#define S_FUNCTION_NAME scomerrrate2
#define S_FUNCTION_LEVEL 2
#include "simstruc.h"
#include "comm_defs.h"

enum {RX_DELAY_C=0, ST_DELAY_C, CP_MODE_C, SUB_FRAME_C, OUTPUT_C, VAR_NAME_C, \
      RESET_BOX_C, STOP_C, NUMERR_C, MAXBITS_C,NUM_PARAMS};

enum {IN_PORT1=0, IN_PORT2, OPT_PORT1, OPT_PORT2};
enum {OUT_PORT=0};

enum {RATIO=0, ERRORS, SYMBOLS, ST_CNT, TX_BUFF, FR_BUFF, USE_FRAME, WIDTH, \
      TX_SCALAR, RX_SCALAR, NUM_DWORK};
enum {CUR_TX, CUR_FR, NUM_PWORK};

#define RX_DELAY  (ssGetSFcnParam(S, RX_DELAY_C  ))
#define ST_DELAY  (ssGetSFcnParam(S, ST_DELAY_C  ))
#define CP_MODE   (ssGetSFcnParam(S, CP_MODE_C   ))
#define SUB_FRAME (ssGetSFcnParam(S, SUB_FRAME_C ))
#define OUTPUT    (ssGetSFcnParam(S, OUTPUT_C    ))
#define VAR_NAME  (ssGetSFcnParam(S, VAR_NAME_C  ))
#define RESET_BOX (ssGetSFcnParam(S, RESET_BOX_C ))
#define STOP      (ssGetSFcnParam(S, STOP_C      ))
#define NUMERR    (ssGetSFcnParam(S, NUMERR_C    ))
#define MAXBITS   (ssGetSFcnParam(S, MAXBITS_C   ))

#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S)
{
    /*
     * Check that the Startup/Computation Delay is a finite real positive
     * integer.
     */
    if (OK_TO_CHECK_VAR(S, RX_DELAY)) {
        if ( !IS_FLINT_GE(RX_DELAY,0) ) {
            THROW_ERROR(S, "Receive delay must be a finite real positive "
                      "integer.");
        }
    }

    /* Check that the Receive Delay is a finite real positive integer. */
    if (OK_TO_CHECK_VAR(S, ST_DELAY)) {
        if ( !IS_FLINT_GE(ST_DELAY,0) ) {
            THROW_ERROR(S, "Startup/computation delay must be a finite real "
                      "positive integer.");
        }
    }

    /* Check the Subframe Port checkbox */
    if (!IS_FLINT_IN_RANGE(CP_MODE, 1, 3)) {
        THROW_ERROR(S, "Computation mode parameter can be only 1 (entire frame)"
                  ", 2 (selected samples from mask) or 3 (selected samples "
                  "from port).");
    }

    /*
     * Check that the Subframe Elements are finite real integers greater than
     * one. Only need to check if the Subframe is specified in the mask.
     */
    if (mxGetPr(CP_MODE)[0] == 2){
        if (OK_TO_CHECK_VAR(S, SUB_FRAME)) {
            int_T i;
            int_T sz = mxGetNumberOfElements(SUB_FRAME);
            if (mxGetM(SUB_FRAME) > 1) {
                THROW_ERROR(S, "Selected samples from frame must be a row "
                          "vector.");
            }
            for (i=0; i<sz; i++) {
                if (!IS_IDX_FLINT_GE(SUB_FRAME,i,0)) {
                    THROW_ERROR(S, "Selected samples from frame elements must "
                              "be finite real integers greater than zero.");
                }
            }
        }
    }

    /* Check the Output Port checkbox*/
    if (!IS_FLINT_IN_RANGE(OUTPUT, 1, 2)) {
        THROW_ERROR(S, "Output data parameter can be only 1 (results to "
                  "workspace) or 2 (results to port).");
    }

    /* Check the Reset Port checkbox */
    if (!IS_FLINT_IN_RANGE(RESET_BOX, 0, 1)) {
        THROW_ERROR(S, "Reset Port parameter can be only 0 (no reset) or 1 "
                  "(reset port).");
    }
    /* Check the Stop Simulation checkbox */
    if (!IS_FLINT_IN_RANGE(STOP, 0, 1)) {
        THROW_ERROR(S, "Stop Simulation parameter can be only 0 (no stop) or 1 "
                  "(stop).");
    }

    /* Check the # of errors parameter*/
    if( (mxGetN(NUMERR)==0) || ( (real_T)mxGetPr(NUMERR)[0] <= 0.0) ||(!IS_FLINT(NUMERR) && !mxIsInf(mxGetPr(NUMERR)[0])
        || mxIsComplex(NUMERR) ) ){
        THROW_ERROR(S,"Target number of errors must be a real integer greater than 0");
    }

    /* Check the # of bits parameter*/
    if( (mxGetN(MAXBITS)==0) ||( (real_T)mxGetPr(MAXBITS)[0] <= 0.0) ||(!IS_FLINT(MAXBITS) && !mxIsInf(mxGetPr(MAXBITS)[0])
        || mxIsComplex(MAXBITS) ) ){
        THROW_ERROR(S,"Maximum number of symbols must a real integer be greater than 0");
    }

}
#endif

static void mdlInitializeSizes(SimStruct *S)
{
    int i;

    ssSetNumSFcnParams(S, NUM_PARAMS);


    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        return; /* Parameter mismatch will be reported by Simulink */
    }else{
#ifdef MATLAB_MEX_FILE
        mdlCheckParameters(S);
        if (ssGetErrorStatus(S) != NULL) return;
#endif
    }

    ssSetNumSampleTimes(S, PORT_BASED_SAMPLE_TIMES);

    /* The number of inputs is determined by the parameters CP_MODE and
     * RESET_BOX. The width of OPT_PORT1 depends on whether the input is
     * for Subframe or Reset.
     */
    if (mxGetPr(CP_MODE)[0]==3) {
        if (mxGetPr(RESET_BOX)[0]==1) {
            if (!ssSetNumInputPorts(S, 4)) return;

            ssSetInputPortDimensionInfo(    S, OPT_PORT2, DYNAMIC_DIMENSION);
            ssSetInputPortFrameData(        S, OPT_PORT2, FRAME_INHERITED);
            ssSetInputPortDirectFeedThrough(S, OPT_PORT2, 1);
            ssSetInputPortComplexSignal(    S, OPT_PORT2, COMPLEX_NO);
            ssSetInputPortSampleTime(       S, OPT_PORT2, INHERITED_SAMPLE_TIME);
        }else{
            if (!ssSetNumInputPorts(S, 3)) return;
        }

        ssSetInputPortDimensionInfo(    S, OPT_PORT1, DYNAMIC_DIMENSION);
        ssSetInputPortFrameData(        S, OPT_PORT1, FRAME_NO);
        ssSetInputPortDirectFeedThrough(S, OPT_PORT1, 1);
        ssSetInputPortComplexSignal(    S, OPT_PORT1, COMPLEX_NO);
        ssSetInputPortSampleTime(       S,OPT_PORT1, INHERITED_SAMPLE_TIME);
    }else if (mxGetPr(RESET_BOX)[0]==1) {
        if (!ssSetNumInputPorts(S, 3)) return;

        ssSetInputPortDimensionInfo(    S, OPT_PORT1, DYNAMIC_DIMENSION);
        ssSetInputPortFrameData(        S, OPT_PORT1, FRAME_INHERITED);
        ssSetInputPortDirectFeedThrough(S, OPT_PORT1, 1);
        ssSetInputPortComplexSignal(    S, OPT_PORT1, COMPLEX_NO);
        ssSetInputPortSampleTime(       S,OPT_PORT1, INHERITED_SAMPLE_TIME);
    }else{
        if (!ssSetNumInputPorts(S, 2)) return;
    }

    /*
     * The two signal input ports, always dynamically-sized and
     * complex-inherited.
     */
    ssSetInputPortDimensionInfo(    S, IN_PORT1, DYNAMIC_DIMENSION);
    ssSetInputPortFrameData(        S, IN_PORT1, FRAME_INHERITED);
    ssSetInputPortDirectFeedThrough(S, IN_PORT1, 1);
    ssSetInputPortComplexSignal(    S, IN_PORT1, COMPLEX_INHERITED);
    ssSetInputPortSampleTime(       S, IN_PORT1, INHERITED_SAMPLE_TIME);

    ssSetInputPortDimensionInfo(    S, IN_PORT2, DYNAMIC_DIMENSION);
    ssSetInputPortFrameData(        S, IN_PORT2, FRAME_INHERITED);
    ssSetInputPortDirectFeedThrough(S, IN_PORT2, 1);
    ssSetInputPortComplexSignal(    S, IN_PORT2, COMPLEX_INHERITED);
    ssSetInputPortSampleTime(       S, IN_PORT2, INHERITED_SAMPLE_TIME);

    /* There is one output only if the OUTPUT pop-up is set to 2. */
    if (mxGetPr(OUTPUT)[0]==2) {
        if (!ssSetNumOutputPorts(S,1)) return;
        ssSetOutputPortWidth(        S, OUT_PORT, 3);
        ssSetOutputPortFrameData(     S, OUT_PORT, FRAME_NO);
        ssSetOutputPortComplexSignal(S, OUT_PORT, COMPLEX_NO);
        ssSetOutputPortSampleTime(   S, OUT_PORT, INHERITED_SAMPLE_TIME);
    }else{
        if (!ssSetNumOutputPorts(S,0)) return;
    }

    if (!ssSetNumDWork(S, DYNAMICALLY_SIZED)) return;

    ssSetNumPWork(S, DYNAMICALLY_SIZED);

    ssSetOptions(S, SS_OPTION_NONSTANDARD_PORT_WIDTHS |
                 SS_OPTION_RUNTIME_EXCEPTION_FREE_CODE);

    for (i = 0; i< NUM_PARAMS; i++)
        ssSetSFcnParamNotTunable(S, i);

}

/*
 *      Table of allowed inputs and outputs
 *
 *      Tx    |    Rx    |   Sel    |    Rst   |   Output |
 *  ----------|----------|----------|----------|----------|
 *  1       SB|[Mx1]   FB|1       SB|1       SB|[1x3]   SB *
 *  1       SB|[Mx1]   FB|1       SB|[1x1]   FB|[1x3]   SB *
 *  1       SB|1       SB|1       SB|1       SB|[1x3]   SB
 *  1       SB|1       SB|1       SB|[1x1]   FB|[1x3]   SB
 *  [Mx1]   FB|[Mx1]   FB|[Lx1]   SB|1       SB|[1x3]   SB
 *  [Mx1]   FB|[Mx1]   FB|[Lx1]   SB|[1x1]   FB|[1x3]   SB
 *  [Mx1]   FB|1       SB|[Lx1]   SB|1       SB|[1x3]   SB *
 *  [Mx1]   FB|1       SB|[Lx1]   SB|[1x1]   FB|[1x3]   SB *
 *  [1x1]   FB|[Mx1]   FB|[Lx1]   SB|1       SB|[1x3]   SB *
 *  [1x1]   FB|[Mx1]   FB|[Lx1]   SB|[1x1]   FB|[1x3]   SB *
 *  [Mx1]   FB|[1x1]   FB|[Lx1]   SB|1       SB|[1x3]   SB *
 *  [Mx1]   FB|[1x1]   FB|[Lx1]   SB|[1x1]   FB|[1x3]   SB *
 *
 *  L < M
 *  * means that the comparison  in 1 to many
 */


#if defined(MATLAB_MEX_FILE)
#define MDL_SET_INPUT_PORT_DIMENSION_INFO

static boolean_T checkInputPortDimsOk(SimStruct *S, int_T portIdx1, int_T portIdx2)
{
    const int_T *dims1 = ssGetInputPortDimensions(S,portIdx1);
    const int_T *dims2 = ssGetInputPortDimensions(S,portIdx2);

    return((boolean_T)( ((dims1[0]==dims2[0]) && (dims1[1]==dims2[1])) ||  /* equal dims */
						/* extra cases to allow for [1x1] input dimensions */
					    ((dims1[0]==1) && (dims1[1]==1)) ||				   /* dims1 = {1, 1} */
						((dims2[0]==1) && (dims2[1]==1)) )); 			   /* dims2 = {1, 1} */
}

boolean_T isInputColVector(SimStruct *S, int_T port) 
{
    if (ssGetInputPortNumDimensions(S, port) > 1) {
        const int_T *dims = ssGetInputPortDimensions(S,port); 
        return((boolean_T)((dims[0]>1) && (dims[1]==1)));
    } else {
        return false;
    }
}

boolean_T isInput1or2D(SimStruct *S, int_T port) {
    const int_T numDims = ssGetInputPortNumDimensions(S, port);
    return( (boolean_T)((numDims == 1) || (numDims == 2)) );
}

static void mdlSetInputPortDimensionInfo(SimStruct *S, int_T portIdx,
                                      const DimsInfo_T *dimsInfo)
{

	/* Get data from input structures */
	int_T inputPortWidth;
	int_T numDims;
	const int_T inRows     = dimsInfo->dims[0];
    const int_T inCols     = dimsInfo->dims[1];


    /* set this input port's dimension info */
    if(!ssSetInputPortDimensionInfo(S, portIdx, dimsInfo)) return;

    /* get this ports info from simulink */
	numDims  = ssGetInputPortNumDimensions(S, portIdx);
    inputPortWidth = ssGetInputPortWidth(S, portIdx);

    /* if the number of dimensions is not 1 ot 2 then error out */
	if (!isInput1or2D(S,portIdx)) {
		THROW_ERROR(S, "Input must be 1-D or 2-D.");
	}
    /* Do consistency checking on widths for all ports. */
	switch(portIdx)
	{
	case IN_PORT1: /* transmit port */
		/* Divide the processing based on whether the Tx port is frame or sample based */
		if (ssGetInputPortFrameData(S, IN_PORT1) == FRAME_YES) {
		    /* The Tx port is frame based. Now is it a column vector */
		    if(!isInputColVector(S, IN_PORT1) && !(ssGetInputPortWidth(S,IN_PORT1) == 1)) {
		        /* the Tx input is not a column vector */
			    THROW_ERROR(S,"Frame-based input to the 'Tx' port must be a column vector.");
			}

			/* If the ports are dynamically sized, don't do any more checking */
			if (ssGetInputPortWidth(S, IN_PORT2) == DYNAMICALLY_SIZED) {
				break;
			}

			/* Now check the Rx port */
            if (ssGetInputPortFrameData(S, IN_PORT2) == FRAME_YES) {
				/* The Rx port dims have been set, check if it is a vector */
				if (!isInputColVector(S, IN_PORT2) && !(ssGetInputPortWidth(S,IN_PORT2) == 1)) {
    		        /* the input is not a column vector */
    			    THROW_ERROR(S,"Frame-based input to the 'Rx' port must be a column vector.");
    			}
    			/* throw an error if the column length of the Tx and Rx ports don't match */
				if (!checkInputPortDimsOk(S, IN_PORT2,IN_PORT1)) {
					THROW_ERROR(S,"The inputs to the 'Tx' and 'Rx' ports must have the same length.");
				}
    		}
		    else {
		        /* the Rx port is sample based, now is it a scalar ?*/
    		    if(!(ssGetInputPortWidth(S,IN_PORT2) == 1)) {
    		        /* the input is not a scalar */
    			    THROW_ERROR(S,"Sample-based input to the 'Rx' port must be a scalar.");
    			}
		    } /* end of if (isFrameDataOn(IN_PORT2)) */
		}
		else {
		    /* The Tx port is sample based. Now is it a scalar ?*/
		    if (!(ssGetInputPortWidth(S,IN_PORT1) == 1)) {
		        /* the Tx input is not a scalar */
			    THROW_ERROR(S,"Sample-based input to the 'Tx' port must be a scalar.");
			}

			/* If the ports are dynamically sized, don't do any more checking */
			if (ssGetInputPortWidth(S, IN_PORT2) == DYNAMICALLY_SIZED) {
				break;
			}

			/* Tx input is sample-based. Is the Rx input a scalar ? */
		    if(!isInputColVector(S, IN_PORT2) && !(ssGetInputPortWidth(S,IN_PORT2) == 1)) {
		        /* the Rx input is not a scalar */
			    THROW_ERROR(S,"Input to the 'Rx' port must be a column vector or a scalar.");
			}
    	}/* end of if (isFrameDataOn(IN_PORT1)) */
		break;

	case IN_PORT2:  /* Rx port processing */
		/* Divide the processing based on whether the Rx port is frame or sample based */
		if (ssGetInputPortFrameData(S, IN_PORT2) == FRAME_YES) {
		    /* The Rx port is frame based, now is it a column vector? */
		    if (!isInputColVector(S, IN_PORT2) && !(ssGetInputPortWidth(S,IN_PORT2) == 1)) {
		        /* the Rx input is not a column vector */
			    THROW_ERROR(S,"Frame-based input to the 'Rx' port must be a column vector.");
			}

		    /* If the ports are dynamically sized, don't do any more checking */
		    if (ssGetInputPortWidth(S, IN_PORT1) == DYNAMICALLY_SIZED) {
		        break;
		    }

			/* Now check the Tx port. Is the port frame-based ? */
    		if (ssGetInputPortFrameData(S, IN_PORT1) == FRAME_YES) {
   				/* The Tx port dims have been set, check if it is a vector */
				if(!isInputColVector(S, IN_PORT1) && !(ssGetInputPortWidth(S,IN_PORT1) == 1)) {
    		        /* the Tx input is not a column vector */
    			    THROW_ERROR(S,"Frame-based input to the 'Tx' port must be a column vector.");
    			}
    			/* throw an error if the column length of the Tx and Rx ports don't match */
				if (!checkInputPortDimsOk(S, IN_PORT2,IN_PORT1)) {
					THROW_ERROR(S,"The inputs to the 'Tx' and 'Rx' ports must have the same length.");
				}
    		}
		    else {
		        /* the Tx port is sample based, now is it a scalar ? */
    		    if(!(ssGetInputPortWidth(S,IN_PORT1) == 1)) {
    		        /* the Tx input is not a scalar */
    			    THROW_ERROR(S,"Sample-based input to the 'Tx' port must be a scalar.");
    			}
		    }/* end of if (isFrameDataOn(IN_PORT1)) */
		}
		else {
	        /* the Rx port is sample based, now is it a scalar ?*/
		    if(!(ssGetInputPortWidth(S,IN_PORT2) == 1)) {
		        /* the Rx input is not a scalar */
			    THROW_ERROR(S,"Sample-based input to the 'Rx' port must be a scalar.");
			}

		    /* If the ports are dynamically sized, don't do any more checking */
		    if (ssGetInputPortWidth(S, IN_PORT1) == DYNAMICALLY_SIZED) {
		        break;
		    }

	        /* Rx input is a scalar. Now is the Tx input a scalar ?*/
		    if(!isInputColVector(S, IN_PORT1) && !(ssGetInputPortWidth(S,IN_PORT1) == 1)) {
		        /* the Tx input is not a scalar */
			    THROW_ERROR(S,"Input to the 'Tx' port must be a column vector or a scalar.");
			}
		}/* end of if (isFrameDataOn(IN_PORT2)) */
		break;

	case OPT_PORT1:

		/* is this port for the Reset port or the Select port */
		if (mxGetPr(CP_MODE)[0]!=3){
			/* check that the Reset port is a scalar ? */
			if (!(ssGetInputPortWidth(S,OPT_PORT1) == 1)) {
				THROW_ERROR(S,"Input to the 'Rst' port must be a scalar.");
			}
		}
		else{
			/* check that the Sel port is a row vector or scalar */
			if (!isInputColVector(S, OPT_PORT1) && !(ssGetInputPortWidth(S,OPT_PORT1) == 1)) {
				THROW_ERROR(S,"Input to the 'Sel' port must be a sample-based column vector or a scalar.");
			}
		}/* end of if (mxGetPr(CP_MODE)[0]!=3){ */
		break;

	case OPT_PORT2:
		/* check that the Reset port is a scalar */
		if (!(ssGetInputPortWidth(S,OPT_PORT2) == 1)) {
			THROW_ERROR(S,"Input to the 'Rst' port must be a scalar.");
		}
		break;
	default:
        THROW_ERROR(S, "Input port dimension propagation "
                  "failure in error rate block.");
	}/* end of switch(portIdx) */

}
#endif


#if defined(MATLAB_MEX_FILE)
#define MDL_SET_OUTPUT_PORT_DIMENSION_INFO
static void mdlSetOutputPortDimensionInfo(SimStruct *S, int_T portIdx,
                                          const DimsInfo_T *dimsInfo)
{
	/* is this port valid ? */
    if(portIdx != OUT_PORT){
		THROW_ERROR(S,"Invalid output port used in setting output port dimensions.");
	}

    if(!ssSetOutputPortDimensionInfo(S, portIdx, dimsInfo)) return;
}

#define MDL_SET_DEFAULT_PORT_DIMENSION_INFO
static void mdlSetDefaultPortDimensionInfo(SimStruct *S)
{
    /* initialize a dynamically-dimensioned DimsInfo_T */
    DECL_AND_INIT_DIMSINFO(dInfo); 
    int_T dims[2] = {1, 1};

    /* select valid port dimensions - [1x1] scalar */
    dInfo.width     = 1;
    dInfo.numDims   = 2;
    dInfo.dims      = dims;

    /* call the input functions for all ports */
    if (mxGetPr(CP_MODE)[0]==3) {
        if (mxGetPr(RESET_BOX)[0]==1) {
            /* 4 ports - with reset */
            if (ssGetInputPortWidth(S, OPT_PORT2) == DYNAMICALLY_SIZED) 
                mdlSetInputPortDimensionInfo(S, OPT_PORT2, &dInfo);
        }
        /* 3 ports  - only the samples */
        if (ssGetInputPortWidth(S, OPT_PORT1) == DYNAMICALLY_SIZED) 
            mdlSetInputPortDimensionInfo(S, OPT_PORT1, &dInfo);
    }else if (mxGetPr(RESET_BOX)[0]==1) {
        /* 3 ports - 2 signal + reset */
        if (ssGetInputPortWidth(S, OPT_PORT1) == DYNAMICALLY_SIZED) 
            mdlSetInputPortDimensionInfo(S, OPT_PORT1, &dInfo);
    }

    /* 2 signal ports */
    if (ssGetInputPortWidth(S,IN_PORT1) == DYNAMICALLY_SIZED) 
        mdlSetInputPortDimensionInfo(S, IN_PORT1, &dInfo);
    
    if (ssGetInputPortWidth(S,IN_PORT2) == DYNAMICALLY_SIZED) 
        mdlSetInputPortDimensionInfo(S, IN_PORT2, &dInfo);
}
#endif

#ifdef  MATLAB_MEX_FILE
#define MDL_SET_INPUT_PORT_COMPLEX_SIGNAL
static void setPortComplexities(SimStruct *S,
						   int_T thisPortIdx,
						   int_T otherPortIdx,
                           int_T InputPortComplexSignal)
{
	ssSetInputPortComplexSignal(S, thisPortIdx, InputPortComplexSignal);

	if (ssGetInputPortComplexSignal(S, otherPortIdx) == COMPLEX_INHERITED)
	{
		ssSetInputPortComplexSignal(S, otherPortIdx, InputPortComplexSignal);
	}
	else if (ssGetInputPortComplexSignal(S, otherPortIdx) != InputPortComplexSignal)
	{
		THROW_ERROR(S,"Complexity propagation failed.");
	}
}

static void mdlSetInputPortComplexSignal(SimStruct *S, int_T portIdx,
                                         int_T InputPortComplexSignal)
{
	switch (portIdx)
	{
		case IN_PORT1:
		    setPortComplexities(S, portIdx, IN_PORT2, InputPortComplexSignal);
            break;

		case IN_PORT2:
		    setPortComplexities(S, portIdx, IN_PORT1, InputPortComplexSignal);
			break;
		case OPT_PORT1:
		case OPT_PORT2:
	        break;
		default:
			THROW_ERROR(S,"Invalid port index for complexity propagation.");
	}
}
#endif

#ifdef  MATLAB_MEX_FILE
#define MDL_SET_OUTPUT_PORT_COMPLEX_SIGNAL
static void mdlSetOutputPortComplexSignal(SimStruct *S, int_T portIdx,
                                          int_T OutputPortComplexSignal)
{
}
#endif


#if defined(MATLAB_MEX_FILE)
#define MDL_SET_INPUT_PORT_SAMPLE_TIME
static void mdlSetInputPortSampleTime(SimStruct *S,
                                      int_T     portIdx,
                                      real_T    sampleTime,
                                      real_T    offsetTime)
{
    if (sampleTime == CONTINUOUS_SAMPLE_TIME) {
        THROW_ERROR(S, "Continuous sample times not allowed for error rate "
                  "calculation block.");
    }

    if (offsetTime != 0.0) {
        THROW_ERROR(S, "Non-zero sample time offsets not allowed for error "
                  "rate calculation block.");
    }

    {
        int_T i, num;

        num = ssGetNumInputPorts(S);
        for (i=0; i<num; i++) {
            ssSetInputPortSampleTime(S, i, sampleTime);
            ssSetInputPortOffsetTime(S, i, offsetTime);
        }

        num = ssGetNumOutputPorts(S);
        for (i=0; i<num; i++) {
            ssSetOutputPortSampleTime(S, i, sampleTime);
            ssSetOutputPortOffsetTime(S, i, offsetTime);
        }
    }
}


#define MDL_SET_OUTPUT_PORT_SAMPLE_TIME
static void mdlSetOutputPortSampleTime(SimStruct *S,
                                       int_T     portIdx,
                                       real_T    sampleTime,
                                       real_T    offsetTime)
{
    if (sampleTime == CONTINUOUS_SAMPLE_TIME) {
        THROW_ERROR(S, "Continuous sample times not allowed for error rate "
                  "calculation block.");
    }

    if (offsetTime != 0.0) {
        THROW_ERROR(S, "Non-zero sample time offsets not allowed for error "
                  "rate calculation block.");
    }

    {
        int_T i, num;

        num = ssGetNumInputPorts(S);
        for (i=0; i<num; i++) {
            ssSetInputPortSampleTime(S, i, sampleTime);
            ssSetInputPortOffsetTime(S, i, offsetTime);
        }

        num = ssGetNumOutputPorts(S);
        for (i=0; i<num; i++) {
            ssSetOutputPortSampleTime(S, i, sampleTime);
            ssSetOutputPortOffsetTime(S, i, offsetTime);
        }
    }
}
#endif


static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetModelReferenceSampleTimeInheritanceRule(S, USE_DEFAULT_FOR_DISCRETE_INHERITANCE);
}

#define MDL_INITIALIZE_CONDITIONS
static void mdlInitializeConditions(SimStruct *S)
{

    /* Set the starting values for DWork variables and PWork pointer. */

    real_T   *errors    = (real_T *)   ssGetDWork(S, ERRORS);
    real_T   *symbols   = (real_T *)   ssGetDWork(S, SYMBOLS);
    real_T    *ratio     = (real_T *)    ssGetDWork(S, RATIO);
    int32_T   *st_cnt    = (int32_T *)   ssGetDWork(S, ST_CNT);
    int_T     *width     = (int_T *)     ssGetDWork(S, WIDTH);
    boolean_T *tx_scalar = (boolean_T *) ssGetDWork(S, TX_SCALAR);
    boolean_T *rx_scalar = (boolean_T *) ssGetDWork(S, RX_SCALAR);

    /* Set three result variables to zero initially. */
    *errors = 0;
    *symbols = 0;
    *ratio = 0;

    /* Because either of the inputs can be a scalar while the other is a vector,
     * 'width' is used to keep track of the width of the vector, whichever
     * input it is.
     */
    if (ssGetInputPortWidth(S, IN_PORT1) > 1) {
        *width = ssGetInputPortWidth(S, IN_PORT1);
    }else{
        *width = ssGetInputPortWidth(S, IN_PORT2);
    }

    /* Determine if either of the inputs are scalar. */
    if (ssGetInputPortWidth(S, IN_PORT1) == 1) {
        *tx_scalar = true;
    }else{
        *tx_scalar = false;
    }
    if (ssGetInputPortWidth(S, IN_PORT2) == 1) {
        *rx_scalar = true;
    }else{
        *rx_scalar = false;
    }

    /* Set the startup delay counter to zero. */
    *st_cnt = 0;

    /* Check the complexities of the two input signals. */
    if ( ssGetInputPortComplexSignal(S,IN_PORT1) !=
         ssGetInputPortComplexSignal(S,IN_PORT2) ) {
        THROW_ERROR(S, "Input Port Complexities unequal.");
    }

    /* It is only after this input port width has been defined that the elements
     * of the subframe parameter can be checked for not being too big. */
    if (mxGetPr(CP_MODE)[0] == 2) {
        int_T i;
        int_T sz = mxGetNumberOfElements(SUB_FRAME);
        for (i=0; i<sz; i++) {
            if (mxGetPr(SUB_FRAME)[i] > *width) {
                THROW_ERROR(S, "Selected samples from frame elements must not "
                          "be larger than the input port width.");
            }
        }
    }

    /*
     * Check that the width of the Selected Samples from Frame Port is not "
     * "wider than the Input Signal Ports.
     */
    if (mxGetPr(CP_MODE)[0]==3) {
        if ( ssGetInputPortWidth(S,OPT_PORT1) > *width ) {
            THROW_ERROR(S, "Selected samples from frame port width cannot be "
                      "greater than input signal port width.");
        }
    }

    /* CUR_TX is a PWork pointer to keep track of the delayed Tx signal.
     * CUR_TX PWork pointer will point to creal_T if input signal is complex. */
    if (ssGetInputPortComplexSignal(S,IN_PORT1) == COMPLEX_YES) {
        creal_T *ptr = (creal_T *) ssGetDWork(S,TX_BUFF);
        if(ptr==NULL) {
            THROW_ERROR(S, "Failed to allocate memory for Receive Delay Buffer.");
        }
        ssSetPWorkValue(S, CUR_TX, ptr);
    }else{
        /* CUR_TX PWork pointer will point to real_T if input signal is real. */
        real_T *ptr = (real_T *) ssGetDWork(S,TX_BUFF);
        if(ptr==NULL) {
            THROW_ERROR(S, "Failed to allocate memory for Receive Delay Buffer.");
        }
        ssSetPWorkValue(S, CUR_TX, ptr);
    }

    /*
     * CUR_FR is a PWork pointer to keep track of whether each sample is part
     * of the Usable Subframe.
     */
    {
        boolean_T *ptr = (boolean_T *) ssGetDWork(S,FR_BUFF);
        if(ptr==NULL) {
            THROW_ERROR(S, "Failed to allocate memory for Selected Samples "
                      "Buffer.");
        }
        ssSetPWorkValue(S, CUR_FR, ptr);
    }

    /*
     * If the Usable Subframe is specified as a parameter, define the
     * DWork now.
     */
    if (mxGetPr(CP_MODE)[0] < 3){
        int_T i = 0;
        int_T s_idx;
        boolean_T *use_frame = (boolean_T *) ssGetDWork(S,USE_FRAME);

        /*
         * If the block is to operate in 'Full frame' mode just fill this
         * vector with all ones.
         */
        if (mxGetPr(CP_MODE)[0] == 1) {
            for (i=0; i<(*width); i++) {
                *use_frame++ = true;
            }
        }else{
            /* find which specific elements to compare. */
            int_T num = mxGetN(SUB_FRAME);
            /* First place zeros in all elements of use_frame. */
            for (i=0; i<(*width); i++) {
                *use_frame++ = false;
            }
            use_frame = (boolean_T *) ssGetDWork(S,USE_FRAME);
            /*
             * Then put a one in each element whose index is included in
             * the parameter.
             */
            for (i=0; i<num; i++) {
                s_idx = (int_T)mxGetPr(SUB_FRAME)[i];
                if (s_idx > 0) {
                    use_frame[ --s_idx ] = true;
                }
            }
        }
    }
}

static void mdlOutputs(SimStruct *S, int_T tid)
{
    /* Define some variables and get the DWork values. */
    int_T idx;
    real_T err = 0;
    real_T sym = 0;
    int_T st_delay = (int_T)(mxGetPr(ST_DELAY)[0]);
    int_T rx_delay = (int_T)(mxGetPr(RX_DELAY)[0]);

    int_T tot_delay = st_delay + rx_delay;

    int_T  stop    = (int_T)(mxGetPr(STOP)[0]);
    real_T  num_err = (real_T)(mxGetPr(NUMERR)[0]);
    real_T  maxbits = (real_T)(mxGetPr(MAXBITS)[0]);
 
    
    real_T   *errors    = (real_T *)   ssGetDWork(S, ERRORS);
    real_T   *symbols   = (real_T *)   ssGetDWork(S, SYMBOLS);
    real_T    *ratio     = (real_T *)    ssGetDWork(S, RATIO);
    int32_T   *st_cnt    = (int32_T *)   ssGetDWork(S, ST_CNT);
    boolean_T *use_frame = (boolean_T *) ssGetDWork(S, USE_FRAME);
    int_T     *width     = (int_T *)     ssGetDWork(S, WIDTH);
    boolean_T *tx_scalar = (boolean_T *) ssGetDWork(S, TX_SCALAR);
    boolean_T *rx_scalar = (boolean_T *) ssGetDWork(S, RX_SCALAR);
 
    /* Set inf to zero, to ensure cross-platform consistency*/
    if(mxIsInf(mxGetPr(NUMERR)[0])){ num_err = 0;}
    if(mxIsInf(mxGetPr(MAXBITS)[0])){maxbits = 0;}

    /*
     * First check if the reset port is active.
     * If so all that needs to be done is reset the three values.
     */
    if (mxGetPr(RESET_BOX)[0]==1) {
        InputRealPtrsType uRsPtrs;
        /*
         * The Reset Port can be either the third or fourth port,
         * depends on whether the subframe is defined by an input port or
         * a parameter.
         */
        if (mxGetPr(CP_MODE)[0]==3) {
            uRsPtrs = ssGetInputPortRealSignalPtrs(S,OPT_PORT2);
        }else{
            uRsPtrs = ssGetInputPortRealSignalPtrs(S,OPT_PORT1);
        }

        if ( *((real_T *) uRsPtrs[0]) != 0 ) {
            *errors = 0;
            *symbols = 0;
            *ratio = 0;
	}
    }

    /* If the Usable Subframe is specified as an input, define the DWork */
    if (mxGetPr(CP_MODE)[0]==3) {
        int_T s_idx;
        int_T num = ssGetInputPortWidth(S, OPT_PORT1);
        int_T sz = ssGetInputPortWidth(S,OPT_PORT1);
        InputRealPtrsType uFrPtrs=ssGetInputPortRealSignalPtrs(S,OPT_PORT1);
        for (idx=0; idx<(*width); idx++) {
            use_frame[idx] = false;
        }
        for (idx=0; idx<num; idx++) {
            s_idx = (int_T)(*((real_T *) uFrPtrs[idx]));
            if ( s_idx > (*width) ) {
                THROW_ERROR(S, "Selected samples from frame elements must "
                          "not be larger than the input port width.");
            }
            if ( s_idx > 0 ) {
                use_frame[ --s_idx ] = true;
            }
        }
    }

    /* Here the actual comparison is made. */
    /* For complex inputs.... */
    if (ssGetInputPortComplexSignal(S,IN_PORT1) == COMPLEX_YES) {
        InputPtrsType uPtrs1 = ssGetInputPortSignalPtrs(S,IN_PORT1);
        InputPtrsType uPtrs2 = ssGetInputPortSignalPtrs(S,IN_PORT2);

        /* Cycle through each frame element. */
        for (idx=0; idx<(*width); idx++) {

            /* First retreive the pointers to the Tx Buffers. */
            creal_T   *cur_tx = (creal_T *)ssGetPWorkValue(S, CUR_TX);
            creal_T   *end_tx = (creal_T *)ssGetDWork(S,TX_BUFF) + rx_delay;
            boolean_T cur_fr;

            /* Get the new Tx signal */
            *cur_tx = *((creal_T *) uPtrs1[idx * !(*tx_scalar)]);
            cur_fr = use_frame[idx];

            /*
             * Step the pointers to the next spaces in the buffers, which
             * coincidentally is the location of the delayed Tx signal.
             */
            if ( cur_tx == end_tx ) {
                cur_tx = (creal_T *)ssGetDWork(S,TX_BUFF);
            }else{
                cur_tx++;
            }
            /* Store the new Tx Buffer pointers. */
            ssSetPWorkValue(S, CUR_TX, cur_tx);

            /*
             * The actual comparison is not performed until both delays
             * have been waited.
             */
            if ( (*st_cnt) < tot_delay ) {
                (*st_cnt)++;
            } else if ( cur_fr ) {
                /*
                 * Check if this particular sample is part of the Usable
                 * Subframe.
                 */
                /* Get the new Rx signal. */
                creal_T cu = *((creal_T *) uPtrs2[idx * !(*rx_scalar)]);
                sym++;

                /* The comparison. */
                if ( ((cur_tx->re != cu.re ) ||
                      (cur_tx->im != cu.im )) == 1) {
                    err++;
                }
            }
        }
    } else {
	/* For real inputs..... */
        InputRealPtrsType uPtrs1 = ssGetInputPortRealSignalPtrs(S,IN_PORT1);
        InputRealPtrsType uPtrs2 = ssGetInputPortRealSignalPtrs(S,IN_PORT2);

        /* Cycle through each usable frame element. */
        for (idx=0; idx<(*width); idx++) {
            /* First retreive the pointers to the Tx Buffers. */
            real_T    *cur_tx = (real_T *) ssGetPWorkValue(S, CUR_TX);
            real_T    *end_tx = (real_T *) ssGetDWork(S,TX_BUFF) + rx_delay;
            boolean_T cur_fr;

            /* Get the new Tx signal */
            *cur_tx = *((real_T *) uPtrs1[idx * !(*tx_scalar)]);
            cur_fr = use_frame[idx];

            /*
             * Step the pointers to the next space in the buffers, which
             * coincidentally is the location of the delayed Tx signal.
             */
            if ( cur_tx == end_tx ) {
                cur_tx = (real_T *)ssGetDWork(S,TX_BUFF);
            }else{
                cur_tx++;
            }

            /* Store the new Tx Buffer pointers. */
            ssSetPWorkValue(S, CUR_TX, cur_tx);

            /*
             * The actual comparison is not performed until both delays
             * have been waited.
             */
            if ( (*st_cnt) < tot_delay ) {
                (*st_cnt)++;
            }else if ( cur_fr ){
                /*
                 * Check if this particular sample is part of the Usable
                 * Subframe.
                 */

                /* Get the new Rx signal. */
                real_T ru = *((real_T *) uPtrs2[idx * !(*rx_scalar)]);
                sym++;
                /* The comparison. */
                if ( (*cur_tx != ru) == 1) {
                    err++;
                }
            }
        }
    }

    *errors += err;
    *symbols += sym;
    if ( *symbols > 0 ) {
        *ratio = 1.0 * (*errors) / (*symbols);
    }

    /* If the results are output to a port. */
    if (mxGetPr(OUTPUT)[0]==2) {
        real_T *y = ssGetOutputPortRealSignal(S,0);

        y[ERRORS] = *errors;
        y[SYMBOLS] = *symbols;
        y[RATIO] = *ratio;
    }

    /*Check to see if simulation should stop*/
    if(stop==1)
    {
        if( (*errors>=(num_err)) && (num_err!=0) ){
         ssSetStopRequested(S,1);
        }

        if( (*symbols>=(maxbits)) && (maxbits!=0) ){
         ssSetStopRequested(S,1);
        }
    }

}



#define MDL_SET_WORK_WIDTHS
static void mdlSetWorkWidths(SimStruct *S)
{
    /* One parameter is needed to determine size of a DWork variable. */
    int_T rx_delay = (int_T)mxGetPr(RX_DELAY)[0];

    ssSetNumDWork(S, NUM_DWORK);
    ssSetNumPWork(S, NUM_PWORK);

    ssSetDWorkWidth(        S, TX_SCALAR, 1);
    ssSetDWorkDataType(     S, TX_SCALAR, SS_BOOLEAN);
    ssSetDWorkComplexSignal(S, TX_SCALAR, COMPLEX_NO);

    ssSetDWorkWidth(        S, RX_SCALAR, 1);
    ssSetDWorkDataType(     S, RX_SCALAR, SS_BOOLEAN);
    ssSetDWorkComplexSignal(S, RX_SCALAR, COMPLEX_NO);

    /* The eigth DWork is used to keep track of the input port width. */
    ssSetDWorkWidth(        S, WIDTH, 1);
    ssSetDWorkDataType(     S, WIDTH, SS_INT32);
    ssSetDWorkComplexSignal(S, WIDTH, COMPLEX_NO);

    /*
     * The seventh DWork vector keeps track of which elements from the input
     * frames to compare. The size of this vector is determined by the width
     * of the first input port.
     */
    if ( ssGetInputPortWidth(S,IN_PORT1) > 1 ) {
        ssSetDWorkWidth(    S, USE_FRAME, ssGetInputPortWidth(S,IN_PORT1));
    }else{
        ssSetDWorkWidth(    S, USE_FRAME, ssGetInputPortWidth(S,IN_PORT2));
    }
    ssSetDWorkDataType(     S, USE_FRAME, SS_BOOLEAN);
    ssSetDWorkComplexSignal(S, USE_FRAME,
                            (ssGetInputPortComplexSignal(S,IN_PORT1)));

    /*
     * The fifth and sixth DWork variables are needed as a buffers for the
     * receive delay,  TX_BUFF is the buffer for the received signal itself.
     * FR_BUFF is the buffer that stores if each sample was part of the Usable
     * Subframe. Size of vectors determined by receive delay.
     * Complexity of TX_BUFF vector elements determined by input signal.
     * PWork pointers are also needed to index into these DWork vectors.
     */
    ssSetDWorkWidth(        S, TX_BUFF, (rx_delay + 1));
    ssSetDWorkDataType(     S, TX_BUFF, SS_DOUBLE);
    ssSetDWorkComplexSignal(S, TX_BUFF,
                            (ssGetInputPortComplexSignal(S,IN_PORT1)));

    ssSetDWorkWidth(        S, FR_BUFF, (rx_delay + 1));
    ssSetDWorkDataType(     S, FR_BUFF, SS_BOOLEAN);
    ssSetDWorkComplexSignal(S, FR_BUFF, COMPLEX_NO);

    /* The fourth DWork variable is a counter for the startup delay. */
    ssSetDWorkWidth(        S, ST_CNT, 1);
    ssSetDWorkDataType(     S, ST_CNT, SS_INT32);
    ssSetDWorkComplexSignal(S, ST_CNT, COMPLEX_NO);

    /* The three result variables: Ratio, Number of Errors, Number of Symbols.*/
    ssSetDWorkWidth(        S, ERRORS, 1);
    ssSetDWorkDataType(     S, ERRORS, SS_DOUBLE);
    ssSetDWorkComplexSignal(S, ERRORS, COMPLEX_NO);

    ssSetDWorkWidth(        S, SYMBOLS, 1);
    ssSetDWorkDataType(     S, SYMBOLS, SS_DOUBLE);
    ssSetDWorkComplexSignal(S, SYMBOLS, COMPLEX_NO);

    ssSetDWorkWidth(        S, RATIO, 1);
    ssSetDWorkDataType(     S, RATIO, SS_DOUBLE);
    ssSetDWorkComplexSignal(S, RATIO, COMPLEX_NO);
}

static void mdlTerminate(SimStruct *S)
{
#ifdef MATLAB_MEX_FILE
    /* Output the results to a workspace variable. */
    if (mxGetPr(OUTPUT)[0]==1) {
        char *out_name;		/* The output MATLAB variable name. */
        mxArray *out_vec;	/* The actual output MATLAB variable. */

        /* Get name of array to create in MATLAB workspace: */
        {
            const mxArray *pmat     = VAR_NAME;
            int_T name_len = mxGetNumberOfElements(pmat) + 1;

            out_name = (char *)mxCalloc(name_len, sizeof(char));
            /* Create a string from the input parameter array. */
            mxGetString(pmat, out_name, name_len);
        }

        /* Create result array in MATLAB's base workspace. */
        {
            int_T out_size[2];
            out_size[0] = 1;
            out_size[1] = 3;

            out_vec = mxCreateNumericArray(2, out_size, mxDOUBLE_CLASS, mxREAL);

        }
        /* Copy Error-Rate results to MATLAB array. */
        {
            real_T *v = mxGetPr(out_vec);

            real_T *errors = (real_T *) ssGetDWork(S,ERRORS);
            real_T *symbols = (real_T *) ssGetDWork(S,SYMBOLS);
            real_T *ratio = (real_T *) ssGetDWork(S,RATIO);

            v[ERRORS] = *errors;
            v[SYMBOLS] = *symbols;
            v[RATIO] = *ratio;
        }

        /* Determine the Destination Workspace and output the data */
        {
            char_T    *workspace;
            int_T      buflen;
            int_T      status;
            mxArray   *input_array[2];
            mxArray   *output_array[1];
            mxArray   *model[1];

            /* Get the string for the current root model */
            mexCallMATLAB(1, model, 0, NULL, "bdroot");

            /* Get the desitination workspace for output */
            input_array[0] = model[0];
            input_array[1] = mxCreateString("DstWorkSpace");

            /* NOTE: The command simget only returns the string
             * "current" and does not give you the correct state
             * of the DstWorkspace parameter for the model.  This
             * is a bug with simget that should be fixed. xxx
             */
            mexCallMATLAB(1, output_array, 2, input_array, "simget");

            buflen = mxGetNumberOfElements(output_array[0]) + 1;

            workspace = mxCalloc(buflen, sizeof(char));
            if(workspace == NULL) {
                THROW_ERROR(S, "Allocation failure when writing matrix to "
                          "workspace.");
            }

            status = mxGetString(output_array[0], workspace, buflen);
            if(status != 0) {
                THROW_ERROR(S, "Failed to determine destination workspace.");
            }

            /*
             * Put the output matrix into the workspace specified by
             * DstWorksSpace
             *
             *    (Simulink)     (MATLAB)
             *   DstWorkspace  Where we put array
             *   ------------  ------------------
             *     current       base
             */
            {
                char_T *dest_str = "base";
                if (mexPutVariable(dest_str, out_name, out_vec) != 0) {
                    THROW_ERROR(S, "Failed to transfer matrix to the requested "
                              "workspace.");
                }
            }

            mxFree(out_name);         /* Free the name allocation */
            mxFree(workspace);
            mxDestroyArray(input_array[1]);
            mxDestroyArray(input_array[0]);
            mxDestroyArray(output_array[0]);
            mxDestroyArray(out_vec);
        }
    }
#endif
}

#ifdef MATLAB_MEX_FILE /* Is this file being compiled as a MEX-file? */
#include "simulink.c" /* MEX-file interface mechanism */
#else
#include "cg_sfun.h" /* Code generation registration function */
#endif
