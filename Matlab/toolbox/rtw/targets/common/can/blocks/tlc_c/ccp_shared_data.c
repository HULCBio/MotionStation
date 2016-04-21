/* $Revision: 1.1.4.3 $ */
/* Copyright 2002-2003 The MathWorks, Inc. */

#include "ccp_shared_data.h"

/* These functions only require an implementation during
 * Simulation */
#ifndef CCP_STRUCT

/* the name of the MEX file to call */
#define MEX_FILE "ccp_shared_data_mex"

/* local prototypes for static functions */
static void setUINT8UINT8(int, uint8_T, uint8_T);
static void setUINT8(int, uint8_T);
static uint8_T getUINT8UINT8(int, uint8_T);
static uint8_T getUINT8(int);

/* Set functions */

/* Special case setMTA,
 * INDEX = uint8, MTA = uint32 */
void setMTA(uint8_T index, uint32_T mta) {
   enum { COMMAND_ARG = 0, INDEX_ARG, MTA_ARG, NUMARGS };
   mxArray *rhs[NUMARGS];
   int i;
   rhs[COMMAND_ARG] = mxCreateScalarDouble(E_SET_MTA);
   setUINT8arg(rhs, INDEX_ARG, index);
   setUINT32arg(rhs, MTA_ARG, mta);
   mexCallMATLAB(0, NULL, NUMARGS, rhs, MEX_FILE);
   for (i=0; i<NUMARGS; i++) {
      mxDestroyArray(rhs[i]);
   }
}

void setStation_Address(uint8_T index, uint8_T address) {
   setUINT8UINT8(E_SET_STATION_ADDRESS, index, address);
}

void setSlave_Version(uint8_T index, uint8_T version) {
   setUINT8UINT8(E_SET_SLAVE_VERSION, index, version);
}

void setMaster_Version(uint8_T index, uint8_T version) {
   setUINT8UINT8(E_SET_MASTER_VERSION, index, version);
}

void setData(uint8_T index, uint8_T data) {
   setUINT8UINT8(E_SET_DATA, index, data);
}


void setS_Status(uint8_T status) {
   setUINT8(E_SET_S_STATUS, status);
}


void setHandled(uint8_T handled) {
   setUINT8(E_SET_HANDLED, handled);
}

void setCurrent_State(uint8_T state) {
   setUINT8(E_SET_CURRENT_STATE, state);
}

/* Get functions */

/* special case 
 * INDEX = uint8, MTA = uint32 */
uint32_T getMTA(uint8_T index) {
   enum { COMMAND_ARG = 0, INDEX_ARG, NUMRHS };
   enum { MTA_ARG = 0, NUMLHS };
   int i;
   uint32_T mta;
   mxArray *rhs[NUMRHS];
   mxArray *lhs[NUMLHS];
   rhs[COMMAND_ARG] = mxCreateScalarDouble(E_GET_MTA);
   setUINT8arg(rhs, INDEX_ARG, index);
   mexCallMATLAB(NUMLHS, lhs, NUMRHS, rhs, MEX_FILE);
   mta = getUINT32arg((const mxArray **) lhs, MTA_ARG);
   for (i=0; i<NUMRHS; i++) {
      mxDestroyArray(rhs[i]);
   }
   for (i=0; i<NUMLHS; i++) {
      mxDestroyArray(lhs[i]);
   }
   return mta; 
}

uint8_T getStation_Address(uint8_T index) {
   return getUINT8UINT8(E_GET_STATION_ADDRESS, index); 
}

uint8_T getSlave_Version(uint8_T index) {
   return getUINT8UINT8(E_GET_SLAVE_VERSION, index);
}

uint8_T getMaster_Version(uint8_T index) {
   return getUINT8UINT8(E_GET_MASTER_VERSION, index);
}

uint8_T getData(uint8_T index) {
   return getUINT8UINT8(E_GET_DATA, index);
}

uint8_T getS_Status(void) {
   return getUINT8(E_GET_S_STATUS);
}

uint8_T getHandled(void) {
   return getUINT8(E_GET_HANDLED);
}

uint8_T getCurrent_State(void) {
   return getUINT8(E_GET_CURRENT_STATE);
}

/* Pointer Get Methods 
 *
 * The mex function returns a uint32 address 
 * which is interpreted as a pointer to a uint32 
 * value */
