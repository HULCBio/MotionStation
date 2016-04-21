/* $Revision: 1.1.6.1 $ */
/*
 * SWRITFIL  A Simulink triggered read from a file.
 *
 *  Syntax:  [sys, x0] = swritfil(t,x,u,flag, filename, format, pulnum, threshold)
 *  This function has two inputs and no outputs. The first input is
 *  the signal to be stored. The second signal is the clock pulse.
 *
 *  filename is a string for the filename.
 *  format   is the format to be written into the file. The choices are:
 *            "data", "ascii"
 *  pulnum   number of pulses between saved data. If pulnum is a two 
 *           dimentional vector, the second element is the number of
 *           'offset' pulse before the first data is saved.
 *
 * Wes Wang  Feb. 7, 1995
 * Copyright 1996-2002 The MathWorks, Inc.
 */

#define S_FUNCTION_NAME swritfil

#include <string.h>    /* needed for string operation */
#include <stdio.h>

#ifdef MATLAB_MEX_FILE
#include "mex.h"      /* needed for declaration of mexErrMsgTxt */
#endif

/*
 * need to include simstruc.h for the definition of the SimStruct and
 * its associated macro definitions.
 */

#include "simstruc.h"
#include "tmwtypes.h"

/* For RTW */
#if defined(RT) || defined(NRT)  
#undef  mexPrintf
#define mexPrintf printf
#endif

/*
 * Defines for easy access of the input parameters
 */

#define NUM_ARGS      4
/* file name for the data to be saved */
#define FILENAME      ssGetArg(S, 0)
/* data type, which is a string of ASCII, Integer, float, or binary */
#define DATA_TYPE     ssGetArg(S, 1)
/* number of pulse count to trigger one saving record */
#define NUM_IN_BT     ssGetArg(S, 2)
/* threshold in detecting the rising edge. */
#define THRESHOLD     ssGetArg(S, 3)

/*
 * mdlInitializeSizes - called to initialize the sizes array stored in
 *                      the SimStruct.  The sizes array defines the
 *                      characteristics (number of inputs, outputs,
 *                      states, etc.) of the S-Function.
 */

static void mdlInitializeSizes(SimStruct *S)
{
  /*
   * Set-up size information.
   */ 
  
  if (ssGetNumArgs(S) == NUM_ARGS) {
    int_T i, FileName, DataType, NumInBetween, NumOffset;
    if ((mxGetN(FILENAME) > 1) && (mxGetM(FILENAME) > 1)) {
#ifdef MATLAB_MEX_FILE
      char_T err_msg[256];
      sprintf(err_msg, "Filename should be a string vector.");
      mexErrMsgTxt(err_msg);
#endif  
    }
    
    if ((mxGetN(DATA_TYPE) > 1) && (mxGetM(DATA_TYPE) > 1)) {
#ifdef MATLAB_MEX_FILE
      char_T err_msg[256];
      sprintf(err_msg, "Data Type should be a string vector.");
      mexErrMsgTxt(err_msg);
#endif  
    }
    
    if ((mxGetN(NUM_IN_BT) * mxGetM(NUM_IN_BT) > 2) || (mxGetN(NUM_IN_BT) * mxGetM(NUM_IN_BT) < 1) ) {
#ifdef MATLAB_MEX_FILE
      char_T err_msg[256];
      sprintf(err_msg, "Dimension for trigger pulse number is incorrect.");
      mexErrMsgTxt(err_msg);
#endif  
    }
    
    ssSetNumContStates(    S, 0);
    ssSetNumDiscStates(    S, 0);
    ssSetNumInputs(        S, -1);
    ssSetNumOutputs(       S, 1);
    ssSetDirectFeedThrough(S, 1);
    ssSetNumInputArgs(     S, NUM_ARGS);
    ssSetNumSampleTimes(   S, 1);
    ssSetNumRWork(         S, 0);
    ssSetNumIWork(         S, 3);
    /* 1st: 0--start, not passed offset; 1--regular calculation
     * 2nd: accumulate accounting for the how many pulse passed
     * 3rd: 0: last trigger signal was below threshold 1: last trigger signal was above threshold
     */
    ssSetNumPWork(         S, 1);
    /* point for the opened file name */
  } else {
#ifdef MATLAB_MEX_FILE
    char_T err_msg[256];
    sprintf(err_msg, "Wrong number of input arguments passed to S-function MEX-file.\n"
	    "%d input arguments were passed in when expecting %d input arguments.\n", ssGetNumArgs(S) + 4, NUM_ARGS + 4);
    mexErrMsgTxt(err_msg);
#endif
  }
}

/*
 * mdlInitializeSampleTimes - initializes the array of sample times stored in
 *                            the SimStruct associated with this S-Function.
 */

