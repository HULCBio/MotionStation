/* $Revision: 1.1.6.1 $ */
/*
 * HOMOPULS   A Simulink homonic pulse generator.
 *
 *           Syntax:  [sys, x0] = homopuls(t,x,u,flag,sample,divider,offset)
 *
 * Wes Wang  8/18/1994 revised 1/24/1996.
 * Copyright 1996-2002 The MathWorks, Inc.
 */

#define S_FUNCTION_NAME homopuls

#ifdef MATLAB_MEX_FILE
#include "mex.h"      /* needed for declaration of mexErrMsgTxt */
#endif

/*
 * need to include simstruc.h for the definition of the SimStruct and
 * its associated macro definitions.
 */

#include "simstruc.h"
#include "tmwtypes.h"
#include <math.h>

/* For RTW */
#if defined(RT) || defined(NRT)  
#undef  mexPrintf
#define mexPrintf printf
#endif

/*
 * Defines for easy access of the input parameters
 */

#define NUM_ARGS     3
#define SAMPLE_TIME       ssGetArg(S,0)
#define DIVIDER_EACH      ssGetArg(S,1)
#define OFFSET_EACH       ssGetArg(S,2)

/*
 * mdlInitializeSizes - called to initialize the sizes array stored in
 *                      the SimStruct.  The sizes array defines the
 *                      characteristics (number of inputs, outputs,
 *                      states, etc.) of the S-Function.
 */

static int_T isclose(real_T a, real_T b)
{
#define EPS       4.656612875245797e-10    /*  reciprocal of 2^31-1 */
     real_T diff;

#ifdef MATLAB_MEX_FILE
    if (0) {
      char_T err_msg[255];
      sprintf(err_msg, "a %f, b %f \n", a, b);
      mexPrintf(err_msg);
    } 
#endif
    
     diff = fabs(a - b);
     if (diff * 1.e-5 /(fabs(a) + EPS) < EPS)
       return(1);
     else
       return(0);
}

