/*
 * File: sfun_can_util.h
 *
 * Abstract:
 *
 *
 * $Revision: 1.9.4.1 $
 * $Date: 2004/04/19 01:20:27 $
 *
 * Copyright 2001-2002 The MathWorks, Inc.
 */

#ifndef H_SFUN_CAN_UTIL
#define H_SFUN_CAN_UTIL

/*---------------------------------------------------------------
*   Header File For Sfunction CAN utilities
*
*   This file should be included with any S-Function
*   blocks that require CAN specific data types. Do
*   not include this in any code that is to be
*   generated for a target. These exported functions
*   are purely for simulation mode.
*
*   Created 21-Dec-2000
*   Brad Phelan
*-----------------------------------------------------------------*/

#include "can_msg.h"
#include "simstruc.h"
#include "tmwtypes.h"

/*--------------------------------------------------------------
 * Data Type Names 
 *
 * Use these names with the macro
 *
 *      DTypeID ssGetDataTypeId(SimStruct *S, char *name)
 *
 * to retrieve a data type to set the datatype of a port. You
 * must call CAN_Common_MdlInitSizes first to ensure that
 * the data types are registered.
*-------------------------------------------------------------*/
#define SL_CAN_STANDARD_FRAME_DTYPE_NAME "CAN_MESSAGE_STANDARD"
#define SL_CAN_EXTENDED_FRAME_DTYPE_NAME "CAN_MESSAGE_EXTENDED"



/*--------------------------------------------------------------
 * Function CAN_Common_MdlInitSizes
 *
 * Description
 *
 *      Registers all the signal datatypes that are required to
 *      use the CAN signal blocks. Call this function in
 *      any MDLInitializeSizes callback of an S-function before
 *      you use the 
 *
 *      DTypeID ssGetDataTypeId(SimStruct *S, char *name)
 *
 *      methods to assign data types to your ports. The 
 *
 *--------------------------------------------------------------*/
void CAN_Common_MdlInitSizes( SimStruct *S );


/*------------------------------------------------------------
 * Function
 *    CAN_write_rtw_frame
 *      
 *
 * Purpose
 *
 *    To write out the initial values of an RTW frame that
 *    has constant sample time. 
 *
 * Arguments
 *
 *    S        -  SimStruct 
 *    frame    -  The frame to be written out
 *
 * Returns
 *
 *    nothing
 *
 *----------------------------------------------------------*/
void CAN_write_rtw_frame( SimStruct * S, CAN_FRAME * frame);

#endif
