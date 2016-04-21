/* Copyright 1994-2004 The MathWorks, Inc.
 * $Revision: 1.1.6.4 $
 * $Date: 2004/04/15 00:35:38 $
 *
 * File      : sfun_user_fxp_dtprop.c
 *
 * Abstract:
 *      User S-function Fixed-Point
 *      Data Type Propagaton Block
 *      Sets the data type of the third input so that it
 *      can represent the sum of the first two inputs without
 *      loss of precision and without possibility of overflow
 *      Custom WordLengths can be used such as 17 bits. 
 */


/*=====================================*
 * Required setup for C MEX S-Function *
 *=====================================*/
#define S_FUNCTION_NAME sfun_user_fxp_dtprop
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

static void mdlInitializeSizes(SimStruct *S)
{
    int i;
    int numInputPorts = 3;

    ssSetNumSFcnParams(S, 0);
    if (ssGetNumSFcnParams(S) != 0) return;
    
    if ( !ssSetNumOutputPorts(S, 0) )  return;

    if ( !ssSetNumInputPorts(  S, numInputPorts ) ) return;

    ssSetNumSampleTimes(S, 1);
    
    for ( i = 0; i < numInputPorts; i++ )
    {
        ssSetInputPortOffsetTime(S, i, 0.0 );
        
        ssSetInputPortDirectFeedThrough(S, i, FALSE );
        
        if(!ssSetInputPortDimensionInfo(S, i, DYNAMIC_DIMENSION)) return;
        
        ssSetInputPortFrameData(S, i, FRAME_INHERITED);
        
        ssSetInputPortDataType(  S, i, DYNAMICALLY_TYPED );
        
        ssSetInputPortReusable(S, i, TRUE);
        
        ssSetInputPortOverWritable(S, i, TRUE);
        
        ssSetInputPortComplexSignal(S, i, COMPLEX_INHERITED);
    }

    /* Other than propagate data types, this sfunction doesn't
     * do anything.  Request reduction so that efficiency of 
     * generated code is maximized.
     */    
    ssSetBlockReduction(S,TRUE);

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
    ssSetSampleTime( S, 0, INHERITED_SAMPLE_TIME );
    ssSetOffsetTime( S, 0, FIXED_IN_MINOR_STEP_OFFSET );
    ssSetModelReferenceSampleTimeDefaultInheritance(S);
}


static void mdlOutputs(SimStruct *S, int_T tid)
{
}


static void mdlTerminate(SimStruct *S)
{
}


#define MDL_SET_INPUT_PORT_DIMENSION_INFO
static void mdlSetInputPortDimensionInfo(SimStruct        *S, 
                                         int_T            port,
                                         const DimsInfo_T *pDimsInfo)
{
    /* accept any dimensions, there is no relationship between the dimensions
     * of any ports.
     */
    ssSetInputPortDimensionInfo(S,port, pDimsInfo);
}

# define MDL_SET_OUTPUT_PORT_DIMENSION_INFO
static void mdlSetOutputPortDimensionInfo(SimStruct        *S, 
                                          int_T            port,
                                          const DimsInfo_T *pDimsInfo)
{
    /* never an output port, but a consistency checker may complain, so
     * this functions only purpose is to shutup the checker.
     */
    ssSetOutputPortDimensionInfo(S,port, pDimsInfo);
}


# define MDL_SET_INPUT_PORT_FRAME_DATA
static void mdlSetInputPortFrameData(SimStruct  *S, 
                                     int_T      port,
                                     Frame_T    frameData)
{
    /* Accept frame status silently */
    ssSetInputPortFrameData(S, port, frameData);
}


