/* File : %M%
 * -----------------------------------------------------------------------------
 *
 * This S Function keeps the past N-1 input samples plus the present one
 * in a shift register, for every input signal,
 * and outputs them as a vector of length "N".
 * All the output vectors will be multiplexed in a single vector
 *
 * u0[0]
 * +--+
 * |  |--------+
 * +--+        v  Shift register
 *  .         +-+-+-+...+---+---+
 *  .         |0|1|2|...|N-2|N-1|->
 *  .         +-+-+-+...+---+---+
 *  .          | | |      |   |
 *  .          v v v      v   v        y0[n*N]
 *  .         +-+-+-+...+---+---+.....+-+-+-+...+---+---+
 *  .   y0[0] |0|1|2|...|N-2|N-1|.....|0|1|2|...|N-2|N-1| Output (mpx)
 *  .         +-+-+-+...+---+---+.....+-+-+-+...+---+---+
 *  .                                  ^ ^ ^      ^   ^
 *  .                                  | | |      |   |
 *  .                                 +-+-+-+...+---+---+
 *  .                                 |0|1|2|...|N-2|N-1|->
 * u0[n]                              +-+-+-+...+---+---+
 * +--+                                ^  Shift register
 * |  |--------------------------------+
 * +--+
 *
 * (n+1) is the input signal width.
 *
 * Input can be multiplexed data of any type..
 * 
 *   BLOCK PARAMETERS:
 *
 *   The block has three parameters (in that order):
 *
 *     - Number of past samples:
 *                             Number of past samples
 *                             to keep.
 *                             Type: integer; Not tunable.
 *
 *     - Sample time:          The discrete sample time in seconds.
 *                             Type: double; Not tunable.
 *                             Default value: 50e-6 seconds
 *
 *     - Initial value:        The value to output before attaining
 *                             the conservation period.
 *                             Type: Same as port 0; Not tunable
 *                             Default: Double
 *
 *   PORT PROPERTIES:
 *
 *   The block has one input port and one output port.
 *
 *     - u0:     The input signals.
 *               Size: Variable
 *               Type: Same as driving block
 *
 *     - y0    : The output signals, in a single vector.
 *               Size: Variable. Equal: N * input width.
 *               Type: Same as u0
 *
 *   BLOCK RULES:
 *
 *   - The number of samples kept (N) should not exceed 32768.
 *   - The maximum number of input signals should not exceed 10.
 *   - Width rule: Width of outputs "y" equals: (N+1) times input width.
 *   - Data type rule: u0 and y0 have the same data types, and they 
 *     accept the following types: real_T, real32_T, int8_T, uint8_T, int16_T,
 *                                 uint16_T, int32_T, uint32_T, boolean_T
 *
 * -----------------------------------------------------------------------------
 *
 * Author: Raymond Roussel					October 2002
 * Transmitted to Patrice Brunelle April 15 2003
 * -----------------------------------------------------------------------------
 * HYDRO-QUEBEC -- 2000-2002
 */

#define S_FUNCTION_NAME discreteNLastSamples
#define S_FUNCTION_LEVEL 2

#include "simstruc.h"


#include <math.h>
#include <stdlib.h>
#include <assert.h>
#include <string.h>

#ifdef TRUE
#  undef TRUE
#endif

#ifdef FALSE
#  undef FALSE
#endif

#define TRUE 1
#define FALSE 0

/* Macros to access input and output signals */

/* Access to input port values */

#define U0(upt, element) (*(upt)[element])  /* Pointer to Input Port0 */

/*
    Ouput past values according to data type "dtype"

    Parameters:

        ss            Pointer to SimStruct
        psi           Present Sample Index
        nlsmplbuf     Number of input signals
        nsmpl         Number of samples to keep
        dtype         Signals type.
*/

#define OUTPUT_PAST_SAMPLES(ss, psi, nlsmplbuf, nsmpl, dtype)                 \
    {                                                                         \
        dtype *y         = (dtype *)ssGetOutputPortSignal(ss,0);              \
        dtype **uBuffers = (dtype **)ssGetPWork(ss);                          \
        int  io          = 0;                                                 \
        dtype *uBuf;                                                          \
        int  ipw;                                                             \
        int  iv;                                                              \
                                                                              \
        for(ipw = 0; ipw < (nlsmplbuf); ++ipw)                                \
        {                                                                     \
            assert(uBuffers[ipw] != NULL);                                    \
                                                                              \
            uBuf = uBuffers[ipw];                                             \
                                                                              \
            /* Output from present sample index to 0 */                       \
                                                                              \
            for(iv = (psi); iv >=  0; --iv)                                   \
                y[io++] = uBuf[iv];    /* Output past value(s) */             \
                                                                              \
            /* Output from end of buffer to present sample index excl. */     \
                                                                              \
            for(iv = (nsmpl)-1; iv >  (psi); --iv)                            \
                y[io++] = uBuf[iv];    /* Output past value(s) */             \
        }                                                                     \
    }


/*
    Input present values occording to data type "dtype"

    Parameters:

        ss            Pointer to SimStruct
        psi           Present Sample Index
        nlsmplbuf     Number of input signals
        dtype         Signals type.
*/

#define INPUT_PRESENT_SAMPLES(ss, psi, nlsmplbuf, dtype)                       \
    {                                                                          \
        dtype **uBuffers = (dtype **)ssGetPWork(ss);                           \
        InputRealPtrsType uPtrs0 =                                             \
                            (InputRealPtrsType)ssGetInputPortSignalPtrs(ss,0); \
        int  ipw;                                                              \
                                                                               \
        for(ipw = 0; ipw < (nlsmplbuf); ++ipw)                                 \
        {                                                                      \
            assert(uBuffers[ipw] != NULL);                                     \
                                                                               \
            /* Input at present sample index */                                \
                                                                               \
            (uBuffers[ipw])[psi] = (dtype)U0(uPtrs0, ipw);                     \
                                                                               \
        }                                                                      \
    }
/* S-Function parameters */

#define NPARAMS            3

#define N_PAST_SAMPLES_IDX 0
#define N_PAST_SAMPLES(S) ssGetSFcnParam(S,N_PAST_SAMPLES_IDX)

 
#define SMPL_TIM_IDX 1
#define SMPL_TIM(S) ssGetSFcnParam(S,SMPL_TIM_IDX)
 
#define INIT_VALUE_IDX 2
#define INIT_VALUE(S) ssGetSFcnParam(S,INIT_VALUE_IDX)
 
/* Work buffers sizes and indexes */

#ifndef MAX_BUFFER_SIZE
#  define MAX_BUFFER_SIZE	   32768
#endif /* MAX_BUFFER_SIZE */

#define IWORKS_NUMBER       2

#define IND_PS_IDX          0
#define BUF_SZ_IDX          1

#define RWORKS_NUMBER       0


/* define error messages */
#define ERR_INVALID_SET_INPUT_DTYPE_CALL  \
              "Invalid call to mdlSetInputPortDataType"

#define ERR_INVALID_SET_OUTPUT_DTYPE_CALL \
              "Invalid call to mdlSetOutputPortDataType"

#define ERR_INVALID_DTYPE     "Invalid input or output port data type"

#define ERR_INVALID_PARAM \
  "Invalid parameter. The parameter must be real, integer or boolean."
  
/* Type definitions */

typedef struct dvtdInfo_tag
{
  int delayTruncWarningDone;
} dvtdInfo;
  
/* Functions */
  
static char *simulinkTypeName(DTypeId dtid)
{
    switch(dtid)
    {
      case SS_DOUBLE:  return("double");
      case SS_SINGLE:  return("single");
      case SS_INT8:    return("int8");
      case SS_UINT8:   return("uint8");
      case SS_INT16:   return("int16");
      case SS_UINT16:  return("uint16");
      case SS_INT32:   return("int32");
      case SS_UINT32:  return("uint32");
      case SS_BOOLEAN: return("boolean");
      default:         return("unknown");
    }
}


#define MDL_CHECK_PARAMETERS   /* Change to #undef to remove function */
#if defined(MDL_CHECK_PARAMETERS) && defined(MATLAB_MEX_FILE)
  /* Function: mdlCheckParameters =============================================
   * Abstract:
   *    mdlCheckParameters verifies new parameter settings whenever parameter
   *    change or are re-evaluated during a simulation. When a simulation is
   *    running, changes to S-function parameters can occur at any time during
   *    the simulation loop.
   *
   *    This method can be called at any point after mdlInitializeSizes.
   *    You should add a call to this method from mdlInitalizeSizes
   *    to check the parameters. After setting the number of parameters
   *    you expect in your S-function via ssSetNumSFcnParams(S,n), you should:
   *     #if defined(MATLAB_MEX_FILE)
   *       if (ssGetNumSFcnParams(S) == ssGetSFcnParamsCount(S)) {
   *           mdlCheckParameters(S);
   *           if (ssGetErrorStatus(S) != NULL) return;
   *       } else {
   *           return;     Simulink will report a parameter mismatch error
   *       }
   *     #endif
   *
   *     When a Simulation is running, changes to S-function parameters can
   *     occur either at the start of a simulation step, or during a
   *     simulation step. When changes to S-function parameters occur during
   *     a simulation step, this method is called twice, for the same
   *     parameter changes. The first call during the simulation step is
   *     used to verify that the parameters are correct. After verifying the
   *     new parameters, the simulation continues using the original
   *     parameter values until the next simulation step at which time the
   *     new parameter values will be used. Redundant calls are needed to
   *     maintain simulation consistency.  Note that you cannot access the
   *     work, state, input, output, etc. vectors in this method. This
   *     method should only be used to validate the parameters. Processing
   *     of the parameters should be done in mdlProcessParameters.
   *
   *     See matlabroot/simulink/src/sfun_errhdl.c for an example. 
   */
  static void mdlCheckParameters(SimStruct *S)
  {
    const mxArray *init_value = ssGetSFcnParam(S, INIT_VALUE_IDX);
    int           init_value_width = mxGetNumberOfElements(init_value);

#ifndef NDEBUG
    ssPrintf("Ex?cution de \"mdlCheckParameters\":\n");
#endif /* NDEBUG */

    if(!((ssGetSimMode(S) == SS_SIMMODE_SIZES_CALL_ONLY) &&
          mxIsEmpty(init_value)))
    {
        boolean_T isOk = ((mxIsNumeric(init_value)  ||  
                          mxIsLogical(init_value)) &&
                          !mxIsComplex(init_value) &&  
                          !mxIsSparse(init_value)  && 
                          !mxIsEmpty(init_value));

        if(!isOk)
        {   
            ssSetErrorStatus(S,ERR_INVALID_PARAM);
#ifndef NDEBUG
    ssPrintf("mdlCheckParameters: Param^tre invalide\n");
    ssPrintf("                    mxIsNumeric = %s\n",
             mxIsNumeric(init_value) == TRUE ? "TRUE" : "FALSE");
    ssPrintf("                    mxIsLogical = %s\n",
             mxIsLogical(init_value) == TRUE ? "TRUE" : "FALSE");
    ssPrintf("                    mxIsComplex = %s\n",
             mxIsComplex(init_value) == TRUE ? "TRUE" : "FALSE");
    ssPrintf("                    mxIsSparse = %s\n",
             mxIsSparse(init_value) == TRUE ? "TRUE" : "FALSE");
    ssPrintf("                    mxIsEmpty = %s\n",
             mxIsEmpty(init_value) == TRUE ? "TRUE" : "FALSE");
#endif /* NDEBUG */

            return;
        }
        else
        {
            /* 
             * Verify that initial value is of a type compatible
             * with input port 0 type
             */

            DTypeId  dtype =    ssGetDTypeIdFromMxArray(init_value);
            DTypeId  dtypeInp = ssGetInputPortDataType(S, 0);

            isOk = FALSE;

#ifndef NDEBUG
    ssPrintf("mdlCheckParameters: type param^tre = ,%d "
             "type signal: = %d\n", (int)dtype, (int)dtypeInp);
#endif /* NDEBUG */

            switch(dtypeInp)
            {
              case SS_DOUBLE:    isOk = (dtype == dtypeInp) ||
                                        (dtype == SS_SINGLE) ||
                                        (dtype == SS_INT32) ||
                                        (dtype == SS_INT16) ||
                                        (dtype == SS_INT8) ||
                                        (dtype == SS_UINT32) ||
                                        (dtype == SS_UINT16) ||
                                        (dtype == SS_UINT8); break;

              case SS_SINGLE:    isOk = (dtype == dtypeInp) ||
                                        (dtype == SS_INT16) ||
                                        (dtype == SS_INT8) ||
                                        (dtype == SS_UINT16) ||
                                        (dtype == SS_UINT8); break;

              case SS_INT32:     isOk = (dtype == dtypeInp); /* Fall through */
              case SS_INT16:     isOk |= (dtype == SS_INT16); /* Fall through */
              case SS_INT8:      isOk |= (dtype == SS_INT8); break;


              case SS_UINT32:    isOk = (dtype == dtypeInp); /* Fall through */
              case SS_UINT16:    isOk |= (dtype == SS_UINT16);/* Fall through */
              case SS_UINT8:     isOk |= (dtype == SS_UINT8); break;

              case SS_BOOLEAN:   isOk = (dtype == dtypeInp); break;

            }
            
            if(!isOk)
            {
                ssSetErrorStatus(S,
                   "ERROR! Input signal and initial value data types mismatch");
                ssPrintf(
                  "ERROR! Input signal and initial value data types mismatch");
                ssPrintf("Input port 0 (signal) : %s; Initial values : %s\n",
                         simulinkTypeName(dtypeInp), simulinkTypeName(dtype));
                return;
            }
        }

        /* Verify that number of initial values matches inport 0 width or 1*/

        if(init_value_width > 1 && init_value_width != ssGetInputPortWidth(S, 0))
        {
            ssSetErrorStatus(S,
           "ERROR! Number of initial values must equal the width of input port 0 or one");
            return;
        }
    }
  }
#endif /* MDL_CHECK_PARAMETERS */


