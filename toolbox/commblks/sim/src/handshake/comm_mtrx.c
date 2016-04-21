/*    
 *    Functions required for matrix support in Communications blockset.
 *    Copyright 1996-2003 The MathWorks, Inc.
 *    $Revision: 1.1.6.2 $
 *    $Date: 2004/04/12 23:03:51 $
 *    Author: Mojdeh Shakeri
 */

#include "comm_mtrx.h"

/* Function: GetDimsInfoType ==================================================
 * Abstarct: Get type of input. 
 */
ssDimsType_T GetDimsInfoType(const DimsInfo_T *dimsInfo)
{
    ssDimsType_T dimsType;

    switch(dimsInfo->numDims){
      case DYNAMICALLY_SIZED:
        dimsType = UNKNOWN_DIMS;
        break;
      case 1: 
        dimsType = VECTOR_1D_DIMS;
        break;
      case 2: 
        if(dimsInfo->width == 1){
            dimsType = SCALAR_2D_DIMS;
        }else if(dimsInfo->dims[0] == 1 && dimsInfo->dims[1] > 1){
            dimsType =  ROW_VECTOR_DIMS;
        }else if(dimsInfo->dims[0] > 1 && dimsInfo->dims[1] == 1){
            dimsType = COL_VECTOR_DIMS;
        }else{
            dimsType = MATRIX_DIMS;
        }
        break;
      default:
        dimsType = N_D_ARRAY_DIMS;
        break;
    }
    return dimsType;
}


/* Function: IsDimsInfoFullySet ===============================================
 * Abstract:
 *  Return true if the dimension info has full information, i.e., width,
 *  number of dimensions, and dimensions are known. 
 */
boolean_T IsDimsInfoFullySet(const DimsInfo_T *thisInfo)

{
    boolean_T fullySet = true;
    if(thisInfo->width == DYNAMICALLY_SIZED){
        fullySet = false;
        goto EXIT_POINT;
    }

    if(thisInfo->numDims == DYNAMICALLY_SIZED){
        fullySet = false;
        goto EXIT_POINT;
    }else if(thisInfo->numDims == 1){
        if(thisInfo->dims[0] == DYNAMICALLY_SIZED){
            fullySet = false;
            goto EXIT_POINT;
        }
    }else if(thisInfo->numDims == 2){
        if(thisInfo->dims[0] == DYNAMICALLY_SIZED || 
           thisInfo->dims[1] == DYNAMICALLY_SIZED){
            fullySet = false;
            goto EXIT_POINT;
        }
    }
        
 EXIT_POINT:
    return fullySet;
}


/* Function: ssIsInputPortDimsInfoFullySet ====================================
 * Abstract:
 *  Return true if the port has full information, i.e., width,
 *  number of dimensions, and dimensions are known. 
 */
boolean_T ssIsInputPortDimsInfoFullySet(SimStruct *S, 
                                        int_T     port)
{
    DECL_AND_INIT_DIMSINFO(thisInfo);
    boolean_T fullySet = true;
    thisInfo.width   = ssGetInputPortWidth(        S, port);
    thisInfo.numDims = ssGetInputPortNumDimensions(S, port);
    thisInfo.dims    = ssGetInputPortDimensions(   S, port);
    
    fullySet = IsDimsInfoFullySet(&thisInfo);

    return fullySet;
}

/* Function: ssIsOutputPortDimsInfoFullySet ===================================
 * Abstract:
 *  Return true if the port has full information, i.e., width,
 *  number of dimensions, and dimensions are known. 
 */
boolean_T ssIsOutputPortDimsInfoFullySet(SimStruct *S, 
                                         int_T     port)
{
    DECL_AND_INIT_DIMSINFO(thisInfo);
    boolean_T fullySet = true;
    thisInfo.width   = ssGetOutputPortWidth(        S, port);
    thisInfo.numDims = ssGetOutputPortNumDimensions(S, port);
    thisInfo.dims    = ssGetOutputPortDimensions(   S, port);
    
    fullySet = IsDimsInfoFullySet(&thisInfo);

    return fullySet;
}


/* Function: CommGetOtherDimensions ==========================================
 * Abstarct: Given the input (or output) port dimension info, this function 
 *           fills the output (input) port dimension info.
 *           
 *  thisFactor: k, otherFactor: n, thisInfo->width: w 
 * 
 *       Input dimension    | Frame | Comment              | Output
 *      --------------------|-------|----------------------|-----------
 *            w             | No    | if k = w, else ERR   | n
 *            [1x1]         | No    | if k=n=1, else ERR   | [1x1]
 *                          |       | if n>1               | n     <-- 
 *            [wx1]         | No    | if k = w             | [nx1]
 *            [1xw]         | No    | if k = w             | [1xn]
 *            [mxn]         | No    | ERR                  | ERR
 *            [1x1]         | Yes   | k = 1                | [nx1] <--
 *            [wx1]         | Yes   | if w/k int, else ERR | [n*w/kx1]
 *            [1xw]         | Yes   | ERR                  | ERR
 *            [mxn]         | Yes   | ERR                  | ERR
 */
boolean_T  CommGetOtherDimensions(SimStruct        *S,
                                  PortType_T       portType,
                                  int_T            thisFactor,
                                  const DimsInfo_T *thisInfo,
                                  int_T            otherFactor,
                                  DimsInfo_T       *otherInfo,
                                  boolean_T        frameData)
{
    boolean_T     status = true;
    ssDimsType_T  thisType = GetDimsInfoType(thisInfo);

    /* Set other width */
    int32_T blockSize = (thisInfo->width) / thisFactor;
    otherInfo->width   = blockSize * otherFactor;

    /* Set other port number of dimensions and dimensions */
    switch(thisType){
      case VECTOR_1D_DIMS:
        /* 
         * If portType is IS_INPORT, it is forward propagation, otherwise,
         * it is backward propagation.
         * Forward propagation: 1-D input -> 1-D output 
         * Backward propagation: 1-D output:
         *  If input is scalar, input can be 1 or [1x1].
         *  If input is wide, input must be 1-D
         */
        if(portType == IS_INPORT || otherInfo->width > 1 || 
           (thisInfo->width == 1 && otherInfo->width == 1)){
            otherInfo->numDims = 1;
            otherInfo->dims[0] = otherInfo->width;
        }
        break;
      case SCALAR_2D_DIMS:
        if(otherInfo->width == 1){
            /* scalar 2-D */
            otherInfo->numDims = 2;
            otherInfo->dims[0] = 1;
            otherInfo->dims[1] = 1;
        }else{
            if(frameData == FRAME_YES){
                otherInfo->numDims = 2;
                otherInfo->dims[0] = otherInfo->width;
                otherInfo->dims[1] = 1;
            }else{
                otherInfo->numDims = 1;
                otherInfo->dims[0] = otherInfo->width;
            }
        }
        break;  
      case  COL_VECTOR_DIMS:
        otherInfo->numDims = 2;
        otherInfo->dims[0] = otherInfo->width;
        otherInfo->dims[1] = 1;
        break;
      case ROW_VECTOR_DIMS:
        otherInfo->numDims = 2;
        otherInfo->dims[0] = 1;
        otherInfo->dims[1] = otherInfo->width;
        break;
      case UNKNOWN_DIMS:
      case MATRIX_DIMS:
      case N_D_ARRAY_DIMS:
        /* Must be an assert */
        status = false;
        break;
    }
    return status;
}


/* Function: CommSetInputAndOutputPortDimsInfo ================================
 * Abstract: Given the input (or output) port dimensions, set the input and
 *   output port dimensions.
 */
void CommSetInputAndOutputPortDimsInfo(SimStruct        *S, 
                                       int_T            port,
                                       PortType_T       portType,
                                       int_T            thisFactor,
                                       const DimsInfo_T *thisInfo,
                                       int_T            otherFactor)
{
    /* Set other port dimensions */
    const Frame_T frameData   = (portType == IS_INPORT) ? 
                                         ssGetInputPortFrameData( S, port) :
                                         ssGetOutputPortFrameData(S, port);

    DECL_AND_INIT_DIMSINFO(otherInfo);
    int_T            dims[2] = {1, 1};
    boolean_T        status = false;
    const DimsInfo_T *inInfo, *outInfo;
    otherInfo.dims = dims;
    
    status = CommGetOtherDimensions(S,portType,
                                    thisFactor,thisInfo,
                                    otherFactor,&otherInfo,
                                    frameData);
    /* Must be assert */
    if(!status){
        ssSetErrorStatus(S, COMM_ERR_ASSERT);
        goto EXIT_POINT;
    }

    inInfo  = (portType == IS_INPORT) ? thisInfo   : &otherInfo;
    outInfo = (portType == IS_INPORT) ? &otherInfo : thisInfo;
    
    if(!ssSetInputPortDimensionInfo( S, port, inInfo))   return;
    if(!ssSetOutputPortDimensionInfo(S, port, outInfo))  return; 

 EXIT_POINT:
    return;
}


