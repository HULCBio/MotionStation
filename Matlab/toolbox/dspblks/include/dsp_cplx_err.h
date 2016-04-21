/*
 *  dsp_cplx_err.h
 *  Macros for common error checking for DSP Blockset.
 *
 * Functions to check the input and output port complexity information.
 *
 * NOTE: This is query on the port dimension information. Therefore, 
 * the dimension information must already be set for the port.
 *
 *
 *  Copyright 1995-2002 The MathWorks, Inc.
 *  $Revision: 1.8 $ $Date: 2002/04/14 20:35:01 $
 */

#ifndef dsp_cplx_err_h
#define dsp_cplx_err_h

#include "dsp_cplx_sim.h"

/****************************************************/
/*         DEFAULT ERROR MESSAGES                   */
/****************************************************/

#define InputMustBeReal         "Input must be real."
#define OutputMustBeReal        "Output must be real."

#define InputMustBeComplex      "Input must be complex."
#define OutputMustBeComplex     "Output must be complex."



/****************************************************/
/*              ERROR CHECKING                      */
/****************************************************/

/*            
 * One PORT I/O ERROR CHECKING:
 */


/***********************************************************/
/*       Real and Complex error checking                   */
/***********************************************************/

#define ErrorIfInputIsReal(S, port)                        \
    if (isInputReal(S, port)) {                            \
        THROW_ERROR(S, InputMustBeComplex);                  \
    }                     

#define ErrorIfOutputIsReal(S, port)                       \
    if (isOutputReal(S, port)) {                           \
        THROW_ERROR(S, OutputMustBeComplex);                 \
    }

#define ErrorIfInputIsComplex(S, port)                     \
    if (isInputComplex(S, port)) {                         \
        THROW_ERROR(S, InputMustBeReal);                     \
    }

#define ErrorIfOutputIsComplex(S, port)                    \
    if (isOutputComplex(S, port)) {                        \
        THROW_ERROR(S, OutputMustBeReal);                    \
    }

#endif  /* dsp_cplx_err_h */
/* end of dsp_cplx_err.h */
