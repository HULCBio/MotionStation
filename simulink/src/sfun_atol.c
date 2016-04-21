/* $Revision: 1.3.4.2 $ */
/* File     : sfun_atol.c
 * Abstract :
 *
 *     Example of an S-function with sets different absolute tolerances 
 *     for each continuous state.  The system modeled is this 2-D ODE,
 *               x1' = x2 
 *               x2' = Mu[(1-x1^2)x2] - x1
 *     which is the van der Pol equation.  The constant Mu is set through
 *     an inport and the absolute tolerance for each state is set by parameters
 *     to the S-function.
 * 
 */


#define S_FUNCTION_NAME sfun_atol
#define S_FUNCTION_LEVEL 2

/*
 * Need to include simstruc.h for the definition of the SimStruct and
 * its associated macro definitions.
 */
#include "simstruc.h"

#define IS_PARAM_DOUBLE(pVal) (mxIsNumeric(pVal) && !mxIsLogical(pVal) &&\
!mxIsEmpty(pVal) && !mxIsSparse(pVal) && !mxIsComplex(pVal) && mxIsDouble(pVal))


/*====================*
 * S-function methods *
 *====================*/

#define MDL_CHECK_PARAMETERS
#if defined(MDL_CHECK_PARAMETERS)  && defined(MATLAB_MEX_FILE)
/*
 * Check to make sure that each parameter is 1-d and positive
 */
static void mdlCheckParameters(SimStruct *S)
{

    const mxArray *pVal0 = ssGetSFcnParam(S,0);
    const mxArray *pVal1 = ssGetSFcnParam(S,1);

    if ( mxGetNumberOfElements(ssGetSFcnParam(S,0)) != 1 || !IS_PARAM_DOUBLE(pVal0)) {
        ssSetErrorStatus(S, "Parameter to S-function must be a scalar");
        return;
    } 
    else if (mxGetPr(ssGetSFcnParam(S,0))[0] < 0) {
        ssSetErrorStatus(S, "Parameter to S-function must be non-negative");
        return;
    }

    if (mxGetNumberOfElements(ssGetSFcnParam(S,1)) != 1 || !IS_PARAM_DOUBLE(pVal1)) {
        ssSetErrorStatus(S, "Parameter to S-function must be a scalar");
        return;
    } 
    else if (mxGetPr(ssGetSFcnParam(S,1))[0] < 0) {
        ssSetErrorStatus(S, "Parameter to S-function must be non-negative");
        return;
    } 
}
#endif

static void mdlInitializeSizes(SimStruct *S)
{

    ssSetNumSFcnParams(S, 2);  /* Number of expected parameters */
#if defined(MATLAB_MEX_FILE)
    /*
     * Check the initial settings of the parameters
     */
    if (ssGetNumSFcnParams(S) == ssGetSFcnParamsCount(S)) {
        mdlCheckParameters(S);
        if (ssGetErrorStatus(S) != NULL) return;
    } else {
        return;
    }
#endif

    {
        int iParam = 0;
        int nParam = ssGetNumSFcnParams(S);

        for ( iParam = 0; iParam < nParam; iParam++ )
        {
            ssSetSFcnParamTunable( S, iParam, SS_PRM_SIM_ONLY_TUNABLE );
        }
    }

    ssSetNumContStates(S, 2);
    ssSetNumDiscStates(S, 0);

    if (!ssSetNumInputPorts(S, 1)) return;
    ssSetInputPortWidth(S, 0, 1);

    if (!ssSetNumOutputPorts(S, 2)) return;
    ssSetOutputPortWidth(S, 0, 1);
    ssSetOutputPortWidth(S, 1, 1);

    ssSetNumSampleTimes(S, 1);

    ssSetOptions(S, 0);
}


static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, CONTINUOUS_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);
    ssSetModelReferenceSampleTimeDefaultInheritance(S);
}


#define MDL_INITIALIZE_CONDITIONS
#if defined(MDL_INITIALIZE_CONDITIONS)
/*
 * Set the initial conditions to [0 2]
 */
static void mdlInitializeConditions(SimStruct *S)
{
    real_T *x0 = ssGetContStates(S);

    /* Initialize to the inputs */
    x0[0] = 2.0;
    x0[1] = 0.0;
    
}
#endif /* MDL_INITIALIZE_CONDITIONS */


#define MDL_START 
#if defined(MDL_START) 
/*
 * Set the absolute tolerances based on the parameters
 */
static void mdlStart(SimStruct *S)
{
    const real_T *abstol1 = mxGetPr(ssGetSFcnParam(S,0));
    const real_T *abstol2 = mxGetPr(ssGetSFcnParam(S,1));
    int_T  varSolver;
    
    varSolver = ssIsVariableStepSolver(S);
    if (varSolver) {
        real_T *absTol  = ssGetAbsTol(S);

        absTol[0] = *abstol1;
        absTol[1] = *abstol2;
    }
}
#endif /*  MDL_START */


#define MDL_PROCESS_PARAMETERS
#if defined(MDL_PROCESS_PARAMETERS)  && defined(MATLAB_MEX_FILE)
/*
 * Process any changes to parameters
 */
static void mdlProcessParameters(SimStruct *S)
{
    const real_T *abstol1 = mxGetPr(ssGetSFcnParam(S,0));
    const real_T *abstol2 = mxGetPr(ssGetSFcnParam(S,1));
    int_T        varSolver; 
    
    /*
     * Only update the abstol if a
     * variable step solver is being used.
     */
    varSolver = ssIsVariableStepSolver(S);
    if (varSolver) {
        real_T       *absTol  = ssGetAbsTol(S);    

        absTol[0] = *abstol1;
        absTol[1] = *abstol2;
    }
}
#endif


static void mdlOutputs(SimStruct *S, int_T tid)
{
    real_T   *y1    = ssGetOutputPortRealSignal(S,0);
    real_T   *y2    = ssGetOutputPortRealSignal(S,1);
    real_T   *x     = ssGetContStates(S);

    
    /* Set the outputs to the continuous states */
    *y1 = x[0];
    *y2 = x[1];

#ifdef PRINT_ABS_TOL
    if (ssIsMajorTimeStep(S)) {        
        ssPrintf("Abs tol %.16g %.16g \n", ssGetStateAbsTol(S,0), 
                 ssGetStateAbsTol(S,1));
    }
#endif
}


#define MDL_DERIVATIVES
#if defined(MDL_DERIVATIVES)
static void mdlDerivatives(SimStruct *S)
{
    real_T            *dx = ssGetdX(S);
    real_T            *x  = ssGetContStates(S);
    InputRealPtrsType u0  = ssGetInputPortRealSignalPtrs(S,0);
    real_T            Mu  = *u0[0];

    dx[0] = x[1];
    dx[1] = Mu*((1.0 - x[0]*x[0])*x[1]) - x[0];
}
#endif /* MDL_DERIVATIVES */


static void mdlTerminate(SimStruct *S)
{
}


/*=============================*
 * Required S-function trailer *
 *=============================*/

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
