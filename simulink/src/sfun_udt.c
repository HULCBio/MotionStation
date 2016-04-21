/*  File    : sfun_udt.c
 *  Abstract:
 *
 *      A level 2 S-function to convert an floating point input to a
 *      user-defined structure type
 *
 *  Copyright 1990-2004 The MathWorks, Inc.
 *  $Revision: 1.7.4.2 $
 */


#define S_FUNCTION_NAME  sfun_udt
#define S_FUNCTION_LEVEL 2

#include "simstruc.h"


/* Define an enumerated type, as well as a struct that will be used in
 * simulation and code generation.  The structure encodes a floating
 * point value with a signed integer representation.  If the magnitude of
 * of the floating point value being encoded is less than or equal to 1.0,
 * then encode the value using high resolution; otherwise encode the value
 * using low resolution
 */
typedef enum { LO_RES, HI_RES } Resolution;
typedef struct { Resolution res; int8_T value; } Data;


/* Function: DataCnvBtw
 * Abstract:
 *   Intended to convert data of type "Data" to double; this utility
 *   function will be used by builtin blocks such as Scope, ToWks, and
 *   subsystem Trigger blocks
 */
static int_T DataCnvBtw(
 slDataTypeAccess *dta,
 const char       *pStrPath,
 DTypeId          yId,
 DTypeId          uId,
 int_T            numEls,
 const void       *u,
 const void       *options,
 void             *y
)
{
    if (yId != SS_DOUBLE) {
        dtaSetErrorString(dta, "ConvertBetween function only converts from type \"Data\" to type \"double\"");
        return 0;
    } else {
        Data*      data = (Data*) u;
        double*    out  = (double*) y;
        Resolution res  = data->res;
        if (res == HI_RES) {
            *out = ((double) data->value)/(127.0);
        } else {
            *out = (double) data->value;
        }
        return 1;
    }
}



/* Function: DataIsPos
 * Abstract:
 *   Intended to test data of type "Data" to see if the encoded floating
 *   point value is positive or not; this utility function will be used
 *   by builtin blocks such as subsystem Enable blocks
 */
static int_T DataIsPos(
 slDataTypeAccess *dta,
 const char       *pStrPath,
 DTypeId          uId,
 int_T            numEls,
 const void       *u,
 const void       *options,
 void             *y
)
{
    Data* data = (Data*) u;
    bool* out  = (bool*) y;

    *out = data->value > 0;
    return 1;
}

static Data zero = { HI_RES, 0 };

/* Function: mdlInitializeSizes ===============================================
 * Abstract:
 *   Setup sizes of the various vectors.
 */
static void mdlInitializeSizes(SimStruct *S)
{
    slDataTypeAccess *dta = ssGetDataTypeAccess(S);
    int              udtId;

    ssSetNumSFcnParams(S, 0);  /* Number of expected parameters */
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        /* Return if number of expected != number of actual parameters */
        return;
    }

    /* Obtain an integer datatype ID for the udt (user-defined type) "Data" */
    udtId = ssRegisterDataType(S, "Data");
    if ( udtId == INVALID_DTYPE_ID ) return;

    /* Register the size of the udt */
    if (!ssSetDataTypeSize(S, udtId, sizeof(Data))) return;

    /* Register the zero of the udt */
    if (!ssSetDataTypeZero(S, udtId, &zero)) return;

    /* Register the convert-between datatype function defined above */
    if (!dtaSetConvertBetweenFcn(dta, ssGetPath(S), udtId, &DataCnvBtw)) return;

    /* Register the is-positive datatype function defined above*/
    if (!dtaSetIsPositiveFcn(dta, ssGetPath(S), udtId, &DataIsPos)) return;

    /* Set input-port properties */
    if (!ssSetNumInputPorts(S, 1)) return;
    ssSetInputPortWidth(S, 0, 1);
    ssSetInputPortDataType(S, 0, SS_DOUBLE);
    ssSetInputPortDirectFeedThrough(S, 0, 1);

    /* Set output port properties */
    if (!ssSetNumOutputPorts(S, 1)) return;
    ssSetOutputPortDataType(S, 0, udtId);
    ssSetOutputPortWidth(S, 0, 1);

    /* Set miscellaneous properties */
    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);
    ssSetNumSampleTimes(S, 1);
    ssSetNumRWork(S, 0);
    ssSetNumIWork(S, 0);
    ssSetNumPWork(S, 0);
    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);

    ssSetOptions(S,
                 SS_OPTION_WORKS_WITH_CODE_REUSE |
                 SS_OPTION_USE_TLC_WITH_ACCELERATOR |
                 SS_OPTION_DISALLOW_CONSTANT_SAMPLE_TIME |
                 SS_OPTION_SFUNCTION_INLINED_FOR_RTW);
}

/* Function: mdlInitializeSampleTimes =========================================
 * Abstract:
 *    This function is used to specify the sample time(s) for your
 *    S-function. You must register the same number of sample times as
 *    specified in ssSetNumSampleTimes.
 */
static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);
    ssSetModelReferenceSampleTimeDefaultInheritance(S);
}


/* Function: mdlOutputs =======================================================
 * Abstract:
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
    InputRealPtrsType u  = ssGetInputPortRealSignalPtrs(S,0);
    Data              *y = ssGetOutputPortSignal(S,0);

    if (*u[0] > 127 || mxIsInf(*u[0])) {
        y->value = 127;
        y->res = LO_RES;
    } else if (*u[0] < 1.0 && *u[0] > -1.0) {
        y->value = (int8_T) (127.0 * *u[0]);
        y->res   = HI_RES;
    } else {
        y->value = (int8_T) *u[0];
        y->res   = LO_RES;
    }
}


/* Function: mdlTerminate =====================================================
 * Abstract:
 *    Noop
 */
static void mdlTerminate(SimStruct *S)
{
}

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif

