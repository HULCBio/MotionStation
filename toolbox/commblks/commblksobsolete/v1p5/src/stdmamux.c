/* $Revision: 1.1.6.1 $ */
/*
 *  Simulink TDMA MUX/DEMUX block.
 *
 *  Syntax:  [sys, x0] = stdmamux(t, x, u, flag, switch_box, keeping_value, ini_value)
 *  This function takes multiple inputs and may be multi-output
 *  depending on the variables switch_box, keeping_value and ini_value
 *  assignments. This block takes N+1 inputs. The first N inputs are the
 *  signals. The last signal of the block input triggers the
 *  switch. The block sends the initial value before trigger signal is received
 *
 *  switch_box: The column number is the block output number. The row
 *              number decides how many switching options. The element
 *              values of the block are in the range [0, N], where N
 *              is the vector length of the signal input of this block.
 *              This block switches the output at the rising edge of the
 *              trigger signal. When the content of the output is 0,
 *              this block outputs the specified initial value, or 0,
 *              or the last value of the output depending on the setting of
 *              -1, 0, 1 of the keeping_value.
 *  keeping_value: The keeping value should be a vector with its length
 *              the same as the column number of the variable switch_box.
 *  ini_value: The initial value of the block output. The vector size
 *              is the same as the column number of the switch_box.
 *  The vector size of this block is the same as the column number of
 *  the variable switch_box, as well as the vector size of
 *  keeping_value and ini_value.
 *
 * Wes Wang  March 6, 1995
 * Copyright 1996-2002 The MathWorks, Inc.
 */

#define S_FUNCTION_NAME stdmamux

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

#define NUM_ARGS   4
#define SWITCH_BOX         ssGetArg(S,0)
#define KEEP_VALUE         ssGetArg(S,1)
#define INI__VALUE         ssGetArg(S,2)
#define TTHRESHOLD         ssGetArg(S,3)

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
      int_T i, numoutput;
/*    char_T    err_msg[256];
 */
      numoutput = mxGetN(INI__VALUE) * mxGetM(INI__VALUE);
      if (numoutput < 1) {
#ifdef MATLAB_MEX_FILE
        char_T err_msg[256];
        sprintf(err_msg, "Empty initial variable assignment.");
        mexErrMsgTxt(err_msg);
#endif  
      }
      if (mxGetN(KEEP_VALUE) * mxGetM(KEEP_VALUE) != numoutput) {
#ifdef MATLAB_MEX_FILE
        char_T err_msg[256];
        sprintf(err_msg, "Keep_Value should have the same vector size as Ini_Value.");
        mexErrMsgTxt(err_msg);
#endif
      }
      if (mxGetN(TTHRESHOLD) * mxGetM(TTHRESHOLD) != 1) {
#ifdef MATLAB_MEX_FILE
        char_T err_msg[256];
        sprintf(err_msg, "Threshold must be a scalar.");
        mexErrMsgTxt(err_msg);
#endif
      }      
      if (mxGetN(SWITCH_BOX) != numoutput) {
#ifdef MATLAB_MEX_FILE
        char_T err_msg[256];
        sprintf(err_msg, "The column number of Switch_Box must match the vector size of Ini_Value.");
        mexErrMsgTxt(err_msg);
#endif
      }
      ssSetNumContStates(    S, 0);
      ssSetNumDiscStates(    S, 0);
      ssSetNumInputs(        S, -1);
      ssSetNumOutputs(       S, numoutput);
      ssSetDirectFeedThrough(S, 1);
      ssSetNumInputArgs(     S, NUM_ARGS);
      ssSetNumSampleTimes(   S, 1);
      ssSetNumRWork(         S, 1);
      ssSetNumIWork(         S, 2 + numoutput);
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
    int_T    *regIndex       = ssGetIWork(S);
    int_T    *lastTrig       = ssGetIWork(S) + 1;

    real_T *lastTime       = ssGetRWork(S);
    
    /*
     * Initialize the current buffer position and buffer start
     */
    
    *regIndex       = -1;
    *lastTrig       = 0;
    *lastTime       = -1.0;
}

/*
 * mdlOutputs - computes the outputs of the S-Function
 */
static void mdlOutputs(real_T *y, const real_T *x, const real_T *u, SimStruct *S, int_T tid)
{
    real_T  trigThreshold   = mxGetPr(TTHRESHOLD)[0];
    int_T    *regIndex        = ssGetIWork(S);
    int_T    *lastTrig        = ssGetIWork(S) + 1;    
    int_T     numoutput       = ssGetNumOutputs(S);
    int_T     numinput        = ssGetNumInputs(S);
    real_T *lastTime        = ssGetRWork(S);
    
    int_T     Index;
    int_T     i, outnum, m_switch_box;
    real_T  currentTime     = ssGetT(S);
/*         char_T    err_msg[256]; */
/*    char_T    err_msg[256];
    sprintf(err_msg, "**MAXDELAY %d, u[1] %f, *lastTrig %d, thrshold %f, time %f.\n", maxDelay, u[1], *lastTrig, trigThreshold, currentTime);
    mexPrintf(err_msg);    
 */
    /*
     * acquire the buffer data
     */
    if (currentTime <= 0.0) {
        for (i=0; i<numoutput; i++)
            y[i] = mxGetPr(INI__VALUE)[i];
    }
    m_switch_box = mxGetM(SWITCH_BOX);
/*      sprintf(err_msg, "m_switch_box %d, *regIndex %d, time %f., lastTrig  %d, u[numinput-1], %f, threshold %f\n", m_switch_box, *regIndex, currentTime, *lastTrig, u[numinput-1], trigThreshold);
         mexPrintf(err_msg);    
 */
    if ((u[numinput-1] >= trigThreshold) & (*lastTrig == 0)) {
        /* time for switch to the next line of the switch_box */
/*         char_T    err_msg[256];
         sprintf(err_msg, "m_switch_box %d, *regIndex %d, time %f.\n", m_switch_box, *regIndex, currentTime);
         mexPrintf(err_msg);
 */    
        /* sprintf(err_msg, "maxDelay %d\n", maxDelay);
           mexPrintf(err_msg);
         */
        *regIndex += 1;
        if (*regIndex >= m_switch_box)
            *regIndex = 0;
        for (i = 0; i < numoutput; i++) {
/*            Index = (int_T)mxGetPr(SWITCH_BOX)[*regIndex * m_switch_box +i];*/
            Index = (int_T)mxGetPr(SWITCH_BOX)[*regIndex + m_switch_box * i];
/*          sprintf(err_msg, "outnum %d, modulo(outnum)%d\n", outnum, (maxDelay + *regIndex - outnum) % maxDelay);
            mexPrintf(err_msg);
 */
            if (Index <= 0) {
                if (mxGetPr(KEEP_VALUE)[i] < 0)
                    y[i] = mxGetPr(INI__VALUE)[i];
                else if (mxGetPr(KEEP_VALUE)[i] == 0)
                    y[i] = 0.0;
            } else if (Index > numinput - 1) {
#ifdef MATLAB_MEX_FILE
                 char_T err_msg[256];
                 sprintf(err_msg, "The index number in Switch_Box variable is larger than the signal input vector.");
                 mexErrMsgTxt(err_msg);
#endif            
            } else {
                y[i] = u[Index-1];
            }
        }
        *lastTrig = 1;
        *lastTime = currentTime;
    } else {
        if (*regIndex >= 0) {
            for (i = 0; i < numoutput; i++) {
/*                Index = (int_T)mxGetPr(SWITCH_BOX)[*regIndex * m_switch_box + i];
 */
                Index = (int_T)mxGetPr(SWITCH_BOX)[*regIndex + m_switch_box * i]; 
                if (Index > 0)
                    y[i] = u[Index - 1];
            }
        }
        if (u[numinput-1] < trigThreshold)
            *lastTrig = 0;
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

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-File interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
