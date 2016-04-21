/* 
 * dsp_ic_sim.h
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.12.4.2 $  $Date: 2004/04/12 23:11:24 $
 *
 * Abstract: Initial condition handler
 */

#ifndef DSP_IC_SIM_H
#define DSP_IC_SIM_H

#include "dsp_sim.h"

#ifdef __cplusplus
extern "C" {
#endif

#include "dsp_ic_rt.h" /* run-time IC support */

/* 
 * Function: CreateICRTPFromSFcnParam
 *
 * Abstract: Creates a run-time parameter to store ICs from
 *           an S-function input parameter.
 *
 * Inputs:
 *   RTPName 
 *     A string specifying the name of the to-be-created RTP.  This
 *     string is usually "IC" for uniformity across DSP Blockset S-fcns
 *     that use ICs.
 *   RTP_Index
 *     An integer index for the to-be-created RTP.
 *   Param_Index
 *     The integer index of the S-fcn IC parameter.
 *   outportNum
 *     The integer ID for the output port on which the ICs will
 *     eventually be output on.
 *
 * Functional spec:
 *   Given the datatype/complexity/size attributes of the specified
 *   output port, this function reads the IC elements from the
 *   specified S-function input parameter and formats them to "fit"
 *   the output port characteristics.  It then creates a run-time
 *   parameter for the formatted ICs and stores the formatted elements
 *   in the created RTP.
 *
 * Pre-conditions:  The following assumptions are made by this function.
 *   - The S-fcn IC parameter is stored in an mxArray.  This function
 *     will make calls to ssGetSFcnParam to obtain the IC elements
 *     from the given S-fcn parameter.
 *   - Any dimension matching/validation has been done prior to
 *     calling this function.
 *
 * Special case handling:
 *   - If the IC parameter contains an empty matrix [], this function
 *     will create a run-time parameter that holds a scalar zero 
 *     corresponding to the datatype and complexity of the output port.
 *
 * Error handling: This function will throw an error for the following
 *                 scenarios.
 *   - Output port is real-valued but IC parameter is complex-valued.
 *   - Allocation of RTP space failed.
 */
DSP_COMMON_SIM_EXPORT void CreateICRTPFromSFcnParam( SimStruct     *S,
                                      const char    *RTPName,
                                      int_T          RTP_Index,
                                      int_T          Param_Index,
                                      const int_T    outportNum );


/* 
 * Function: CreateICRTPFromMxArray
 *
 * Abstract: This function creates a run-time parameter to store IC
 *           info given an mxArray that contains the IC elements.
 *           Apart from the source of the IC elements, this function
 *           behaves in exactly the same manner as the function
 *           CreateICRTPFromSFcnParam, described above.
 *
 */
DSP_COMMON_SIM_EXPORT void CreateICRTPFromMxArray( SimStruct     *S,
                                    const char    *RTPName,
                                    int_T          RTP_Index,
                                    int_T          Param_Index,
                                    const mxArray *srcArray,
                                    const int_T    outportNum );


/* Function: validateICs
 *
 * Abstract: Rudimentary validation mechanism provides bare-bones
 *           checking of ICs given in a mxArray.
 *
 * Functional spec:
 *   This function throws an error in any of the following scenarios.
 *   - ICs are complex and output port is real-valued
 *   - ICs have dimensionality greater than 3
 *   - ICs are non-numeric.
 */
DSP_COMMON_SIM_EXPORT void validateICs( SimStruct     *S,
                         const mxArray *ICs,
                         const int_T    outputPortNum );


/* 
 * The following code provides initial-condition handling support
 * specifically for the Integer Delay, Variable Integer Delay,
 * and the Variable Fractional Delay blocks in the DSP Blockset.
 *
 */


typedef struct {
    MWDSP_DelayCopyICsArgs args;
    int_T                  fcnIdx;
} CopyICsCache;


DSP_COMMON_SIM_EXPORT void initCopyICsFcn(
    SimStruct     *S,
    CopyICsCache  *ic_cache,
    int_T          dworkNum,
    int_T          ICRTPIndex,
    int_T          portNum,
    int_T          nChans,
    int_T          fcnID
    );

#ifdef __cplusplus
}
#endif

#endif /* DSP_IC_SIM_H */

/* [EOF] dsp_ic_sim.h */
