/*
 * File: sfun_can_frame_inspector.cpp
 *
 * Abstract:
 *    Description of file contents and purpose.
 *
 *
 * $Revision: 1.8.4.3 $
 * $Date: 2004/04/19 01:19:59 $
 *
 * Copyright 2001-2004 The MathWorks, Inc.
 */

  /*
    * You must specify the S_FUNCTION_NAME as the name of your S-function
    * (i.e. replace sfuntmpl_basic with the name of your S-function).
    */
#define S_FUNCTION_NAME sfun_can_frame_inspector
#define S_FUNCTION_LEVEL 2

// must include this outside of the C linkage
#include "sfun_can_frame_functions.hpp"
#include "serial_packing.hpp"

/* C++ templated function to scale real32 and real64 types.
 *
 * All calculations are performed in the template type T, which
 * will be the type of the output signal.
 */
template <class T>
static T outputScaleReal(SimStruct *S,
                         int idx,
                         CANDB_BIT_PATTERN_DTYPE scaledValue) {
   debugPrintf("Real unscaling calculation\n");

   /* get offset and factor */
   T offset = (T) signalProp(S,idx,"offset");
   T factor = (T) signalProp(S,idx,"factor");

   int can_data_type = (int) signalProp(S,idx,"dataType");
  
   /* map scaledValue back to a real taking care of sign */
   T scaledValueReal;   
   if (can_data_type == UNSIGNED) {
      /* CANDB_BIT_PATTERN_DTYPE is unsigned,
       * so we just cast to real */
      scaledValueReal = (T) scaledValue;
   }
   else {
      /* must cast to intermediate signed type
       * before we cast to real or we will end
       * up with a +ve real! */
      int32_T temp = (int32_T) scaledValue;
      scaledValueReal = (T) temp;
   }

   debugPrintf("ScaledValue = %f, Offset = %f, Factor = %f\n", scaledValueReal, offset, factor);
   
  /* perform the unscaling calculation - 
   * assume that overflow will not occur */
   T output = (scaledValueReal * factor) + offset;

   debugPrintf("Output = %f\n", output);

   return output;
}

/* C++ templated function to unscale all integer types.
 *
 * All calculations are performed in the template type T, which
 * will be the type of the "working datatype", which may be wider
 * than the type of the signal.
 *
 * We use the pre-calculated constant term in the scaling calculation.
 *
 */
template <class T> 
static T workingDTypeScale(SimStruct *S, 
                           int idx, 
                           CANDB_BIT_PATTERN_DTYPE scaledValue) {
   debugPrintf("Integer scaling calculation\n");

   /* get factor */
   T factor = (T) signalProp(S,idx,"factor");

   /* get the user data object so that we can set constantTerm appropriately */
   UserData * userData = (UserData * )  (ssGetUserData(S));
   
   /* get the constantTerm from the userdata */
   T constantTerm = userData->constantTerm[idx];
 
   /* NOTE: scaledValue does not need to be sign extended, since it
    * is already in the largest integer type, 32 bits.
    * In real time, we may need to sign extend to a wider type */

   /* NOTE: Justification for cast of scaledValue to type T (>= word size / max sv size) 
    *
    * T output = x * (T) factor, where T is big enough to handle any x * factor (earlier check)
    * 
    * Consider T unsigned, factor is unsigned -> x must also be unsigned.
    *
    * Consider T signed, factor is signed & x cannot be a large unsigned value since
    * the result always fits in output -> safe to cast to signed.
    *
    * constantTerm is already type T, so apply type T to scaledValue to make
    * sure multiplication occurs in type T
    *
    */ 
   T output = ( ((T) scaledValue) + constantTerm) * factor;

   return output; 
}

/* C++ templated function to handle the narrowing of the working datatype
 * to the integer output signal types
 *
 * This function calls the workingDTypeScale function to perform the scaling in 
 * the working datatype, and then narrows down to the output type.
 */
