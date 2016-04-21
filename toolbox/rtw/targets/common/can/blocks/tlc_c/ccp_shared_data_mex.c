/*
 * File: ccp_shared_data_mex.c
 *
 * Abstract:
 * 
 * Mex file that implements Simulation time shared data for the CCP 
 * Block
 *
 *
 * $Revision: 1.1.4.2 $
 * $Date: 2004/04/19 01:19:46 $
 *
 * Copyright 1990-2003 The MathWorks, Inc.
 */

#include "ccp_shared_data_mex.h"

/* persistent shared data - initialise to 0
 *
 * S-functions that need to share this data will make calls to
 * this mex function in order to get and set the data */
static struct ccp_shared_data ccp = {{0,0}, {0,0}, {0,0}, {0,0}, 0, {0,0,0,0,0,0,0,0}, 0, CCP_DISCONNECTED_STATE};

void mexFunction(
      int nlhs,              // Number of left hand side (output) arguments
      mxArray *plhs[],       // Array of left hand side arguments
      int nrhs,              // Number of right hand side (input) arguments
      const mxArray *prhs[]  // Array of right hand side arguments
      )
{
   /* the command string */
   int command; 
   if (nrhs > 0) {
      /* retrieve the command number from prhs */
      command = (int) mxGetScalar(prhs[0]); 
   
      /* use common enumerations to choose 
       * a suitable function */
      switch (command) {
         case E_SET_MTA:
            commandSetMTA(prhs);
            break;
         case E_SET_STATION_ADDRESS:
         case E_SET_SLAVE_VERSION:
         case E_SET_MASTER_VERSION:
         case E_SET_DATA:                
            commandSetUINT8UINT8(command, prhs);
            break;
         case E_SET_S_STATUS:
         case E_SET_HANDLED:
         case E_SET_CURRENT_STATE:
            commandSetUINT8(command, prhs);                   
            break;
         case E_GET_MTA:
            commandGetMTA(plhs, prhs);
            break;
         case E_GET_STATION_ADDRESS:
         case E_GET_SLAVE_VERSION: 
         case E_GET_MASTER_VERSION:
         case E_GET_DATA:
            commandGetUINT8UINT8(command, plhs, prhs);
            break;
         case E_GET_S_STATUS:
         case E_GET_HANDLED:
         case E_GET_CURRENT_STATE:    
            commandGetUINT8(command, plhs);
            break;
         case E_GET_MTA_PTR:
            commandGetMTAPtr(plhs, prhs); 
            break;
         case E_GET_DATA_PTR:
            commandGetDataPtr(plhs, prhs);
            break;
      }
   }
}

/* SET Commands */

/* SET MTA is a special case 
 *
 * INDEX = uint8, MTA = uint32 */
static void commandSetMTA(const mxArray *prhs[]) {
   enum { INDEX_ARG = 1, DATA_ARG };
   ccp.mta[getUINT8arg(prhs,INDEX_ARG)] = getUINT32arg(prhs,DATA_ARG); 
}

/* INDEX = uint8, VALUE = uint8 */
static void commandSetUINT8UINT8(int field, const mxArray * prhs[]) {
   enum { INDEX_ARG = 1, VALUE_ARG };
   uint8_T index = getUINT8arg(prhs, INDEX_ARG);
   uint8_T value = getUINT8arg(prhs, VALUE_ARG);
   switch (field) {
      case E_SET_STATION_ADDRESS: 
         ccp.station_address[index] = value;
         break;
      case E_SET_SLAVE_VERSION:
         ccp.slave_version[index] = value;
         break;
      case E_SET_MASTER_VERSION:
         ccp.master_version[index] = value;
         break;
      case E_SET_DATA:
         ccp.data[index] = value;
   }
}

/* NO INDEX, VALUE = uint8 */
static void commandSetUINT8(int field, const mxArray * prhs[]) {
   enum { VALUE_ARG = 1 };
   uint8_T value = getUINT8arg(prhs, VALUE_ARG);
   switch (field) {
      case E_SET_S_STATUS:
         ccp.s_status = value;
         break;
      case E_SET_HANDLED:
         ccp.handled = value;
         break;
      case E_SET_CURRENT_STATE:
         ccp.current_state = value;
         break;
   }
}

/* GET Commands */

/* Special case for MTA
 *
 * INDEX = uint8, MTA = uint32
 */
static void commandGetMTA(mxArray *plhs[], const mxArray *prhs[]) {
   enum { INDEX_ARG = 1 };
   enum { ADDRESS_ARG = 0 };
   setUINT32arg(plhs, ADDRESS_ARG, ccp.mta[getUINT8arg(prhs, INDEX_ARG)]);
}

/* INDEX = uint8, VALUE = uint8 */
static void commandGetUINT8UINT8(int field, mxArray *plhs[], const mxArray *prhs[]) {
   enum { INDEX_ARG = 1 };
   enum { VALUE_ARG = 0 };
   uint8_T index = getUINT8arg(prhs, INDEX_ARG);
   uint8_T value;
   switch (field) {
      case E_GET_STATION_ADDRESS:
         value = ccp.station_address[index];
         break;
      case E_GET_SLAVE_VERSION:
         value = ccp.slave_version[index];
         break;
      case E_GET_MASTER_VERSION:
         value = ccp.master_version[index];
         break;
      case E_GET_DATA:
         value = ccp.data[index];
         break;     
   }
   setUINT8arg(plhs, VALUE_ARG, value); 
}

/* NO INDEX, VALUE = UINT8 */
static void commandGetUINT8(int field, mxArray *plhs[]) {
   enum { VALUE_ARG = 0 };
   uint8_T value; 
   switch (field) {
      case E_GET_S_STATUS:
         value = ccp.s_status;
         break;
      case E_GET_HANDLED:
         value = ccp.handled;
         break;
      case E_GET_CURRENT_STATE:
         ccp.current_state;
         break;
   }
   setUINT8arg(plhs, VALUE_ARG, value);
}

/* POINTER GET Commands */

/* INDEX = uint8
 * Pointer to a uint32 (MTA) is a returned as a uint32 address */
static void commandGetMTAPtr(mxArray *plhs[], const mxArray *prhs[]) {
   enum { INDEX_ARG = 1 };
   enum { PTR_ARG = 0 };
   setUINT32arg(plhs, PTR_ARG, (uint32_T) &ccp.mta[getUINT8arg(prhs, INDEX_ARG)]);
}

/* INDEX = uint8
 * Pointer to a uint8 (Data) is returned as uint32 address */
static void commandGetDataPtr(mxArray *plhs[], const mxArray *prhs[]) {
   enum { INDEX_ARG = 1 };
   enum { PTR_ARG = 0 };
   setUINT32arg(plhs, PTR_ARG, (uint32_T) &ccp.data[getUINT8arg(prhs, INDEX_ARG)]);
}
