/*
 *  dsp_dtype_err.h
 *  Macros for common data type error checking for DSP Blockset.
 *
 * Functions to check the input and output port data type information
 * (BUILT-IN DTYPES ONLY).
 *
 * NOTE: This is query on the port dimension information. Therefore, 
 * the dimension information must already be set for the port.
 *
 *
 *  Copyright 1995-2002 The MathWorks, Inc.
 *  $Revision: 1.16 $ $Date: 2002/04/14 20:38:58 $
 */

#ifndef dsp_dtype_err_h
#define dsp_dtype_err_h

#include "dsp_dtype_sim.h"

/****************************************************/
/*         DEFAULT ERROR MESSAGES                   */
/****************************************************/

#define InputMustBeDouble           "Input must be double precision floating-point."
#define OutputMustBeDouble          "Output must be double precision floating-point."

#define InputMustNotBeDouble        "Input must not be double precision floating-point."
#define OutputMustNotBeDouble       "Output must not double precision floating-point."

#define InputMustBeSingle           "Input must be single precision floating-point."
#define OutputMustBeSingle          "Output must be single precision floating-point."

#define InputMustNotBeSingle        "Input must not be single precision floating-point."
#define OutputMustNotBeSingle       "Output must not be single precision floating-point."

#define InputMustBeUint8            "Input must be a uint8." 
#define OutputMustBeUint8           "Output must be a uint8." 

#define InputMustNotBeUint8         "Input must not be a uint8." 
#define OutputMustNotBeUint8        "Output must not be a uint8." 

#define InputMustBeUint16           "Input must be a uint16." 
#define OutputMustBeUint16          "Output must be a uint16." 

#define InputMustNotBeUint16        "Input must not be a uint16." 
#define OutputMustNotBeUint16       "Output must not be a uint16." 

#define InputMustBeUint32           "Input must be a uint32." 
#define OutputMustBeUint32          "Output must be a uint32." 

#define InputMustNotBeUint32        "Input must not be a uint32." 
#define OutputMustNotBeUint32       "Output must not be a uint32." 

#define InputMustBeInt8             "Input must be a int8." 
#define OutputMustBeInt8            "Output must be a int8." 

#define InputMustNotBeInt8          "Input must not be a int8." 
#define OutputMustNotBeInt8         "Output must not be a int8." 

#define InputMustBeInt16            "Input must be a int16." 
#define OutputMustBeInt16           "Output must be a int16." 

#define InputMustNotBeInt16         "Input must not be a int16." 
#define OutputMustNotBeInt16        "Output must not be a int16." 

#define InputMustBeInt32            "Input must be a int32." 
#define OutputMustBeInt32           "Output must be a int32." 

#define InputMustNotBeInt32         "Input must not be a int32." 
#define OutputMustNotBeInt32        "Output must not be a int32." 

#define InputMustBeBoolean          "Input must be a boolean." 
#define OutputMustBeBoolean         "Output must be a boolean." 

#define InputMustNotBeBoolean       "Input must not be a boolean." 
#define OutputMustNotBeBoolean      "Output must not be a boolean." 

#define InputMustBeFloat            "Input must be floating-point." 
#define OutputMustBeFloat           "Output must be floating-point." 

#define InputMustNotBeFloat         "Input must not be floating-point." 
#define OutputMustNotBeFloat        "Output must not be floating-point." 

#define AllIODtypesMustBeFloat      "All inputs and outputs must be floating-point."
#define AllIODtypesMustNotBeFloat   "All inputs and outputs must not be floating-point."

#define InputMustBeInteger          "Input must be an integer." 
#define OutputMustBeInteger         "Output must be an integer." 

#define InputMustNotBeInteger       "Input must not be an integer." 
#define OutputMustNotBeInteger      "Output must not be an integer." 

#define InputMustBeSignedInteger     "Input must be a signed integer." 
#define OutputMustBeSignedInteger    "Output must be a signed integer." 

#define InputMustNotBeSignedInteger  "Input must not be a signed integer." 
#define OutputMustNotBeSignedInteger "Output must not be a signed integer." 

#define InputMustBeUnsignedInteger     "Input must be an unsigned integer." 
#define OutputMustBeUnsignedInteger    "Output must be an unsigned integer." 

#define InputMustNotBeUnsignedInteger  "Input must not be an unsigned integer." 
#define OutputMustNotBeUnsignedInteger "Output must not be an unsigned integer." 

#define SignedDataTypesOnlyErrorStr    "Signed data types only. For fixed point, must have zero bias."

#define InAndOutDtypesMustNotBeSame  " Data Types must be different. "
#define InAndOutDtypesMustBeSame     " Data Types must be the same."

#define AllIODtypesMustNotBeSame     "Data types of all input and output ports must not be the same."
#define AllIODtypesMustBeSame        "Data types of all input and output ports must be the same."

/****************************************************/
/*              ERROR CHECKING                      */
/****************************************************/

/*            
 * ONE PORT I/O ERROR CHECKING:
 */

/***********************************************************/
/*  DOUBLE                                                 */
/***********************************************************/

#define ErrorIfInputIsNotDouble(S, port)                    \
    if (!isInputDouble(S, port)) {                          \
        THROW_ERROR(S, InputMustBeDouble);                  \
    }

#define ErrorIfOutputIsNotDouble(S, port)                   \
    if (!isOutputDouble(S, port)) {                         \
        THROW_ERROR(S, OutputMustBeDouble);                 \
    }

#define ErrorIfInputIsDouble(S, port)                       \
    if (isInputDouble(S, port)) {                           \
        THROW_ERROR(S, InputMustNotBeDouble);               \
    }

#define ErrorIfOutputIsDouble(S, port)                      \
    if (isOutputDouble(S, port)) {                          \
        THROW_ERROR(S, OutputMustNotBeDouble);              \
    }

/***********************************************************/
/*  SINGLE                                                 */
/***********************************************************/

#define ErrorIfInputIsNotSingle(S, port)                    \
    if (!isInputSingle(S, port)) {                          \
        THROW_ERROR(S, InputMustBeSingle);                  \
    }

#define ErrorIfOutputIsNotSingle(S, port)                   \
    if (!isOutputSingle(S, port)) {                         \
        THROW_ERROR(S, OutputMustBeSingle);                 \
    }

#define ErrorIfInputIsSingle(S, port)                       \
    if (isInputSingle(S, port)) {                           \
        THROW_ERROR(S, InputMustNotBeSingle);               \
    }

#define ErrorIfOutputIsSingle(S, port)                      \
    if (isOutputSingle(S, port)) {                          \
        THROW_ERROR(S, OutputMustNotBeSingle);              \
    }

/***********************************************************/
/*  UINT8                                                  */
/***********************************************************/

#define ErrorIfInputIsNotUint8(S, port)                     \
    if (!isInputUint8(S, port)) {                           \
        THROW_ERROR(S, InputMustBeUint8);                   \
    }

#define ErrorIfOutputIsNotUint8(S, port)                    \
    if (!isOutputUint8(S, port)) {                          \
        THROW_ERROR(S, OutputMustBeUint8);                  \
    }

#define ErrorIfInputIsUint8(S, port)                        \
    if (isInputUint8(S, port)) {                            \
        THROW_ERROR(S, InputMustNotBeUint8);                \
    }

#define ErrorIfOutputIsUint8(S, port)                       \
    if (isOutputUint8(S, port)) {                           \
        THROW_ERROR(S, OutputMustNotBeUint8);               \
    }

/***********************************************************/
/*  UINT16                                                 */
/***********************************************************/

#define ErrorIfInputIsNotUint16(S, port)                    \
    if (!isInputUint16(S, port)) {                          \
        THROW_ERROR(S, InputMustBeUint16);                  \
    }

#define ErrorIfOutputIsNotUint16(S, port)                   \
    if (!isOutputUint16(S, port)) {                         \
        THROW_ERROR(S, OutputMustBeUint16);                 \
    }

#define ErrorIfInputIsUint16(S, port)                       \
    if (isInputUint16(S, port)) {                           \
        THROW_ERROR(S, InputMustNotBeUint16);               \
    }

#define ErrorIfOutputIsUint16(S, port)                      \
    if (isOutputUint16(S, port)) {                          \
        THROW_ERROR(S, OutputMustNotBeUint16);              \
    }

/***********************************************************/
/*  UINT32                                                 */
/***********************************************************/

#define ErrorIfInputIsNotUint32(S, port)                    \
    if (!isInputUint32(S, port)) {                          \
        THROW_ERROR(S, InputMustBeUint32);                  \
    }

#define ErrorIfOutputIsNotUint32(S, port)                   \
    if (!isOutputUint32(S, port)) {                         \
        THROW_ERROR(S, OutputMustBeUint32);                 \
    }

#define ErrorIfInputIsUint32(S, port)                       \
    if (isInputUint32(S, port)) {                           \
        THROW_ERROR(S, InputMustNotBeUint32);               \
    }

#define ErrorIfOutputIsUint32(S, port)                      \
    if (isOutputUint32(S, port)) {                          \
        THROW_ERROR(S, OutputMustNotBeUint32);              \
    }

/***********************************************************/
/*  INT8                                                   */
/***********************************************************/

#define ErrorIfInputIsNotInt8(S, port)                      \
    if (!isInputInt8(S, port)) {                            \
        THROW_ERROR(S, InputMustBeInt8);                    \
    }

#define ErrorIfOutputIsNotInt8(S, port)                     \
    if (!isOutputInt8(S, port)) {                           \
        THROW_ERROR(S, OutputMustBeInt8);                   \
    }

#define ErrorIfInputIsInt8(S, port)                         \
    if (isInputInt8(S, port)) {                             \
        THROW_ERROR(S, InputMustNotBeInt8);                 \
    }

#define ErrorIfOutputIsInt8(S, port)                        \
    if (isOutputInt8(S, port)) {                            \
        THROW_ERROR(S, OutputMustNotBeInt8);                \
    }

/***********************************************************/
/*  INT16                                                  */
/***********************************************************/

#define ErrorIfInputIsNotInt16(S, port)                     \
    if (!isInputInt16(S, port)) {                           \
        THROW_ERROR(S, InputMustBeInt16);                   \
    }

#define ErrorIfOutputIsNotInt16(S, port)                    \
    if (!isOutputInt16(S, port)) {                          \
        THROW_ERROR(S, OutputMustBeInt16);                  \
    }

#define ErrorIfInputIsInt16(S, port)                        \
    if (isInputInt16(S, port)) {                            \
        THROW_ERROR(S, InputMustNotBeInt16);                \
    }

#define ErrorIfOutputIsInt16(S, port)                       \
    if (isOutputInt16(S, port)) {                           \
        THROW_ERROR(S, OutputMustNotBeInt16);               \
    }

/***********************************************************/
/*  INT32                                                  */
/***********************************************************/

#define ErrorIfInputIsNotInt32(S, port)                     \
    if (!isInputInt32(S, port)) {                           \
        THROW_ERROR(S, InputMustBeInt32);                   \
    }

#define ErrorIfOutputIsNotInt32(S, port)                    \
    if (!isOutputInt32(S, port)) {                          \
        THROW_ERROR(S, OutputMustBeInt32);                  \
    }

#define ErrorIfInputIsInt32(S, port)                        \
    if (isInputInt32(S, port)) {                            \
        THROW_ERROR(S, InputMustNotBeInt32);                \
    }

#define ErrorIfOutputIsInt32(S, port)                       \
    if (isOutputInt32(S, port)) {                           \
        THROW_ERROR(S, OutputMustNotBeInt32);               \
    }

/***********************************************************/
/*  BOOLEAN                                                */
/***********************************************************/

#define ErrorIfInputIsNotBoolean(S, port)                   \
    if (!isInputBoolean(S, port)) {                         \
        THROW_ERROR(S, InputMustBeBoolean);                 \
    }

#define ErrorIfOutputIsNotBoolean(S, port)                  \
    if (!isOutputBoolean(S, port)) {                        \
        THROW_ERROR(S, OutputMustBeBoolean);                \
    }

#define ErrorIfInputIsBoolean(S, port)                      \
    if (isInputBoolean(S, port)) {                          \
        THROW_ERROR(S, InputMustNotBeBoolean);              \
    }

#define ErrorIfOutputIsBoolean(S, port)                     \
    if (isOutputBoolean(S, port)) {                         \
        THROW_ERROR(S, OutputMustNotBeBoolean);             \
    }

/***********************************************************/
/*  FLOAT                                                  */
/***********************************************************/

#define ErrorIfInputIsNotFloat(S, port)                     \
    if (!isInputFloat(S, port)) {                           \
        THROW_ERROR(S, InputMustBeFloat);                   \
    }

#define ErrorIfOutputIsNotFloat(S, port)                    \
    if (!isOutputFloat(S, port)) {                          \
        THROW_ERROR(S, OutputMustBeFloat);                  \
    }

#define ErrorIfInputIsFloat(S, port)                        \
    if (isInputFloat(S, port)) {                            \
        THROW_ERROR(S, InputMustNotBeFloat);                \
    }

#define ErrorIfOutputIsFloat(S, port)                       \
    if (isOutputFloat(S, port)) {                           \
        THROW_ERROR(S, OutputMustNotBeFloat);               \
    }

#define ErrorIfAnyIOPortsAreNotFloat(S)                     \
    if (!allInputAndOutputDtypesFloat(S)) {                 \
        THROW_ERROR(S, AllIODtypesMustBeFloat);             \
    }

#define ErrorIfAnyIOPortsAreFloat(S)                        \
    if (anyInputOrOutputDtypesFloat(S)) {                   \
        THROW_ERROR(S, AllIODtypesMustNotBeFloat);          \
    }

/***********************************************************/
/*  INTEGER                                                */
/***********************************************************/

#define ErrorIfInputIsNotInteger(S, port)                   \
    if (!isInputInteger(S, port)) {                         \
        THROW_ERROR(S, InputMustBeInteger);                 \
    }

#define ErrorIfOutputIsNotInteger(S, port)                  \
    if (!isOutputInteger(S, port)) {                        \
        THROW_ERROR(S, OutputMustBeInteger);                \
    }

#define ErrorIfInputIsInteger(S, port)                      \
    if (isInputInteger(S, port)) {                          \
        THROW_ERROR(S, InputMustNotBeInteger);              \
    }

#define ErrorIfOutputIsInteger(S, port)                     \
    if (isOutputInteger(S, port)) {                         \
        THROW_ERROR(S, OutputMustNotBeInteger);             \
    }

#define ErrorIfInputIsNotSignedInteger(S, port)             \
    if (!isInputSignedInteger(S, port)) {                   \
        THROW_ERROR(S, InputMustBeSignedInteger);           \
    }

#define ErrorIfOutputIsNotSignedInteger(S, port)            \
    if (!isOutputSignedInteger(S, port)) {                  \
        THROW_ERROR(S, OutputMustBeSignedInteger);          \
    }

#define ErrorIfInputIsSignedInteger(S, port)                \
    if (isInputSignedInteger(S, port)) {                    \
        THROW_ERROR(S, InputMustNotBeSignedInteger);        \
    }

#define ErrorIfOutputIsSignedInteger(S, port)               \
    if (isOutputSignedInteger(S, port)) {                   \
        THROW_ERROR(S, OutputMustNotBeSignedInteger);       \
    }

#define ErrorIfInputIsNotUnsignedInteger(S, port)           \
    if (!isInputUnsignedInteger(S, port)) {                 \
        THROW_ERROR(S, InputMustBeUnsignedInteger);         \
    }

#define ErrorIfOutputIsNotUnsignedInteger(S, port)          \
    if (!isOutputUnsignedInteger(S, port)) {                \
        THROW_ERROR(S, OutputMustBeUnsignedInteger);        \
    }

#define ErrorIfInputIsUnsignedInteger(S, port)              \
    if (isInputUnsignedInteger(S, port)) {                  \
        THROW_ERROR(S, InputMustNotBeUnsignedInteger);      \
    }

#define ErrorIfOutputIsUnsignedInteger(S, port)             \
    if (isOutputUnsignedInteger(S, port)) {                 \
        THROW_ERROR(S, OutputMustNotBeUnsignedInteger);     \
    }

/***********************************************************/
/*  NEGATION SUPPORTED?                                    */
/***********************************************************/

#define ErrorIfInputDataTypeDoesNotSupportNegation(S, port)                                  \
    if (!(isInputPortSignedZeroBiasFixpt(S, port) || isInputFloatOrSignedInteger(S, port))) \
        THROW_ERROR(S, SignedDataTypesOnlyErrorStr);

#define ErrorIfOutputDataTypeDoesNotSupportNegation(S, port)                                  \
    if (!(isOutputPortSignedZeroBiasFixpt(S, port) || isOutputFloatOrSignedInteger(S, port))) \
        THROW_ERROR(S, SignedDataTypesOnlyErrorStr);


/***********************************************************/
/*  MULTIPLE PORT I/O ERROR CHECKING:                      */
/***********************************************************/

#define ErrorIfInAndOutDtypesSame(S, inport, outport) \
    if (inputAndOutputDtypesSame(S, inport, outport)) {   \
        char_T indx1[3]; \
        char_T indx2[3]; \
        char_T temp[128] = "Inport indexed "; \
        sprintf(indx1,"(%d)", inport); \
        sprintf(indx2,"(%d)", outport); \
        strcat(temp,indx1); \
        strcat(temp," and Outport indexed "); \
        strcat(temp,indx2); \
        strcat(temp,InAndOutDtypesMustNotBeSame); \
        THROW_ERROR(S,temp);     \
    }

#define ErrorIfInAndOutDtypesDiffer(S, inport, outport) \
    if (!inputAndOutputDtypesSame(S, inport, outport)) {   \
        char_T indx1[3]; \
        char_T indx2[3]; \
        char_T temp[128] = " For Inport: "; \
        sprintf(indx1,"(%d)", inport); \
        sprintf(indx2,"(%d)", outport); \
        strcat(temp,indx1); \
        strcat(temp," and Outport: "); \
        strcat(temp,indx2); \
        strcat(temp,InAndOutDtypesMustBeSame); \
        THROW_ERROR(S,temp);   \
    }

#define ErrorIfAllIOPortDtypesSame(S)             \
    if (allInputAndOutputDtypesSame(S)) {         \
        THROW_ERROR(S, AllIODtypesMustNotBeSame); \
    }

#define ErrorIfAnyIOPortDtypesDiffer(S)        \
    if (!allInputAndOutputDtypesSame(S)) {     \
        THROW_ERROR(S, AllIODtypesMustBeSame); \
    }

#endif  /* dsp_dtype_err_h */
/* [EOF] dsp_dtype_err.h */
