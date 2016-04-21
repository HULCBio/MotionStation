/* $Revision: 1.11.6.1 $ $Date: 2004/04/08 21:03:22 $ */
/* scblock.c - xPC Target, Scope Block source for build */
/* Copyright 1996-2003 The MathWorks, Inc.
*/


#define SCOPENO                 ssGetSFcnParam(S, 0)
#define YLIMITS                 ssGetSFcnParam(S, 4)
#define NOSAMPLES               ssGetSFcnParam(S, 6)
#define INTERLEAVE              ssGetSFcnParam(S, 7)
#define TRIGGERSIGNAL           ssGetSFcnParam(S, 9)
#define TRIGGERLEVEL            ssGetSFcnParam(S, 10)
#define TRIGGERSCOPE            ssGetSFcnParam(S, 12)
#define TRIGGERSAMPLE           ssGetSFcnParam(S, 14)
#define FILENAME                ssGetSFcnParam(S, 15)
#define WRITESIZE               ssGetSFcnParam(S, 17)
#define FORMATSTR               ssGetSFcnParam(S, 19)

#define NPARAMS 20

char msg[256];

#define S_FUNCTION_LEVEL 2
#define S_FUNCTION_NAME scblock

#include "simstruc.h"
#include "tmwtypes.h"

static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumSFcnParams(S, NPARAMS);  /* Number of expected parameters */
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        /* Return if number of expected != number of actual parameters */
        return;
    }
    if (mxGetM(SCOPENO)!=1 || mxGetN(SCOPENO)!=1) {
        sprintf(msg,"Scope Number argument must be a scalar");
        ssSetErrorStatus(S,msg);
        return;
    }
    if ((int)mxGetPr(SCOPENO)[0] < 1) {
        sprintf(msg,"Scope Number cannot be smaller than 1");
        ssSetErrorStatus(S,msg);
        return;
    }
        if (mxGetM(YLIMITS)!=1 || mxGetN(YLIMITS)!=2) {
        sprintf(msg,"Y-Axis Limits argument must be a row vector with two elements");
        ssSetErrorStatus(S,msg);
        return;
    }
    if (mxGetPr(YLIMITS)[0] > mxGetPr(YLIMITS)[1]) {
        sprintf(msg,"Y-Axis Limits argument: lower limit must be smaller than upper limit");
        ssSetErrorStatus(S,msg);
        return;
    }
    if (mxGetM(NOSAMPLES)!=1 || mxGetN(NOSAMPLES)!=1) {
        sprintf(msg,"Number of Samples argument must be a scalar");
        ssSetErrorStatus(S,msg);
        return;
    }
    if ((int)mxGetPr(NOSAMPLES)[0] < 3) {
        sprintf(msg,"Number of Samples cannot be smaller than 3");
        ssSetErrorStatus(S,msg);
        return;
    }
    if (mxGetM(INTERLEAVE)!=1 || mxGetN(INTERLEAVE)!=1) {
        sprintf(msg,"Decimation argument must be a scalar");
        ssSetErrorStatus(S,msg);
        return;
    }
    if ((int)mxGetPr(INTERLEAVE)[0] < 1) {
        sprintf(msg,"Interleave cannot be smaller than 1");
        ssSetErrorStatus(S,msg);
        return;
    }
    if (mxGetM(TRIGGERSIGNAL)!=1 || mxGetN(TRIGGERSIGNAL)!=1) {
        sprintf(msg,"Trigger Signal argument must be a scalar");
        ssSetErrorStatus(S,msg);
        return;
    }
    if ((int)mxGetPr(TRIGGERSIGNAL)[0] < 1) {
        sprintf(msg,"Trigger Signal cannot be smaller than 1");
        ssSetErrorStatus(S,msg);
        return;
    }

    {
        double trigSamp;
        trigSamp = mxGetPr(TRIGGERSAMPLE)[0];
        if (mxGetM(TRIGGERSAMPLE) != 1 || mxGetN(TRIGGERSAMPLE) != 1 ||
            (int)trigSamp != trigSamp || trigSamp < -1) {
            sprintf(msg, "Sample to trigger on must be an integer"
                    " greater than -2");
            ssSetErrorStatus(S, msg);
            return;
        }
    }

    {
	char *filename = mxArrayToString(FILENAME);
	char *dot = strstr(filename, ".");
	int len = strlen(filename);
	
	if (len <= 0) {
	    sprintf(msg, "Filename must be at least one character long");
	    ssSetErrorStatus(S, msg);

	} else if ((filename + strlen(filename) - 1 - dot) > 3) {
	    sprintf(msg, "Filename must have an extension 3 characters or less");
	    ssSetErrorStatus(S, msg);
	}
	
	mxFree(filename);
    }
    
    if ((int)mxGetPr(WRITESIZE)[0] <= 0) {
	sprintf(msg, "WriteSize must be an integer greater than 0");
	ssSetErrorStatus(S, msg);
    }

    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);

    ssSetNumInputPorts(S, 1);

    ssSetInputPortWidth(S, 0, DYNAMICALLY_SIZED);
    ssSetInputPortDataType(S, 0, DYNAMICALLY_TYPED);

    ssSetNumSampleTimes(S, 1);

    ssSetNumRWork(S, 0);
    ssSetNumIWork(S, 1);
    ssSetNumPWork(S, 0);

    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);

    {
	int i;
	
	for (i = 0; i < NPARAMS; i++) {
	    ssSetSFcnParamNotTunable(S, i);
	}
    }

    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE | SS_OPTION_PLACE_ASAP);

}

