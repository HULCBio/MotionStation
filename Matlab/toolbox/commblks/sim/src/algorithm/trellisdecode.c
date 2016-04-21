/*
 * Copyright 1996-2004 The MathWorks, Inc.
 * $Revision: 1.1.6.3 $ $Date: 2004/02/09 06:38:05 $
 */
 
#include "trellisdecode.h"

/********************************************************************* */
/* Function: decodeSymbols                                              */
/* Purpose:  Decode the symbols in the input buffer based upon the code */
/*           described by the decoder object.                           */
/*                                                                      */
/* Passed in: decoder_T *decoderObj                                     */
/*            buff_T *inputBuff                                         */
/*            buff_T *outputBuff                                        */
/*            const int_T   decodeCount                                 */
/*                                                                      */
/* Passed out: char * (error message - NULL if OK)                      */
/* ******************************************************************** */

char* decodeSymbols(decoder_T *decoderObj, buff_T *inputBuff, buff_T *outputBuff, const int_T decodeCount)
{
    creal_T  *rxSym      = (creal_T *) calloc(decoderObj->stateObj->samplesPerSymbol , sizeof(creal_T));   /* Holds the received symbol when read out of the buffer    */
    creal_T **refSymPtr  = (creal_T **)calloc(decoderObj->stateObj->M, sizeof(creal_T*));                  /* Vector of pointers to the reference signals              */
    real_T   *metricVec  = (real_T *)  calloc(decoderObj->stateObj->M, sizeof(real_T));                    /* Holds the metrics returned from the correlation routine  */

    int_T     stateIdx, nextPosIdx, survivorPath=0, symIdx;
    real_T    maxMetric  = MIN_METRIC;   /* Maximum metric used to scale metrics and to determine survivor */

    char* emsg = NULL;

    /* --- Decode the required number of symbols */
    for (symIdx=0;
         (decodeCount == DECODE_ENTIRE_BUFFER) 
            ? (inputBuff->dataAvail >= decoderObj->stateObj->samplesPerSymbol) 
            : (symIdx < decodeCount); 
         symIdx++) 
    {
        /* --- Input buffer error -> Not enough data in the buffer */
        if(inputBuff->dataAvail < decoderObj->stateObj->samplesPerSymbol) {
            return(emsg); /* removing an error case, return NULL now. */
        }

        if( (emsg=readBuffer(inputBuff, rxSym, decoderObj->stateObj->samplesPerSymbol)) != NULL) {
            return(emsg);
        }

        /* --- Move the next pointer forward */
        nextPosIdx = (decoderObj->pathPosIdx+1)%(decoderObj->memLen);

        /* --- Determine the transitions from each state and determine the survivor */
        for (stateIdx=0; stateIdx<decoderObj->stateObj->numStates; stateIdx++)
        {
            real_T tempMetric;
            int_T  inputIdx;

            /* --- Create the array of reference pointers */
            for (inputIdx=0; inputIdx<decoderObj->stateObj->M; inputIdx++) {
                refSymPtr[inputIdx] = (creal_T *)decoderObj->stateObj->states[stateIdx].transitions[inputIdx].output;
            }

            computeMetric(  (void *)rxSym, (const void **)refSymPtr, 
                            decoderObj->stateObj->samplesPerSymbol, 
                            decoderObj->stateObj->M, 
                            REAL_CORRELATION_METRIC, metricVec);

            tempMetric = decoderObj->pathMem[stateIdx].pathMetric;

            for (inputIdx=0; inputIdx<decoderObj->stateObj->M; inputIdx++)
            {
                int_T nextStateIdx;

                nextStateIdx = (int_T)decoderObj->stateObj->states[stateIdx].transitions[inputIdx].nextPhase;

                if(tempMetric + metricVec[inputIdx] > decoderObj->tempPathMem[nextStateIdx].pathMetric) {
                    int_T stateMemIdx;

                    stateMemIdx = nextPosIdx*decoderObj->stateObj->numStates + nextStateIdx;

                    decoderObj->tempPathMem[nextStateIdx].pathMetric = tempMetric + metricVec[inputIdx];
                
                    decoderObj->stateMem[stateMemIdx].input          = decoderObj->stateObj->states[stateIdx].transitions[inputIdx].input;
                    decoderObj->stateMem[stateMemIdx].prevState      = stateIdx;

                    /* --- Track the maximum value of the metric and store the state in */
                    /*     which the maximum was found.                                 */
                    if(decoderObj->tempPathMem[nextStateIdx].pathMetric > maxMetric) {
                        maxMetric    = decoderObj->tempPathMem[nextStateIdx].pathMetric;
                        survivorPath = nextStateIdx;
                    }
                }
            } /* End of for (inputIdx=0; inputIdx<M; inputIdx++) {} */

        } /* End of for (stateIdx=0; stateIdx<stateObj->numStates; stateIdx++) {} */

        /* --- The temporary path metrics become the current metrics */
        /*     Temporary path metrics are cleared                    */
        for (stateIdx=0; stateIdx<decoderObj->stateObj->numStates; stateIdx++) 
        {
            decoderObj->pathMem[stateIdx].pathMetric     = decoderObj->tempPathMem[stateIdx].pathMetric;
            decoderObj->tempPathMem[stateIdx].pathMetric = MIN_METRIC;

            /* --- Rescale the metrics if required */
            if(decoderObj->scalingMode == SCALING_ON) {
                decoderObj->pathMem[stateIdx].pathMetric -= maxMetric;
                decoderObj->pathMem[stateIdx].pathMetric = MAX(decoderObj->pathMem[stateIdx].pathMetric, MIN_METRIC);
            }
        }

        maxMetric = MIN_METRIC; /* Reset the maximum value for the next pass */

        /* --- Update the postion in the trellis */
        decoderObj->pathPosIdx = nextPosIdx;

        if(decoderObj->pathPosIdx >= decoderObj->memLen-1) {
            decoderObj->traceBack = true;
        }

        /* --- Traceback if required */
        if (decoderObj->traceBack) {
            int_T  currentStateIdx, prevStateIdx, stateMemIdx=0, tbIdx;
            real_T outputSym;

            prevStateIdx = survivorPath;
            for (tbIdx=0; tbIdx <= decoderObj->tbLen; tbIdx++)
            {
                int_T tempPosIdx;

                tempPosIdx      = (decoderObj->pathPosIdx)-tbIdx;
                tempPosIdx      = (tempPosIdx < 0) ? tempPosIdx+(decoderObj->memLen) : tempPosIdx;

                stateMemIdx     = (tempPosIdx * (decoderObj->stateObj->numStates)) + prevStateIdx;
                currentStateIdx = prevStateIdx;
                prevStateIdx    = decoderObj->stateMem[stateMemIdx].prevState;

            }

            outputSym = (real_T)(decoderObj->stateMem[stateMemIdx].input);
            writeBuffer(outputBuff, &outputSym, 1);
        }

    } /* End of for(symIdx=0; (decodeCount == DECODE_ENTIRE_BUFFER) ? ... ; symIdx++) */

    /* --- Free memory */
    if(NULL != metricVec){
	free(metricVec);
    }
    if(NULL != refSymPtr){
	free(refSymPtr);
    }
    if(NULL != rxSym){
	free(rxSym);
    }
    return(emsg);
}