static void mdlInitializeSampleTimes(SimStruct *S)
{
  /*
   * Note, blocks that are continuous in nature should have a single
   * sample time of 0.0.
   */
  
    ssSetSampleTimeEvent(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTimeEvent(S, 0, FIXED_IN_MINOR_STEP_OFFSET);
}

/*
 * mdlInitializeConditions - initializes the states for the S-Function
 */

static void mdlInitializeConditions(real_T *x0, SimStruct *S)
{
  int_T    *CountFlag      = ssGetIWork(S);
  int_T    *CountNum       = ssGetIWork(S) + 1;
  int_T    *LastTrig       = ssGetIWork(S) + 2;
  FILE   *fp            = (FILE *) ssGetPWork(S)[0];
  
  *CountFlag = 0;
  *CountNum  = 0;
  *LastTrig  = 0;
  fp = NULL;
}

/*
 * mdlOutputs - computes the outputs of the S-Function
 */

static void mdlOutputs(real_T *y, const real_T *x, const real_T *u, SimStruct *S, int_T tid)
{
  int_T    *CountFlag      = ssGetIWork(S);
  int_T    *CountNum       = ssGetIWork(S) + 1;
  int_T    *LastTrig       = ssGetIWork(S) + 2;
  FILE   *fp            = (FILE *)ssGetPWork(S)[0];
  
  real_T  trigThreshold   = mxGetPr(THRESHOLD)[0];
  
  int_T     numInput       = ssGetNumInputs(S);
  int_T     i;

  char_T   filename[32];
  char_T   dataType[10];
  
  /*
   * acquire the buffer data
   */
  
  if ((u[numInput-1] >= trigThreshold) & (*LastTrig == 0)) {
    
#ifdef MATLAB_MEX_FILE
    if (mxGetString(DATA_TYPE, dataType, sizeof(dataType)) != 0) {
      mexErrMsgTxt("Error in Data Type specification.");
    }
#endif
    *CountNum += 1;
    if (*CountFlag) {
      /* action when count number is larger or equal to number count */
      int_T NumberInBetween = (int_T)mxGetPr(NUM_IN_BT)[0];
      
      if (*CountNum > NumberInBetween) {
	/* reset Count */
	*CountNum = 0;
	
	if (fp != NULL) {
	  if (strcmp(dataType, "float") == 0) {
	    for (i = 0;  i < numInput - 1; i++)
	      fprintf(fp, " %g", u[i]);
	    fprintf(fp, "\n");
	  } else if (strcmp(dataType, "integer") == 0) {
	    for (i = 0;  i < numInput - 1; i++)
	      fprintf(fp, " %i", (int_T)u[i]);
	    fprintf(fp, "\n");
	  } else if ((strcmp(dataType, "ascii") == 0) || (strcmp(dataType, "ASCII") == 0)) {
	    for (i = 0;  i < numInput - 1; i++) {
	      if (u[i])
		fprintf(fp, "%c", (char_T)((int_T)u[i]));
	    }
	  } else if ((strcmp(dataType, "binary") == 0)) {
	    fwrite(u, (numInput - 1) * sizeof(real_T), 1, fp);
	  } else {
#ifdef MATLAB_MEX_FILE
	    mexErrMsgTxt("Data type is not a legal string.");
#endif
	  }
	} else {
#ifdef MATLAB_MEX_FILE
	  mexErrMsgTxt("File point has lost.");
#endif
	}
      }
    } else {
      i = 0;
      if ((mxGetN(NUM_IN_BT) * mxGetM(NUM_IN_BT)) < 2) {
	i = 1;
      } else {
	if (*CountNum > mxGetPr(NUM_IN_BT)[1])
	  i = 1;
      }
      if (i) {
	/* this one will be run once only. */
	
    mxGetString(FILENAME, filename, sizeof(filename));
	
	fp = fopen(filename, "w");
	
	if (fp == NULL) {
#ifdef MATLAB_MEX_FILE
	  char_T err_msg[256];
	  sprintf(err_msg, "Error in opening the data file %s", filename);
	  mexErrMsgTxt(err_msg);
#endif
	} else {
	  ssGetPWork(S)[0] = (void *)fp;
	  if (strcmp(dataType, "float") == 0) {
	    for (i = 0;  i < numInput - 1; i++)
	      fprintf(fp, " %g", u[i]);
	    fprintf(fp, "\n");
	  } else if (strcmp(dataType, "integer") == 0) {
	    for (i = 0;  i < numInput - 1; i++)
	      fprintf(fp, " %i", (int_T)u[i]);
	    fprintf(fp, "\n");
	  } else if ((strcmp(dataType, "ascii") == 0) || (strcmp(dataType, "ASCII") == 0)) {
	    for (i = 0;  i < numInput - 1; i++) {
	      if (u[i])
		fprintf(fp, "%c", (char_T)((int_T)u[i]));
	    }
	  } else if ((strcmp(dataType, "binary") == 0)) {
	    fwrite(u, (numInput - 1) * sizeof(real_T), 1, fp);
	  } else {
#ifdef MATLAB_MEX_FILE
	    mexErrMsgTxt("Data type is not a legal string.");
#endif
	  }
	}

	/* set flag, the Count flag setting avoid duplication of open file */
	*CountFlag = 1;
	*CountNum = 0;
      }
    }
  }
  if (u[numInput-1] >= trigThreshold) {
    *LastTrig = 1;
  } else {
    *LastTrig = 0;
  }
  y[0] = 0;
}

/*
 * mdlUpdate - computes the discrete states of the S-Function
 */

static void mdlUpdate(real_T *x, const real_T *u, SimStruct *S, int_T tid)
{
}

/*
 * mdlDerivatives - computes the derivatives of the S-Function
 */

static void mdlDerivatives(real_T *dx, const real_T *x, const real_T *u, SimStruct *S, int_T tid)
{
}

/*
 * mdlTerminate - called at termination of model execution.
 */

static void mdlTerminate(SimStruct *S)
{
  FILE *fp = (FILE *)ssGetPWork(S)[0];
  
  if (fp != NULL)
    fclose(fp);
}

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-File interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif



