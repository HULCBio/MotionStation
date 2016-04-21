/*
 *  dsp_fixpt_err.h
 *  Macros for common fixed-point data type error checking for DSP Blockset.
 *
 *  Copyright 1995-2002 The MathWorks, Inc.
 *  $Revision: 1.11 $ $Date: 2002/12/23 22:24:01 $
 */

#ifndef dsp_fixpt_err_h
#define dsp_fixpt_err_h

#include "dsp_fixpt_sim.h"

/****************************************************/
/*         DEFAULT ERROR MESSAGES                   */
/****************************************************/

#define InputMustBeFixedPoint            "Input must be fixed-point."
#define OutputMustBeFixedPoint           "Output must be fixed-point."

#define InputCannotBeFixedPoint          "Input cannot be fixed-point."
#define OutputCannotBeFixedPoint         "Output cannot be fixed-point."

#define InputMustBeSignedFixedPoint      "Input must be signed fixed-point."
#define OutputMustBeSignedFixedPoint     "Output must be signed fixed-point."

#define InputCannotBeSignedFixedPoint    "Input cannot be signed fixed-point."
#define OutputCannotBeSignedFixedPoint   "Output cannot be signed fixed-point."

#define InputMustBeUnsignedFixedPoint    "Input must be unsigned fixed-point."
#define OutputMustBeUnsignedFixedPoint   "Output must be unsigned fixed-point."

#define InputCannotBeUnsignedFixedPoint  "Input cannot be unsigned fixed-point."
#define OutputCannotBeUnsignedFixedPoint "Output cannot be unsigned fixed-point."


/****************************************************/
/*              ERROR CHECKING                      */
/****************************************************/

#define ErrorIfInputIsNotFixedPoint(S, port)        \
    if (!isInputPortFixpt(S, port)) {               \
        THROW_ERROR(S, InputMustBeFixedPoint);      \
    }

#define ErrorIfOutputIsNotFixedPoint(S, port)       \
    if (!isOutputPortFixpt(S, port)) {              \
        THROW_ERROR(S, OutputMustBeFixedPoint);     \
    }

#define ErrorIfInputIsFixedPoint(S, port)           \
    if (isInputPortFixpt(S, port)) {                \
        THROW_ERROR(S, InputCannotBeFixedPoint);    \
    }

#define ErrorIfOutputIsFixedPoint(S, port)          \
    if (isOutputPortFixpt(S, port)) {               \
        THROW_ERROR(S, OutputCannotBeFixedPoint);   \
    }

#define ErrorIfInputIsNotSignedFixedPoint(S, port)        \
    if (!isInputPortSignedFixpt(S, port)) {               \
        THROW_ERROR(S, InputMustBeSignedFixedPoint);      \
    }

#define ErrorIfOutputIsNotSignedFixedPoint(S, port)       \
    if (!isOutputPortSignedFixpt(S, port)) {              \
        THROW_ERROR(S, OutputMustBeSignedFixedPoint);     \
    }

#define ErrorIfInputIsSignedFixedPoint(S, port)           \
    if (isInputPortSignedFixpt(S, port)) {                \
        THROW_ERROR(S, InputCannotBeSignedFixedPoint);    \
    }

#define ErrorIfOutputIsSignedFixedPoint(S, port)          \
    if (isOutputPortSignedFixpt(S, port)) {               \
        THROW_ERROR(S, OutputCannotBeSignedFixedPoint);   \
    }

#define ErrorIfInputIsNotUnsignedFixedPoint(S, port)        \
    if (!isInputPortUnsignedFixpt(S, port)) {               \
        THROW_ERROR(S, InputMustBeUnsignedFixedPoint);      \
    }

#define ErrorIfOutputIsNotUnsignedFixedPoint(S, port)       \
    if (!isOutputPortUnsignedFixpt(S, port)) {              \
        THROW_ERROR(S, OutputMustBeUnsignedFixedPoint);     \
    }

#define ErrorIfInputIsUnsignedFixedPoint(S, port)           \
    if (isInputPortUnsignedFixpt(S, port)) {                \
        THROW_ERROR(S, InputCannotBeUnsignedFixedPoint);    \
    }

#define ErrorIfOutputIsUnsignedFixedPoint(S, port)          \
    if (isOutputPortUnsignedFixpt(S, port)) {               \
        THROW_ERROR(S, OutputCannotBeUnsignedFixedPoint);   \
    }

#define ErrorIfInputNotSfix16ZeroBiasUnitSlopeType(S, portIdx) \
    if (!isInputNfracSignedUnitSlopeZeroBiasFixpt(S,portIdx,16)) {  \
        THROW_ERROR(S, "Input must be signed 16-bit fixed-point (with zero bias and power-of-two slope)."); \
    }

#define ErrorIfOutputNotSfix16ZeroBiasUnitSlopeType(S, portIdx) \
    if (!isOutputNfracSignedUnitSlopeZeroBiasFixpt(S,portIdx,16)) {   \
        THROW_ERROR(S, "Output must be signed 16-bit fixed-point (with zero bias and power-of-two slope)."); \
    }

#define ErrorIfInputNotSfix32ZeroBiasUnitSlopeType(S, portIdx) \
    if (!isInputNfracSignedUnitSlopeZeroBiasFixpt(S,portIdx,32)) {  \
        THROW_ERROR(S, "Input must be signed 32-bit fixed-point (with zero bias and power-of-two slope)."); \
    }

#define ErrorIfOutputNotSfix32ZeroBiasUnitSlopeType(S, portIdx) \
    if (!isOutputNfracSignedUnitSlopeZeroBiasFixpt(S,portIdx,32)) {   \
        THROW_ERROR(S, "Output must be signed 32-bit fixed-point (with zero bias and power-of-two slope)."); \
    }

#endif /* dsp_fixpt_err_h */

/* [EOF] dsp_fixpt_err.c */
