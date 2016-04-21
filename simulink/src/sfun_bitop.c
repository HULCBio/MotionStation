/*  File    : sfun_bitop.c
 *  Abstract:
 *
 *      A level 2 S-function to perform the bitwise operations
 *      AND, OR, XOR, left shift, right shift and one's complement
 *      on uint8, uint16 and uint32 inputs.  Output precision matches
 *      input precision.  Parameters are stored with 32 bits of precision
 *      but are masked off / modulo-ed to input precision before use.
 *      doubles can be used as parameters but get truncated to integer
 *      before use.
 *
 *      String representations of parameter values are not
 *      DBCS compliant since only ASCII 0-9 and a-f/A-F are expected.  
 *
 *  Copyright 1990-2004 The MathWorks, Inc.
 *  $Revision: 1.17.4.3 $
 */


#define S_FUNCTION_NAME  sfun_bitop
#define S_FUNCTION_LEVEL 2

#include <math.h>

#include "simstruc.h"

#define EDIT_OK(S, ARG) \
       (!((ssGetSimMode(S) == SS_SIMMODE_SIZES_CALL_ONLY) && mxIsEmpty(ARG)))

static char bitopDefMsg[] = "Internal error; suspect memory corruption";

/* Parameters for this block */

typedef enum { OP_AND=1, OP_OR, OP_XOR, OP_SHL, OP_SHR, OP_NOT } OperatorTypes;
typedef enum { OPERATOR_PIDX=0, OPERAND2_PIDX, OP2_STRING_PIDX } paramIndices;
typedef enum { LOOP_SCSC=0, LOOP_VESC, LOOP_SCVE, LOOP_VEVE } loopTypes;

static const char *OperatorNames[] = {"AND", "OR", "XOR", "SHIFT_LEFT", "SHIFT_RIGHT", "NOT"};

#define NUM_SPARAMS      3

#define OPERATOR(S)   (ssGetSFcnParam(S, OPERATOR_PIDX))
#define OPERAND2(S)   (ssGetSFcnParam(S, OPERAND2_PIDX))
#define OP2_STRING(S) (ssGetSFcnParam(S, OP2_STRING_PIDX))

/* UserData:  parameter cache inhabitants */

typedef struct SFcnCache_tag {
    OperatorTypes operator;
    uint32_T      loopFlag;
    uint32_T      numOperands;
    void          *operands;
} SFcnCache;


/* misc. definitions */

#define MAX_MSG_LENGTH 128
#define HEX_CHARS       21

static int isValidHexStr(mxArray *pa)
{
   static char *validHex = "0123456789ABCDEFabcdef";
   char *vc   = validHex;
   int   vlen = strlen(validHex);
   char  hexStr[HEX_CHARS];
   char *str  = hexStr;
   int j, k, found = 1, strStatus;
   
   strStatus = mxGetString(pa, hexStr, HEX_CHARS);
   for (j=strlen(hexStr); j > 0; j--,str++) {
     int foundChar = 0;
     for (k=vlen, vc = validHex; k > 0; k--) {
       if (*vc++ == *str) {
         foundChar = 1;
         break;
       }
     }
     if (!foundChar) {
       found = 0;
       break;
     }
   }
   return(found);
}


