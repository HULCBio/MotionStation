/*
 * File: sfun_vector_can_app_init.c
 *
 * Abstract:
 *    S-function for initialization of Vector CAN channel
 *
 *
 * $Revision: 1.1.6.2 $
 * $Date: 2004/04/19 01:20:08 $
 *
 * Copyright 1990-2003 The MathWorks, Inc.
 */

#define S_FUNCTION_NAME  sfun_vector_can_app_init
#define S_FUNCTION_LEVEL 2

/*
 * Need to include simstruc.h for the definition of the SimStruct and
 * its associated macro definitions.
 */
#include "simstruc.h"
#include "sfun_vector_can.h"
#include "windows.h"

/*=============*
 * Parameters
 *=============*/

enum { E_CHANNEL_PARAM=0, E_DISABLED, E_TAG, P_NPARMS};

// macros for grabbing the params.
#define P_INT_SCALAR(ID) ((int)mxGetScalar(ssGetSFcnParam(S,(ID)))) 
#define P_REAL_SCALAR(ID) ((real_T)mxGetScalar(ssGetSFcnParam(S,(ID)))) 

#define P_CHANNEL_PARAM P_INT_SCALAR(E_CHANNEL_PARAM)
#define P_DISABLED P_INT_SCALAR(E_DISABLED)

/* Error handling
 * --------------
 *
 * You should use the following technique to report errors encountered within
 * an S-function:
 *
*       ssSetErrorStatus(S,"Error encountered due to ...");
*       return;
 *
 * Note that the 2nd argument to ssSetErrorStatus must be persistent memory.
 * It cannot be a local variable. For example the following will cause
 * unpredictable errors:
 *
*      mdlOutputs()
*      {
*         char msg[256];         {ILLEGAL: to fix use "static char msg[256];"}
*         sprintf(msg,"Error due to %s", string);
*         ssSetErrorStatus(S,msg);
*         return;
*      }
 *
 * See matlabroot/simulink/src/sfuntmpl_doc.c for more details.
 */

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
   /* See sfuntmpl_doc.c for more details on the macros below */

   int idx;
   int chanIndex;
   int disabled = P_DISABLED;
   ErrorStatus errorStatus;
   
   ssSetNumSFcnParams(S, P_NPARMS);  /* Number of expected parameters */

   // No parameters will be tunable
   for(idx=0; idx<P_NPARMS; idx++){
      ssSetSFcnParamNotTunable(S,idx);
   }

   if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
      /* Return if number of expected != number of actual parameters */
      return;
   }

   ssSetNumContStates(S, 0);
   ssSetNumDiscStates(S, 0);

   if (!ssSetNumInputPorts(S, 0)) return;

   if (!ssSetNumOutputPorts(S, 0)) return;

   ssSetNumSampleTimes(S, 1);
   ssSetNumRWork(S, 0);
   ssSetNumIWork(S, 0);
   ssSetNumPWork(S, 0);
   ssSetNumModes(S, 0);
   ssSetNumNonsampledZCs(S, 0);

   if ( disabled == 1 ) {
      return;
   }

   /* NOTE: SS_OPTION_CALL_TERMINATE_ON_EXIT
    *
    * makes sure mdlTerminate is always called (even after model update).
    * This means that all ports are shutdown correctly (in case of failure creating 
    * writeports) */
   ssSetOptions(S, SS_OPTION_CALL_TERMINATE_ON_EXIT);
}

/* Function: mdlInitializeSampleTimes =========================================
 * Abstract:
*    This function is used to specify the sample time(s) for your
*    S-function. You must register the same number of sample times as
*    specified in ssSetNumSampleTimes.
*/
static void mdlInitializeSampleTimes(SimStruct *S)
{
   ssSetSampleTime(S, 0, -1);
   ssSetOffsetTime(S, 0, 0.0);
}

#define MDL_INITIALIZE_CONDITIONS   /* Change to #undef to remove function */
#if defined(MDL_INITIALIZE_CONDITIONS)
/* Function: mdlInitializeConditions ========================================
 * Abstract:
*    In this function, you should initialize the continuous and discrete
*    states for your S-function block.  The initial states are placed
*    in the state vector, ssGetContStates(S) or ssGetRealDiscStates(S).
*    You can also perform any other initialization activities that your
*    S-function may require. Note, this routine will be called at the
*    start of simulation and if it is present in an enabled subsystem
*    configured to reset states, it will be call when the enabled subsystem
*    restarts execution to reset the states.
*/
static void mdlInitializeConditions(SimStruct *S)
{
}
#endif /* MDL_INITIALIZE_CONDITIONS */

