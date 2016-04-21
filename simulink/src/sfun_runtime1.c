/*   Copyright 1990-2004 The MathWorks, Inc.
/* $Revision: 1.7.4.3 $ */
/*
 * File : sfun_runtime1.c
 * Abstract:
 *      Run-time parameter S-function example. 
 *
 *      This S-function accepts N input
 *      signals (which can be scalar or vector) and produces 1 or 2
 *      outputs which are the sum*gain or both sum*gain and average of the
 *      input signals.
 *
 *      To use this S-function, place it in an S-function block,
 *      the first parameter is the number of input ports specified as
 *      a string of '+' and '-' characters, e.g.
 *          '++-'
 *      The second parameter is a gain to be applied to the sum of the
 *      input signals.
 *
 *      The third parameter is one of the following text strings:
 *         'SumTimesGain'
 *         'SumTimesGainAndAverage'
 *
 *  See simulink/src/sfuntmpl.doc
 *
 */


/*
 * You must specify the S_FUNCTION_NAME as the name of your S-function.
 */

#define S_FUNCTION_NAME  sfun_runtime1
#define S_FUNCTION_LEVEL 2

/*
 * Need to include simstruc.h for the definition of the SimStruct and
 * its associated macro definitions.
 */
#include <string.h>
#include "tmwtypes.h"
#include "simstruc.h"


#define SIGNS_IDX 0
#define SIGNS_PARAM(S) ssGetSFcnParam(S,SIGNS_IDX)

#define GAIN_IDX  1
#define GAIN_PARAM(S) ssGetSFcnParam(S,GAIN_IDX)

#define OUT_IDX   2
#define OUT_PARAM(S) ssGetSFcnParam(S,OUT_IDX)

#define NPARAMS   3


#if !defined(MATLAB_MEX_FILE)
/*
 * This file cannot be used directly with the Real-Time Workshop. However,
 * this S-function does work with the Real-Time Workshop via
 * the Target Language Compiler technology. See 
 * matlabroot/toolbox/simulink/blocks/tlc_c/sfun_multiport.tlc   
 * for the C version
 * matlabroot/toolbox/simulink/blocks/tlc_ada/sfun_multiport.tlc 
 * for the Ada version
 */
# error This_file_can_be_used_only_during_simulation_inside_Simulink
#endif


/*====================*
 * S-function methods *
 *====================*/

#define MDL_CHECK_PARAMETERS
#if defined(MDL_CHECK_PARAMETERS) && defined(MATLAB_MEX_FILE)
  /* Function: mdlCheckParameters =============================================
   * Abstract:
   *    Validate our parameters to verify they are okay.
   */
  static void mdlCheckParameters(SimStruct *S)
  {
      /* Check 1st parameter: signs parameter */
      {
          int_T     nu;
          char_T    *plusMinusStr;
          boolean_T illegalParam = 0;

          if (!mxIsChar(SIGNS_PARAM(S)) ||
              (nu=mxGetNumberOfElements(SIGNS_PARAM(S))) < 2) {
              illegalParam = 1;
          } else {
              if ((plusMinusStr=(char_T*)malloc(nu+1)) == NULL) {
                  ssSetErrorStatus(S,"Memory allocation error while parsing "
                                   "1st parameters");
                  return;
              }
              if (mxGetString(SIGNS_PARAM(S),plusMinusStr,nu+1) != 0) {
                  free(plusMinusStr);
                  ssSetErrorStatus(S,"mxGetString error while parsing 1st "
                                   "parameter");
                  return;
              } else {
                  int_T i;
                  for (i = 0; i < nu; i++) {
                      if (plusMinusStr[i] != '+' && plusMinusStr[i] != '-') {
                          illegalParam = 1;
                          break;
                      }
                  }
              }
              free(plusMinusStr);
          }

          if (illegalParam) {
              ssSetErrorStatus(S,"1st parameter to S-function must be a "
                               "string of at least 2 '+' and '-' characters");
              return;
          }
      }

      /* Check 2nd parameter: gain to be applied to the sum */
      {
          if (!mxIsDouble(GAIN_PARAM(S)) ||
              mxGetNumberOfElements(GAIN_PARAM(S)) != 1) {
              ssSetErrorStatus(S,"2nd parameter to S-function must be a "
                               "scalar \"gain\" value to be applied to "
                               "the sum of the inputs");
              return;
          }
      }


      /*
       * Check 3nd parameter: what to output (SumTimesGain or
       * SumTimesGainAndAverage.
       */
      {
          char_T str[sizeof("SumTimesGainAndAverage")];

          if (!mxIsChar(OUT_PARAM(S)) ||
              mxGetNumberOfElements(OUT_PARAM(S)) >= sizeof(str) ||
              mxGetString(OUT_PARAM(S),str,sizeof(str)) != 0 ||
              (strcmp(str,"SumTimesGain") != 0 &&
               strcmp(str,"SumTimesGainAndAverage") != 0)) {
              ssSetErrorStatus(S, "3rd parameter to S-function must be a "
                               "string specifying what to output: "
                               "'SumTimesGain', or 'SumTimesGainAndAverage'");
              return;
          }
      }
  }