/* ******************************************************************** */
/* Function: computeMetric                                              */
/* Purpose:  Compute the required metric between a received symbol and  */
/*           a set of reference symbols                                 */
/*                                                                      */
/* Passed in: const void *rxSym                                         */
/*            const void **refSym                                       */
/*            const int_T symLength                                     */
/*            const int_T numRef                                        */
/*            const metricOptions_T metricType                          */
/*            real_T     *metricVec                                     */
/*                                                                      */
/* Passed out: char * (error message - NULL if OK)                      */
/* ******************************************************************** */

char* computeMetric( const void *rxSym,
                            const void **refSym,
                            const int_T symLength,
                            const int_T numRef,
                            const metricOptions_T metricType,
                            real_T     *metricVec )
{
    char* emsg = NULL;

    switch (metricType) 
    {
        case REAL_CORRELATION_METRIC:
            {
                int_T   symIdx, refIdx;

                for (refIdx=0; refIdx<numRef; refIdx++)
                { 
                    real_T  tempSum;
                    creal_T *tempRef, *tempRx;

                    tempRef = (creal_T *)(refSym[refIdx]);
                    tempRx  = (creal_T *)rxSym;

                    tempSum = 0.0;
                    for(symIdx=0; symIdx<symLength; symIdx++) {
                        tempSum += tempRx[symIdx].re*tempRef[symIdx].re + tempRx[symIdx].im*tempRef[symIdx].im;
                    }
                    metricVec[refIdx] = tempSum;
                }
            }
            break;
        default:
            /* Unknown metric calculation method */
            return NULL;
    }
    return(emsg);
}


