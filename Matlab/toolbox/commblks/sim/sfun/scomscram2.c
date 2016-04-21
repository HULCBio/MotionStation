/*
 *  SCOMSCRAM2  A sample-time driven Simulink scrambler.
 *              Updated to allow Frame-based signals. 
 *  
 *  $Revision: 1.7.4.1 $  $Date: 2003/12/01 19:00:19 $
 *  Copyright 1996-2003 The MathWorks, Inc.
 */


#define S_FUNCTION_NAME scomscram2
#define S_FUNCTION_LEVEL 2

#include "comm_defs.h"

#define BLOCK_BASED_SAMPLE_TIMES        1

/* D-work vectors */
enum {SHIFT_REG_IDX = 0, POLY_ORD_IDX, NUM_DWORKS};

/* Input/output ports */
enum {INPORT = 0, NUM_INPORTS};
enum {OUTPORT = 0, NUM_OUTPORTS};

/* S-fcn parameters */
enum {M_BASE_ARGC = 0, POLYNOMIAL_ARGC, MODE_ARGC, INITIAL_STATE_ARGC, 
      NUM_ARGS};
    
#define M_BASE_ARG          ssGetSFcnParam(S, M_BASE_ARGC)
#define POLYNOMIAL_ARG      ssGetSFcnParam(S, POLYNOMIAL_ARGC)
/*MODE: 0 scramble, 1 descramble */
#define MODE_ARG            ssGetSFcnParam(S, MODE_ARGC)
#define INITIAL_STATE_ARG   ssGetSFcnParam(S, INITIAL_STATE_ARGC)

#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S)
{
    /* Calculation Base parameter - positive, real, integer scalar*/
    if (OK_TO_CHECK_VAR(S, M_BASE_ARG))
    {
        if ( (mxGetNumberOfElements(M_BASE_ARG) != 1) ||
              mxIsComplex(M_BASE_ARG)                 ||
             (mxIsInf(mxGetPr(M_BASE_ARG)[0]))        ||
             (!IS_FLINT_GE(M_BASE_ARG,1))            
           ) {
                THROW_ERROR(S, "The calculation base parameter must be a "
                           "positive, real, integer scalar greater than 1.");
        }
    }

    /* Scramble polynomial parameter - real, integer vector */
    if (OK_TO_CHECK_VAR(S, POLYNOMIAL_ARG)) 
    {
        if ( (mxGetNumberOfElements(POLYNOMIAL_ARG) < 2) ||
             !mxIsNumeric(POLYNOMIAL_ARG)                ||
             mxIsSparse(POLYNOMIAL_ARG)
           ) {
                THROW_ERROR(S, "The scrambler polynomial parameter must be"
                               " a numeric vector.");
        }
    }

    /* Initial state parameter - real, integer vector or scalar */
    if (OK_TO_CHECK_VAR(S, INITIAL_STATE_ARG))
    {
        if ( (mxGetNumberOfElements(INITIAL_STATE_ARG) < 1) ||
             !mxIsNumeric(INITIAL_STATE_ARG)                ||
             mxIsSparse(INITIAL_STATE_ARG)
           ) {
                THROW_ERROR(S, "The initial state parameter must be numeric.");
        }
    }

    /* Function Mode - only 0 or 1*/
    if (OK_TO_CHECK_VAR(S, MODE_ARG))
    {
        if ( !mxIsDouble(MODE_ARG)                  ||
             (mxGetNumberOfElements(MODE_ARG) != 1) ||
             ( (mxGetPr(MODE_ARG)[0] != 0) && (mxGetPr(MODE_ARG)[0] != 1) )
           ) {
                THROW_ERROR(S, "Invalid function mode.");
        }
    }
}
#endif


static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumSFcnParams(S, NUM_ARGS);

#ifdef MATLAB_MEX_FILE
    if (ssGetNumSFcnParams(S) != NUM_ARGS) return;
    mdlCheckParameters(S);
    if (ssGetErrorStatus(S) != NULL) return;
#endif

    /* All parameters are non-tunable */
    ssSetSFcnParamTunable(S, M_BASE_ARGC, 0);
    ssSetSFcnParamTunable(S, POLYNOMIAL_ARGC, 0);
    ssSetSFcnParamTunable(S, MODE_ARGC, 0);
    ssSetSFcnParamTunable(S, INITIAL_STATE_ARGC, 0);

    /* Port parameters */
    if (!ssSetNumInputPorts(S, NUM_INPORTS)) return;
    if (!ssSetInputPortDimensionInfo(S, INPORT, DYNAMIC_DIMENSION)) return;
    ssSetInputPortFrameData(         S, INPORT, FRAME_INHERITED);
    ssSetInputPortComplexSignal(     S, INPORT, COMPLEX_NO);
    ssSetInputPortDirectFeedThrough( S, INPORT, 1);
    ssSetInputPortReusable(          S, INPORT, 1);
    ssSetInputPortRequiredContiguous(S, INPORT, 1);

    if (!ssSetNumOutputPorts(S, NUM_OUTPORTS)) return;
    if (!ssSetOutputPortDimensionInfo(S, OUTPORT, DYNAMIC_DIMENSION)) return;
    ssSetOutputPortFrameData(         S, OUTPORT, FRAME_INHERITED);
    ssSetOutputPortComplexSignal(     S, OUTPORT, COMPLEX_NO);
    ssSetOutputPortReusable(          S, OUTPORT, 1);

    /* Set up inport/outport sample times: only one rate*/
    ssSetNumSampleTimes(S, BLOCK_BASED_SAMPLE_TIMES);

    if (!ssSetNumDWork(S, DYNAMICALLY_SIZED)) return;
    ssSetNumDWork(S, DYNAMICALLY_SIZED);
    ssSetOptions( S, SS_OPTION_EXCEPTION_FREE_CODE);
}


#ifdef MATLAB_MEX_FILE
#define MDL_SET_WORK_WIDTHS
static void mdlSetWorkWidths(SimStruct *S)
{
    int_T polyOrder;
    polyOrder = mxGetN(POLYNOMIAL_ARG) * mxGetM(POLYNOMIAL_ARG) - 1;

    /* Set DWork vector */
    if (!ssSetNumDWork(S, NUM_DWORKS)) return;
        
    /* Polynomial Order*/
    ssSetDWorkName(         S, POLY_ORD_IDX, "DEGREE");
    ssSetDWorkWidth(        S, POLY_ORD_IDX, 1);
    ssSetDWorkDataType(     S, POLY_ORD_IDX, SS_INT32);
    ssSetDWorkComplexSignal(S, POLY_ORD_IDX, COMPLEX_NO);

    /* Shift Register */
    ssSetDWorkName(         S, SHIFT_REG_IDX, "REGISTER");
    ssSetDWorkWidth(        S, SHIFT_REG_IDX, polyOrder);
    ssSetDWorkDataType(     S, SHIFT_REG_IDX, SS_INT32);
    ssSetDWorkComplexSignal(S, SHIFT_REG_IDX, COMPLEX_NO);
    ssSetDWorkUsedAsDState( S, SHIFT_REG_IDX, SS_DWORK_USED_AS_DSTATE);
}
#endif


static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, FIXED_IN_MINOR_STEP_OFFSET);

    if (ssGetSampleTime(S, 0) == CONTINUOUS_SAMPLE_TIME)
    {
        THROW_ERROR(S, "Input sample time must be discrete.");
    }
    
    ssSetModelReferenceSampleTimeInheritanceRule(S, USE_DEFAULT_FOR_DISCRETE_INHERITANCE);
}


#define MDL_START
static void mdlStart(SimStruct *S)
{
    /* Error-checking among parameters is done in the mask 
       initialization function */
    UNUSED_ARG(S);
}


