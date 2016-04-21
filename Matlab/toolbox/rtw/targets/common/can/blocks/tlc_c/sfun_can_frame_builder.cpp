/*
 * File: sfun_can_frame_builder.cpp
 *
 * Abstract:
 *    Description of file contents and purpose.
 *
 *
 * $Revision: 1.9.4.3 $
 * $Date: 2004/04/19 01:19:53 $
 *
 * Copyright 2001-2004 The MathWorks, Inc.
 */

#ifdef __cplusplus
extern "C" { // use the C fcn-call standard for all functions  
#endif       // defined within this scope                     

/*
 * You must specify the S_FUNCTION_NAME as the name of your S-function
 * (i.e. replace sfuntmpl_basic with the name of your S-function).
 */

#define S_FUNCTION_NAME sfun_can_frame_builder 
#define S_FUNCTION_LEVEL 2

/*
 * Need to include simstruc.h for the definition of the SimStruct and
 * its associated macro definitions.
 */
#include "simstruc.h"
#include "sfun_can_util.h"
#include "endian_test.hpp"

/*=============================
 * Externally defined functions
 *=============================*/
/*ml2rtw.c*/
extern bool WriteMatlabStructureToRTWFile(SimStruct     *S,
                const mxArray *mlStruct,
                const char    *structName,
                char          *strBuffer,
                const int     strBufferLen);

/*====================*
 * Defines
 *===================*/

#define P_INT_SCALAR(ID) ((int)mxGetScalar(ssGetSFcnParam(S,(ID)))) 
enum { E_TYPE=0, E_ID, E_ENDIAN,  P_NPARMS }; 


#define P_TYPE      P_INT_SCALAR(E_TYPE)
#define P_ID        P_INT_SCALAR(E_ID)
#define P_ENDIAN    P_INT_SCALAR(E_ENDIAN)





/*====================*
 * User - Methods
 *====================*/
static boolean_T isAcceptableDataType(SimStruct * S, DTypeId dataType,int portWidth){
    switch ( dataType ){
       case SS_UINT8:
       case SS_INT8:
          if (portWidth<=8){
             return true;
          }else{
             return false;
          }
       case SS_UINT16:
       case SS_INT16:
          if(portWidth<=4){
             return true;
          }else{
             return false;
          }
       case SS_UINT32:
       case SS_INT32:
          if(portWidth<=2){
             return true;
          }else{
             return false;
          }
       case SS_SINGLE:
          if(portWidth<=2){
             return true;
          }else{
             return false;
          }
       default:
          return false;
    }
}



static void setInputPorts(SimStruct * S){
   if (P_ID == -1){
      ssSetNumInputPorts(S,2);
      ssSetInputPortDataType(S,1,SS_UINT32);
      ssSetInputPortWidth(S,1,1);
      ssSetInputPortDirectFeedThrough(S,1,true);
   }else{
      ssSetNumInputPorts(S,1);
   }
   ssSetInputPortRequiredContiguous(S,0,true);
   ssSetInputPortDataType(S,0,DYNAMICALLY_TYPED);
   ssSetInputPortDirectFeedThrough(S,0,true);
   ssSetInputPortWidth(S,0,DYNAMICALLY_SIZED);
}

/*====================*
 * S-function methods *
 *====================*/

#define MDL_SET_DEFAULT_PORT_DATA_TYPES
    static void mdlSetDefaultPortDataTypes(SimStruct *S) {
        if ( ssGetInputPortDataType(S,0) == DYNAMICALLY_TYPED ){
			if ( isAcceptableDataType(S,SS_UINT8,ssGetInputPortWidth(S,0))){
            	ssSetInputPortDataType(  S, 0, SS_UINT8 );
			}else{
				ssSetErrorStatus(S,"Invalid input signal width, data type or input port is not connected. See mask help for valid data types.");
			}
        }

	}

#define MDL_SET_INPUT_PORT_DATA_TYPE
static void mdlSetInputPortDataType(SimStruct *S, int_T port, DTypeId dataType) {
    int portWidth;
    if ( port == 0 ) {
        portWidth = ssGetInputPortWidth(S,0);
        if( isAcceptableDataType( S, dataType,portWidth ) ) {
            /*
             * Accept proposed data type if it is an unsigned integer type
             * force all data ports to use this data type.
             */
            
            ssSetInputPortDataType(  S, 0, dataType );

        } else {
            /* Reject proposed data type */
            ssSetErrorStatus(S,"Invalid input signal width, data type or input port is not connected. See mask help for valid data types.");
            goto EXIT_POINT;
        }
    } else {
        /*
         * Should not end up here.  Simulink will only call this function
         * for existing input ports whose data types are unknown.
         */
        ssSetErrorStatus(S, "Error setting input port data type.");
        goto EXIT_POINT;
    }

EXIT_POINT:
    return;
   
}

//#define MDL_SET_INPUT_PORT_WIDTH   /* Change to #undef to remove function */
#if defined(MDL_SET_INPUT_PORT_WIDTH) && defined(MATLAB_MEX_FILE)
void mdlSetInputPortWidth (SimStruct *S, int_T port, int_T width){
}
#endif /* MDL_SET_INPUT_PORT_WIDTH */

/* Function: mdlInitializeSizes ===============================================
 * Abstract:
 *    The sizes information is used by Simulink to determine the S-function
 *    block's characteristics (number of inputs, outputs, states, etc.).
 */
static void mdlInitializeSizes(SimStruct *S)
{
        int idx;

        int_T canExDT; // Extended extended frame
        int_T canStDT; // Standard frame

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

        // Setup all the CAN datatypes
        CAN_Common_MdlInitSizes(S);
        canExDT = ssGetDataTypeId(S,SL_CAN_EXTENDED_FRAME_DTYPE_NAME );
        canStDT = ssGetDataTypeId(S,SL_CAN_STANDARD_FRAME_DTYPE_NAME );

        // One vectorized output port may contain several CAN
        // messages, one frame per signal element
        ssSetNumOutputPorts(S,1);
        ssSetOutputPortWidth(S,0,1);
        if( P_TYPE == CAN_MESSAGE_STANDARD){
                ssSetOutputPortDataType(S,0,canStDT);
        }else if ( P_TYPE == CAN_MESSAGE_EXTENDED ){
                ssSetOutputPortDataType(S,0,canExDT);
        }

        // Multiple input ports. Each input port represents
        // a CAN data frame. These will be vectorized
        // uint8 inputs. The width corressponds to the
        // number of data bytes in the frame
        setInputPorts(S);

        ssSetNumContStates(S, 0);
        ssSetNumDiscStates(S, 0);


        ssSetNumSampleTimes(S, 1);
        ssSetNumRWork(S, 0);
        ssSetNumIWork(S, 0);
        ssSetNumPWork(S, 0);
        ssSetNumModes(S, 0);
        ssSetNumNonsampledZCs(S, 0);
         
        /* currently accelerator mode does not provide the endian
         * and word size settings required - this should change in the future */
        //ssSetOptions(S, SS_OPTION_USE_TLC_WITH_ACCELERATOR);
}



/* Function: mdlInitializeSampleTimes =========================================
 * Abstract:
 *    This function is used to specify the sample time(s) for your
 *    S-function. You must register the same number of sample times as
 *    specified in ssSetNumSampleTimes.
 */
static void mdlInitializeSampleTimes(SimStruct *S)
{
        ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
        ssSetOffsetTime(S, 0, 0.0);

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



/* Function: mdlOutputs =======================================================
 * Abstract:
 *    In this function, you compute the outputs of your S-function
 *    block. Generally outputs are placed in the output vector, ssGetY(S).
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
   CAN_FRAME * frame;
   const void * uFrame = ssGetInputPortSignal(S,0);
   int length,idx,signals,portWidth,dataTypeSize,offset ;
   InputInt32PtrsType uID;
   DTypeId dataType = ssGetInputPortDataType(S,0);
   length = ssGetDataTypeSize(S,dataType) * ssGetInputPortWidth(S,0);



   frame = (CAN_FRAME *) ssGetOutputPortSignal(S,0);
   frame->LENGTH = length;
   memset(frame->DATA,0,8);

   if (P_ID == -1 ){
      uID = (InputInt32PtrsType) ssGetInputPortSignalPtrs(S,1);
      frame->ID = *uID[0];
   }else{
      frame->ID = P_ID;
   }

   if (P_ENDIAN == CPU_ENDIAN){
      /* Target is same endianess as source */
      memcpy(frame->DATA,uFrame,length);
   }else{
      /* Target is alternate endianess as source.
       * Reverse the bytes in each signal but 
       * preserve the ordering of the signals. */
      dataTypeSize = ssGetDataTypeSize(S,ssGetInputPortDataType(S,0));
      portWidth = ssGetInputPortWidth(S,0);
      for (signals = 0 ; signals < portWidth ; signals++){
         offset = signals * dataTypeSize;
         for ( idx=0;idx < dataTypeSize;idx++ ){
            ((uint8_T *)(frame->DATA))[offset+idx]=(( uint8_T *)uFrame)[offset+dataTypeSize-idx-1];
         }
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


#define MDL_RTW  /* Change to #undef to remove function */
#if defined(MDL_RTW) && (defined(MATLAB_MEX_FILE) || defined(NRT))
static void mdlRTW(SimStruct *S){
   int_T type     = P_TYPE;
   int_T id       = P_ID;
   DTypeId  dataType = ssGetInputPortDataType(S,0);
   int_T length   =ssGetDataTypeSize(S,dataType) * ssGetInputPortWidth(S,0); 
   int32_T       endian     = P_ENDIAN;

   /* -- Write Invariant Parameter Settings -- */
   ssWriteRTWParamSettings(S,4,
         SSWRITE_VALUE_DTYPE_NUM, "TYPE",
         &type,
         DTINFO(SS_UINT32,0),

         SSWRITE_VALUE_DTYPE_NUM, "ID",
         &id,
         DTINFO(SS_UINT32,0),

         SSWRITE_VALUE_DTYPE_NUM, "LENGTH",
         &length,
         DTINFO(SS_UINT16,0),

         SSWRITE_VALUE_DTYPE_NUM, "Endian",
         &endian,
         DTINFO(SS_UINT32,0)
      );

   /* -- Write Invariant Signal Settings -- */
   if ( !mxIsFinite( ssGetSampleTime( S, 0 ) ) ) {
      CAN_FRAME * frame = (CAN_FRAME *) ssGetOutputPortSignal(S,0);
      CAN_write_rtw_frame(S,frame);
   }

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

#ifdef __cplusplus
} // end of extern "C" scope
#endif
