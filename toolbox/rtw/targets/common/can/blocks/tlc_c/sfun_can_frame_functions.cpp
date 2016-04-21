/*
 * $Revision: 1.9.4.4 $
 * $Date: 2004/04/19 01:19:57 $
 *
 * Copyright 2002-2004 The MathWorks, Inc.
 */
#include "sfun_can_frame_functions.hpp"
#include "endian_test.hpp"

/* documentation in header file */
void debugPrintf(char *fmt, ...) {
#ifdef DEBUG_OUTPUT
   /* buffer used for call to vsprintf */
   static char buffer[1024];
   
   va_list args;
   va_start( args, fmt );
   /* use vsprintf to process the arguments */
   vsprintf(buffer, fmt, args);
   va_end( args );

   /* make the call to mexPrintf */
   mexPrintf("%s", buffer);
#endif
}

/* documentation in header file */
bool isWholeNumber(real64_T input) {
   if (floor(input) != input) {
      return false;
   }
   else return true;
}

/* documentation in header file */
bool isParameterValid(real64_T input, 
                      DTypeId dtype) {
   real64_T min,max;
   /* get the range of the datatype */
   getDTypeRange(dtype, min, max);
   if (isIntegerDType(dtype)) {
      /* check parameter is whole number */
      if (!isWholeNumber(input)) {
         return false;
      }
   }

   if (input > max) return false;
   if (input < min) return false;
   return true;
}

/* documentation in header file */
bool isIntegerDType(DTypeId dtype) {
   if ((dtype == SS_DOUBLE) || (dtype == SS_SINGLE)) {
      /* real datatype */
      return false;
   }
   else {
      /* integer datatype */
      return true;
   }
}

/* documentation in header file */
bool isSignedIntegerDType(DTypeId dtype) {
   if (isIntegerDType(dtype)) {
      switch (dtype) {
         case SS_INT8:
         case SS_INT16:
         case SS_INT32:
            /* signed integer */
            return true;
            break;
         case SS_BOOLEAN:
         case SS_UINT8:
         case SS_UINT16:
         case SS_UINT32:
            /* unsigned integer */
            return false;
            break;
         default:
            mexPrintf("Error: isSignedIntegerDType: Unknown datatype!");   
            return false;
            break;
      }
   }
   else {
      /* real type */
      return false;
   }
}

/* documentation in header file */
void getSVRange(SimStruct *S, 
                int idx, 
                real64_T &minSV, 
                real64_T &maxSV) {
   int sv_bit_length   = (int) signalProp(S,idx,"length"); 
   int sv_data_type = (int) signalProp(S,idx,"dataType");

   /* zero min/maxSV */
   minSV = 0;
   maxSV = 0;
   
   if (sv_data_type == UNSIGNED) {

      if ( sv_bit_length == 32 ){
         maxSV = UINT_MAX;
      }else{
         maxSV = (uint32_T ) ~( ~0 << sv_bit_length );
      }
   }
   else {
      // SIGNED

      if ( sv_bit_length == 32 ){
         maxSV = INT_MAX;
         minSV = INT_MIN;
      }else{
         maxSV = (int32_T) ( ~ ( ~0 << ( sv_bit_length - 1) )); 
         minSV = (int32_T)  - ( maxSV + 1);
      }
   }
}

/* documentation in header file */
void getDTypeRange(DTypeId dtype, 
                   real64_T & dtypeMin, 
                   real64_T & dtypeMax) {
   switch (dtype) {
         case SS_DOUBLE:
            dtypeMin = -DBL_MAX;
            dtypeMax = DBL_MAX;
            break;
         case SS_SINGLE:
            dtypeMin = -FLT_MAX;
            dtypeMax = FLT_MAX;
            break;
         case SS_BOOLEAN:
            dtypeMin = 0;
            dtypeMax = 1;
            break;
         case SS_UINT8:
            dtypeMin = MIN_uint8_T; 
            dtypeMax = MAX_uint8_T;
            break;
         case SS_UINT16:
            dtypeMin = MIN_uint16_T;
            dtypeMax = MAX_uint16_T;
            break;
         case SS_UINT32:
            dtypeMin = MIN_uint32_T;
            dtypeMax = MAX_uint32_T;
            break;
         case SS_INT8:
            dtypeMin = MIN_int8_T;
            dtypeMax = MAX_int8_T;
            break;
         case SS_INT16:
            dtypeMin = MIN_int16_T;
            dtypeMax = MAX_int16_T;
            break;
         case SS_INT32:
            dtypeMin = MIN_int32_T;
            dtypeMax = MAX_int32_T;
            break;
         default:
            mexPrintf("Error: getDTypeRange: Unknown datatype!");   
            break;
      }
}

/* documentation in header file */
void setPortDataTypeErrorStatus(SimStruct *S, int_T port, PORT_DATATYPE_ERROR error_code, CALLER_TYPE caller) {
   static char err_msg[500];
   char name[SIGMAXLEN];
   signalName(S, port, name, SIGMAXLEN - 1);

   switch (error_code) {
      case OFFSET_NOT_CORRECT_TYPE:
         if (caller == PACKING_BLOCK) {
            sprintf(err_msg,
               "The offset specified for signal %s is incompatible "
               "with the input signal datatype. The offset must be "
               "representable in the same datatype as the input signal.",
               name);
         }
         else {
            /* UNPACKING_BLOCK */
            sprintf(err_msg,
               "The offset specified for signal %s is incompatible "
               "with the output signal datatype. The offset must be "
               "representable in the same datatype as the output signal.",
               name);
         }
         ssSetErrorStatus(S,err_msg);
         break;
      case FACTOR_NOT_CORRECT_TYPE:
         if (caller == PACKING_BLOCK) {
            sprintf(err_msg,
               "The factor specified for signal %s is incompatible "
               "with the input signal datatype. The factor must be "
               "representable in the same datatype as the input signal.",
               name);
         }
         else {
            sprintf(err_msg,
               "The factor specified for signal %s is incompatible "
               "with the output signal datatype. The factor must be "
               "representable in the same datatype as the output signal.",
               name);
         }
         ssSetErrorStatus(S,err_msg);
         break;
      case CONSTANT_TERM_ERROR:
         if (caller == PACKING_BLOCK) {
            sprintf(err_msg,
               "The offset and factor specified for signal %s are incompatible "
               "with the input signal datatype. "
               "The division, offset / factor, must result in a value "
               "that is representable in the input signal datatype.",
               name);

         }
         else {
            sprintf(err_msg,
               "The offset and factor specified for signal %s are incompatible "
               "with the output signal datatype. "
               "The division, offset / factor, must result in a value "
               "that is representable in the output signal datatype.",
               name);
         }
         ssSetErrorStatus(S,err_msg);
         break;
      default:
         ssSetErrorStatus(S, "Unknown error code!");   
         break;
   }
}

/* documentation in header file */
PORT_DATATYPE_ERROR checkPortDataType(SimStruct *S, int_T port, DTypeId dataType) {
   real64_T offset_real64 = signalProp(S,port,"offset");
   real64_T factor_real64 = signalProp(S,port,"factor");

   /* check offset parameter is of the 
    * input / output datatype */
   if (!isParameterValid(offset_real64,
            dataType)) {
      return OFFSET_NOT_CORRECT_TYPE;
   }

   /* check factor parameter is of the  
    * input / output datatype */
   if (!isParameterValid(factor_real64,
            dataType)) {
      return FACTOR_NOT_CORRECT_TYPE;
   }

   if (isIntegerDType(dataType)) {
      /* additional check is required to ensure that integer offset and factor,
       * result in a constantTerm that is representable in the same type 
       * this is a potentially nasty edge case */
      if (factor_real64 == -1) {
         /* in this case, if offset is dtypemin, then 
          * offset / factor will result in a value that is 
          * not representable in dtype */
         real64_T min, max;
         getDTypeRange(dataType, min, max);
         if (offset_real64 == min) {
            return CONSTANT_TERM_ERROR;
         }
      }
   }
   return SUCCESS;
}

/* documented in header file */
void getRealInputMinMax(SimStruct *S, 
                        int idx, 
                        real64_T & min_real, 
                        real64_T & max_real,
                        real64_T & constantTerm,
                        int dtype) {
   
   
   real64_T offset_real = signalProp(S,idx,"offset");
   real64_T factor_real = signalProp(S,idx,"factor");

   /* calculate the constant term = offset / factor
    *
    * use the appropriate INTEGER division */
   if (isSignedIntegerDType(dtype)) {
      /* handle all cases by performing division as int32 */
      constantTerm = (real64_T) ((int32_T) offset_real / (int32_T) factor_real);
   }
   else {
      /* handle all cases by performing division as uint32 */
      constantTerm = (real64_T) ((uint32_T) offset_real / (uint32_T) factor_real);
   }

   /* apply the inverse scaling 
    *
    * we perform this calculation in double precision
    *
    * Note that minSV, constantTerm & factor_real are all integers:
    *    
    *    double can represent each of these numbers exactly, but may not be able to represent
    *    the result integer EXACTLY - if this is true, then we know that the result is 
    *    out of range for the integer input datatype, and so we don't care - the input datatype
    *    will provide our saturation.   Otherwise, we should have an exact integer.
    *
    *    Note also that the calculation below can not overflow since it is done in double 
    *    precision.   The maximum value of SV, constantTerm and factor_real is:
    *
    *    UINT32 <= 2^32
    *
    *    So, the maximum value of the calculation would be, (2^32 + 2^32) * 2^32 = 
    *    2 * 2^32 * 2^32 = 2^65
    *
    *    This is well within the range of double precision values: 
    *
    *    -(2-2^-52) x 2^1023 .. (2-2^-52) x 2^1023 
    * 
    */
   real64_T minSV, maxSV;
   /* get the range of the scaled output value */
   getSVRange(S, idx, minSV, maxSV);

   min_real = (minSV + constantTerm) * factor_real;
   max_real = (maxSV + constantTerm) * factor_real;

   /* swap min_real and max_real if required */
   if (min_real > max_real) {
      real64_T temp = min_real;
      min_real = max_real;
      max_real = temp;
   }
}

/* documentation in header file */
bool deriveWorkingDataType(SimStruct *S, int_T port, DTypeId portDataType, DTypeId & workingDType) {
   /* the bit length of the output signal */
   int sv_bit_length   = (int) signalProp(S,port,"length"); 
   
   /* check the length of the output signal 
    * is no greater than the word size, since we are
    * not supporting packing of multi word datatypes */
   if (sv_bit_length > MESSAGE_WORD_SIZE) {
      ssSetErrorStatus(S, "One of the signals specified is too wide to be packed. "
                          "The CANdb Packing block only supports signals up to 32 bits long. "
                          "Please change the signal specification to be narrower.");
      return false;
   }
   
   /* derive the working datatype for all parts of the scaling
    * calculation */
   if (isIntegerDType(portDataType)) {
      /* need to be careful about the working datatype */
      /* get the bit size of the input / output datatype */
      int size = ssGetDataTypeSize(S, portDataType) * 8;
      if (size > MESSAGE_WORD_SIZE) {
         /* we know that sv_bit_length <= MESSAGE_WORD_SIZE 
          * --> size > sv_bit_length
          *
          * So, we should work in the size in this case */
         workingDType = portDataType; 
      }
      else {
         /* size <= MESSAGE_WORD_SIZE
          *
          * AND size MAY BE <= sv_bit_length
          *
          * So, we widen the working type to MESSAGE_WORD_SIZE.
          *
          * We keep the sign of the input / output datatype though */
         if (isSignedIntegerDType(portDataType)) {
            workingDType = SIGNED_WORD_SIZE_DTYPE_ID;
         }
         else {
            workingDType = UNSIGNED_WORD_SIZE_DTYPE_ID;
         }
      }
   }
   else {
      /* for floating point input / output types,
       * we will work in the input / output datatype */
      workingDType = portDataType;
   }
   return true;
}


/* constructor for UserData class
 *
 * array sizes are set to numSignals
 *
 */
UserData::UserData(int numSignals) {
   min = new real64_T[numSignals];
   max = new real64_T[numSignals];
   constantTerm = new real64_T[numSignals];
   apply_min = new uint8_T[numSignals];
   apply_max = new uint8_T[numSignals];
}

/* destructor for UserData class */
UserData::~UserData() {
   delete min;
   delete max;
   delete constantTerm;
   delete apply_min;
   delete apply_max;
}
