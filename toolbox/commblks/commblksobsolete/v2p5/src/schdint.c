/* $Revision: 1.1.6.2 $ */
/*
 * SCHDINT   A Simulink scheduling integration
 *
 *           Syntax:  [sys, x0] = schdint(t, x, u, flag, TD, TS, Modulo)
 *
 *      This block will reset the integration to be zero at K*TD(1) + TD(2).
 *      TS: sampling time of the integration. This is a discrete-time block.
 *      Modulo: Limitation of the integration. When State is larger than this
 *              value it will do x=rem(x,Modulo) computation.
 *
 * Wes Wang Dec. 8, 1994
 * Copyright 1996-2003 The MathWorks, Inc.
 */

#define S_FUNCTION_NAME schdint

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
#define NUM_ARGS   3
#define TD         ssGetArg(S,0)
#define TS         ssGetArg(S,1)
#define Modulo     ssGetArg(S,2)

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

    real_T td;
    real_T ts;
    real_T mod_bound; 

    if ((mxGetN(TD)*mxGetM(TD) != 1) &&
	(mxGetN(TD)*mxGetM(TD) != 2)) {
#ifdef MATLAB_MEX_FILE
      mexErrMsgTxt("The reset time must be a scalar or a vector of length 2");
#endif
    }
    if ((mxGetN(TS)*mxGetM(TS) != 1) &&
	(mxGetN(TS)*mxGetM(TS) != 2)) {
#ifdef MATLAB_MEX_FILE
      mexErrMsgTxt("The sample time must be a scalar or a vector of length 2");
#endif
     }
    if (mxGetN(Modulo)*mxGetM(Modulo) != 1) {
#ifdef MATLAB_MEX_FILE
      mexErrMsgTxt("The modulo number must be a scalar value.");
#endif
    }

    mod_bound = mxGetPr(Modulo)[0];
    if (mod_bound <= 0) {
#ifdef MATLAB_MEX_FILE
      mexErrMsgTxt("The modulo number can be positive number only.");
#endif
    }           

    td = mxGetPr(TD)[0];
    ts = mxGetPr(TS)[0];

    ssSetNumContStates(    S, 0);
    ssSetNumDiscStates(    S, -1);
    ssSetNumInputs(        S, -1);
    ssSetNumOutputs(       S, -1);
    ssSetDirectFeedThrough(S, 0);
    ssSetNumInputArgs(     S, NUM_ARGS);
    if (td < ts) {
#ifdef MATLAB_MEX_FILE
      mexErrMsgTxt("The reset interval cannot be smaller than the sample time.");
#endif
    }
    if (ts / td < 10e-10)
        ssSetNumSampleTimes(   S, 1);
    else
        ssSetNumSampleTimes(   S, 2);
    ssSetNumRWork(         S, 2);
    ssSetNumIWork(         S, 1);
    ssSetNumPWork(         S, 0);
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
  real_T sampleTime, offsetTime;

  /*
   * Note, blocks that are continuous in nature should have a single
   * sample time of 0.0.
   */

  real_T td = mxGetPr(TD)[0];
  real_T ts = mxGetPr(TS)[0];  

  if (ts / td >= 1.0e-10){
      sampleTime = mxGetPr(TD)[0];

      if ((mxGetN(TD) * mxGetM(TD)) == 2)
          offsetTime = mxGetPr(TD)[1];
      else
          offsetTime = 0.;
    
      ssSetSampleTimeEvent(S, 1, sampleTime);
      ssSetOffsetTimeEvent(S, 1, offsetTime);
  }

  sampleTime = mxGetPr(TS)[0];
  if ((mxGetN(TS) * mxGetM(TS)) == 2)
    offsetTime = mxGetPr(TS)[1];
  else
    offsetTime = 0.;
  
  ssSetSampleTimeEvent(S, 0, sampleTime);
  ssSetOffsetTimeEvent(S, 0, offsetTime);      
}

/*
 * mdlInitializeConditions - initializes the states for the S-Function
 */


