/* Copyright 1994-2004 The MathWorks, Inc.
 * $Revision: 1.1.6.4 $
 * $Date: 2004/04/15 00:35:37 $
 *
 * File      : sfun_user_fxp_const.c
 *
 * Abstract:
 *      User S-function Fixed-Point CONSTANT.
 */


/*=====================================*
 * Required setup for C MEX S-Function *
 *=====================================*/
#define S_FUNCTION_NAME sfun_user_fxp_const
#define S_FUNCTION_LEVEL 2

/*
 * Define indices for s_function parameters
 */
enum {
    IDX_STORED_INTEGER_VALUE,
    IDX_ISSIGNED,
    IDX_WORDLENGTH,
    IDX_FRACTIONLENGTH,
    N_PAR
};

#include <math.h>
#include "simstruc.h"
#include "fixedpoint.h"

#define PMX_STORED_INTEGER_VALUE  ( ssGetSFcnParam(S, IDX_STORED_INTEGER_VALUE ))
#define PMX_ISSIGNED              ( ssGetSFcnParam(S, IDX_ISSIGNED             ))
#define PMX_WORDLENGTH            ( ssGetSFcnParam(S, IDX_WORDLENGTH           ))
#define PMX_FRACTIONLENGTH        ( ssGetSFcnParam(S, IDX_FRACTIONLENGTH       ))

#define V_STORED_INTEGER_VALUE  ( mxIsEmpty(PMX_STORED_INTEGER_VALUE ) ? 0 : (mxGetPr(PMX_STORED_INTEGER_VALUE )[0]) )
#define V_ISSIGNED              ( mxIsEmpty(PMX_ISSIGNED             ) ? 0 : (mxGetPr(PMX_ISSIGNED             )[0]) )
#define V_WORDLENGTH            ( mxIsEmpty(PMX_WORDLENGTH           ) ? 0 : (mxGetPr(PMX_WORDLENGTH           )[0]) )
#define V_FRACTIONLENGTH        ( mxIsEmpty(PMX_FRACTIONLENGTH       ) ? 0 : (mxGetPr(PMX_FRACTIONLENGTH       )[0]) )

#ifndef TRUE
#define TRUE 1
#endif 

#ifndef FALSE
#define FALSE 1
#endif 

/*
 * Userdata structure
 */
typedef struct UserDataStruct_tag {

  char *pCharValConst;   /* allocated memory */

  unsigned int uSizeAllocFixValConst;

} UserDataStruct;


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
    if ( !basicParamCheck( S, PMX_STORED_INTEGER_VALUE ) ) return;
    if ( !basicParamCheck( S, PMX_ISSIGNED             ) ) return;
    if ( !basicParamCheck( S, PMX_WORDLENGTH           ) ) return;
    if ( !basicParamCheck( S, PMX_FRACTIONLENGTH       ) ) return;

    if ( V_WORDLENGTH <= 0 || ( V_WORDLENGTH <= 1 && V_ISSIGNED ) )
    {
        ssSetErrorStatus(S,"The number of bits was too small.");
    }

    if ( V_WORDLENGTH > FXP_MAX_BITS )
    {
        ssSetErrorStatus(S,"The number of bits was too big.");
    }

} 



