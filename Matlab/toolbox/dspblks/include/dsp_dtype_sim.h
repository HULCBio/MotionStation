/*
 * dsp_dtype_sim.h
 *
 * DSP Blockset helper function.
 *
 * Query input/output port data type information (BUILT-IN DTYPES ONLY).
 *
 *
 * Copyright 1995-2003 The MathWorks, Inc.
 * $Revision: 1.16.4.2 $ $Date: 2004/04/12 23:11:16 $
 */

#ifndef dsp_dtype_sim_h
#define dsp_dtype_sim_h

#include "simstruc.h"

#ifdef DSP_SIM_COMMON_EXPORTS
#define DSP_COMMON_SIM_EXPORT EXPORT_FCN
#else
#define DSP_COMMON_SIM_EXPORT extern
#endif


/*--------------------------------------------------------------
 * DYNAMICALLY_TYPED:
 */

/*******************************************************************************
 * FUNCTION isInputDynamicallyTyped
 *
 * DESCRIPTION: Check if an input port is dynamically typed (i.e. not yet set)
 *
 * INPUTS: S    - the block SimStruct
 *         port - the index of the input port to be checked
 *
 * RETURNS: boolean value
 *          (true -> input dynamically typed, false -> not dynamically typed)
 *
 * PRECONDITIONS: None
 *
 * POSTCONDITIONS: None
 *
 * OPERATION: Synchronous (operation completed upon function return)
 ******************************************************************************/
DSP_COMMON_SIM_EXPORT boolean_T isInputDynamicallyTyped(SimStruct *S, int_T port);

/*******************************************************************************
 * FUNCTION isOutputDynamicallyTyped
 *
 * DESCRIPTION: Check if an output port is dynamically typed (i.e. not yet set)
 *
 * INPUTS: S    - the block SimStruct
 *         port - the index of the output port to be checked
 *
 * RETURNS: boolean value
 *          (true -> output dynamically typed, false -> not dynamically typed)
 *
 * PRECONDITIONS: None
 *
 * POSTCONDITIONS: None
 *
 * OPERATION: Synchronous (operation completed upon function return)
 ******************************************************************************/
DSP_COMMON_SIM_EXPORT boolean_T isOutputDynamicallyTyped(SimStruct *S, int_T port);


/*--------------------------------------------------------------
 * DOUBLE:
 */

/*******************************************************************************
 * FUNCTION isInputDouble
 *
 * DESCRIPTION: Check if an input port type is double precision floating-point
 *
 * INPUTS: S    - the block SimStruct
 *         port - the index of the input port to be checked
 *
 * RETURNS: boolean value (true -> input double, false -> input not double)
 *
 * PRECONDITIONS: None
 *
 * POSTCONDITIONS: None
 *
 * OPERATION: Synchronous (operation completed upon function return)
 ******************************************************************************/
DSP_COMMON_SIM_EXPORT boolean_T isInputDouble(SimStruct *S, int_T port);

/*******************************************************************************
 * FUNCTION isOutputDouble
 *
 * DESCRIPTION: Check if an output port type is double precision floating-point
 *
 * INPUTS: S    - the block SimStruct
 *         port - the index of the output port to be checked
 *
 * RETURNS: boolean value (true -> output double, false -> output not double)
 *
 * PRECONDITIONS: None
 *
 * POSTCONDITIONS: None
 *
 * OPERATION: Synchronous (operation completed upon function return)
 ******************************************************************************/
DSP_COMMON_SIM_EXPORT boolean_T isOutputDouble(SimStruct *S, int_T port);


/*--------------------------------------------------------------
 * SINGLE:
 */

/*******************************************************************************
 * FUNCTION isInputSingle
 *
 * DESCRIPTION: Check if an input port type is single precision floating-point
 *
 * INPUTS: S    - the block SimStruct
 *         port - the index of the input port to be checked
 *
 * RETURNS: boolean value (true -> input single, false -> input not single)
 *
 * PRECONDITIONS: None
 *
 * POSTCONDITIONS: None
 *
 * OPERATION: Synchronous (operation completed upon function return)
 ******************************************************************************/
