/*    
 *    Function required for frame support capability in CDMA Reference
 *    blockset.
 *
 *    Minimal Requirements:
 *       Allow propagation of frame-based signals.
 *       Only single channel inputs/outputs.
 *       Provide backwards compatibility for sample-based unoriented signals.
 *
 *    Implementation details:
 *       Signals are allowed of specific lengths only i.e. vectors or frames
 *       of known sizes).
 *       All data signals can be 1D unoriented sample-based or 2D framebased
 *       signals.
 *       All scalar signals (Rate inputs or diagnostic outputs) are 1D scalars
 *       only.
 *       Error for sample-based 2-D signals.
 *       Error for multi-channel inputs/outputs.
 *
 *    Common S-function/Block properties:
 *       For inputs, the first input port is either a Rate parameter input
 *       (1D scalar) or a data signal, while all the others are data signals.
 *       For outputs, the last output port is either a diagnostic output
 *       (1D scalar) or a data signal, while all the others are data signals.
 *
 *    Copyright 2000-2002 The MathWorks, Inc. and ALGOREX, Inc.
 *    $Revision: 1.3 $ $Date: 2002/04/14 16:33:19 $
 */

#include "cdma_frm.h"
 
/* Function: cdmaSetAllPortsDimensions
 * Purpose: Check the ports and set the sizes of all the ports based on the
 *          parameters passed in.
 */
boolean_T cdmaSetAllPortsDimensions(SimStruct           *S,
                                    int                 portIdx,      
                                    const DimsInfo_T    *dimsInfo,
                                    boolean_T           isInput,
                                    int                 *inWidths,     
                                    int                 numInportsToSet, 
                                    int                 *outWidths,
                                    int                 numOutportsToSet,
                                    int                 firstInPortToSet)     
{
    boolean_T frameBased;
    int_T i, numDims;

    if (isInput) { 

        /* Check correct input port size */ 
    	if ( dimsInfo->dims[0] != inWidths[portIdx] ) {
    		ssSetErrorStatus(S, CDMA_ERROR_INVALID_SIGNAL_WIDTH);
    		return (boolean_T) false;
    	}

        /* Set current input port */
        if(!ssSetInputPortDimensionInfo(S, portIdx, dimsInfo)) 
            return (boolean_T) false;

        /* Port parameters */
        numDims    = ssGetInputPortNumDimensions(S, portIdx);
        frameBased = (boolean_T)
                     (ssGetInputPortFrameData(S, portIdx) == FRAME_YES);

    } else {

        /* Check correct output port size */ 
    	if ( dimsInfo->dims[0] != outWidths[portIdx] ) {
    		ssSetErrorStatus(S, CDMA_ERROR_INVALID_SIGNAL_WIDTH);
    		return (boolean_T) false;
    	}

        /* Set current output port */
        if(!ssSetOutputPortDimensionInfo(S, portIdx, dimsInfo)) 
            return (boolean_T) false;

        /* Port parameters */
        numDims    = ssGetOutputPortNumDimensions(S, portIdx);
        frameBased = (boolean_T)
                     (ssGetInputPortFrameData(S, firstInPortToSet) == FRAME_YES);

    }

        	
    /* Check for single channels */
    if ( ( numDims == 2) && (dimsInfo->dims[1] != 1) ) {
    	ssSetErrorStatus(S, CDMA_ERROR_MULTI_CHAN_SIGNAL);
    	return (boolean_T) false;
    }

    /* Check for sample-based 2D signals */
    if ( ( numDims == 2) && (!frameBased) ) {
    	ssSetErrorStatus(S, CDMA_ERROR_SAMPLE_2D_SIGNAL);
    	return (boolean_T) false;
    }

    /* Set all Input ports */
    for (i = firstInPortToSet; i < numInportsToSet; i++){
        if (ssGetInputPortWidth(S, i) == DYNAMICALLY_SIZED) {
    	    if (frameBased) {
    			if(!ssSetInputPortMatrixDimensions(S, i, inWidths[i], 1))
    				return (boolean_T) false;
    		} else {
    			if(!ssSetInputPortVectorDimension(S, i, inWidths[i]))
    				return (boolean_T) false;
    		}
    	}
    }

    /* Set all Output ports */
    for (i = 0; i < numOutportsToSet; i++){
        if (ssGetOutputPortWidth(S, i) == DYNAMICALLY_SIZED) {
            if (frameBased)  { 
                if(!ssSetOutputPortMatrixDimensions(S, i, outWidths[i], 1))
                    return (boolean_T) false;
            } else {
                if(!ssSetOutputPortVectorDimension(S, i, outWidths[i]))
                    return (boolean_T) false;
            }        
        }
    }

    return (boolean_T) true;
}

/* EOF */
 