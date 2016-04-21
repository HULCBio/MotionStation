/*
 * SCOMCRCSYNDDETECT CRC syndrome detector removes the redundant bits from the 
 * input data frame and flags any frame errors in the data frames.
 *
 *  Copyright 1996-2003 The MathWorks, Inc.
 *  $Revision: 1.3.4.2 $  $Date: 2004/04/12 23:03:21 $	
 */

#define S_FUNCTION_NAME scomcrcsynddetect
#define S_FUNCTION_LEVEL 2

#include "comm_defs.h"

/* List input & output ports*/
enum {INPORT=0, NUM_INPORTS};
enum {OUTPORT1=0, OUTPORT2, NUM_OUTPORTS};

/* List the mask parameters*/
enum {POLY_ARGC=0, NUMBITS_ARGC, INISTATES_ARGC, NUM_CHECKSUMS_ARGC, NUM_ARGS}; 

#define POLY_ARG            (ssGetSFcnParam(S, POLY_ARGC))
#define NUMBITS_ARG         (ssGetSFcnParam(S, NUMBITS_ARGC))
#define INISTATES_ARG       (ssGetSFcnParam(S, INISTATES_ARGC))
#define NUM_CHECKSUMS_ARG   (ssGetSFcnParam(S, NUM_CHECKSUMS_ARGC))

#define COMM_CRC_INVALID_DIMS "Invalid dimensions are specified for the input or output port."


/* Function: mdlCheckParameters =============================================*/
#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S) 
{
     /* The mask checks for the polynomial, initial states and the number of 
      *  checksums parameters as entered by the user.  
      */
}
#endif

/* Function: mdlInitializeSizes =============================================*/
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
    if (!ssSetOutputPortDimensionInfo(S, OUTPORT1, DYNAMIC_DIMENSION)) return;
    ssSetOutputPortFrameData(         S, OUTPORT1, FRAME_YES);
    ssSetOutputPortComplexSignal(	  S, OUTPORT1, COMPLEX_NO);
    ssSetOutputPortReusable(     	  S, OUTPORT1, 0);

    if (!ssSetOutputPortDimensionInfo(S, OUTPORT2, DYNAMIC_DIMENSION)) return;
    ssSetOutputPortFrameData(         S, OUTPORT2, FRAME_YES);
    ssSetOutputPortComplexSignal(	  S, OUTPORT2, COMPLEX_NO);
    ssSetOutputPortReusable(     	  S, OUTPORT2, 0);

    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE);

    for (i=0; i<NUM_ARGS; i++)
        ssSetSFcnParamNotTunable(S, i);
}

/* Function: mdlInitializeSampleTimes =======================================*/
static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);

    if (ssGetSampleTime(S, 0) == CONTINUOUS_SAMPLE_TIME)	
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

/* Function: mdlOutputs =====================================================*/
static void mdlOutputs(SimStruct *S, int_T tid)
{
    real_T       *u      = (real_T *)ssGetInputPortRealSignal(S, INPORT);
    real_T       *y1     = (real_T *)ssGetOutputPortRealSignal(S, OUTPORT1);
    real_T       *y2     = (real_T *)ssGetOutputPortRealSignal(S, OUTPORT2); 
 
    const int_T  inPortWidth     = ssGetInputPortWidth(S, INPORT);
    const int_T  outPortWidth    = ssGetOutputPortWidth(S, OUTPORT1);
 
    uint32_T     genPoly         = (uint32_T)mxGetPr(POLY_ARG)[0];
    int_T        numBits         = (int_T)mxGetPr(NUMBITS_ARG)[0];
    uint32_T     shReg           = (uint32_T)mxGetPr(INISTATES_ARG)[0];
    int_T        numChecksums    = (int_T)mxGetPr(NUM_CHECKSUMS_ARG)[0];

    int_T        i, k; 
    uint32_T     inpBit, regOut, flag;
    uint32_T     iniReg = shReg;

    int_T  inFrameLength  = inPortWidth/numChecksums;
    int_T  outFrameLength = outPortWidth/numChecksums;

    for (k = 0; k < numChecksums; k++)
    {
        for(i=0; i < inFrameLength; i++)
        { 
    	    inpBit = (uint32_T)(*u++) & 0x1;

            if (i < outFrameLength)       /* original message bits */
			    *y1++ = (real_T) inpBit;
		    
            regOut = (shReg >> (numBits - 1)) & 0x1; /* get MSB of register */
            shReg <<= 1;                /* left shift by 1 */
            shReg += inpBit;            /* load the input bit */
            if (regOut) 
            {
                shReg ^= genPoly;       /* xor with poly if output was 1 */
            }
        }

        /* Output a flag to indicate if an error occurred (0 => no error) */
        flag = 0;
        for (i = 0; i < numBits; i++)
        {
            if ((shReg >> (numBits - i - 1)) & 0x1) {
                flag = 1;
                break;
            }
        }
        *y2++ = (real_T) flag;
        shReg = iniReg; /* re-initialize the register for next data frame*/
    }    /* End of numChecksums for loop */
}

static void mdlTerminate(SimStruct *S)
{
}

#if defined(MATLAB_MEX_FILE)
#define MDL_SET_INPUT_PORT_DIMENSION_INFO
static void mdlSetInputPortDimensionInfo(SimStruct *S, int_T port,
                                      const DimsInfo_T *dimsInfo)
{
    int outCols1, outRows1, outCols2, outRows2;
    int_T  numBits          = ((int_T)mxGetPr(NUMBITS_ARG)[0]);
    int_T  numChecksums    = ((int_T)mxGetPr(NUM_CHECKSUMS_ARG)[0]);
    
    if (!ssSetInputPortDimensionInfo(S, port, dimsInfo)) return;

    /* Check and/or set the value for the input/output ports */
    {
        const int     dataPortWidth  = ssGetInputPortWidth(S, INPORT);
        const int     numDims        = ssGetInputPortNumDimensions(S, INPORT);
        const int     inRows         = (numDims >= 1) ? dimsInfo->dims[0] : 0;
        const int     inCols         = (numDims >= 2) ? dimsInfo->dims[1] : 0;

        if (inCols != 1)
        {
            THROW_ERROR(S, "This block does not support multi-channel frame signals.");
        }

        if (fmod(inRows, numChecksums) !=0)
        {
            THROW_ERROR(S, "The input frame length must be an integer multiple of the number of checksums per frame.");
        }
        
        if ((inRows/numChecksums) <= numBits)
        {
            THROW_ERROR(S, "The input message block length must be greater than the degree of the generator polynomial.");
        }

        outCols1 = inCols;
        outCols2 = inCols;
        outRows1 = inRows - (numBits * numChecksums);
        outRows2 = numChecksums; 

        if (ssGetOutputPortWidth(S,OUTPORT1) == DYNAMICALLY_SIZED)
        {
            if (!ssSetOutputPortMatrixDimensions(S, \
                OUTPORT1, outRows1, outCols1)) return;
        } else 
        {
            if (ssGetOutputPortWidth(S, OUTPORT1) != outRows1) 
            {
                THROW_ERROR(S, COMM_CRC_INVALID_DIMS);
            }
        }

        if (ssGetOutputPortWidth(S,OUTPORT2) == DYNAMICALLY_SIZED)
        {
            if (!ssSetOutputPortMatrixDimensions(S, \
                OUTPORT2, outRows2, outCols2)) return;
        } else
        {
            if (ssGetOutputPortWidth(S, OUTPORT2) != outRows2)
            {
                THROW_ERROR(S, COMM_CRC_INVALID_DIMS);
            }
        }
    }
}

#define MDL_SET_OUTPUT_PORT_DIMENSION_INFO
static void mdlSetOutputPortDimensionInfo(SimStruct *S, int_T portIdx,
                                          const DimsInfo_T *dimsInfo)
{    
    int inCols, inRows;
    int_T  numBits        = ((int_T)mxGetPr(NUMBITS_ARG)[0]);
    int_T  numChecksums   = ((int_T)mxGetPr(NUM_CHECKSUMS_ARG)[0]);

    if (!ssSetOutputPortDimensionInfo(S, portIdx, dimsInfo)) return;

    /* Check and/or set the value for the input/output ports */
    {
        switch(portIdx)
        {
            case OUTPORT1:
            {
                int outRows2, outCols2;
                const int numDims  = ssGetOutputPortNumDimensions(S, OUTPORT1);
                const int outRows1 = (numDims >= 1) ? dimsInfo->dims[0] : 0;
                const int outCols1 = (numDims >= 2) ? dimsInfo->dims[1] : 0;

                if (outCols1 != 1)
                {
                   THROW_ERROR(S, "This block does not support multi-channel frame signals.");
                }

                if (fmod(outRows1, numChecksums) !=0)
                {
                    THROW_ERROR(S, "The output frame length must be an integer multiple of the number of checksums per frame.");
                }
        
                inCols = outCols1;
                inRows = outRows1 + (numChecksums * numBits);
                outCols2 = outCols1;
                outRows2 = numChecksums;
                
                if (ssGetInputPortWidth(S,INPORT) == DYNAMICALLY_SIZED) 
                {
                    if(!ssSetInputPortMatrixDimensions(S, \
                                            INPORT, inRows, inCols)) return;
                } else 
                {
                    if (ssGetInputPortWidth(S,INPORT) != inRows) 
                    {
                        THROW_ERROR(S, COMM_CRC_INVALID_DIMS);
                    }	
                }
                if (ssGetOutputPortWidth(S,OUTPORT2) == DYNAMICALLY_SIZED) 
                {
                    if(!ssSetOutputPortMatrixDimensions(S, \
                                        OUTPORT2, outRows2, outCols2)) return;
                } else 
                {
                    if (ssGetOutputPortWidth(S,OUTPORT2) != outRows2) 
                    {
                        THROW_ERROR(S, COMM_CRC_INVALID_DIMS);
                    }	
                }
                break;
            }
            case OUTPORT2:
            {
                const int numDims  = ssGetOutputPortNumDimensions(S, OUTPORT2);
                const int outRows2 = (numDims >= 1) ? dimsInfo->dims[0] : 0;
                const int outCols2 = (numDims >= 2) ? dimsInfo->dims[1] : 0;

                if (outCols2 != 1)
                {
                    THROW_ERROR(S, "This block does not support multi-channel frame signals.");
                }

                if (outRows2 != numChecksums)
                {
                    THROW_ERROR(S, "Error in port dimension propagation.");
                }
                break;
            }
            default:
                THROW_ERROR(S, "Invalid port index.");
        }
    }
}

#define MDL_SET_DEFAULT_PORT_DIMENSION_INFO
static void mdlSetDefaultPortDimensionInfo(SimStruct *S)
{
    /* initialize a dynamically-dimensioned DimsInfo_T */
    DECL_AND_INIT_DIMSINFO(dInfo); 
    int_T dims[2] = {1, 1};

    /* select scalar 2D dimensions */
    dInfo.width     = 1;
    dInfo.numDims   = 2;
    dInfo.dims      = dims;

    /* call the output functions */
    if (ssGetOutputPortWidth(S,OUTPORT1) == DYNAMICALLY_SIZED)
    { 
        mdlSetOutputPortDimensionInfo(S, OUTPORT1, &dInfo);
    }
    if (ssGetOutputPortWidth(S,OUTPORT2) == DYNAMICALLY_SIZED) 
    { 
        mdlSetOutputPortDimensionInfo(S, OUTPORT2, &dInfo);
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