/*=====================================*
 * Configuration and execution methods *
 *=====================================*/

/* Function: mdlInitializeSizes ===============================================
 * Abstract:
 *    The sizes information is used by Simulink to determine the S-function
 *    block's characteristics (number of inputs, outputs, states, etc.).
 *
 *    The direct feedthrough flag can be either 1=yes or 0=no. It should be
 *    set to 1 if the input, "u", is used in the mdlOutput function. Setting
 *    this to 0 is akin to making a promise that "u" will not be used in the
 *    mdlOutput function. If you break the promise, then unpredictable results
 *    will occur.
 *
 *    The NumContStates, NumDiscStates, NumInputs, NumOutputs, NumRWork,
 *    NumIWork, NumPWork NumModes, and NumNonsampledZCs widths can be set to:
 *       DYNAMICALLY_SIZED    - In this case, they will be set to the actual
 *                              input width, unless you are have a
 *                              mdlSetWorkWidths to set the widths.
 *       0 or positive number - This explicitly sets item to the specified
 *                              value.
 */
static void mdlInitializeSizes(SimStruct *S)
   {
#ifndef NDEBUG
    ssPrintf("Ex?cution de \"mdlInitializeSizes\":\n");
#endif /* NDEBUG */

    ssSetNumSFcnParams(S, NPARAMS);  /* Number of expected parameters */

#if defined(MATLAB_MEX_FILE)
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        /*
         * If the the number of expected input parameters is not equal
         * to the number of parameters entered in the dialog box return.
         * Simulink will generate an error indicating that there is a
         * parameter mismatch.
         */
        return;
    }
#endif

    /* Parameters ARE NOT tunables */

    ssSetSFcnParamTunable(S, N_PAST_SAMPLES_IDX, FALSE);
    ssSetSFcnParamTunable(S, SMPL_TIM_IDX, FALSE);
    ssSetSFcnParamTunable(S, INIT_VALUE_IDX, FALSE);

    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);

    if (!ssSetNumInputPorts(S, 1)) return;

    ssSetInputPortDataType(         S, 0, DYNAMICALLY_TYPED );
    ssSetInputPortDirectFeedThrough(S, 0, TRUE);


    if (!ssGetInputPortConnected(S,0))
    {
        ssWarning(S,"Input is unconnected or grounded, "
                  "setting input width to 1");
        ssSetInputPortWidth(S, 0, 1);
    } else {
        ssSetInputPortWidth(S, 0, DYNAMICALLY_SIZED);
    }

    if (!ssSetNumOutputPorts(S, 1)) return;

    if (!ssGetOutputPortConnected(S,0)) {
        ssWarning(S,"output is unconnected or terminated");
    }

    ssSetOutputPortWidth(   S, 0, DYNAMICALLY_SIZED);
    ssSetOutputPortDataType(S, 0, DYNAMICALLY_TYPED );

    ssSetNumSampleTimes(S, 1);

    ssSetNumRWork(S, RWORKS_NUMBER);
    ssSetNumIWork(S, IWORKS_NUMBER);
    ssSetNumPWork(S, DYNAMICALLY_SIZED);

    ssSetNumModes(S, 0);

    ssSetNumNonsampledZCs(S, 0);

    /* Take care when specifying exception free code - see sfuntmpl.doc */
    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE);
}



#define MDL_SET_INPUT_PORT_WIDTH   /* Change to #undef to remove function */
#if defined(MDL_SET_INPUT_PORT_WIDTH) && defined(MATLAB_MEX_FILE)
  /* Function: mdlSetInputPortWidth ===========================================
   * Abstract:
   *    This method is called with the candidate width for a dynamically
   *    sized port.  If the proposed width is acceptable, the method should
   *    go ahead and set the actual port width using ssSetInputPortWidth.  If
   *    the size is unacceptable an error should generated via
   *    ssSetErrorStatus.  Note that any other dynamically sized input or
   *    output ports whose widths are implicitly defined by virtue of knowing
   *    the width of the given port can also have their widths set via calls
   *    to ssSetInputPortWidth or ssSetOutputPortWidth.
   */
  static void mdlSetInputPortWidth(SimStruct *S, int port, int inputPortWidth)
  {
      int      nSamples       = (int)mxGetScalar(N_PAST_SAMPLES(S));
      int      outputPortWidth;

      if( nSamples < 1)
      {
        nSamples = 1;
      }
      else if( nSamples >= MAX_BUFFER_SIZE )
      {
        nSamples = MAX_BUFFER_SIZE;
        ssWarning(S,"Number of samples truncated!");
      }

      if (inputPortWidth > 0)
      {
          outputPortWidth =  nSamples * inputPortWidth;
          ssSetOutputPortWidth(S,0,outputPortWidth);
      }
      else
      {
          ssSetErrorStatus(S,"Input width must be greater than 0");
      }

      ssSetInputPortWidth(S,port,inputPortWidth);
  } /* end mdlSetInputPortWidth */
#endif /* MDL_SET_INPUT_PORT_WIDTH */


#define MDL_SET_OUTPUT_PORT_WIDTH   /* Change to #undef to remove function */
#if defined(MDL_SET_OUTPUT_PORT_WIDTH) && defined(MATLAB_MEX_FILE)
  /* Function: mdlSetOutputPortWidth ==========================================
   * Abstract:
   *    This method is called with the candidate width for a dynamically
   *    sized port.  If the proposed width is acceptable, the method should
   *    go ahead and set the actual port width using ssSetOutputPortWidth.  If
   *    the size is unacceptable an error should generated via
   *    ssSetErrorStatus.  Note that any other dynamically sized input or
   *    output ports whose widths are implicitly defined by virtue of knowing
   *    the width of the given port can also have their widths set via calls
   *    to ssSetInputPortWidth or ssSetOutputPortWidth.
   */
  static void mdlSetOutputPortWidth(SimStruct *S, int portIndex, int width)
  {
      ssSetOutputPortWidth(S,portIndex,width);
  } /* end mdlSetOutputPortWidth */
#endif /* MDL_SET_OUTPUT_PORT_WIDTH */


/* Function: mdlInitializeSampleTimes =========================================
 */
static void mdlInitializeSampleTimes(SimStruct *S)
{  

    real_T   sampleTimePt   = mxGetScalar(SMPL_TIM(S));
#ifndef NDEBUG
    ssPrintf("Ex?cution de \"mdlInitializeSampleTimes\":\n");
#endif /* NDEBUG */

    ssSetSampleTime(S, 0, sampleTimePt);
    ssSetOffsetTime(S, 0, 0.0);
}



#ifdef MATLAB_MEX_FILE
/* Function: isAcceptableDataType
 *    determine if the data type ID corresponds to an unsigned integer
 */
static boolean_T isAcceptableDataType(DTypeId dataType) 
{
    boolean_T isAcceptable = (dataType == SS_DOUBLE ||
                              dataType == SS_SINGLE ||
                              dataType == SS_INT8   ||
                              dataType == SS_UINT8  ||
                              dataType == SS_INT16  ||
                              dataType == SS_UINT16 ||
                              dataType == SS_INT32  ||
                              dataType == SS_UINT32 ||
                              dataType == SS_BOOLEAN);
    
    return isAcceptable;
}
#endif /* MATLAB_MEX_FILE */

