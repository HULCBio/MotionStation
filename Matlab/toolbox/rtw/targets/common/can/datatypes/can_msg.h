/*
 * File: can_msg.h
 *
 * Abstract:
 *    Definition of CAN_MESSAGE types
 *
 *
 * $Revision: 1.12.6.3 $
 * $Date: 2004/04/19 01:20:25 $
 *
 * Copyright 2001-2003 The MathWorks, Inc.
 */

#ifndef H_SIM_CAN_DATATYPES
#define H_SIM_CAN_DATATYPES

#include "tmwtypes.h"

/* Enumeration of frame types */
typedef enum {CAN_MESSAGE_STANDARD, CAN_MESSAGE_EXTENDED} CanFrameType;

typedef struct {

   uint8_T LENGTH;

   uint8_T RTR;

   CanFrameType type;

   uint32_T ID;

   uint8_T DATA[8];

}  CAN_FRAME;

/*-------------------------------------------------------------------
 * Function initExtendedCanFrame
 *
 * Description
 *      
 *      Sets all the bits up for a default extended frame.
 * ----------------------------------------------------------------*/
void initStandardCanFrame(CAN_FRAME * cf);

/*-------------------------------------------------------------------
 * Function initStandardCanFrame
 *
 * Description
 *      
 *      Sets all the bits up for a default stand frame.
 * ----------------------------------------------------------------*/
void initExtendedCanFrame(CAN_FRAME * cf);

#endif 
