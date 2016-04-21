/* $Revision: 1.1.4.1 $ */
#include "ccp_shared_data_common.h"

/* Useful mxArray processing functions :
 *
 * see header file for more info */

uint8_T getUINT8arg(const mxArray * args[], int index) {
   return * (uint8_T *) mxGetData(args[index]);
}

uint32_T getUINT32arg(const mxArray * args[], int index) {
   return * (uint32_T *) mxGetData(args[index]);
}

void setUINT8arg(mxArray * args[], int index, uint8_T value) {
   const int dim[2] = {1, 1};
   args[index] = mxCreateNumericArray(2, dim, mxUINT8_CLASS, mxREAL);
   * (uint8_T *) mxGetData(args[index]) = value;
}

void setUINT32arg(mxArray * args[], int index, uint32_T value) {
   const int dim[2] = {1, 1};
   args[index] = mxCreateNumericArray(2, dim, mxUINT32_CLASS, mxREAL);
   * (uint32_T *) mxGetData(args[index]) = value;
}