/* Function: mdlCheckParameters =============================================
 * Abstract:
 *    check that:
 *    o The first parameter is the operator code: should be an integer that maps
 *      to the OperatorTypes enum.
 *
 *    o The second paramenter should be a 1D cell array of strings
 *      that represent hexadecimal numbers.
 *
 */
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S)
{
    static char *invalidOpMsg = 
        "Unrecognized operator value.  Must use one of: AND, "
        "OR, XOR, SHIFT_LEFT, SHIFT_RIGHT or NOT (1 thru 6)";
    int_T i, operator;

    /* check for proper operator value */

    if (mxIsEmpty(OPERATOR(S)) ||
        !mxIsNumeric(OPERATOR(S)) ||
        mxIsComplex(OPERATOR(S)) ||
        mxGetNumberOfElements(OPERATOR(S)) > 1) {
        ssSetErrorStatus(S, invalidOpMsg);
        goto EXIT_POINT;
    } else {        
    operator = (int) mxGetScalar( OPERATOR(S) );

    if ( operator < OP_AND || operator > OP_NOT ) {
            ssSetErrorStatus(S, invalidOpMsg);
            goto EXIT_POINT;
        }
    }

    /*
     * For non-NOT, check the operand's basic properties:  
     * it must be a 1-D or 2-D cell array of strings.
     * The strings must be made up of 0-9, a-f, A-F.
     */

    if (operator != OP_NOT) {
        static char *msg = "Second operand must be a 1-D or 2-D cell array of "
            "hexadecimal strings compatible with input signal's dimensions";
        const mxArray *operand = OPERAND2(S);
        mxArray *cellElt;

        if (EDIT_OK(S, operand)) {
            /* check that the parameter is a cell array */
            if ( mxIsEmpty(operand) || !mxIsCell(operand) ) {
                ssSetErrorStatus(S, msg);
                goto EXIT_POINT;
            }

            /* OK, now check each element of the cell array */
            for ( i=0; i < mxGetNumberOfElements(operand); i++ ) {
                cellElt = mxGetCell(operand, i);
                /* elements can only be strings - the mask makes it so */
                if( mxIsEmpty(cellElt) || !mxIsChar(cellElt) ) {
                    ssSetErrorStatus(S, msg);
                    goto EXIT_POINT;
                } else {
                    if (!isValidHexStr(cellElt)) {
                        ssSetErrorStatus(S, 
                                         "Input string found with characters"
                                         " other than 0-9, a-f, or A-F");
                        goto EXIT_POINT;
                    }
                }
            }
        }
    }

 EXIT_POINT:
    return;
}  

/* Function: mdlInitializeSizes ===============================================
 * Abstract:
 *   Checks parameters and does setup on sizes of the various vectors.
 */

static void mdlInitializeSizes(SimStruct *S)
{
    int paramNumDims;
    const int *paramDims;

    /* --- There is an operator parameter and an operand parameter
     *     for all operators except one's complement, which only
     *     has an operator parameter.
     */
    static char msg[] = "Illegal parameter matrix shape specified.  "
      "Only scalar, vector and 2-D matrix supported";

    ssSetNumSFcnParams(S,NUM_SPARAMS);   /* expected number */

#if defined(MATLAB_MEX_FILE)
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) goto EXIT_POINT;
    mdlCheckParameters(S);
    if (ssGetErrorStatus(S) != NULL) goto EXIT_POINT;
#endif

    if ( !mxIsEmpty(OPERAND2(S)) ) {
        paramNumDims = mxGetNumberOfDimensions(OPERAND2(S));
        paramDims    = mxGetDimensions(OPERAND2(S));
    } else {
        /* postpone problems to mdlStart -- assume scalar */
        paramNumDims = 1;
        paramDims = &paramNumDims;
    }


    /* the parameters are not tunable */

    ssSetSFcnParamNotTunable( S, OPERATOR_PIDX );
    ssSetSFcnParamNotTunable( S, OPERAND2_PIDX );
    ssSetSFcnParamNotTunable( S, OP2_STRING_PIDX );
    
    /* there are no states */

    ssSetNumContStates( S, 0 );
    ssSetNumDiscStates( S, 0 );

    /* one input port of varying width */

    if (!ssSetNumInputPorts(S, 1)) goto EXIT_POINT;

    if (!ssSetInputPortDimensionInfo(S, 0, DYNAMIC_DIMENSION)) goto EXIT_POINT;
    ssSetInputPortDirectFeedThrough(S, 0, 1);
    ssSetInputPortDataType(S, 0, DYNAMICALLY_TYPED);
    ssSetInputPortOptimOpts(S, 0, SS_REUSABLE_AND_LOCAL);
    ssSetInputPortOverWritable(S, 0, 1);

    /*
     * one output port of varying dimensions
     */

    if (!ssSetNumOutputPorts(S,1)) goto EXIT_POINT;

    if (paramNumDims == 2 && (paramDims[0] > 1 && paramDims[1] > 1)) {
        /* actual 2-D matrix parameter */
        DECL_AND_INIT_DIMSINFO(oDims);
        int dims[2];

        dims[0] = paramDims[0];
        dims[1] = paramDims[1];

        oDims.width       = paramDims[0] * paramDims[1];
        oDims.numDims     = 2;
        oDims.dims        = dims;
        oDims.nextSigDims = NULL;

        if (!ssSetOutputPortDimensionInfo(S, 0, &oDims)) goto EXIT_POINT;
    } else if (paramNumDims == 2 && (paramDims[0] > 1 || paramDims[1] > 1)) {
        /* 1-D MATLAB parameter: could be row, col or unoriented */
        DECL_AND_INIT_DIMSINFO(oDims);

        oDims.width   = paramDims[0] * paramDims[1];
        oDims.numDims = -1;

        if (!ssSetOutputPortDimensionInfo(S, 0, &oDims)) goto EXIT_POINT;
        if (paramDims[0] == 1) {
            ssSetVectorMode(S, SS_1_D_OR_ROW_VECT);
        } else {
            ssSetVectorMode(S, SS_1_D_OR_COL_VECT);
        }
    } else {
        /* scalar, empty or n-D parameter - size as scalar */
        if (!ssSetOutputPortDimensionInfo(S, 0, DYNAMIC_DIMENSION)) goto EXIT_POINT;
    }
    ssSetOutputPortDataType(S, 0, DYNAMICALLY_TYPED);
    ssSetOutputPortOptimOpts(S, 0, SS_REUSABLE_AND_LOCAL);
    
    ssSetOptions(S,
                 SS_OPTION_WORKS_WITH_CODE_REUSE |
                 SS_OPTION_RUNTIME_EXCEPTION_FREE_CODE |
                 SS_OPTION_ALLOW_INPUT_SCALAR_EXPANSION |
                 SS_OPTION_ALLOW_PARTIAL_DIMENSIONS_CALL |
                 SS_OPTION_CAN_BE_CALLED_CONDITIONALLY |
                 SS_OPTION_USE_TLC_WITH_ACCELERATOR |
                 SS_OPTION_NONVOLATILE);

    {
        const int operator = (int) mxGetScalar( OPERATOR(S) );

        ssSetOutputPortOutputExprInRTW(S, 0, (
          operator == OP_NOT || 
          mxGetNumberOfElements(OPERAND2(S)) == 1));
        ssSetInputPortAcceptExprInRTW(S, 0, true);
    }
 EXIT_POINT:
    return;
}

/* Function: SetPortDataType ======================================== 
 * Abstract: 
 *  
 *    Set the input and output port data types.
 */ 
static void SetPortDataType(SimStruct *S, DTypeId dataTypeId )
{
    switch (dataTypeId) {
      case SS_UINT8:
      case SS_UINT16:
      case SS_UINT32:
        ssSetInputPortDataType( S, 0, dataTypeId);
        ssSetOutputPortDataType(S, 0, dataTypeId);
        break;
      default:
        /* non-predefined or unsupported input type, handle separately */

        /*     enhancement: handle fixed point w/IsFixPtDataType() */
        ssSetErrorStatus(S, "Input, output signals must be one of these types: "
                         "uint8, uint16, uint32.  " 
                         "Suggest using a data type conversion block "
                         "before the input");

    }
}

/* Function: mdlSetInputPortDataType ===========================================
 * Abstract:
 *
 */
#define MDL_SET_INPUT_PORT_DATA_TYPE
static void mdlSetInputPortDataType(SimStruct *S, int port, DTypeId dType)
{
    SetPortDataType(S, dType);
}

/* Function: mdlSetOutputPortDataType ==========================================
 * Abstract:
 *
 */
#define MDL_SET_OUTPUT_PORT_DATA_TYPE
static void mdlSetOutputPortDataType(SimStruct *S, int port, DTypeId dType)
{
    SetPortDataType(S, dType);
}

/* Function: mdlSetDefaultPortDataTypes ========================================
 * Abstract:
 *    When no forward and no backward propagation is available, use
 *    uint32 as it is compatible with all mask values.
 */
#define MDL_SET_DEFAULT_PORT_DATA_TYPES
static void mdlSetDefaultPortDataTypes(SimStruct *S)
{
    SetPortDataType(S, SS_UINT32);
}

/* Function: mdlInitializeSampleTimes =========================================
 * Abstract:
 *    Specifiy that we inherit our sample time from the driving block.
 */
static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0);
    ssSetModelReferenceSampleTimeDefaultInheritance(S);
}


/* Function: mdlStart =========================================================
 * Abstract:
 *
 *    Validate our parameters to verify they are okay.
 *    This means that the Operator is one of the recognized strings and
 *    that the Operand(s) are compatible with the input width.
 *
 *    Change the output width based on the input width and Operand2, 
 *    as follows:
 *
 *         Input  Operand2*  Output
 *         -----  ---------  ------
 *           1        1        1
 *           N        1        N
 *           1        N        N
 *           N        N**      N
 *
 *     * Operand2 not applicable if "Operator" is "NOT", so set
 *       OutputWidth = InputWidth
 *
 *    ** An error is asserted if Input N and Operand2 N are not equal.
 *
 *    Cache parameter values and precisions in UserData.
 *
 *    NOTE:  supports up to 32-bit parameters.
 */