static void mdlInitializeSizes(SimStruct *S)
{
  /*
   * Set-up size information.
   */ 
  int_T NumSampleTime;

  if (ssGetNumArgs(S) == NUM_ARGS) {
    int_T dividerSize;
    if ((mxGetN(SAMPLE_TIME) * mxGetM(SAMPLE_TIME)) > 1) {
#ifdef MATLAB_MEX_FILE
      mexErrMsgTxt("The sample time is a scalar.");
#endif
    }
    
    if ((mxGetN(DIVIDER_EACH) != 1) && (mxGetM(DIVIDER_EACH) != 1)) {
#ifdef MATLAB_MEX_FILE
      mexErrMsgTxt("The divider must be a vector");
#endif
    }
               
    if ((mxGetN(OFFSET_EACH) != 1) && (mxGetM(OFFSET_EACH) != 1)) {
#ifdef MATLAB_MEX_FILE
      mexErrMsgTxt("The offset must be a vector");
#endif
    }
               
    if ((mxGetN(OFFSET_EACH) * (mxGetM(OFFSET_EACH))) != ((mxGetN(DIVIDER_EACH) * (mxGetM(DIVIDER_EACH))))) {
#ifdef MATLAB_MEX_FILE
      mexErrMsgTxt("Divider and Offset must have the same length");
#endif
    }
    
    dividerSize = mxGetN(DIVIDER_EACH) * mxGetM(DIVIDER_EACH);
    NumSampleTime = dividerSize;
    if (dividerSize > 0) {
       real_T sampleTime, sampleTimeI, offsetTimeI;
       int_T    adj, i;
       real_T *past_sample, *past_offset;
       
       past_sample = (real_T *)calloc(dividerSize, sizeof(real_T));
       past_offset = (real_T *)calloc(dividerSize, sizeof(real_T));

       sampleTime = mxGetPr(SAMPLE_TIME)[0];
       NumSampleTime = 0;
       for (i=0; i < dividerSize; i++) {
         offsetTimeI = mxGetPr(OFFSET_EACH)[i];
         sampleTimeI = sampleTime/2./mxGetPr(DIVIDER_EACH)[i];
         if (sampleTimeI <= 0) {
#ifdef MATLAB_MEX_FILE
	     mexErrMsgTxt("Sample time must be positive number.");
#endif
         }
         while  (offsetTimeI < 0)
            offsetTimeI += sampleTimeI;
         adj = (int_T)(offsetTimeI / sampleTimeI);
         offsetTimeI = offsetTimeI - ((real_T)adj) * sampleTimeI;

#ifdef MATLAB_MEX_FILE
         if (0) {
           char_T err_msg[255];
           sprintf(err_msg, "Iteration %d, offsetTimeI %f, sampleTimeI %f \n", i, offsetTimeI, sampleTimeI);
           mexPrintf(err_msg);
         }     
#endif

	 if ((isclose(offsetTimeI, 0.0)) || (isclose(offsetTimeI, sampleTimeI)))
	   offsetTimeI = 0;
	 if (i > 0) {
	   int_T test_flag, ii;
	   test_flag = 1;
	   for (ii = 0; ii<NumSampleTime; ii++) {
#ifdef MATLAB_MEX_FILE
          if (0) {
               char_T err_msg[255];
               sprintf(err_msg, "sampleTimeI %f, past_sample[ii] %f, offsetTimeI %f, past_offset[ii] %f \n", sampleTimeI, past_sample[ii], offsetTimeI, past_offset[ii]);
               mexPrintf(err_msg);
	  }
#endif
	     if ((isclose(sampleTimeI, past_sample[ii])) && (isclose(offsetTimeI, past_offset[ii])))
	        test_flag = 0;
	   }
	   if (test_flag) {
	     past_sample[NumSampleTime] = sampleTimeI;
             past_offset[NumSampleTime] = offsetTimeI;
	     NumSampleTime++;
	   }
	 } else {
	   past_sample[NumSampleTime] = sampleTimeI;
	   past_offset[NumSampleTime] = offsetTimeI;
           NumSampleTime++;
	 }
       }
       free(past_sample);
       free(past_offset);
    }
#ifdef MATLAB_MEX_FILE     
    if (0) {
      char_T err_msg[255];
      sprintf(err_msg, "NumSampleTime %d: \n", NumSampleTime);
      mexPrintf(err_msg);
    }
#endif

    ssSetNumContStates(    S, 0);
    ssSetNumDiscStates(    S, 0);
    ssSetNumInputs(        S, 0);
    ssSetNumOutputs(       S, dividerSize);
    ssSetDirectFeedThrough(S, 0);
    ssSetNumInputArgs(     S, NUM_ARGS);
    ssSetNumSampleTimes(   S, NumSampleTime);
    ssSetNumRWork(         S, 4*dividerSize+2); /* store the timing */
    ssSetNumIWork(         S, dividerSize); /* store the last time access. */
    ssSetNumPWork(         S, 0);
  } else {
#ifdef MATLAB_MEX_FILE
    char_T err_msg[256];
    sprintf(err_msg, "Wrong number of input arguments passed to S-function MEX-file.\n %d input arguments were passed in when expecting %d input arguments.\n", ssGetNumArgs(S) + 4, NUM_ARGS + 4);
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
  int_T dividerSize, NumSampleTime;
  int_T NumSmpTm = ssGetNumSampleTimes(S);

  dividerSize = mxGetN(DIVIDER_EACH) * mxGetM(DIVIDER_EACH);

  NumSampleTime = dividerSize;
  if (dividerSize > 0) {
    real_T sampleTime, sampleTimeI, offsetTimeI;
    int_T    adj, i;
    real_T *past_sample, *past_offset;
       
    past_sample = (real_T *)calloc(dividerSize, sizeof(real_T));
    past_offset = (real_T *)calloc(dividerSize, sizeof(real_T));

    sampleTime = mxGetPr(SAMPLE_TIME)[0];
    NumSampleTime = 0;
    for (i=0; i < dividerSize; i++) {
      offsetTimeI = mxGetPr(OFFSET_EACH)[i];
      sampleTimeI = sampleTime/2./mxGetPr(DIVIDER_EACH)[i];
      while  (offsetTimeI < 0)
         offsetTimeI += sampleTimeI;

      adj = (int_T)(offsetTimeI / sampleTimeI);
      offsetTimeI = offsetTimeI - ((real_T)adj) * sampleTimeI;
      if ((isclose(offsetTimeI, 0.0)) || (isclose(offsetTimeI, sampleTimeI)))
	offsetTimeI = 0;
      while  (offsetTimeI > sampleTimeI)
        offsetTimeI -= sampleTimeI;
      if (i > 0) {
	int_T test_flag, ii;
	test_flag = 1;
	for (ii = 0; ii<NumSampleTime; ii++) {
	  if ((isclose(sampleTimeI, past_sample[ii])) && (isclose(offsetTimeI, past_offset[ii])))
	    test_flag = 0;
	}
	if (test_flag) {
	  past_sample[NumSampleTime] = sampleTimeI;
          past_offset[NumSampleTime] = offsetTimeI;
#ifdef MATLAB_MEX_FILE
	  if (0) {
	      char_T err_msg[255];
	      sprintf(err_msg, "Sample Time: %f, Offset Time: %f\n", sampleTimeI, offsetTimeI);
	      mexPrintf(err_msg);
	  } 
#endif    
          ssSetSampleTimeEvent(S, NumSampleTime, sampleTimeI);
          ssSetOffsetTimeEvent(S, NumSampleTime, offsetTimeI);
	  NumSampleTime++;
	}
      } else {
	past_sample[NumSampleTime] = sampleTimeI;
	past_offset[NumSampleTime] = offsetTimeI;
#ifdef MATLAB_MEX_FILE
	if (0) {
	    char_T err_msg[255];
	    sprintf(err_msg, "Sample Time: %f, Offset Time: %f", sampleTimeI, offsetTimeI);
	    mexPrintf(err_msg);
        }     
#endif
        ssSetSampleTimeEvent(S, NumSampleTime, sampleTimeI);
        ssSetOffsetTimeEvent(S, NumSampleTime, offsetTimeI);
        NumSampleTime++;
      }
      if (NumSampleTime > NumSmpTm) {
#ifdef MATLAB_MEX_FILE
        mexErrMsgTxt("Check your sample time and offset time. It is not consistant.");
#endif
      }
    }
    free(past_sample);
    free(past_offset);
  }
#ifdef MATLAB_MEX_FILE
  if (0) {
      char_T err_msg[255];
      sprintf(err_msg, "NumSampleTime %d: \n", NumSampleTime);
      mexPrintf(err_msg);
  }
#endif
    ssSetNumContStates(    S, 0);
    ssSetNumDiscStates(    S, 0);
}

/*
 * mdlInitializeConditions - initializes the states for the S-Function
 */

static void mdlInitializeConditions(real_T *x0, SimStruct *S)
{

  int_T dividerSize = mxGetN(DIVIDER_EACH) * mxGetM(DIVIDER_EACH);
  int_T offsetSize  = mxGetN(OFFSET_EACH) * mxGetM(OFFSET_EACH);

  real_T *hit_base   = ssGetRWork(S);
  real_T *next_hit   = ssGetRWork(S) + 1;    
  real_T *last_value = ssGetRWork(S) + dividerSize + 1;
  real_T *increment  = ssGetRWork(S) + dividerSize * 2 + 1;
  real_T *adj_offset = ssGetRWork(S) + dividerSize * 3 + 1;
  real_T *tolerance  = ssGetRWork(S) + dividerSize * 4 + 1;
  int_T  *reverse    = ssGetIWork(S);        
  real_T  sampleTime, offsetTime, offsetMin, tmp, tol;
  int_T   i, adj;
  
  dividerSize = (dividerSize < offsetSize) ? dividerSize : offsetSize;

  offsetMin = mxGetPr(OFFSET_EACH)[0];
  sampleTime = mxGetPr(SAMPLE_TIME)[0];
  /* 
   * Initialize the last_accs to all zeros.
   */
  tol = sampleTime;
  for (i = 0; i < dividerSize; i++) {
    *last_value++ = 0.;
    
    offsetTime = mxGetPr(OFFSET_EACH)[i];        
    offsetMin = (offsetMin < offsetTime) ? offsetMin : offsetTime;
    
    next_hit[i] = offsetTime;
    
    tmp = sampleTime/2./mxGetPr(DIVIDER_EACH)[i];
    increment[i] = tmp;
    
    tol = (tol < tmp) ? tol : tmp;
    
    adj = (int_T)(offsetTime / tmp);
    tmp = offsetTime - ((real_T)adj) * tmp;

    /*
    if (isclose(tmp, 0.0)) {
      reverse[i] = 0;
    } else if (isclose(tmp, offsetTime - ((real_T)(((int_T)(offsetTime/tmp/2)))) * tmp * 2)) {
    mexPrintf("offsetTime=%f, increment[%d]=%f.",offsetTime,i,increment[i]);
    */

    if (increment[i] > offsetTime - 2 * increment[i] * floor(offsetTime/2./increment[i])) {
      reverse[i] = 0;
    } else {
      reverse[i] = 1;
    }
#ifdef MATLAB_MEX_FILE
    if (0) {
      char_T err_msg[255];
      sprintf(err_msg, "reverse[%d]=%d; \n", i, reverse[i]);
      mexPrintf(err_msg);
    }
#endif
    adj_offset[i] = tmp;
    if (tmp > 0)
      tol = (tol < tmp) ? tol : tmp;        
  }
#ifdef MATLAB_MEX_FILE
  if (0) {
    char_T err_msg[255];
    sprintf(err_msg, "\n");
    mexPrintf(err_msg);
  }
#endif
  *hit_base = offsetMin + sampleTime;
  *hit_base = sampleTime;
  *tolerance = tol / 100;
}

/*
 * mdlOutputs - computes the outputs of the S-Function
 */

static void mdlOutputs(real_T *y, const real_T *x, const real_T *u, SimStruct *S, int_T tid)
{
  int_T dividerSize = mxGetN(DIVIDER_EACH) * mxGetM(DIVIDER_EACH);
  real_T *hit_base      = ssGetRWork(S);
  real_T *next_hit      = ssGetRWork(S) + 1;    
  real_T *last_value    = ssGetRWork(S) + dividerSize + 1;
  real_T *increment     = ssGetRWork(S) + dividerSize * 2 + 1;
  real_T *adj_offset    = ssGetRWork(S) + dividerSize * 3 + 1;
  real_T *tolerance     = ssGetRWork(S) + dividerSize * 4 + 1;
  int_T    *reverse = ssGetIWork(S);
  
  real_T time_clock, tol;
  int_T i;
  
  tol = *tolerance;
  
  time_clock = ssGetT(S) + tol;
  for (i = 0; i < dividerSize; i++) {
    if (time_clock >= next_hit[i]) {
      int_T    num;
      real_T sampleTime;
      
      sampleTime = mxGetPr(SAMPLE_TIME)[0];        
      num = (int_T)((time_clock - *hit_base - adj_offset[i] - sampleTime) / increment[i]);
      num = num%2;
      if (num)
	last_value[i] = 1.;
      else
	last_value[i] = 0.;
#ifdef MATLAB_MEX_FILE
      if (0) {
	char_T err_msg[255];
	sprintf(err_msg, "reverse[%d]=%d; last_value=%d; \n", i, reverse[i], (int_T)last_value[i]);
	mexPrintf(err_msg);
      }
#endif
      if (reverse[i])
	last_value[i] = ((int_T)last_value[i] + 1) % 2;
#ifdef MATLAB_MEX_FILE
      if (0) {
	char_T err_msg[255];
	sprintf(err_msg, "new_last_value=%d;\n ", (int_T)last_value[i]);
	mexPrintf(err_msg);
      }
#endif
      next_hit[i] = next_hit[i] + increment[i];
    }
    y[i] = last_value[i];
  }
  
  /*    sprintf(err_msg, "\n ");
	mexPrintf(err_msg);
	
	for (i = 0; i < dividerSize; i++) {
	sprintf(err_msg, "output_y[%d]= %f, \", i, y[i]);
	mexPrintf(err_msg);
	}
	*/
  /* adjust the "current hit" every sample cycle.    */
  if (time_clock > *hit_base){
    real_T sampleTime;
    sampleTime = mxGetPr(SAMPLE_TIME)[0];        
    for (i = 0; i < dividerSize; i++) {
      if (time_clock > mxGetPr(OFFSET_EACH)[i]) {
	
	if (adj_offset[i] <= 0) {
	  next_hit[i] = *hit_base + increment[i];
	} else {
	  next_hit[i] = *hit_base + adj_offset[i];
	}
      }
    }
    *hit_base = *hit_base +sampleTime;        
  }    
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
}

#ifdef     MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-File interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif



