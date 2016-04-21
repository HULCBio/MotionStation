/*
 * dsp_cplx_sim.h
 *
 * DSP Blockset helper function.
 *
 * Query input/output port complexity information. 
 *
 *
 * Copyright 1995-2003 The MathWorks, Inc.
 * $Revision: 1.8.4.2 $ $Date: 2004/04/12 23:11:12 $
 */

#ifndef dsp_cplx_sim_h
#define dsp_cplx_sim_h

#include "simstruc.h"

#ifdef DSP_SIM_COMMON_EXPORTS
#define DSP_COMMON_SIM_EXPORT EXPORT_FCN
#else
#define DSP_COMMON_SIM_EXPORT extern
#endif

/*--------------------------------------------------------------
 * COMPLEX_INHERITED:
 */

/*******************************************************************************
 * FUNCTION isInputComplexInherited
 *
 * DESCRIPTION: Check if an input port is complex inherited (i.e. not yet set)
 *
 * INPUTS: S    - the block SimStruct
 *         port - the index of the input port to be checked
 *
 * RETURNS: boolean value (true -> input cplx inherited, false -> not cplx inh)
 *
 * PRECONDITIONS: None
 *
 * POSTCONDITIONS: None
 *
 * OPERATION: Synchronous (operation completed upon function return)
 ******************************************************************************/
DSP_COMMON_SIM_EXPORT boolean_T isInputComplexInherited(SimStruct *S, int_T port);

/*******************************************************************************
 * FUNCTION isOutputComplexInherited
 *
 * DESCRIPTION: Check if an output port is complex inherited (i.e. not yet set)
 *
 * INPUTS: S    - the block SimStruct
 *         port - the index of the output port to be checked
 *
 * RETURNS: boolean value (true -> output cplx inherited, false -> not cplx inh)
 *
 * PRECONDITIONS: None
 *
 * POSTCONDITIONS: None
 *
 * OPERATION: Synchronous (operation completed upon function return)
 ******************************************************************************/
DSP_COMMON_SIM_EXPORT boolean_T isOutputComplexInherited(SimStruct *S, int_T port);


/*--------------------------------------------------------------
 * REAL:
 */

/*******************************************************************************
 * FUNCTION isInputReal
 *
 * DESCRIPTION: Check if an input port complexity is real
 *
 * INPUTS: S    - the block SimStruct
 *         port - the index of the input port to be checked
 *
 * RETURNS: boolean value (true -> input real, false -> input not real)
 *
 * PRECONDITIONS: None
 *
 * POSTCONDITIONS: None
 *
 * OPERATION: Synchronous (operation completed upon function return)
 ******************************************************************************/
DSP_COMMON_SIM_EXPORT boolean_T isInputReal(SimStruct *S, int_T port);

/*******************************************************************************
 * FUNCTION isOutputReal
 *
 * DESCRIPTION: Check if an output port complexity is real
 *
 * INPUTS: S    - the block SimStruct
 *         port - the index of the output port to be checked
 *
 * RETURNS: boolean value (true -> input is real, false -> input not real)
 *
 * PRECONDITIONS: None
 *
 * POSTCONDITIONS: None
 *
 * OPERATION: Synchronous (operation completed upon function return)
 ******************************************************************************/
DSP_COMMON_SIM_EXPORT boolean_T isOutputReal(SimStruct *S, int_T port);


/*--------------------------------------------------------------
 * COMPLEX:
 */

/*******************************************************************************
 * FUNCTION isInputComplex
 *
 * DESCRIPTION: Check if an input port complexity is complex
 *
 * INPUTS: S    - the block SimStruct
 *         port - the index of the input port to be checked
 *
 * RETURNS: boolean value (true -> input complex, false -> input not complex)
 *
 * PRECONDITIONS: None
 *
 * POSTCONDITIONS: None
 *
 * OPERATION: Synchronous (operation completed upon function return)
 ******************************************************************************/
DSP_COMMON_SIM_EXPORT boolean_T isInputComplex(SimStruct *S, int_T port);

/*******************************************************************************
 * FUNCTION isOutputComplex
 *
 * DESCRIPTION: Check if an output port complexity is complex
 *
 * INPUTS: S    - the block SimStruct
 *         port - the index of the output port to be checked
 *
 * RETURNS: boolean value (true -> output complex, false -> output not complex)
 *
 * PRECONDITIONS: None
 *
 * POSTCONDITIONS: None
 *
 * OPERATION: Synchronous (operation completed upon function return)
 ******************************************************************************/
DSP_COMMON_SIM_EXPORT boolean_T isOutputComplex(SimStruct *S, int_T port);

#endif /* dsp_cplx_sim_h */

/* [EOF] dsp_cplx_sim.h */
