/* $Revision: $ $Date: 2001/06/11 19:57:14 $ */
/**
 * xPC Target From File block.
 */
/* Copyright 1996-2003 The MathWorks, Inc. */


#define         S_FUNCTION_LEVEL        2
#undef          S_FUNCTION_NAME
#define         S_FUNCTION_NAME         xpcfromfile

#include        <stddef.h>
#include        <stdlib.h>
#include        "simstruc.h"
#define         WIN32_LEAN_AND_MEAN
#include        <windows.h>

#ifdef          MATLAB_MEX_FILE
#include        "mex.h"
#endif

typedef struct xpcfreadoptions_tag {
    int bufferSize;                     /* size of entire buffer */
    int dataSize;                       /* multiple of 512 */
    int readSize;                       /* how much to read in one shot */
    int EOFOption;                      /* what do we do on EOF */
} FReadOptions_T;

#ifndef MATLAB_MEX_FILE
unsigned int (XPCCALLCONV *xpceInitFileRead)(const char *filename,
                                             FReadOptions_T *opt);
int (XPCCALLCONV *xpceReadFromFile)(unsigned int id, unsigned char *data);

void (XPCCALLCONV *xpceTermFileRead)(unsigned int id);
#endif

/* Input Arguments */
#define NUMBER_OF_ARGS          (6)
#define FILENAME                (ssGetSFcnParam(S, 0))
#define NUM_BYTES               (ssGetSFcnParam(S, 1))
#define BUFFER_SIZE             (ssGetSFcnParam(S, 2))
#define READ_SIZE               (ssGetSFcnParam(S, 3))
#define EOF_OPTION              (ssGetSFcnParam(S, 4))
#define SAMP_TIME               (ssGetSFcnParam(S, 5))

static char_T msg[256];


static void *getFuncPtr(const char *name) {
    void *func;
    if ((func = GetProcAddress(GetModuleHandle(NULL), name)) == NULL) {
        sprintf(msg, "Could not resolve function %s\n", name);
    }
    return func;
}

static void mdlInitializeSizes(SimStruct *S) {
    int i;
    ssSetNumSFcnParams(S, NUMBER_OF_ARGS);
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        sprintf(msg,"Wrong number of input arguments passed.\n"
                "%d arguments are expected\n",NUMBER_OF_ARGS);
        ssSetErrorStatus(S,msg);
        return;
    }

    for (i = 0; i < NUMBER_OF_ARGS; i++) {
        ssSetSFcnParamNotTunable(S, i);
    }
    ssSetNumOutputPorts(S, 1);
    ssSetNumIWork(S, 1);
    ssSetOutputPortDataType(S, 0, SS_UINT8);
    ssSetOutputPortWidth(S, 0, (int)(mxGetPr(NUM_BYTES)[0]));
    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE | SS_OPTION_PLACE_ASAP);
    return;
}

static void mdlInitializeSampleTimes(SimStruct *S) {
    ssSetSampleTime(S, 0, mxGetPr(SAMP_TIME)[0]);
    ssSetOffsetTime(S, 0, 0.0);
    return;
}

#define MDL_START
static void mdlStart(SimStruct *S) {
#ifndef MATLAB_MEX_FILE
    static char filename[200];
    FReadOptions_T opt;
    unsigned int id;

    if ((xpceInitFileRead = getFuncPtr("xpceInitFileRead")) == NULL ||
        (xpceReadFromFile = getFuncPtr("xpceReadFromFile")) == NULL ||
        (xpceTermFileRead = getFuncPtr("xpceTermFileRead")) == NULL) {
        ssSetErrorStatus(S, msg);
        return;
    }
    mxGetString(FILENAME, filename, 200);
    opt.bufferSize = (int)mxGetPr(BUFFER_SIZE)[0];
    opt.dataSize   = (int)mxGetPr(NUM_BYTES)[0];
    opt.readSize   = (int)mxGetPr(READ_SIZE)[0];
    opt.EOFOption  = (int)mxGetPr(EOF_OPTION)[0];
    id = xpceInitFileRead(filename, &opt);
    if (id == 0) {
        sprintf(msg, "Could not open file %s\n", filename);
        ssSetErrorStatus(S, msg);
        return;
    }
    ((unsigned int *)ssGetIWork(S))[0] = id;
#endif
    return;
}

static void mdlOutputs(SimStruct *S, int_T tid) {
#ifndef MATLAB_MEX_FILE
    unsigned int id = ((unsigned int *)ssGetIWork(S))[0];
    if (xpceReadFromFile(id, ssGetOutputPortSignal(S, 0)) < 0)
        /* do nothing for now, TBD */
        ;
#endif
    return;
}

static void mdlTerminate(SimStruct *S) {
#ifndef MATLAB_MEX_FILE
    unsigned int id = ((unsigned int *)ssGetIWork(S))[0];
    xpceTermFileRead(id);
#endif
}

#ifdef MATLAB_MEX_FILE  /* Is this file being compiled as a MEX-file? */
#include "simulink.c"   /* Mex glue */
#else
#include "cg_sfun.h"    /* Code generation glue */
#endif
