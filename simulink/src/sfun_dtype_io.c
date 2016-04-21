/*
 *   SFUN_DTYPE_IO C-MEX S-function example for data typed input and 
 *                 output ports.
 *
 *   The real purpose of this example is to serve as a very simple 
 *   introduction to the use of simulink data types for inputs and outputs.
 *
 *   PORT PROPERTIES:
 *   - The block has three input ports and one output port. 
 *   - u0 and u1 are data input ports, and u2 is the control input port.
 *   - The first two input ports and the output port are DYNAMICALLY_SIZED and 
 *     have inherited datatypes.
 *   - The third input port is a boolean scalar signal.
 *
 *   BLOCK OPERATION:
 *     The nominal operation is as follows:
 *        If u2 is true (1) 
 *           y0 = u0 BITWISE_OR u1
 *        otherwise
 *           y0 = u0 BITWISE_XOR u1
 *
 *   BLOCK RULES:
 *   - Width rule: Width of u0, u1 and y0 are the same.
 *   - Data type rule: u0, u1 and y0 have the same data types, and they only 
 *     accept unsigned integer types, i.e., uint8, uint16 and uint32.
 *                     
 *  Authors: M. Shakeri
 *  Copyright 1990-2004 The MathWorks, Inc.
 *  $Revision: 1.4.4.2 $  $Date: 2004/04/14 23:49:45 $
 */

/*=====================================*
 * Required setup for C MEX S-Function *
 *=====================================*/
#define S_FUNCTION_NAME  sfun_dtype_io
#define S_FUNCTION_LEVEL 2


/* define error messages */
#define ERR_INVALID_SET_INPUT_DTYPE_CALL  \
              "Invalid call to mdlSetInputPortDataType"

#define ERR_INVALID_SET_OUTPUT_DTYPE_CALL \
              "Invalid call to mdlSetOutputPortDataType"

#define ERR_INVALID_DTYPE     "Invalid input or output port data type"


/*========================*
g* General Defines/macros *
*========================*/

/*
 * Need to include simstruc.h for the definition of the SimStruct and
 * its associated macro definitions.
 */
#include "simstruc.h" 

#define TRUE 1
#define FALSE 0

/* total number of block parameters */
#define N_PAR                0


/* Function: mdlInitializeSizes ===============================================
 * Abstract:
 *   Initialize the sizes array
 */
static void mdlInitializeSizes(SimStruct *S)
{
    /* Set and Check parameter count  */
    ssSetNumSFcnParams(S, N_PAR);

    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) return;

    /* Inputs */
    if ( !ssSetNumInputPorts(  S, 3 ) ) return;
            
    /*
     * input 0 is dynamically sized and  typed.
     *   Via data type propagation, Simulink will propose data types for
     *   any ports that are dynamically typed.  Simulink will call the function
     *   mdlSetInputPortDataType or mdlSetOutputPortDataType.  These functions
     *   can accept the proposed data type or refuse it, i.e. error out.  These
     *   functions also have the opportunity to use all currently available
     *   information to set any input or output data types that are still 
     *   dynamically typed.  A typically example is to force an output to
     *   be the same as the data type that was just proposed for an input
     *   (or visa versa).
     */
    ssSetInputPortWidth(             S, 0, DYNAMICALLY_SIZED );
    ssSetInputPortDataType(          S, 0, DYNAMICALLY_TYPED );
    ssSetInputPortDirectFeedThrough( S, 0, TRUE );

    /* input 1 is dynamically sized and  typed. */
    ssSetInputPortWidth(             S, 1, DYNAMICALLY_SIZED );
    ssSetInputPortDataType(          S, 1, DYNAMICALLY_TYPED );
    ssSetInputPortDirectFeedThrough( S, 1, TRUE );

    /* input 2 is a boolean scalar signal. */
    ssSetInputPortWidth(             S, 2, 1 );
    ssSetInputPortDataType(          S, 2, SS_BOOLEAN );
    ssSetInputPortDirectFeedThrough( S, 2, TRUE );

    /* outputs */
    if ( !ssSetNumOutputPorts( S, 1 ) ) return;
    
    /* output 0 is dynamically sized and typed. */
    ssSetOutputPortWidth(    S, 0, DYNAMICALLY_SIZED );
    ssSetOutputPortDataType( S, 0, DYNAMICALLY_TYPED );

    /* sample times */
    ssSetNumSampleTimes(   S, 1 );
    
    /* options */
    ssSetOptions(S,
                 SS_OPTION_WORKS_WITH_CODE_REUSE |
                 SS_OPTION_EXCEPTION_FREE_CODE);
    
} /* end mdlInitializeSizes */



