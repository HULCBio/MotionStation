/*
 * File: sfun_can_frame_functions.hpp
 *
 * Abstract:
 *
 *
 * $Revision: 1.9.4.5 $
 * $Date: 2004/04/19 01:19:58 $
 *
 * Copyright 2001-2004 The MathWorks, Inc.
 */

#ifndef _SFUN_CAN_FRAME_FUNCTIONS_HPP_
#define  _SFUN_CAN_FRAME_FUNCTIONS_HPP_

#include <math.h>
#include <stdarg.h>
/* for DBL/FLT MAX/MIN */
#include <float.h>

#ifdef __cplusplus
/* function prototypes - use the C function call standard */
extern "C" {
	#include "simstruc.h"

   /* include special floating point routines */
   #include "sfun_can_frame_fp_functions.h"

   /* C++ inlined functions in this header file */
	static inline real64_T signalProp(SimStruct *, const int idx, const char *);
   static inline void signalName(SimStruct *, const int, char *, int);
   static inline uint32_T signedIntExtend(uint32_T, const uint8_T);
   
   /* functions in sfun_can_frame_functions.cpp */

   /* Wrapper for mexPrintf that only prints
    * when the global define DEBUG_OUTPUT is defined */
   void debugPrintf(char *fmt, ...);
  
   /* dtypeMin and dtypeMax are set to the min and max
    * values of the datatype, dtype.
    */
   void getDTypeRange(DTypeId dtype, 
                      real64_T & dtypeMin, 
                      real64_T & dtypeMax);
   
   /* returns true if input has no fractional part,
    * false otherwise */
   bool isWholeNumber(real64_T input);
   
   /* checks value, input, can be represented in the 
    * data type given by dtype.
    *
    * For integer dtype, input must be a whole number
    * and in range for the datatype. 
    *
    * For real dtype, input must be in range for the 
    * datatype. 
    */
   bool isParameterValid(real64_T input, 
                         DTypeId dtype);
  
   /* Given a datatype, dtype, returns true if it is an
    * integer type, and false if it is not integer - ie. real.
    */
   bool isIntegerDType(DTypeId dtype);

   /* Given a datatype, dtype, returns true if it is a
    * signed integer type, and false otherwise - 
    * ie. unsigned integer or real .
    */
   bool isSignedIntegerDType(DTypeId dtype);
  
   /* Given a signal index, idx, minSV, and maxSV are
    * set to the minimum and maximum scaled output values.
    */
   void getSVRange(SimStruct *S, 
                   int idx, 
                   real64_T &minSV, 
                   real64_T &maxSV); 

   /* enumeration used to flag whether 
    * the offset and factor are valid for 
    * a particular port datatype */
   typedef enum {SUCCESS, 
                 OFFSET_NOT_CORRECT_TYPE, 
                 FACTOR_NOT_CORRECT_TYPE,
                 CONSTANT_TERM_ERROR,
                 } PORT_DATATYPE_ERROR;

   
   /* enumeration to identify who (Packing / Unpacking) is calling
    * a shared function */
   typedef enum CALLER_TYPE { PACKING_BLOCK=0, UNPACKING_BLOCK };
  
   /* shared function between the packing and unpacking block
    * The purpose of this function is to set the error status appropriately if
    * a port datatype does not match up with the offset and factor.
    * The hope is that by keeping all of the error strings together in one place,
    * they will remain similar across both the packing and unpacking blocks */
   void setPortDataTypeErrorStatus(SimStruct*, int_T, PORT_DATATYPE_ERROR, CALLER_TYPE);

   /* check that the offset and factor are valid for a particular input / output 
    * port datatype.
    *
    * The PORT_DATATYPE_ERROR return value is one of the values in the enumeration
    * above. */
   PORT_DATATYPE_ERROR checkPortDataType(SimStruct *S, int_T port, DTypeId dataType);

   /* invert the scaling formula to calculate
    * the saturation points, so that we can guarentee
    * the result of the scaling calculation will fit in the
    * scaled value range.

    * Scaling formula :  sv = (input - offset) / factor
    *
    * Rewrite as: sv = (input / factor) - (offset / factor)
    *
    * sv = (input / factor) - C
    *
    * Invert: input = (sv + C) * factor
    *
    */
   void getRealInputMinMax(SimStruct *S, 
                           int idx, 
                           real64_T & min_real, 
                           real64_T & max_real,
                           real64_T & constantTerm,
                           int dtype);

   /* Given an input / output datatype, and signal index, the working datatype
    * for the calculation is derived and set in the reference parameter, workingDType.
    * 
    * The working datatype will be at least as wide as the input / output datatype.
    *
    */
   bool deriveWorkingDataType(SimStruct *S, int_T port, DTypeId portDataType, DTypeId & workingDType);
 
}
#endif