static void setValue(SimStruct *S, void *pVoidOut)
{
    DTypeId dataTypeId = ssGetOutputPortDataType( S, 0 );
      
    double storedIntVal = V_STORED_INTEGER_VALUE;

    fxpStorageContainerCategory storageContainer = 
        ssGetDataTypeStorageContainCat( S, dataTypeId );

    if ( ssGetDataTypeIsFixedPoint( S, dataTypeId ) )
    {
        /* force stored integer value to be in range */

        double minInt, maxInt;
        
        int vNumBits = ssGetDataTypeFxpWordLength( S, dataTypeId );
        
        int isSigned = ssGetDataTypeFxpIsSigned( S, dataTypeId );

        if ( !isSigned )
        {
            minInt = 0.0;
            maxInt = ldexp( 1.0, vNumBits ) - 1.0;
        }
        else
        {
            maxInt = ldexp( 1.0, (vNumBits - 1.0) ) ;
            minInt = -maxInt;
            maxInt -= 1.0;
        }
        
        if ( storedIntVal <= minInt )
        {
            storedIntVal = minInt;
        }
        else if ( storedIntVal >= maxInt )
        {
            storedIntVal = maxInt;
        }
    }

    switch ( storageContainer )
    {
      case FXP_STORAGE_UINT8:

        *((uint8_T  *)pVoidOut) = (uint8_T )storedIntVal;
        break;

      case FXP_STORAGE_INT8:

        *(( int8_T  *)pVoidOut) = ( int8_T )storedIntVal;
        break;

      case FXP_STORAGE_UINT16:

        *((uint16_T *)pVoidOut) = (uint16_T)storedIntVal;
        break;

      case FXP_STORAGE_INT16:

        *(( int16_T *)pVoidOut) = ( int16_T)storedIntVal;
        break;

      case FXP_STORAGE_UINT32:

        *((uint32_T *)pVoidOut) = (uint32_T)storedIntVal;
        break;

      case FXP_STORAGE_INT32:

        *(( int32_T *)pVoidOut) = ( int32_T)storedIntVal;
        break;

      case FXP_STORAGE_SCALEDDOUBLE:

        *(( double  *)pVoidOut) = storedIntVal;
        break;

      case FXP_STORAGE_DOUBLE:

        /* Data Type Override must have be set to True Doubles for this subsystem.
         * Convert stored integer value to Real World Value before setting output.
         */
        *(( double  *)pVoidOut) = ldexp(storedIntVal,-1.0*V_FRACTIONLENGTH);
        break;

      case FXP_STORAGE_SINGLE:

        /* Data Type Override must have be set to True Singles for this subsystem.
         * Convert stored integer value to Real World Value before setting output.
         */
        *(( float   *)pVoidOut) = (float)ldexp(storedIntVal,-1.0*V_FRACTIONLENGTH);
        break;

      case FXP_STORAGE_CHUNKARRAY:
        {
            fxpChunkArray chunkArray;

            int vNumBits = ssGetDataTypeFxpWordLength( S, dataTypeId );
            
            int indexChunk;
            int indexMostSignificantUsedChunk;
            int indexBit;
            
            double absValue;
            double remainder;
            double divisor = ldexp( 1.0, FXP_BITS_PER_CHUNK );
            
            for ( indexChunk = 0; indexChunk < FXP_NUM_CHUNKS; indexChunk++ )
            {
                /* force all bits used and unused to zero */
                chunkArray.chunk[indexChunk] = 0;
            }
            
            if ( storedIntVal < 0 )
            {
                absValue = -storedIntVal;
            }
            else
            {
                absValue = storedIntVal;
            }
            
            indexMostSignificantUsedChunk = ( (unsigned int)vNumBits - 1 ) / FXP_BITS_PER_CHUNK ;
            
            for ( indexChunk = 0; indexChunk <= indexMostSignificantUsedChunk; indexChunk++ )
            {
                remainder = fmod( absValue, divisor );
                
                chunkArray.chunk[indexChunk] = remainder;
                
                absValue -= remainder;
                absValue /= divisor;
            }
            
            if ( storedIntVal < 0 )
            {
                /* two's complement result */
                
                int carryBit = 1;
                
                for ( indexChunk = 0; indexChunk <= indexMostSignificantUsedChunk; indexChunk++ )
                {
                    chunkArray.chunk[indexChunk] = ~chunkArray.chunk[indexChunk];
                    
                    if ( carryBit )
                    {
                        chunkArray.chunk[indexChunk] += 1;
                        
                        if ( chunkArray.chunk[indexChunk] == 0 )
                        {
                            carryBit = 1;
                        }
                        else
                        {
                            carryBit = 0;
                        }
                    }
                }
                /* force any unused bits in the most significant chunks 
                 *  to be zero 
                 */
                {
                    FXP_CHUNK_T mask = FXP_ALL_ONES_CHUNK;
                    
                    int unusedBits = ( indexMostSignificantUsedChunk + 1 ) * FXP_BITS_PER_CHUNK - vNumBits;
                    
                    mask >>= unusedBits;
                    
                    chunkArray.chunk[indexMostSignificantUsedChunk] &= mask;
                }
            }
            
            *((fxpChunkArray *)pVoidOut) = chunkArray;
        }
        break;

      default:

        ssSetErrorStatus( S, "Unanticipated data type case." );
    } 
} 



#define     MDL_PROCESS_PARAMETERS
static void mdlProcessParameters(SimStruct *S)
{
    UserDataStruct *userData = ssGetUserData(S);

    setValue(S,(void *)userData->pCharValConst);
}



static void mdlInitializeSizes(SimStruct *S)
{
    int i;

    int notSizesOnlyCall = ( ssGetSimMode(S) != SS_SIMMODE_SIZES_CALL_ONLY );

    ssSetNumSFcnParams(S, N_PAR);
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) return;

    mdlCheckParameters(S);
    if (ssGetErrorStatus(S) != NULL) return;

    if ( !ssSetNumOutputPorts(S, 1) )  return;

    if ( !ssSetNumInputPorts(  S, 0 ) ) return;

    for ( i = 0; i < N_PAR; i++ )
    {
        ssSetSFcnParamNotTunable( S, i );
    }

    ssSetOutputPortWidth(S,0,1);

    /* register data type
     */
    if ( notSizesOnlyCall )
    {
        DTypeId DataTypeId = ssRegisterDataTypeFxpBinaryPoint(
            S,
            V_ISSIGNED,
            V_WORDLENGTH,
            V_FRACTIONLENGTH,
            1 /* true means obey data type override setting for this subsystem */ );

            ssSetOutputPortDataType( S, 0, DataTypeId );
    }
    else
    {
        ssSetOutputPortDataType( S, 0, DYNAMICALLY_TYPED );
    }

    ssSetOutputPortReusable(            S, 0, TRUE);

    ssSetOutputPortConstOutputExprInRTW(S, 0, TRUE);

    ssSetOutputPortComplexSignal(S, 0, COMPLEX_NO );

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
  ssSetSampleTime( S, 0, mxGetInf() );
  ssSetOffsetTime( S, 0, 0.0 );
  ssSetModelReferenceSampleTimeDefaultInheritance(S);
}



static void InitUserData(SimStruct *S)
{
    UserDataStruct    *userData = ssGetUserData(S);

    if (userData != NULL)
    {
        ssSetErrorStatus(S,"UserData not NULL before InitUserData.");
        return;
    }

    userData = malloc(sizeof(UserDataStruct));

    if ( userData == NULL )
    {
        ssSetErrorStatus(S,"Unable to allocate memory for user data.");
        return;
    }

    /*  in userData
     *  initialize any pointers to allocated memory to NULL
     *
     * NOTE: If InitUserData is called then, mdlTerminate will
     *       also be called.  Any and all allocated parts of
     *       userData with non-NULL pointers must
     *       be freed there.
     */
    userData->pCharValConst = NULL;

    ssSetUserData(S, (void *)userData);

    userData->uSizeAllocFixValConst = ssGetDataTypeSize(S,ssGetOutputPortDataType(S,0));

    userData->pCharValConst = malloc( userData->uSizeAllocFixValConst );

    if ( userData->pCharValConst == NULL )
    {
        ssSetErrorStatus(S,"Unable to allocate memory for constant vector.");
        return;
    }
} 



#define     MDL_SET_WORK_WIDTHS
static void mdlSetWorkWidths(SimStruct *S)
{
  UserDataStruct *userData;

  InitUserData(S);

  if (ssGetErrorStatus(S) != NULL) return;

  userData = ssGetUserData(S);

  mdlProcessParameters(S);

  if (ssGetErrorStatus(S) != NULL) return;

  if (!ssSetNumRunTimeParams(S, 1)) 
  {
      return; /* An error occurred. Simulink will display a message */
  }
  else 
  {
      ssParamRec    p;

      int indexToSfunParamList = IDX_STORED_INTEGER_VALUE;
                
      int dim = mxGetNumberOfElements( ssGetSFcnParam(S,indexToSfunParamList) );
      
      int paramIsComplex = mxIsComplex( ssGetSFcnParam(S,indexToSfunParamList) );
      
      DTypeId dataTypeId = ssGetOutputPortDataType( S, 0 );
      
      if (ssGetErrorStatus(S) != NULL) return;
      
      p.name               = "Constant";
      p.nDimensions        = 1;
      p.dimensions         = &dim;
      p.dataTypeId         = dataTypeId;
      p.complexSignal      = paramIsComplex;
      p.data               = userData->pCharValConst;
      p.dataAttributes     = NULL;
      p.nDlgParamIndices   = 1;
      p.dlgParamIndices    = &indexToSfunParamList;
      p.transformed        = RTPARAM_MAKE_TRANSFORMED_TUNABLE;
      p.outputAsMatrix     = FALSE;
      
      ssSetRunTimeParamInfo(S, 0, &p);
  }  
} 



#define     MDL_START
static void mdlStart(SimStruct *S)
{
    void *pVoidOut = ssGetOutputPortSignal(S,0);

    UserDataStruct *userData = ssGetUserData(S);

    memcpy( pVoidOut, userData->pCharValConst, userData->uSizeAllocFixValConst );

}



static void mdlOutputs(SimStruct *S, int_T tid)
{
    void *pVoidOut = ssGetOutputPortSignal(S,0);

    UserDataStruct *userData = ssGetUserData(S);

    memcpy( pVoidOut, userData->pCharValConst, userData->uSizeAllocFixValConst );
} 



static void mdlTerminate(SimStruct *S)
{
    UserDataStruct    *userData = ssGetUserData(S);

    if (userData != NULL)
    {
        if (userData->pCharValConst != NULL) free(userData->pCharValConst);
        free(userData);
        ssSetUserData(S, NULL);
    }
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