/* Function: CommCheckConvCodPortDimensions ===================================
 * Abstarct: Error out:
 *   Non-frame signal:
 *   - if the port is a [mxn] matrix, m > 1 and n > 1. 
 *   - inputWidth/thisFactor must be 1.
 *   Frame signal: (multi-channel)
 *   - if the port is a [mxn] matrix, m > 1 and n > 1. 
 *   - if the port is a row-vector frame.
 *
 *   - inputWidth/thisFactor must be integer.
 */
void CommCheckConvCodPortDimensions(SimStruct        *S,
                                    PortType_T       port,
                                    PortType_T       portType,
                                    int_T            thisFactor,
                                    const DimsInfo_T *thisInfo)
{
    ssDimsType_T  dimsType  = GetDimsInfoType(thisInfo);
    const Frame_T frameData = (portType == IS_INPORT) ? 
                                     ssGetInputPortFrameData( S, port) :
                                     ssGetOutputPortFrameData(S, port);

    if(dimsType == N_D_ARRAY_DIMS){
        ssSetErrorStatus(S, COMM_ERR_INVALID_N_D_ARRAY);
        goto EXIT_POINT;
    }

    if(frameData == FRAME_NO){
        if(dimsType == MATRIX_DIMS){
            ssSetErrorStatus(S, COMM_ERR_INVALID_MATRIX);
            goto EXIT_POINT;
        }
        if(thisInfo->width != thisFactor) {
            ssSetErrorStatus(S, COMM_ERR_INVALID_PORT_BLOCK_SIZE);
            goto EXIT_POINT;
        }
    }else{ /* Frame signal */
        if(dimsType == MATRIX_DIMS || dimsType == ROW_VECTOR_DIMS){
            ssSetErrorStatus(S, COMM_ERR_INVALID_MULTI_CHANNEL);
            goto EXIT_POINT;
        }
    }

    if((thisInfo->width % thisFactor) != 0){
        ssSetErrorStatus(S, COMM_ERR_PORT_DIMS_NOT_MATCH_TRELLIS);
        goto EXIT_POINT;
    }

 EXIT_POINT:
    return;
}

/* Function: SetDefaultInputPortDimsWithKnownWidth ============================
 * Abstract: Using the port width, this functions sets port dimensions.
 *    If the number of dimensions are known, since comm blockset does not
 *    support partial dimensions, do not do any thing.
 *    If the number of dimensions are unknown:
 *       if signal is frame     => set port dimensions to column-vector
 *       if signal is non-frame => set port dimensions to 1-D signal
 */
void SetDefaultInputPortDimsWithKnownWidth(SimStruct *S,
                                           int_T     port)
{
    if(!ssIsInputPortDimsInfoFullySet(S, port)) {
        /* 
         * Since width is known, check number of dimensions to see 
         * if the port dimensions has been set.
         */
        int_T numDims = ssGetInputPortNumDimensions(S,port);
        
        if(numDims == DYNAMICALLY_SIZED){
            int_T width   = ssGetInputPortWidth(S, port);
            const Frame_T frameData  = ssGetInputPortFrameData(S,port);
            if(frameData == FRAME_YES){
                if(!ssSetInputPortMatrixDimensions(S, port, width, 1)) return;
            }else{
                if(!ssSetInputPortVectorDimension(S, port, width)) return;
            }
        }/* else port dimensions are known */
    }
}



/* Function: GetDefaultInputDimsIfPortDimsUnknown =============================
 * Abstract:
 *  Check input and output port dimensions. If both of them are known, return 
 *  true. If at least one of them is unknown, return the default input port
 *  dimensions.
 */
boolean_T GetDefaultInputDimsIfPortDimsUnknown(SimStruct  *S,
                                               int_T      port,
                                               int_T      dataPortWidth,
                                               DimsInfo_T *dInfo)/* out */
{
    /* Check and set data input and output ports. */
    boolean_T dataPortsAreKnown = ssIsInputPortDimsInfoFullySet(S, port) &&
                                  ssIsOutputPortDimsInfoFullySet(S, port);
    /* 
     * Possible cases: both input and output port dimensions are known.
     * Possible cases: both input and output port dimensions are unknown.
     * Possible cases: output is 1-D, input is scalar, and input dimensions
     * are unknown, i.e., [1] or [1x1]
     */
    if(!dataPortsAreKnown){
        /* 
         * If input is a frame signal, set input to column-vector.
         * If input is a non-frame signal, set input to 1-D vector.
         */
        const Frame_T frameData = ssGetInputPortFrameData(S, port);

        dInfo->width   = dataPortWidth;
        dInfo->numDims = (frameData == FRAME_YES) ? 2 : 1;
        dInfo->dims[0] = dataPortWidth;
        dInfo->dims[1] = 1; /* safe:  dInfo.dims points to dims[2] */
    }

    return dataPortsAreKnown;
}

/* EOF comm_mtrx.c */