template <class T>
static T outputScale(SimStruct * S, 
                     int idx, 
                     CANDB_BIT_PATTERN_DTYPE scaledValue, 
                     DTypeId workingDType) {
   T output;
   switch (workingDType) {
      case SS_BOOLEAN: {
         boolean_T wideOutput = workingDTypeScale <boolean_T> (S, idx, scaledValue);
         output = (T) wideOutput;
         break;
      }
      case SS_UINT8: {
         uint8_T wideOutput = workingDTypeScale <uint8_T> (S, idx, scaledValue);
         output = (T) wideOutput;
         break;
      }
      case SS_UINT16: {
         uint16_T wideOutput = workingDTypeScale <uint16_T> (S, idx, scaledValue);
         output = (T) wideOutput;
         break;
      }
      case SS_UINT32: { 
         uint32_T wideOutput = workingDTypeScale <uint32_T> (S, idx, scaledValue);
         output = (T) wideOutput;
         break;
      }
      case SS_INT8: {
         int8_T wideOutput = workingDTypeScale <int8_T> (S, idx, scaledValue);
         output = (T) wideOutput;
         break;
      }
      case SS_INT16: {
         int16_T wideOutput = workingDTypeScale <int16_T> (S, idx, scaledValue);
         output = (T) wideOutput;
         break;
      }
      case SS_INT32: {
         int32_T wideOutput = workingDTypeScale <int32_T> (S, idx, scaledValue);
         output = (T) wideOutput;
         break;
      }
      default: {
         ssSetErrorStatus(S, "Unknown datatype!");   
         break;
      }
   }
   return output;
}


#ifdef __cplusplus
extern "C" { // use the C fcn-call standard for all functions  
#endif       // defined within this scope                     

 
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
#define FIELD
#define P_MESSAGE(prop)  mxGetField(ssGetSFcnParam(S,E_MESSAGE),0,(prop))
#define P_SIGNALS        P_MESSAGE("signals")
#define P_SIGNAL      mxGetField(P_SIGNALS,0,"signal") 
#define N_SIGNALS        ((mxIsEmpty(P_SIGNALS)==1) ? 0 : ((mxGetDimensions(P_SIGNAL))[1]))

#define SAFE_GET_SCALAR(array) ( array != NULL ? mxGetScalar(array) : \
      ( ssSetErrorStatus(S,"null pointer to mxGetScalar"), 0 ) )

#define _SCLR_MESS_PROP(prop)    ( (int) SAFE_GET_SCALAR((P_MESSAGE(prop))))
#define P_LENGTH           _SCLR_MESS_PROP("length")

   /*====================*
    * User - Methods
    *====================*/
   static boolean_T isAcceptableDataType(SimStruct *, DTypeId);

   static CANDB_BIT_PATTERN_DTYPE getUnprocessedSignalValue(SimStruct * S, int idx, uint32_T * data);
   
   void setCANdbOutputSignal(SimStruct* S, int idx, uint32_T * data);
   
   static bool portDataTypeRangeError(SimStruct * S, int port, DTypeId dataType);

   
   static boolean_T isAcceptableDataType(SimStruct * S, DTypeId dataType) {
        int_T     canExDT      = ssGetDataTypeId(S,SL_CAN_EXTENDED_FRAME_DTYPE_NAME );
        int_T     canStDT      = ssGetDataTypeId(S,SL_CAN_STANDARD_FRAME_DTYPE_NAME );
        boolean_T isAcceptable = (dataType == canExDT || dataType == canStDT );
        return isAcceptable;
    }
   
/*====================*
 * S-function methods *
 *====================*/