static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);

}

#undef MDL_INITIALIZE_CONDITIONS   /* Change to #undef to remove function */
#undef MDL_START  /* Change to #undef to remove function */
#undef MDL_UPDATE  /* Change to #undef to remove function */
#undef MDL_DERIVATIVES  /* Change to #undef to remove function */


static void mdlOutputs(SimStruct *S, int_T tid)
{
}

static void mdlTerminate(SimStruct *S)
{
}

#define MDL_RTW
#if defined(MDL_RTW) && (defined(MATLAB_MEX_FILE) || defined(NRT))
/* Function: mdlRTW ===========================================================
 *
 */
static void mdlRTW(SimStruct *S)
{
    char_T *buffer;

    buffer=(char *)calloc(mxGetN(FORMATSTR)+1,sizeof(char));
    if (buffer==NULL) {
	ssSetErrorStatus(S,"Scope(xPC): could not allocate memory\n");
	return;
    }
    mxGetString(FORMATSTR, buffer, mxGetN(FORMATSTR)+1);

    (void)ssWriteRTWParamSettings(S, NPARAMS,
                                  SSWRITE_VALUE_NUM,  "ScopeNo",          (double)  mxGetPr(ssGetSFcnParam(S,0))[0],
                                  SSWRITE_VALUE_NUM,  "ScopeType",        (double)  mxGetPr(ssGetSFcnParam(S,1))[0],
                                  SSWRITE_VALUE_NUM,  "ViewMode",         (double)  mxGetPr(ssGetSFcnParam(S,2))[0],
                                  SSWRITE_VALUE_NUM,  "Grid",             (double)  mxGetPr(ssGetSFcnParam(S,3))[0],
                                  SSWRITE_VALUE_VECT, "YLimits",          (double*) mxGetPr(ssGetSFcnParam(S,4)), mxGetNumberOfElements(ssGetSFcnParam(S,4)),
                                  SSWRITE_VALUE_NUM,  "AutoStart",        (double) mxGetPr(ssGetSFcnParam(S,5))[0],
                                  SSWRITE_VALUE_NUM,  "NoSamples",        (double) mxGetPr(ssGetSFcnParam(S,6))[0],
                                  SSWRITE_VALUE_NUM,  "Interleave",       (double) mxGetPr(ssGetSFcnParam(S,7))[0],
                                  SSWRITE_VALUE_NUM,  "TriggerMode",      (double) mxGetPr(ssGetSFcnParam(S,8))[0],
                                  SSWRITE_VALUE_NUM,  "TriggerSignal",    (double) mxGetPr(ssGetSFcnParam(S,9))[0],
                                  SSWRITE_VALUE_NUM,  "TriggerLevel",     (double) mxGetPr(ssGetSFcnParam(S,10))[0],
                                  SSWRITE_VALUE_NUM,  "TriggerSlope",     (double) mxGetPr(ssGetSFcnParam(S,11))[0],
                                  SSWRITE_VALUE_NUM,  "TriggerScope",     (double) mxGetPr(ssGetSFcnParam(S,12))[0],
                                  SSWRITE_VALUE_NUM,  "NoPrePostSamples", (double) mxGetPr(ssGetSFcnParam(S,13))[0],
                                  SSWRITE_VALUE_NUM,  "TriggerSample",    (double) mxGetPr(ssGetSFcnParam(S,14))[0], 
				  SSWRITE_VALUE_STR,  "Filename",                  mxArrayToString(ssGetSFcnParam(S,15)), 
                                  SSWRITE_VALUE_STR,  "Mode",                      mxArrayToString(ssGetSFcnParam(S,16)),
				  SSWRITE_VALUE_NUM,  "WriteSize",        (double) mxGetPr(ssGetSFcnParam(S,17))[0],
				  SSWRITE_VALUE_NUM,  "AutoRestart",      (double) mxGetPr(ssGetSFcnParam(S,18))[0],
                                  SSWRITE_VALUE_STR, "formatstr", (char*) buffer);

    (void)ssWriteRTWWorkVect(S, "IWork", 1, "AcquireOK", 1);

}
#endif /* MDL_RTW */



#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
