/*
 *  File: timrec_hs.c
 * 
 *  Defines the Port Attribute Propagation functions for the Timing Phase
 *  Recovery Sfunctions. Includes functions for Sample Time, Frameness,
 *  and Dimension propagation.
 *
 *  Copyright 1996-2003 The MathWorks, Inc.
 *  $Revision: 1.1.6.2 $ $Date: 2003/06/03 15:52:07 $
 */
 
#include "timrec_hs.h"

/* Function timRecSetInputPortSampleTime()
 *   Setting Options:
 *     SB mode:    
 *                 ts   -> In1    Out1 -> tsym
 *    (if present) tsym -> Rst    Out2 -> tsym   , where tsym = ts*N
 *   
 *     FB mode:    
 *                 tf => In1   Out1 => tf
 *    (if present) tf => Rst   Out2 => tf        , where tf = ts*N*NumSymb 
 */
void timRecSetInputPortSampleTime(SimStruct *S,
                                  int_T     portIdx,
                                  real_T    sampleTime,
                                  real_T    offsetTime)
{
          real_T    outSampTime, inSampTime;
    const int_T     N           = (int_T)mxGetPr(SAMP_PER_SYMB_ARG(S))[0];
    const boolean_T isSampBased = (boolean_T)
                    (ssGetInputPortFrameData(S, INPORT) == FRAME_NO);

    /* Set the input port */
    ssSetInputPortSampleTime(S, portIdx, sampleTime);
    ssSetInputPortOffsetTime(S, portIdx, offsetTime);

    if (sampleTime == CONTINUOUS_SAMPLE_TIME)
        THROW_ERROR(S, COMM_EMSG_DISCRETE_SIGNALS);

    if (offsetTime != 0.0)
        THROW_ERROR(S, COMM_EMSG_NONZERO_OFFSET_TIME);

    if (portIdx==INPORT)
    {
        outSampTime = (isSampBased) ? (sampleTime*N) : sampleTime;
        inSampTime = outSampTime;
        
        /* Set the Reset port */
        if (HAS_RST_PORT(S)) 
        {
            if (ssGetInputPortSampleTime(S, RSTPORT) == INHERITED_SAMPLE_TIME)
            {
                ssSetInputPortSampleTime(S, RSTPORT, inSampTime);
                ssSetInputPortOffsetTime(S, RSTPORT, offsetTime);
            }
        }
    } else /* portIdx == RSTPORT */
    {
        inSampTime = (isSampBased) ? (sampleTime/N) : sampleTime;
        outSampTime = sampleTime;

        /* Set the INPORT */
        if (ssGetInputPortSampleTime(S, INPORT) == INHERITED_SAMPLE_TIME)
        {
            ssSetInputPortSampleTime(S, INPORT, inSampTime);
            ssSetInputPortOffsetTime(S, INPORT, offsetTime);
        }
    } /* end if (portIdx==INPORT)

    /* Set the outports */
    ssSetOutputPortSampleTime(S, OUTPORT1, outSampTime);
    ssSetOutputPortOffsetTime(S, OUTPORT1, offsetTime);
    ssSetOutputPortSampleTime(S, OUTPORT2, outSampTime);
    ssSetOutputPortOffsetTime(S, OUTPORT2, offsetTime);

} /* end timRecSetInputPortSampleTime */


/* Function timRecSetOutputPortSampleTime()
 *   Setting Options:
 *   SB mode:    
 *       tsym -> Out1   In1 -> ts
 *       tsym -> Out2   Rst -> tsym (if present)  , where tsym = ts*N
 *
 *   FB mode:    
 *       tf => Out1   In1 => tf
 *       tf => Out2   Rst => tf (if present)      , where tf = ts*N*NumSymb 
 */                
void timRecSetOutputPortSampleTime(SimStruct *S,
                                   int_T     portIdx,
                                   real_T    sampleTime,
                                   real_T    offsetTime)
{
          real_T    inSampTime;
    const int_T     N  = (int_T)mxGetPr(SAMP_PER_SYMB_ARG(S))[0];
    const boolean_T isSampBased = (boolean_T)
                    (ssGetOutputPortFrameData(S, portIdx) == FRAME_NO);

    /* Set the output ports */
    ssSetOutputPortSampleTime(S, portIdx, sampleTime);
    ssSetOutputPortOffsetTime(S, portIdx, offsetTime);

    if (sampleTime == CONTINUOUS_SAMPLE_TIME)
        THROW_ERROR(S, COMM_EMSG_DISCRETE_SIGNALS);

    if (offsetTime != 0.0)
        THROW_ERROR(S, COMM_EMSG_NONZERO_OFFSET_TIME);

    if (portIdx==OUTPORT1) 
    {
        ssSetOutputPortSampleTime(S, OUTPORT2, sampleTime);
        ssSetOutputPortOffsetTime(S, OUTPORT2, offsetTime);
    } else {
        ssSetOutputPortSampleTime(S, OUTPORT1, sampleTime);
        ssSetOutputPortOffsetTime(S, OUTPORT1, offsetTime);
    }

    /* Set input ports */
    inSampTime = (isSampBased) ? (sampleTime/N) : sampleTime;

    ssSetInputPortSampleTime(S, INPORT, inSampTime);
    ssSetInputPortOffsetTime(S, INPORT, offsetTime);

    if (HAS_RST_PORT(S))
    {
        ssSetInputPortSampleTime(S, RSTPORT, sampleTime);
        ssSetInputPortOffsetTime(S, RSTPORT, offsetTime);
    }

} /* end timRecSetOutputPortSampleTime */


void timRecSetInputPortFrameData(SimStruct *S,
                                 int_T portIdx,
                                 Frame_T frameData)
{
    ssSetInputPortFrameData(S, portIdx, frameData);

    /* Set the outputs same as first input port */
    if (portIdx == INPORT)
    {
        if (ssGetInputPortFrameData(S, INPORT) == FRAME_NO) 
        {
            if ((int_T)(mxGetPr(RESET_ARG(S))[0]) == RESET_EVERY_FRAME)
                THROW_ERROR(S, COMM_EMSG_RST_OPTION);
        }
        
        ssSetOutputPortFrameData(S, OUTPORT1, frameData);
        ssSetOutputPortFrameData(S, OUTPORT2, frameData);
    }
} /* end timRecSetInputPortFrameData */


/* Helper Function for setting input ports */
void setInputPortDimensions(SimStruct *S, int_T portIdx, 
                            int_T numDims, int_T inRows, int_T inCols)
{
    if(ssGetInputPortWidth(S, portIdx) == DYNAMICALLY_SIZED)
    {
        if (numDims > 1) {
            if (!ssSetInputPortMatrixDimensions(S, portIdx, inRows, inCols))
                return;
        } else { /* 1-D mode */
            if (!ssSetInputPortVectorDimension(S, portIdx, inRows)) return;
        }                    
    } else {
        if (ssGetInputPortWidth(S, portIdx) != inRows)
            THROW_ERROR(S, COMM_EMSG_INVALID_DIMS);
    }
}                                         


/* Helper Function for setting output ports */
void setOutputPortDimensions(SimStruct *S, int_T portIdx,
                             int_T numDims, int_T outRows, int_T outCols)
{
    if (ssGetOutputPortWidth(S, portIdx) == DYNAMICALLY_SIZED)
    {
        if (numDims > 1) {
            if (!ssSetOutputPortMatrixDimensions(S,portIdx,outRows,outCols))
                return;
        } else { /* 1-D mode */
            if (!ssSetOutputPortVectorDimension(S,portIdx,outRows)) return;
        }                    
    } else {
        if (ssGetOutputPortWidth(S, portIdx) != outRows)
            THROW_ERROR(S, COMM_EMSG_INVALID_DIMS);
    }
}


/* Function timRecSetInputPortDimensionInfo()        
 *   Setting options:
 *   SB mode:
 *     [1x1], [1]    -> In1  Out1 -> [1x1], [1]
 *                           Out2 -> [1x1], [1]
 *   
 *     [1x1], [1]    -> In1  Out1 -> [1x1], [1]
 *     [1x1], [1]    -> Rst  Out2 -> [1x1], [1]
 *    
 *   FB mode: (all 2D)
 *     [N*numSymbx1] => In1  Out1 => [numSymbx1]
 *                           Out2 => [numSymbx1] , numSymb >= 1 
 *   
 *     [N*numSymbx1] => In1  Out1 => [numSymbx1]
 *             [1x1] => Rst  Out2 => [numSymbx1] , numSymb >= 1 
 *   
 *     [N*numSymbx1] => In1  Out1 => [numSymbx1]
 *             [1x1] -> Rst  Out2 => [numSymbx1] , numSymb >= 1 
 */
