/* 
 * dsp_rtp_sim.h : Run-time parameter support for the DSP Blockset
 *
 * Abstract: 
 *   This module contains support functions to assist S-functions with
 *   handling run-time parameters (RTPs) via the following operations:
 *
 *     - Creation of a run-time parameter
 *     - Accessing data and associated information from a specific RTP
 *     - Updating (tuning) data stored in a specific RTP 
 *     - De-allocating/destroying RTPs
 *
 * Copyright 1995-2003 The MathWorks, Inc.
 * $Revision: 1.20.4.2 $ $Date: 2004/04/12 23:11:32 $ 
 */
#ifndef dsp_rtp_sim_h
#define dsp_rtp_sim_h

#include "dsp_sim.h"

/* This module contains the following functions:
 * (NOTE: PLEASE UPDATE THIS LIST IF YOU ARE ADDING NEW FUNCTIONS!!)
 *
 * Creation functions:
 *
 *   CreateRTPDirectlyFromSFcnParam
 *   CreateRTPDerivedFromSFcnParams
 *   CreateRTPFromData
 *   RegisterRTPDerivedFromSFcnParams
 *   RegisterRTPFromData
 *
 * Update functions:
 *
 *   UpdateRTPDirectlyFromSFcnParam
 *   UpdateRTPDerivedFromSFcnParams
 *   UpdateRTPFromData
 *
 * Access functions:
 *
 *   GetRTPDataPtr
 *   GetRTPDTypeId
 *   GetRTPIsComplex
 *   GetRTPNumElements
 *   GetRTPNumDims
 *   GetRTPDimsInfo
 *   GetRTPNumIndices
 *   GetRTPIndicesPtr
 *
 * Destroy functions:
 *
 *   ParamRecFreeAll
 *
 */

/* --------------------------------------------------------------------------------
 *
 * Begin RTP Handler v2.0 functions here
 *
 * --------------------------------------------------------------------------------
 */

/* Functions to create/register RTPs: */

/* Functon: CreateRTPDirectlyFromSFcnParam
 *
 * Creates an RTP directly from data values in a specified S-function parameter.
 *
 * Arguments:
 *  SimStruct *S:
 *    Pointer to SimStruct, identifies client S-function.
 *
 *  SFcnParamIndex: 
 *    0-based integer index specifying S-function parameter, assumed to contain
 *    a numeric mxArray with source data values that need to be stored in an
 *    RTP.
 *
 *  RTPIndex:
 *    0-based integer index specifying RTP to be created.
 *
 *  RTPName:        
 *    quoted string literal name for created RTP, e.g. "COEFFS_RTP" This string
 *    must be unique in the first 4 characters compared to all other RTPs being
 *    registered/created by the calling S-function client.
 *
 *  RTPDataTypeID:
 *    Specifies datatype of RTP to be created.  If DYNAMICALLY_TYPED, RTP is
 *    created with the same equivalent Simulink datatype ID as the source
 *    data values.
 *
 *  RTPComplexity:
 *    Specifies complexity of the stored RTP data values.
 *    Choices are:
 *      COMPLEX_YES:
 *        Make the created RTP complex, always, even if extra imaginary zeroes
 *        of the right datatype have to be interleaved for the imaginary parts.
 *      COMPLEX_NO:
 *        Make the created RTP purely-real, always.  Error out if the source
 *        data value array is complex.
 *      COMPLEX_INHERITED:
 *        Make the created RTP have the same complexity as the source data.
 */
DSP_COMMON_SIM_EXPORT void CreateRTPDirectlyFromSFcnParam(
    SimStruct  *S,
    int_T       SFcnParamIndex,
    int_T       RTPIndex,
    const char *RTPName,
    DTypeId     RTPDataTypeID,
    CSignal_T   RTPComplexity
    );

/* Functon: CreateRTPDerivedFromSFcnParams
 *
 * Creates an RTP from data values.  These data values may have been derived
 * from a set of S-function input parameters.
 *
 * Arguments:
 *  SimStruct *S, RTPIndex, RTPName, RTPDataTypeID, RTPComplexity:
 *    Same definition as in CreateRTPDirectlyFromSFcnParam
 *
 *  srcDataPtr:
 *    Pointer to source data values array.  Cannot be NULL.
 *
 *  numSrcDataDims:
 *    Number of dimensions in source data values array.  Must be > 0.
 *
 *  srcDataDims[numSrcDataDims]:
 *    Pointer to array containing size of each dimension in source data array.
 *    Size of each dimension must be > 0.
 *
 *  srcDataTypeID:
 *    Data type of source data values.  Cannot be DYNAMICALLY_TYPED.
 *
 *  srcDataComplexity:
 *    Complexity of source data values.  Must be COMPLEX_YES or COMPLEX_NO.
 *
 *  numSFcnParams:
 *    Number of S-function parameters that the source data values were derived from.
 *    Can be 0.
 *
 *  SFcnParamIndices[numSFcnParams]:
 *    Pointer to array list of S-function parameters.
 *    Can be NULL only if numSFcnParams is 0.
 *
 */
DSP_COMMON_SIM_EXPORT void CreateRTPDerivedFromSFcnParams(
    SimStruct  *S,
    const void *srcDataPtr,
    int_T       numSrcDataDims,
    int_T      *srcDataDims,
    DTypeId     srcDataTypeID,
    CSignal_T   srcDataComplexity,
    int_T       numSFcnParams,
    int_T      *SFcnParamIndices,
    int_T       RTPIndex,
    const char *RTPName,
    DTypeId     RTPDataTypeID,
    CSignal_T   RTPComplexity
    );

/* Function: CreateRTPFromData
 *
 * Same as CreateRTPDerivedFromSFcnParams, except that the source data values are
 * assumed to be independent of any S-function parameter.
 * 
 * Equivalent to calling CreateRTPDerivedFromSFcnParams with:
 *   numSFcnParams = 0, SFcnParamIndices = NULL.
 *
 */
#define CreateRTPFromData(S,                 \
                          srcDataPtr,        \
                          numSrcDataDims,    \
                          srcDataDims,       \
                          srcDataTypeID,     \
                          srcDataComplexity, \
                          RTPIndex,          \
                          RTPName,           \
                          RTPDataTypeID,     \
                          RTPComplexity)     \
        CreateRTPDerivedFromSFcnParams((S),  \
            (srcDataPtr),                    \
            (numSrcDataDims),                \
            (srcDataDims),                   \
            (srcDataTypeID),                 \
            (srcDataComplexity),             \
            0,                               \
            NULL,                            \
            (RTPIndex),                      \
            (RTPName),                       \
            (RTPDataTypeID),                 \
            (RTPComplexity))


/* Function: RegisterRTPDerivedFromSFcnParams
 *
 * Same as CreateRTPDerivedFromSFcnParams, except that this function does not
 * create new memory to store the source data values.  Rather, the source data
 * values are assumed to be persistent and ready to be registered as RTP data
 * "as is".
 *
 * Arguments:
 *   Defined the same as their counterparts in CreateRTPDerivedFromSFcnParams.
 *
 */
DSP_COMMON_SIM_EXPORT void RegisterRTPDerivedFromSFcnParams(
    SimStruct  *S,
    const void *dataPtr,
    int_T       numDataDims,
    int_T      *dataDims,
    DTypeId     dataTypeID,
    CSignal_T   dataComplexity,
    int_T       numSFcnParams,
    int_T      *SFcnParamIndices,
    int_T       RTPIndex,
    const char *RTPName
    );

/* Function: RegisterRTPFromData
 *
 * Same as RegisterRTPDerivedFromSFcnParams, except that the RTP data values are
 * assumed to be independent of any S-function parameter.
 * 
 * Equivalent to calling RegisterRTPDerivedFromSFcnParams with:
 *   numSFcnParams = 0, SFcnParamIndices = NULL.
 *
 */
