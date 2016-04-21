/*
 * File: sfun_can_frame_constructor.cpp
 *
 * Abstract:
 *    Description of file contents and purpose.
 *
 *
 * $Revision: 1.8.4.3 $
 * $Date: 2004/04/19 01:19:55 $
 *
 * Copyright 2001-2004 The MathWorks, Inc.
 */

/*
 * You must specify the S_FUNCTION_NAME as the name of your S-function
 * (i.e. replace sfuntmpl_basic with the name of your S-function).
 */
#define S_FUNCTION_NAME sfun_can_frame_constructor
#define S_FUNCTION_LEVEL 2

// must include this outside of the C linkage
#include "sfun_can_frame_functions.hpp"
#include "serial_packing.hpp"

/* C++ templated function to unscale real32 and real64 types.
 *
 * All calculations are performed in the template type T, which
 * will be the type of the input signal.
 */
template <class T> 
static CANDB_BIT_PATTERN_DTYPE inputScaleReal(SimStruct *S, 
                                              int idx, 
                                              T input) {
   debugPrintf("Real scaling calculation\n");

   UserData * userData = (UserData * )  (ssGetUserData(S));
   
   /* get offset and factor */
   T offset = (T) signalProp(S,idx,"offset");
   T factor = (T) signalProp(S,idx,"factor");
   
   debugPrintf("Input = %f, Offset = %f, Factor = %f\n", input, offset, factor);
  
   /* perform the scaling calculation - assume that the input / offset
    * are conditioned such that overflow will not occur */
   T result = ((input - offset) / factor);

   debugPrintf("Result = %f\n", result);
   
   /* saturate the result */
   T min = (T) userData->min[idx];
   T max = (T) userData->max[idx];

   if (result > max) {
      debugPrintf("Saturating result to maxSV = %f\n", max);
      result = max;
   }
   else if (result < min) {
      debugPrintf("Saturating result to minSV = %f\n", min);
      result = min;
   }

   int can_data_type = (int) signalProp(S,idx,"dataType");
   
   /* output has been saturated
    *  
    * cast (truncate) to an integer type to make sure it ends up 
    * in the saturated range 
    *
    * Could have rounded here instead, but truncatation is the simpler
    * mechanism, especially when considering all of the edge 
    * cases associated with float & double spacing, and the saturation range etc */
   if (can_data_type == UNSIGNED) {
      uint32_T temp = (uint32_T) result;
      debugPrintf("Result as unsigned int = %u\n", temp);
      return (CANDB_BIT_PATTERN_DTYPE) temp;
   }
   else {
      int32_T temp = (int32_T) result;
      debugPrintf("Result as signed int = %d\n", temp);
      return (CANDB_BIT_PATTERN_DTYPE) temp;
   }
}

/* C++ templated function to scale all integer types.
 *
 * All calculations are performed in the template type T, which
 * will be the type of the "working datatype", which may be wider
 * than the type of the signal.
 *
 * For integer types, saturation is applied before scaling.
 *
 * We use the pre-calculated constant term in the scaling calculation.
 *
 */
template <class T> 
static CANDB_BIT_PATTERN_DTYPE workingDTypeScale(SimStruct *S, int idx, T input) {
   debugPrintf("Integer scaling calculation\n");

   UserData * userData = (UserData * )  (ssGetUserData(S));
   
   /* get the saturation points for input */
   T min = (T) userData->min[idx];
   T max = (T) userData->max[idx];
   /* get precalculated constant */
   T constantTerm = (T) userData->constantTerm[idx];
   /* get offset and factor */
   T offset = (T) signalProp(S,idx,"offset");
   T factor = (T) signalProp(S,idx,"factor");

   debugPrintf("Input = %f, Offset = %f, Factor = %f\n", (double) input, (double) offset, (double) factor);

   if (input <  min) {
      // lower saturation
      input = min;
      debugPrintf("Saturating input to min input = %f\n", (double) min);
   }
   else if (input > max) {
      // upper saturation
       input = max;
       debugPrintf("Saturating input to max input =%f\n", (double) max);
   }
   
   /* perform the scaling calculation */
   CANDB_BIT_PATTERN_DTYPE result = ((input / factor) - constantTerm);

   int can_data_type = (int) signalProp(S,idx,"dataType");
   if (can_data_type == UNSIGNED) {
      debugPrintf("Result as unsigned int = %u\n", result);
   }
   else {
      debugPrintf("Result as signed int = %d\n", result);
   }
   return result;
}

/* C++ templated function to handle the widening of integer input signal types
 * to the working datatype.
 *
 * This function widens the input type, and then calls the workingDTypeScale function
 * to perform the scaling in the working datatype.
 *
 */
template <class T>
static CANDB_BIT_PATTERN_DTYPE inputScale(SimStruct * S, int idx, T input, DTypeId workingDType) {
   CANDB_BIT_PATTERN_DTYPE bitPattern;
   switch (workingDType) {
      case SS_BOOLEAN: {
         boolean_T widenedInput = (boolean_T) input;
         bitPattern = workingDTypeScale(S, idx, widenedInput);
         break;
      }
      case SS_UINT8: {
         uint8_T widenedInput = (uint8_T) input;
         bitPattern = workingDTypeScale(S, idx, widenedInput);
         break;
      }
      case SS_UINT16: {
         uint16_T widenedInput = (uint16_T) input;
         bitPattern = workingDTypeScale(S, idx, widenedInput);
         break;
      }
      case SS_UINT32: {
         uint32_T widenedInput = (uint32_T) input;
         bitPattern = workingDTypeScale(S, idx, widenedInput);
         break;
      }
      case SS_INT8: {
         int8_T widenedInput = (int8_T) input;
         bitPattern = workingDTypeScale(S, idx, widenedInput);
         break;
      }
      case SS_INT16: {
         int16_T widenedInput = (int16_T) input;
         bitPattern = workingDTypeScale(S, idx, widenedInput);
         break;
      }
      case SS_INT32: {
         int32_T widenedInput = (int32_T) input;
         bitPattern = workingDTypeScale(S, idx, widenedInput);
         break;
      }
      default: {
         ssSetErrorStatus(S, "Unknown datatype!");   
         break;
      }
                 
   }
   return bitPattern;
}

#ifdef __cplusplus
extern "C" { // use the C fcn-call standard for all functions  
            // defined within this scope                     
#endif

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
#define P_SIGNAL         mxGetField(P_SIGNALS,0,"signal")
#define N_SIGNALS        ((mxIsEmpty(P_SIGNALS)==1) ? 0 : ((mxGetDimensions(P_SIGNAL))[1]))

#define SAFE_GET_SCALAR(array) ( array != NULL ? mxGetScalar(array) : \
      ( ssSetErrorStatus(S,"null pointer to mxGetScalar"), 0 ) )

#define _SCLR_MESS_PROP(prop)    ( (int) SAFE_GET_SCALAR((P_MESSAGE(prop))))
#define P_LENGTH           _SCLR_MESS_PROP("length")
#define P_ID               _SCLR_MESS_PROP("id")
#define P_ID_TYPE          _SCLR_MESS_PROP("idType")


   /*====================*
    * User - Methods
    *====================*/
   static void packSignals(SimStruct * S, int idx, uint32_T * data);
   static CANDB_BIT_PATTERN_DTYPE getUnprocessedSignalValue(SimStruct * S, int idx, uint32_T * data);

/*====================*
 * S-function methods *
 *====================*/

