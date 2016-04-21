/*
 *  dsp_dtype_convert_sim.h
 *  Data type conversion helper functions for Simulink S-functions
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.4.4.2 $ $Date: 2004/04/12 23:11:14 $
 */

#ifndef dsp_dtype_convert_sim_h
#define dsp_dtype_convert_sim_h

#include "dsp_sim.h"

#ifdef __cplusplus
extern "C" {
#endif

/* Obtain closest "equivalent" Simulink datatype ID for the datatype stored
 * in the given mxArray.  If the datatype stored in the mxArray does not match
 * with a valid Simulink datatype the function returns INVALID_DTYPE_ID
 * (defined in simstruc.h)
 */
DSP_COMMON_SIM_EXPORT DTypeId getDTypeIdFromMxArray(const mxArray *mxArrayPtr);

/* Obtain closest "equivalent" MATLAB data type ID for given Simulink data type ID */
DSP_COMMON_SIM_EXPORT mxClassID convertSLTypetoMLType(BuiltInDTypeId SL_dtype);

/* Converts an mxArray from its original data type to a new one */
DSP_COMMON_SIM_EXPORT void convertMxArrayToNewDataType(
    SimStruct *S,
    mxArray *outArray[],
    const mxArray *inArray[],
    mxClassID newDType
    );

/*
 * Function: CreateNewDataPtrFromMxArray
 *
 * Abstract: 
 *
 *     This function will accept a pointer to a mxArray (srcArray),
 *     convert each element stored in srcArray to the Simulink
 *     datatype specified by dstDTypeId, and store the resulting
 *     converted elements in a contiguous memory area.  Interleaving
 *     of real and imaginary parts will be done automatically if the
 *     srcArray contains complex data.  The function returns the
 *     starting address of the allocated memory area.  This function
 *     will allocate the memory required via calls to slMalloc.
 *     Therefore, the allocated memory will be persistent and should
 *     be deallocated by calls to slFree by the calling function when
 *     the memory area is no longer needed.
 *
 * Inputs:
 *     SimStruct *S
 *       The floating SimStruct from the calling S-function
 *     const mxArray *srcArray
 *       An mxArray that contains data elements which can be complex
 *       or real-valued.  In the case of the mxArray containing zero
 *       elements (mxGetNumberOfElements returns zero), it is assumed
 *       that the mxArray represents an empty matrix.  The spec
 *       description below describes how this function will handle an
 *       empty matrix in srcArray.
 *     const DTypeId dstDType
 *       The DTypeId for the datatype to which the srcArray elements
 *       will be converted.
 *
 * Returns:
 *     a void pointer pointing to the starting address of the converted
 *     elements.
 *
 * Functional spec:
 *     Datatype conversion:
 *     - It is assumed that the input mxArray has data elements that
 *       are stored as datatypes compatible with Simulink's built-in
 *       datatypes.  This function will call the datatype
 *       identification helper function getDTypeIdFromMxArray (defined
 *       in dsp_sfcn_param_sim.h) to obtain the SL-equivalent
 *       DTypeId value from the mxArray.  If the returned DTypeId
 *       value is equal to INVALID_DTYPE_ID, this function will
 *       throw an error.
 *     - Type conversion will occur only if the SL-equivalent
 *       datatype stored in the source mxArray does *not* match the
 *       destination datatype.  In that event, this function will
 *       call the convertBetween function registered for the output
 *       port datatype to convert from the SL-equivalent built-in
 *       datatype that the source elements are stored as in srcArray.
 *       It is assumed that the convertBetween function registered
 *       for the destination datatype can handle conversions from
 *       all Simulink built-in datatypes.
 *     Complexity handling:
 *     - If srcArray contains complex data, the returned pointer will
 *       point to a memory area where the elements are stored in an
 *       interleaved manner, paired off in real and imaginary parts
 *       respectively.
 *     Special case handling:
 *     - Empty mxArray:
 *       - For the case where the input srcArray holds an empty
 *         matrix, it is assumed that mxGetNumberOfElements returns
 *         zero.  In this case, the function will obtain the zero
 *         representation for the destination datatype and return
 *         that representation.  A check for complexity will not be
 *         done because it is assumed that srcArray = [] translates
 *         to srcArray holding a scalar real-valued zero.  Therefore
 *         no interleaving will be done.
 *     - It is assumed that the input mxArray will have numElems >= 0.
 *     Error handling:
 *       This function will throw an error in the following situations:
 *       - destination data type      == INVALID_DTYPE_ID
 *       - mxArray data type          == INVALID_DTYPE_ID
 *       - destination data type size == INVALID_DTYPE_SIZE
 *       - any slMalloc returns a NULL pointer 
 */
DSP_COMMON_SIM_EXPORT void *CreateNewDataPtrFromMxArray( SimStruct      *S,
                                          const mxArray  *srcArray,
                                          const DTypeId   dstDType );


/*
 * Function: ConvertInputSignalToDouble
 *
 * Abstract: Converts each element of the input signal on the specified
 *           input port to a double-precision floating point element.
 *           Allocates contiguous data storage for the resulting converted
 *           elements.  Be sure to free the allocated space when the client
 *           function is finished with using the elements.
 * 
 * Inputs:
 *   inPortNum
 *     The integer port number for the input port to be converted.
 *
 * Returns: 
 *   a void pointer pointing to the starting address of the newly
 *   allocated memory area that contains the converted input signal
 *   elements.
 *
 * Functional spec:
 *   This function makes an underlying call to the ConvertBetween function
 *   for the input port datatype to convert each element to an SS_DOUBLE
 *   type element.  This function allocates space equal to the number of
 *   input elements (equal to the input port width if the input is real-valued
 *   or twice the port width otherwise).  The memory allocation is performed
 *   regardless of whether the input port is already of type SS_DOUBLE, so be
 *   sure to call this function only if you absolutely need to.  Typical usage
 *   of this function would be:
 *
 *   {
 *     if (ssGetInputPortDataType(S, INPORT) != SS_DOUBLE) {
 *       const void *u = (const void *) ConvertInputSignalToDouble(S, INPORT);
 *     } else {
 *       const void *u = ssGetInputPortSignal(S, INPORT);
 *     }
 *     .
 *     .
 *     .
 *     if (ssGetInputPortDataType(S, INPORT) != SS_DOUBLE) {
 *       slFree(u);
 *     }
 *   }
 * 
 */
#define ConvertInputSignalToDouble(S,inPortNum) _convertInputSignalToDouble(S,inPortNum,ssGetInputPortSignal(S,inPortNum))
DSP_COMMON_SIM_EXPORT void* _convertInputSignalToDouble( SimStruct *S, const int_T inPortNum, const void* inputSignalPtr);


#ifdef __cplusplus
}
#endif

#endif  /* dsp_dtype_convert_sim_h */

/* [EOF] dsp_dtype_convert_sim.h */
