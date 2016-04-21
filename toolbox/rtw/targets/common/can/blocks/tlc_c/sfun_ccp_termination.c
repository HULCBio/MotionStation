/*
 * File: sfun_ccp_termination.c
 *
 * Abstract:
 *   
 *
 * $Revision: 1.3.4.2 $
 * $Date: 2004/04/19 01:20:03 $
 *
 * Copyright 2002-2003 The MathWorks, Inc.
 */

/*
 * You must specify the S_FUNCTION_NAME as the name of your S-function
 * (i.e. replace sfuntmpl_basic with the name of your S-function).
 */

#define S_FUNCTION_NAME sfun_ccp_termination
#define S_FUNCTION_LEVEL 2

/*
 * Need to include simstruc.h for the definition of the SimStruct and
 * its associated macro definitions.
 */
#include "simstruc.h"
#include "ccp_shared_data.h"

/*=============================
 * Externally defined functions
 *=============================*/

/*====================*
 * Defines
 *===================*/

#define P_NPARMS     0


/*====================*
 * S-function methods *
 *====================*/

/* Function: mdlInitializeSizes ===============================================
 * Abstract:
 *    The sizes information is used by Simulink to determine the S-function
 *    block's characteristics (number of inputs, outputs, states, etc.).
 */
static void mdlInitializeSizes(SimStruct *S)
{

        int idx;

        /* See sfuntmpl_doc.c for more details on the macros below */

        ssSetNumSFcnParams(S, P_NPARMS);  /* Number of expected parameters */
        // No parameters will be tunable
        for(idx=0; idx<P_NPARMS; idx++){
                ssSetSFcnParamNotTunable(S,idx);
        }

        if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
                /* Return if number of expected != number of actual parameters */
                return;
        }

        ssSetNumInputPorts(S,0);
        
        ssSetNumOutputPorts(S,2);
        ssSetOutputPortWidth(S,0,1);
        ssSetOutputPortWidth(S,1,8);
        ssSetOutputPortDataType(S,1,SS_UINT8);

        ssSetNumContStates(S, 0);
        ssSetNumDiscStates(S, 0);


        ssSetNumSampleTimes(S, 1);
        ssSetNumRWork(S, 0);
        ssSetNumIWork(S, 0);
        ssSetNumPWork(S, 0);
        ssSetNumModes(S, 0);
        ssSetNumNonsampledZCs(S, 0);

        ssSetOptions(S, 0);
}



/* Function: mdlInitializeSampleTimes =========================================
 * Abstract:
 *    This function is used to specify the sample time(s) for your
 *    S-function. You must register the same number of sample times as
 *    specified in ssSetNumSampleTimes.
 */
static void mdlInitializeSampleTimes(SimStruct *S)
{
        int idx;

        // Just set this to avoid Simulink whinging
        ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
        ssSetOffsetTime(S, 0, 0.0);

        /* Outport 0 is a function call trigger */
        ssSetCallSystemOutput(S,0);
}

#undef MDL_START  /* Change to #undef to remove function */
#if defined(MDL_START) 
/* Function: mdlStart =======================================================
 * Abstract:
 *    This function is called once at start of model execution. If you
 *    have states that should be initialized once, this is the place
 *    to do it.
 */
static void mdlStart(SimStruct *S)
{
}
#endif /*  MDL_START */



#define U(element) (*uPtrs[element])  /* Pointer to Input Port0 */
#define UT(type,element) (*((type *)uPtrs[element])) /* Pointer to Input Port0 */

/* Function: mdlOutputs =======================================================
 * Abstract:
 *    In this function, you compute the outputs of your S-function
 *    block. Generally outputs are placed in the output vector, ssGetY(S).
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
   /* the output signal */
   uint8_T* data_out = (uint8_T*) ssGetOutputPortSignal(S,1);
   if ((getHandled()==0) && (getCurrent_State()==CCP_CONNECTED_STATE)) {
      /* message is unhandled, but we are connected so we must output
       * the Unknown Command response */
      data_out[0] = 0xFF;
      data_out[1] = 0x30;
      /* Command Counter */
      data_out[2] = getData(1);
      data_out[3] = 0;
      data_out[4] = 0;
      data_out[5] = 0;
      data_out[6] = 0;
      data_out[7] = 0;
   } 
   else if (getHandled()==1) {
      /* we have a valid response */
      data_out[0] = getData(0);
      data_out[1] = getData(1);
      data_out[2] = getData(2);
      data_out[3] = getData(3);
      data_out[4] = getData(4);
      data_out[5] = getData(5);
      data_out[6] = getData(6);
      data_out[7] = getData(7);
   }
   
   if ((getHandled()==1) || (getCurrent_State()==CCP_CONNECTED_STATE)) {
      /* We either handled the message and have a valid response, 
       * or we have an unknown command response */
      if (!ssCallSystemWithTid(S,0,tid)) {
         mexPrintf("Some error!\n");
         return;
      } 
   }
}

/* Function: mdlTerminate =====================================================
 * Abstract:
 *    In this function, you should perform any actions that are necessary
 *    at the termination of a simulation.  For example, if memory was
 *    allocated in mdlStart, this is the place to free it.
 */
static void mdlTerminate(SimStruct *S)
{
}

/*======================================================*
 * See sfuntmpl_doc.c for the optional S-function methods *
 *======================================================*/

/*=============================*
 * Required S-function trailer *
 *=============================*/

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
