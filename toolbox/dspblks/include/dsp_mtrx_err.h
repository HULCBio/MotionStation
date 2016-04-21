/*
 *  dsp_mtrx_err.h
 *  Macros for common matrix and frame error checking for DSP Blockset.
 *
 *  Functions to check the input and output port dimension information.
 *  For example if input/output is oriented, unoriented, row, column vectors 
 *  and full matrices.
 *
 *  NOTE: This is query on the port dimension information. Therefore, 
 *  the dimension information must already be set for the port.
 *
 *  Copyright 1995-2002 The MathWorks, Inc.
 *  $Revision: 1.15 $ $Date: 2002/04/14 20:35:07 $
 */

#ifndef dsp_mtrx_err_h
#define dsp_mtrx_err_h

#include "dsp_mtrx_sim.h"

/****************************************************/
/*         DEFAULT ERROR MESSAGES                   */
/****************************************************/

#define InputMustBe1or2D            "Input must be 1-D or 2-D." 
#define OutputMustBe1or2D           "Output must be 1-D or 2-D." 

#define InputMustBe2D               "Input must be 2-D." 
#define OutputMustBe2D              "Output must be 2-D." 

#define InputCannotBe2D             "Input cannot be 2-D." 
#define OutputCannotBe2D            "Output cannot be 2-D." 

#define InputMustBeOriented         "Input dimensions must be greater than 1-D."
#define OutputMustBeOriented        "Output dimensions must be greater than 1-D."

#define InputMustBeUnoriented       "Input must be 1-D."
#define OutputMustBeUnoriented      "Output must be 1-D."

#define InputMustBeScalar           "Input must be a scalar." 
#define OutputMustBeScalar          "Output must be a scalar." 

#define InputCannotBeScalar         "Input cannot be a scalar." 
#define OutputCannotBeScalar        "Output cannot be a scalar." 

#define InputMustBeVector           "Input must be a vector." 
#define OutputMustBeVector          "Output must be a vector." 

#define InputCannotBeVector         "Input cannot be a vector." 
#define OutputCannotBeVector        "Output cannot be a vector." 

#define InputCannotBeRowVector      "Input cannot be a row vector." 
#define OutputCannotBeRowVector     "Output cannot be a row vector." 

#define InputMustBeRowVector        "Input must be a row vector." 
#define OutputMustBeRowVector       "Output must be a row vector." 

#define InputCannotBeColVector      "Input cannot be a column vector." 
#define OutputCannotBeColVector     "Output cannot be a column vector." 

#define InputMustBeColVector        "Input must be a column vector." 
#define OutputMustBeColVector       "Output must be a column vector." 

#define InputCannotBeFullMatrix     "Input cannot be a full matrix." 
#define OutputCannotBeFullMatrix    "Output cannot be a full matrix." 

#define FullMatrixInputMustBeFrame  "Full matrix input must be frame-based." 
#define FullMatrixOutputMustBeFrame "Full matrix output must be frame-based." 

#define InputMustBeFullMatrix       "Input must be a full matrix." 
#define OutputMustBeFullMatrix      "Output must be a full matrix." 

#define InputMustBeSquareMatrix     "Input must be a square matrix." 
#define OutputMustBeSquareMatrix    "Output must be a square matrix." 

#define InputCannotBeSquareMatrix   "Input cannot be a square matrix."
#define OutputCannotBeSquareMatrix  "Output cannot be a square matrix."

#define InputsMustHaveSameVectorOrientation     "Inputs must have same vector orientation." 
#define OutputsMustHaveSameVectorOrientation    "Outputs must have same vector orientation." 

#define InputMustBeFrameBased       "Input must be frame-based." 
#define OutputMustBeFrameBased      "Output must be frame-based." 

#define InputMustBeSampleBased      "Input must be sample-based." 
#define OutputMustBeSampleBased     "Output must be sample-based." 

/****************************************************/
/*              ERROR CHECKING                      */
/****************************************************/

/*            
 * One PORT I/O ERROR CHECKING:
 */

/***********************************************************/
/*       Valid signal dimensions error checking            */
/***********************************************************/

#define ErrorIfInputIsNot1or2D(S, port)                     \
    if (!isInput1or2D(S, port)) {                           \
        THROW_ERROR(S, InputMustBe1or2D);                   \
    }

#define ErrorIfOutputIsNot1or2D(S, port)                    \
    if (!isOutput1or2D(S, port)) {                          \
        THROW_ERROR(S, OutputMustBe1or2D);                  \
    }