uint32_T * getMTAPtr(uint8_T index) {
   enum { COMMAND_ARG = 0, INDEX_ARG, NUMRHS };
   enum { ADDRESS_ARG = 0, NUMLHS };
   int i;
   uint32_T address;
   mxArray *rhs[NUMRHS];
   mxArray *lhs[NUMLHS];
   rhs[COMMAND_ARG] = mxCreateScalarDouble(E_GET_MTA_PTR);
   setUINT8arg(rhs, INDEX_ARG, index);
   mexCallMATLAB(NUMLHS, lhs, NUMRHS, rhs, MEX_FILE);
   address = getUINT32arg((const mxArray **) lhs, ADDRESS_ARG);
   for (i=0; i<NUMRHS; i++) {
      mxDestroyArray(rhs[i]);
   }
   for (i=0; i<NUMLHS; i++) {
      mxDestroyArray(lhs[i]);
   }
   return (uint32_T *) address;
}

/* The mex function returns a uint32 address
 * which is interpreted as a pointer to a uint8
 * value */
uint8_T * getDataPtr(uint8_T index) {
   enum { COMMAND_ARG = 0, INDEX_ARG, NUMRHS };
   enum { ADDRESS_ARG = 0, NUMLHS };
   int i;
   uint32_T address;
   mxArray *rhs[NUMRHS];
   mxArray *lhs[NUMLHS];
   rhs[COMMAND_ARG] = mxCreateScalarDouble(E_GET_DATA_PTR);
   setUINT8arg(rhs, INDEX_ARG, index);
   mexCallMATLAB(NUMLHS, lhs, NUMRHS, rhs, MEX_FILE);
   address = getUINT32arg((const mxArray **) lhs, ADDRESS_ARG);
   for (i=0; i<NUMRHS; i++) {
      mxDestroyArray(rhs[i]);
   }
   for (i=0; i<NUMLHS; i++) {
      mxDestroyArray(lhs[i]);
   }
   return (uint8_T *) address;
}


/* Internal Static helper methods */

/* INDEX = uint8
 * VALUE = uint8 */
static void setUINT8UINT8(int command, uint8_T index, uint8_T value) {
   enum { COMMAND_ARG = 0, INDEX_ARG, VALUE_ARG, NUMARGS };
   mxArray *rhs[NUMARGS];
   int i;
   rhs[COMMAND_ARG] = mxCreateScalarDouble(command);
   setUINT8arg(rhs, INDEX_ARG, index);
   setUINT8arg(rhs, VALUE_ARG, value);
   mexCallMATLAB(0, NULL, NUMARGS, rhs, MEX_FILE);
   for (i=0; i<NUMARGS; i++) {
      mxDestroyArray(rhs[i]);
   }
}

/* NO INDEX,
 * VALUE = uint8 */
static void setUINT8(int command, uint8_T value) {
   enum { COMMAND_ARG = 0, VALUE_ARG, NUMARGS };
   mxArray *rhs[NUMARGS];
   int i;
   rhs[COMMAND_ARG] = mxCreateScalarDouble(command);
   setUINT8arg(rhs, VALUE_ARG, value);
   mexCallMATLAB(0, NULL, NUMARGS, rhs, MEX_FILE);
   for (i=0; i<NUMARGS; i++) {
      mxDestroyArray(rhs[i]);
   }
}

/* INDEX = uint8,
 * VALUE = uint8 */
static uint8_T getUINT8UINT8(int command, uint8_T index) {
   enum { COMMAND_ARG = 0, INDEX_ARG, NUMRHS };
   enum { VALUE_ARG = 0, NUMLHS };
   int i;
   uint8_T value;
   mxArray *rhs[NUMRHS];
   mxArray *lhs[NUMLHS];
   rhs[COMMAND_ARG] = mxCreateScalarDouble(command);
   setUINT8arg(rhs, INDEX_ARG, index);
   mexCallMATLAB(NUMLHS, lhs, NUMRHS, rhs, MEX_FILE);
   value = getUINT8arg((const mxArray **) lhs, VALUE_ARG);
   for (i=0; i<NUMRHS; i++) {
      mxDestroyArray(rhs[i]);
   }
   for (i=0; i<NUMLHS; i++) {
      mxDestroyArray(lhs[i]);
   } 
   return value;
}

/* NO INDEX,
 * VALUE = uint8 */
static uint8_T getUINT8(int command) {
   enum { COMMAND_ARG = 0, NUMRHS };
   enum { VALUE_ARG = 0, NUMLHS };
   int i;
   uint8_T value;
   mxArray *rhs[NUMRHS];
   mxArray *lhs[NUMLHS];
   rhs[COMMAND_ARG] = mxCreateScalarDouble(command);
   mexCallMATLAB(NUMLHS, lhs, NUMRHS, rhs, MEX_FILE);
   value = getUINT8arg((const mxArray **) lhs, VALUE_ARG);
   for (i=0; i<NUMRHS; i++) {
      mxDestroyArray(rhs[i]);
   }
   for (i=0; i<NUMLHS; i++) {
      mxDestroyArray(lhs[i]);
   } 
   return value;
}

#endif
