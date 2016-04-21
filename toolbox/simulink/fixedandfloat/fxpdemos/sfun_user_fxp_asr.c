/* Copyright 1994-2004 The MathWorks, Inc.
 * $Revision: 1.1.6.4 $
 * $Date: 2004/04/15 00:35:36 $
 *
 * File      : sfun_user_fxp_asr.c
 *
 * Abstract:
 *      User S-function Fixed-Point
 *      Arithmetic Shift Right Block
 *      Both the bits and the binary point are shifted right
 *      effectively bits of precision are discarded.
 */


/*=====================================*
 * Required setup for C MEX S-Function *
 *=====================================*/
#define S_FUNCTION_NAME sfun_user_fxp_asr
#define S_FUNCTION_LEVEL 2

/*
 * Define indices for s_function parameters
 */
enum {
    IDX_NUM_BITS_TO_SHIFT_RGHT,
    N_PAR
};

#include <math.h>
#include "simstruc.h"
#include "fixedpoint.h"

#define PMX_NUM_BITS_TO_SHIFT_RGHT ( ssGetSFcnParam(S, IDX_NUM_BITS_TO_SHIFT_RGHT))

#define V_NUM_BITS_TO_SHIFT_RGHT ( mxIsEmpty(PMX_NUM_BITS_TO_SHIFT_RGHT) ? 0 : (mxGetPr(PMX_NUM_BITS_TO_SHIFT_RGHT)[0]) )

#ifndef TRUE
#define TRUE 1
#endif 

#ifndef FALSE
#define FALSE 1
#endif 

static int basicParamCheck
(
 SimStruct *S,
 const mxArray *pOrigParam
)
{
    if ( ( ssGetSimMode(S) != SS_SIMMODE_SIZES_CALL_ONLY ) || !mxIsEmpty( pOrigParam ) )
    {
        if ( mxIsEmpty( pOrigParam ) )
        {
            ssSetErrorStatus(S,"An SFunction parameter was empty.");
            return 0;
        }

        if ( mxGetNumberOfElements( pOrigParam ) != 1 )
        {
            ssSetErrorStatus(S,"An SFunction parameter was not a scalar as required.");
            return 0;
        }
        if ( !mxIsDouble( pOrigParam ) )
        {
            ssSetErrorStatus(S,"SFunction parameter was not a double as required.");
            return 0;
        }
    }

    /* all parameters are OK */
    return 1;

} 



#define     MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S)
{
    if ( !basicParamCheck( S, PMX_NUM_BITS_TO_SHIFT_RGHT) ) return;

    if ( V_NUM_BITS_TO_SHIFT_RGHT <= 0 )
    {
        ssSetErrorStatus(S,"Number of bits to shift right must be strictly positive.");
    }
    if ( V_NUM_BITS_TO_SHIFT_RGHT >= 32 )
    {
        ssSetErrorStatus(S,"Number of bits to shift right must less than the width of the word.  Word is always 32 or fewer bits.");
    }

    if ( floor(V_NUM_BITS_TO_SHIFT_RGHT) != V_NUM_BITS_TO_SHIFT_RGHT )
    {
        ssSetErrorStatus(S,"Number of bits to shift right must be a whole number.");
    }
} 



static void mdlInitializeSizes(SimStruct *S)
{
    int i;

    ssSetNumSFcnParams(S, N_PAR);
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) return;

    mdlCheckParameters(S);
    if (ssGetErrorStatus(S) != NULL) return;

    if ( !ssSetNumOutputPorts(S, 1) )  return;

    if ( !ssSetNumInputPorts(  S, 1 ) ) return;

    for ( i = 0; i < N_PAR; i++ )
    {
        ssSetSFcnParamNotTunable( S, i );
    }

    ssSetOutputPortWidth(S,0,1);

    /* register data type
     */
    ssSetOutputPortDataType( S, 0, DYNAMICALLY_TYPED );

    ssSetOutputPortReusable(            S, 0, TRUE);

    ssSetOutputPortComplexSignal(S, 0, COMPLEX_NO );

    ssSetInputPortDirectFeedThrough( S, 0, TRUE );

    ssSetInputPortDataType( S, 0, DYNAMICALLY_TYPED );

    ssSetInputPortWidth( S, 0, 1 );

    ssSetInputPortReusable(S, 0, TRUE);

    ssSetInputPortOverWritable(S, 0, FALSE);

    ssSetInputPortComplexSignal( S, 0, COMPLEX_NO);

    ssSetInputPortRequiredContiguous( S, 0, TRUE );

    ssSetNumSampleTimes(   S, 1 );

    ssSetOptions( S,
                  SS_OPTION_DISCRETE_VALUED_OUTPUT   |
                  SS_OPTION_EXCEPTION_FREE_CODE      | 
                  SS_OPTION_USE_TLC_WITH_ACCELERATOR |
                  SS_OPTION_WORKS_WITH_CODE_REUSE |
                  SS_OPTION_NONVOLATILE |
                  SS_OPTION_CALL_TERMINATE_ON_EXIT |
                  SS_OPTION_CAN_BE_CALLED_CONDITIONALLY );
}



static void mdlInitializeSampleTimes(SimStruct *S)
{
  ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
  ssSetOffsetTime( S, 0, 0.0 );
  ssSetModelReferenceSampleTimeDefaultInheritance(S);
}



#define     MDL_SET_WORK_WIDTHS
static void mdlSetWorkWidths(SimStruct *S)
{
    DTypeId dataTypeId = ssGetOutputPortDataType( S, 0 );
      
    int vNumBits = ssGetDataTypeFxpWordLength( S, dataTypeId );
        
    if ( V_NUM_BITS_TO_SHIFT_RGHT >= vNumBits )
    {
        ssSetErrorStatus(S,"Number of bits to shift right must less than the width of the word.");
    }
} 



static int isDataTypeSupported(SimStruct *S, DTypeId dataTypeId)
{    
    int intDataTypeSupported = 0;

    if ( ssGetDataTypeIsFxpFltApiCompat( S, dataTypeId ) == 0) 
    {
        ssSetErrorStatus(S,"Unrecognized data type.");
        goto EXIT_POINT;
    }
    else
    {
        fxpStorageContainerCategory storageContainer = 
            ssGetDataTypeStorageContainCat( S, dataTypeId );

        switch ( storageContainer )
        {
          case FXP_STORAGE_UINT8:
          case FXP_STORAGE_INT8:
          case FXP_STORAGE_UINT16:
          case FXP_STORAGE_INT16:
          case FXP_STORAGE_UINT32:
          case FXP_STORAGE_INT32:
                
            if ( !ssGetDataTypeIsScalingPow2( S, dataTypeId ) )
            {
                ssSetErrorStatus(S,"Only fixed point data types with power of two scaling are supported.");
                goto EXIT_POINT;
            }
                
            intDataTypeSupported = 1;
            break;
            
          case FXP_STORAGE_SCALEDDOUBLE:
            
            ssSetErrorStatus(S,"Scaled doubles data types are not supported.");
            goto EXIT_POINT;
            break;
            
          case FXP_STORAGE_DOUBLE:
          case FXP_STORAGE_SINGLE:

            ssSetErrorStatus(S,"Floating point data types are not supported.");
            goto EXIT_POINT;
            break;
            
          case FXP_STORAGE_CHUNKARRAY:

            ssSetErrorStatus(S,"Fixed point data types with more than 32 bits are not supported.");
            goto EXIT_POINT;
            break;

          default:
            
            ssSetErrorStatus( S, "Unanticipated data type case." );
        }
    }

EXIT_POINT:
    return ( intDataTypeSupported );
}



#define MDL_SET_INPUT_PORT_DATA_TYPE
static void mdlSetInputPortDataType(SimStruct *S, int port, DTypeId dataTypeIdInput)
{
    if ( isDataTypeSupported( S, dataTypeIdInput ) )
    {
        DTypeId dataTypeIdOutput;

        ssSetInputPortDataType( S, port, dataTypeIdInput );

        dataTypeIdOutput = ssRegisterDataTypeFxpBinaryPoint(
            S,
            ssGetDataTypeFxpIsSigned(       S, dataTypeIdInput ),
            ssGetDataTypeFxpWordLength(     S, dataTypeIdInput ),
            ssGetDataTypeFractionLength(    S, dataTypeIdInput ) - V_NUM_BITS_TO_SHIFT_RGHT,
            0 /* false means do NOT obey data type override setting for this subsystem */ );

        ssSetOutputPortDataType( S, 0, dataTypeIdOutput );
    }
}


#define MDL_SET_OUTPUT_PORT_DATA_TYPE
static void mdlSetOutputPortDataType(SimStruct *S, int port, DTypeId dataTypeIdOutput)
{
    if ( isDataTypeSupported( S, dataTypeIdOutput ) )
    {
        DTypeId dataTypeIdInput;

        ssSetOutputPortDataType( S, port, dataTypeIdOutput );

        dataTypeIdInput = ssRegisterDataTypeFxpBinaryPoint(
            S,
            ssGetDataTypeFxpIsSigned(       S, dataTypeIdOutput ),
            ssGetDataTypeFxpWordLength(     S, dataTypeIdOutput ),
            ssGetDataTypeFractionLength(    S, dataTypeIdOutput ) + V_NUM_BITS_TO_SHIFT_RGHT,
            0 /* false means do NOT obey data type override setting for this subsystem */ );

        ssSetInputPortDataType( S, 0, dataTypeIdInput );
    }
}


static void mdlOutputs(SimStruct *S, int_T tid)
{
    void *pVoidOut = ssGetOutputPortSignal(S,0);

    const void *pVoidIn = (const void *)ssGetInputPortSignal(S,0);

    DTypeId dataTypeId = ssGetOutputPortDataType( S, 0 );
      
    fxpStorageContainerCategory storageContainer = 
        ssGetDataTypeStorageContainCat( S, dataTypeId );

    int nShiftRight = (int)V_NUM_BITS_TO_SHIFT_RGHT;

    switch ( storageContainer )
    {
      case FXP_STORAGE_UINT8:

        *((uint8_T  *)pVoidOut) = (uint8_T )( (*((uint8_T  *)pVoidIn)) >> nShiftRight);
        break;

      case FXP_STORAGE_INT8:

        *(( int8_T  *)pVoidOut) = ( int8_T )( (*(( int8_T  *)pVoidIn)) >> nShiftRight);
        break;

      case FXP_STORAGE_UINT16:

        *((uint16_T *)pVoidOut) = (uint16_T)( (*((uint16_T *)pVoidIn)) >> nShiftRight);
        break;

      case FXP_STORAGE_INT16:

        *(( int16_T *)pVoidOut) = ( int16_T)( (*(( int16_T *)pVoidIn)) >> nShiftRight);
        break;

      case FXP_STORAGE_UINT32:

        *((uint32_T *)pVoidOut) = (uint32_T)( (*((uint32_T *)pVoidIn)) >> nShiftRight);
        break;

      case FXP_STORAGE_INT32:

        *(( int32_T *)pVoidOut) = ( int32_T)( (*(( int32_T *)pVoidIn)) >> nShiftRight);
        break;
        
      default:

        ssSetErrorStatus( S, "This data type is not supported by this sfunction." );
    }
} 



static void mdlTerminate(SimStruct *S)
{
} 



/*=======================================*
 * Required closing for C MEX S-Function *
 *=======================================*/

#ifdef    MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
# include "simulink.c"     /* MEX-file interface mechanism               */
# include "fixedpoint.c"
#else
# include "cg_sfun.h"      /* Code generation registration function      */
#endif