#define ErrorIfInputIsNot2D(S, port)                        \
    if (!isInput2D(S, port)) {                              \
        THROW_ERROR(S, InputMustBe2D);                      \
    }

#define ErrorIfOutputIsNot2D(S, port)                       \
    if (!isOutput2D(S, port)) {                             \
        THROW_ERROR(S, OutputMustBe2D);                     \
    }

#define ErrorIfInputIs2D(S, port)                           \
    if (isInput2D(S, port)) {                               \
        THROW_ERROR(S, InputCannotBe2D);                    \
    }

#define ErrorIfOutputIs2D(S, port)                          \
    if (isOutput2D(S, port)) {                              \
        THROW_ERROR(S, OutputCannotBe2D);                   \
    }


/***********************************************************/
/*       Oriented and unoriented error checking            */
/***********************************************************/

#define ErrorIfInputIsUnoriented(S, port)                   \
    if (isInputUnoriented(S, port)) {                       \
        THROW_ERROR(S, InputMustBeOriented);                  \
    }                     

#define ErrorIfOutputIsUnoriented(S, port)                  \
    if (isOutputUnoriented(S, port)) {                      \
        THROW_ERROR(S, OutputMustBeOriented);                 \
    }

#define ErrorIfInputIsOriented(S, port)                     \
    if (isInputOriented(S, port)) {                         \
        THROW_ERROR(S, InputMustBeUnoriented);                \
    }

#define ErrorIfOutputIsOriented(S, port)                    \
    if (isOutputOriented(S, port)) {                        \
        THROW_ERROR(S, OutputMustBeUnoriented);               \
    }


/***********************************************************/
/*              Scalar error checking                      */
/***********************************************************/

#define ErrorIfInputIsScalar(S, port)                       \
    if (isInputScalar(S, port)) {                           \
        THROW_ERROR(S, InputCannotBeScalar);                  \
    }                     

#define ErrorIfOutputIsScalar(S, port)                      \
    if (isOutputScalar(S, port)) {                          \
        THROW_ERROR(S, OutputCannotBeScalar);                 \
    }

#define ErrorIfInputIsNotScalar(S, port)                    \
    if (!isInputScalar(S, port)) {                          \
        THROW_ERROR(S, InputMustBeScalar);                    \
    }                     

#define ErrorIfOutputIsNotScalar(S, port)                   \
    if (!isOutputScalar(S, port)) {                         \
        THROW_ERROR(S, OutputMustBeScalar);                   \
    }

/***********************************************************/
/*              Vector error checking                      */
/***********************************************************/

#define ErrorIfInputIsVector(S, port)                       \
    if (isInputVector(S, port)) {                           \
        THROW_ERROR(S, InputCannotBeVector);                  \
    }                     

#define ErrorIfOutputIsVector(S, port)                      \
    if (isOutputVector(S, port)) {                          \
        THROW_ERROR(S, OutputCannotBeVector);                 \
    }

#define ErrorIfInputIsNotVector(S, port)                    \
    if (!isInputVector(S, port)) {                          \
        THROW_ERROR(S, InputMustBeVector);                    \
    }                     

#define ErrorIfOutputIsNotVector(S, port)                   \
    if (!isOutputVector(S, port)) {                         \
        THROW_ERROR(S, OutputMustBeVector);                   \
    }

/***********************************************************/
/*              Row vector error checking                  */
/***********************************************************/

#define ErrorIfInputIsRowVector(S, port)                    \
    if (isInputRowVector(S, port)) {                        \
        THROW_ERROR(S, InputCannotBeRowVector);               \
    }

#define ErrorIfOutputIsRowVector(S, port)                   \
    if (isOutputRowVector(S, port)) {                       \
        THROW_ERROR(S, OutputCannotBeRowVector);              \
    }

#define ErrorIfInputIsNotRowVector(S, port)                 \
    if (!isInputRowVector(S, port)) {                       \
        THROW_ERROR(S, InputMustBeRowVector);                 \
    }

#define ErrorIfOutputIsNotRowVector(S, port)                \
    if (!isOutputRowVector(S, port)) {                      \
        THROW_ERROR(S, OutputMustBeRowVector);                \
    }


/***********************************************************/
/*           Column vector error checking                  */
/***********************************************************/

#define ErrorIfInputIsColVector(S, port)                    \
    if (isInputColVector(S, port)) {                        \
        THROW_ERROR(S, InputCannotBeColVector);               \
    }