#define MDL_INITIALIZE_CONDITIONS
static void mdlInitializeConditions(SimStruct *S)
{
    int_T    i;
    real_T   *initial_state = (real_T *)mxGetPr(INITIAL_STATE_ARG);
    int_T    *shift_reg  = (int_T *)ssGetDWork(S, SHIFT_REG_IDX);
    int_T    *degree     = (int_T *)ssGetDWork(S, POLY_ORD_IDX);

    degree[0] = mxGetN(POLYNOMIAL_ARG) * mxGetM(POLYNOMIAL_ARG) - 1;

    /* Set up the Initial states */
    shift_reg[0] = 0;
    if (mxGetN(INITIAL_STATE_ARG) * mxGetM(INITIAL_STATE_ARG) == degree[0]) 
    {
        for (i = 0; i < degree[0]; i++)
            shift_reg[i] = (int_T)initial_state[i];
    } else { /* scalar expand */
        for (i = 0; i < degree[0]; i++)
            shift_reg[i] = (int_T)initial_state[0];
    }
}


static void mdlOutputs(SimStruct *S, int_T tid)
{
    int_T    i, j, tmp;

    int_T    *shift_reg  = (int_T *)ssGetDWork(S, SHIFT_REG_IDX);
    int_T    *degree     = (int_T *)ssGetDWork(S, POLY_ORD_IDX);

    int_T    M_base      = (int_T) mxGetPr(M_BASE_ARG)[0];
    int_T    MODE        = (int_T) mxGetPr(MODE_ARG)[0];
    real_T   *polynomial = (real_T *)mxGetPr(POLYNOMIAL_ARG);

          real_T *u           = (real_T *)ssGetInputPortRealSignal(S,INPORT);
          real_T *y           = (real_T *)ssGetOutputPortRealSignal(S,OUTPORT);
    const int_T   inPortWidth = ssGetInputPortWidth(S, INPORT);

    if(MODE==0)
    {   /* SCRAMBLER */

        /* Loop over the incoming samples */
        for (j = 0; j < inPortWidth; j++) 
        {
            tmp = (int_T)u[j];
            for (i = 1; i <= degree[0]; i++)
                tmp += (int_T)polynomial[i] * shift_reg[i-1];
            tmp = tmp % M_base;

            /* output */
            y[j] = tmp;

            /* shift */
            for (i = degree[0]-1; i > 0; i--)
                shift_reg[i] = shift_reg[i-1];
            shift_reg[0] = tmp;
        }
    }
    else if(MODE==1) 
    {   /* DESCRAMBLER */

        /* Loop over the incoming samples */
        for (j = 0; j < inPortWidth; j++) 
        {
            tmp = (int_T)u[j];
            for (i = 1; i <= degree[0]; i++)
                tmp -= (int_T)polynomial[i] * shift_reg[i-1];

            while(tmp<0) tmp += M_base;
            tmp = tmp % M_base;

            /* output */
            y[j] = tmp;

            /* shift */
            for (i = degree[0]-1; i > 0; i--)
                shift_reg[i] = shift_reg[i-1];
            shift_reg[0] = (int_T)u[j];
        }
    }
    
    UNUSED_ARG(tid);
}


static void mdlTerminate(SimStruct *S)
{
    UNUSED_ARG(S);
}