#define MDL_START
static void mdlStart(SimStruct *S)
{
    SFcnCache *paramCache;
    uint32_T   inputWidth = ssGetInputPortWidth(S,0);
    int        paramWidth = mxGetNumberOfElements(OPERAND2(S));

    /*
     * Allocate memory blocks for UserData. allow 1 32-bit element for each
     * operand (cannot have zero elements).  
     */

    paramCache = (SFcnCache *) calloc(1, sizeof(SFcnCache) );
    if (paramCache == NULL) {
        ssSetErrorStatus(S,"Could not allocate data cache memory");
        goto EXIT_POINT;
    }

    /*
     * start populating the cache members 
     */

    /* uses two casts to fix an SGI enum cast warning */
    paramCache->operator = (OperatorTypes) (int) mxGetScalar( OPERATOR(S) );
    paramCache->numOperands = (paramCache->operator != OP_NOT) ? paramWidth : 0;

    /*
     * get the looping type flag for the cache 
     */

    if ( inputWidth == 1 ) {
        if ( paramWidth == 1 ) {
            paramCache->loopFlag = LOOP_SCSC;
        } else {
            paramCache->loopFlag = LOOP_SCVE;
        }
    } else {
        if ( paramWidth == 1 ) {
            paramCache->loopFlag = LOOP_VESC;
        } else {
            paramCache->loopFlag = LOOP_VEVE;
        }
    }


    /*
     * populate operand cache for operators other than 'NOT' 
     */

    if ( paramCache->operator != OP_NOT ) {
        mxArray  *lhs[1];
        mxArray  *rhs[1];
        double   *plhs;
        DTypeId  dType  = ssGetInputPortDataType(S,0);
        int_T    dtSize = ssGetDataTypeSize(S, dType);

        paramCache->operands = malloc( paramWidth * dtSize );
        if ( paramCache->operands == NULL ) {
            ssSetErrorStatus(S,"Could not allocate data cache memory");
            goto EXIT_POINT;
        }

        /*
         * Call into MATLAB to decode hex strings
         */

        rhs[0] = (mxArray *) OPERAND2(S);
        if (mexCallMATLAB( 1, lhs, 1, rhs, "hex2dec" ) != 0) {
            ssSetErrorStatus(S, "Error decoding second operand strings");
            goto EXIT_POINT;
        }
        plhs = mxGetPr( lhs[0] );
        
        /* 
         * fill the operands array, simply lop off extra msbs 
         */

        switch (dType) {
            int_T i;
          case SS_UINT8: {
              uint8_T *op = paramCache->operands;
              for ( i=0; i < paramCache->numOperands; i++ ) {
                  op[i] = (uint8_T)plhs[i];
              }
          }
          break;
          case SS_UINT16: {
              uint16_T *op = paramCache->operands;
              for ( i=0; i < paramCache->numOperands; i++ ) {
                  op[i] = (uint16_T)plhs[i];
              }
          }
          break;
          case SS_UINT32: {
              uint32_T *op = paramCache->operands;
              for ( i=0; i < paramCache->numOperands; i++ ) {
                  op[i] = (uint32_T)plhs[i];
              }
          }
          break;
          default:
            ssSetErrorStatus(S, bitopDefMsg);
            goto EXIT_POINT;
        }
        mxDestroyArray( lhs[0] );
    }

    ssSetUserData( S, paramCache );

 EXIT_POINT:
    if (ssGetErrorStatus(S) != NULL) {
        /* clean up */
        if (paramCache != NULL) {
            free(paramCache->operands);
        }
        free(paramCache);
        ssSetUserData(S, NULL);
    }
    return;
}


