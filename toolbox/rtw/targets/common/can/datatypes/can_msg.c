/*
 * File: can_msg.c
 *
 * Abstract:
 *    Definition of CAN_MESSAGE types
 *
 *
 * $Revision: 1.9.4.2 $
 * $Date: 2004/04/19 01:20:24 $
 *
 * Copyright 2001-2003 The MathWorks, Inc.
 */

#include "can_msg.h"
#include <stdlib.h>

void initStandardCanFrame(CAN_FRAME * cf){
   cf->LENGTH=0;
   cf->ID=0;
   cf->RTR=0;
   cf->type=CAN_MESSAGE_STANDARD;

   cf->DATA[0]=0;
   cf->DATA[1]=0;
   cf->DATA[2]=0;
   cf->DATA[3]=0;
   cf->DATA[4]=0;
   cf->DATA[5]=0;
   cf->DATA[6]=0;
   cf->DATA[7]=0;
}

void initExtendedCanFrame(CAN_FRAME * cf){
   cf->LENGTH=0;
   cf->ID=0;
   cf->RTR=0;
   cf->type=CAN_MESSAGE_EXTENDED;

   cf->DATA[0]=0;
   cf->DATA[1]=0;
   cf->DATA[2]=0;
   cf->DATA[3]=0;
   cf->DATA[4]=0;
   cf->DATA[5]=0;
   cf->DATA[6]=0;
   cf->DATA[7]=0;
}




