/*
 * SCOMCRCGEN generates CRC bits according to the specified polynomial
 * and appends the CRC frame (checksum) to the input data frame.
 *
 *   Copyright 1996-2003 The MathWorks, Inc.
 *   $Revision: 1.3.4.2 $  $Date: 2004/04/12 23:03:20 $
 */

#define S_FUNCTION_NAME scomcrcgen
#define S_FUNCTION_LEVEL 2

#include "comm_defs.h"

/* List input & output ports*/
enum {INPORT=0, NUM_INPORTS};
enum {OUTPORT=0, NUM_OUTPORTS};

/* List the mask parameters*/
enum {POLY_ARGC=0, NUMBITS_ARGC, INISTATES_ARGC, NUM_CHECKSUMS_ARGC, NUM_ARGS}; 

#define POLY_ARG		    (ssGetSFcnParam(S, POLY_ARGC))
#define NUMBITS_ARG		    (ssGetSFcnParam(S, NUMBITS_ARGC))
#define INISTATES_ARG       (ssGetSFcnParam(S, INISTATES_ARGC))
#define NUM_CHECKSUMS_ARG   (ssGetSFcnParam(S, NUM_CHECKSUMS_ARGC))

#define COMM_CRC_INVALID_DIMS "Invalid dimensions are specified for the input or output port."


/* Function: mdlCheckParameters =============================================*/
#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S) 
{
     /* The mask checks for the polynomial, initial states and the number of 
      * checksums parameters as entered by the user.  
      */
}
#endif

/* Function: mdlInitializeSizes ============================================*/
static void mdlInitializeSizes(SimStruct *S)
{
    int i;
    ssSetNumSFcnParams(S, NUM_ARGS);

#if defined(MATLAB_MEX_FILE)
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) return;
    mdlCheckParameters(S);
    if (ssGetErrorStatus(S) != NULL) return;
#endif

    ssSetNumSampleTimes(S, 1);

    /* Input: */
    if (!ssSetNumInputPorts(S, NUM_INPORTS)) return;
    if (!ssSetInputPortDimensionInfo(S, INPORT, DYNAMIC_DIMENSION)) return;
    ssSetInputPortFrameData(         S, INPORT, FRAME_YES);
    ssSetInputPortComplexSignal(     S, INPORT, COMPLEX_NO);
    ssSetInputPortDirectFeedThrough( S, INPORT, 1);
    ssSetInputPortRequiredContiguous(S, INPORT, 1);
    ssSetInputPortReusable(          S, INPORT, 0);

    /* Output: */
    if (!ssSetNumOutputPorts(S, NUM_OUTPORTS)) return;
    if (!ssSetOutputPortDimensionInfo(S, OUTPORT, DYNAMIC_DIMENSION)) return;
    ssSetOutputPortFrameData(         S, OUTPORT, FRAME_YES);
    ssSetOutputPortComplexSignal(     S, OUTPORT, COMPLEX_NO);
    ssSetOutputPortReusable(	      S, OUTPORT, 0);
    
    ssSetOptions( S, SS_OPTION_EXCEPTION_FREE_CODE);

    for (i=0; i<NUM_ARGS; i++)
    	ssSetSFcnParamNotTunable(S, i);
}

/* Function: mdlInitializeSampleTimes ======================================*/
static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);

    if (ssGetSampleTime(S,0) == CONTINUOUS_SAMPLE_TIME)	
    {
        THROW_ERROR(S, "Input sample time must be discrete.");
    }
    
    ssSetModelReferenceSampleTimeInheritanceRule(S, USE_DEFAULT_FOR_DISCRETE_INHERITANCE);
}

/* Function: mdlInitializeConditions ========================================*/
#define MDL_INITIALIZE_CONDITIONS
static void mdlInitializeConditions(SimStruct *S)
{
}

/* Function: mdlStart =======================================================*/
#define MDL_START
static void mdlStart (SimStruct *S)
{
}

/* Function: mdlOutputs ====================================================*/
static void mdlOutputs(SimStruct *S, int_T tid)
{
    real_T   *u   = (real_T *)ssGetInputPortRealSignal(S, INPORT);
    real_T   *y   = (real_T *)ssGetOutputPortRealSignal(S, OUTPORT);

    const int_T   inPortWidth   = ssGetInputPortWidth(S, INPORT);

    uint32_T genPoly        = (uint32_T)mxGetPr(POLY_ARG)[0];
    int_T    numBits        = (int_T)mxGetPr(NUMBITS_ARG)[0];
    uint32_T shReg          = (uint32_T)mxGetPr(INISTATES_ARG)[0];
    int_T    numChecksums   = (int_T)mxGetPr(NUM_CHECKSUMS_ARG)[0];

    int_T    i, k, outFrameLength;
    uint32_T inpBit, regOut;
    uint32_T iniReg = shReg; 

    int_T    inFrameLength = inPortWidth/numChecksums; 

    outFrameLength = inFrameLength + numBits;

    for (k = 0; k < numChecksums; k++) /* process for each data frame */
    {
        for (i = 0; i < outFrameLength; i++)
        {
            /* Get the Input */
            if (i < inFrameLength) /* input message bits*/
            {
                inpBit = (uint32_T)(*u++) & 0x1; /* get the LSB of the input */
                *y++ = (real_T) inpBit;          /* Will output only 0, 1's.*/
            }
            else  /* the appended zeros at the end */
            {
                inpBit = 0;
            }

            regOut = (shReg >> (numBits - 1)) & 0x1; /* get MSB of register */
            shReg <<= 1;     /* left shift by 1 */
            shReg += inpBit; /* load the input bit  */
            if (regOut)
            {
                shReg ^= genPoly; /* xor with poly if output was 1 */
            }
        }

        /* Feed out the register which has the remainder */
        for (i = 0; i < numBits; i++)
        {
            *y++ = (real_T)( (shReg >> (numBits - i - 1)) & 0x1 );
        }
        shReg = iniReg; /* re-initialize the register for next data frame */
    } /* End of numChecksums for loop */
}

static void mdlTerminate(SimStruct *S)
{
}

#ifdef MATLAB_MEX_FILE
#define MDL_SET_INPUT_PORT_DIMENSION_INFO
static void mdlSetInputPortDimensionInfo(SimStruct *S, int_T port,
                                      const DimsInfo_T *dimsInfo)
{
    int_T  outCols, outRows;
    int_T  numBits         = ((int_T)mxGetPr(NUMBITS_ARG)[0]);
    int_T  numChecksums   = ((int_T)mxGetPr(NUM_CHECKSUMS_ARG)[0]);
 
    if (!ssSetInputPortDimensionInfo(S, port, dimsInfo)) return;

    /* Check and/or set the value for the input port */
    {
		const int_T  numDims  = ssGetInputPortNumDimensions(S, INPORT);
		const int_T  inRows   = (numDims >= 1) ? dimsInfo->dims[0] : 0;
		const int_T  inCols   = (numDims >= 2) ? dimsInfo->dims[1] : 0;

        if (inCols != 1)
        {
            THROW_ERROR(S, "This block does not support multi-channel frame signals.");
        }

        if (fmod(inRows, numChecksums) !=0)
        {
            THROW_ERROR(S, "The input frame length must be an integer multiple of the number of checksums per frame.");
        }
        
        outCols = inCols;
        outRows = inRows + (numBits * numChecksums);

		if (ssGetOutputPortWidth(S,OUTPORT) == DYNAMICALLY_SIZED) 
		{
            if(!ssSetOutputPortMatrixDimensions(S, \
                                    OUTPORT, outRows, outCols)) return;
        } else 
        {
            if (ssGetOutputPortWidth(S, OUTPORT) != outRows) 
            {
                THROW_ERROR(S, COMM_CRC_INVALID_DIMS);
            }
        }                
    }
}

#define MDL_SET_OUTPUT_PORT_DIMENSION_INFO
static void mdlSetOutputPortDimensionInfo(SimStruct *S, int_T port,
                                          const DimsInfo_T *dimsInfo)
{
    int_T  inCols, inRows;
    int_T  numBits        = ((int_T)mxGetPr(NUMBITS_ARG)[0]);
    int_T  numChecksums   = ((int_T)mxGetPr(NUM_CHECKSUMS_ARG)[0]);
 
    if (!ssSetOutputPortDimensionInfo(S, port, dimsInfo)) return;

    /* Check and/or set the value for the output port */
    {
        const int_T     numDims  = ssGetOutputPortNumDimensions(S, OUTPORT);
        const int_T     outRows  = (numDims >= 1) ? dimsInfo->dims[0] : 0;
        const int_T     outCols  = (numDims >= 2) ? dimsInfo->dims[1] : 0;

        if (outCols != 1)
        {
            THROW_ERROR(S, "This block does not support multi-channel frame signals.");
        }

        if (fmod(outRows, numChecksums) !=0)
        {
            THROW_ERROR(S, "The output frame length must be an integer multiple of the number of checksums per frame.");
        }
        
        if ((outRows/numChecksums) <= numBits)
        {
            THROW_ERROR(S, "The output message block length must be greater than the degree of the generator polynomial.");
        }

        inCols = outCols;
        inRows = outRows - (numBits * numChecksums);

        if (ssGetInputPortWidth(S,INPORT) == DYNAMICALLY_SIZED) 
        {
            if(!ssSetInputPortMatrixDimensions(S, \
                                    INPORT, inRows, inCols)) return;
        } else 
        {
            if (ssGetInputPortWidth(S, INPORT) != inRows) 
            {
                THROW_ERROR(S, COMM_CRC_INVALID_DIMS);
            }
        }                 
    }
}

#define MDL_SET_DEFAULT_PORT_DIMENSION_INFO
static void mdlSetDefaultPortDimensionInfo(SimStruct *S)
{
    /* initialize a dynamically-dimensioned DimsInfo_T */
    DECL_AND_INIT_DIMSINFO(dInfo); 
    int_T dims[2] = {1, 1};

    /* select valid port dimensions */
    dInfo.width     = 1;
    dInfo.numDims   = 2;
    dInfo.dims      = dims;

    /* call the output functions */
    if (ssGetOutputPortWidth(S,OUTPORT) == DYNAMICALLY_SIZED) 
    { 
        mdlSetOutputPortDimensionInfo(S, OUTPORT, &dInfo);
    }

    /* call the input functions */
    if (ssGetInputPortWidth(S,INPORT) == DYNAMICALLY_SIZED) 
    { 
        mdlSetInputPortDimensionInfo(S, INPORT, &dInfo);
    }
}
#endif

#ifdef  MATLAB_MEX_FILE    
#include "simulink.c"      
#else
#include "cg_sfun.h"       
#endif