/* Function: mdlInitializeSampleTimes =========================================
 * Abstract:
 *    Initialize the sample times array.
 */
static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime( S, 0, INHERITED_SAMPLE_TIME );
    ssSetOffsetTime( S, 0, FIXED_IN_MINOR_STEP_OFFSET );
    ssSetModelReferenceSampleTimeDefaultInheritance(S);
} /* end mdlInitializeSampleTimes */

#define OR_OP(x,y)   ((x) | (y))
#define XOR_OP(x,y)  ((x) ^ (y)) 

/* Function: mdlOutputs =======================================================
 * Abstract:
 *   Compute the outputs of the S-function.
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
    /* 
     * Get "uPtrs" for input port 0 and 1.  
     * uPtrs is essentially a vector of pointers because the input signal may 
     * not be contiguous.  
     */

    InputPtrsType u0Ptrs = ssGetInputPortSignalPtrs(S,0);
    InputPtrsType u1Ptrs = ssGetInputPortSignalPtrs(S,1);

    /* The control port is a boolean signal */
    InputBooleanPtrsType u2Ptr = (InputBooleanPtrsType)
                                           ssGetInputPortSignalPtrs(S,2);
    boolean_T doOR = (*u2Ptr[0] != 0);
    
    /* 
     * Get data type Identifier for output port 0. Note, this matches the data 
     * type ID for input port 0 and 1.
     */
    DTypeId   y0DataType = ssGetOutputPortDataType(S, 0);
    int_T     y0Width    = ssGetOutputPortWidth(S, 0);

    /* 
     * This s-function must work for three different data type cases.
     * In essence, three different versions of mdlOutputs are needed.
     * Using the data type ID obtained above, a switch will control
     * which "version" of mdlOutputs is used.
     */
    switch (y0DataType)
    {
        case SS_UINT8:
        {
            uint8_T            *pY0 = (uint8_T *)ssGetOutputPortSignal(S,0);
            InputUInt8PtrsType pU0  = (InputUInt8PtrsType)u0Ptrs;
            InputUInt8PtrsType pU1  = (InputUInt8PtrsType)u1Ptrs;
            int     i;
            
            for( i = 0; i < y0Width; ++i){
                /* Implement the bitwise OR or XOR*/
                pY0[i] = (doOR)? OR_OP (*pU0[i],*pU1[i]) :
                                 XOR_OP(*pU0[i],*pU1[i]);
            }
   
            break;
        }
        case SS_UINT16:
        {
            uint16_T            *pY0 = (uint16_T *)ssGetOutputPortSignal(S,0);
            InputUInt16PtrsType pU0  = (InputUInt16PtrsType)u0Ptrs;
            InputUInt16PtrsType pU1  = (InputUInt16PtrsType)u1Ptrs;
            int     i;
        
            for( i = 0; i < y0Width; ++i){
                /* Implement the bitwise OR or XOR*/
                pY0[i] = (doOR)? OR_OP( *pU0[i],*pU1[i]) :
                                 XOR_OP(*pU0[i],*pU1[i]);
            }
            break;
        }
        case SS_UINT32:
        {
            uint32_T            *pY0 = (uint32_T *)ssGetOutputPortSignal(S,0);
            InputUInt32PtrsType pU0  = (InputUInt32PtrsType)u0Ptrs;
            InputUInt32PtrsType pU1  = (InputUInt32PtrsType)u1Ptrs;
            int     i;
        
            for( i = 0; i < y0Width; ++i){
                /* Implement the bitwise OR or XOR*/
                pY0[i] = (doOR)? OR_OP (*pU0[i],*pU1[i]) :
                                 XOR_OP(*pU0[i],*pU1[i]);
            }
         
            break;
        }
    } /* end switch (y0DataType) */

} /* end mdlOutputs */



/* Function: mdlTerminate =====================================================
 * Abstract:
 *    Called when the simulation is terminated.
 */
static void mdlTerminate(SimStruct *S)
{
} /* end mdlTerminate */


/* Function: isAcceptableDataType
 *    determine if the data type ID corresponds to an unsigned integer
 */
