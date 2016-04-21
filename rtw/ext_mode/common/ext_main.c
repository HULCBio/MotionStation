/*
 * Copyright 1994-2004 The MathWorks, Inc.
 *
 * File: ext_main.c     $Revision: 1.1.6.4 $
 *
 * Abstract:
 * MEX glue for the mechanism to communicate with an externally running, RTW-
 * generated program.  Mechanisms are provided to:
 *  
 *  o download block parameters to the external program
 *  o upload data from the external program to Simulink
 *  o control the target program
 */

#include "extsim.h"  /* ext_mode data struct */
 
/*
 * Debugging print statement.
 */
#define EXT_MAIN_DEBUG (0)
#if EXT_MAIN_DEBUG
#define PRINTD(args) mexPrintf args
#else
#define PRINTD(args) /* do nothing */      
#endif


/* Function: ExtCommMain =======================================================
 * Abstract:
 *    Main entry point for external communications processing.
 */
PRIVATE void ExtCommMain(
    int             nlhs, 
    mxArray         *plhs[], 
    int             nrhs, 
    const   mxArray *prhs[])
{
    ExternalSim  *ES;
    
    /*
     * Simulink directly passes a pointer to the ExternalSim data structure
     * in the plhs array.
     */
    if (nlhs == -1) {
        ES = (ExternalSim *)plhs[0];
        if (((int *)ES)[0] != EXTSIM_VERSION) {
            esSetError(ES,
                "\nThe version of the 'ExternalSim' structure passed by "
                "Simulink and the version of the structure used by ext_main.c "
                "are not consistent.  The mex file is either out of date or "
                "built with structure alignment not equal to 8.  Ensure that "
                "the external mode mex file was built using the include file: "
                "<matlabroot>/rtw/ext_mode/extsim.h\n.");
            goto EXIT_POINT;
        }

        /*
         * Provide Simulink with a direct pointer to this function so that
         * subsequent calls can be made more efficiently.  Do not set this
         * if your version of ext_comm is not "exception free" as described
         * in the documentation for Simulink S-functions.
         * See <matlabroot>/simulink/src/sfuntmpl_doc.c.
         */
        esSetMexFuncGateWayFcn(ES,ExtCommMain);
    } else {
	mexPrintf("This external mex file is used by Simulink in external "
		  "mode\nfor communicating with Real-Time Workshop targets "
		  "using interprocess communications.\n");
        goto EXIT_POINT;
    }

    
    /*
     * Dispatch the packet to appropriate routine in ext_comm.c.
     */
    switch(esGetAction(ES)) {

    case EXT_CONNECT:
        /* Connect to target. */
        ExtConnect(ES, nrhs, prhs);
        if (esGetVerbosity(ES)) mexPrintf("action: EXT_CONNECT\n");
        break;

    case EXT_DISCONNECT_REQUEST:
        /* Request to terminate communication has been made - notify target. */
        if (esGetVerbosity(ES)) mexPrintf("action: EXT_DISCONNECT_REQUEST\n");
        ExtDisconnectRequest(ES, nrhs, prhs);
        break;

    case EXT_DISCONNECT_REQUEST_NO_FINAL_UPLOAD:
        /* Request to terminate communication has been made - notify target. */
        if (esGetVerbosity(ES)) {
            mexPrintf("action: EXT_DISCONNECT_REQUEST_NO_FINAL_UPLOAD\n");
        }
        ExtDisconnectRequestNoFinalUpload(ES, nrhs, prhs);
        break;

    case EXT_DISCONNECT_CONFIRMED:
        /* Terminate communication with target. */
        if (esGetVerbosity(ES)) mexPrintf("action: EXT_DISCONNECT_CONFIRMED\n");
        ExtDisconnectConfirmed(ES, nrhs, prhs);
        break;

    case EXT_SETPARAM: 
        /* Download parameters to be set on target. */
        if (esGetVerbosity(ES)) mexPrintf("action: EXT_SETPARAM\n");
        ExtSendGenericPkt(ES, nrhs, prhs);
        break;

    case EXT_GETPARAMS:
        /* Upload interfaceable variables from target. */
        if (esGetVerbosity(ES)) mexPrintf("action: EXT_GETPARAMS\n");
        ExtGetParams(ES, nrhs, prhs);
        break;

    case EXT_SELECT_SIGNALS: 
        /* Select signals for data uploading. */
        if (esGetVerbosity(ES)) mexPrintf("action: EXT_SELECT_SIGNALS\n");
        ExtSendGenericPkt(ES, nrhs, prhs);
        break;

    case EXT_SELECT_TRIGGER: 
        /* Select signals for data uploading. */
        if (esGetVerbosity(ES)) mexPrintf("action: EXT_SELECT_TRIGGER\n");
        ExtSendGenericPkt(ES, nrhs, prhs);
        break;

    case EXT_ARM_TRIGGER: 
        /* Select signals for data uploading. */
        if (esGetVerbosity(ES)) mexPrintf("action: EXT_ARM_TRIGGER\n");
        ExtSendGenericPkt(ES, nrhs, prhs);
        break;

    case EXT_CANCEL_LOGGING:
        /* Send packet to target to cancel the current data loggin session. */
        if (esGetVerbosity(ES)) mexPrintf("action: EXT_CANCEL_LOGGING\n");
        ExtSendGenericPkt(ES, nrhs, prhs);
        break;

    case EXT_MODEL_START:
        /* Start the external simulation. */
        if (esGetVerbosity(ES)) mexPrintf("action: EXT_MODEL_START\n");
        ExtSendGenericPkt(ES, nrhs, prhs);
        break;

    case EXT_MODEL_STOP:
        /* Stop the external simulation and kill target program. */
        if (esGetVerbosity(ES)) mexPrintf("action: EXT_MODEL_STOP\n");
        ExtSendGenericPkt(ES, nrhs, prhs);
        break;

    case EXT_MODEL_PAUSE:
        /* Pause the target (The MathWorks internal testing only). */
        if (esGetVerbosity(ES)) mexPrintf("action: EXT_MODEL_PAUSE\n");
        ExtSendGenericPkt(ES, nrhs, prhs);
        break;
    
    case EXT_MODEL_STEP:
        /* Run the model for 1 step - if paused (The MathWorks internal
           testing only). */
        if (esGetVerbosity(ES)) mexPrintf("action: EXT_MODEL_STEP\n");
        ExtSendGenericPkt(ES, nrhs, prhs);
        break;

    case EXT_MODEL_CONTINUE:
        /* Run the model for 1 step - if paused (The MathWorks internal
           testing only). */
        if (esGetVerbosity(ES)) mexPrintf("action: EXT_MODEL_CONTINUE\n");
        ExtSendGenericPkt(ES, nrhs, prhs);
        break;

    case EXT_GET_TIME:
        /*
         * Request the sim time from the target.
         *
         * NOTE:
         *  Skip verbosity.  There are too many of these packets when
         *  autoupdating Simulink's status bar clock.
         */
        /*if (esGetVerbosity(ES)) mexPrintf("action: EXT_GET_TIME\n");*/
        ExtSendGenericPkt(ES, nrhs, prhs);
        break;

    default:
        esSetError(ES,"\nUnrecognized external communication action.");
        goto EXIT_POINT;
    } /* end switch */

EXIT_POINT:
    return;
} /* end ExtCommMain */


/* Function: mexFunction =======================================================
 * Abstract:
 *    Gateway from Matlab.
 */
void mexFunction(
    int           nlhs, 
    mxArray       *plhs[], 
    int           nrhs, 
    const mxArray *prhs[])
{
    ExtCommMain(nlhs,plhs,nrhs,prhs);
} /* end mexFunction */


/* [EOF] ext_main.c */
