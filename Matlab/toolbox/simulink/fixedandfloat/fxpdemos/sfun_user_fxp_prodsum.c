/* Copyright 1994-2004 The MathWorks, Inc.
 * $Revision: 1.1.6.4 $
 * $Date: 2004/04/15 00:35:39 $
 *
 * File      : sfun_user_fxp_prodsum.c
 *
 * Abstract:
 *      User S-function Fixed-Point
 *      Multiply the two inputs element by element and sum all the products
 *      using a hand written fixed point integer based C code.
 */


/*=====================================*
 * Required setup for C MEX S-Function *
 *=====================================*/
#define S_FUNCTION_NAME sfun_user_fxp_prodsum
#define S_FUNCTION_LEVEL 2

#include <math.h>
#include "simstruc.h"
#include "fixedpoint.h"

#ifndef TRUE
#define TRUE 1
#endif 

#ifndef FALSE
#define FALSE 1
#endif 


/* Example of user written legacy C code that implements
 * fixed point using integer math.
 */

#if ( SHRT_MAX != 32767 )
#error The interface from Simulink to the legacy C code assumes short is 16 bits, but this was not true.
#endif  

#if ( INT_MAX != 2147483647 )
#error The interface from Simulink to the legacy C code assumes int is 32 bits, but this was not true.
#endif  

static short fixpt_prodsum(const short *b, const short *x, int L, int shift_out) {
    long LSB_BY_2 = 1<<(shift_out-1);
    long ACC;
    int i;

    ACC = x[L-1] * b[0];
    for (i=1; i<L; i++) ACC += b[i] * x[L-1-i];
    return ((short)((ACC + LSB_BY_2) >> shift_out));    
}



static void mdlInitializeSizes(SimStruct *S)
{
    int i;

    ssSetNumSFcnParams(S, 0);
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) return;

    if ( !ssSetNumOutputPorts(S, 1) )  return;

    if ( !ssSetNumInputPorts(  S, 2 ) ) return;

    ssSetOutputPortWidth(S,0,1);

    /* register data type
     */
    ssSetOutputPortDataType( S, 0, DYNAMICALLY_TYPED );

    ssSetOutputPortReusable(            S, 0, TRUE);

    ssSetOutputPortComplexSignal(S, 0, COMPLEX_NO );


    ssSetInputPortDirectFeedThrough( S, 0, TRUE );
    ssSetInputPortDirectFeedThrough( S, 1, TRUE );

    ssSetInputPortDataType( S, 0, DYNAMICALLY_TYPED );
    ssSetInputPortDataType( S, 1, DYNAMICALLY_TYPED );

    ssSetInputPortWidth( S, 0, DYNAMICALLY_SIZED );
    ssSetInputPortWidth( S, 1, DYNAMICALLY_SIZED );

    ssSetInputPortReusable(S, 0, TRUE);
    ssSetInputPortReusable(S, 1, TRUE);

    ssSetInputPortOverWritable(S, 0, FALSE);
    ssSetInputPortOverWritable(S, 1, FALSE);

    ssSetInputPortComplexSignal( S, 0, COMPLEX_NO);
    ssSetInputPortComplexSignal( S, 1, COMPLEX_NO);

    ssSetInputPortRequiredContiguous( S, 0, TRUE );
    ssSetInputPortRequiredContiguous( S, 1, TRUE );

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
          case FXP_STORAGE_INT16:
                
            if ( !ssGetDataTypeIsScalingPow2( S, dataTypeId ) )
            {
                ssSetErrorStatus(S,"Only signed 16 bit fixed point data types with power of two scaling are supported.");
                goto EXIT_POINT;
            }
                
            intDataTypeSupported = 1;
            break;
            
          case FXP_STORAGE_UINT16:
          case FXP_STORAGE_UINT8:
          case FXP_STORAGE_INT8:
          case FXP_STORAGE_UINT32:
          case FXP_STORAGE_INT32:
                
            ssSetErrorStatus(S,"Only signed 16 bit fixed point data types with power of two scaling are supported.");
            goto EXIT_POINT;
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



static int getShiftOut(SimStruct *S)
{
    DTypeId dataTypeIdY0 = ssGetOutputPortDataType( S, 0 );
    DTypeId dataTypeIdU0 = ssGetInputPortDataType( S, 0 );
    DTypeId dataTypeIdU1 = ssGetInputPortDataType( S, 1 );
    
    int fracLenU0 = ssGetDataTypeFractionLength( S, dataTypeIdU0 );
    int fracLenU1 = ssGetDataTypeFractionLength( S, dataTypeIdU1 );
    int fracLenY0 = ssGetDataTypeFractionLength( S, dataTypeIdY0 );
            
    int shift_out = fracLenU0 + fracLenU1 - fracLenY0;

    return (shift_out);
}