DSP_COMMON_SIM_EXPORT boolean_T isInputSingle(SimStruct *S, int_T port);

/*******************************************************************************
 * FUNCTION isOutputSingle
 *
 * DESCRIPTION: Check if an output port type is single precision floating-point
 *
 * INPUTS: S    - the block SimStruct
 *         port - the index of the output port to be checked
 *
 * RETURNS: boolean value (true -> output single, false -> output not single)
 *
 * PRECONDITIONS: None
 *
 * POSTCONDITIONS: None
 *
 * OPERATION: Synchronous (operation completed upon function return)
 ******************************************************************************/
DSP_COMMON_SIM_EXPORT boolean_T isOutputSingle(SimStruct *S, int_T port);


/*--------------------------------------------------------------
 * UINT8:
 */

/*******************************************************************************
 * FUNCTION isInputUint8
 *
 * DESCRIPTION: Check if an input port type is 8-bit unsigned integer
 *
 * INPUTS: S    - the block SimStruct
 *         port - the index of the input port to be checked
 *
 * RETURNS: boolean value (true -> input uint8, false -> input not uint8)
 *
 * PRECONDITIONS: None
 *
 * POSTCONDITIONS: None
 *
 * OPERATION: Synchronous (operation completed upon function return)
 ******************************************************************************/
DSP_COMMON_SIM_EXPORT boolean_T isInputUint8(SimStruct *S, int_T port);

/*******************************************************************************
 * FUNCTION isOutputUint8
 *
 * DESCRIPTION: Check if an output port type is 8-bit unsigned integer
 *
 * INPUTS: S    - the block SimStruct
 *         port - the index of the output port to be checked
 *
 * RETURNS: boolean value (true -> output uint8, false -> output not uint8)
 *
 * PRECONDITIONS: None
 *
 * POSTCONDITIONS: None
 *
 * OPERATION: Synchronous (operation completed upon function return)
 ******************************************************************************/
DSP_COMMON_SIM_EXPORT boolean_T isOutputUint8(SimStruct *S, int_T port);


/*--------------------------------------------------------------
 * UINT16:
 */

/*******************************************************************************
 * FUNCTION isInputUint16
 *
 * DESCRIPTION: Check if an input port type is 16-bit unsigned integer
 *
 * INPUTS: S    - the block SimStruct
 *         port - the index of the input port to be checked
 *
 * RETURNS: boolean value (true -> input uint16, false -> input not uint16)
 *
 * PRECONDITIONS: None
 *
 * POSTCONDITIONS: None
 *
 * OPERATION: Synchronous (operation completed upon function return)
 ******************************************************************************/
DSP_COMMON_SIM_EXPORT boolean_T isInputUint16(SimStruct *S, int_T port);

/*******************************************************************************
 * FUNCTION isOutputUint16
 *
 * DESCRIPTION: Check if an output port type is 16-bit unsigned integer
 *
 * INPUTS: S    - the block SimStruct
 *         port - the index of the output port to be checked
 *
 * RETURNS: boolean value (true -> output uint16, false -> output not uint16)
 *
 * PRECONDITIONS: None
 *
 * POSTCONDITIONS: None
 *
 * OPERATION: Synchronous (operation completed upon function return)
 ******************************************************************************/
DSP_COMMON_SIM_EXPORT boolean_T isOutputUint16(SimStruct *S, int_T port);


/*--------------------------------------------------------------
 * UINT32:
 */

/*******************************************************************************
 * FUNCTION isInputUint32
 *
 * DESCRIPTION: Check if an input port type is 32-bit unsigned integer
 *
 * INPUTS: S    - the block SimStruct
 *         port - the index of the input port to be checked
 *
 * RETURNS: boolean value (true -> input uint32, false -> input not uint32)
 *
 * PRECONDITIONS: None
 *
 * POSTCONDITIONS: None
 *
 * OPERATION: Synchronous (operation completed upon function return)
 ******************************************************************************/
DSP_COMMON_SIM_EXPORT boolean_T isInputUint32(SimStruct *S, int_T port);

/*******************************************************************************
 * FUNCTION isOutputUint32
 *
 * DESCRIPTION: Check if an output port type is 32-bit unsigned integer
 *
 * INPUTS: S    - the block SimStruct
 *         port - the index of the output port to be checked
 *
 * RETURNS: boolean value (true -> output uint32, false -> output not uint32)
 *
 * PRECONDITIONS: None
 *
 * POSTCONDITIONS: None
 *
 * OPERATION: Synchronous (operation completed upon function return)
 ******************************************************************************/
DSP_COMMON_SIM_EXPORT boolean_T isOutputUint32(SimStruct *S, int_T port);


/*--------------------------------------------------------------
 * INT8:
 */

/*******************************************************************************
 * FUNCTION isInputInt8
 *
 * DESCRIPTION: Check if an input port type is 8-bit signed integer
 *
 * INPUTS: S    - the block SimStruct
 *         port - the index of the input port to be checked
 *
 * RETURNS: boolean value (true -> input int8, false -> input not int8)
 *
 * PRECONDITIONS: None
 *
 * POSTCONDITIONS: None
 *
 * OPERATION: Synchronous (operation completed upon function return)
 ******************************************************************************/
DSP_COMMON_SIM_EXPORT boolean_T isInputInt8(SimStruct *S, int_T port);

/*******************************************************************************
 * FUNCTION isOutputInt8
 *
 * DESCRIPTION: Check if an output port type is 8-bit signed integer
 *
 * INPUTS: S    - the block SimStruct
 *         port - the index of the output port to be checked
 *
 * RETURNS: boolean value (true -> output int8, false -> output not int8)
 *
 * PRECONDITIONS: None
 *
 * POSTCONDITIONS: None
 *
 * OPERATION: Synchronous (operation completed upon function return)
 ******************************************************************************/
DSP_COMMON_SIM_EXPORT boolean_T isOutputInt8(SimStruct *S, int_T port);


/*--------------------------------------------------------------
 * INT16:
 */

/*******************************************************************************
 * FUNCTION isInputInt16
 *
 * DESCRIPTION: Check if an input port type is 16-bit signed integer
 *
 * INPUTS: S    - the block SimStruct
 *         port - the index of the input port to be checked
 *
 * RETURNS: boolean value (true -> input int16, false -> input not int16)
 *
 * PRECONDITIONS: None
 *
 * POSTCONDITIONS: None
 *
 * OPERATION: Synchronous (operation completed upon function return)
 ******************************************************************************/
DSP_COMMON_SIM_EXPORT boolean_T isInputInt16(SimStruct *S, int_T port);

/*******************************************************************************
 * FUNCTION isOutputInt16
 *
 * DESCRIPTION: Check if an output port type is 16-bit signed integer
 *
 * INPUTS: S    - the block SimStruct
 *         port - the index of the output port to be checked
 *
 * RETURNS: boolean value (true -> output int16, false -> output not int16)
 *
 * PRECONDITIONS: None
 *
 * POSTCONDITIONS: None
 *
 * OPERATION: Synchronous (operation completed upon function return)
 ******************************************************************************/
DSP_COMMON_SIM_EXPORT boolean_T isOutputInt16(SimStruct *S, int_T port);


/*--------------------------------------------------------------
 * INT32:
 */

/*******************************************************************************
 * FUNCTION isInputInt32
 *
 * DESCRIPTION: Check if an input port type is 32-bit signed integer
 *
 * INPUTS: S    - the block SimStruct
 *         port - the index of the input port to be checked
 *
 * RETURNS: boolean value (true -> input int32, false -> input not int32)
 *
 * PRECONDITIONS: None
 *
 * POSTCONDITIONS: None
 *
 * OPERATION: Synchronous (operation completed upon function return)
 ******************************************************************************/
DSP_COMMON_SIM_EXPORT boolean_T isInputInt32(SimStruct *S, int_T port);

/*******************************************************************************
 * FUNCTION isOutputInt32
 *
 * DESCRIPTION: Check if an output port type is 32-bit signed integer
 *
 * INPUTS: S    - the block SimStruct
 *         port - the index of the output port to be checked
 *
 * RETURNS: boolean value (true -> output int32, false -> output not int32)
 *
 * PRECONDITIONS: None
 *
 * POSTCONDITIONS: None
 *
 * OPERATION: Synchronous (operation completed upon function return)
 ******************************************************************************/