static void mdlInitializeConditions(real_T *x0, SimStruct *S)
{
  real_T *current_drive_time  = ssGetRWork(S);
  real_T *last_time = ssGetRWork(S) + 1;
  real_T sampleTime;
  int_T    *hitted_num = ssGetIWork(S);
  int_T in_length = ssGetNumInputs(S);
  int_T i;
  
  if (ssGetT(S) <= 0) {
    sampleTime = mxGetPr(TS)[0];    
    /*take the following number instead of 0 to avoid additive error for miss hitting*/
    *current_drive_time = 0.0;
    *last_time = ssGetT(S)-sampleTime;
    *hitted_num = 0;
    for (i=0; i<in_length; i++)
      x0[i] = 0.0;
  }
}

/*
 * mdlOutputs - computes the outputs of the S-Function
 */

static void mdlOutputs(real_T *y, const real_T *x, const real_T *u, SimStruct *S, int_T tid)
{
  int_T in_length = ssGetNumInputs(S);
  int_T i;

#ifdef MATLAB_MEX_FILE
  if (0) {
    char_T err_msg[256];
    sprintf(err_msg, "Output checking point Time: %f\n", ssGetT(S));
    mexPrintf(err_msg);
    for (i = 0; i<in_length; i++) {
      sprintf(err_msg, "State %f, [%i]\n", x[i], i);
      mexPrintf(err_msg);
    }
  }
#endif
  if (ssIsMajorTimeStep(S)){
    for (i=0; i<in_length;i++)
      y[i] = x[i];
  }
}

/*
 * mdlUpdate - computes the discrete states of the S-Function
 */

static void mdlUpdate(real_T *x, const real_T *u, SimStruct *S, int_T tid)
{
  real_T *current_drive_time  = ssGetRWork(S);
  real_T *last_time = ssGetRWork(S) + 1;
  real_T current_time = ssGetT(S);
  real_T sampleTime, offsetTime, time_step, it_time;
  
  int_T    *hitted_num = ssGetIWork(S);    
  int_T in_length = ssGetNumInputs(S);
  int_T i;
  
  it_time = mxGetPr(TS)[0];    
  sampleTime = mxGetPr(TD)[0];
  if ((mxGetN(TD) * mxGetM(TD)) == 2)
    offsetTime = mxGetPr(TD)[1];
  else
    offsetTime = 0.;
  
  /* calculation only if the time is passed offset time. */
  if (current_time >= offsetTime) {
    real_T mod_bound;
    
    mod_bound = mxGetPr(Modulo)[0];
    time_step = current_time - (*last_time);
    time_step = time_step < it_time ? time_step : it_time;
    *current_drive_time += time_step;

#ifdef MATLAB_MEX_FILE
    if (0) {
       char_T err_msg[256];
       sprintf(err_msg, "Current_drive_time %f, Current_time %f, Sample_time %f, hitted_num %i, offsetTime %f\n", *current_drive_time, current_time, sampleTime, *hitted_num, offsetTime);
	  mexPrintf(err_msg);        
    }
#endif
    /*
    if ((*current_drive_time >= sampleTime) || ((*hitted_num>0) && (current_time >= (real_T)(*hitted_num) * sampleTime + offsetTime))){
    */
    if ((*current_drive_time >= sampleTime) || ( current_time >= (real_T)(*hitted_num) * sampleTime + offsetTime ) ){
      /*reset*/
      for (i=0; i<in_length; i++) {
	/*    sprintf(err_msg, "x %f, time_step %f\n", x[i], time_step);
	      mexPrintf(err_msg);                        
	      */
	x[i] = u[i] * time_step;
	if (mxIsInf(mod_bound))
	  x[i] = x[i];
	else
	  x[i] = fmod(x[i], mod_bound);               
      }
      *hitted_num += 1;
      /*take the following number instead of 0 to avoid additive error for miss hitting*/
      *current_drive_time = sampleTime/1000000000;
    } else {
      for (i=0; i<in_length; i++) {
	/*    sprintf(err_msg, "ELSE x %f, time_step %f\n", x[i], time_step);
	      mexPrintf(err_msg);                                        
	      */
	x[i] += u[i] * time_step;
	if (mxIsInf(mod_bound))
	  x[i] = x[i];
	else
	  x[i] = fmod(x[i], mod_bound); 
      }
    }
  }
  if (current_time > *last_time)
    *last_time = current_time;
#ifdef MATLAB_MEX_FILE
    if (0) {
      char_T err_msg[256];
      for (i = 0; i<in_length; i++) {
         sprintf(err_msg, "State %f, [%i]\n", x[i], i);
         mexPrintf(err_msg);
      }
    }
#endif
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

#ifdef   MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-File interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