static int checkPortDtAgreement(SimStruct *S)
{    
    int intDataTypesOfPortsCompatible = 1;

    DTypeId dataTypeIdU0 = ssGetInputPortDataType(  S, 0 );
    DTypeId dataTypeIdU1 = ssGetInputPortDataType(  S, 1 );
    DTypeId dataTypeIdY0 = ssGetOutputPortDataType( S, 0 );

    int knownFixPtU0  = 0;
    int knownFixPtU1  = 0;
    int knownFixPtY0  = 0;

    if ( dataTypeIdU0 != DYNAMICALLY_TYPED )
    {
        knownFixPtU0  = 1;
    }
    
    if ( dataTypeIdU1 != DYNAMICALLY_TYPED )
    {
        knownFixPtU1  = 1;
    }
    
    if ( dataTypeIdY0 != DYNAMICALLY_TYPED )
    {
        knownFixPtY0  = 1;
    }
    
    if ( knownFixPtU0 && knownFixPtU1 && knownFixPtY0  )
    {
        int shift_out = getShiftOut(S);

        if ( shift_out < 0 )
        {
            ssSetErrorStatus(S,"The output fraction length can not exceed the sum of the input fraction lengths.");
            intDataTypesOfPortsCompatible = 0;
            goto EXIT_POINT;
        }

        if ( shift_out > 31 )
        {
            ssSetErrorStatus(S,"The output fraction length can not be more than 31 bits less than the sum of the input fraction lengths.");
            intDataTypesOfPortsCompatible = 0;
            goto EXIT_POINT;
        }
    }

EXIT_POINT:
    return ( intDataTypesOfPortsCompatible );
}



#define MDL_SET_INPUT_PORT_DATA_TYPE
static void mdlSetInputPortDataType(SimStruct *S, int port, DTypeId dataTypeIdInput)
{
    if ( isDataTypeSupported( S, dataTypeIdInput ) )
    {
        ssSetInputPortDataType( S, port, dataTypeIdInput );

        checkPortDtAgreement(S);
    }
}


#define MDL_SET_OUTPUT_PORT_DATA_TYPE
static void mdlSetOutputPortDataType(SimStruct *S, int port, DTypeId dataTypeIdOutput)
{
    if ( isDataTypeSupported( S, dataTypeIdOutput ) )
    {
        ssSetOutputPortDataType( S, port, dataTypeIdOutput );

        checkPortDtAgreement(S);
    }
}


# define MDL_SET_INPUT_PORT_WIDTH
static void mdlSetInputPortWidth(SimStruct *S, int_T port,
                                 int_T inputPortWidth)
{
    if ( port >= 2 )
    {
        ssSetErrorStatus(S,"There are only 2 input ports.");
    }
    else
    {
        /* ports must have same width */
        ssSetInputPortWidth(S,0,inputPortWidth);
        ssSetInputPortWidth(S,1,inputPortWidth);
    }
}

# define MDL_SET_OUTPUT_PORT_WIDTH
static void mdlSetOutputPortWidth(SimStruct *S, int_T port,
                                  int_T outputPortWidth)
{
    ssSetErrorStatus(S,"Output port width already set, so mdlSetOutputPortWidth should not be called.");
}



static void mdlOutputs(SimStruct *S, int_T tid)
{
    int width = ssGetInputPortWidth( S, 0 );

    DTypeId dataTypeIdY0 = ssGetOutputPortDataType( S, 0 );
      
    fxpStorageContainerCategory storageContainer = 
        ssGetDataTypeStorageContainCat( S, dataTypeIdY0 );

    switch ( storageContainer )
    {
      case FXP_STORAGE_INT16:
        {
            int shift_out = getShiftOut(S);

            short *pShrtY0 = (short *)ssGetOutputPortSignal(S,0);

            const short *pShrtU0 = (const short *)ssGetInputPortSignal(S,0);
            
            const short *pShrtU1 = (const short *)ssGetInputPortSignal(S,1);

            *pShrtY0 = fixpt_prodsum( pShrtU0, pShrtU1, width, shift_out );

            break;
        }
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