static boolean_T isAcceptableDataType(DTypeId dataType) 
{
    boolean_T isAcceptable = (dataType == SS_UINT8  || 
                              dataType == SS_UINT16 || 
                              dataType == SS_UINT32);
    
    return isAcceptable;
}


#ifdef MATLAB_MEX_FILE

#define MDL_SET_INPUT_PORT_DATA_TYPE
/* Function: mdlSetInputPortDataType ==========================================
 *    This routine is called with the candidate data type for a dynamically
 *    typed port.  If the proposed data type is acceptable, the routine should
 *    go ahead and set the actual port data type using ssSetInputPortDataType.
 *    If the data tyoe is unacceptable an error should generated via
 *    ssSetErrorStatus.  Note that any other dynamically typed input or
 *    output ports whose data types are implicitly defined by virtue of knowing
 *    the data type of the given port can also have their data types set via 
 *    calls to ssSetInputPortDataType or ssSetOutputPortDataType.
 */
static void mdlSetInputPortDataType(SimStruct *S, 
                                    int       port, 
                                    DTypeId   dataType)
{
    if ( ( port == 0 ) || ( port == 1 ) ) {
        if( isAcceptableDataType( dataType ) ) {
            /*
             * Accept proposed data type if it is an unsigned integer type
             * force all data ports to use this data type.
             */
            ssSetInputPortDataType(  S, 0, dataType );            
            ssSetInputPortDataType(  S, 1, dataType );            
            ssSetOutputPortDataType( S, 0, dataType );            
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


#define MDL_SET_OUTPUT_PORT_DATA_TYPE
/* Function: mdlSetOutputPortDataType =========================================
 *    This routine is called with the candidate data type for a dynamically
 *    typed port.  If the proposed data type is acceptable, the routine should
 *    go ahead and set the actual port data type using ssSetOutputPortDataType.
 *    If the data tyoe is unacceptable an error should generated via
 *    ssSetErrorStatus.  Note that any other dynamically typed input or
 *    output ports whose data types are implicitly defined by virtue of knowing
 *    the data type of the given port can also have their data types set via 
 *    calls to ssSetInputPortDataType or ssSetOutputPortDataType.
 */
static void mdlSetOutputPortDataType(SimStruct *S, 
                                     int       port, 
                                     DTypeId   dataType)
{
    if ( port == 0 ) {
        if( isAcceptableDataType( dataType ) ) {
            /*
             * Accept proposed data type if it is an unsigned integer type
             * force all the ports to use this data type.
             */
            ssSetInputPortDataType(  S, 0, dataType );            
            ssSetInputPortDataType(  S, 1, dataType );            
            ssSetOutputPortDataType( S, 0, dataType );            
        } else {
            /* reject proposed data type */
            ssSetErrorStatus(S,ERR_INVALID_DTYPE);
            goto EXIT_POINT;
        }
    } else {
        /* 
         * Should not end up here.  Simulink will only call this function
         * for existing output ports whose data types are unknown.  
         */
        ssSetErrorStatus(S, ERR_INVALID_SET_OUTPUT_DTYPE_CALL);
        goto EXIT_POINT;
    }

EXIT_POINT:
    return;

} /* mdlSetOutputPortDataType */

#define MDL_SET_DEFAULT_PORT_DATA_TYPES
/* Function: mdlSetDefaultPortDataTypes ========================================
 *    This routine is called when Simulink is not able to find data type 
 *    candidates for dynamically typed ports. This function must set the data 
 *    type of all dynamically typed ports.
 */
static void mdlSetDefaultPortDataTypes(SimStruct *S)
{
    /* Set input port data type to uint8 */
    ssSetInputPortDataType(  S, 0, SS_UINT8 );            
    ssSetInputPortDataType(  S, 1, SS_UINT8 );            
    ssSetOutputPortDataType( S, 0, SS_UINT8 );            

} /* mdlSetDefaultPortDataTypes */

#endif /* MATLAB_MEX_FILE */



/*=======================================*
* Required closing for C MEX S-Function *
*=======================================*/

#ifdef    MATLAB_MEX_FILE  /* Is this file being compiled as a MEX-file? */
# include "simulink.c"     /* MEX-file interface mechanism               */
#else
# include "cg_sfun.h"      /* Code generation registration function      */
#endif


/* [EOF] sfun_dtype_io.c */

