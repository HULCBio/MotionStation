/* $Revision: 1.1.4.3 $ */
/* Copyright 2002-2003 The MathWorks, Inc. */

#ifndef _CCP_SHARED_DATA_COMMON_H
#define _CCP_SHARED_DATA_COMMON_H

#include "tmwtypes.h"

#include "ccp_build_mode.h"

#ifndef CCP_STRUCT
   #include "mex.h"
#endif

/* The structure below is the definition 
 * of the data shared between blocks in
 * the Simulink model
 */
struct ccp_shared_data {
   uint32_T mta[2];
   uint8_T station_address[2];
   uint8_T slave_version[2];
   uint8_T master_version[2];
   uint8_T s_status;
   uint8_T data[8];
   uint8_T handled;
   uint8_T current_state;
};

enum state {CCP_DISCONNECTED_STATE=0, CCP_TEMPORARILY_DISCONNECTED_STATE, CCP_CONNECTED_STATE};

#ifndef CCP_STRUCT
/* Define some useful enumerations for dealing with the different 
 * share data commands */

/* set commands */
enum { E_SET_MTA = 0, E_SET_STATION_ADDRESS, E_SET_SLAVE_VERSION, E_SET_MASTER_VERSION,
       E_SET_S_STATUS, E_SET_DATA, E_SET_HANDLED, E_SET_CURRENT_STATE, E_NUM_SET_COMMANDS };

/* get commands */
enum { E_GET_MTA = E_NUM_SET_COMMANDS, E_GET_STATION_ADDRESS, E_GET_SLAVE_VERSION, E_GET_MASTER_VERSION,
       E_GET_S_STATUS, E_GET_DATA, E_GET_HANDLED, E_GET_CURRENT_STATE, E_NUM_SET_AND_GET_COMMANDS };

/* pointer commands */
enum { E_GET_MTA_PTR = E_NUM_SET_AND_GET_COMMANDS, E_GET_DATA_PTR };



/* Useful functions for processing typed
 * mxArray arguments!
 * 
 * for example:
 *
 * getUINT8arg has arguments: const mxArray *[] - argument list,
 *                            int - index into argument list
 *
 * Return value : Interprets the mxArray at the index position as a 1*1 (scalar) 
 * uint8_T value.
 */
uint8_T getUINT8arg(const mxArray *[], int);
uint32_T getUINT32arg(const mxArray *[], int);

void setUINT8arg(mxArray *[], int, uint8_T);
void setUINT32arg(mxArray *[], int, uint32_T); 

#endif

#endif