#define ErrorIfOutputIsColVector(S, port)                   \
    if (isOutputColVector(S, port)) {                       \
        THROW_ERROR(S, OutputCannotBeColVector);              \
    }

#define ErrorIfInputIsNotColVector(S, port)                 \
    if (!isInputColVector(S, port)) {                       \
        THROW_ERROR(S, InputMustBeColVector);                 \
    }

#define ErrorIfOutputIsNotColVector(S, port)                \
    if (!isOutputColVector(S, port)) {                      \
        THROW_ERROR(S, OutputMustBeColVector);                \
    }



/***********************************************************/
/*                  Matrix error checking                  */
/***********************************************************/

#define ErrorIfInputIsFullMatrix(S, port)                   \
    if (isInputFullMatrix(S, port)) {                       \
        THROW_ERROR(S, InputCannotBeFullMatrix);              \
    }

#define ErrorIfOutputIsFullMatrix(S, port)                  \
    if (isOutputFullMatrix(S, port)) {                      \
        THROW_ERROR(S, OutputCannotBeFullMatrix);             \
    }

#define ErrorIfInputIsNotFullMatrix(S, port)                \
    if (!isInputFullMatrix(S, port)) {                      \
        THROW_ERROR(S, InputMustBeFullMatrix);                \
    }

#define ErrorIfOutputIsNotFullMatrix(S, port)               \
    if (!isOutputFullMatrix(S, port)) {                     \
        THROW_ERROR(S, OutputMustBeFullMatrix);               \
    }
    
#define ErrorIfInputIsSamplebasedFullMatrix(S, port)        \
    if (isInputFullMatrix(S, port) &&                       \
       (!isInputFrameBased(S,port) )) {                     \
        THROW_ERROR(S, FullMatrixInputMustBeFrame);         \
    }

#define ErrorIfOutputIsSamplebasedFullMatrix(S, port)       \
    if (isOutputFullMatrix(S, port) &&                      \
       (!isOutputFrameBased(S,port) )) {                    \
        THROW_ERROR(S, FullMatrixOutputMustBeFrame);        \
    }

#define ErrorIfInputIsNotSquareMatrix(S, port)              \
    if (!isInputSquareMatrix(S, port)) {                    \
        THROW_ERROR(S, InputMustBeSquareMatrix);              \
    }

#define ErrorIfOutputIsNotSquareMatrix(S, port)             \
    if (!isOutputSquareMatrix(S, port)) {                   \
        THROW_ERROR(S, OutputMustBeSquareMatrix);             \
    }

#define ErrorIfInputIsSquareMatrix(S, port)              \
    if (isInputSquareMatrix(S, port)) {                    \
        THROW_ERROR(S, InputCannotBeSquareMatrix);              \
    }

#define ErrorIfOutputIsSquareMatrix(S, port)             \
    if (isOutputSquareMatrix(S, port)) {                   \
        THROW_ERROR(S, OutputCannotBeSquareMatrix);             \
    }



/*            
 * Two PORT I/O ERROR CHECKING:
 */

/***********************************************************/
/*          Orientation error checking                     */
/***********************************************************/

/*
 * Checks that ALL input ports have the same orientation.
 * If the ports are all full matrices with the same dimensionality
 * If the input ports differ in orientation (row/col), generate an error.
 * If any input port is a general matrix (e.g., not a row), generate an error.
 * If all input ports are unoriented, returns ????
 */
#define ErrorIfInputsAreNotSameDimsInfo(S) {                          \
    THROW_ERROR(S,"ErrorIfInputsAreNotSameDimsInfo macro not yet implemented.");  \
    \
    int_T i = ssGetNumInputPorts(S);                                  \
    if (i>0) {                                                        \
        DimsInfo *lastDims = isInputColVector(S,--i);                 \
        while(i-- > 0) {                                              \
            /* blah blah blah */                                      \
        }                                                             \
    }                                                                 \
}

/* Two input checking
 * If the ports are not both row vectors or not both column vectors, 
 * generate an error.
 */
#define ErrorIfInputsAreNotSameVectorOrient(S) {                \
    if (ssGetNumInputPorts(S)!=2) {                             \
        THROW_ERROR(S, "Block must have 2 ports.");               \
    }                                                           \
    ErrorIfInputIsFullMatrix(S,0);                              \
    ErrorIfInputIsUnoriented(S,0);                              \
    if ( (isInputColVector(S, 0) && isInputRowVector(S,1)) ||   \
         (isInputColVector(S, 1) && isInputRowVector(S,0))      \
         ) {                                                    \
        THROW_ERROR(S, InputsMustHaveSameVectorOrientation);      \
    } \
}

/*
 *
 */
#define ErrorIfOutputsIsNotSameVectorOrient(S) \
    if (ssGetNumOutputPorts(S)!=2) {                            \
        THROW_ERROR(S, "Block must have 2 ports.");               \
    }                                                           \
    ErrorIfOutputIsFullMatrix(S,0); \
    ErrorIfOutputIsUnoriented(S,0); \
    \
    if ( (isOutputColVector(S, 0) && isOutputRowVector(S, 1)) ||\
         (isOutputColVector(S, 1) && isOutputRowVector(S, 0))   \
       ) {                                                      \
        THROW_ERROR(S, OutputsMustHaveSameVectorOrientation);     \
    }


/***********************************************************/
/*                  FRAME CHECKING                         */
/***********************************************************/


/* NOTE: THIS FUNCTION JUST ERRORS IF FRAME DATA = ON. */
/*       THIS MAY OR NOT BE THE SAME AS ERRORING IF    */
/*       FRAME-BASED, DEPENDING ON YOUR DEFINITION.    */
#define ErrorIfInputFrameDataOn(S, port)         \
    if (isInputFrameDataOn(S, port)) {           \
        THROW_ERROR(S, InputMustBeSampleBased);  \
    }

/* NOTE: THIS FUNCTION JUST ERRORS IF FRAME DATA = ON. */
/*       THIS MAY OR NOT BE THE SAME AS ERRORING IF    */
/*       FRAME-BASED, DEPENDING ON YOUR DEFINITION.    */
#define ErrorIfOutputFrameDataOn(S, port)        \
    if (isOutputFrameDataOn(S, port)) {          \
        THROW_ERROR(S, OutputMustBeSampleBased); \
    }

/* NOTE: THIS FUNCTION JUST ERRORS IF FRAME DATA = OFF. */
/*       THIS MAY OR NOT BE THE SAME AS ERRORING IF     */
/*       SAMPLE-BASED, DEPENDING ON YOUR DEFINITION.    */
#define ErrorIfInputFrameDataOff(S, port)        \
    if (isInputFrameDataOff(S, port)) {          \
        THROW_ERROR(S, InputMustBeFrameBased);   \
    }

/* NOTE: THIS FUNCTION JUST ERRORS IF FRAME DATA = OFF. */
/*       THIS MAY OR NOT BE THE SAME AS ERRORING IF     */
/*       SAMPLE-BASED, DEPENDING ON YOUR DEFINITION.    */
#define ErrorIfOutputFrameDataOff(S, port)       \
    if (isOutputFrameDataOff(S, port)) {         \
        THROW_ERROR(S, OutputMustBeFrameBased);  \
    }

/* NOTE: THIS FUNCTION DOES NOT JUST ERROR IF FRAME DATA = ON, */
/*       IT ALSO CHECKS THAT SAMPLES-PER-FRAME > 1.            */
#define ErrorIfInputIsFrameBased(S, port)        \
    if (isInputFrameBased(S, port)) {            \
        THROW_ERROR(S, InputMustBeSampleBased);  \
    }

/* NOTE: THIS FUNCTION DOES NOT JUST ERROR IF FRAME DATA = ON, */
/*       IT ALSO CHECKS THAT SAMPLES-PER-FRAME > 1.            */
#define ErrorIfOutputIsFrameBased(S, port)       \
    if (isOutputFrameBased(S, port)) {           \
        THROW_ERROR(S, OutputMustBeSampleBased); \
    }

/* NOTE: THIS FUNCTION DOES NOT JUST ERROR IF FRAMEDATA = OFF,   */
/*       IT ALSO ERRORS IF FRAMEDATA=ON AND SAMPLES-PER-FRAME=1. */
#define ErrorIfInputIsSampleBased(S, port)       \
    if (isInputSampleBased(S, port)) {           \
        THROW_ERROR(S, InputMustBeFrameBased);   \
    }

/* NOTE: THIS FUNCTION DOES NOT JUST ERROR IF FRAMEDATA = OFF,   */
/*       IT ALSO ERRORS IF FRAMEDATA=ON AND SAMPLES-PER-FRAME=1. */
#define ErrorIfOutputIsSampleBased(S, port)      \
    if (isOutputSampleBased(S, port)) {          \
        THROW_ERROR(S, OutputMustBeFrameBased);  \
    }


#endif  /* dsp_mtrx_err_h */
/* end of dsp_mtrx_err.h */