#define MDL_SET_INPUT_PORT_DATA_TYPE
static void mdlSetInputPortDataType(SimStruct *S, int_T port, DTypeId dataType) {
   /* dynamic typing for message input port */
   if (port == 0) {
      if (isAcceptableDataType(S, dataType)) {
         /*
          * Accept proposed data type if it is std / xtd message type
          */
         ssSetInputPortDataType(S, 0, dataType);
      } 
      else {
         /* Reject proposed data type */
         ssSetErrorStatus(S,"Invalid input signal data type.");
         return;
      }
   } 
   else {
      /*
       * Should not end up here.  Simulink will only call this function
       * for existing input ports whose data types are unknown.
       */
      ssSetErrorStatus(S, "Error setting input port data type.");
      return;
   }
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
   // loop counter
   int idx;

   UserData * userData = new UserData(N_SIGNALS); // UserData

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
   // Extended frame
   int_T canExDT = ssGetDataTypeId(S,SL_CAN_EXTENDED_FRAME_DTYPE_NAME );
   // Standard frame
   int_T canStDT = ssGetDataTypeId(S,SL_CAN_STANDARD_FRAME_DTYPE_NAME );

   // Setup input port
   ssSetNumInputPorts(S,1);
   ssSetInputPortWidth(S,0,1);
   ssSetInputPortDirectFeedThrough(S,0,true);
   ssSetInputPortDataType(S,0,DYNAMICALLY_TYPED);

   // Work out the number of output ports
   ssSetNumOutputPorts(S,N_SIGNALS);

   // rogue value for mode signal
   userData->mode_signal = -1;
   
   for (idx = 0; idx< N_SIGNALS; idx ++){
      ssSetOutputPortWidth(S,idx,1);
      ssSetOutputPortDataType(S, idx, DYNAMICALLY_TYPED);
      real_T factor_real = signalProp(S,idx,"factor");
      real_T offset_real = signalProp(S,idx,"offset");
      if (factor_real == 0) {
         static char err_msg[200];
         char name[SIGMAXLEN] = "\0";
         signalName(S, idx, name, SIGMAXLEN-1);
         sprintf(err_msg,
               "Signal %s: The factor_real must be non-zero. ",
               name);
         /* reject proposed data type */
         ssSetErrorStatus(S,err_msg);
         return;
      }
      // Search to find if there is a MODE signal in the 
      // signal set and save the id of that signal and
      // the blocks user data.
      if (signalProp(S,idx,"signalType")==MODE){
         userData->mode_signal=idx;
         if ((factor_real!=1) && (offset_real!=0)) {
            ssSetErrorStatus(S,"Mode signal must have factor_real=1 and offset_real=0.");
         }
      }

      /* No support for Float & Double types yet */
      int can_data_type = (int) signalProp(S,idx,"dataType");
      switch (can_data_type) {
         case FLOAT:
            ssSetErrorStatus(S, "CANdb: IEEE Float datatype not yet supported.");
            break;
         case DOUBLE:
            ssSetErrorStatus(S, "CANdb: IEEE Double datatype not yet supported.");
            break;
      }
   }

   if ( ssGetUserData(S)!=NULL ){
      ssSetErrorStatus(S,"UserData was not null.");
      return;
   }
   ssSetUserData(S,userData);

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
	int idx;

	CAN_FRAME * frame = ((CAN_FRAME *) (ssGetInputPortSignalPtrs(S,0)[0]));

	/* copy the data to the frame */
	uint32_T data[2] = {0, 0};
	memcpy(data,&(frame->DATA),P_LENGTH);
   
	// First must retrieve the mode signal if it exists before
	// any of the other signals
	UserData * userData = (UserData * )  (ssGetUserData(S));
	if(userData==NULL){
   	ssSetErrorStatus(S,"UserData was null when trying to access it");
   	return;
	}

	if ( userData->mode_signal != -1 ){

		/* get Mode signal value
         modeSig can be used unscaled as we have the restriction
         that factor_real == 1 and offset_real == 0 
         We must sign extend though.
      */
      CANDB_BIT_PATTERN_DTYPE modeSig = getUnprocessedSignalValue(S, userData->mode_signal, data);
      /* Sign extend signed signals */
      int data_type = (int) signalProp(S,userData->mode_signal,"dataType");
      switch(data_type) {
         case SIGNED:
            {
               int bit_len   = (int) signalProp(S,userData->mode_signal,"length"); 
               modeSig = signedIntExtend(modeSig, bit_len);
               debugPrintf("Unpacking: Mode signal signed value after sign extending %d\n",modeSig);
               break;
            }
      }
      
      for(idx = 0 ; idx < N_SIGNALS; idx ++ ){
         int signal_type = (int) signalProp(S,idx,"signalType");
         int mode_value = (int) signalProp(S,idx,"modeValue");
         switch (signal_type) {
            case MODE:
            case STANDARD:
              /* always unpack */
              setCANdbOutputSignal(S, idx, data);
              break;
            case MODE_DEPENDANT:
               switch (data_type) {
                  case SIGNED:
                     if (mode_value == (int32_T) modeSig) {
                        setCANdbOutputSignal(S, idx, data);      
                     }
                     break;
                  case UNSIGNED:
                     if (mode_value == modeSig) {
                        setCANdbOutputSignal(S, idx, data);
                     }
                     break;
                }
                break;
         }
      }
   }else{
      // There is no mode signal so we can quickly
      // retrieve all the signals
      for(idx = 0 ; idx < N_SIGNALS; idx ++ ){
         setCANdbOutputSignal(S, idx, data);
      }
   }
}

void setCANdbOutputSignal(SimStruct* S, int idx, uint32_T * data) {
   // read the output type correctly according to it's type
   int dtype = ssGetOutputPortDataType(S,idx);
   void * outputSignal = ssGetOutputPortSignal(S,idx);
   
   CANDB_BIT_PATTERN_DTYPE scaledIntValue = getUnprocessedSignalValue(S, idx, data);
   
   debugPrintf("Unpacking: Uint Signal value unpacked from the frame=%u\n", scaledIntValue); 
   
   int data_type = (int) signalProp(S,idx,"dataType");

   /* Sign extend signed CAN signals */
   if (data_type == SIGNED ){
      int bit_len   = (int) signalProp(S,idx,"length"); 
      scaledIntValue = signedIntExtend(scaledIntValue, bit_len);
      debugPrintf("Unpacking: Signed value after sign extending %d\n",scaledIntValue);
   }

   /* get the working datatype for integer scaling calculations */
   DTypeId workingDType;
   if (!deriveWorkingDataType(S, idx, dtype, workingDType)) {
      return;
   } 

   switch (dtype) {
      case SS_DOUBLE: {
         *(real64_T *) outputSignal = outputScaleReal <real64_T> (S, idx, scaledIntValue);            
         break;
      }
      case SS_SINGLE: {
         *(real32_T *) outputSignal = outputScaleReal <real32_T> (S, idx, scaledIntValue);
         break;
      }
      case SS_BOOLEAN: {
         *(boolean_T *) outputSignal = outputScale <boolean_T> (S, idx, scaledIntValue, workingDType);
         break;
      }
      case SS_UINT8: {
         *(uint8_T *) outputSignal = outputScale <uint8_T> (S, idx, scaledIntValue, workingDType);
         break;
      }
      case SS_UINT16: {
         *(uint16_T *) outputSignal = outputScale <uint16_T> (S, idx, scaledIntValue, workingDType);
         break;
      }
      case SS_UINT32: {
         *(uint32_T *) outputSignal = outputScale <uint32_T> (S, idx, scaledIntValue, workingDType);
         break;
      }
      case SS_INT8: {
         *(int8_T *) outputSignal = outputScale <int8_T> (S, idx, scaledIntValue, workingDType);
         break;
      }
      case SS_INT16: {
         *(int16_T *) outputSignal = outputScale <int16_T> (S, idx, scaledIntValue, workingDType);
         break;
      }
      case SS_INT32: {
         *(int32_T *) outputSignal = outputScale <int32_T> (S, idx, scaledIntValue, workingDType);
         break;
      }
      default: {
         ssSetErrorStatus(S, "Unknown datatype!");
         break;
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
   char buffer[1500];

   UserData * userData = (UserData * )  (ssGetUserData(S));

   if(!WriteMatlabStructureToRTWFile(S,
            ssGetSFcnParam(S,E_MESSAGE),
            "SFcnCanDbMessage",
            buffer, 1500)){
      ssSetErrorStatus(S,"Writing MATLAB structure to Real-Time Workshop file failed.\n");
      return;
   };

   /* -- Write out the user data vector, constantTerm -- */ 
   if (!ssWriteRTWParamSettings(S, 1, 
            
            SSWRITE_VALUE_VECT, "constantTerm",
            userData->constantTerm, N_SIGNALS
               
            )) {
      ssSetErrorStatus(S,"Writing Values to RTW file failed.\n");
   }

   /* safe to delete our user data object now */
   delete userData;
}
#endif

/*======================================================*
 * See sfuntmpl_doc.c for the optional S-function methods *
 *======================================================*/

/*======================================================*
 * Utilitiies
 *======================================================*/

/*-----------------------------------------------------------------------------
  Function getSignalValue

  Purpose - Extracts a signal from the data and returns it's real_T value

  Parameters

   S           -  Simstruct
   idx         -  The signal index we wish to extract
   data        -  The data in original orientation

-------------------------------------------------------------------------------*/
static CANDB_BIT_PATTERN_DTYPE getUnprocessedSignalValue(SimStruct * S, int idx, uint32_T * data){
	/* Retrieve parameters */
	int can_byte_layout = (int) signalProp(S,idx,"byteLayout");
	int start_bit = (int) signalProp(S,idx,"startBit");
	int bit_len   = (int) signalProp(S,idx,"length"); 

	return unpack(data,P_LENGTH, start_bit, bit_len, can_byte_layout );
}

#ifdef MATLAB_MEX_FILE

#define MDL_SET_OUTPUT_PORT_DATA_TYPE
/* Function: mdlSetOutputPortDataType =========================================
 *    This routine is called with the candidate data type for a dynamically
 *    typed port.  If the proposed data type is acceptable, the routine should
 *    go ahead and set the actual port data type using ssSetOutputPortDataType.
 *    If the data tyoe is unacceptable an error should generated via
 *    ssSetErrorStatus.  Note that any other dynamically typed input or
 *    output ports whose data types are implicitly defined by virtue of knowing
 *    the data type of the given port can also have their data types set via 
 *    calls to ssSetInputPortDataType or ssSetOutputPortDataType.
 */
static void mdlSetOutputPortDataType(SimStruct *S, 
                                     int       port, 
                                     DTypeId   dataType) {
   /* This function is used for checking the dynamic typing of the output ports.
    *
    * The type of the output signal
    * will be used to constrain the types of the 
    * other scaling operands, offset and factor.
    *
    */
   PORT_DATATYPE_ERROR error = checkPortDataType(S, port, dataType);
   if (error != SUCCESS) {
      setPortDataTypeErrorStatus(S, port, error, UNPACKING_BLOCK);
      return;
   }
   
   /* additional check that the output datatype is 
    * wide enough to handle whatever could be unpacked */
   if (portDataTypeRangeError(S, port, dataType)) {
      /* error status is already set */
      return;
   }

   /* no errors --> this datatype is good */
   ssSetOutputPortDataType(S, port, dataType);

} /* mdlSetOutputPortDataType */

/* check that the output datatype is 
 * wide enough to handle whatever could be unpacked */
static bool portDataTypeRangeError(SimStruct * S, int port, DTypeId dataType) {
   bool range_error = false;

   static char err_msg[500];
   char name[SIGMAXLEN];
   signalName(S, port, name, SIGMAXLEN - 1);
   
   /* get the user data object so that we can set constantTerm appropriately */
   UserData * userData = (UserData * )  (ssGetUserData(S));
   
   /* only check the data type range for integer types */
   if (isIntegerDType(dataType)) {
      /* get real input range */
      real64_T min_real, max_real, constantTerm;
      getRealInputMinMax(S, port, min_real, max_real, constantTerm, dataType);
     
      /* store the constant term, to avoid extra division during real time */
      userData->constantTerm[port] = constantTerm;

      /* get range of output datatype */ 
      real64_T dtypeMin, dtypeMax;
      getDTypeRange(dataType, dtypeMin, dtypeMax);

      if ((min_real < dtypeMin) || (max_real > dtypeMax)) {
            range_error = true;
            sprintf(err_msg, "The integer output datatype specified for signal %s cannot "
                             "represent all possible values that may have "
                             "been packed into this signal. Please choose a wider datatype or "
                             "a datatype with different sign "
                             "for the output.", name);
            ssSetErrorStatus(S, err_msg);      
      }
   }
   else {
      /* store a zero constantTerm to keep the RTW file tidy */
      userData->constantTerm[port] = 0.0;
   }
   return range_error;
}

#define MDL_SET_DEFAULT_PORT_DATA_TYPES
/* Function: mdlSetDefaultPortDataTypes ========================================
 *    This routine is called when Simulink is not able to find data type 
 *    candidates for dynamically typed ports. This function must set the data 
 *    type of all dynamically typed ports.
 */
static void mdlSetDefaultPortDataTypes(SimStruct *S)
{
    int port;
    int_T canStDT = ssGetDataTypeId(S,SL_CAN_STANDARD_FRAME_DTYPE_NAME );
   
    if (ssGetInputPortDataType(S,0) == DYNAMICALLY_TYPED){
       ssSetInputPortDataType(S, 0, canStDT);
    }

    for (port=0;port<N_SIGNALS;port++) {

        /* Only apply default datatype if none already set */
        if (ssGetOutputPortDataType(S, port) == -1) {
            ssSetOutputPortDataType(S, port, SS_DOUBLE);
            /* check that chosen datatype is valid,
             * in the same way we do for user specified datatypes */
            PORT_DATATYPE_ERROR error = checkPortDataType(S, port, SS_DOUBLE);
            if (error!=SUCCESS) {
              setPortDataTypeErrorStatus(S, port, error, UNPACKING_BLOCK);
            }
            /* no need to check the port datatype range for real (SS_DOUBLE)
             * types. */
        }
    }
} /* mdlSetDefaultPortDataTypes */


#endif /* MATLAB_MEX_FILE */



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
