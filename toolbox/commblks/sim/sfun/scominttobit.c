/*
* SCOMINTTOBIT Communications Blockset S-Function for converting
* between integers and bits.
*
*  Copyright 1996-2004 The MathWorks, Inc.
*  $Revision: 1.15.4.3 $  $Date: 2004/04/12 23:03:29 $
*/

#define S_FUNCTION_NAME scominttobit
#define S_FUNCTION_LEVEL 2

#include "comm_defs.h"

/* List input & output ports*/
enum {INPORT=0, NUM_INPORTS};
enum {OUTPORT=0, NUM_OUTPORTS};

/* List the mask parameters*/
enum {NUM_BITC=0,CONVC, NUM_ARGS}; /* CONV=1, symbolizes bit to integer conversion
                                      CONV=2, symbolizes integer to bit conversion  */
#define CONV                    (ssGetSFcnParam(S,CONVC))
#define NUM_BIT                 (ssGetSFcnParam(S,NUM_BITC))


enum {BIT_INPUT=1, INTEGER_INPUT};
#define CONV_MODE               ((int_T)mxGetPr(CONV)[0])
#define IS_INTEGER_INPUT        ((int_T)mxGetPr(CONV)[0] == INTEGER_INPUT)
#define IS_BIT_INPUT            ((int_T)mxGetPr(CONV)[0] == BIT_INPUT)
#define N_BIT                   ((int_T)mxGetPr(NUM_BIT)[0])

#define BLOCK_BASED_SAMPLE_TIME 1



/* Function: mdlCheckParameters ===============================================*/
#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S)
{
    /*---Check to see if the Conversion parameter is either 1 or 2 ------*/
    if (!IS_FLINT_IN_RANGE(CONV,1,2))
    {
        THROW_ERROR(S,"Input type parameter is outside of expected range.");
    }
    /*---Check if number of bits per integer is a positive scalar integer---*/
    if (OK_TO_CHECK_VAR(S, NUM_BIT))
    {
        if (!IS_FLINT_IN_RANGE(NUM_BIT, 1, 31))
        {
            THROW_ERROR(S, "Number of bits parameter must be a scalar positive integer value less than 31.");
        }
    }
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

    ssSetNumSampleTimes(S, BLOCK_BASED_SAMPLE_TIME);

    /* Input: */
    if (!ssSetNumInputPorts(S, NUM_INPORTS)) return;
    if (!ssSetInputPortDimensionInfo(S, INPORT, DYNAMIC_DIMENSION)) return;
    ssSetInputPortFrameData(         S, INPORT, FRAME_INHERITED);
    ssSetInputPortComplexSignal(     S, INPORT, COMPLEX_NO);
    ssSetInputPortDirectFeedThrough( S, INPORT, 1);
    ssSetInputPortRequiredContiguous(S, INPORT, 1);
    ssSetInputPortReusable(          S, OUTPORT, 0);

    /* Output: */

    if (!ssSetNumOutputPorts(S, NUM_OUTPORTS)) return;
    if (!ssSetOutputPortDimensionInfo(S, OUTPORT, DYNAMIC_DIMENSION)) return;
    ssSetOutputPortFrameData(         S, OUTPORT, FRAME_INHERITED);
    ssSetOutputPortComplexSignal(S, OUTPORT, COMPLEX_NO);
    ssSetOutputPortReusable(     S, OUTPORT, 0);

    ssSetOptions( S, SS_OPTION_EXCEPTION_FREE_CODE         |
                     SS_OPTION_CAN_BE_CALLED_CONDITIONALLY );

    ssSetSFcnParamNotTunable(S, NUM_BITC);
    ssSetSFcnParamNotTunable(S, CONVC);
}
 /* End of mdlInitializeSizes(SimStruct *S) */

/* Function: mdlInitializeSampleTimes =========================================*/

static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, FIXED_IN_MINOR_STEP_OFFSET);
    
    ssSetModelReferenceSampleTimeInheritanceRule(S, USE_DEFAULT_FOR_DISCRETE_INHERITANCE);    
}

/* Function: mdlInitializeConditions ========================================*/

#define MDL_INITIALIZE_CONDITIONS
static void mdlInitializeConditions(SimStruct *S)
{
}

/* Function: mdlProcessParameters ===========================================*/
#define MDL_PROCESS_PARAMETERS
static void mdlProcessParameters(SimStruct *S)
{
}


/* Function: mdlStart =======================================================*/

#define MDL_START
static void mdlStart (SimStruct *S)
{
}
/* End of mdlStart (SimStruct *S) */

