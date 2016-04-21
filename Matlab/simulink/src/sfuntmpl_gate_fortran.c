/*
 *  File: sfuntmpl_gate_fortran.c
 *
 *  Abstract:: 
 *
 *  C->Fortran gateway TEMPLATE for a level 2 S-function.
 *  Copy, rename and then edit this file to call your Fortran
 *  code in the solver mode you want, then build it.
 *
 *  To build the mex file, first compile the Fortran file(s), 
 *  then include their object file names in the mex command.  
 *  For example, if your Fortran compiler is invoked with the
 *  'g77' command, a mex session looks like this at the command 
 *  prompt:
 *
 *  >> !g77 -c myfortranfile.f
 *  >> mex my_sfuntmpl_gate_fortran.c myfortranfile.o
 *  
 *  ---------------------------------------------------------
 *  | See matlabroot/simulink/src/sfuntmpl_doc.c for a more |
 *  | detailed description of the C-MEX template.           |
 *  ---------------------------------------------------------
 *
 * Copyright 1990-2004 The MathWorks, Inc.
 * $Revision: 1.5.4.2 $
 */


/*
 * You must specify the S_FUNCTION_NAME as the name of your S-function
 * (i.e. replace sfungate with the name of your S-function, which has
 * to match the name of the final mex file, e.g., if the S_FUNCTION_NAME
 * is my_sfuntmpl_gate_fortran, the mex filename will have to be 
 * my_sfuntmpl_gate_fortran.dll on Windows and 
 * my_sfuntmpl_gate_fortran.mexXXX on unix where XXX is the 3 letter 
 * mex extension code for your platform).
 */

#define S_FUNCTION_LEVEL 2
#define S_FUNCTION_NAME  sfuntmpl_gate_fortran

/*
 * Need to include simstruc.h for the definition of the SimStruct and
 * its associated macro definitions.
 */
#include "simstruc.h"

/* 
 * As a convenience, this template has options for both variable 
 * step and fixed step algorithm support.  If you want fixed step
 * operation, change the #define below to #undef.
 *
 * If you want to, you can delete all references to VARIABLE_STEP 
 * and set up the C-MEX as described in the "Writing S-functions" 
 * manual.
 */

#define VARIABLE_STEP

/* 
 * The interface (function prototype) for your  Fortran subroutine.  
 * Change the name to the name of the subroutine and the arguments 
 * to the actual argument list.
 *
 * Note that datatype REAL is 32 bits in Fortran and are passed
 * by reference, so the prototype arguments must be 'float *'.
 * INTEGER maps to int, so those arguments are 'int *'. Be
 * wary of IMPLICIT rules in Fortran when datatypes are not
 * explicit in your Fortran code.  To use the datatype double
 * the Fortran variables need to be declared DOUBLE PRECISION
 * either explicitly or via an IMPLICIT DOUBLE PRECISION
 * statement.
 *
 * Your Fortran compiler may decorate and/or change the 
 * capitalization of 'SUBROUTINE nameOfSub' differently 
 * than the prototype below.  Check your Fortran compiler's 
 * manual for options to learn about and possibly control 
 * external symbol decoration.  See also the text file named
 * sfuntmpl_fortran.txt in this file's directory.
 *
 * Additionally, you may want to use CFORTRAN, a tool for 
 * automating interface generation between C and Fortran.
 * Search the web for 'cfortran'.
 * 
 */

#ifdef VARIABLE_STEP

extern void nameofsub_(float *sampleArgs, 
                       float *states, 
                       int   *numstates,
                       float *sampleOutput);
#else

extern void nameofsub_(float *sampleArgs, float *sampleOutput);