#define MDL_START  /* Change to #undef to remove function */
#if defined(MDL_START) 
/* Function: mdlStart =======================================================
 * Abstract:
*    This function is called once at start of model execution. If you
*    have states that should be initialized once, this is the place
*    to do it.
*/
static void mdlStart(SimStruct *S)
{
   int disabled = P_DISABLED;
   char * id_string; 
   ErrorStatus errorStatus;
   
   if ( disabled == 1 ) {
      return;
   }
      
   /* create a master port that will be shared by all Vector transmit blocks */
   /* id shared by all tx blocks in this model */
   id_string = generateIdString(S,E_TAG);    
     
   errorStatus = LibraryCreateMasterPortOnAppChannel(P_CHANNEL_PARAM,
                                         id_string);

   if (handleVectorError(errorStatus)) {
      ssSetErrorStatus(S, err_msg);
      return;
   }
  
   /* free persistent id_string */
   mxFree(id_string);
}
#endif /*  MDL_START */



/* Function: mdlOutputs =======================================================
 * Abstract:
*    In this function, you compute the outputs of your S-function
*    block. Generally outputs are placed in the output vector, ssGetY(S).
*/
static void mdlOutputs(SimStruct *S, int_T tid)
{
   // Do nothing during simulation run time
}



#define MDL_UPDATE  /* Change to #undef to remove function */
#if defined(MDL_UPDATE)
/* Function: mdlUpdate ======================================================
 * Abstract:
*    This function is called once for every major integration time step.
*    Discrete states are typically updated here, but this function is useful
*    for performing any tasks that should only take place once per
*    integration step.
*/
static void mdlUpdate(SimStruct *S, int_T tid)
{
}
#endif /* MDL_UPDATE */



#define MDL_DERIVATIVES  /* Change to #undef to remove function */
#if defined(MDL_DERIVATIVES)
/* Function: mdlDerivatives =================================================
 * Abstract:
*    In this function, you compute the S-function block's derivatives.
*    The derivatives are placed in the derivative vector, ssGetdX(S).
*/
static void mdlDerivatives(SimStruct *S)
{
}
#endif /* MDL_DERIVATIVES */



/* Function: mdlTerminate =====================================================
 * Abstract:
*    In this function, you should perform any actions that are necessary
*    at the termination of a simulation.  For example, if memory was
*    allocated in mdlStart, this is the place to free it.
*/
static void mdlTerminate(SimStruct *S)
{
   int isActive;
   int disabled = P_DISABLED;
   char * id_string;
   
   if (disabled == 1) {
      return;
   }
  
   /* generate the id string to present to vector_can_interface */
   id_string = generateIdString(S,E_TAG);    
   
   /* shutdown the master port, but only if it is active */
   if (handleVectorError(LibraryIsPortIdActive(id_string, &isActive))) {
      ssSetErrorStatus(S, err_msg);
      return; 
   }
      
   if (isActive) {
      if (handleVectorError(LibraryShutdownPort(id_string))) {
         ssSetErrorStatus(S, err_msg);
         return;
      }      
   }
   mxFree(id_string);
}

#define MDL_RTW
#if defined(MDL_RTW) && (defined(MATLAB_MEX_FILE) || defined(NRT))
static void mdlRTW(SimStruct *S) {
   char * id_string = generateIdString(S,E_TAG);
  
   int8_T chanIndexInt8 = P_CHANNEL_PARAM;
  
   /* master CHANNEL_PARAM, ID_STRING and all TIMING Params */
   if (!ssWriteRTWParamSettings(S, 2, 
         SSWRITE_VALUE_DTYPE_NUM, "CHANNEL_PARAM", 
         &chanIndexInt8, DTINFO(SS_INT8,0),
         SSWRITE_VALUE_STR,         "ID_STRING",
         id_string)) {
      ssSetErrorStatus(S,"Writing Values to RTW file failed.\n");
   }
   /* free up mem */
   mxFree(id_string);
}
#endif

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