#if defined(MATLAB_MEX_FILE)
#define MDL_SET_INPUT_PORT_DIMENSION_INFO
static void mdlSetInputPortDimensionInfo(SimStruct *S, int_T port,
                                      const DimsInfo_T *dimsInfo)
{
    int_T outRows = 0;
    int_T outCols = 0;

    if(!ssSetInputPortDimensionInfo(S, port, dimsInfo)) return;
    
    {
        /* Port info */
        const boolean_T frameBased   = (boolean_T)
                                        ssGetInputPortFrameData(S,INPORT);
        const int_T     numDims      = ssGetInputPortNumDimensions(S, INPORT);
        const int_T     inRows       = (numDims>=1) ? dimsInfo->dims[0] : 0;
        const int_T     inCols       = (numDims>=2) ? dimsInfo->dims[1] : 0;
        const int_T     dataPortWidth= ssGetInputPortWidth(S, INPORT);

        if ( (numDims != 1) && (numDims != 2) ) 
        {
            THROW_ERROR(S, "Input must be 1D or 2D.");
        }

        if ( (frameBased) && (inCols > 1) )
        {
            THROW_ERROR(S, COMM_EMSG_NO_MULTICHAN_SIGNAL);
        } else if ( (!frameBased) && ( ((numDims==1) && (inRows != 1)) || 
                    ((numDims==2) && (inRows*inCols != 1)) ) )
        {
            THROW_ERROR(S, COMM_EMSG_SCALAR_INPUT);
        }

        outRows  = inRows;
        outCols  = inCols;

        /* Determine if Output port need setting */
        if (ssGetOutputPortWidth(S,OUTPORT) == DYNAMICALLY_SIZED) 
        {
            if (frameBased) { /* Assumes FB is 2D */
                if(!ssSetOutputPortMatrixDimensions(S, OUTPORT, \
                    outRows, outCols)) return;
            } else { /* Sample-Based */
                if (numDims==2) {
                    if(!ssSetOutputPortMatrixDimensions(S, OUTPORT, \
                        outRows, outCols)) return;
                } else {/* numDims==1*/
                    if(!ssSetOutputPortVectorDimension(S, OUTPORT, \
                        outRows)) return;
                }
            }
        } else {
            /* Output has been set, so do error checking. */
            if (dataPortWidth  != ssGetOutputPortWidth(S, OUTPORT))
            {
                THROW_ERROR(S, "Dimension propagation failed.");
            }
        }
    }
}


#define MDL_SET_OUTPUT_PORT_DIMENSION_INFO
static void mdlSetOutputPortDimensionInfo(SimStruct *S, int_T port,
                                          const DimsInfo_T *dimsInfo)
{
    int_T inRows =0;
    int_T inCols =0;

    if(!ssSetOutputPortDimensionInfo(S, port, dimsInfo)) return;

    {    
        /* Port info */
        const boolean_T frameBased = (boolean_T)
                               (ssGetInputPortFrameData(S,INPORT)==FRAME_YES);
        const int_T     numDims    = ssGetOutputPortNumDimensions(S, OUTPORT);
        const int_T     outRows    = (numDims>=1) ? dimsInfo->dims[0] : 0;
        const int_T     outCols    = (numDims>=2) ? dimsInfo->dims[1] : 0;
        const int_T     dataPortWidth  = ssGetOutputPortWidth(S, OUTPORT);

        if ( (numDims != 1) && (numDims != 2) ) 
        {
            THROW_ERROR(S, "Output must be 1-D or 2-D.");
        }
        
        if ( (frameBased) && (outCols > 1) )
        {
            THROW_ERROR(S, COMM_EMSG_NO_MULTICHAN_SIGNAL);
        } else if ( (!frameBased) && ( ((numDims==1) && (outRows != 1)) || 
                                     ((numDims==2) && (outRows*outCols != 1)) ) )
        {
            THROW_ERROR(S, COMM_EMSG_SCALAR_INPUT);
        }                

        inRows  = outRows;
        inCols  = outCols;

        /* Determine if inport need setting */
        if (ssGetInputPortWidth(S,INPORT) == DYNAMICALLY_SIZED) 
        {
            if (frameBased) { /* Assumes FB is 2D */
                if(!ssSetInputPortMatrixDimensions(S, INPORT, \
                   inRows, inCols)) return;
            } else { /* Sample-Based */
                if (numDims==2) {                
                    if(!ssSetInputPortMatrixDimensions(S, INPORT, \
                       inRows, inCols)) return;
                } else { /* numDims==1*/
                    if(!ssSetInputPortVectorDimension(S, INPORT, \
                       inRows)) return;
                }
            }
        } else 
        {
            /* Input has been set, so do error checking. */
            if (dataPortWidth  != ssGetInputPortWidth(S, INPORT))
            {
                THROW_ERROR(S, "Dimension propagation failed.");
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


#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-File interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