#define RegisterRTPFromData(S,              \
                            dataPtr,        \
                            numDataDims,    \
                            dataDims,       \
                            dataTypeID,     \
                            dataComplexity, \
                            RTPIndex,       \
                            RTPName)        \
        RegisterRTPDerivedFromSFcnParams(   \
            (S),                            \
            (dataPtr),                      \
            (numDataDims),                  \
            (dataDims),                     \
            (dataTypeID),                   \
            (dataComplexity),               \
            0,                              \
            NULL,                           \
            (RTPIndex),                     \
            (RTPName))


/* 
 * RTP tuning functions - the following functions can be used by the
 * calling S-function to update the parameter values for the stored
 * RTP.  
 *
 * These functions should be called in mdlProcessParameters since that
 * module will be called by Simulink if any of the parameters that the
 * associated RTPs depend on change during simulation.  These tuning
 * functions do not perform transformations, so it is imperative that
 * the transformations be computed before calling these tuning
 * functions.
 * 
 * WARNING: all of the following tuning functions assume that the only
 * aspect of the RTPs that change are the actual values contained, and
 * that all other attributes of the RTP stay the same.  That is, the
 * changed RTP will have the same datatype, complexity, number of
 * elements, number of dimensions, etc. as the old RTP, but with
 * possibly changed element values.  Segmentation violations could
 * result if the client S-function changes any other aspects of the
 * RTP.
 */
DSP_COMMON_SIM_EXPORT void UpdateRTPDirectlyFromSFcnParam(SimStruct *S, const int_T RTPIndex);

DSP_COMMON_SIM_EXPORT void UpdateRTPDerivedFromSFcnParams(
    SimStruct  *S,
    int_T       RTPIndex,
    const void *srcDataPtr,
    DTypeId     srcDataTypeID,
    CSignal_T   srcDataComplexity
    );

#define UpdateRTPFromData UpdateRTPDerivedFromSFcnParams

/* Old RTP tuning functions: potentially being obsoleted. */
#define TuneParamRecFromSFcnParam UpdateRTPDirectlyFromSFcnParam
#define TuneParamRecFromDataPtr(S, RTPIndex, newDataPtr) \
        UpdateRTPFromData((S), (RTPIndex), (newDataPtr), DYNAMICALLY_TYPED, COMPLEX_INHERITED)

DSP_COMMON_SIM_EXPORT void TuneParamRecFromMxArray(  SimStruct *S, const int_T RTPIndex, const mxArray *srcArray);

/* Functions to access RTP attributes */
/* 
 * RTP access functions - the following functions can be used by the
 * calling S-function to access data and associated information from a
 * created RTP specified by a valid integer RTP index:
 * - GetRTPDataPtr    : returns a pointer to the raw data in the specified RTP.
 * - GetRTPDTypeId    : returns the datatype ID for the specified RTP.
 * - GetRTPIsComplex  : returns the complexity of the specified RTP.
 * - GetRTPNumElements: returns the total number of elements in the specified RTP.
 * - GetRTPNumDims    : returns the number of dimensions in the specified RTP.
 * - GetRTPDimsInfo   : returns an array of dimensions info for the specific RTP.
 * - GetRTPNumIndices : returns the number of param indices involved in the 
 *                      creation of the specific RTP.
 * - GetRTPIndicesPtr : returns an array of param indices involved in the
 *                      creation of the specific RTP.
 */

/* Function: GetRTPDataPtr
 *   - returns a pointer to the raw data in the specified RTP.
 *   - if RTPIndex is invalid, function returns NULL, sets ErrorStatus.
 */
DSP_COMMON_SIM_EXPORT void *GetRTPDataPtr( SimStruct *S, const int_T RTPIndex );

/* Function: GetRTPDTypeId
 *   - returns the datatype ID for the specified RTP.
 *   - if RTPIndex is invalid, function returns INVALID_DTYPE_ID, sets ErrorStatus.
 */
DSP_COMMON_SIM_EXPORT DTypeId GetRTPDTypeId( SimStruct *S, const int_T RTPIndex );

/* Function: GetRTPIsComplex
 *   - returns the complexity of the specified RTP.
 *   - if RTPIndex is invalid, function returns COMPLEX_NO, sets ErrorStatus.
 */
DSP_COMMON_SIM_EXPORT boolean_T GetRTPIsComplex( SimStruct *S, const int_T RTPIndex );

/* Function: GetRTPNumElements
 *   - returns the total number of elements in the specified RTP.
 *   - if RTPIndex is invalid, function returns 0, sets ErrorStatus.
 */
DSP_COMMON_SIM_EXPORT int_T GetRTPNumElements( SimStruct *S, const int_T RTPIndex );

/* Function: GetRTPNumDims
 *   - returns the number of dimensions in the specified RTP.
 *   - if RTPIndex is invalid, function returns 0, sets ErrorStatus.
 */
DSP_COMMON_SIM_EXPORT int_T GetRTPNumDims( SimStruct *S, const int_T RTPIndex );

/* Function: GetRTPDimsInfo
 *   - returns an array of dimensions info for the specific RTP.
 *   - if RTPIndex is invalid, function returns NULL, sets ErrorStatus.
 */
DSP_COMMON_SIM_EXPORT int_T *GetRTPDimsInfo( SimStruct *S, const int_T RTPIndex );

/* Function: GetRTPNumIndices
 *   - returns the number of param indices involved in the creation of
 *     the specified RTP.
 *   - if RTPIndex is invalid, function returns 0, sets ErrorStatus.
 */
DSP_COMMON_SIM_EXPORT int_T GetRTPNumIndices( SimStruct *S, const int_T RTPIndex );

/* Function: GetRTPIndicesPtr
 *   - returns the an array of param indices involved in the creation of
 *     the specified RTP.
 *   - if RTPIndex is invalid, function returns NULL, sets ErrorStatus.
 */
DSP_COMMON_SIM_EXPORT int_T *GetRTPIndicesPtr( SimStruct *S, const int_T RTPIndex );


/* Functions to destroy RTPs */
/*
 * Function: ParamRecFreeAll
 *
 * Abstract: Frees previously allocated persistent memory used for RTPs
 *
 * Inputs:   SimStruct pointer S
 *
 * Functional spec:
 *   - Gets the total number of RTPs via a call to ssGetNumRunTimeParams
 *   - Looping over NumRunTimeParams, for each RTP(i):
 *       if data pointer of RTP(i) is not NULL, it is assumed that the
 *       memory pointed to by the data pointer has been previously
 *       allocated via calls to slCalloc.  So, this functions uses
 *       corresponding calls to slFree to free the RTP data pointer,
 *       then sets pointer to NULL.
 */
DSP_COMMON_SIM_EXPORT void ParamRecFreeAll(SimStruct *S);



/* Old pre-08/02 DSP Blockset RTP infrastructure begins here:
 *
 *
 * WARNING: SOME OF THE FOLLOWING FUNCTIONS ARE BEING OBSOLETED.
 * WARNING: SOME OF THE FOLLOWING FUNCTIONS ARE BEING OBSOLETED.
 * WARNING: SOME OF THE FOLLOWING FUNCTIONS ARE BEING OBSOLETED.
 * WARNING: SOME OF THE FOLLOWING FUNCTIONS ARE BEING OBSOLETED.
 * WARNING: SOME OF THE FOLLOWING FUNCTIONS ARE BEING OBSOLETED.
 * WARNING: SOME OF THE FOLLOWING FUNCTIONS ARE BEING OBSOLETED.
 * 
 * PLEASE USE THE FUNCTIONS LISTED ABOVE INSTEAD.
 */