#define MDL_SET_INPUT_PORT_DATA_TYPE   /* Change to #undef to remove function */
#if defined(MDL_SET_INPUT_PORT_DATA_TYPE) && defined(MATLAB_MEX_FILE)
  /* Function: mdlSetInputPortDataType =========================================
   * Abstract:
   *    This method is called with the candidate data type id for a dynamically
   *    typed input port.  If the proposed data type is acceptable, the method
   *    should go ahead and set the actual port data type using
   *    ssSetInputPortDataType.  If the data type is unacceptable an error
   *    should generated via ssSetErrorStatus.  Note that any other dynamically
   *    typed input or output ports whose data types are implicitly defined by
   *    virtue of knowing the data type of the given port can also have their
   *    data types set via calls to ssSetInputPortDataType or 
   *    ssSetOutputPortDataType.  
   *
   *    See matlabroot/simulink/include/simstruc_types.h for built-in
   *    type defines: SS_DOUBLE, SS_BOOLEAN, etc.
   *
   *    See matlabroot/simulink/src/sfun_dtype_io.c for an example. 
   */
  static void mdlSetInputPortDataType(SimStruct *S, int portIndex,DTypeId dType)
  {
#ifndef NDEBUG
    ssPrintf("Ex?cution de \"mdlSetInputPortDataType\":\n");
#endif /* NDEBUG */

    if ( ( portIndex == 0 )) {
        if( isAcceptableDataType( dType ) ) {
            /*
             * Force input port 0 to have that data type.
             */
            ssSetInputPortDataType(  S, 0, dType );            
        } else {
            /* Reject proposed data type */
            ssSetErrorStatus(S,ERR_INVALID_DTYPE);
            goto EXIT_POINT;
        }
    } else {
        /* 
         * Should not end up here.  Simulink will only call this function
         * for existing input ports whose data types are unknown.
         */
        ssSetErrorStatus(S, ERR_INVALID_SET_INPUT_DTYPE_CALL);
        goto EXIT_POINT;
    }

EXIT_POINT:
    return;
  } /* mdlSetInputPortDataType */
#endif /* MDL_SET_INPUT_PORT_DATA_TYPE */


#define MDL_SET_OUTPUT_PORT_DATA_TYPE  /* Change to #undef to remove function */
#if defined(MDL_SET_OUTPUT_PORT_DATA_TYPE) && defined(MATLAB_MEX_FILE)
  /* Function: mdlSetOutputPortDataType ========================================
   * Abstract:
   *    This method is called with the candidate data type id for a dynamically
   *    typed output port.  If the proposed data type is acceptable, the method
   *    should go ahead and set the actual port data type using
   *    ssSetOutputPortDataType.  If the data type is unacceptable an error
   *    should generated via ssSetErrorStatus.  Note that any other dynamically
   *    typed input or output ports whose data types are implicitly defined by
   *    virtue of knowing the data type of the given port can also have their
   *    data types set via calls to ssSetInputPortDataType or 
   *    ssSetOutputPortDataType.  
   *
   *    See matlabroot/simulink/src/sfun_dtype_io.c for an example. 
   */
  static void mdlSetOutputPortDataType(SimStruct *S,int portIndex,DTypeId dType)
  {
    DTypeId dTypeInput = ssGetInputPortDataType(S, 0);

#ifndef NDEBUG
    ssPrintf("Ex?cution de \"mdlSetOutputPortDataType\":\n");
#endif /* NDEBUG */

    if( isAcceptableDataType( dTypeInput ) ) {
	/*
	 * Accept input data type.
	 * Force output port to have that data type.
	 */
	ssSetOutputPortDataType( S, 0, dTypeInput );            
    } else {
	/* reject proposed data type */
	ssSetErrorStatus(S,ERR_INVALID_DTYPE);
	goto EXIT_POINT;
    }

EXIT_POINT:
    return;

  } /* mdlSetOutputPortDataType */
#endif /* MDL_SET_OUTPUT_PORT_DATA_TYPE */



#define MDL_SET_WORK_WIDTHS   /* Change to #undef to remove function */
#if defined(MDL_SET_WORK_WIDTHS) && defined(MATLAB_MEX_FILE)
  /* Function: mdlSetWorkWidths ===============================================
   * Abstract:
   *      The optional method, mdlSetWorkWidths is called after input port
   *      width, output port width, and sample times of the S-function have
   *      been determined to set any state and work vector sizes which are
   *      a function of the input, output, and/or sample times. This method
   *      is used to specify the nonzero work vector widths via the macros
   *      ssNumContStates, ssSetNumDiscStates, ssSetNumRWork, ssSetNumIWork,
   *      ssSetNumPWork, ssSetNumModes, and ssSetNumNonsampledZCs.
   *
   *      If you are using mdlSetWorkWidths, then any work vectors you are
   *      using in your S-function should be set to DYNAMICALLY_SIZED in
   *      mdlInitializeSizes, even if the exact value is know at that. The
   *      actual size to be used by the S-function should then be specified
   *      in mdlSetWorkWidths.
   */
  static void mdlSetWorkWidths(SimStruct *S)
  {
#ifndef NDEBUG
    ssPrintf("Ex?cution de \"mdlSetWorkWidths\":\n");
#endif /* NDEBUG */

    ssSetNumPWork(S, ssGetInputPortWidth(S, 0));
  }
#endif /* MDL_SET_WORK_WIDTHS */

#define MDL_START  /* Change to #undef to remove function */
#if defined(MDL_START)

#define BUFFER_SIZE_LIMITED(limit) \
        "Delay buffer has been truncated to " # limit " samples"

