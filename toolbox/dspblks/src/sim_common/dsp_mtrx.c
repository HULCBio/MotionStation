/*
 * dsp_mtrx_sim.c 
 *
 * DSP Blockset helper function.
 *
 * Check input/output port dimension and frame information. 
 *
 * NOTE: This is a query on the port dimension and frame information. Therefore, 
 * the information must already be set for the port.
 *
 *
 * Copyright 1995-2003 The MathWorks, Inc.
 * $Revision: 1.1.6.2 $ $Date: 2004/04/12 23:12:59 $
 */

#include "dsp_mtrx_sim.h"

/*--------------------------------------------------------------*/
/*                  DIMENSION INFO                              */
/*--------------------------------------------------------------*/


/*--------------------------------------------------------------*/
/* ONE OR TWO DIMENSIONS (1D OR 2D):
 *  If input/output signal is 1D or 2D, return true.
 *  Otherwise, return false.
 */
EXPORT_FCN boolean_T isInput1or2D(SimStruct *S, int_T port) {
    const int_T numDims = ssGetInputPortNumDimensions(S, port);
    return( (boolean_T)((numDims == 1) || (numDims == 2)) );
}

EXPORT_FCN boolean_T isOutput1or2D(SimStruct *S, int_T port) {
    const int_T numDims = ssGetOutputPortNumDimensions(S, port);
    return( (boolean_T)((numDims == 1) || (numDims == 2)) );
}

EXPORT_FCN boolean_T isInput2D(SimStruct *S, int_T port) {
    return((boolean_T)(ssGetInputPortNumDimensions(S, port) == 2));
}

EXPORT_FCN boolean_T isOutput2D(SimStruct *S, int_T port) {
    return((boolean_T)(ssGetOutputPortNumDimensions(S, port) == 2));
}


/*--------------------------------------------------------------*/
/* DYNAMICALLY SIZED
 */
EXPORT_FCN boolean_T isInputDynamicallySized(SimStruct *S, int_T port) 
{
    return((boolean_T)(ssGetInputPortWidth(S,port) == DYNAMICALLY_SIZED));
}


EXPORT_FCN boolean_T isOutputDynamicallySized(SimStruct *S, int_T port) 
{
    return((boolean_T)(ssGetOutputPortWidth(S,port) == DYNAMICALLY_SIZED));
}


/*--------------------------------------------------------------*/
/* DEFINED DIMENSIONS:
 *  If all input/output port dimensions defined, return true.
 *  Otherwise, return false.
 */
EXPORT_FCN boolean_T areAllInputDimensionsDefined( SimStruct *S ) {
    int_T portNum = ssGetNumInputPorts(S);

    while (--portNum >= 0) {
        if ( isInputDynamicallySized(S, portNum) ) {
            return false;  /* NOTE: Early return! */
        }
    }
    return true;
}

EXPORT_FCN boolean_T areAllOutputDimensionsDefined( SimStruct *S ) {
    int_T portNum = ssGetNumOutputPorts(S);

    while (--portNum >= 0) {
        if ( isOutputDynamicallySized(S, portNum) ) {
            return false;  /* NOTE: Early return! */
        }
    }
    return true;
}

EXPORT_FCN boolean_T areAllPortDimensionsDefined( SimStruct *S ) {
    return (boolean_T)(
        areAllInputDimensionsDefined(S) && areAllOutputDimensionsDefined(S) );
}

EXPORT_FCN boolean_T areAllButOneInputDimensionsDefined(SimStruct *S, int_T *unsetPortIdx)
{
    const int_T numInports = ssGetNumInputPorts(S);
    int_T       portNum    = numInports;
    int_T       cnt        = 0;

    while (--portNum >= 0) {
        if ( !isInputDynamicallySized( S, portNum ) ) {
            cnt++;
        } else {
            if (unsetPortIdx != NULL) {
                *unsetPortIdx = numInports-portNum-1;
            }
        }
    }
    return ( (boolean_T)(cnt == (numInports-1)) );
}

EXPORT_FCN boolean_T areAllButOneOutputDimensionsDefined(SimStruct *S, int_T *unsetPortIdx)
{
    const int_T numOutports = ssGetNumOutputPorts(S);
    int_T       portNum     = numOutports;
    int_T       cnt         = 0;

    while (--portNum >= 0) {
        if ( !isOutputDynamicallySized( S, portNum ) ) {
            cnt++;
        } else {
            if (unsetPortIdx != NULL) {
                *unsetPortIdx = numOutports-portNum-1;
            }
        }
    }
    return ( (boolean_T)(cnt == (numOutports-1)) );
}


/*--------------------------------------------------------------*/
/* UNORIENTED: [M], M >= 1
 *  If input/output is unoriented, return true.
 *  Otherwise, return false.
 */
EXPORT_FCN boolean_T isInputUnoriented(SimStruct *S, int_T port) {
    return((boolean_T)(ssGetInputPortNumDimensions(S, port) == 1));
}

EXPORT_FCN boolean_T isOutputUnoriented(SimStruct *S, int_T port) {
    return((boolean_T)(ssGetOutputPortNumDimensions(S, port) == 1));
}

EXPORT_FCN boolean_T areAllInputPortsUnoriented( SimStruct *S ) {
    int_T portNum = ssGetNumInputPorts(S);

    while (--portNum >= 0) {
        if ( ssGetInputPortNumDimensions( S, portNum ) != 1 ) {
            return false;  /* NOTE: Early return! */
        }
    }
    return true;
}


/*--------------------------------------------------------------*/
/* ORIENTED: [MxN], M,N >= 1
 *  If input/output is oriented, return true.
 *  Otherwise, return false.
 */
EXPORT_FCN boolean_T isInputOriented(SimStruct *S, int_T port) {
    return((boolean_T)(ssGetInputPortNumDimensions(S, port) > 1));
}

EXPORT_FCN boolean_T isOutputOriented(SimStruct *S, int_T port) {
    return((boolean_T)(ssGetOutputPortNumDimensions(S, port) > 1));
}


/*--------------------------------------------------------------*/
/* SCALAR: [1], [1x1]
 *  If input/output is oriented or unoriented scalar, return true.
 *  Otherwise, return false.
 */
EXPORT_FCN boolean_T isInputScalar(SimStruct *S, int_T port) 
{
    return((boolean_T)(ssGetInputPortWidth(S,port) == 1));
}

EXPORT_FCN boolean_T isOutputScalar(SimStruct *S, int_T port) 
{
    return((boolean_T)(ssGetOutputPortWidth(S,port) == 1));
}


/*--------------------------------------------------------------*/
/* ROW VECTOR: [1xN], N>1
 *  If input/output is an oriented row, return true.
 *  Otherwise, return false (including if it is unoriented).
 */
EXPORT_FCN boolean_T isInputRowVector(SimStruct *S, int_T port) 
{
    if (isInputOriented(S, port)) {
        int_T *dims = ssGetInputPortDimensions(S,port); 
        return((boolean_T)((dims[0]==1) && (dims[1]>1)));
    } else {
        return false;
    }
}

EXPORT_FCN boolean_T isOutputRowVector(SimStruct *S, int_T port) 
{
    if (isOutputOriented(S, port)) {
        int_T *dims = ssGetOutputPortDimensions(S,port); 
        return((boolean_T)((dims[0]==1) && (dims[1]!=1)));
    } else {
        return false;
    }
}


/*--------------------------------------------------------------*/
/* COLUMN VECTOR: [Mx1], M>1
 *  If input is an oriented col, return true.
 *  Otherwise, return false (including if it is unoriented).
 */
EXPORT_FCN boolean_T isInputColVector(SimStruct *S, int_T port) 
{
    if (isInputOriented(S,port)) {
        const int_T *dims = ssGetInputPortDimensions(S,port); 
        return((boolean_T)((dims[0]>1) && (dims[1]==1)));
    } else {
        return false;
    }
}

EXPORT_FCN boolean_T isOutputColVector(SimStruct *S, int_T port) 
{
    if (isOutputOriented(S,port)) {
        const int_T *dims = ssGetOutputPortDimensions(S,port); 
        return((boolean_T)((dims[0]!=1) && (dims[1]==1)));
    } else {
        return false;
    }
}



/*--------------------------------------------------------------*/
/* FULL MATRIX:  [MxN], M,N > 1
 *  If input/output is a full matrix, return true.
 *  Otherwise, return false.
 */
EXPORT_FCN boolean_T isInputFullMatrix(SimStruct *S, int_T port) 
{
    if (!isInputScalar(S, port) && isInputOriented(S,port)) {
        return((boolean_T)(!isInputRowVector(S,port) && !isInputColVector(S,port)));
    } else {
        return false;
    }
    
}

EXPORT_FCN boolean_T isOutputFullMatrix(SimStruct *S, int_T port) 
{
    if (!isOutputScalar(S, port) && isOutputOriented(S,port)) {
        return((boolean_T)(!isOutputRowVector(S,port) && !isOutputColVector(S,port)));
    } else {
        return false;
    }
    
}


/*--------------------------------------------------------------*/
/* SQUARE MATRIX: [MxM], M >= 1
 *  If input is a sqaure matrix, return true.
 *  Otherwise, return false.
 */
EXPORT_FCN boolean_T isInputSquareMatrix(SimStruct *S, int_T port) 
{
    if (isInputFullMatrix(S, port)) {
        const int_T *dims = ssGetInputPortDimensions(S,port); 
        return((boolean_T)(dims[0] == dims[1]));
    } else {
        return(isInputScalar(S,port));
    }
    
}

EXPORT_FCN boolean_T isOutputSquareMatrix(SimStruct *S, int_T port) 
{
    if (isOutputFullMatrix(S, port)) {
        const int_T *dims = ssGetOutputPortDimensions(S,port); 
        return((boolean_T)(dims[0] == dims[1]));
    } else {
        return(isOutputScalar(S,port));
    }
    
}

/*--------------------------------------------------------------*/
/* VECTOR: [1], [1x1], [F], [1xF], [Fx1] (anything but full matrix)
 *  If input/output is oriented or unoriented scalar or vector, return true.
 *  Otherwise, return false.
 */
EXPORT_FCN boolean_T isInputVector(SimStruct *S, int_T port) 
{
    return((boolean_T)(!isInputFullMatrix(S, port)));
}

EXPORT_FCN boolean_T isOutputVector(SimStruct *S, int_T port) 
{
    return((boolean_T)(!isOutputFullMatrix(S, port)));
}


/*--------------------------------------------------------------*/
/*                  FRAME-NESS                                  */
/*--------------------------------------------------------------*/


/*--------------------------------------------------------------*/
/* Frame Data: On or Off
 * (See below to check whether a signal is frame-based)
 */

/* Frame inherited */
EXPORT_FCN boolean_T isInputFrameDataInherited(SimStruct *S, int_T port) {
    return((boolean_T)(ssGetInputPortFrameData(S, port) == FRAME_INHERITED));
}

EXPORT_FCN boolean_T isOutputFrameDataInherited(SimStruct *S, int_T port) {
    return((boolean_T)(ssGetOutputPortFrameData(S, port) == FRAME_INHERITED));
}

/* Frame on */
EXPORT_FCN boolean_T isInputFrameDataOn(SimStruct *S, int_T port) {
    return((boolean_T)(ssGetInputPortFrameData(S, port) == FRAME_YES));
}

EXPORT_FCN boolean_T isOutputFrameDataOn(SimStruct *S, int_T port) {
    return((boolean_T)(ssGetOutputPortFrameData(S, port) == FRAME_YES));
}

/* Frame off */
EXPORT_FCN boolean_T isInputFrameDataOff(SimStruct *S, int_T port) {
    return((boolean_T)(ssGetInputPortFrameData(S, port) == FRAME_NO));
}

EXPORT_FCN boolean_T isOutputFrameDataOff(SimStruct *S, int_T port) {
    return((boolean_T)(ssGetOutputPortFrameData(S, port) == FRAME_NO));
}

/*--------------------------------------------------------------*/
/* Frame-based checks:
 * Definition of Frame-based: If frame-bit is on and sample per frame is > 1.
 */

EXPORT_FCN boolean_T isInputFrameBased(SimStruct *S, int_T port) {
    return((boolean_T)(isInputFrameDataOn(S, port) && (isInputColVector(S, port) || isInputFullMatrix(S, port))));
}

EXPORT_FCN boolean_T isOutputFrameBased(SimStruct *S, int_T port) {
    return((boolean_T)(isOutputFrameDataOn(S, port) && (isOutputColVector(S, port) || isOutputFullMatrix(S, port))));
}


EXPORT_FCN boolean_T isInputSampleBased(SimStruct *S, int_T port) {
    return((boolean_T)(isInputFrameDataOff(S, port) || (isInputFrameDataOn(S, port) && (!isInputColVector(S, port) && !isInputFullMatrix(S, port)))));
}


EXPORT_FCN boolean_T isOutputSampleBased(SimStruct *S, int_T port) {
    return((boolean_T)(isOutputFrameDataOff(S, port) || (isOutputFrameDataOn(S, port) && (!isOutputColVector(S, port) && !isOutputFullMatrix(S, port)))));
}


/*--------------------------------------------------------------*/
/*                  DIMENSION INFO                              */
/*--------------------------------------------------------------*/
/*
 * Return the number of samples (nSamps) and number of channels (nChans)
 * based on the registered attributes of inport/outport portNum.
 * Provides vector convenience rule (1-D and row/col vectors are all
 *  treated as single-channel inputs).
 */
EXPORT_FCN void getInportSampsAndChans(
    SimStruct   *S,
    const int_T  portNum,
    int_T       *nSamps,
    int_T       *nChans
) {
    const boolean_T isFullMatrix = isInputFullMatrix(S, portNum);
    const boolean_T isFrame      = isInputFrameDataOn(S, portNum);
    const int_T    *dims         = ssGetInputPortDimensions(S, portNum);

    *nSamps = (isFrame || isFullMatrix) ? dims[0] : ssGetInputPortWidth(S, portNum);
    *nChans = (isFrame || isFullMatrix) ? dims[1] : 1;
}


EXPORT_FCN void getOutportSampsAndChans(
    SimStruct   *S,
    const int_T  portNum,
    int_T       *nSamps,
    int_T       *nChans
) {
    const boolean_T isFullMatrix = isOutputFullMatrix(S, portNum);
    const boolean_T isFrame      = isOutputFrameDataOn(S, portNum);
    const int_T    *dims         = ssGetOutputPortDimensions(S, portNum);

    *nSamps = (isFrame || isFullMatrix) ? dims[0] : ssGetOutputPortWidth(S, portNum);
    *nChans = (isFrame || isFullMatrix) ? dims[1] : 1;
}


EXPORT_FCN boolean_T areInportAndOutportSameDims(
    SimStruct *S,
    int_T inport,
    int_T outport)
{
    int_T *inDims     = ssGetInputPortDimensions(    S, inport);
    int_T *outDims    = ssGetOutputPortDimensions(   S, outport);
    int_T  inNumDims  = ssGetInputPortNumDimensions( S, inport);
    int_T  outNumDims = ssGetOutputPortNumDimensions(S, outport);
    int_T i;

    if (inNumDims != outNumDims) return(false);
    for (i=0; i<outNumDims; i++) {
        if (inDims[i] != outDims[i]) return(false);
    }
    return(true);
}



EXPORT_FCN boolean_T areInportAndOutportCollapsedDims(
    SimStruct *S,
    int_T inport,
    int_T outport)
{
    int_T *inDims     = ssGetInputPortDimensions(    S, inport);
    int_T *outDims    = ssGetOutputPortDimensions(   S, outport);
    int_T  inNumDims  = ssGetInputPortNumDimensions( S, inport);
    int_T  outNumDims = ssGetOutputPortNumDimensions(S, outport);

    if (inNumDims != outNumDims) return(false);
    if (inNumDims == 1) {
        /* 1-D input, output must be a scalar: */
        if (outDims[0] != 1) return(false);
    } else {
        /* 2-D input, output must be a row vector: */
        if ((outDims[0] != 1) || (outDims[1] != inDims[1])) return(false);
    }
    return(true);
}


/* [EOF] dsp_mtrx_sim.c */