void timRecSetInputPortDimensionInfo(SimStruct *S, int_T portIdx,
                                      const DimsInfo_T *dimsInfo)
{
    /* Set input port */
    if (!ssSetInputPortDimensionInfo(S, portIdx, dimsInfo)) return;

    {
              int_T  outCols1, outRows1, outCols2, outRows2;
        const int_T  N  = (int_T) mxGetPr(SAMP_PER_SYMB_ARG(S))[0];

        const boolean_T isSampBased = (boolean_T)
                        (ssGetInputPortFrameData(S, INPORT) == FRAME_NO);

        const int_T  numDims  = ssGetInputPortNumDimensions(S, portIdx);
		const int_T  inRows   = dimsInfo->dims[0];
		const int_T  inCols   = (numDims >= 2) ? dimsInfo->dims[1] : 0;

        /* Check and get dimensions to set */
        if ( (numDims==2) && (inCols != 1) )
            THROW_ERROR(S, COMM_EMSG_NO_MULTICHAN_SIGNAL);

        if (isSampBased)  /* Sample-based mode */
        {
            if (inRows!=1)  THROW_ERROR(S, COMM_EMSG_SCALAR_INPUT);

            outRows1 = inRows;
            outRows2 = inRows;

            /* Set other input port */
            if (portIdx == INPORT)
            {
                if (HAS_RST_PORT(S))
                    setInputPortDimensions(S, RSTPORT, numDims, inRows, inCols);
            } else  /* == RST_PORT */
                setInputPortDimensions(S, INPORT, numDims, inRows, inCols);

        } else      /* Frame-based mode */
        {
            if (portIdx == INPORT)
            {
                if (fmod(inRows, N)!=0)  THROW_ERROR(S, COMM_EMSG_FRAME_MULT_SAMP);

                outRows1 = inRows/N;
                outRows2 = outRows1;

                if (HAS_RST_PORT(S)) 
                {
                    if(ssGetInputPortWidth(S, RSTPORT) == DYNAMICALLY_SIZED)
                    {
                        if (!ssSetInputPortMatrixDimensions(S, RSTPORT, 1, 1))
                        return;
                    } else {
                        if (ssGetInputPortWidth(S, RSTPORT) != 1) 
                            THROW_ERROR(S, COMM_EMSG_SCALAR_RST_SIGNAL);
                    }
                }
            } else { /* RST_PORT */
                if (inRows!=1)  THROW_ERROR(S, COMM_EMSG_SCALAR_RST_SIGNAL);   

                return; /* cant do anything else */
            }            
        } /* end if (isSampBased) */

        outCols1 = inCols;
        outCols2 = inCols;
        
        /* Set Output Ports */
        setOutputPortDimensions(S, OUTPORT1, numDims, outRows1, outCols1);
        setOutputPortDimensions(S, OUTPORT2, numDims, outRows2, outCols2);
    }
} /* end timRecSetInputPortDimensionInfo */


void timRecSetOutputPortDimensionInfo(SimStruct *S, int_T portIdx,
                                      const DimsInfo_T *dimsInfo)
{
     /* Set port */
    if (!ssSetOutputPortDimensionInfo(S, portIdx, dimsInfo)) return;

    {
              int_T outCols2, outRows2, inCols, inRows;

        const int_T  N  = (int_T) mxGetPr(SAMP_PER_SYMB_ARG(S))[0];
        const boolean_T isSampBased = (boolean_T)
                    (ssGetOutputPortFrameData(S, portIdx) == FRAME_NO);

        const int_T numDims  = ssGetOutputPortNumDimensions(S, portIdx);
        const int_T outRows = dimsInfo->dims[0];
        const int_T outCols = (numDims >= 2) ? dimsInfo->dims[1] : 0;
    
        /* Check and get dimensions to set */
        if ( (numDims==2) && (outCols != 1) )
            THROW_ERROR(S, COMM_EMSG_NO_MULTICHAN_SIGNAL);
        
        if (isSampBased) 
        {
            if (outRows !=1)  THROW_ERROR(S, COMM_EMSG_SCALAR_OUTPUT);

            inRows = outRows;
        } else /* FrameBased */ 
        {
            inRows = outRows * N;
        }
        inCols   = outCols;
    
        outRows2 = outRows;
        outCols2 = outCols;
    
        /* Set input ports */
        setInputPortDimensions(S, INPORT, numDims, inRows, inCols);
        if (HAS_RST_PORT(S))
            setInputPortDimensions(S, RSTPORT, numDims, 1, inCols);
                        
        /* Set other output port*/                
        if (portIdx == OUTPORT1)
            setOutputPortDimensions(S, OUTPORT2, numDims, outRows2, outCols2);
        else 
            setOutputPortDimensions(S, OUTPORT1, numDims, outRows2, outCols2);
    }
} /* end timRecSetOutputPortDimensionInfo */

/* EOF */