#endif


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
 *         char msg[256];    {ILLEGAL: to fix use "static char msg[256];"}
 *         sprintf(msg,"Error due to %s", string);
 *         ssSetErrorStatus(S,msg);
 *         return;
 *      }
 *
 * See matlabroot/simulink/src/sfunctmpl_doc.c for further details.
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
    /* See sfuntmpl.doc for more details on the macros below */

    ssSetNumSFcnParams(S, 0);  /* Number of expected parameters */
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        /* Return if number of expected != number of actual parameters */
        return;
    }

    ssSetNumContStates(S, 1);  /* how many continuous states? */
    ssSetNumDiscStates(S, 0);

    if (!ssSetNumInputPorts(S, 1)) return;
    ssSetInputPortWidth(S, 0, 1);
    /*
     * Set direct feedthrough flag (1=yes, 0=no).
     * A port has direct feedthrough if the input is used in either
     * the mdlOutputs or mdlGetTimeOfNextVarHit functions.
     * See matlabroot/simulink/src/sfuntmpl_directfeed.txt.
     */
    ssSetInputPortDirectFeedThrough(S, 0, 1);

    if (!ssSetNumOutputPorts(S, 1)) return;
    ssSetOutputPortWidth(S, 0, 1);

    ssSetNumSampleTimes(S, 1);

    /* 
     * If your Fortran code uses REAL for the state, input, and/or output 
     * datatypes, use these DWorks as work areas to downcast continuous 
     * states from double to REAL before calling your code.  You could
     * also put the work vectors in hard-coded local (stack) variables.
     *
     * For fixed step code, keep a copy of the variables  to be output 
     * in a DWork vector so the mdlOutputs() function can provide output 
     * data when needed. You can use as many DWork vectors as you like 
     * for both input and output (or hard-code local variables).
     */
    if(!ssSetNumDWork(   S, 3)) return;

    ssSetDWorkWidth(     S, 0, ssGetOutputPortWidth(S,0));
    ssSetDWorkDataType(  S, 0, SS_SINGLE); /* use SS_DOUBLE if needed */

    ssSetDWorkWidth(     S, 1, ssGetInputPortWidth(S,0));
    ssSetDWorkDataType(  S, 1, SS_SINGLE);

    ssSetDWorkWidth(     S, 2, ssGetNumContStates(S));
    ssSetDWorkDataType(  S, 2, SS_SINGLE);

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
#ifdef VARIABLE_STEP
    
    /* 
     * For Fortran code with either no states at
     * all or with continuous states that you want
     * to support with variable time steps, use
     * a sample time like this:
     */
    ssSetSampleTime(S, 0, CONTINUOUS_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);
    
#else

    /* 
     * If the Fortran code implicitly steps time
     * at a fixed rate and you don't want to change
     * the code, you need to use a discrete (fixed
     * step) sample time, 1 second is chosen below.
     */
    ssSetSampleTime(S, 0, 0.01); /* Choose the sample time here if discrete */
    ssSetOffsetTime(S, 0, 0.0);
   
#endif
    ssSetModelReferenceSampleTimeDefaultInheritance(S);
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
      /* 
       * #undef MDL_INITIALIZE_CONDITIONS if you don't have any
       * continuous states.
       */
      real_T *x = ssGetContStates(S);

      /* set the values of the states (x) to start with */

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
    
  }
#endif /*  MDL_START */



/* Function: mdlOutputs =======================================================
 * Abstract:
 *    In this function, you compute the outputs of your S-function
 *    block.  The default datatype for signals in Simulink is double,
 *    but you can use other intrinsic C datatypes or even custom
 *    datatypes if you wish.  See Simulink document "Writing S-functions"
 *    for details on datatype topics.
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{

#ifdef VARIABLE_STEP

    /*
     *    For Variable Step Code WITH CONTINUOUS STATES
     *    ---------------------------------------------
     * For Fortran code that implements continuous states and uses
     * the mdlDerivatives interface, call your Fortran code's output
     * routines from here.  If it alters the states, you have to
     * reset the solver.  Remember, in Simulink the continuous states
     * must be of type double, so be prepared to copy them to float 
     * if your Fortran code uses REAL as the datatype for the states.
     *
     *                ... or, NO STATES
     *                -----------------
     * If your code has no states and you want it to execute in
     * a continuous model, keep the uPtrs, sampleArgs, y, and
     * sampleOutput variables and delete x, xf, and nx.  Adjust 
     * the function call accordingly.
     */ 
    InputRealPtrsType uPtrs = ssGetInputPortRealSignalPtrs(S,0);
    float  *sampleArgs   = (float *) ssGetDWork(S,1);
    double *y            = ssGetOutputPortRealSignal(S,0);
    float  *sampleOutput = (float *) ssGetDWork(S,0);
    double *x            = ssGetContStates(S);
    float  *xf           = (float *) ssGetDWork(S,2);
    int     nx           = ssGetNumContStates(S);
    int k;
    
    /* 
     * If the datatype in the Fortran code is REAL
     * then you have to downcast the I/O and states from
     * double to float as copies before sending them 
     * to your code (or change the Fortran code).
     */

    for (k=0; k < ssGetDWorkWidth(S,1); k++) {
        sampleArgs[k] = (float) (*uPtrs[k]);
    }

    /*
     * It is recommended to use a DWork vector to 
     * allocate the space for  the float copy of 
     * the states (if needed).
     */
    for (k=0; k < nx; k++) {
        xf[k] = (float) x[k];
    }
    

    /* ==== Call the Fortran routine (args are pass-by-reference) */
    
    /* nameofsub_(sampleArgs, xf, &nx, sampleOutput ); */

   
    /* 
     * If needed, convert the float outputs to the 
     * double (y) output array 
     */
    for (k=0; k < ssGetOutputPortWidth(S,0); k++) {
        y[k] = (double) sampleOutput[k];
    }

#else

    /* 
     *    For Fixed Step Code
     *    -------------------
     * If the Fortran code implements discrete states (implicitly or
     * registered with Simulink, it doesn't matter), call the code
     * from mdlUpdates() and save the output values in a DWork vector.  
     * The variable step solver may call mdlOutputs() several
     * times in between calls to mdlUpdate, and you must extract the 
     * values from the DWork vector and copy them to the block output
     * variables.
     *
     * Be sure that the ssSetDWorkDataType(S,0) declaration in 
     * mdlInitializeSizes() uses SS_DOUBLE for the datatype when 
     * this code is active.
     */
    
    double *copyOfOutputs = (double *) ssGetDWork(S, 0);
    double *y             = ssGetOutputPortRealSignal(S,0);
    int     k;
    
    for (k=0; k < ssGetOutputSignalWidth(S,0); k++ ) {
        y[k] = copyOfOutputs[k];
    }

#endif

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

#ifndef VARIABLE_STEP

    /* 
     *    For Fixed Step Code Only
     *    ------------------------
     * If your Fortran code runs at a fixed time step that advances
     * each time you call it, it is best to call it here instead of
     * in mdlOutputs().  The states in the Fortran code need not be
     * continuous if you call your code from here.
     */
    InputRealPtrsType uPtrs = ssGetInputPortRealSignalPtrs(S,0);
    float  *sampleArgs   = (float *) ssGetDWork(S,1);
    double *y            = ssGetOutputPortRealSignal(S,0);
    float  *sampleOutput = (float *) ssGetDWork(S,0);
    int k;
    
    /* 
     * If the datatype in the Fortran code is REAL
     * then you have to downcast the I/O and states from
     * double to float as copies before sending them 
     * to your code (or change the Fortran code).
     */

    for (k=0; k < ssGetDWorkWidth(S,1); k++) {
        sampleArgs[k] = (float) (*uPtrs[k]);
    }


    /* ==== Call the Fortran routine (args are pass-by-reference) */
    
    /* nameofsub_(sampleArgs, sampleOutput ); */

   
    /* 
     * If needed, convert the float outputs to the 
     * double (y) output array 
     */
    for (k=0; k < ssGetOutputPortWidth(S,0); k++) {
        y[k] = (double) sampleOutput[k];
    }

#endif

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

#ifdef VARIABLE_STEP

      /* 
       *    For Variable Step Code Only
       *    ---------------------------
       * If your Fortran code needs to support continuous states
       * with variable timestep solvers, you need to call into
       * your Fortran routine (or perhaps one that shares a 
       * common block but only calculates derivatives) here to 
       * extract/calculate state derivatives WITHOUT ADVANCING TIME.
       */

#endif

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
}


/*========================================================*
 * See sfuntmpl_doc.c for the optional S-function methods *
 *========================================================*/

/*=============================*
 * Required S-function trailer *
 *=============================*/

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif

