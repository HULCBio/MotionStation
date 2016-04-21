/*
 * dsp_mtrx_sim.h
 *
 * DSP Blockset helper function.
 *
 * Query input/output port dimension and frame information. 
 *
 *
 * Copyright 1995-2003 The MathWorks, Inc.
 * $Revision: 1.9.4.2 $ $Date: 2004/04/12 23:11:29 $
 */

#ifndef dsp_mtrx_sim_h
#define dsp_mtrx_sim_h

#include "simstruc.h"

#ifdef DSP_SIM_COMMON_EXPORTS
#define DSP_COMMON_SIM_EXPORT EXPORT_FCN
#else
#define DSP_COMMON_SIM_EXPORT extern
#endif

/*--------------------------------------------------------------*/
/*                  DIMENSION INFO                              */
/*--------------------------------------------------------------*/


/*--------------------------------------------------------------
 * ONE OR TWO DIMENSIONS (1D OR 2D):
 *  If input/output signal is 1D or 2D, return true.
 *  Otherwise, return false.
 */
DSP_COMMON_SIM_EXPORT boolean_T isInput1or2D(SimStruct *S, int_T port);
DSP_COMMON_SIM_EXPORT boolean_T isOutput1or2D(SimStruct *S, int_T port);
DSP_COMMON_SIM_EXPORT boolean_T isInput2D(SimStruct *S, int_T port);
DSP_COMMON_SIM_EXPORT boolean_T isOutput2D(SimStruct *S, int_T port);

/*--------------------------------------------------------------
 * DYNAMICALLY SIZED
 */
DSP_COMMON_SIM_EXPORT boolean_T isInputDynamicallySized(SimStruct *S, int_T port);
DSP_COMMON_SIM_EXPORT boolean_T isOutputDynamicallySized(SimStruct *S, int_T port);

/*--------------------------------------------------------------
 * DEFINED DIMENSIONS:
 *  If all input/output port dimensions defined, return true.
 *  Otherwise, return false.
 */
DSP_COMMON_SIM_EXPORT boolean_T areAllInputDimensionsDefined( SimStruct *S );
DSP_COMMON_SIM_EXPORT boolean_T areAllOutputDimensionsDefined( SimStruct *S );
DSP_COMMON_SIM_EXPORT boolean_T areAllPortDimensionsDefined( SimStruct *S );
DSP_COMMON_SIM_EXPORT boolean_T areAllButOneInputDimensionsDefined(SimStruct *S, int_T *unsetPortIdx);
DSP_COMMON_SIM_EXPORT boolean_T areAllButOneOutputDimensionsDefined(SimStruct *S, int_T *unsetPortIdx);

/*--------------------------------------------------------------
 * UNORIENTED: [M], M >= 1
 *  If input/output is unoriented, return true.
 *  Otherwise, return false.
 */
DSP_COMMON_SIM_EXPORT boolean_T isInputUnoriented(SimStruct *S, int_T port);
DSP_COMMON_SIM_EXPORT boolean_T isOutputUnoriented(SimStruct *S, int_T port);
DSP_COMMON_SIM_EXPORT boolean_T areAllInputPortsUnoriented( SimStruct *S );

/*--------------------------------------------------------------
 * ORIENTED: [MxN], M,N >= 1
 *  If input/output is oriented, return true.
 *  Otherwise, return false.
 */
DSP_COMMON_SIM_EXPORT boolean_T isInputOriented(SimStruct *S, int_T port);
DSP_COMMON_SIM_EXPORT boolean_T isOutputOriented(SimStruct *S, int_T port);

/*--------------------------------------------------------------
 * SCALAR: [1], [1x1]
 *  If input/output is oriented or unoriented scalar, return true.
 *  Otherwise, return false.
 */
DSP_COMMON_SIM_EXPORT boolean_T isInputScalar(SimStruct *S, int_T port);
DSP_COMMON_SIM_EXPORT boolean_T isOutputScalar(SimStruct *S, int_T port);

/*--------------------------------------------------------------
 * ROW VECTOR: [1xN], N>1
 *  If input/output is an oriented row, return true.
 *  Otherwise, return false (including if it is unoriented).
 */
DSP_COMMON_SIM_EXPORT boolean_T isInputRowVector(SimStruct *S, int_T port);
DSP_COMMON_SIM_EXPORT boolean_T isOutputRowVector(SimStruct *S, int_T port);

/*--------------------------------------------------------------
 * COLUMN VECTOR: [Mx1], M>1
 *  If input/output is an oriented col, return true.
 *  Otherwise, return false (including if it is unoriented).
 */
DSP_COMMON_SIM_EXPORT boolean_T isInputColVector(SimStruct *S, int_T port);
DSP_COMMON_SIM_EXPORT boolean_T isOutputColVector(SimStruct *S, int_T port);

/*--------------------------------------------------------------
 * FULL MATRIX:  [MxN], M,N > 1
 *  If input/output is a full matrix, return true.
 *  Otherwise, return false.
 */
DSP_COMMON_SIM_EXPORT boolean_T isInputFullMatrix(SimStruct *S, int_T port);
DSP_COMMON_SIM_EXPORT boolean_T isOutputFullMatrix(SimStruct *S, int_T port);

/*--------------------------------------------------------------
 * SQUARE MATRIX: [MxM], M >= 1
 *  If input/output is a sqaure matrix, return true.
 *  Otherwise, return false.
 */
DSP_COMMON_SIM_EXPORT boolean_T isInputSquareMatrix(SimStruct *S, int_T port);
DSP_COMMON_SIM_EXPORT boolean_T isOutputSquareMatrix(SimStruct *S, int_T port);

/*--------------------------------------------------------------
 * VECTOR: [1], [1x1], [F], [1xF], [Fx1] (anything but full matrix)
 *  If input/output is oriented or unoriented scalar or vector, return true.
 *  Otherwise, return false.
 */
DSP_COMMON_SIM_EXPORT boolean_T isInputVector(SimStruct *S, int_T port);
DSP_COMMON_SIM_EXPORT boolean_T isOutputVector(SimStruct *S, int_T port);


/*--------------------------------------------------------------*/
/*                  FRAME-NESS                                  */
/*--------------------------------------------------------------*/


/*--------------------------------------------------------------
 * Frame Data ("frame-bit") checks: On or Off or Inherited
 * (See below to check whether a signal is frame-based)
 */
DSP_COMMON_SIM_EXPORT boolean_T isInputFrameDataInherited(SimStruct *S, int_T port);
DSP_COMMON_SIM_EXPORT boolean_T isOutputFrameDataInherited(SimStruct *S, int_T port);
DSP_COMMON_SIM_EXPORT boolean_T isInputFrameDataOn(SimStruct *S, int_T port);
DSP_COMMON_SIM_EXPORT boolean_T isOutputFrameDataOn(SimStruct *S, int_T port);
DSP_COMMON_SIM_EXPORT boolean_T isInputFrameDataOff(SimStruct *S, int_T port);
DSP_COMMON_SIM_EXPORT boolean_T isOutputFrameDataOff(SimStruct *S, int_T port);

/*--------------------------------------------------------------
 * Frame-based checks:
 * Definition of Frame-based: If frame-bit is on and sample per frame is > 1.
 */
DSP_COMMON_SIM_EXPORT boolean_T isInputFrameBased(SimStruct *S, int_T port);
DSP_COMMON_SIM_EXPORT boolean_T isOutputFrameBased(SimStruct *S, int_T port);
DSP_COMMON_SIM_EXPORT boolean_T isInputSampleBased(SimStruct *S, int_T port);
DSP_COMMON_SIM_EXPORT boolean_T isOutputSampleBased(SimStruct *S, int_T port);


/*--------------------------------------------------------------*/
/*      COMBINED DIMENSIONS AND FRAME-BASED INFO CHECKING       */
/*--------------------------------------------------------------*/


/*
 * Return the number of samples (nSamps) and number of channels (nChans)
 * based on the registered attributes of inport/outport portNum.
 * Provides vector convenience rule (1-D and row/col vectors are all
 *  treated as single-channel inputs).
 */
DSP_COMMON_SIM_EXPORT void getInportSampsAndChans(
    SimStruct   *S,
    const int_T  portNum,
    int_T       *nSamps,
    int_T       *nChans);

DSP_COMMON_SIM_EXPORT void getOutportSampsAndChans(
    SimStruct   *S,
    const int_T  portNum,
    int_T       *nSamps,
    int_T       *nChans);

DSP_COMMON_SIM_EXPORT boolean_T areInportAndOutportSameDims(
    SimStruct *S,
    int_T inport,
    int_T outport);

DSP_COMMON_SIM_EXPORT boolean_T areInportAndOutportCollapsedDims(
    SimStruct *S,
    int_T inport,
    int_T outport);


#endif /* dsp_mtrx_sim_h */

/* [EOF] dsp_mtrx_sim.h */