static void mdlStart(SimStruct *S)
{
    void     **pWork      = NULL;
    void     *initValue   = mxGetData(INIT_VALUE(S));
    int      initValueWidth = mxGetNumberOfElements(INIT_VALUE(S));
    DTypeId  dtypePar     = ssGetDTypeIdFromMxArray(INIT_VALUE(S));
    DTypeId  dtypeInp     = ssGetInputPortDataType(S, 0);
    int_T    uDTypeSize   = ssGetDataTypeSize(S, dtypeInp);
    int_T    uWidth       = ssGetInputPortWidth(S,0);
    int_T    bufSz;
    int_T    nSamples     = (int)mxGetScalar(N_PAST_SAMPLES(S));
    int_T    indPs        = 0;
    int_T    ipw;
    int_T    ipiv;
    int_T    i;
    dvtdInfo *pinfo;
      
    assert(uWidth > 0);
    
#if defined(MATLAB_MEX_FILE)
    mdlCheckParameters(S);
    if (ssGetErrorStatus(S) != NULL)
        return;
#endif

    pinfo = (dvtdInfo *)malloc(sizeof(dvtdInfo));
    
    if(pinfo != NULL)
        pinfo->delayTruncWarningDone = 0;
    
    ssSetUserData(S, (void*)pinfo);

    /* Determine buffer size */
          
    if(nSamples < 1)
      nSamples = 1;

    bufSz = nSamples;
          
    if(bufSz > MAX_BUFFER_SIZE)
    {
        bufSz = MAX_BUFFER_SIZE;
        nSamples = bufSz;
        ssWarning(S, BUFFER_SIZE_LIMITED( MAX_BUFFER_SIZE ));
    }
          
          
#ifndef NDEBUG
      printf("mdlStart: number of past samples = %d, bufSz = %d\n", nSamples, bufSz);
      printf("mdlStart: dtypePar = %d, dtypeInp = %d\n",(int)dtypePar,
              (int)dtypeInp);
#endif

    /* Allocate memory for work arrays */
          
    pWork = (void **)calloc(uWidth, sizeof(void *));
          
    if(pWork != NULL)
    {
      for(ipw = 0; ipw < uWidth; ++ipw)
      {
        pWork[ipw] = calloc(bufSz, uDTypeSize);
                  
        if(pWork[ipw] != NULL)
        {

          ipiv = initValueWidth == 1 ? 0 : ipw;
          
          if(dtypeInp ==  SS_DOUBLE)
          {
            real_T   *uBuffer = (real_T *)pWork[ipw];

            switch(dtypePar)
            {
              case SS_DOUBLE: for(i=0;i<bufSz;++i)
                                uBuffer[i] = ((real_T *)initValue)[ipiv];
                            break;
              case SS_SINGLE: for(i=0;i<bufSz;++i)
                                uBuffer[i] = ((real32_T *)initValue)[ipiv];
                            break;
              case SS_INT8: for(i=0;i<bufSz;++i)
                                uBuffer[i] = ((int8_T *)initValue)[ipiv];
                            break;
              case SS_INT16: for(i=0;i<bufSz;++i)
                                uBuffer[i] = ((int16_T *)initValue)[ipiv];
                             break;
              case SS_INT32: for(i=0;i<bufSz;++i)
                                uBuffer[i] = ((int32_T *)initValue)[ipiv];
                             break;
              case SS_UINT8: for(i=0;i<bufSz;++i)
                                uBuffer[i] = ((uint8_T *)initValue)[ipiv];
                             break;
              case SS_UINT16: for(i=0;i<bufSz;++i)
                                uBuffer[i] = ((uint16_T *)initValue)[ipiv];
                               break;
              case SS_UINT32: for(i=0;i<bufSz;++i)
                                uBuffer[i] = ((uint32_T *)initValue)[ipiv];
                           break;
            }
          }
          else if(dtypeInp ==  SS_SINGLE)
          {
            real32_T *uBuffer = (real32_T *)pWork[ipw]; 

            switch(dtypePar)
            {
              case SS_SINGLE: for(i=0;i<bufSz;++i)
                                uBuffer[i] = ((real32_T *)initValue)[ipiv];
                            break;
              case SS_INT8: for(i=0;i<bufSz;++i)
                                uBuffer[i] = ((int8_T *)initValue)[ipiv];
                            break;
              case SS_INT16: for(i=0;i<bufSz;++i)
                                uBuffer[i] = ((int16_T *)initValue)[ipiv];
                             break;
              case SS_UINT8: for(i=0;i<bufSz;++i)
                                uBuffer[i] = ((uint8_T *)initValue)[ipiv];
                             break;
              case SS_UINT16: for(i=0;i<bufSz;++i)
                                uBuffer[i] = ((uint16_T *)initValue)[ipiv];
                             break;
            }
          }
          else if(dtypeInp ==  SS_INT8)
          {
            int8_T *uBuffer = (int8_T *)pWork[ipw]; 

            for(i=0;i<bufSz;++i) uBuffer[i] = ((int8_T *)initValue)[ipiv];
          }
          else if(dtypeInp ==  SS_UINT8)
          {
            uint8_T *uBuffer = (uint8_T *)pWork[ipw]; 

            for(i=0;i<bufSz;++i) uBuffer[i] = ((uint8_T *)initValue)[ipiv];
          }
          else if(dtypeInp ==  SS_INT16)
          {
            int16_T *uBuffer = (int16_T *)pWork[ipw];

            switch(dtypePar)
            {
              case SS_INT8: for(i=0;i<bufSz;++i)
                                uBuffer[i] = ((int8_T *)initValue)[ipiv];
                            break;
              case SS_INT16: for(i=0;i<bufSz;++i)
                                uBuffer[i] = ((int16_T *)initValue)[ipiv];
                            break;
            }
          }
          else if(dtypeInp ==  SS_UINT16)
          {
            uint16_T *uBuffer = (uint16_T *)pWork[ipw]; 

            switch(dtypePar)
            {
              case SS_UINT8: for(i=0;i<bufSz;++i)
                                uBuffer[i] = ((uint8_T *)initValue)[ipiv];
                             break;
              case SS_UINT16: for(i=0;i<bufSz;++i)
                                uBuffer[i] = ((uint16_T *)initValue)[ipiv];
                             break;
            }
          }
          else if(dtypeInp ==  SS_INT32)
          {
            int32_T *uBuffer = (int32_T *)pWork[ipw]; 

            switch(dtypePar)
            {
              case SS_INT8: for(i=0;i<bufSz;++i)
                                uBuffer[i] = ((int8_T *)initValue)[ipiv];
                          break;
              case SS_INT16: for(i=0;i<bufSz;++i)
                                uBuffer[i] = ((int16_T *)initValue)[ipiv];
                             break;
              case SS_INT32: for(i=0;i<bufSz;++i)
                                uBuffer[i] = ((int32_T *)initValue)[ipiv];
                               break;
            }
          }
          else if(dtypeInp ==  SS_UINT32)
          {
            uint32_T *uBuffer = (uint32_T *)pWork[ipw]; 

            switch(dtypePar)
            {
              case SS_UINT8: for(i=0;i<bufSz;++i)
                                uBuffer[i] = ((uint8_T *)initValue)[ipiv];
                             break;
              case SS_UINT16: for(i=0;i<bufSz;++i)
                                uBuffer[i] = ((uint16_T *)initValue)[ipiv];
                             break;
              case SS_UINT32: for(i=0;i<bufSz;++i)
                                uBuffer[i] = ((uint32_T *)initValue)[ipiv];
                             break;
            }
          }
          else if(dtypeInp ==  SS_BOOLEAN)
          {
            boolean_T *uBuffer = (boolean_T *)pWork[ipw]; 

            for(i=0;i<bufSz;++i) uBuffer[i] = ((boolean_T *)initValue)[ipiv];
          }

        }
      }
    }
          
    ssGetPWork(S) = pWork;
    ssSetIWorkValue(S,IND_PS_IDX,indPs);
    ssSetIWorkValue(S,BUF_SZ_IDX,bufSz);
}
#endif /* MDL_START */

#ifndef NDEBUG
    static unsigned long numPassage = 0;
#endif