/* Function: mdlOutputs =======================================================*/
static void mdlOutputs(SimStruct *S, int_T tid)
{
    real_T        *uin   = (real_T *)ssGetInputPortRealSignal(S, INPORT);
    real_T        *y     = (real_T *)ssGetOutputPortRealSignal(S, OUTPORT);
    const int_T   InPortWidth     = ssGetInputPortWidth(S, INPORT);
    const int_T   SamplesPerInputFrame = (IS_BIT_INPUT) ? InPortWidth/N_BIT : InPortWidth;
    const int_T   M               = (int_T)pow(2,N_BIT);
    int_T i = 0, j = 0, uconv = 0, integer = 0, Count = 0, inc = -1;
    real_T u = 0.0;


    switch (CONV_MODE)
    {
        case INTEGER_INPUT:
            for (i = 0; i < SamplesPerInputFrame; i++)
            {
                Count = (i + 1) * N_BIT - 1;
                u  = *uin++;
                if ((u != floor(u)) || (u > (M-1)) || (u < 0.0))
                {
                    THROW_ERROR(S,"Input must be an integer in the range of 0 to (2^(number of bits per integer) - 1).");
                }
                uconv = (int_T)u;
                for (j = 0; j < N_BIT; j++)
                {
                    y[Count] = uconv%2;
                    uconv = uconv/2;
                    Count += inc;
                }
            }
            break;
        case BIT_INPUT:
            for (i = 0; i < SamplesPerInputFrame; i++)
            {
                for (j = 0; j < N_BIT; j++)
                {
                    integer<<=1;
                    u         = *uin++;
                    if((u != 0) && (u != 1))
                    {
                        THROW_ERROR(S,"Input must be binary.");
                    }
                    integer+= (int_T)u;
                }
                *y = integer;
                y++;
                integer = 0;
            }
            break;
        default:
            THROW_ERROR(S,"Invalid conversion mode.");
    }
}
/* End of mdlOutputs (SimStruct *S, int_T tid) */


static void mdlTerminate(SimStruct *S)
{
}

#if defined(MATLAB_MEX_FILE)
#define MDL_SET_INPUT_PORT_DIMENSION_INFO
static void mdlSetInputPortDimensionInfo(SimStruct *S, int_T port,
                                      const DimsInfo_T *dimsInfo)
{
    int_T outCols, outRows;

    if (!ssSetInputPortDimensionInfo(S, port, dimsInfo)) return;

    /* Check and/or set the value for the input port */
    if(ssGetInputPortConnected(S,INPORT) || ssGetOutputPortConnected(S,OUTPORT))
    {
        /* Port info */
        const boolean_T framebased = (boolean_T)ssGetInputPortFrameData(S,INPORT);
        const int_T     dataPortWidth  = ssGetInputPortWidth(S, INPORT);
        const int_T     numDims        = ssGetInputPortNumDimensions(S, INPORT);
        const int_T     inRows     = (numDims >= 1) ? dimsInfo->dims[0] : 0;
        const int_T     inCols     = (numDims >= 2) ? dimsInfo->dims[1] : 0;

        if ((numDims != 1) && (numDims != 2))
        {
            THROW_ERROR(S, "Input must be 1-D or 2-D.");
        }

        /* calculate the sizes for the output port */
        if (!framebased)
        {
            if (IS_INTEGER_INPUT)
            {
                if (dataPortWidth != 1)
                {
                    THROW_ERROR(S,"For sample-based inputs, the input must be a scalar.");
                }
                else
                {
                    outCols = inCols;
                    outRows = inRows * N_BIT;
                }
            }
            else /* BIT_INPUT */
            {
                /* Input width must equal N_BIT value*/
                if((dataPortWidth != N_BIT) || ((numDims == 2) && (inCols!=1) && (inRows!=1)))
                {
                    THROW_ERROR(S,"For sample-based inputs, the input must be a vector whose width equals the number of bits per integer.");
                }

                if ((numDims == 2) && (inCols > 1)) /* [1 x N_BIT] */
                {
                    outCols = inCols/N_BIT;
                    outRows = inRows;
                }
                else    /* [N_BIT x 1], N_BIT */
                {
                    outRows = inRows/N_BIT;
                    outCols = inCols;
                }
            }
        }
        else /* Frame-based */
        {
            if (inCols != 1)
            {
                THROW_ERROR(S,"In frame-based mode, input must be a column vector.");
            }
            else if ((IS_BIT_INPUT) && ((inRows % N_BIT) != 0))
            {
                THROW_ERROR(S,"In case of frame-based inputs, the input must be a column vector whose width is an integer multiple of the number of bits per integer.");
            }
            else
            {
                outCols = inCols;
                outRows = IS_BIT_INPUT ? inRows/N_BIT : inRows * N_BIT;
            }
        }

        /* Determine if Outport need setting */
        if (ssGetOutputPortWidth(S,OUTPORT) == DYNAMICALLY_SIZED)
        {

            if((numDims == 1) || ((!framebased) && (IS_INTEGER_INPUT)))
            {
                if(!ssSetOutputPortVectorDimension(S,OUTPORT,outRows)) return;
            }
            else
            {
                if(!ssSetOutputPortMatrixDimensions(S, OUTPORT, outRows, outCols)) return;
            }
        }
        else /* Output has been set, so do error checking. */
        {
            const int_T  numOutDims = ssGetOutputPortNumDimensions(S, OUTPORT);
            const int_T *outDims    = ssGetOutputPortDimensions(S, OUTPORT);
            const int_T  outRowsSet = (numOutDims >= 1) ? outDims[0] : 0;
            const int_T  outColsSet = (numOutDims >= 2) ? outDims[1] : 0;

            if((!framebased) && (IS_BIT_INPUT)
                && (numDims == 2) && (inCols > 1) /* [1 x N_BIT] -> [1 x 1] */
                && (outColsSet != outCols))
            {
                THROW_ERROR(S, "Port width propagation failed.");
            }
            else if (outRowsSet != outRows)
            {
                THROW_ERROR(S, "Port width propagation failed.");
            }
        }
    }
}


#define MDL_SET_OUTPUT_PORT_DIMENSION_INFO
static void mdlSetOutputPortDimensionInfo(SimStruct *S, int_T port,
                                          const DimsInfo_T *dimsInfo)
{
    int_T       inCols, inRows;

    if (!ssSetOutputPortDimensionInfo(S, port, dimsInfo)) return;

    /* Check and/or set the value for the output port */
    if(ssGetInputPortConnected(S,INPORT) || ssGetOutputPortConnected(S,OUTPORT))
    {
        /* Port info */
        const boolean_T framebased = (boolean_T)(ssGetInputPortFrameData(S,INPORT) == FRAME_YES);
        const int_T     dataPortWidth  = ssGetOutputPortWidth(S, OUTPORT);
        const int_T     numDims        = ssGetOutputPortNumDimensions(S, OUTPORT);
        const int_T     outRows        = (numDims >= 1) ? dimsInfo->dims[0] : 0;
        const int_T     outCols        = (numDims >= 2) ? dimsInfo->dims[1] : 0;

        if ((numDims != 1) && (numDims != 2))
        {
            THROW_ERROR(S, "Output must be 1-D or 2-D.");
        }

        /* calculate the sizes for the input port */
        if (framebased)
        {
            if (outCols != 1)
            {
                THROW_ERROR(S,"In frame-based mode, the input must be a column vector.");
            }

            if (IS_INTEGER_INPUT)
            {
                if ((dataPortWidth % N_BIT) != 0)
                {
                    THROW_ERROR(S, "In frame-based mode, the input must be a column vector whose width is an integer multiple of the number of bits per integer.");
                }
                else
                {
                    inCols = outCols;
                    inRows = outRows/N_BIT;
                }
            }
            else /* BIT_INPUT */
            {
                inCols = outCols;
                inRows = outRows * N_BIT;
            }
        }
        else /* Sample-based */
        {
            if (IS_INTEGER_INPUT) {
                if (dataPortWidth != N_BIT)
                {
                    if (dataPortWidth % N_BIT == 0)
                    {
                        THROW_ERROR(S,"In case of sample-based input, the input must be a scalar.");
                    }
                    else
                    {
                        THROW_ERROR(S,"In case of sample-based input, the 'Number of bits per integer' "
                        "parameter must match the output width and the input must be a scalar.");
                    }
                } else if (dataPortWidth == N_BIT)
                {
                    inRows = dataPortWidth/N_BIT;
                }
            } else if (IS_BIT_INPUT) {
                if (dataPortWidth != 1)
                {
                    THROW_ERROR(S,"In case of sample-based input, the input width must match the "
                    "'Number of bits per integer' parameter and the output must be a scalar.");
                } else {
                    if (numDims == 1){
                        inRows = dataPortWidth*N_BIT;
                    } else {
                        inRows = outRows*N_BIT;                        
                    }
                }
            }                
        }

        /* Determine if inport need setting,
           For sample-based case since port dimensions are ambiguous
           set the INPORT widths/dimensions to be 1D only. */
        if (ssGetInputPortWidth(S,INPORT) == DYNAMICALLY_SIZED)
        {
            if (numDims ==2) {
                if (framebased){
                    if(!ssSetInputPortMatrixDimensions(S, INPORT, inRows, inCols)) return;
                } else {
                    if(!ssSetInputPortVectorDimension(S, INPORT, inRows)) return;
                }
            } else {
                if(!ssSetInputPortVectorDimension(S, INPORT, inRows)) return;
            }
        } else /* Input has been set, so do error checking. */
        {
            const int_T  numInDims = ssGetInputPortNumDimensions(S, INPORT);
            const int_T *inDims    = ssGetInputPortDimensions(S, INPORT);
            const int_T  inRowsSet = (numInDims >= 1) ? inDims[0]: 0;
            const int_T  inColsSet = (numInDims >= 2) ? inDims[1]: 0;


            if(inRowsSet != inRows)
            {
                THROW_ERROR(S, "Port width propagation failed.");
            }
        }
    }
}
#endif

#ifdef  MATLAB_MEX_FILE
#include "simulink.c"
#else
#include "cg_sfun.h"
#endif