/*
 * Background information and terminology:
 *   - Parameters:
 *       There are two types of parameters referred to in this module:
 *       1. S-function parameters: (aka simulation parameters)
 *            These are the parameters that are accepted by an
 *            S-function as input parameters for use during
 *            simulation.  These usually (but not always) correspond
 *            directly to equivalent mask dialog parameter fields,
 *            which the user then edits/modifies to specify data for
 *            each parameter.
 *
 *            For example, the FFT block has a "Twiddle-factor
 *            computation" parameter that allows the user to select
 *            which method gets used to compute the twiddle factors
 *            for that block.
 *
 *     2. Run-time parameters:
 *            These are parameters that are used during "run-time" by
 *            the code that gets generated for an S-function block
 *            using Real-Time Workshop (RTW).  Usually, in such
 *            situations, each block has an associated Target Language
 *            Compiler (TLC) file that contains the specifics of how
 *            the generated code is to be constructed.  However, the
 *            TLC file will not contain data values for parameters
 *            that get computed during simulation.
 *            
 *            For example, the TLC for the FFT block will not contain
 *            the specific values for the twiddle factors computed by
 *            the S-function.  Those twiddle factor values would be
 *            considered "run-time" parameters that the generated code
 *            needs to access and use.
 *
 *   - Run-time parameter handling:
 *       Given that S-functions compute and/or use certain parameters
 *       that the generated code would need to access during
 *       "run-time", it is desirable for the S-function to "pass" such
 *       run-time parameters to the generated code.  The mechanism by
 *       which Simulink and RTW coordinate the communication of
 *       run-time parameters from the S-function to the generated code
 *       is called run-time parameter handling.  For each parameter
 *       that needs to be "passed", information about the parameter
 *       needs to be specified in a parameter record structure.  For
 *       the purposes of this DSP Blockset-specific RTP handling
 *       support module, the parameter records maintained by
 *       Simulink/RTW can be considered to be independent storage
 *       areas.  This support module provides interface functions for
 *       DSP Blockset S-functions to access, create, destroy, and
 *       manage RTPs during simulation.
 *
 *   - Parameter Record structure (ParamRec)
 *       A parameter record is a structure designed to hold
 *       information about a run-time parameter.  In Simulink, this
 *       structure is called an 'ssParamRec' structure.  For a
 *       detailed listing of the various fields contained in an
 *       ssParamRec structure, see the help text for the Simulink
 *       function ssSetRunTimeParamInfo.  In this RTP helper module,
 *       the terms ParamRec and RTP are used interchangeably to mean a
 *       container for information about a run-time parameter.
 *
 */

/* 
 * -----------------------------------
 * INTERFACE FUNCTIONS IN THIS MODULE:
 * -----------------------------------
 * RTP creation functions:
 *   - CreateParamRecFromMxArray
 *   - CreateParamRecFromSFcnParam
 *   - CreateParamRecFromSFcnParamOfSLDType
 *   - CreateParamRecFromDataPtr
 * RTP de-allocation functions:
 *   - ParamRecFreeAll
 * RTP access functions:
 *   - GetParamRecData
 *   - GetRTPDataPtr
 *   - GetRTPDTypeId
 *   - GetRTPIsComplex
 *   - GetRTPNumElements
 *   - GetRTPNumDims
 *   - GetRTPDimsInfo
 *   - GetRTPNumIndices
 *   - GetRTPIndicesPtr
 * RTP update/tuning functions:
 *   - TuneParamRecFromMxArray
 *   - TuneParamRecFromSFcnParam
 *   - TuneParamRecFromDataPtr
 */

/* 
 * Run-time parameters have the following storage categories:
 * - RTP_ROM_STORAGE: for parameters that are non-tunable.
 *     Parameters stored in this category of storage are generally
 *     those that are considered to be "transformed" parameters.  A
 *     "transformed" parameter is defined as a parameter that has been
 *     obtained via a "transformation" applied to one or more input
 *     S-function parameters.  If the S-function input parameters
 *     involved in the creation of a "transformed" RTP change during
 *     simulation, the S-function would need to provide specific
 *     instructions on how to update the RTP accordingly in
 *     mdlProcessParameters (which is the S-function module that
 *     Simulink will call when parameters change during simulation).
 *     Hence, this category of RTP storage is called "ROM" or
 *     non-tunable storage because it is analogous to the parameter
 *     being "burned" into ROM during simulation.  Hence, parameters
 *     with this storage class cannot be changed (e.g. tuned via SL
 *     external mode) in the RTW generated code.
 *
 * - RTP_RAM_STORAGE: for parameters that are tunable.
 *     Parameters stored in this category are parameters that are
 *     directly obtained from an S-function input parameter without
 *     any intervening transformation involved.  In addition, these
 *     parameters may be tuned (e.g. via SL external mode) in the RTW
 *     generated code.
 */
typedef enum {
    RTP_RAM_STORAGE = RTPARAM_NOT_TRANSFORMED,
    RTP_ROM_STORAGE = RTPARAM_TRANSFORMED
} RTP_StorageClass;


/* 
 * RTP creation functions - the following functions can be used by the
 * calling S-function to create run-time parameter records:
 * - CreateParamRecFromMxArray
 * - CreateParamRecFromSFcnParam
 * - CreateParamRecFromSFcnParamOfSLDType
 * - CreateParamRecFromDataPtr
 */

/* 
 * Function: CreateParamRecFromMxArray
 *
 * Abstract: Creates a "transformed" RTP from specified data in an mxArray
 *
 * Inputs:
 *   array
 *     An mxArray containing data that is to be stored as a run-time
 *     parameter.  Specifically, it is assumed that the parameter data
 *     was created based on one or more S-function parameters.  That
 *     is, one or more S-function input parameters were "transformed"
 *     to create the run-time parameter to be stored.  Since the
 *     transformation process can be different for each parameter this
 *     implies that the created RTP is to be stored in
 *     RTP_ROM_STORAGE.
 *   
 *     If the parameter is to be tunable, make sure that the
 *     transformation process involved gets called in
 *     mdlProcessParameters, followed by a call to the tunability
 *     function TuneParamRecFromMxArray (described below).
 *   numDlgIndices
 *     The number of mask dialog parameters involved in the creation
 *     of the data to be stored in RTP.
 *   dlgIndices    
 *     A pointer to an array of indices.  Each index corresponds to
 *     a mask dialog parameter involved in the creation of the data
 *     in the given mxArray.
 *   RTPName
 *     A string holding the name of the to-be-created RTP.
 *   RTPIndex
 *     An integer index for the to-be-created RTP.
 *
 * Functional spec:
 *   - Creates a persistent memory block for RTP storage.  Be sure to use
 *     ParamRecFreeAll to free all allocated RTPs when done with them.
 *   - If the data in the given mxArray is complex, the data will be stored
 *     in the created RTP storage area with interleaved real and imaginary
 *     parts.  This corresponds to organization of complex-valued data in
 *     Simulink.
 *
 * Post-conditions:
 *   - If array is not null, persistent RTP storage is allocated and
 *     properly filled in with data elements.
 *   - If array is null, RTP data pointer is set to null.
 *
 * Error handling:
 *   - A call to THROW_ERROR will be made if allocation of persistent
 *     memory for RTP storage fails.  
 */
/* 
 * WARNING WARNING WARNING: THIS FUNCTION IS BEING OBSOLETED 
 * WARNING WARNING WARNING: THIS FUNCTION IS BEING OBSOLETED 
 * WARNING WARNING WARNING: THIS FUNCTION IS BEING OBSOLETED 
 */
DSP_COMMON_SIM_EXPORT void CreateParamRecFromMxArray(
    SimStruct     *S,
    const char    *RTPName,
    int_T            RTPIndex,
    int_T            numDlgIndices,
    int_T           *dlgIndices,
    const mxArray *array
    );

/* 
 * Function: CreateParamRecFromSFcnParam
 *           CreateParamRecFromSFcnParamOfSLDType
 *
 * Abstract: Creates a "non-transformed" RTP directly from data
 *           specified in a given S-function parameter.
 *           The CreateParamRecFromSFcnParam function stores the
 *           data with the same datatype as that of the mxArray
 *           from which the S-function parameter data was obtained.
 *           The CreateParamRecFromSFcnParamOfSLDType function has
 *           an additional input argument that allows you to
 *           explicitly specify the storage datatype.  The function
 *           will then convert the S-function parameter data 
 *           elements from their original datatype to the datatype
 *           specified prior to storage in RTP.
 *
 * Inputs:
 *   paramIdx
 *     The index of the S-function parameter to be stored in RTP.
 *     Since the data for the parameters is obtained directly from a
 *     single input S-function parameter, this is a parameter that
 *     is not "transformed".  
 *   
 *     The tunability of this parameter is now determined by settings
 *     made made by the S-function (that is, outside of this module).
 *     The S-function needs to explicitly specify, prior to calling
 *     this function, whether the S-function parameter associated with
 *     this RTP is tunable or not.  If the S-function parameter is
 *     tunable, this function will store the created RTP in
 *     RTP_RAM_STORAGE.  Otherwise, this function will store the
 *     created RTP in RTP_ROM_STORAGE.
 *
 *     If the parameter is tunable, make sure the S-function includes
 *     a call in mdlProcessParameters to the tuning function
 *     TuneParamRecFromSFcnParam (described below).
 *   RTPIndex
 *     The integer index of the to-be-created RTP.
 *   RTPName
 *     A string holding the name of the to-be-created RTP.
 *   RTPDatatype (if using CreateParamRecFromSFcnParamOfSLDType)
 *     The Simulink datatype ID of the to-be-created RTP.
 *
 * Functional spec:
 *   - Creates a persistent memory block for RTP storage.  Be sure to use
 *     ParamRecFreeAll to free all allocated RTPs when done with them.
 *   - If the data in the given parameter is complex, the data will be stored
 *     in the created RTP storage area with interleaved real and imaginary
 *     parts.
 *
 * Pre-conditions: 
 *   - Tunability of S-fcn parameter paramIdx assumed to have been 
 *     explicitly specified prior to calling this function.
 *
 * Error handling:
 *   - a call to THROW_ERROR will be made if allocation of persistent
 *     memory for RTP storage fails.  
 */
/* 
 * WARNING WARNING WARNING: THIS FUNCTION IS BEING OBSOLETED 
 * WARNING WARNING WARNING: THIS FUNCTION IS BEING OBSOLETED 
 * WARNING WARNING WARNING: THIS FUNCTION IS BEING OBSOLETED 
 */
DSP_COMMON_SIM_EXPORT void CreateParamRecFromSFcnParam(
    SimStruct  *S,
    const char *RTPName,
    int_T       RTPIndex,
    int_T       paramIdx
    );

/* 
 * WARNING WARNING WARNING: THIS FUNCTION IS BEING OBSOLETED 
 * WARNING WARNING WARNING: THIS FUNCTION IS BEING OBSOLETED 
 * WARNING WARNING WARNING: THIS FUNCTION IS BEING OBSOLETED 
 */
DSP_COMMON_SIM_EXPORT void CreateParamRecFromSFcnParamOfSLDType(
    SimStruct  *S,
    const char *RTPName,
    int_T       RTPIndex,
    int_T       paramIdx,
    DTypeId     RTPDatatype
    );

/*
 * Public function CreateRTPFromSFcnParamOfSLDType
 *
 * this function is essentially similar to CreateParamRecFromSFcnParamOfSLDType, with only one difference
 * that the complexity of RTP is one of the input parameters to this function. So, the caller of this 
 * function can create an RTP of output datatype , or specify it to be COMPLEX_NO (real only) always. 
 * So if the last argument is  boolean 1, then we inherit the complexity from the output port, otherwise
 * we always declare the RTP to be of "real" datatype. 
 * The CreateParamRecFromSFcnParamOfSLDType() function should be replaced by this function
 * everywhere, with an added argument. 
 */

/* 
 * WARNING WARNING WARNING: THIS FUNCTION IS BEING OBSOLETED 
 * WARNING WARNING WARNING: THIS FUNCTION IS BEING OBSOLETED 
 * WARNING WARNING WARNING: THIS FUNCTION IS BEING OBSOLETED 
 */
DSP_COMMON_SIM_EXPORT void CreateRTPFromSFcnParamOfSLDType(
    SimStruct  *S,
    const char *RTPName,
    int_T       RTPIndex,
    int_T       paramIdx,
    DTypeId     RTPDatatype, 
    boolean_T   inheritCplxtFrmPort
    );

/*
 * Function: CreateParamRecFromDataPtr
 *
 * Abstract: Creates a "transformed" RTP given data that is of a
 *           Simulink datatype (as opposed to a mxArray MATLAB
 *           datatype).  The data itself is assumed to be in a
 *           contiguous memory area pointed to by the input dataPtr.
 *           Information about the data, such as complexity, number of
 *           elements, etc., is encapusulated and passed in via a
 *           mxArray called infoArray.  The Simulink datatype for the
 *           data is specified by the StorageDTypeId parameter.
 *
 * Inputs:
 *   dataPtr 
 *     A pointer to a memory area containing contiguous bytes of
 *     data to be stored in RTP.  It is assumed that if the data is
 *     complex it already has its real and imaginary parts
 *     interleaved.
 *     
 *     If the created RTP is to be tunable, make sure the process
 *     involved in creating the data pointer gets called in
 *     mdlProcessParameters, followed by a call to the tuning function
 *     TuneParamRecFromDataPtr (described below).
 *   infoArray 
 *     A mxArray that holds the following information about the data
 *     to be stored in RTP:
 *       - complexity (mxCOMPLEX or mxREAL)
 *       - numDims    (the number of dimensions)
 *       - *dimsInfo  (an array holding dimensions information)
 *     NOTE: No other fields of the mxArray need be specified.
 *   StorageDTypeId
 *     The Simulink datatype ID for the data to be stored.
 *   numDialogIndices 
 *     The number of mask dialog parameters involved in the creation
 *     of the data to be stored in RTP.
 *   dialogIndices 
 *     A pointer to an array of indices.  Each index corresponds to
 *     a mask dialog parameter involved in the creation of the data
 *     in the given mxArray.
 *   RTPName
 *     A string holding the name of the to-be-created RTP.
 *   RTPIndex
 *     An integer index for the to-be-created RTP.
 *
 * Functional spec:
 *   Creates a persistent memory block for RTP storage.  Be sure to use
 *   ParamRecFreeAll to free all allocated RTPs when done with them.
 *
 * Error handling:
 *   A call to THROW_ERROR will be made if allocation of persistent
 *   memory for RTP storage fails.  
 */
/* 
 * WARNING WARNING WARNING: THIS FUNCTION IS BEING OBSOLETED 
 * WARNING WARNING WARNING: THIS FUNCTION IS BEING OBSOLETED 
 * WARNING WARNING WARNING: THIS FUNCTION IS BEING OBSOLETED 
 */
DSP_COMMON_SIM_EXPORT void CreateParamRecFromDataPtr(
    SimStruct     *S,
    const char    *RTPName,
    int_T            RTPIndex,
    int_T            numDialogIndices,
    int_T           *dialogIndices,
    const mxArray *infoArray,
    const void    *dataPtr,
    const DTypeId  storageDTypeId
    );

/* Function GetParamRecData
 *   - returns a pointer to the raw data in the specified RTP.
 *   - if RTPIndex is invalid, function returns NULL, sets ErrorStatus.
 */
/* 
 * WARNING WARNING WARNING: THIS FUNCTION IS BEING OBSOLETED 
 * WARNING WARNING WARNING: THIS FUNCTION IS BEING OBSOLETED 
 * WARNING WARNING WARNING: THIS FUNCTION IS BEING OBSOLETED 
 */
DSP_COMMON_SIM_EXPORT void *GetParamRecData( SimStruct *S, const int_T RTPIndex );


/* 
 * WARNING WARNING WARNING: THIS FUNCTION IS BEING OBSOLETED 
 * WARNING WARNING WARNING: THIS FUNCTION IS BEING OBSOLETED 
 * WARNING WARNING WARNING: THIS FUNCTION IS BEING OBSOLETED 
 */
DSP_COMMON_SIM_EXPORT void CreateCmplxRTPFromSFcnParamOfSLDType(SimStruct *S, const char *RTPName,
                                int_T RTPIndex, int_T paramIdx, DTypeId RTPDatatype);



#endif  /* dsp_rtp_sim_h */

/* [EOF] dsp_rtp_sim.h */