/* Function: mdlOutputs =======================================================
 * Abstract:
 *    For each input element, perform the specified operation as follows 
 *    for the width of the data port for the input data type:
 *
 *    AND: y = u & p
 *     OR: y = u | p
 *    XOR: y = u ^ p
 *    SHL: y = u << p
 *    SHR: y = u >> p
 *    NOT: y = ~u
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
    uint_T          i, *j, *k;
    uint_T          j0=0;
    uint_T          k0=0;
    InputPtrsType   uVoidPtrs   = ssGetInputPortSignalPtrs(S,0);
    void            *yVoid      = ssGetOutputPortSignal(S,0);
    uint_T          width       = ssGetOutputPortWidth(S,0);
    const SFcnCache *paramCache = ssGetUserData(S);

    /* 
     * pre-set dimensional reduction for input width iteration and 
     * parameter width iteration.  
     */

    switch ( paramCache->loopFlag ) {
      case LOOP_SCSC:
        j = &j0;
        k = &k0;
        break;
      case LOOP_SCVE:
        j = &j0;
        k = &i;
        break;
      case LOOP_VESC:
        j = &i;
        k = &k0;
        break;
      case LOOP_VEVE:
        j = &i;
        k = &i;
        break;
      default:
        ssSetErrorStatus( S, bitopDefMsg);
        return;
    }

    switch (ssGetInputPortDataType(S,0)) {
      case SS_UINT8: {
          
          uint8_T       *y = yVoid;
          const uint8_T *op = paramCache->operands;
          
          switch ( paramCache->operator ) {
            case OP_AND:
              for ( i=0; i<width; i++ ) {
                  const uint8_T *uPtr = uVoidPtrs[*j];
                  y[i] = *uPtr & op[ (*k) ];
              }
              break;
            case OP_OR:
              for ( i=0; i<width; i++ ) {
                  const uint8_T *uPtr = uVoidPtrs[*j];
                  y[i] = *uPtr | op[ (*k) ];
              }
              break;
            case OP_XOR:
              for ( i=0; i<width; i++ ) {
                  const uint8_T *uPtr = uVoidPtrs[*j];
                  y[i] = *uPtr ^ op[ (*k) ];
              }
              break;
            case OP_SHL:
              for ( i=0; i<width; i++ ) {
                  const uint8_T *uPtr = uVoidPtrs[*j];
                  y[i] = *uPtr << op[ (*k) ];
              }
              break;
            case OP_SHR:
              for ( i=0; i<width; i++ ) {
                  const uint8_T *uPtr = uVoidPtrs[*j];
                  y[i] = *uPtr >> op[ (*k) ];
              }
              break;
            case OP_NOT:
              for ( i=0; i<width; i++ ) {
                  const uint8_T *uPtr = uVoidPtrs[*j];
                  y[i] = ~(*uPtr);
              }
              break;
            default:
              break;
          }

      }
      break;

      case SS_UINT16: {

          uint16_T       *y = (uint16_T *)yVoid;
          const uint16_T *op = paramCache->operands;

          switch ( paramCache->operator ) {
            case OP_AND:
              for ( i=0; i<width; i++ ) {
                  const uint16_T *uPtr = uVoidPtrs[*j];
                  y[i] = *uPtr & op[ (*k) ];
              }
              break;
            case OP_OR:
              for ( i=0; i<width; i++ ) {
                  const uint16_T *uPtr = uVoidPtrs[*j];
                  y[i] = *uPtr | op[ (*k) ];
              }
              break;
            case OP_XOR:
              for ( i=0; i<width; i++ ) {
                  const uint16_T *uPtr = uVoidPtrs[*j];
                  y[i] = *uPtr ^ op[ (*k) ];
              }
              break;
            case OP_SHL:
              for ( i=0; i<width; i++ ) {
                  const uint16_T *uPtr = uVoidPtrs[*j];
                  y[i] = *uPtr << op[ (*k) ];
              }
              break;
            case OP_SHR:
              for ( i=0; i<width; i++ ) {
                  const uint16_T *uPtr = uVoidPtrs[*j];
                  y[i] = *uPtr >> op[ (*k) ];
              }
              break;
            case OP_NOT:
              for ( i=0; i<width; i++ ) {
                  const uint16_T *uPtr = uVoidPtrs[*j];
                  y[i] = ~(*uPtr);
              }
              break;
            default:
              break;
          }

      }
      break;

      case SS_UINT32: {

          uint32_T       *y  = (uint32_T *)yVoid;
          const uint32_T *op = paramCache->operands;

          switch ( paramCache->operator ) {
            case OP_AND:
              for ( i=0; i<width; i++ ) {
                  const uint32_T *uPtr = uVoidPtrs[*j];
                  y[i] = *uPtr & op[ (*k) ];
              }
              break;
            case OP_OR:
              for ( i=0; i<width; i++ ) {
                  const uint32_T *uPtr = uVoidPtrs[*j];
                  y[i] = *uPtr | op[ (*k) ];
              }
              break;
            case OP_XOR:
              for ( i=0; i<width; i++ ) {
                  const uint32_T *uPtr = uVoidPtrs[*j];
                  y[i] = *uPtr ^ op[ (*k) ];
              }
              break;
            case OP_SHL:
              for ( i=0; i<width; i++ ) {
                  const uint32_T *uPtr = uVoidPtrs[*j];
                  y[i] = *uPtr << op[ (*k) ];
              }
              break;
            case OP_SHR:
              for ( i=0; i<width; i++ ) {
                  const uint32_T *uPtr = uVoidPtrs[*j];
                  y[i] = *uPtr >> op[ (*k) ];
              }
              break;
            case OP_NOT:
              for ( i=0; i<width; i++ ) {
                  const uint32_T *uPtr = uVoidPtrs[*j];
                  y[i] = ~(*uPtr);
              }
              break;
            default:
              break;
          } /* switch on operator type */

      }  /* extent of uint32 case */
      break;

      default:
        break;
    } /* switch data type */

}


/* Function: mdlTerminate =====================================================
 * Abstract:
 *    Free up the memory that was used.
 */
static void mdlTerminate(SimStruct *S)
{
    SFcnCache *paramCache = ssGetUserData(S);

    if (paramCache != NULL) {
        free(paramCache->operands);
    }
    free( paramCache );
    ssSetUserData(S, NULL);
    return;
}

/* Function: mdlRTW ===========================================================
 * Abstract:
 *      Write out the Operator, Operand2 values, Operand2 hex strings
 *      and Operand2 user-entered string for this block.
 */
#define MDL_RTW
static void mdlRTW(SimStruct *S)
{
    const SFcnCache *paramCache   = ssGetUserData(S);
    OperatorTypes    operator     = paramCache->operator;
    const void      *operands     = paramCache->operands;
    int_T            opWidth      = paramCache->numOperands;
    int_T            opDType      = DTINFO(ssGetInputPortDataType(S,0), false);

    /* 
     * allocate enough space for the operand #2 hex strings with 
     * quotes, commas and brackets.  '"FFFFFFFF", ' is 4+8 
     */

    int_T           opStrLen    = 3+(4+2*sizeof(uint32_T))*opWidth;
    int_T           sidx;
    char_T          *opStr;
    static char     opCommentStr[MAX_MSG_LENGTH];


    /*
     * make correct-length hex strings for second operand
     */

    if ( (opStr = calloc(opStrLen, sizeof(char_T))) == NULL ) {
        ssSetErrorStatus( S, "Could not allocate data cache memory");
        return;
    }

    sidx = sprintf(opStr, "[]") - 1;

    switch (ssGetInputPortDataType(S,0)) {
        int_T i;
        
      case SS_UINT8: {
          for ( i=0; i < paramCache->numOperands; i++ ) {
              char_T *suffix = (i+1 == opWidth) ? "]": ", ";
              sidx += sprintf(opStr+sidx, "\"%02X\"%s", ((uint8_T *)operands)[i], suffix);
          }
      }
      break;
      case SS_UINT16: {
          for ( i=0; i < paramCache->numOperands; i++ ) {
              char_T *suffix = (i+1 == opWidth) ? "]": ", ";
              sidx += sprintf(opStr+sidx, "\"%04X\"%s", ((uint16_T *)operands)[i], suffix);
          }
      }
      break;
      case SS_UINT32: {
          for ( i=0; i < paramCache->numOperands; i++ ) {
              char_T *suffix = (i+1 == opWidth) ? "]": ", ";
              sidx += sprintf(opStr+sidx, "\"%08X\"%s", ((uint32_T *)operands)[i], suffix);
          }
      }
      break;
      default:
        ssSetErrorStatus(S, bitopDefMsg);
        goto EXIT_POINT;
    }

    /*
     * retrieve the user string for the second operand 
     */

    mxGetString( OP2_STRING(S), opCommentStr, MAX_MSG_LENGTH );

    /*
     * write operator string and second operand data out to the RTW file
     */

    if (!ssWriteRTWParamSettings( S, 4, 
                                  SSWRITE_VALUE_QSTR,       "Operator", 
                                  OperatorNames[operator-1],
                                  SSWRITE_VALUE_DTYPE_VECT, "Operand", 
                                  operands, opWidth, opDType,
                                  SSWRITE_VALUE_VECT_STR,   "OperandString", 
                                  opStr, opWidth,
                                  SSWRITE_VALUE_QSTR,       "OperandCommentString", 
                                  opCommentStr
                                  )) {
        ssSetErrorStatus(S,"Error writing parameter data to .rtw file");
        goto EXIT_POINT;
    }

 EXIT_POINT:
    free(opStr);
    return;
}


#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif

