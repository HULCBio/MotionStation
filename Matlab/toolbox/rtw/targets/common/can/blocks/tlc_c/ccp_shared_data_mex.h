/* $Revision: 1.1 $ */
/* Copyright 2002 The MathWorks, Inc. */

#ifndef _CCP_SHARED_DATA_MEX_H
#define _CCP_SHARED_DATA_MEX_H

#include "mex.h"

/* includes some helper functions + data types */
#include "ccp_shared_data_common.h"

/* function prototypes */

void mexFunction(int, mxArray*[], int, const mxArray*[]);

/* local functions only */
static void commandSetMTA(const mxArray *[]);
static void commandSetUINT8(int, const mxArray *[]);
static void commandSetUINT8UINT8(int, const mxArray *[]); 

static void commandGetMTA(mxArray *[], const mxArray *[]);
static void commandGetUINT8(int, mxArray *[]);
static void commandGetUINT8UINT8(int, mxArray *[], const mxArray *[]); 

static void commandGetMTAPtr(mxArray *[], const mxArray *[]);
static void commandGetDataPtr(mxArray *[], const mxArray *[]);

#endif