/* ******************************************************************** */
/* Function: createDecoderObject                                        */
/* Purpose:  Create the decoder object                                  */
/*                                                                      */
/* Passed in: const *stateStruct_T                                      */
/*            const int_T tbLen                                         */
/*                                                                      */
/* Passed out: decoderObj * (decoder object - NULL if error)            */
/* ******************************************************************** */

decoder_T* createDecoderObject(SimStruct *S,
                               const stateStruct_T *stateObj, 
                               const int_T tbLen, 
                               const initStateOptions_T startState, 
                               const scaleOptions_T scalingMode)
{
    decoder_T  *decoderObj = NULL;
    stateMem_T *stateMem;
    pathMem_T  *pathMem, *tempPathMem;
    int_T memLen = tbLen + 1;

    decoderObj = (decoder_T *)calloc(1, sizeof(decoder_T));

    if(decoderObj == NULL) {
		return(decoderObj);
    }

    if( (stateMem = (stateMem_T *)calloc(stateObj->numStates * memLen, sizeof(stateMem_T))) == NULL ) {
        free(decoderObj);
		return(NULL);
    }

    if( (pathMem = (pathMem_T *) calloc(stateObj->numStates, sizeof(pathMem_T))) == NULL ) {
        free(decoderObj);
        free(stateMem);
		return(NULL);
    }

    if( (tempPathMem = (pathMem_T *) calloc(stateObj->numStates, sizeof(pathMem_T)) ) == NULL ) {
        free(decoderObj);
        free(stateMem);
        free(pathMem);
		return(NULL);
    }

    /* --- Create the starting state and clear the temporary metrics */
    {
        int_T stateIdx;
        real_T defaultMetric;

        if(startState == -1) {
            defaultMetric = 0.0;
        } else {
            defaultMetric = MIN_METRIC;
        }

        for(stateIdx=0; stateIdx<stateObj->numStates; stateIdx++) {
            pathMem[stateIdx].pathMetric     = defaultMetric;
            tempPathMem[stateIdx].pathMetric = MIN_METRIC;
        }

        if(startState != -1) {
            pathMem[startState].pathMetric = 0.0;
        }
    }


    /* --- Assign the fields in the decoder object */
    decoderObj->tbLen       = tbLen;
    decoderObj->memLen      = memLen;
    decoderObj->traceBack   = false;
    decoderObj->scalingMode = scalingMode;

    decoderObj->pathPosIdx  = -1;

    decoderObj->stateMem    = stateMem;
    decoderObj->pathMem     = pathMem;
    decoderObj->tempPathMem = tempPathMem;

    decoderObj->stateObj    = (stateStruct_T *)stateObj;

    return(decoderObj);
}


/* ******************************************************************** */
/* Function: freeDecoderObject                                          */
/* Purpose:  Free the memory used by the decoder object                 */
/*                                                                      */
/* Passed in: *decoder_T                                                */
/*                                                                      */
/* Passed out: void                                                     */
/* ******************************************************************** */

void freeDecoderObject(decoder_T *decoderObj)
{
    freePhaseTrellis(decoderObj->stateObj);

	if(NULL != decoderObj->tempPathMem){
	    free(decoderObj->tempPathMem);
	}
	if(NULL != decoderObj->pathMem){
		free(decoderObj->pathMem);
	}
	if(NULL != decoderObj->stateMem){
		free(decoderObj->stateMem);
	}
	if(NULL != decoderObj){
		free(decoderObj);
	}
}

/* --- EOF ---*/