/* Function: mdlOutputs =======================================================
 * Abstract:
 *      y = uBuffer[indDelay]
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
    int_T    uWidth            = ssGetInputPortWidth(S,0);
    DTypeId  dtypeInp          = ssGetInputPortDataType(S, 0);
    int_T    nSmpl             = ssGetIWorkValue(S,BUF_SZ_IDX);
    int_T    indPs             = ssGetIWorkValue(S,IND_PS_IDX);

    
#ifndef NDEBUG
    ++numPassage;
#endif

    assert(uWidth > 0);

    switch(dtypeInp)
    {
      case SS_DOUBLE:
      {
        INPUT_PRESENT_SAMPLES(S, indPs, uWidth, real_T);
        OUTPUT_PAST_SAMPLES(S, indPs, uWidth, nSmpl, real_T);

        break;
      }

      case SS_SINGLE:
      {
        INPUT_PRESENT_SAMPLES(S, indPs, uWidth, real32_T);
        OUTPUT_PAST_SAMPLES(S, indPs, uWidth, nSmpl, real32_T);

        break;
      }

      case SS_INT8:
      {
        INPUT_PRESENT_SAMPLES(S, indPs, uWidth, int8_T);
        OUTPUT_PAST_SAMPLES(S, indPs, uWidth, nSmpl, int8_T);

        break;
      }

      case SS_INT16:
      {
        INPUT_PRESENT_SAMPLES(S, indPs, uWidth, int16_T);
        OUTPUT_PAST_SAMPLES(S, indPs, uWidth, nSmpl, int16_T);

        break;
      }

      case SS_INT32:
      {
        INPUT_PRESENT_SAMPLES(S, indPs, uWidth, int32_T);
        OUTPUT_PAST_SAMPLES(S, indPs, uWidth, nSmpl, int32_T);

        break;
      }

      case SS_UINT8:
      {
        INPUT_PRESENT_SAMPLES(S, indPs, uWidth, uint8_T);
        OUTPUT_PAST_SAMPLES(S, indPs, uWidth, nSmpl, uint8_T);

        break;
      }

      case SS_UINT16:
      {
        INPUT_PRESENT_SAMPLES(S, indPs, uWidth, uint16_T);
        OUTPUT_PAST_SAMPLES(S, indPs, uWidth, nSmpl, uint16_T);

        break;
      }

      case SS_UINT32:
      {
        INPUT_PRESENT_SAMPLES(S, indPs, uWidth, uint32_T);
        OUTPUT_PAST_SAMPLES(S, indPs, uWidth, nSmpl, uint32_T);

        break;
      }

      case SS_BOOLEAN:
      {
        INPUT_PRESENT_SAMPLES(S, indPs, uWidth, boolean_T);
        OUTPUT_PAST_SAMPLES(S, indPs, uWidth, nSmpl, boolean_T);

        break;
      }

    }

    if(++indPs == nSmpl)
        indPs = 0;
        
    ssSetIWorkValue(S,IND_PS_IDX,indPs);
    
} /* end mdlOutputs */

#undef MDL_UPDATE
#if defined(MDL_UPDATE)
/* Function: mdlUpdate ======================================================
 * Abstract:
   *    This function is called once for every major integration time step.
   *    Discrete states are typically updated here, but this function is useful
   *    for performing any tasks that should only take place once per
   *    integration step.
 */
static void mdlUpdate(SimStruct *S, int_T tid)
{ 
    int_T   nSmpl      = ssGetIWorkValue(S,BUF_SZ_IDX) - 1;
    int_T   indPs      = ssGetIWorkValue(S,IND_PS_IDX);
    int_T   uWidth     = ssGetInputPortWidth(S,0);
    DTypeId dtypeInp   = ssGetInputPortDataType(S, 0);
    
    
    indPs = indPs < nSmpl ? indPs+1 : 0;
    

#ifndef NDEBUG
    if(numPassage == 1 || (numPassage % 357) == 0)
        printf("mdlUpdate: indPs = %d\n",indPs);
#endif

    /* Keep present values in buffers */

    switch(dtypeInp)
    {
      case SS_DOUBLE:
      {
        INPUT_PRESENT_SAMPLES(S, indPs, uWidth, real_T);

        break;
      }

      case SS_SINGLE:
      {
        INPUT_PRESENT_SAMPLES(S, indPs, uWidth, real32_T);

        break;
      }

      case SS_INT8:
      {
        INPUT_PRESENT_SAMPLES(S, indPs, uWidth, int8_T);

        break;
      }

      case SS_INT16:
      {
        INPUT_PRESENT_SAMPLES(S, indPs, uWidth, int16_T);

        break;
      }

      case SS_INT32:
      {
        INPUT_PRESENT_SAMPLES(S, indPs, uWidth, int32_T);

        break;
      }

      case SS_UINT8:
      {
        INPUT_PRESENT_SAMPLES(S, indPs, uWidth, uint8_T);

        break;
      }

      case SS_UINT16:
      {
        INPUT_PRESENT_SAMPLES(S, indPs, uWidth, uint16_T);

        break;
      }

      case SS_UINT32:
      {
        INPUT_PRESENT_SAMPLES(S, indPs, uWidth, uint32_T);

        break;
      }

      case SS_BOOLEAN:
      {
        INPUT_PRESENT_SAMPLES(S, indPs, uWidth, boolean_T);

        break;
      }

    }

    ssSetIWorkValue(S,IND_PS_IDX,indPs);

}
#endif /* MDL_UPDATE */


/* Function: mdlTerminate =====================================================
 */
static void mdlTerminate(SimStruct *S)
{
    int_T  uWidth  = ssGetInputPortWidth(S,0);
    int_T  ipw;
    void   **pWork = ssGetPWork(S);
    void   *pinfo  = ssGetUserData(S);
    
    assert(uWidth > 0);

#ifndef NDEBUG
    ssPrintf("Ex?cution de \"mdlTerminate\":\n");
#endif /* NDEBUG */

    if(pinfo != NULL)
        free(pinfo);

    if(pWork != NULL)
    {
        for(ipw = 0; ipw < uWidth; ++ipw)
        {
            if(pWork[ipw] != NULL)
                free(pWork[ipw]);
        }
        
        free((void *)pWork);
    }
}