/* turn on | off debugging output */
//#define DEBUG_OUTPUT 

// Here the assumption is made that this Simulation code will never be run
// on a machine of word size less then 32 bits.
// This code will use a 32 bit word size.   It should execute fine on a
// 64 bit machine as 32 bit ops. will be allowed.
#define MESSAGE_WORD_SIZE 32

/* Store the scaled bit pattern in a 
 * uint32 (word size) ready for packing */
#define CANDB_BIT_PATTERN_DTYPE_SIZE 32
#define CANDB_BIT_PATTERN_DTYPE uint32_T

/* Signed word size datatype */
#define SIGNED_WORD_SIZE_DTYPE_ID SS_INT32

/* Unsigned word size datatype */
#define UNSIGNED_WORD_SIZE_DTYPE_ID SS_UINT32

/* max size of signal name we will copy */
#define SIGMAXLEN 50

typedef enum SIGNAL_TYPE { STANDARD=0, MODE, MODE_DEPENDANT };
typedef enum DATA_TYPE { SIGNED=0, UNSIGNED, FLOAT, DOUBLE };

enum { E_MESSAGE=0, P_NPARMS };

// NOTE: Below are C++ static inline functions which should be about as quick as a C Macro.

static inline uint32_T signedIntExtend(uint32_T input_uint, const uint8_T bit_len) {
   if (bit_len == MESSAGE_WORD_SIZE) {
      /* the uint32 contains a 32 bit value
       * no need to sign extend */
      return input_uint;
   }
   
   /* must mask off any top bits that may be set */
   input_uint = input_uint & (0xffffffff >> (MESSAGE_WORD_SIZE - bit_len));

	// sign extend the input value
   // Brad's code for sign extend...
	// check sign bit, then extend if necessary.
	if ((input_uint >> (bit_len - 1)) & 0x1){
          input_uint = ( 0xFFFFFFFF << bit_len ) | input_uint; 
	}
	return  input_uint;
}

/* Get the signal parameters property.
 *
 * S           -     SimStruct
 * idx         -     the signal number
 * prop        -     string representing the parameter
 *
 * */
// Leave this function definition here as static and inline cause problems.
static inline real64_T signalProp(SimStruct * S,const int idx, const char * prop){
   mxArray * field = mxGetField(ssGetSFcnParam(S,E_MESSAGE),0,"signals");
   if(field !=NULL){
      field = mxGetField(field,0,"signal");
      if(field !=NULL){
         field = mxGetField(field,idx,prop);
         if(field!=NULL){
            return mxGetScalar(field);
         }else{
            ssPrintf("%s was NULL\n",prop);
            return 0;
         }
      }else{
         ssPrintf("signal was NULL\n");
         return 0;
      }
   }else{
      ssPrintf("signals was NULL\n");
      return 0;
   }
}

/* Get the signal name
 *
 * S           -     SimStruct
 * idx         -     the signal number
 * str         -     char array to store the string
 * maxlen      -     maximum length of str
 *
 * */
// Leave this function definition here as static and inline cause problems.
static inline void signalName(SimStruct * S, const int idx, char * str, 
                              int maxlen){
   mxArray * field = mxGetField(ssGetSFcnParam(S,E_MESSAGE),0,"signals");
   field = mxGetField(field,0,"signal");
   field = mxGetField(field,idx,"name");
   mxGetString(field, str, maxlen);
}

/* dynamically sized user data class definition
 *
 * contains arrays for min, max,
 * constantTerm, apply_min, and apply_max
 *
 */
class UserData {
   public:
      /* constructor */
      UserData(int numSignals);
      /* destructor */
      ~UserData();

      /* Public fields */

      int mode_signal;
      /* minimum saturation points */ 
      real64_T * min;
      /* maximum saturation points */
      real64_T * max;
      /* constantTerms */
      real64_T * constantTerm;
      /* minimum saturation points applicable? */
      uint8_T * apply_min;
      /* maximum saturation points applicable? */
      uint8_T * apply_max;
};

#endif
