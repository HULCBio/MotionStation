/* SCOMPROPATTRIB Communications Toolbox S-Function, used to 
*  propogate signal dimensions, sample time and complexity from
*  port 1(reference) to port 2.
*   
*   Copyright 1996-2004 The MathWorks, Inc.
*   $Revision: 1.3.4.3 $  $Date: 2004/04/12 23:03:35 $
*/


#define S_FUNCTION_NAME scompropattrib
#define S_FUNCTION_LEVEL 2

#include "comm_defs.h"

enum {NUM_ARGS};
enum {NUM_INPORTS=2};
enum {NUM_OUTPORTS};
enum {INPUT_1, INPUT_2};

/* Function: mdlInitializeSizes ===============================================*/
static void mdlInitializeSizes(SimStruct *S)
{
    
    ssSetNumSFcnParams(S,NUM_ARGS);

    #if defined(MATLAB_MEX_FILE)
        if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) return;
        if (ssGetErrorStatus(S) != NULL) return;
    #endif

    if (!ssSetNumInputPorts(S, NUM_INPORTS)) return;

     /*Dynamically size inport 1, inherit frame data, sample time, complexity*/
     if(!ssSetInputPortDimensionInfo(S, INPUT_1, DYNAMIC_DIMENSION)) return;
     ssSetInputPortFrameData(S,INPUT_1,FRAME_INHERITED);
     ssSetInputPortComplexSignal(S,INPUT_1,COMPLEX_INHERITED);   
   
     /*Set inport 2 */
    if(!ssSetInputPortDimensionInfo(S, INPUT_2, DYNAMIC_DIMENSION)) return;
    ssSetInputPortFrameData(S,INPUT_2,FRAME_INHERITED);
    ssSetInputPortComplexSignal(S,INPUT_2, COMPLEX_INHERITED);

    /* One Sample time for this block*/
    ssSetNumSampleTimes(S, PORT_BASED_SAMPLE_TIMES);

    ssSetInputPortSampleTime(S, INPUT_1, INHERITED_SAMPLE_TIME);
    ssSetInputPortSampleTime(S, INPUT_2, INHERITED_SAMPLE_TIME);
    
    ssSetOptions( S, SS_OPTION_CAN_BE_CALLED_CONDITIONALLY );
}

/* End of mdlInitializeSizes(SimStruct *S) */

#if defined(MATLAB_MEX_FILE)
#define MDL_SET_INPUT_PORT_DIMENSION_INFO
/*Function: mdlSetInputPortDimensionInfo========================================*/
static void mdlSetInputPortDimensionInfo(SimStruct *S,int_T port, const DimsInfo_T *dimsInfo)
{

     if(port==INPUT_1)
     {           
         /* Set input 1 up*/
         if(!ssSetInputPortDimensionInfo(S, port, dimsInfo)) return;        
         /* Set input 2 to match input 1*/
         if(!ssSetInputPortDimensionInfo(S, INPUT_2, dimsInfo)) return;        
     }

    /* Check here for port 1== SampleBased && port 2== FrameBased */
     if( (ssGetInputPortFrameData(S, INPUT_1)==FRAME_NO) && (ssGetInputPortFrameData(S, INPUT_2) == FRAME_YES))
     {
         THROW_ERROR(S,"If port 1 is sample based, port 2 must also be sample based.");
     }

}
#endif

#if defined(MATLAB_MEX_FILE)
#define MDL_SET_INPUT_PORT_SAMPLE_TIME
/*Function: mdlSetInputPortSampleTime ===========================================*/
static void mdlSetInputPortSampleTime(SimStruct *S, int_T port, real_T sampleTime, real_T offset_Time)
{

     /*Set both sample times and offsets to match port 1*/
    if(port==INPUT_1)
    {
        ssSetInputPortSampleTime(S, INPUT_1, sampleTime);
        ssSetInputPortOffsetTime(S, INPUT_1, offset_Time);
    }
    else /*Input 2*/
    {
        /* Check to see if input 1 have matching sample times*/
        if(ssGetInputPortSampleTime(S,INPUT_1) != sampleTime) {
            THROW_ERROR(S, "Input 2 should inherit its sample time, or its sample time should match input 1.");
        }
        else
        {
            ssSetInputPortSampleTime(S, INPUT_2, sampleTime);
            ssSetInputPortOffsetTime(S, INPUT_2, offset_Time);
        }
    }
          
}
#endif
/*End of mdlSetInputPortSampleTime*/

#if defined(MATLAB_MEX_FILE)
#define MDL_SET_OUTPUT_PORT_SAMPLE_TIME
/*Function: mdlSetOutputPortSampleTime==========================================*/
static void mdlSetOutputPortSampleTime(SimStruct *S, int_T port, real_T sampleTime, real_T offset_Tims)
{
    /* Do nothing*/
}
#endif
/*End of mdlSetOutputPortSampleTime*/

/* Function: mdlInitializeSampleTimes =========================================*/
static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetModelReferenceSampleTimeInheritanceRule(S, USE_DEFAULT_FOR_DISCRETE_INHERITANCE);
}

#if defined (MATLAB_MEX_FILE)
#define MDL_SET_INPUT_PORT_COMPLEX_SIGNAL
/* Fuunction: mdlSetInputPortComlpexSignal =====================================*/
static void mdlSetInputPortComplexSignal(SimStruct *S, int_T port, CSignal_T csig)
{
    int       otherPort;
    CSignal_T csigOther;

    /* Set the port prop */
    ssSetInputPortComplexSignal(S, port, csig);

    /* Check that ports have same info */
    if (port==INPUT_1) {
        otherPort = INPUT_2;
    } else {
        otherPort = INPUT_1;
    }
    
    csigOther = ssGetInputPortComplexSignal(S, otherPort);
    
    if (csigOther != DYNAMICALLY_TYPED && csig != csigOther) {
        THROW_ERROR(S, "Input 2 should inherit complexity, or its complexity should match input 1"); 
    }
}
#endif
/*End of mdlSetInputPortComplexSignal*/

/* Function: mdlOutputs =======================================================*/
static void mdlOutputs(SimStruct *S, int_T tid)
{
    /*No outputs*/
}

/* Function: mdlTerminate ===============================================*/
static void mdlTerminate(SimStruct *S)
{
}

#ifdef  MATLAB_MEX_FILE
#include "simulink.c"
#else
#include "cg_sfun.h"
#endif