#endif /* MDL_CHECK_PARAMETERS */



/* Function: mdlInitializeSizes ===============================================
 * Abstract:
 *    Call mdlCheckParameters to verify that the parameters are okay,
 *    then setup sizes of the various vectors.
 */
static void mdlInitializeSizes(SimStruct *S)
{
    /* See sfuntmpl.doc for more details on the macros below */

    ssSetNumSFcnParams(S, NPARAMS);  /* Number of expected parameters */
#if defined(MATLAB_MEX_FILE)
    if (ssGetNumSFcnParams(S) == ssGetSFcnParamsCount(S)) {
        mdlCheckParameters(S);
        if (ssGetErrorStatus(S) != NULL) {
            return;
        }
    } else {
        return; /* Parameter mismatch will be reported by Simulink */
    }
#endif

    ssSetSFcnParamTunable(S,GAIN_IDX,true);
    ssSetSFcnParamTunable(S,SIGNS_IDX,false);
    ssSetSFcnParamTunable(S,OUT_IDX,false);  

    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);

    {
        int_T nu = (int_T)mxGetNumberOfElements(SIGNS_PARAM(S));
        int_T i;

        if (!ssSetNumInputPorts(S, nu)) return;
        for (i = 0; i < nu; i++) {
            ssSetInputPortWidth(S, i, DYNAMICALLY_SIZED);
            ssSetInputPortDirectFeedThrough(S, i, 1);
            ssSetInputPortOverWritable(S, i, 1);
            ssSetInputPortOptimOpts(S, i, SS_REUSABLE_AND_LOCAL);
        }
    }

    {
        int_T  i;
        int_T  nOutputPorts;
        char_T str[sizeof("SumTimesGainAndAverage")];

        mxGetString(OUT_PARAM(S),str,sizeof(str));

        if (strcmp(str,"SumTimesGain")==0) {
            nOutputPorts = 1;
        } else {
            nOutputPorts = 2;
        }

        if (!ssSetNumOutputPorts(S, nOutputPorts)) return;
        for (i = 0; i < nOutputPorts; i++) {
            ssSetOutputPortWidth(S, i, DYNAMICALLY_SIZED);
            ssSetOutputPortOptimOpts(S, i, SS_REUSABLE_AND_LOCAL);
        }
    }

    ssSetNumSampleTimes(S, 1);
    ssSetNumRWork(S, 0);
    ssSetNumIWork(S, 0);
    ssSetNumPWork(S, 0);
    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);

    /* Take care when specifying exception free code - see sfuntmpl.doc */
    ssSetOptions(S,
                 SS_OPTION_WORKS_WITH_CODE_REUSE |
                 SS_OPTION_EXCEPTION_FREE_CODE |
                 SS_OPTION_ALLOW_INPUT_SCALAR_EXPANSION |
                 SS_OPTION_USE_TLC_WITH_ACCELERATOR |
                 SS_OPTION_CALL_TERMINATE_ON_EXIT);
}



/* Function: mdlInitializeSampleTimes =========================================
 * Abstract:
 *    Specifiy that we inherit our sample time from the driving block.
 */
static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);
    ssSetModelReferenceSampleTimeDefaultInheritance(S);
}


#define MDL_SET_WORK_WIDTHS   /* Change to #undef to remove function */
#if defined(MDL_SET_WORK_WIDTHS) && defined(MATLAB_MEX_FILE)
/* Function: mdlSetWorkWidths ===============================================
 * Abstract:
 *      Set up run-time parameters.
 */
static void mdlSetWorkWidths(SimStruct *S)
{
    const char_T    *rtParamNames[] = {"Gain"};
    ssRegAllTunableParamsAsRunTimeParams(S, rtParamNames);
}
#endif /* MDL_SET_WORK_WIDTHS */


#define MDL_PROCESS_PARAMETERS   /* Change to #undef to remove function */
#if defined(MDL_PROCESS_PARAMETERS) && defined(MATLAB_MEX_FILE)
/* Function: mdlProcessParameters ===========================================
 * Abstract:
 *      Update run-time parameters.
 */
static void mdlProcessParameters(SimStruct *S)
{
    /* Update Run-Time parameters */
    ssUpdateAllTunableParamsAsRunTimeParams(S);
}
#endif /* MDL_PROCESS_PARAMETERS */


#define MDL_START
#if defined(MDL_START)
/* Function: mdlStart =========================================================
 * Abstract:
 *    Initialize user data with "cached" sign string values (1 or -1), so that
 *    we do need not use string functions in the main simulation loop.
 */