#define MDL_RTW  /* Change to #undef to remove function */
#if defined(MDL_RTW) && (defined(MATLAB_MEX_FILE) || defined(NRT))
  /* Function: mdlRTW =========================================================
   * Abstract:
   *
   *    This function is called when the Real-Time Workshop is generating
   *    the model.rtw file. In this method, you can call the following
   *    functions which add fields to the model.rtw file.
   *
   *    1) The following creates Parameter records for your S-functions.
   *       nParams is the number of tunable S-function parameters.
   *
   *       if ( !ssWriteRTWParameters(S, nParams,
   *
   *                                  SSWRITE_VALUE_[type],paramName,stringInfo,
   *                                  [type specific arguments below]
   *
   *                                 ) ) {
   *           return; (error reporting will be handled by SL)
   *       }
   *
   *       Where SSWRITE_VALUE_[type] can be one of the following groupings
   *       (and you must have "nParams" such groupings):
   *
   *         SSWRITE_VALUE_VECT,
   *           const char_T *paramName,
   *           const char_T *stringInfo,
   *           const real_T *valueVect,
   *           int_T        vectLen
   *
   *         SSWRITE_VALUE_2DMAT,
   *           const char_T *paramName,
   *           const char_T *stringInfo,
   *           const real_T *valueMat,
   *           int_T        nRows,
   *           int_T        nCols
   *
   *         SSWRITE_VALUE_DTYPE_VECT,
   *           const char_T   *paramName,
   *           const char_T   *stringInfo,
   *           const void     *valueVect,
   *           int_T          vectLen,
   *           int_T          dtInfo
   *
   *         SSWRITE_VALUE_DTYPE_2DMAT,
   *           const char_T   *paramName,
   *           const char_T   *stringInfo,
   *           const void     *valueMat,
   *           int_T          nRows,
   *           int_T          nCols,
   *           int_T          dtInfo
   *
   *         SSWRITE_VALUE_DTYPE_ML_VECT,
   *           const char_T   *paramName,
   *           const char_T   *stringInfo,
   *           const void     *rValueVect,
   *           const void     *iValueVect,
   *           int_T          vectLen,
   *           int_T          dtInfo
   *
   *         SSWRITE_VALUE_DTYPE_ML_2DMAT,
   *           const char_T   *paramName,
   *           const char_T   *stringInfo,
   *           const void     *rValueMat,
   *           const void     *iValueMat,
   *           int_T          nRows,
   *           int_T          nCols,
   *           int_T          dtInfo
   *
   *       Notes:
   *       1. nParams is an integer and stringInfo is a string describing
   *          generalinformation about the parameter such as how it was derived.
   *       2. The last argument to this function, dtInfo, is obtained from the
   *          DTINFO macro (defined in simstruc.h) as:
   *                 dtInfo = DTINFO(dataTypeId, isComplexSignal);
   *          where dataTypeId is the data type id and isComplexSignal is a
   *          boolean value specifying whether the parameter is complex.
   *
   *       See simulink/include/simulink.c for the definition (implementation)
   *       of this function and simulink/src/sfun_multiport.c for an example
   *       of using this function.
   *
   *    2) The following creates SFcnParameterSetting record for S-functions
   *       (these can be derived from the non-tunable S-function parameters).
   *
   *       if ( !ssWriteRTWParamSettings(S, nParamSettings,
   *
   *                                     SSWRITE_VALUE_[whatever], settingName,
   *                                     [type specific arguments below]
   *
   *                                    ) ) {
   *           return; (error reporting will be handled by SL)
   *       }
   *
   *       Where SSWRITE_VALUE_[type] can be one of the following groupings
   *       (and you must have "nParamSettings" such groupings):
   *       Also, the examples in the right hand column below show how the
   *       ParamSetting appears in the .rtw file
   *
   *         SSWRITE_VALUE_STR,              - Used to write (un)quoted strings
   *           const char_T *settingName,      example:
   *           const char_T *value,              Country      USA
   *
   *         SSWRITE_VALUE_QSTR,             - Used to write quoted strings
   *           const char_T *settingName,      example:
   *           const char_T *value,              Country      "U.S.A"
   *
   *         SSWRITE_VALUE_VECT_STR,         - Used to write vector of strings
   *           const char_T *settingName,      example:
   *           const char_T *value,              Countries    ["USA", "Mexico"]
   *           int_T        nItemsInVect
   *
   *         SSWRITE_VALUE_NUM,              - Used to write numbers
   *           const char_T *settingName,      example:
   *           const real_T value                 NumCountries  2
   *
   *
   *         SSWRITE_VALUE_VECT,             - Used to write numeric vectors
   *           const char_T *settingName,      example:
   *           const real_T *settingValue,       PopInMil        [300, 100]
   *           int_T        vectLen
   *
   *         SSWRITE_VALUE_2DMAT,            - Used to write 2D matrices
   *           const char_T *settingName,      example:
   *           const real_T *settingValue,       PopInMilBySex  Matrix(2,2)
   *           int_T        nRows,                   [[170, 130],[60, 40]]
   *           int_T        nCols
   *
   *         SSWRITE_VALUE_DTYPE_NUM,        - Used to write numeric vectors
   *           const char_T   *settingName,    example: int8 Num 3+4i
   *           const void     *settingValue,   written as: [3+4i]
   *           int_T          dtInfo
   *
   *
   *         SSWRITE_VALUE_DTYPE_VECT,       - Used to write data typed vectors
   *           const char_T   *settingName,    example: int8 CArray [1+2i 3+4i]
   *           const void     *settingValue,   written as:
   *           int_T          vectLen             CArray  [1+2i, 3+4i]
   *           int_T          dtInfo
   *
   *
   *         SSWRITE_VALUE_DTYPE_2DMAT,      - Used to write data typed 2D
   *           const char_T   *settingName     matrices
   *           const void     *settingValue,   example:
   *           int_T          nRow ,            int8 CMatrix  [1+2i 3+4i; 5 6]
   *           int_T          nCols,            written as:
   *           int_T          dtInfo               CMatrix         Matrix(2,2)
   *                                                [[1+2i, 3+4i]; [5+0i, 6+0i]]
   *
   *
   *         SSWRITE_VALUE_DTYPE_ML_VECT,    - Used to write complex matlab data
   *           const char_T   *settingName,    typed vectors example:
   *           const void     *settingRValue,  example: int8 CArray [1+2i 3+4i]
   *           const void     *settingIValue,      settingRValue: [1 3]
   *           int_T          vectLen              settingIValue: [2 4]
   *           int_T          dtInfo
   *                                             written as:
   *                                                CArray    [1+2i, 3+4i]
   *
   *         SSWRITE_VALUE_DTYPE_ML_2DMAT,   - Used to write matlab complex
   *           const char_T   *settingName,    data typed 2D matrices
   *           const void     *settingRValue,  example
   *           const void     *settingIValue,      int8 CMatrix [1+2i 3+4i; 5 6]
   *           int_T          nRows                settingRValue: [1 5 3 6]
   *           int_T          nCols,               settingIValue: [2 0 4 0]
   *           int_T          dtInfo
   *                                              written as:
   *                                              CMatrix         Matrix(2,2)
   *                                                [[1+2i, 3+4i]; [5+0i, 6+0i]]
   *
   *       Note, The examples above show how the ParamSetting is written out
   *       to the .rtw file
   *
   *       See simulink/include/simulink.c for the definition (implementation)
   *       of this function and simulink/src/sfun_multiport.c for an example
   *       of using this function.
   *
   *    3) The following creates the work vector records for S-functions
   *
   *       if (!ssWriteRTWWorkVect(S, vectName, nNames,
   *
   *                            name, size,   (must have nNames of these pairs)
   *                                 :
   *                           ) ) {
   *           return;  (error reporting will be handled by SL)
   *       }
   *
   *       Notes:
   *         a) vectName must be either "RWork", "IWork" or "PWork"
   *         b) nNames is an int_T (integer), name is a const char_T* (const
   *            char pointer) and size is int_T, and there must be nNames number
   *            of [name, size] pairs passed to the function.
   *         b) intSize1+intSize2+ ... +intSizeN = ssGetNum<vectName>(S)
   *            Recall that you would have to set ssSetNum<vectName>(S)
   *            in one of the initialization functions (mdlInitializeSizes
   *            or mdlSetWorkVectorWidths).
   *
   *       See simulink/include/simulink.c for the definition (implementation)
   *       of this function, and ... no example yet :(
   *
   *    4) Finally the following functions/macros give you the ability to write
   *       arbitrary strings and [name, value] pairs directly into the .rtw
   *       file.
   *
   *       if (!ssWriteRTWStr(S, const_char_*_string)) {
   *          return;
   *       }
   *
   *       if (!ssWriteRTWStrParam(S, const_char_*_name, const_char_*_value)) {
   *          return;
   *       }
   *
   *       if (!ssWriteRTWScalarParam(S, const_char_*_name, 
   *                                  const_void_*_value,
   *                                  DTypeId_dtypeId)) {
   *          return;
   *       }
   *
   *       if (!ssWriteRTWStrVectParam(S, const_char_*_name,
   *                                   const_char_*_value,
   *                                   int_num_items)) {
   *          return;
   *       }
   *
   *       if (!ssWriteRTWVectParam(S, const_char_*_name, const_void_*_value,
   *                                int_data_type_of_value, int_vect_len)){
   *          return;
   *       }
   *
   *       if (!ssWriteRTW2dMatParam(S, const_char_*_name, const_void_*_value,
   *                        int_data_type_of_value, int_nrows, int_ncols)){
   *          return;
   *       }
   *
   *       The 'data_type_of_value' input argument for the above two macros is
   *       obtained using
   *          DTINFO(dTypeId, isComplex),
   *       where
   *          dTypeId: can be any one of the enum values in BuitlInDTypeID
   *                   (SS_DOUBLE, SS_SINGLE, SS_INT8, SS_UINT8, SS_INT16,
   *                   SS_UINT16, SS_INT32, SS_UINT32, SS_BOOLEAN defined
   *                   in simstuc_types.h)
   *          isComplex: is either 0 or 1, as explained in Note-2 for
   *                    ssWriteRTWParameters.
   *
   *       For example DTINFO(SS_INT32,0) is a non-complex 32-bit signed
   *       integer.
   *
   *       If isComplex==1, then it is assumed that 'const_void_*_value' array
   *       has the real and imaginary parts arranged in an interleaved manner
   *       (i.e., Simulink Format).
   *
   *       If you prefer to pass the real and imaginary parts as two seperate
   *       arrays, you should use the follwing macros:
   *
   *       if (!ssWriteRTWMxVectParam(S, const_char_*_name,
   *                                  const_void_*_rvalue, const_void_*_ivalue,
   *                                  int_data_type_of_value, int_vect_len)){
   *          return;
   *       }
   *
   *       if (!ssWriteRTWMx2dMatParam(S, const_char_*_name,
   *                                   const_void_*_rvalue, const_void_*_ivalue,
   *                                   int_data_type_of_value,
   *                                   int_nrows, int_ncols)){
   *          return;
   *       }
   *
   *       See simulink/include/simulink.c and simstruc.h for the definition 
   *       (implementation) of these functions and simulink/src/ml2rtw.c for 
   *       examples of using these functions.
   *
   */
  static void mdlRTW(SimStruct *S)
  {
  
    int_T  uWidth  = ssGetInputPortWidth(S,0);

#ifndef NDEBUG
    ssPrintf("Ex?cution de \"mdlRTW\":\n");
#endif /* NDEBUG */

    /* Write informations on Work structures */
    
    if (!ssWriteRTWWorkVect(S,
                         "PWork", 1,
                             "uBuffers", uWidth) )
    {
      return;  /* Error reporting will be handled by Simulink */
    }

    if (!ssWriteRTWWorkVect(S,
                             "IWork", IWORKS_NUMBER,
                             "indPs", 1,
                             "bufSz", 1) )
    {
      return;  /* Error reporting will be handled by Simulink */
    }

#ifndef NDEBUG
    ssPrintf("mdlRTW: avant l'ecriture des parametres\n");
#endif /* NDEBUG */

    /*
     * Write out the non tunable parameters.
     */
    {
        real_T   pastSamples  = (real_T)mxGetScalar(N_PAST_SAMPLES(S));
        real_T   sampleTime  = (real_T)mxGetScalar(SMPL_TIM(S));
        void     *initValue   = mxGetData(INIT_VALUE(S));
        int      initValueWidth = mxGetNumberOfElements(INIT_VALUE(S));
        DTypeId  dtypePar     = ssGetDTypeIdFromMxArray(INIT_VALUE(S));
        int_T    uWidth       = ssGetInputPortWidth(S,0);


#ifndef NDEBUG
        int i;
        
        ssPrintf("mdlRTW: avant ssWriteRTWParamSettings\n");
        ssPrintf("        pastSamples = %g\n", pastSamples);
        ssPrintf("        sampleTime = %g\n", sampleTime);
        ssPrintf("        uWidth = %d\n", uWidth);
        ssPrintf("        typePar = %s\n", simulinkTypeName(dtypePar));
        
        
        for(i = 0; i < uWidth; ++i)
        {
            
            switch(dtypePar)
            {
              case SS_DOUBLE:  ssPrintf("          initValue[%d] = %g\n", i, ((real_T*)initValue)[i]);
                               break;
              case SS_SINGLE:  ssPrintf("          initValue[%d] = %g\n", i, ((real32_T*)initValue)[i]);
                               break;
              case SS_INT8:    ssPrintf("          initValue[%d] = %d\n", i, ((int8_T*)initValue)[i]);
                               break;
              case SS_UINT8:   ssPrintf("          initValue[%d] = %u\n", i, ((uint8_T*)initValue)[i]);
                               break;
              case SS_INT16:   ssPrintf("          initValue[%d] = %d\n", i, ((int16_T*)initValue)[i]);
                               break;
              case SS_UINT16:  ssPrintf("          initValue[%d] = %u\n", i, ((uint16_T*)initValue)[i]);
                               break;
              case SS_INT32:   ssPrintf("          initValue[%d] = %d\n", i, ((int32_T*)initValue)[i]);
                               break;
              case SS_UINT32:  ssPrintf("          initValue[%d] = %u\n", i, ((uint32_T*)initValue)[i]);
                               break;
              case SS_BOOLEAN: ssPrintf("          initValue[%d] = %s\n", i, 
               ((boolean_T*)initValue)[i] == TRUE ? "TRUE" : "FALSE");
                               break;
            }
        }
#endif /* NDEBUG */

        if (!ssWriteRTWParamSettings(S, NPARAMS,
                                  SSWRITE_VALUE_NUM,
                                      "pastSamples",pastSamples,
                                  SSWRITE_VALUE_NUM,
                                      "sampleTime",sampleTime,
                                  SSWRITE_VALUE_DTYPE_VECT,
                                      "initValue", initValue, initValueWidth,
                                       DTINFO(dtypePar, 0)))
        {
            return; /* An error occurred which will be reported by Simulink */
        }
   }
  }
#endif /* MDL_RTW */


/*=============================*
 * Required S-function trailer *
 *=============================*/

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif


