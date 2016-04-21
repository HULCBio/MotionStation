/*
 * MOVEINT   A Simulink moving integration
 *
 *           Syntax:  [sys, x0] = moveint(t, x, u, flag, In_length, Time_window, Sample_time, Method)
 *
 *      In-length: the vector length of the input vector.
 *      Time_window: int_t^(t+T) f(x) dx, the scale T, window size of the integration.
 *      Sample_time: sampling time of the integration. This is a discrete-time block.
 *      Method: integration method. Can be: forward, backward, first_order.
 *
 * Wes Wang Dec. 8, 1994
 * Copyright 1996-2003 The MathWorks, Inc.
 * $Revision: 1.1.6.2 $ $Date: 2004/04/12 23:02:37 $
 */

#define S_FUNCTION_NAME moveint

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
#define IN_LENGTH     ssGetArg(S,0)
#define TIME_WINDOW   ssGetArg(S,1)
#define SAMPLE_TIME   ssGetArg(S,2)
#define METHOD        ssGetArg(S,3)

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
        int_T in_length, num_points;
        char_T method[4];
        
        real_T td;
        real_T ts;  
        
#ifdef MATLAB_MEX_FILE
        if (0) {
            printf("TIME_WINDOW %f,  SAMPLE_TIME %f\n", td, ts);
        }
#endif
        
#ifdef MATLAB_MEX_FILE        
        if ((mxGetN(SAMPLE_TIME)*mxGetM(SAMPLE_TIME) != 1) &&
            (mxGetN(SAMPLE_TIME)*mxGetM(SAMPLE_TIME) != 2)) {
            mexErrMsgTxt("The sample time must be a scalar or a vector of "
                         "length 2");
        }
#endif
        ts = mxGetPr(SAMPLE_TIME)[0];

#ifdef MATLAB_MEX_FILE
        if(mxGetNumberOfElements(TIME_WINDOW) != 1) {
            char_T err_msg[256];
            sprintf(err_msg, "The integration window length must be "
                    "a scalar value.");
            mexErrMsgTxt(err_msg);
        }
#endif
        td = mxGetPr(TIME_WINDOW)[0];

#ifdef MATLAB_MEX_FILE        
        if ((mxGetN(IN_LENGTH) != 1) || (mxGetM(IN_LENGTH) != 1)) {
            mexErrMsgTxt("The input vector size must be a scalar value.");
        }
                
        if (mxGetM(METHOD) != 1) {
            mexErrMsgTxt("Integration method must be a string");
        }
#endif

        if(mxIsInf(td)) {
#ifdef  MATLAB_MEX_FILE 
           mexErrMsgTxt("The integration window length cannot be infinite.");
#endif
        } 

        in_length  = (int_T)mxGetPr(IN_LENGTH)[0];
        num_points = (int_T)(td / ts + 1.49);

#ifdef MATLAB_MEX_FILE
        if (num_points <= 2) {
            mexErrMsgTxt("The integration window length must be greater "
                         "than sample time.");
        } else if (in_length < 1) {
           mexErrMsgTxt("The input vector length must be a positive number.");
        }
#endif

       mxGetString(METHOD, method, 3);
        
       ssSetNumContStates(    S, 0);
       ssSetNumDiscStates(    S, 0);
       ssSetNumInputs(        S, in_length);
       ssSetNumOutputs(       S, in_length);
       ssSetDirectFeedThrough(S, 1);
    
       ssSetNumInputArgs(     S, NUM_ARGS);
       ssSetNumSampleTimes(   S, 1);
       ssSetNumRWork(         S, in_length*(num_points + 1) + 1);
       /* storage: t, points, last_integration_value */
       ssSetNumIWork(         S, 2);
       /* Total_points=num_points, current points */
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

    sampleTime = mxGetPr(SAMPLE_TIME)[0];
    if ((mxGetN(SAMPLE_TIME) * mxGetM(SAMPLE_TIME)) == 2)
       offsetTime = mxGetPr(SAMPLE_TIME)[1];
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
    int_T in_length = (int_T)mxGetPr(IN_LENGTH)[0];
    int_T num_points = (int_T)(mxGetPr(TIME_WINDOW)[0] / mxGetPr(SAMPLE_TIME)[0] + 0.49) + 1;
    
    real_T *last_time  = ssGetRWork(S);
    real_T *storage_point = ssGetRWork(S) + 1;
    real_T *integ_value   = ssGetRWork(S) + in_length * num_points + 1;
    
    int_T *cur_point       = ssGetIWork(S);
    int_T i;
    
    /* 
     * Initialize all storage and integration values
     */

    for (i = 0; i < in_length * (num_points + 1); i++)
      *storage_point++ = 0.;
    *last_time = -1;
    /*
     * IWork
     */
    
    *cur_point++       = num_points;
    *cur_point         = 0;
}

/*
 * mdlOutputs - computes the outputs of the S-Function
 */

static void mdlOutputs(real_T *y, const real_T *x, const real_T *u, SimStruct *S, int_T tid)
{
    int_T *num_points     = ssGetIWork(S);
    int_T *cur_point      = ssGetIWork(S)+1;
    int_T in_length       = (int_T)mxGetPr(IN_LENGTH)[0];

    real_T *last_time = ssGetRWork(S);
    real_T *storage_point = ssGetRWork(S) + 1;
    real_T *integ_value   = ssGetRWork(S) + (in_length * (*num_points) + 1);
    
    real_T sample_time = mxGetPr(SAMPLE_TIME)[0];

    real_T current_time;
    int_T i;
    char_T method[4];

    current_time  = ssGetT(S);
    mxGetString(METHOD, method, 3);

    if (*num_points > 0) {
      if ((current_time - *last_time) > sample_time/1000000.) {
        int_T increament, point_before, point_after;

        point_before = (*num_points + *cur_point - 1) % (*num_points);
        point_after  = (*cur_point + 1) % (*num_points);
        for (i=0; i<in_length; i++) {
          increament = (*num_points) * i;
          if ((method[0] == 'f') && (method[1] == 'o')) {
            integ_value[i] = integ_value[i]
                   + (storage_point[point_before + increament]
                   - storage_point[*cur_point + increament]) * sample_time;
          } else if ((method[0] == 'b') && (method[1] == 'a')) {
            integ_value[i] = integ_value[i]
                  + (u[i]
                  - storage_point[point_after + increament]) * sample_time;
          } else {
            integ_value[i] = integ_value[i]
                  + (u[i]
                  + storage_point[point_before + increament]
                  - storage_point[(*cur_point) + increament]
                  - storage_point[point_after + increament]) * sample_time / 2;
          }
          storage_point[(*cur_point) + increament] = u[i];
        }
        *cur_point = point_after;
        *last_time = current_time;
      } else {
        for (i=0; i<in_length; i++) {
           int_T increament;
           increament = (*num_points) * i;
           if ((method[0] == 'f') && (method[1] == 'o')) {
           } else if ((method[0] == 'b') && (method[1] == 'a')) {
             integ_value[i] = integ_value[i]
                    + (u[i]
                    - storage_point[*cur_point + increament]) * sample_time;
           } else {
             integ_value[i] = integ_value[i]
                    + (u[i]
                    - storage_point[(*cur_point) + increament]) * sample_time / 2;
           }
           storage_point[(*cur_point) + increament] = u[i];
         }
       }
     }
     for (i = 0; i<in_length; i++)
       y[i] = integ_value[i];
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

#ifdef   MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-File interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