#define     MDL_SET_INPUT_PORT_DATA_TYPE
static void mdlSetInputPortDataType(SimStruct *S, 
                                    int portIndex, 
                                    DTypeId dataTypeIdInput)
{
    DTypeId dataTypeIdU0;
    DTypeId dataTypeIdU1;

    DTypeId dataTypeIdU2Current;
    DTypeId dataTypeIdU2Desired;

    fxpStorageContainerCategory storageContainerU0;
    fxpStorageContainerCategory storageContainerU1;

    int isSignedU0;
    int isSignedU1;
    int isSignedU2;

    int wordLengthU0;
    int wordLengthU1;
    int wordLengthU2;

    double fracSlopeU0;
    double fracSlopeU1;

    int fixedExponentU0;
    int fixedExponentU1;
    int fixedExponentU2;

    int fixedExponentBiggerIn;

    double totalSlopeU0;
    double totalSlopeU1;
    double totalSlopeU2;

    double biasU0;
    double biasU1;
    double biasU2;

    int mostSignificantNonSignBitExpU0;
    int mostSignificantNonSignBitExpU1;
    int mostSignificantNonSignBitExpU2;

    int mostSignificantBitExpSmallerIn;

    int obeyDataTypeOverride = 1;

    if ( ssGetDataTypeIsFxpFltApiCompat( S, dataTypeIdInput ) == 0) 
    {
        ssSetErrorStatus(S,"Unrecognized data type.");
        return;
    }

    ssSetInputPortDataType( S, portIndex, dataTypeIdInput );
    
    dataTypeIdU0 = ssGetInputPortDataType(  S, 0 );
    dataTypeIdU1 = ssGetInputPortDataType(  S, 1 );
    
    dataTypeIdU2Current = ssGetInputPortDataType(  S, 2 );
    
    if ( dataTypeIdU0 == DYNAMICALLY_TYPED ||
         dataTypeIdU1 == DYNAMICALLY_TYPED )
    {
        /* can't set data type of third input
         * until first two are known
         */
        return;
    }
    
    storageContainerU0 = ssGetDataTypeStorageContainCat( S, dataTypeIdU0 );
    storageContainerU1 = ssGetDataTypeStorageContainCat( S, dataTypeIdU1 );
    
    if ( storageContainerU0 == FXP_STORAGE_DOUBLE ||
         storageContainerU1 == FXP_STORAGE_DOUBLE )
    {
        /* Doubles takes priority over all other rules.
         * if either of first two inputs is double,
         * then third input is set to double
         */
        dataTypeIdU2Desired = SS_DOUBLE;
    }
    else if ( storageContainerU0 == FXP_STORAGE_SINGLE ||
              storageContainerU1 == FXP_STORAGE_SINGLE )
    {
        /* Singles takes priority over all other rules, except doubles.
         * if either of first two inputs is single
         * then third input is set to single
         */
        dataTypeIdU2Desired = SS_SINGLE;
    }
    else
    {
        isSignedU0 = ssGetDataTypeFxpIsSigned( S, dataTypeIdU0 );
        isSignedU1 = ssGetDataTypeFxpIsSigned( S, dataTypeIdU1 );
        
        wordLengthU0 = ssGetDataTypeFxpWordLength( S, dataTypeIdU0 );
        wordLengthU1 = ssGetDataTypeFxpWordLength( S, dataTypeIdU1 );

        fracSlopeU0 = ssGetDataTypeFracSlope( S, dataTypeIdU0 );
        fracSlopeU1 = ssGetDataTypeFracSlope( S, dataTypeIdU1 );

        fixedExponentU0 = ssGetDataTypeFixedExponent( S, dataTypeIdU0 );
        fixedExponentU1 = ssGetDataTypeFixedExponent( S, dataTypeIdU1 );

        totalSlopeU0 = ssGetDataTypeTotalSlope( S, dataTypeIdU0 );
        totalSlopeU1 = ssGetDataTypeTotalSlope( S, dataTypeIdU1 );

        biasU0 = ssGetDataTypeBias( S, dataTypeIdU0 );
        biasU1 = ssGetDataTypeBias( S, dataTypeIdU1 );

        if ( fracSlopeU0 != fracSlopeU1 )
        {
            ssSetErrorStatus(S,"Can't get perfect sum if the inputs have different fractional slopes.");
            return;
        }
            
        /* Third input should have same precision as most precise input */
        if ( totalSlopeU0 <= totalSlopeU1 )
        {
            totalSlopeU2 = totalSlopeU0;
            fixedExponentU2 = fixedExponentU0;
        }
        else
        {
            totalSlopeU2 = totalSlopeU1;
            fixedExponentU2 = fixedExponentU1;
        }

        /* if either of first two inputs is signed, then third input
         * should be signed too.
         */
        isSignedU2 = ( isSignedU0 || isSignedU1 );

        /* the third inputs bias should be equal the sum
         * of the first and second inputs biases
         */
        biasU2 = biasU0 + biasU1;

        /* The wordLength of the third input must be large 
         * enough to cover the largest possible sum of the
         * two inputs (including any possible carry bit)
         *
         * The input with the largest positive range,
         * is the key item in determining the range required.
         */
        mostSignificantNonSignBitExpU0 = fixedExponentU0 + wordLengthU0 - 1 - isSignedU0;
        mostSignificantNonSignBitExpU1 = fixedExponentU1 + wordLengthU1 - 1 - isSignedU1;

        if ( mostSignificantNonSignBitExpU0 >= mostSignificantNonSignBitExpU1 )
        {
            mostSignificantNonSignBitExpU2 = mostSignificantNonSignBitExpU0;
            mostSignificantBitExpSmallerIn = mostSignificantNonSignBitExpU1 + isSignedU1;
            fixedExponentBiggerIn = fixedExponentU0;
        }
        else
        {
            mostSignificantNonSignBitExpU2 = mostSignificantNonSignBitExpU1;
            mostSignificantBitExpSmallerIn = mostSignificantNonSignBitExpU0 + isSignedU0;
            fixedExponentBiggerIn = fixedExponentU1;
        }

        /* If the inputs overlap, then a carry is possible
         * so the sum will require an extra bit
         *
         * Even if there is no overlap, the case of both being
         * unsigned can have a carry when the bigger input is at its
         * value closest to minus infinity and the smaller input is
         * also negative.
         */
        if ( ( isSignedU0 && isSignedU1 ) ||
             mostSignificantBitExpSmallerIn >= fixedExponentBiggerIn )
        {
            mostSignificantNonSignBitExpU2++;
        }

        wordLengthU2 = mostSignificantNonSignBitExpU2 - fixedExponentU2 + 1 + isSignedU2;

        if ( wordLengthU2 > FXP_MAX_BITS )
        {
            ssSetErrorStatus(S,"Perfect sum would require more than FXP_MAX_BITS bits.");
            return;
        }
                
        dataTypeIdU2Desired = ssRegisterDataTypeFxpSlopeBias(S,
                                                             isSignedU2,
                                                             wordLengthU2,
                                                             totalSlopeU2,
                                                             biasU2,
                                                             obeyDataTypeOverride);
    }

    if ( dataTypeIdU2Current == DYNAMICALLY_TYPED )
    {
        ssSetInputPortDataType( S, 2, dataTypeIdU2Desired );
    }
    else if ( dataTypeIdU2Current != dataTypeIdU2Desired ) 
    {
        ssSetErrorStatus(S,"The data type previously set for the third input does not agree with the data type need for ideal some of first and second inputs.");
        return;
    }
}


#define     MDL_SET_OUTPUT_PORT_DATA_TYPE
static void mdlSetOutputPortDataType(SimStruct *S, int portIndex, DTypeId portDataType)
{
    /* there are no output ports, 
     * but sometimes Simulink complains if these functions don't come in 
     * input and output pairs.
     */
}


# define MDL_SET_INPUT_PORT_COMPLEX_SIGNAL
static void mdlSetInputPortComplexSignal(SimStruct *S, int port, CSignal_T iPortComplexSignal)
{
    /* accept any complexity */
    ssSetInputPortComplexSignal( S, port, iPortComplexSignal);
}


# define MDL_SET_OUTPUT_PORT_COMPLEX_SIGNAL
static void mdlSetOutputPortComplexSignal(SimStruct *S, int port, CSignal_T oPortComplexSignal)
{
    /* there are no output ports, 
     * but sometimes Simulink complains if these functions don't come in 
     * input and output pairs.
     */
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
