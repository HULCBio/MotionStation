/*
 * dsp_fixpt_sim.h
 *
 * Simulation handling of Simulink fixed-point data types.
 *
 * This includes the following three general services:
 *
 * 1) Set input/output port fixed-point characteristics
 * 2) Get input/output port (or data type) fixed-point characteristics
 * 3) Query (check) i/o port (or data type) fixed-point characteristics
 *
 * Unless otherwise noted, all operations are SYNCHRONOUS (the function's
 * operation is completed upon return) and have no Pre- or Post-conditions.
 * 
 * Copyright 1995-2004 The MathWorks, Inc.
 * $Revision: 1.18.4.3 $ $Date: 2004/04/12 23:11:20 $
 */

#ifndef dsp_fixpt_sim_h
#define dsp_fixpt_sim_h

/* version.h indirectly includes tmwtypes.h
 * after compiler switch automagic
 */
#include "version.h"
#include "simstruc.h"

#ifdef DSP_SIM_COMMON_EXPORTS
#define DSP_COMMON_SIM_EXPORT EXPORT_FCN
#else
#define DSP_COMMON_SIM_EXPORT extern
#endif


typedef enum {
    SIGNED_NO = 0,
    SIGNED_YES
} SignedStat_T;

/* --------------------------------------------------- */
/* SECTION 1 - Fcns to SET fixed-point characteristics */
/* --------------------------------------------------- */

/*******************************************************************************
 * FUNCTION dspSetInputPortFixpt
 * FUNCTION dspSetOutputPortFixpt
 *
 * DESCRIPTION: Set an input or output port to a Simulink fixed-point data type
 *
 * INPUTS: S          - the block SimStruct
 *         portIdx    - the port index
 *         wordLength - the fixed-point integer word length
 *         fracLength - the fixed-point integer fraction length
 *         sgnStat    - the fixed-point signed status (SignedStat_T)
 *
 * RETURNS: none
 ******************************************************************************/
DSP_COMMON_SIM_EXPORT void dspSetInputPortFixpt(
    SimStruct   *S,
    int_T        portIdx,
    uint_T       wordLength,
    int_T        fracLength,
    SignedStat_T sgnStat
);

DSP_COMMON_SIM_EXPORT void dspSetOutputPortFixpt(
    SimStruct   *S,
    int_T        portIdx,
    uint_T       wordLength,
    int_T        fracLength,
    SignedStat_T sgnStat
);


/* --------------------------------------------------- */
/* SECTION 2 - Fcns to GET fixed-point characteristics */
/* --------------------------------------------------- */

/*******************************************************************************
 * FUNCTION dspGetFixPtDataTypeIDFromAttribs
 *
 * DESCRIPTION: Get the DTypeID corresponding to a set of fixed point attributes
 *
 * INPUTS: S          - the block SimStruct
 *         isSigned   - is this a signed data type?
 *         wordLength - total number of bits used to represent this quantity
 *         fracLength - number of fractional bits
 *
 * RETURNS: the Simulink data type identifier
 ******************************************************************************/
DSP_COMMON_SIM_EXPORT DTypeId dspGetFixPtDataTypeIDFromAttribs(SimStruct *S, boolean_T isSigned, uint_T         
                                                wordLength, int_T fracLength);

/*******************************************************************************
 * FUNCTION dspGetInputPortSignedStatus
 * FUNCTION dspGetOutputPortSignedStatus
 * FUNCTION dspGetDataTypeSignedStatus
 *
 * DESCRIPTION: Get the signed status of a SL port data type
 *
 * INPUTS: S          - the block SimStruct
 *         portIdx    - the port index
 *         dataTypeId - the Simulink data type identifier
 *
 * RETURNS: signed status (SIGNED_NO or SIGNED_YES)
 ******************************************************************************/
DSP_COMMON_SIM_EXPORT SignedStat_T dspGetInputPortSignedStatus( SimStruct *S, int_T portIdx);
DSP_COMMON_SIM_EXPORT SignedStat_T dspGetOutputPortSignedStatus(SimStruct *S, int_T portIdx);
DSP_COMMON_SIM_EXPORT SignedStat_T dspGetDataTypeSignedStatus(  SimStruct *S, DTypeId dataTypeId);

/*******************************************************************************
 * FUNCTION dspGetInputPortWordLength
 * FUNCTION dspGetOutputPortWordLength
 * FUNCTION dspGetDataTypeWordLength
 *
 * DESCRIPTION: Get the word length (in bits) of a SL port data type.
 *
 *              For fixed-point types, the size in bits of the integer
 *              representation is returned.
 *
 *              For non-fixed-point data types (including built-in types
 *              and custom data types), the size in bits is returned by
 *              computing "8 * ssGetDataTypeSize(S,dataTypeId)".
 *
 * INPUTS: S          - the block SimStruct
 *         portIdx    - the port index
 *         dataTypeId - the Simulink data type identifier
 *
 * RETURNS: word length of the port data type (in bits)
 ******************************************************************************/
DSP_COMMON_SIM_EXPORT uint_T dspGetInputPortWordLength( SimStruct *S, int_T portIdx);
DSP_COMMON_SIM_EXPORT uint_T dspGetOutputPortWordLength(SimStruct *S, int_T portIdx);
DSP_COMMON_SIM_EXPORT uint_T dspGetDataTypeWordLength(  SimStruct *S, DTypeId dataTypeId);

/*******************************************************************************
 * FUNCTION dspGetInputPortFracLength
 * FUNCTION dspGetOutputPortFracLength
 * FUNCTION dspGetDataTypeFracLength
 *
 * DESCRIPTION: Get the fraction length (number of bits in the fractional part)
 *              of a SL port data type.  For data types that are not pure integer
 *              or fixed-point, "0" is returned.
 *
 * INPUTS: S          - the block SimStruct
 *         portIdx    - the port index
 *         dataTypeId - the Simulink data type identifier
 *
 * RETURNS: fraction length of the port data type (in bits).
 *
 *          Note:
 *
 *          a) Negative fraction length values represent binary points
 *             located at a position less than the LSB (least significant bit),
 *             thus outside of the word boundaries (to the right of the LSB).
 *
 *          b) Non-negative fraction length values less than the word length
 *             represent binary points contained within the word.
 *
 *          c) Positive fraction length values greater than or equal to the
 *             word length represent binary points located at positions greater
 *             than the MSB (most significant bit), thus outside of the word
 *             boundaries (to the left of the MSB).
 ******************************************************************************/
DSP_COMMON_SIM_EXPORT int_T dspGetInputPortFracLength( SimStruct *S, int_T portIdx);
DSP_COMMON_SIM_EXPORT int_T dspGetOutputPortFracLength(SimStruct *S, int_T portIdx);
DSP_COMMON_SIM_EXPORT int_T dspGetDataTypeFracLength(  SimStruct *S, DTypeId dataTypeId);


/* ----------------------------------------------------- */
/* SECTION 3 - Fcns to QUERY fixed-point characteristics */
/* ----------------------------------------------------- */

/*******************************************************************************
 * FUNCTION anyInputOrOutputDtypesFixpt
 *
 * DESCRIPTION: Query for any SL fixed-point port data types
 *
 * INPUTS: S - the block SimStruct
 *
 * RETURNS: 1 (true)  if any I/O port data types are fixed-point
 *          0 (false) otherwise
 ******************************************************************************/
DSP_COMMON_SIM_EXPORT boolean_T anyInputOrOutputDtypesFixpt(SimStruct *S);

/*******************************************************************************
 * FUNCTION isInputPortCustomFloat
 * FUNCTION isOutputPortCustomFloat
 * FUNCTION isDataTypeCustomFloat
 *
 * DESCRIPTION: Query for SL custom floating-point port data type
 *
 * INPUTS: S          - the block SimStruct
 *         portIdx    - the port index
 *         dataTypeId - the Simulink data type identifier
 *
 * RETURNS: 1 (true) if port data type is a SL custom ("quantized")
 *                   floating-point data type (as defined by Fixed-Point Blockset)
 *
 *          0 (false) otherwise
 ******************************************************************************/
DSP_COMMON_SIM_EXPORT boolean_T isInputPortCustomFloat( SimStruct *S, int_T portIdx);
DSP_COMMON_SIM_EXPORT boolean_T isOutputPortCustomFloat(SimStruct *S, int_T portIdx);
DSP_COMMON_SIM_EXPORT boolean_T isDataTypeCustomFloat(  SimStruct *S, DTypeId dataTypeId);

/*******************************************************************************
 * FUNCTION isInputPortFixpt
 * FUNCTION isOutputPortFixpt
 * FUNCTION isDataTypeFixpt
 *
 * DESCRIPTION: Query for SL fixed-point port data type
 *
 * INPUTS: S          - the block SimStruct
 *         portIdx    - the port index
 *         dataTypeId - the Simulink data type identifier
 *
 * RETURNS: 1 (true)  if port data type is a SL fixed-point data type
 *          0 (false) otherwise
 *
 *          Note: a "fixed-point data type" is defined as a data type
 *          supported in simulation by the Fixed-Point Blockset for Simulink,
 *          categorized as a fixed-point datatype by the Fixed-Point Blockset,
 *          and treated as a fixed-point value for computation.
 *
 *          This includes only the following:
 *
 *          a) "sfix" types (signed fixed-point)
 *          b) "ufix" types (unsigned fixed-point)
 *          c) SL "built-in" integer types
 *             (i.e. int8, int16, int32, uint8, uint16, and uint32)
 *
 *          This DOES NOT include the following:
 *
 *          a) other SL "built-in" types (including double, single, boolean)
 *          b) custom floating-point types supported by the Fixed-Point Blockset
 *          c) floating-point overrides (flts) supported by the Fixed-Point Blockset
 *          d) other custom data types
 *
 ******************************************************************************/
DSP_COMMON_SIM_EXPORT boolean_T isInputPortFixpt( SimStruct *S, int_T portIdx);
DSP_COMMON_SIM_EXPORT boolean_T isOutputPortFixpt(SimStruct *S, int_T portIdx);
DSP_COMMON_SIM_EXPORT boolean_T isDataTypeFixpt(  SimStruct *S, DTypeId dataTypeId);

/*******************************************************************************
 * FUNCTION isInputPortSigned
 * FUNCTION isOutputPortSigned
 * FUNCTION isDataTypeSigned
 *
 * DESCRIPTION: Query for SL port data type signed status ("signed-ness")
 *
 * INPUTS: S          - the block SimStruct
 *         portIdx    - the port index
 *         dataTypeId - the Simulink data type identifier
 *
 * RETURNS: 1 (true)  if port data type is a signed data type
 *          0 (false) otherwise
 *
 * LIMITATIONS: return value for custom Simulink data types (other than the
 *              data types supported by the Fixed-Point Blockset) is undefined.
 ******************************************************************************/
DSP_COMMON_SIM_EXPORT boolean_T isInputPortSigned( SimStruct *S, int_T portIdx);
DSP_COMMON_SIM_EXPORT boolean_T isOutputPortSigned(SimStruct *S, int_T portIdx);
DSP_COMMON_SIM_EXPORT boolean_T isDataTypeSigned(  SimStruct *S, DTypeId dataTypeId);

/*******************************************************************************
 * FUNCTION isInputPortSignedFixpt
 * FUNCTION isOutputPortSignedFixpt
 * FUNCTION isDataTypeSignedFixpt
 *
 * DESCRIPTION: Query for SL port data type signed status ("signed-ness")
 *              AND fixed-point data type
 *
 * INPUTS: S          - the block SimStruct
 *         portIdx    - the port index
 *         dataTypeId - the Simulink data type identifier
 *
 * RETURNS: 1 (true)  if port data type is fixed-point AND signed
 *          0 (false) otherwise
 *
 * SEE ALSO: isDataTypeFixpt  (for definition of "fixed-point" data type)
 *           isDataTypeSigned (for limitations of this function)
 ******************************************************************************/
DSP_COMMON_SIM_EXPORT boolean_T isInputPortSignedFixpt( SimStruct *S, int_T portIdx);
DSP_COMMON_SIM_EXPORT boolean_T isOutputPortSignedFixpt(SimStruct *S, int_T portIdx);
DSP_COMMON_SIM_EXPORT boolean_T isDataTypeSignedFixpt(  SimStruct *S, DTypeId dataTypeId);

/*******************************************************************************
 * FUNCTION isInputPortUnsigned
 * FUNCTION isOutputPortUnsigned
 * FUNCTION isDataTypeUnsigned
 *
 * DESCRIPTION: Query for SL port data type signed status ("signed-ness")
 *
 * INPUTS: S          - the block SimStruct
 *         portIdx    - the port index
 *         dataTypeId - the Simulink data type identifier
 *
 * RETURNS: 1 (true)  if port data type is an unsigned data type
 *          0 (false) otherwise
 *
 * LIMITATIONS: return value for custom Simulink data types (other than the
 *              data types supported by the Fixed-Point Blockset) is undefined.
 ******************************************************************************/
DSP_COMMON_SIM_EXPORT boolean_T isInputPortUnsigned( SimStruct *S, int_T portIdx);
DSP_COMMON_SIM_EXPORT boolean_T isOutputPortUnsigned(SimStruct *S, int_T portIdx);
DSP_COMMON_SIM_EXPORT boolean_T isDataTypeUnsigned(  SimStruct *S, DTypeId dataTypeId);

/*******************************************************************************
 * FUNCTION isInputPortUnsignedFixpt
 * FUNCTION isOutputPortUnsignedFixpt
 * FUNCTION isDataTypeUnsignedFixpt
 *
 * DESCRIPTION: Query for SL port data type signed status ("signed-ness")
 *              AND fixed-point data type
 *
 * INPUTS: S          - the block SimStruct
 *         portIdx    - the port index
 *         dataTypeId - the Simulink data type identifier
 *
 * RETURNS: 1 (true)  if port data type is fixed-point AND unsigned
 *          0 (false) otherwise
 *
 * SEE ALSO: isDataTypeFixpt    (for definition of "fixed-point" data type)
 *           isDataTypeUnsigned (for limitations of this function)
 ******************************************************************************/
DSP_COMMON_SIM_EXPORT boolean_T isInputPortUnsignedFixpt( SimStruct *S, int_T portIdx);
DSP_COMMON_SIM_EXPORT boolean_T isOutputPortUnsignedFixpt(SimStruct *S, int_T portIdx);
DSP_COMMON_SIM_EXPORT boolean_T isDataTypeUnsignedFixpt(  SimStruct *S, DTypeId dataTypeId);

/*******************************************************************************
 * FUNCTION isInputPortUnitSlope
 * FUNCTION isOutputPortUnitSlope
 * FUNCTION isDataTypeUnitSlope
 *
 * DESCRIPTION: Query for SL port data type slope equivalent to 1.0
 *
 * INPUTS: S          - the block SimStruct
 *         portIdx    - the port index
 *         dataTypeId - the Simulink data type identifier
 *
 * RETURNS: 1 (true)  if port data type is NOT a fixed-point type
 *
 *          1 (true)  if port data type is a fixed-point type
 *                    AND has unit slope
 *
 *          0 (false) if port data type is a fixed-point type
 *                    AND does not have unit slope
 *
 * SEE ALSO: isDataTypeFixpt (for definition of "fixed-point" data type)
 ******************************************************************************/
DSP_COMMON_SIM_EXPORT boolean_T isInputPortUnitSlope( SimStruct *S, int_T portIdx);
DSP_COMMON_SIM_EXPORT boolean_T isOutputPortUnitSlope(SimStruct *S, int_T portIdx);
DSP_COMMON_SIM_EXPORT boolean_T isDataTypeUnitSlope(  SimStruct *S, DTypeId dataTypeId);

/*******************************************************************************
 * FUNCTION isInputPortUnitSlopeFixpt
 * FUNCTION isOutputPortUnitSlopeFixpt
 * FUNCTION isDataTypeUnitSlopeFixpt
 * FUNCTION isInputPortSignedUnitSlopeFixpt
 * FUNCTION isOutputPortSignedUnitSlopeFixpt
 * FUNCTION isDataTypeSignedUnitSlopeFixpt
 * FUNCTION isInputPortUnsignedUnitSlopeFixpt
 * FUNCTION isOutputPortUnsignedUnitSlopeFixpt
 * FUNCTION isDataTypeUnsignedUnitSlopeFixpt
 *
 * DESCRIPTION: Query for SL port data type slope equivalent to 1.0
 *              AND fixed-point data type
 *              AND other possible characteristics (e.g. signed/unsigned)
 *
 * INPUTS: S          - the block SimStruct
 *         portIdx    - the port index
 *         dataTypeId - the Simulink data type identifier
 *
 * RETURNS: 1 (true)  if ALL criteria true
 *          0 (false) otherwise
 *
 * SEE ALSO: isDataTypeFixpt (for definition of "fixed-point" data type)
 *           isDataTypeUnitSlope
 ******************************************************************************/
DSP_COMMON_SIM_EXPORT boolean_T isInputPortUnitSlopeFixpt(         SimStruct *S, int_T portIdx);
DSP_COMMON_SIM_EXPORT boolean_T isOutputPortUnitSlopeFixpt(        SimStruct *S, int_T portIdx);
DSP_COMMON_SIM_EXPORT boolean_T isDataTypeUnitSlopeFixpt(          SimStruct *S, DTypeId dataTypeId);
DSP_COMMON_SIM_EXPORT boolean_T isInputPortSignedUnitSlopeFixpt(   SimStruct *S, int_T portIdx);
DSP_COMMON_SIM_EXPORT boolean_T isOutputPortSignedUnitSlopeFixpt(  SimStruct *S, int_T portIdx);
DSP_COMMON_SIM_EXPORT boolean_T isDataTypeSignedUnitSlopeFixpt(    SimStruct *S, DTypeId dataTypeId);
DSP_COMMON_SIM_EXPORT boolean_T isInputPortUnsignedUnitSlopeFixpt( SimStruct *S, int_T portIdx);
DSP_COMMON_SIM_EXPORT boolean_T isOutputPortUnsignedUnitSlopeFixpt(SimStruct *S, int_T portIdx);
DSP_COMMON_SIM_EXPORT boolean_T isDataTypeUnsignedUnitSlopeFixpt(  SimStruct *S, DTypeId dataTypeId);

/*******************************************************************************
 * FUNCTION isInputPortZeroBias
 * FUNCTION isOutputPortZeroBias
 * FUNCTION isDataTypeZeroBias
 *
 * DESCRIPTION: Query for SL port data type bias equivalent to 0
 *
 * INPUTS: S          - the block SimStruct
 *         portIdx    - the port index
 *         dataTypeId - the Simulink data type identifier
 *
 * RETURNS: 1 (true)  if port data type is NOT a fixed-point type
 *
 *          1 (true)  if port data type is a fixed-point type
 *                    AND has zero bias
 *
 *          0 (false) if port data type is a fixed-point type
 *                    AND does not have zero bias
 *
 * SEE ALSO: isDataTypeFixpt (for definition of "fixed-point" data type)
 ******************************************************************************/
DSP_COMMON_SIM_EXPORT boolean_T isInputPortZeroBias( SimStruct *S, int_T portIdx);
DSP_COMMON_SIM_EXPORT boolean_T isOutputPortZeroBias(SimStruct *S, int_T portIdx);
DSP_COMMON_SIM_EXPORT boolean_T isDataTypeZeroBias(  SimStruct *S, DTypeId dataTypeId);

/*******************************************************************************
 * FUNCTION isInputPortZeroBiasFixpt
 * FUNCTION isOutputPortZeroBiasFixpt
 * FUNCTION isDataTypeZeroBiasFixpt
 * FUNCTION isInputPortSignedZeroBiasFixpt
 * FUNCTION isOutputPortSignedZeroBiasFixpt
 * FUNCTION isDataTypeSignedZeroBiasFixpt
 * FUNCTION isInputPortUnsignedZeroBiasFixpt
 * FUNCTION isOutputPortUnsignedZeroBiasFixpt
 * FUNCTION isDataTypeUnsignedZeroBiasFixpt
 *
 * DESCRIPTION: Query for SL port data type bias equivalent to 0
 *              AND fixed-point data type
 *              AND other possible characteristics (e.g. signed/unsigned)
 *
 * INPUTS: S          - the block SimStruct
 *         portIdx    - the port index
 *         dataTypeId - the Simulink data type identifier
 *
 * RETURNS: 1 (true)  if ALL criteria true
 *          0 (false) otherwise
 *
 * SEE ALSO: isDataTypeFixpt (for definition of "fixed-point" data type)
 *           isDataTypeZeroBias
 ******************************************************************************/
DSP_COMMON_SIM_EXPORT boolean_T isInputPortZeroBiasFixpt(         SimStruct *S, int_T portIdx);
DSP_COMMON_SIM_EXPORT boolean_T isOutputPortZeroBiasFixpt(        SimStruct *S, int_T portIdx);
DSP_COMMON_SIM_EXPORT boolean_T isDataTypeZeroBiasFixpt(          SimStruct *S, DTypeId dataTypeId);
DSP_COMMON_SIM_EXPORT boolean_T isInputPortSignedZeroBiasFixpt(   SimStruct *S, int_T portIdx);
DSP_COMMON_SIM_EXPORT boolean_T isOutputPortSignedZeroBiasFixpt(  SimStruct *S, int_T portIdx);
DSP_COMMON_SIM_EXPORT boolean_T isDataTypeSignedZeroBiasFixpt(    SimStruct *S, DTypeId dataTypeId);
DSP_COMMON_SIM_EXPORT boolean_T isInputPortUnsignedZeroBiasFixpt( SimStruct *S, int_T portIdx);
DSP_COMMON_SIM_EXPORT boolean_T isOutputPortUnsignedZeroBiasFixpt(SimStruct *S, int_T portIdx);
DSP_COMMON_SIM_EXPORT boolean_T isDataTypeUnsignedZeroBiasFixpt(  SimStruct *S, DTypeId dataTypeId);

/*******************************************************************************
 * FUNCTION isInputPortUnitSlopeZeroBiasFixpt
 * FUNCTION isOutputPortUnitSlopeZeroBiasFixpt
 * FUNCTION isDataTypeUnitSlopeZeroBiasFixpt
 * FUNCTION isInputPortSignedUnitSlopeZeroBiasFixpt
 * FUNCTION isOutputPortSignedUnitSlopeZeroBiasFixpt
 * FUNCTION isDataTypeSignedUnitSlopeZeroBiasFixpt
 * FUNCTION isInputPortUnsignedUnitSlopeZeroBiasFixpt
 * FUNCTION isOutputPortUnsignedUnitSlopeZeroBiasFixpt
 * FUNCTION isDataTypeUnsignedUnitSlopeZeroBiasFixpt
 *
 * DESCRIPTION: Query for SL port data type slope equivalent to 1.0
 *              AND for SL port data type bias equivalent to 0
 *              AND fixed-point data type
 *              AND other possible characteristics (e.g. signed/unsigned)
 *
 * INPUTS: S          - the block SimStruct
 *         portIdx    - the port index
 *         dataTypeId - the Simulink data type identifier
 *
 * RETURNS: 1 (true)  if ALL criteria true
 *          0 (false) otherwise
 *
 * SEE ALSO: isDataTypeFixpt (for definition of "fixed-point" data type)
 *           isDataTypeUnitSlope
 *           isDataTypeZeroBias
 ******************************************************************************/
DSP_COMMON_SIM_EXPORT boolean_T isInputPortUnitSlopeZeroBiasFixpt(         SimStruct *S, int_T portIdx);
DSP_COMMON_SIM_EXPORT boolean_T isOutputPortUnitSlopeZeroBiasFixpt(        SimStruct *S, int_T portIdx);
DSP_COMMON_SIM_EXPORT boolean_T isDataTypeUnitSlopeZeroBiasFixpt(          SimStruct *S, DTypeId dataTypeId);
DSP_COMMON_SIM_EXPORT boolean_T isInputPortSignedUnitSlopeZeroBiasFixpt(   SimStruct *S, int_T portIdx);
DSP_COMMON_SIM_EXPORT boolean_T isOutputPortSignedUnitSlopeZeroBiasFixpt(  SimStruct *S, int_T portIdx);
DSP_COMMON_SIM_EXPORT boolean_T isDataTypeSignedUnitSlopeZeroBiasFixpt(    SimStruct *S, DTypeId dataTypeId);
DSP_COMMON_SIM_EXPORT boolean_T isInputPortUnsignedUnitSlopeZeroBiasFixpt( SimStruct *S, int_T portIdx);
DSP_COMMON_SIM_EXPORT boolean_T isOutputPortUnsignedUnitSlopeZeroBiasFixpt(SimStruct *S, int_T portIdx);
DSP_COMMON_SIM_EXPORT boolean_T isDataTypeUnsignedUnitSlopeZeroBiasFixpt(  SimStruct *S, DTypeId dataTypeId);

/*******************************************************************************
 * FUNCTION isDataTypeNfracSignedUnitSlopeZeroBiasFixpt
 * FUNCTION isInputNfracSignedUnitSlopeZeroBiasFixpt
 * FUNCTION isOutputNfracSignedUnitSlopeZeroBiasFixpt
 * FUNCTION isDataTypeNfracUnsignedUnitSlopeZeroBiasFixpt
 * FUNCTION isInputNfracUnsignedUnitSlopeZeroBiasFixpt
 * FUNCTION isOutputNfracUnsignedUnitSlopeZeroBiasFixpt
 *
 * DESCRIPTION: Query for SL port data type slope equivalent to 1.0
 *              AND for SL port data type bias equivalent to 0
 *              AND fixed-point data type
 *              AND word length equal to wrdLen input parameter
 *              AND other possible characteristics (e.g. signed/unsigned)
 *
 * INPUTS: S          - the block SimStruct
 *         portIdx    - the port index
 *         dataTypeId - the Simulink data type identifier
 *         wrdLen     - word length (in bits)
 *
 * RETURNS: 1 (true)  if ALL criteria true
 *          0 (false) otherwise
 *
 * SEE ALSO: isDataTypeFixpt (for definition of "fixed-point" data type)
 *           isDataTypeUnitSlope
 *           isDataTypeZeroBias
 *           isDataTypeSigned
 *           isDataTypeUnsigned
 ******************************************************************************/
DSP_COMMON_SIM_EXPORT boolean_T isDataTypeNfracSignedUnitSlopeZeroBiasFixpt(  SimStruct *S, DTypeId dataTypeId, uint_T wrdLen);
DSP_COMMON_SIM_EXPORT boolean_T isInputNfracSignedUnitSlopeZeroBiasFixpt(     SimStruct *S, int_T portIdx,      uint_T wrdLen);
DSP_COMMON_SIM_EXPORT boolean_T isOutputNfracSignedUnitSlopeZeroBiasFixpt(    SimStruct *S, int_T portIdx,      uint_T wrdLen);
DSP_COMMON_SIM_EXPORT boolean_T isDataTypeNfracUnsignedUnitSlopeZeroBiasFixpt(SimStruct *S, DTypeId dataTypeId, uint_T wrdLen);
DSP_COMMON_SIM_EXPORT boolean_T isInputNfracUnsignedUnitSlopeZeroBiasFixpt(   SimStruct *S, int_T portIdx,      uint_T wrdLen);
DSP_COMMON_SIM_EXPORT boolean_T isOutputNfracUnsignedUnitSlopeZeroBiasFixpt(  SimStruct *S, int_T portIdx,      uint_T wrdLen);

/*
 * FUNCTION DSP_FIXPT_HS11_CheckandSetPortComplexity
 *
 * DESCRIPTION: Complexity propagation (forward and backward) for blocks that
 * that do floating point or fixed-point arithmetic. Unsigned fixed-point signals
 * must be real. Signed fixed-point signals can be either real or complex.
 * 
 * ASSUMES that there is exactly one input and exactly one output.
 *
 * INPUTS: S          - the block SimStruct
 *         port       - the port index
 *         portComplex- the input or output port complexity handed in to mdlSetXXputPortComplexSignal
 *         caller     - 0 for mdlSetInputPortComplexSignal
 *                      1 for mdlSetOutputPortComplexSignal
 *
 */
DSP_COMMON_SIM_EXPORT void DSP_FIXPT_HS11_CheckandSetPortComplexity(
    SimStruct *S,
    int_T      port,
    CSignal_T  portComplex,
    int_T      caller
    );

#endif /* dsp_fixpt_sim_h */

/* [EOF] dsp_fixpt_sim.h */