#define MDL_SET_INPUT_PORT_DATA_TYPE
#ifdef MDL_SET_INPUT_PORT_DATA_TYPE
static void mdlSetInputPortDataType(SimStruct *S, int_T port, DTypeId dataType) {
   /* This function is used for checking the dynamic typing of the input ports.
    *
    * The type of the input signal
    * will be used to constrain the types of the 
    * other scaling operands, offset and factor.
    *
    */
   PORT_DATATYPE_ERROR error = checkPortDataType(S, port, dataType);
   if (error == SUCCESS) {
      ssSetInputPortDataType(S,port,dataType);
   }
   else {
      setPortDataTypeErrorStatus(S, port, error, PACKING_BLOCK);
   }
}
#endif

#define MDL_SET_DEFAULT_PORT_DATA_TYPES
/* Function: mdlSetDefaultPortDataTypes ========================================
*    This routine is called when Simulink is not able to find data type 
*    candidates for dynamically typed ports. This function must set the data 
*    type of all dynamically typed ports.
*/
static void mdlSetDefaultPortDataTypes(SimStruct *S)
{
   int port;

   for (port=0;port<N_SIGNALS;port++) {
      /* Only apply default datatype if none already set */
      if (ssGetInputPortDataType(S, port) == -1) {
         // always default to double  
         ssSetInputPortDataType(S, port, SS_DOUBLE);
         /* check that chosen datatype is valid,
          * in the same way we do for user specified datatypes */
         PORT_DATATYPE_ERROR error = checkPortDataType(S, port, SS_DOUBLE);
         if (error!=SUCCESS) {
           setPortDataTypeErrorStatus(S, port, error, PACKING_BLOCK);
         }
      }   
   }
} /* mdlSetDefaultPortDataTypes */

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

   // Setup output port
   ssSetNumOutputPorts(S,1);
   ssSetOutputPortWidth(S,0,1);

   // Work out the output port data type
   CanFrameType canFrameType = (CanFrameType) P_ID_TYPE;
   if( canFrameType == CAN_MESSAGE_STANDARD){
      ssSetOutputPortDataType(S,0,canStDT);
   }else if ( canFrameType == CAN_MESSAGE_EXTENDED ){
      ssSetOutputPortDataType(S,0,canExDT);
   }

   // Work out the number of input ports
   int nInputPorts = N_SIGNALS;

   // rogue value for mode signal
   userData->mode_signal = -1;

   ssSetNumInputPorts(S,N_SIGNALS);
   for (idx = 0; idx< N_SIGNALS; idx ++){
      // specify that the port types are dynamically assigned
      // we accept anything as an input argument!
      ssSetInputPortDataType(S,idx,DYNAMICALLY_TYPED);
      ssSetInputPortWidth(S,idx,1);
      ssSetInputPortDirectFeedThrough(S,idx,true);
      real64_T factor_real = signalProp(S,idx,"factor");
      real64_T offset_real = signalProp(S,idx,"offset");
      
      if (factor_real == 0) {
         static char err_msg[200];
         char name[SIGMAXLEN];
         signalName(S, idx, name, SIGMAXLEN-1);
         sprintf(err_msg,
               "Signal %s: The factor must be non-zero. ",
               name);
          //reject proposed data type 
         ssSetErrorStatus(S,err_msg);
         return;
      }
      // Search to find if there is a MODE signal in the 
      // signal set and save the id of that signal and
      // the blocks user data.
      if (signalProp(S,idx,"signalType")==MODE){
         userData->mode_signal=idx;
         if ((factor_real!=1) || (offset_real!=0)) {
            ssSetErrorStatus(S,"Mode signal must have factor=1 and offset=0.");
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
   
   /* use UserData instead of RWork since
    * we do not want the RWork at real time! */
   ssSetNumRWork(S, 0);
   /* use UserData instead of IWork since
    * we do not want the IWork at real time! */
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
   int idx;
   /*
      Calculate range for the packed signal
      based on the signal length and the type. 
      
      Then, for integer datatypes, pre-calculate the min and 
      max input values, and store these as saturation points in the user data.

      For real datatypes, we will saturate after the scaling calculation, and it 
      is the min and max scaled values that we store in the user data.
   
   */
   UserData * userData = (UserData * )  (ssGetUserData(S));
   
   for (idx = 0; idx< N_SIGNALS; idx++){

      int dtype = ssGetInputPortDataType(S,idx);

      if (isIntegerDType(dtype)) {
         
         /* get real minimum and maximum input values */
         real64_T min_real, max_real, constantTerm;
         getRealInputMinMax(S, idx, min_real, max_real, constantTerm, dtype);
         
         /* get range of input datatype */ 
         real64_T dtypeMin, dtypeMax;
         getDTypeRange(dtype, dtypeMin, dtypeMax);

         if ((dtypeMin > max_real) || (dtypeMax < min_real)) {
            /* error */
            ssSetErrorStatus(S,"No possible values of the input signal can be scaled to fit in the CANdb output signal.");
            return;
         }

         uint8_T saturateMin, saturateMax;

         if (dtypeMax > max_real) {
            /* saturate input to max_real */
            saturateMax = 1; 
            /* max_real should be an integer unless 
             * our calculations are incorrect */
            if (!isWholeNumber(max_real)) {
               ssSetErrorStatus(S, "Unexpected error: max_real is not a whole number!");
               return;
            }
         }
         else {
            /* input datatype will provide the saturation we need */
            saturateMax = 0;
            max_real = dtypeMax;
         }

         if (dtypeMin < min_real) {
            /* saturate input to min_real */
            saturateMin = 1;
            /* min_real should be an integer unless
             * our calculations are incorrect */
            if (!isWholeNumber(min_real)) {
               ssSetErrorStatus(S, "Unexpected error: min_real is not a whole number!");
               return;
            }
         }
         else {
            /* min_real <= dtypeMin */
            real64_T factor_real = signalProp(S,idx,"factor");
            if (factor_real == -1) {
               /* when the factor is -1, we cannot allow the input 
                * to equal dtypemin - the result of division will not 
                * be representable in the input type */
               saturateMin = 1;
               /* input must be 1 greater than input dtype min */
               min_real = dtypeMin + 1;
               /* if min_real has become greater than max_real, 
                * then we have a problem */
               if (min_real > max_real) {
                  ssSetErrorStatus(S, "No possible values of the input signal can be scaled to fit in the CANdb output signal.");
                  return;
               }
            }
            else {
               /* input datatype will provide the saturation we need */
               saturateMin = 0;
               min_real = dtypeMin;
            }
         }

         /* store the saturation points in user data */
         userData->min[idx] = min_real;
         userData->max[idx] = max_real;
         /* store the constant term, to avoid extra division during real time */
         userData->constantTerm[idx] = constantTerm;
         /* store whether to apply the saturation points in user data */
         userData->apply_min[idx] = saturateMin;
         userData->apply_max[idx] = saturateMax;
         debugPrintf("Idx = %d: saturateMin = %d\n", idx, saturateMin);
         debugPrintf("Idx = %d: saturateMax = %d\n", idx, saturateMax);
      }
      else {
         /* NOTE: we do not perform the same kind of inverse scaling
          * calculation for the real types.   This is owing to worries 
          * of overflow and precision inconsistencies.
          *
          * Instead, we will saturate the result of the scaling calculation,
          * and assume that the input and offset are conditioned such that
          * overflow will not occur.
          */
         real64_T minSV, maxSV;
         /* get the range of the scaled output value */
         getSVRange(S, idx, minSV, maxSV);

         if (dtype == SS_SINGLE) {
            /* single precision floating point values may not be able to 
             * represent the min / max scaled values exactly.
             * we must find single values to use that are 
             * within the range [minSV, maxSV] */
            real32_T minSVFloat = castMinSVtoFloat((int32_T) minSV);
            real32_T maxSVFloat = castMaxSVtoFloat((uint32_T) maxSV);
            /* store the min and max scaled values in the user data */
            userData->min[idx] = (real64_T) minSVFloat;
            userData->max[idx] = (real64_T) maxSVFloat;
         }
         else {
            /* store the min and max scaled values in the user data */
            userData->min[idx] = minSV;
            userData->max[idx] = maxSV;
         }
         /* store a zero constantTerm to keep the RTW file tidy */
         userData->constantTerm[idx] = 0.0;
      }
   }
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
   const void * uFrame = ssGetOutputPortSignal(S,0);
   int signal_type,mode_value;

   uint32_T data[2] = {0, 0};

   int idx ;

   UserData * userData;

   frame = (CAN_FRAME *) ssGetOutputPortSignal(S,0);

   userData = (UserData * )  (ssGetUserData(S));
   if(userData==NULL){
      ssSetErrorStatus(S,"UserData was null when trying to access it");
      return;
   }
   userData = (UserData *) ssGetUserData(S);
   if ( userData->mode_signal != -1 ){
      /* process the mode signal first */
      packSignals(S, userData->mode_signal, data);
      /* extract the mode value - either a signed or unsigned quantity */
      CANDB_BIT_PATTERN_DTYPE modeSig = getUnprocessedSignalValue(S, userData->mode_signal, data);
      /* Sign extend if signed */
      int data_type = (int) signalProp(S,userData->mode_signal,"dataType");
      switch(data_type) {
         case SIGNED:
            {
               int bit_len   = (int) signalProp(S,userData->mode_signal,"length"); 
               modeSig = signedIntExtend(modeSig, bit_len);
               debugPrintf("Packing: Mode signal signed value after sign extending %d\n",modeSig);
               break;
            }
      }
      
      for(idx = 0; idx < N_SIGNALS; idx++){
         signal_type = (int) signalProp(S,idx,"signalType");
         mode_value = (int) signalProp(S,idx,"modeValue");
         switch (signal_type) {
            case MODE:
               /* no action - already processed */
               break;
            case STANDARD:
               /* always pack */
               packSignals(S,idx,data);
               break;
            case MODE_DEPENDANT:
               switch (data_type) {
                  case SIGNED:
                     if (mode_value == (int32_T) modeSig) {
                        packSignals(S,idx,data);
                     }
                     break;
                  case UNSIGNED:
                     if (mode_value == modeSig) {
                        packSignals(S, idx, data);
                     }
                     break;                 
               }
               break;
         }
      }
   }else{
      for(idx = 0; idx < N_SIGNALS; idx++){
         packSignals(S,idx,data);
      }
   }
   /* copy the data to the frame */
   memcpy(&(frame->DATA),data,P_LENGTH);
   frame->LENGTH = P_LENGTH;
   frame->ID = P_ID;
}

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

/*---------------------------------------------------------------
  Function packSignals

  Purpose - packs signal idx into the frame data (64 bit)

  Parameters -
  S        -  Simstruct
  idx      -  The signal index
  data     -  The output data frame

  ----------------------------------------------------------------*/

static void packSignals(SimStruct * S, int idx, uint32_T * data){
   // we are only dealing with 32 bit words for Simulation.
   // use union so we can easily access individual bytes as required.  
   
      char name[SIGMAXLEN];
      signalName(S, idx, name, SIGMAXLEN-1);

      
      debugPrintf("Packing input signal %d = %s\n", idx + 1, name);

   /* Retrieve parameters for the signal */
   int can_byte_layout = (int) signalProp(S,idx,"byteLayout");
   int can_start_bit = (int) signalProp(S,idx,"startBit");
   int can_bit_length   = (int) signalProp(S,idx,"length"); 

   // read the input type correctly according to it's type
   int inputPortDType = ssGetInputPortDataType(S,idx);

   /* ---------------------------------------------------------------
   *  Create 3 temporary variables for storing the input signal and
   *  then load those variables
    * -------------------------------------------------------------*/

   CANDB_BIT_PATTERN_DTYPE scaledIntValue; 
   
   InputPtrsType inputValuePtrs = ssGetInputPortSignalPtrs(S,idx);


   /* get the working datatype for integer scaling calculations */
   DTypeId workingDType;
   if (!deriveWorkingDataType(S, idx, inputPortDType, workingDType)) {
      return;
   }
   
   switch (inputPortDType) {
      case SS_DOUBLE: {
         real64_T input = (real64_T) *((InputRealPtrsType) inputValuePtrs) [0]; 
         scaledIntValue = inputScaleReal(S, idx, input); 
         break;
      }
      case SS_SINGLE: {
         real32_T input = (real32_T) *((InputReal32PtrsType) inputValuePtrs) [0]; 
         scaledIntValue = inputScaleReal(S, idx, input);
         break;
      }
      case SS_BOOLEAN: {
         boolean_T input = (boolean_T) *((InputBooleanPtrsType) inputValuePtrs)[0];
         scaledIntValue = inputScale(S, idx, input, workingDType); 
         break;
      }
      case SS_UINT8: {
         uint8_T input = (uint8_T) *((InputUInt8PtrsType) inputValuePtrs) [0];
         scaledIntValue = inputScale(S, idx, input, workingDType); 
         break;
      }
      case SS_UINT16: {
         uint16_T input = (uint16_T) *((InputUInt16PtrsType) inputValuePtrs) [0];  
         scaledIntValue = inputScale(S, idx, input, workingDType);
         break;
      }
      case SS_UINT32: {
         uint32_T input = (uint32_T) *((InputUInt32PtrsType) inputValuePtrs) [0];
         scaledIntValue = inputScale(S, idx, input, workingDType);
         break;
      }
      case SS_INT8: {
         int8_T input = (int8_T) *((InputInt8PtrsType) inputValuePtrs) [0];
         scaledIntValue = inputScale(S, idx, input, workingDType);
         break;
      }
      case SS_INT16: {
         int16_T input = (int16_T) *((InputInt16PtrsType) inputValuePtrs) [0];
         scaledIntValue = inputScale(S, idx, input, workingDType);
         break;
      }
      case SS_INT32: {
         int32_T input = (int32_T) *((InputInt32PtrsType) inputValuePtrs) [0];
         scaledIntValue = inputScale(S, idx, input, workingDType);
         break;
      }
      default: {
         ssSetErrorStatus(S, "Unknown datatype!");   
         break;
      }
   }
   debugPrintf("UInt Value that will be packed into the frame=%u\n",scaledIntValue);

   // Mask, Shift and Pack the scaledIntValue into the data
   pack(data, scaledIntValue, P_LENGTH, can_start_bit, can_bit_length, can_byte_layout);

   debugPrintf("Word0 0x%x\n", data[0]);
   debugPrintf("Word1 0x%x\n\n", data[1]);
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
   };

   /* -- Write Invariant Signal Settings -- */
   if ( !mxIsFinite( ssGetSampleTime( S, 0 ) ) ) {
      CAN_FRAME * frame = (CAN_FRAME *) ssGetOutputPortSignal(S,0);
      CAN_write_rtw_frame(S,frame);
   }

   /* -- Write out the user data vectors, 
    * min, max, constantTerm, apply_min, apply_max -- */ 
   if (!ssWriteRTWParamSettings(S, 5, 
            SSWRITE_VALUE_VECT, "min", 
            userData->min, N_SIGNALS,

            SSWRITE_VALUE_VECT, "max",
            userData->max, N_SIGNALS,

            SSWRITE_VALUE_VECT, "constantTerm",
            userData->constantTerm, N_SIGNALS,

            SSWRITE_VALUE_DTYPE_VECT, "apply_min",
            (void *) userData->apply_min, N_SIGNALS, DTINFO(SS_UINT8, 0),

            SSWRITE_VALUE_DTYPE_VECT, "apply_max",
            (void *) userData->apply_max, N_SIGNALS, DTINFO(SS_UINT8,0)
               
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