DSP_COMMON_SIM_EXPORT boolean_T isOutputInt32(SimStruct *S, int_T port);


/*--------------------------------------------------------------
 * BOOLEAN:
 */

/*******************************************************************************
 * FUNCTION isInputBoolean
 *
 * DESCRIPTION: Check if an input port type is boolean
 *
 * INPUTS: S    - the block SimStruct
 *         port - the index of the input port to be checked
 *
 * RETURNS: boolean value (true -> input boolean, false -> input not boolean)
 *
 * PRECONDITIONS: None
 *
 * POSTCONDITIONS: None
 *
 * OPERATION: Synchronous (operation completed upon function return)
 ******************************************************************************/
DSP_COMMON_SIM_EXPORT boolean_T isInputBoolean(SimStruct *S, int_T port);

/*******************************************************************************
 * FUNCTION isOutputBoolean
 *
 * DESCRIPTION: Check if an output port type is boolean
 *
 * INPUTS: S    - the block SimStruct
 *         port - the index of the output port to be checked
 *
 * RETURNS: boolean value (true -> output boolean, false -> output not boolean)
 *
 * PRECONDITIONS: None
 *
 * POSTCONDITIONS: None
 *
 * OPERATION: Synchronous (operation completed upon function return)
 ******************************************************************************/
DSP_COMMON_SIM_EXPORT boolean_T isOutputBoolean(SimStruct *S, int_T port);


/*--------------------------------------------------------------
 * FLOAT: Double and single
 */

/*******************************************************************************
 * FUNCTION isInputFloat
 *
 * DESCRIPTION: Check if an input port type is floating-point
 *              (i.e. double or single precision)
 *
 * INPUTS: S    - the block SimStruct
 *         port - the index of the input port to be checked
 *
 * RETURNS: boolean value (true -> input floating-point, false -> not float-pt)
 *
 * PRECONDITIONS: None
 *
 * POSTCONDITIONS: None
 *
 * OPERATION: Synchronous (operation completed upon function return)
 ******************************************************************************/
DSP_COMMON_SIM_EXPORT boolean_T isInputFloat(SimStruct *S, int_T port);

/*******************************************************************************
 * FUNCTION isOutputFloat
 *
 * DESCRIPTION: Check if an output port type is floating-point
 *              (i.e. double or single precision)
 *
 * INPUTS: S    - the block SimStruct
 *         port - the index of the output port to be checked
 *
 * RETURNS: boolean value (true -> output floating-point, false -> not float-pt)
 *
 * PRECONDITIONS: None
 *
 * POSTCONDITIONS: None
 *
 * OPERATION: Synchronous (operation completed upon function return)
 ******************************************************************************/
DSP_COMMON_SIM_EXPORT boolean_T isOutputFloat(SimStruct *S, int_T port);

/*******************************************************************************
 * FUNCTION isInputFloatOrSignedInteger
 *
 * DESCRIPTION: Check if an input port type is floating-point or signed int
 *
 * INPUTS: S    - the block SimStruct
 *         port - the index of the input port to be checked
 *
 * RETURNS: boolean value (true -> input floating-point or signed int, false -> not )
 *
 * PRECONDITIONS: None
 *
 * POSTCONDITIONS: None
 *
 * OPERATION: Synchronous (operation completed upon function return)
 ******************************************************************************/
DSP_COMMON_SIM_EXPORT boolean_T isInputFloatOrSignedInteger(SimStruct *S, int_T port);

/*******************************************************************************
 * FUNCTION isOutputFloatOrSignedInteger
 *
 * DESCRIPTION: Check if an output port type is floating-point or signed int
 *
 * INPUTS: S    - the block SimStruct
 *         port - the index of the output port to be checked
 *
 * RETURNS: boolean value (true -> output floating-point or signed int, false -> not )
 *
 * PRECONDITIONS: None
 *
 * POSTCONDITIONS: None
 *
 * OPERATION: Synchronous (operation completed upon function return)
 ******************************************************************************/
DSP_COMMON_SIM_EXPORT boolean_T isOutputFloatOrSignedInteger(SimStruct *S, int_T port);

/*--------------------------------------------------------------
 * INTEGER: All signed and unsigned integers (8,16,32)
 */

/*******************************************************************************
 * FUNCTION isInputInteger
 *
 * DESCRIPTION: Check if an input port type is any built-in integer type
 *              (i.e. int8, int16, int32, uint8, uint16, uint32)
 *
 * INPUTS: S    - the block SimStruct
 *         port - the index of the input port to be checked
 *
 * RETURNS: boolean value (true -> input is a built-in integer, false -> not)
 *
 * PRECONDITIONS: None
 *
 * POSTCONDITIONS: None
 *
 * OPERATION: Synchronous (operation completed upon function return)
 ******************************************************************************/
DSP_COMMON_SIM_EXPORT boolean_T isInputInteger(SimStruct *S, int_T port);

/*******************************************************************************
 * FUNCTION isOutputInteger
 *
 * DESCRIPTION: Check if an output port type is any built-in integer type
 *              (i.e. int8, int16, int32, uint8, uint16, uint32)
 *
 * INPUTS: S    - the block SimStruct
 *         port - the index of the output port to be checked
 *
 * RETURNS: boolean value (true -> output is a built-in integer, false -> not)
 *
 * PRECONDITIONS: None
 *
 * POSTCONDITIONS: None
 *
 * OPERATION: Synchronous (operation completed upon function return)
 ******************************************************************************/
DSP_COMMON_SIM_EXPORT boolean_T isOutputInteger(SimStruct *S, int_T port);

/*******************************************************************************
 * FUNCTION isInputSignedInteger
 *
 * DESCRIPTION: Check if an input port type is any built-in signed integer type
 *              (i.e. int8, int16, int32)
 *
 * INPUTS: S    - the block SimStruct
 *         port - the index of the input port to be checked
 *
 * RETURNS: boolean value (true -> input is a signed integer, false -> not)
 *
 * PRECONDITIONS: None
 *
 * POSTCONDITIONS: None
 *
 * OPERATION: Synchronous (operation completed upon function return)
 ******************************************************************************/
DSP_COMMON_SIM_EXPORT boolean_T isInputSignedInteger(SimStruct *S, int_T port);

/*******************************************************************************
 * FUNCTION isOutputSignedInteger
 *
 * DESCRIPTION: Check if an output port type is a built-in signed integer type
 *              (i.e. int8, int16, int32)
 *
 * INPUTS: S    - the block SimStruct
 *         port - the index of the output port to be checked
 *
 * RETURNS: boolean value (true -> output is built-in signed int, false -> not)
 *
 * PRECONDITIONS: None
 *
 * POSTCONDITIONS: None
 *
 * OPERATION: Synchronous (operation completed upon function return)
 ******************************************************************************/
DSP_COMMON_SIM_EXPORT boolean_T isOutputSignedInteger(SimStruct *S, int_T port);

/*******************************************************************************
 * FUNCTION isInputUnsignedInteger
 *
 * DESCRIPTION: Check if an input port type is a built-in unsigned integer type
 *              (i.e. uint8, uint16, uint32)
 *
 * INPUTS: S    - the block SimStruct
 *         port - the index of the input port to be checked
 *
 * RETURNS: boolean value (true -> input is a built-in uint, false -> not uint)
 *
 * PRECONDITIONS: None
 *
 * POSTCONDITIONS: None
 *
 * OPERATION: Synchronous (operation completed upon function return)
 ******************************************************************************/
DSP_COMMON_SIM_EXPORT boolean_T isInputUnsignedInteger(SimStruct *S, int_T port);

/*******************************************************************************
 * FUNCTION isOutputUnsignedInteger
 *
 * DESCRIPTION: Check if an output port type is a built-in unsigned integer type
 *              (i.e. uint8, uint16, uint32)
 *
 * INPUTS: S    - the block SimStruct
 *         port - the index of the output port to be checked
 *
 * RETURNS: boolean value (true -> output is a built-in uint, false -> not uint)
 *
 * PRECONDITIONS: None
 *
 * POSTCONDITIONS: None
 *
 * OPERATION: Synchronous (operation completed upon function return)
 ******************************************************************************/
DSP_COMMON_SIM_EXPORT boolean_T isOutputUnsignedInteger(SimStruct *S, int_T port);

/* getInputPortElementSize
 * 
 * Returns the number of bytes in one element of the input
 * It takes into consideration all the following:
 *  - data type  (double, single, etc)
 *  - complexity (real, complex)
 */
DSP_COMMON_SIM_EXPORT int_T getInputPortElementSize(SimStruct *S, int_T inport);

/* getInputPortBufferSize
 *
 * Returns the number of bytes in the input port buffer.
 * It takes into consideration all the following:
 *  - data type  (double, single, etc)
 *  - complexity (real, complex)
 *  - port width (total number of elements)
 */
DSP_COMMON_SIM_EXPORT int_T getInputPortBufferSize(SimStruct *S, int_T inport);

/* getOutputPortElementSize
 * 
 * Returns the number of bytes in one element of the output
 * It takes into consideration all the following:
 *  - data type  (double, single, etc)
 *  - complexity (real, complex)
 */
DSP_COMMON_SIM_EXPORT int_T getOutputPortElementSize(SimStruct *S, int_T outport);

/* getOutputPortBufferSize
 *
 * Returns the number of bytes in the output port buffer.
 * It takes into consideration all the following:
 *  - data type  (double, single, etc)
 *  - complexity (real, complex)
 *  - port width (total number of elements)
 */
DSP_COMMON_SIM_EXPORT int_T getOutputPortBufferSize(SimStruct *S, int_T outport);

/* Set (force) all input and/or output ports to same data type */
DSP_COMMON_SIM_EXPORT void assignAllInputPortDataTypes( SimStruct *S, DTypeId dataType);
DSP_COMMON_SIM_EXPORT void assignAllOutputPortDataTypes(SimStruct *S, DTypeId dataType);
DSP_COMMON_SIM_EXPORT void assignAllIoPortDataTypes(    SimStruct *S, DTypeId dataType);

/* Checks to see if the input and output datatypes are the same. 
 * If the datatype are the same, the function returns 1, else 0
 */
DSP_COMMON_SIM_EXPORT boolean_T inputAndOutputDtypesSame(SimStruct *S,int_T inport,int_T outport);

/* Checks to see if all input and output port datatypes are the same. 
 * If the datatypes are the same, the function returns 1, else 0
 */
DSP_COMMON_SIM_EXPORT boolean_T allInputAndOutputDtypesSame(SimStruct *S);

/* Checks to see if all input and output port datatypes are floating 
 * point. If so, the function returns 1, else 0
 */
DSP_COMMON_SIM_EXPORT boolean_T allInputAndOutputDtypesFloat(SimStruct *S);

/* Checks to see if any input or output port datatypes are floating 
 * point. If so, the function returns 1, else 0
 */
DSP_COMMON_SIM_EXPORT boolean_T anyInputOrOutputDtypesFloat(SimStruct *S);

/* 
 * Check and set all (input AND output) ports to float or double. No mixing allowed.
 */
DSP_COMMON_SIM_EXPORT boolean_T checkAndSetAllPortsToDblOrSngl(SimStruct *S, DTypeId dataTypeId);


/*
 * Routines for handling arbitrary data types in S-functions
 *
 *    negate_any_data_type(SimStruct *S, DTypeId dtId, void *u)
 *        u is a pointer to the data which is to be negated
 *
 *    conjugate_any_data_type(SimStruct *S, DTypeId dtId, void *u)
 *        u is a pointer to the data which is to be negated
 *
 */
DSP_COMMON_SIM_EXPORT void negate_any_data_type(SimStruct *S, DTypeId dtId,  void *u);
DSP_COMMON_SIM_EXPORT void conjugate_any_data_type(SimStruct *S, DTypeId dtId, void *u);

#endif /* dsp_dtype_sim_h */

/* [EOF] dsp_dtype_sim.h */