static void mdlStart(SimStruct *S)
{
    int_T nInputPorts = ssGetNumInputPorts(S);
    int   *signs;

    if ((signs=(int_T*)malloc(nInputPorts*sizeof(int_T))) == NULL) {
        ssSetErrorStatus(S,"Memory allocation error in mdlStart");
        return;
    }

    {
        int_T  i;
        char_T *plusMinusStr;
        
        if ( (plusMinusStr=(char_T*)malloc(nInputPorts+1)) == NULL ) {
            ssSetErrorStatus(S,"Memory allocation error in mdlStart");
            return;
        }
        
        if ( mxGetString(SIGNS_PARAM(S),plusMinusStr,nInputPorts+1) != 0 ) {
            free(plusMinusStr);
            ssSetErrorStatus(S,"mxGetString error in mdlStart");
            return;
        }
        
        for (i = 0; i < nInputPorts; i++) {
            signs[i] = (plusMinusStr[i] == '+') ? 1 : -1;
        }
        
        free(plusMinusStr);
    }

    ssSetUserData(S, (void*)signs);
}
#endif /* MDL_START */



/* Function: mdlOutputs =======================================================
 * Abstract:
 *
 *      y1 = "sum" * "gain" where sum operation is defined by a list of
 *           '+' and '-' characters.
 *      y2 = "modified" average of the input signals (i.e. sum/nInputPorts).
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
    int_T  el;
    int_T  yWidth       = ssGetOutputPortWidth(S,0);
    real_T *y1          = ssGetOutputPortRealSignal(S,0);
    int_T  nInputPorts  = ssGetNumInputPorts(S);
    int_T  nOutputPorts = ssGetNumOutputPorts(S);
    int_T  *signs       = ssGetUserData(S);
    real_T gain         = *((real_T *)((ssGetRunTimeParamInfo(S,0))->data));

    /*
     * Generate sum and if needed average.
     */
    for (el = 0; el < yWidth; el++) {
        int_T  port;
        real_T sum = 0.0;
        for (port = 0; port < nInputPorts; port++) {
            InputRealPtrsType uPtrs = ssGetInputPortRealSignalPtrs(S,port);
            if (el < ssGetInputPortWidth(S,port)) {
                sum = sum + ((real_T)signs[port] * (*uPtrs[el]));
            } else { /* scalar expanding the signal */
                sum = sum + ((real_T)signs[port] * (*uPtrs[0]));
            }
        }

        y1[el] = sum * gain;

        if (nOutputPorts == 2) {
            real_T *y2 = ssGetOutputPortRealSignal(S,1);
            y2[el] = sum/(real_T)nInputPorts;
        }
    }
}



/* Function: mdlTerminate =====================================================
 * Abstract:
 *      Free the user data.
 */
static void mdlTerminate(SimStruct *S)
{
    int_T *signs = ssGetUserData(S);
    if (signs != NULL) {
        free(signs);
    }
}



#if defined(MATLAB_MEX_FILE)
#define MDL_RTW
/* Function: mdlRTW ===========================================================
 * Abstract:
 *      Write out the single "gain" parameter for this block.
 *      Write out the signs parameter setting for this block.
 */
static void mdlRTW(SimStruct *S)
{

    /*
     * Write out the "SignsStr" param settings.  An example of its form for
     *   '++-' is:
     *
     *      ["+", "+", "-"], so to be consertive we will consider the length
     *                       of the string to be:
     *      
     *          nu = number of signs
     *
     * length = (nu * 5) +  %quote,sign,quote,comma,space
     *          2           %brackets
     *          1           %NULL terminator ('\0')
     */
    {
        int_T     nu  = mxGetNumberOfElements(SIGNS_PARAM(S));
        boolean_T err = 0;
        char_T    *plusMinusStr;
        char_T    *signsStr;

        if ((plusMinusStr=(char_T*)malloc(nu+1)) == NULL ||
            (signsStr=(char_T*)malloc((nu*5)+2+1)) == NULL) {
            ssSetErrorStatus(S,"Memory allocation error in mdlRTW");
            return;
        }

        if (mxGetString(SIGNS_PARAM(S),plusMinusStr,nu+1) != 0) {
            err = 1;
            ssSetErrorStatus(S,"mxGetString error in mdlRTW");
        } else {
            int_T i;

            (void)strcpy(signsStr,"[");
            for (i = 0; i < nu; i++) {
                (void)sprintf(&signsStr[strlen(signsStr)],"\"%c\"%s",
                              plusMinusStr[i], (i+1==nu? "]": ", "));
            }

            if (!ssWriteRTWParamSettings(S, 1,
                                         SSWRITE_VALUE_VECT_STR,
                                         "SignsStr",
                                         signsStr,nu)) {
                err = 1; /* An error occurred which will be reported by SL */
            }
        }

        free(plusMinusStr);
        free(signsStr);

        if (err) {
            return;
        }
    }
}
#endif /* MDL_RTW */

/*======================================================*
 * See sfuntmpl.doc for the optional S-function methods *
 *======================================================*/

/*=============================*
 * Required S-function trailer *
 *=============================*/

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
