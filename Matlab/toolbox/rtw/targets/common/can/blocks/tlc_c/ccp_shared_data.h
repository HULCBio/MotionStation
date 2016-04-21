/* $Revision: 1.1.4.3 $ */
/* Copyright 2002-2003 The MathWorks, Inc. */

#ifndef _CCP_SHARED_DATA_H
#define _CCP_SHARED_DATA_H

/* include some useful functions + data types */
#include "ccp_shared_data_common.h"
#include "ccp_build_mode.h"

#ifndef CCP_STRUCT
   /* During Simulation, data must be shared between the component blocks
    * that make up the CCP kernel.
    *
    * A mex function with persistent data is used to implement this.
    *
    * The following functions can be called from the Stateflow chart in order
    * to gain access to the shared data.
    *
    * During real time execution, the set of macros below replace these function 
    * calls and data is shared by a global structure. 
    *
    * NOTE: within a single MATLAB process all calls to this mex function
    * will access the same shared data.   Within a single model, only 1 CCP kernel
    * is allowed so this shared data is safe, however, if multiple models with 
    * CCP kernels are executed in the same MATLAB process, the shared data will become
    * corrupt.
    *
    * It would be possible to make the shared data structure more complex, but it will
    * likely not be an issue in practice - unlikely people will simulate CCP models 
    * simultaneously */

   /* data set functions */

   /* Shared data structure contains 2 MTA's.  index is either 0 or 1 */
   void setMTA(uint8_T index, uint32_T data);
   /* Index chooses the low (0) or high (byte) of the station address */
   void setStation_Address(uint8_T index, uint8_T address);
   /* Index chooses the low (0) or high (byte) of the slave version */
   void setSlave_Version(uint8_T index, uint8_T version);
   /* Index chooses the low (0) or high (byte) of the master version */
   void setMaster_Version(uint8_T index, uint8_T version);
   /* Set the S_STATUS byte */
   void setS_Status(uint8_T status);
   /* Set the data byte at the given index (0-7) */ 
   void setData(uint8_T index, uint8_T data);
   /* Set the HANDLED byte */
   void setHandled(uint8_T handled);
   /* Set the CURRENT STATE byte */
   void setCurrent_State(uint8_T state);
   
   /* data get functions */
   /* These are the inverse of the set functions described above */
   uint32_T getMTA(uint8_T index);
   uint8_T getStation_Address(uint8_T index);
   uint8_T getSlave_Version(uint8_T index);
   uint8_T getMaster_Version(uint8_T index);
   uint8_T getS_Status(void);
   uint8_T getData(uint8_T index);
   uint8_T getHandled(void);
   uint8_T getCurrent_State(void);

   /* pointer get functions */

   /* Returns a pointer to the required MTA
    * either MTA0 or MTA1 depending on index */
   uint32_T * getMTAPtr(uint8_T index);

   /* Returns a pointer to the required DATA byte
    * Depending on index, &DATA0 to &DATA7 is returned */
   uint8_T * getDataPtr(uint8_T index);
#else
    /* Real time code generation - data is defined as extern */
   extern struct ccp_shared_data ccp; 
   /* Define the macros for the above functions,
    * that will expand into references to ccp */

/* set Macros */
#define setMTA(INDEX,DATA) (ccp.mta[INDEX] = DATA)
#define setStation_Address(INDEX,ADDRESS) (ccp.station_address[INDEX] = ADDRESS)
#define setSlave_Version(INDEX,VERSION) (ccp.slave_version[INDEX] = VERSION)
#define setMaster_Version(INDEX,VERSION) (ccp.master_version[INDEX] = VERSION)
#define setS_Status(STATUS) (ccp.s_status = STATUS)
#define setData(INDEX,DATA) (ccp.data[INDEX] = DATA)
#define setHandled(HANDLED) (ccp.handled = HANDLED)
#define setCurrent_State(STATE) (ccp.current_state = STATE)

/* get Macros */
#define getMTA(INDEX) (ccp.mta[INDEX])
#define getStation_Address(INDEX) (ccp.station_address[INDEX])
#define getSlave_Version(INDEX) (ccp.slave_version[INDEX])
#define getMaster_Version(INDEX) (ccp.master_version[INDEX])
#define getS_Status() (ccp.s_status)
#define getData(INDEX) (ccp.data[INDEX])
#define getHandled() (ccp.handled)
#define getCurrent_State() (ccp.current_state)

/* pointer macros */
#define getMTAPtr(INDEX) (&(ccp.mta[INDEX]))
#define getDataPtr(INDEX) (&(ccp.data[INDEX]))
   
#endif

/* END CCP_SHARED_DATA_H */
#endif
