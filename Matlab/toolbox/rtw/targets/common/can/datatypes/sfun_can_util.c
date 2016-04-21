/*
 * File: sfun_can_util.c
 *
 * Abstract:
 *    
 *
 *
 * $Revision: 1.9.4.1 $
 * $Date: 2004/04/19 01:20:26 $
 *
 * Copyright 2001-2002 The MathWorks, Inc.
 */

#define S_FUNCTION_NAME can_util_routines
#define S_FUNCTION_LEVEL 2

#include "sfun_can_util.h"
#include <stdlib.h>

/*
 * Initialize the CAN signal types in Simulink.
 * This should be called from every S-Function
 * in MdlInitializeSizes that want to use the CAN 
 * datatypes
 */
void CAN_Common_MdlInitSizes( SimStruct *S )
{
     DTypeId dataTypeId;

    if ( ssGetSimMode(S) != SS_SIMMODE_SIZES_CALL_ONLY )
    {
        /* protected from call during SS_SIMMODE_SIZES_CALL_ONLY */
        dataTypeId = ssGetDataTypeId( S, SL_CAN_EXTENDED_FRAME_DTYPE_NAME );

        if (dataTypeId == INVALID_DTYPE_ID) 
        {
            CAN_FRAME frame;
            dataTypeId = ssRegisterDataType( S,
                            SL_CAN_EXTENDED_FRAME_DTYPE_NAME );

            if ( dataTypeId == INVALID_DTYPE_ID ) return;

            ssSetDataTypeSize( S, dataTypeId, sizeof(CAN_FRAME) );

            initExtendedCanFrame(&frame);
            ssSetDataTypeZero( S, dataTypeId, &frame );
        }

        dataTypeId = ssGetDataTypeId( S, SL_CAN_STANDARD_FRAME_DTYPE_NAME );

        if (dataTypeId == INVALID_DTYPE_ID) 
        {
            CAN_FRAME frame;

            dataTypeId = ssRegisterDataType( S,
                            SL_CAN_STANDARD_FRAME_DTYPE_NAME);

            if ( dataTypeId == INVALID_DTYPE_ID ) return;

            ssSetDataTypeSize( S, dataTypeId, sizeof(CAN_FRAME) );

            initStandardCanFrame(&frame);
            ssSetDataTypeZero( S, dataTypeId, &frame );
        }
    }
} 

void CAN_write_rtw_frame( SimStruct * S, CAN_FRAME * frame){

   if ( ! ssWriteRTWStr(S,"SfcnCanFrameOutput {") ) goto Error_Exit;

   if ( ! ssWriteRTWStr(S,"InitialValue {") ) goto Error_Exit;

   /* ---- Write out the structure fields ------- */
   if (!ssWriteRTWScalarParam(S, "LENGTH",&frame->LENGTH,SS_UINT16)) goto Error_Exit; 
   if (!ssWriteRTWScalarParam(S, "RTR",&frame->RTR,SS_UINT16)) goto Error_Exit; 
   if (!ssWriteRTWScalarParam(S, "type",&frame->type,SS_UINT32)) goto Error_Exit; 
   if (!ssWriteRTWScalarParam(S, "ID",&frame->ID,SS_UINT32)) goto Error_Exit; 
   if (!ssWriteRTWVectParam(S, "DATA",&frame->DATA,DTINFO(SS_UINT8,0),8)) goto Error_Exit; 


   if ( ! ssWriteRTWStr(S,"}") ) goto Error_Exit;

   if ( ! ssWriteRTWStr(S,"}") ) goto Error_Exit;

   return;

Error_Exit:

    /*
     * give error message only if one has NOT already been set
     */
    if (ssGetErrorStatus(S) == NULL) {
        ssSetErrorStatus(S,
                         "Failed to write CAN port info to Real-Time Workshop file");
    }

    return;


}

