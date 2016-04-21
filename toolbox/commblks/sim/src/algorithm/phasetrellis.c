/*
* Copyright 1996-2004 The MathWorks, Inc.
* $Revision: 1.1.6.3 $ $Date: 2004/02/09 06:38:04 $
*/

#include "math.h"
#include "phasetrellis.h"
#include <memory.h>
#include <stdlib.h>

/* ******************************************************************** */
/* Function: createPhaseOffsets                                         */
/* Purpose:  Create a structure containing the number and values of     */
/*           phase offsets for the trellis that is being generated .    */
/*                                                                      */
/* Passed in: const int_T M                                             */
/*            const int_T L                                             */
/*            const int_T m                                             */
/*            const int_T p                                             */
/*            const real_T *filterPtr                                   */ 
/*            const int_T  numCoef                                      */
/*                                                                      */
/* Passed out: phaseOffsets_T * (NULL if Error)                         */
/* ******************************************************************** */
phaseOffset_T *createPhaseOffsets(SimStruct *S,
                                  const int_T  M,                   /* Alphabet size    */    
                                  const int_T  L,                   /* Pulse length     */            
                                  const int_T  samplesPerSymbol,                         
                                  const real_T *filterPtr,          /* Matlab filter                */ 
                                  const int_T  numCoef,             /* Number of filter coeficients */
				  const real_T *preHistory,		    /* Data prehistory */
		                  const real_T initialPhase)	    /* Initial phase offset */
                                   
{    
    const int_T  numDataStates    = (int_T)pow(M,(L-1));
    
    phaseOffset_T  *phaseOffsets = NULL;
    state_T        stateStr;
    
    block_params_T *blockParams   = NULL;
    block_dims_T   *blockDims     = NULL;
    
    real_T *tempInitialData       = NULL; /* Used to pass the initial data to the modulator (as the modulator requires real_T) */
    real_T *prehistoryData        = NULL;
    
    const int_T order             = numCoef - 1;
    const int_T tapDelayLineWidth = (int_T)(ceil((real_T)order/(real_T)samplesPerSymbol));

	int_T dataIdx, symbIdx, prehistoryIdx=0;

	real_T deltaPhase;    
	
    blockParams   = (block_params_T *) calloc(1,sizeof(block_params_T));
	if(NULL == blockParams){
		return NULL;
	}

    blockDims     = (block_dims_T *)   calloc(1,sizeof(block_dims_T));
	if(NULL == blockDims){
		free(blockParams);
		return NULL;
	}

	/* --- Dimension info */
    blockDims->numBits          = 1;
    blockDims->isMultiRateBlk   = false;
    blockDims->isMultiTasking   = false;
    
    blockDims->tapIdx           = (int_T *) calloc(1,sizeof(int_T));
	if(NULL == blockDims->tapIdx){
		free(blockDims);
		free(blockParams);
		return NULL;
	}
    blockDims->rdIdx            = (int_T *) calloc(1,sizeof(int_T));
	if(NULL == blockDims->rdIdx){
		free(blockDims->tapIdx);
		free(blockDims);
		free(blockParams);
		return NULL;
	}
    blockDims->wrIdx            = (int_T *) calloc(1,sizeof(int_T));
	if(NULL == blockDims->wrIdx){
		free(blockDims->rdIdx);
		free(blockDims->tapIdx);
		free(blockDims);
		free(blockParams);
		return NULL;
	}
    
    blockDims->tapDelayLineWidth= tapDelayLineWidth;
    
    blockDims->tapDelayLineBuff = (real_T *)calloc(tapDelayLineWidth,sizeof(real_T));
	if(NULL == blockDims->tapDelayLineBuff){
		free(blockDims->wrIdx);
		free(blockDims->rdIdx);
		free(blockDims->tapIdx);
		free(blockDims);
		free(blockParams);
		return NULL;
	}
    blockDims->outBuf           = (real_T *)calloc(samplesPerSymbol*2,sizeof(real_T));
	if(NULL == blockDims->outBuf){
		free(blockDims->tapDelayLineBuff);
		free(blockDims->wrIdx);
		free(blockDims->rdIdx);
		free(blockDims->tapIdx);
		free(blockDims);
		free(blockParams);
		return NULL;
	}
    blockDims->phaseState       = (real_T *)calloc(1,sizeof(real_T));
	if(NULL == blockDims->phaseState){
		free(blockDims->outBuf);
		free(blockDims->tapDelayLineBuff);
		free(blockDims->wrIdx);
		free(blockDims->rdIdx);
		free(blockDims->tapIdx);
		free(blockDims);
		free(blockParams);
		return NULL;
	}
    blockDims->phaseVector      = (real_T *)calloc(samplesPerSymbol*2,sizeof(real_T));
	if(NULL == blockDims->phaseVector){
		free(blockDims->phaseState);
		free(blockDims->outBuf);
		free(blockDims->tapDelayLineBuff);
		free(blockDims->wrIdx);
		free(blockDims->rdIdx);
		free(blockDims->tapIdx);
		free(blockDims);
		free(blockParams);
		return NULL;
	}
    
    blockDims->inFramebased     = 1;
    blockDims->inFrameSize      = 1;
    blockDims->inElem           = 1;
    blockDims->numChans         = 1;
    
    blockDims->outElem          = samplesPerSymbol;
    blockDims->outFrameSize     = samplesPerSymbol;
    
    /* --- Parameter info */
    blockParams->pulseLength        = L;
    blockParams->samplesPerSymbol   = samplesPerSymbol;
    
    blockParams->numInitData        = L-1;
    blockParams->initialFilterData  = NULL;
    
    blockParams->bufferWidth        = tapDelayLineWidth/(blockDims->numChans);
    
    blockParams->numOffsets         = 0;
    blockParams->phaseOffset        = NULL;
    
    blockParams->filterArg          = (real_T *)filterPtr;
    blockParams->filterLength       = numCoef;
    
    blockParams->initialPhaseSwitch = INITIAL_PHASE_AFTER_PREHISTORY;
    
    /* use default value if NULL is passed for prehistoryData. initialize with all ones */
    if(L>1) {
        prehistoryData = calloc(L-1,sizeof(real_T));
        if(NULL == prehistoryData){
			free(blockDims->phaseVector);
			free(blockDims->phaseState);
			free(blockDims->outBuf);
			free(blockDims->tapDelayLineBuff);
			free(blockDims->wrIdx);
			free(blockDims->rdIdx);
			free(blockDims->tapIdx);
			free(blockDims);
			free(blockParams);
            return NULL;
		}
        for (symbIdx=0; symbIdx < (L-1); symbIdx++) {
		    prehistoryData[symbIdx] = (real_T) 1.0;
	    }

        /* --- Create the state transitions */
    
        /* --- If the pulse length is greater than 1, then a prehistory is required. */
        /*     So, allocate the integer vector used by the dec2base function.        */

        tempInitialData = (real_T  *)calloc(L-1,sizeof(real_T));        
		if(NULL == tempInitialData){
			free(prehistoryData);
			free(blockDims->phaseVector);
			free(blockDims->phaseState);
			free(blockDims->outBuf);
			free(blockDims->tapDelayLineBuff);
			free(blockDims->wrIdx);
			free(blockDims->rdIdx);
			free(blockDims->tapIdx);
			free(blockDims);
			free(blockParams);
			return NULL;
		}
		/* This is used to hold the initial data of the modulator */
	}
	/* allocate memory for return struct */ 
	phaseOffsets = (phaseOffset_T  *)calloc(1,sizeof(phaseOffset_T));
	if(NULL == phaseOffsets){
		if(L>1) {		
			free(tempInitialData);
			free(prehistoryData);
		}
		free(blockDims->phaseVector);
		free(blockDims->phaseState);
		free(blockDims->outBuf);
		free(blockDims->tapDelayLineBuff);
		free(blockDims->wrIdx);
		free(blockDims->rdIdx);
		free(blockDims->tapIdx);
		free(blockDims);
		free(blockParams);
		return NULL;
	}

	phaseOffsets->phase = (real_T*)calloc(numDataStates,sizeof(real_T));
	if(NULL == phaseOffsets->phase){
		free(phaseOffsets);
		if(L>1) {		
			free(tempInitialData);
			free(prehistoryData);
		}
		free(blockDims->phaseVector);
		free(blockDims->phaseState);
		free(blockDims->outBuf);
		free(blockDims->tapDelayLineBuff);
		free(blockDims->wrIdx);
		free(blockDims->rdIdx);
		free(blockDims->tapIdx);
		free(blockDims);
		free(blockParams);
		return NULL;
	}

	phaseOffsets->numPhases = numDataStates;

    stateStr.data = NULL; /* stateStr.data == NULL if L>1 */
	if(L>1) {		
        stateStr.data = (int_T *)calloc(L-1,sizeof(int_T));
	    if(NULL == stateStr.data){
		    free(phaseOffsets->phase);
		    free(phaseOffsets);
			free(tempInitialData);
			free(prehistoryData);
		    free(blockDims->phaseVector);
		    free(blockDims->phaseState);
		    free(blockDims->outBuf);
		    free(blockDims->tapDelayLineBuff);
		    free(blockDims->wrIdx);
		    free(blockDims->rdIdx);
		    free(blockDims->tapIdx);
		    free(blockDims);
		    free(blockParams);
		    return NULL;
	    }
	}

    /* create each of the possible data sequences for driving the modulator */
    for (dataIdx=0; dataIdx < numDataStates; dataIdx++) {
        
        transition_T *tempTransition = NULL;
        
        stateStr.phase = 0;
        
        /* --- Create the data sequence */
        if(L>1) {
            int_T sampleIdx;
            
            /* --- Compute the data sequence with mapping */
            dec2base(  &dataIdx,                            /* Decimal data        */
                10,                                 /* Input base          */
                1,                                  /* Input length        */
                INT_T_VEC,                          /* Input type          */
                0,                                  /* Demap input         */
                0,                                  /* Natural binary      */
                (int_T *)stateStr.data,             /* Output vector       */
                M,                                  /* Output base         */
                L-1,                                /* Output ELEMENT size */
                INT_T_VEC,                          /* Output type         */
                1);                                 /* Map to symbol values*/
            
            
            /* --- The modulator expects its input as a vector of */
            /*     reals, so copy the integer vector                   */
            for (sampleIdx=0;sampleIdx<L-1; sampleIdx++) {
                tempInitialData[sampleIdx] = (real_T)(((int_T *)stateStr.data)[sampleIdx]);
            }
            
        } else {
            stateStr.data = NULL;
        }
        /* --- Update the block parameter structures */
        blockParams->numOffsets        = 1;
        blockParams->phaseOffset       = &(stateStr.phase); 
        blockParams->initialFilterData = (L>1 ? prehistoryData : NULL); /* initialize with prehistory data */
        
        /* --- Create all of the transition details */

        tempTransition = (transition_T*)calloc(1,sizeof(transition_T));
        if(tempTransition == NULL){
            return(NULL);
        }
        tempTransition->output = (void *)calloc(samplesPerSymbol,sizeof(creal_T));
        if(tempTransition->output == NULL){
            free(tempTransition);
            return(NULL);
        }

		/* initialize filter and modulator */
        initFilter(blockDims,blockParams);
        initCPMMod(blockDims,blockParams);

        /* run the modulator for L-1 symbols */
        for (symbIdx=0; symbIdx < (L-1); symbIdx++) {
            real_T      tempInput;
            
            tempInput  = (real_T)tempInitialData[(L-2)-symbIdx];
                        
            /* --- Produce the waveform */
            modulate(blockDims,  blockParams, true, true, &tempInput);
            integrate(blockDims, (creal_T*)(tempTransition->output));
            
        } /* end of for (symbIdx... */
        
        /* assign the phase offsets */
        phaseOffsets->phase[dataIdx] = blockDims->phaseState[0];  
           
        /* free( up memory in tempTransitions before it goes out of scope */
        if(tempTransition->output != NULL){
            free(tempTransition->output);
        }
        if(tempTransition != NULL){
            free(tempTransition);
        }
    } /* end of for (dataIdx;... */

	/* Now, once we have the array of phase offsets, adjust them so that the phase 
	   corresponding to the preHistory is set to initialPhase and all others are adjusted accordingly */

	if(L>1){
		base2dec(preHistory,                   /* Input vector        */
			M,                                  /* Input base          */
			L-1,                                /* Input ELEMENT size  */
			1,                                  /* Input length        */
			REAL_T_VEC,                         /* Input type          */
			&prehistoryIdx,                     /* Output data         */
			INT_T_VEC,                          /* Output type         */
			1);                                 /* Map to symbol values*/
	}
	deltaPhase = initialPhase - phaseOffsets->phase[prehistoryIdx];

    for (dataIdx=0; dataIdx < numDataStates; dataIdx++) {
        phaseOffsets->phase[dataIdx] += deltaPhase;  
	}
								   
	/* --- Free memory that is not part of the returned structure */
	if(NULL != tempInitialData) {
		free(tempInitialData);
	}
    if(NULL != blockDims->tapIdx) {
		free(blockDims->tapIdx);
	}
    if(NULL != blockDims->rdIdx) {
		free(blockDims->rdIdx);
	}
    if(NULL != blockDims->wrIdx) {
		free(blockDims->wrIdx);
	}
    if(NULL != blockDims->tapDelayLineBuff) {
		free(blockDims->tapDelayLineBuff);
	}
    if(NULL != blockDims->outBuf) {
		free(blockDims->outBuf);
	}
    if(NULL != blockDims->phaseState) {
		free(blockDims->phaseState);
	}
    if(NULL != blockDims->phaseVector) {
		free(blockDims->phaseVector);
	}
    if(NULL != blockParams) {
		free(blockParams);
	}
    if(NULL != blockDims) {
		free(blockDims);
	}
    if(NULL != prehistoryData) {
		free(prehistoryData);
	}

    return phaseOffsets;
    
} /* end of createPhaseOffsets */


/* ******************************************************************** */
/* Function: createPhaseTrellis                                         */
/* Purpose:  Create a phase trellis using the modulation parameters.    */
/*                                                                      */
/* Passed in: const int_T M                                             */
/*            const int_T L                                             */
/*            const int_T m                                             */
/*            const int_T p                                             */
/*            const real_T *filterPtr                                   */ 
/*            const int_T  numCoef                                      */
/*                                                                      */
/* Passed out: stateStruct_T * (NULL if Error)                          */
/* ******************************************************************** */
stateStruct_T *createPhaseTrellis(SimStruct *S,
                                  const int_T M,                     /* Alphabet size    */    
                                  const int_T L,                     /* Pulse length     */            
                                  const int_T m, const int_T p,      /* Modindex h = m/p */
                                  const int_T samplesPerSymbol,                         
                                  const real_T *filterPtr,           /* Matlab filter                */ 
                                  const int_T  numCoef,              /* Number of filter coeficients */
                                  const phaseOffset_T *phaseOffsets) /* phase offsets */           
                                  
{    
    
    const int_T  numPhaseStates   = (m % 2 == 0 ? p : 2*p);
    const int_T  numDataStates    = (int_T)pow(M,(L-1));
    const int_T  numStates        = numPhaseStates*numDataStates;
    const real_T phaseStateDelta  = (DSP_TWO_PI/(real_T)numPhaseStates);    /* Spacing between phase states */
    
    stateStruct_T  *stateObj;
    state_T        *stateStr;
    
    block_params_T *blockParams;
    block_dims_T   *blockDims;
    
    real_T *tempInitialData       = NULL; /* Used to pass the initial data to the modulator (as the modulator requires real_T) */
    
    const int_T order             = numCoef - 1;
    const int_T tapDelayLineWidth = (int_T)(ceil((real_T)order/(real_T)samplesPerSymbol));
    
    int_T stateCount=0, phaseIdx=0, stateIdx=0;
 
    stateObj = calloc(1,sizeof(stateStruct_T));
	if(NULL == stateObj){
		return NULL;
	}
    stateStr = calloc(numStates,sizeof(state_T));
	if(NULL == stateStr){
		free(stateObj);
		return NULL;
	}
    blockParams = (block_params_T *) calloc(1,sizeof(block_params_T));
	if(NULL == blockParams){
		free(stateStr);
		free(stateObj);
		return NULL;
	}

    blockDims = (block_dims_T *)   calloc(1,sizeof(block_dims_T));
	if(NULL == blockDims){
		free(blockParams);
		free(stateStr);
		free(stateObj);
		return NULL;
	}

	/* --- Populate the state object*/
    stateObj->M = M;
    stateObj->L = L;
    stateObj->m = m;
    stateObj->p = p;    
    stateObj->samplesPerSymbol = samplesPerSymbol;
    
    stateObj->numPhaseStates = numPhaseStates;
    stateObj->numDataStates  = numDataStates;
    stateObj->numStates      = numStates;
    
    /* --- Dimension info */
    blockDims->numBits          = 1;
    blockDims->isMultiRateBlk   = false;
    blockDims->isMultiTasking   = false;
    
    blockDims->tapIdx           = (int_T *) calloc(1,sizeof(int_T));
	if(NULL == blockDims->tapIdx){
		free(blockDims);
		free(blockParams);
		free(stateStr);
		free(stateObj);
		return NULL;
	}
    blockDims->rdIdx            = (int_T *) calloc(1,sizeof(int_T));
	if(NULL == blockDims->rdIdx){
		free(blockDims->tapIdx);
		free(blockDims);
		free(blockParams);
		free(stateStr);
		free(stateObj);
		return NULL;
	}
    blockDims->wrIdx            = (int_T *) calloc(1,sizeof(int_T));
	if(NULL == blockDims->wrIdx){
		free(blockDims->rdIdx);
		free(blockDims->tapIdx);
		free(blockDims);
		free(blockParams);
		free(stateStr);
		free(stateObj);
		return NULL;
	}
    
    blockDims->tapDelayLineWidth= tapDelayLineWidth;
    
    blockDims->tapDelayLineBuff = (real_T *)calloc(tapDelayLineWidth,sizeof(real_T));
	if(NULL == blockDims->tapDelayLineBuff){
		free(blockDims->wrIdx);
		free(blockDims->rdIdx);
		free(blockDims->tapIdx);
		free(blockDims);
		free(blockParams);
		free(stateStr);
		free(stateObj);
		return NULL;
	}
    blockDims->outBuf           = (real_T *)calloc(samplesPerSymbol*2,sizeof(real_T));
	if(NULL == blockDims->outBuf){
		free(blockDims->tapDelayLineBuff);
		free(blockDims->wrIdx);
		free(blockDims->rdIdx);
		free(blockDims->tapIdx);
		free(blockDims);
		free(blockParams);
		free(stateStr);
		free(stateObj);
		return NULL;
	}
    blockDims->phaseState       = (real_T *)calloc(1,sizeof(real_T));
	if(NULL == blockDims->phaseState){
		free(blockDims->outBuf);
		free(blockDims->tapDelayLineBuff);
		free(blockDims->wrIdx);
		free(blockDims->rdIdx);
		free(blockDims->tapIdx);
		free(blockDims);
		free(blockParams);
		free(stateStr);
		free(stateObj);
		return NULL;
	}
    blockDims->phaseVector      = (real_T *)calloc(samplesPerSymbol*2,sizeof(real_T));
	if(NULL == blockDims->phaseVector){
		free(blockDims->phaseState);
		free(blockDims->outBuf);
		free(blockDims->tapDelayLineBuff);
		free(blockDims->wrIdx);
		free(blockDims->rdIdx);
		free(blockDims->tapIdx);
		free(blockDims);
		free(blockParams);
		free(stateStr);
		free(stateObj);
		return NULL;
	}
    
    blockDims->inFramebased     = 1;
    blockDims->inFrameSize      = 1;
    blockDims->inElem           = 1;
    blockDims->numChans         = 1;
    
    blockDims->outElem          = samplesPerSymbol;
    blockDims->outFrameSize     = samplesPerSymbol;
    
    /* --- Parameter info */
    blockParams->pulseLength        = L;
    blockParams->samplesPerSymbol   = samplesPerSymbol;
    
    blockParams->numInitData        = L-1;
    blockParams->initialFilterData  = NULL;
    
    blockParams->bufferWidth        = tapDelayLineWidth/(blockDims->numChans);
    
    blockParams->numOffsets         = 0;
    blockParams->phaseOffset        = NULL;
    
    blockParams->filterArg          = (real_T *)filterPtr;
    blockParams->filterLength       = numCoef;
    
    blockParams->initialPhaseSwitch = INITIAL_PHASE_AFTER_PREHISTORY;
        
    /* --- Create the state transitions */
    
    /* --- If the pulse length is greater than 1, then a prehistory is required. */
    /*     So, allocate the integer vector used by the dec2base function.        */
    if(L>1) {
        tempInitialData = (real_T  *)calloc(L-1,sizeof(real_T));        
		/* This is used to hold the initial data of the modulator */
		if(NULL == tempInitialData){
			free(blockDims->phaseVector);
			free(blockDims->phaseState);
			free(blockDims->outBuf);
			free(blockDims->tapDelayLineBuff);
			free(blockDims->wrIdx);
			free(blockDims->rdIdx);
			free(blockDims->tapIdx);
			free(blockDims);
			free(blockParams);
			free(stateStr);
			free(stateObj);
			return NULL;
		}
    }

    for (stateIdx=0; stateIdx<numStates; stateIdx++) {
		stateStr[stateIdx].data = NULL;
    }
    for (stateIdx=0; stateIdx<numStates; stateIdx++) {
        if(L>1) {
			stateStr[stateIdx].data = (int_T *)calloc(L-1,sizeof(int_T));
			if(NULL == stateStr[stateIdx].data){
				int_T freeIdx;
				for (freeIdx=0; freeIdx<stateIdx; freeIdx++) {
					free(stateStr[freeIdx].data);
				}
				free(tempInitialData);
				free(blockDims->phaseVector);
				free(blockDims->phaseState);
				free(blockDims->outBuf);
				free(blockDims->tapDelayLineBuff);
				free(blockDims->wrIdx);
				free(blockDims->rdIdx);
				free(blockDims->tapIdx);
				free(blockDims);
				free(blockParams);
				free(stateStr);
				free(stateObj);
				return NULL;
			}
		}
    }
    stateCount = 0; /* This holds the ongoing state count. */
    /* It Could be replaced by a calculation based phaseIdx and dataIdx. */
    for (phaseIdx=0; phaseIdx<numPhaseStates; phaseIdx++) {
        int_T dataIdx;
        for (dataIdx=0; dataIdx<numDataStates; dataIdx++) {
            
            /* --- Create the state details */
            int_T  currentIdx;
            real_T initialPhase;
            transition_T *tempTransition;
            int_T *tempDataInt = NULL;

            stateStr[stateCount].phase = (real_T)(phaseIdx)*phaseStateDelta;
            
            /* --- Create the prehistory */
            if(L>1) {
                int_T sampleIdx;
                
                /* --- Compute the prehistory with mapping */
                dec2base(  &dataIdx,                            /* Decimal data        */
                    10,                                 /* Input base          */
                    1,                                  /* Input length        */
                    INT_T_VEC,                          /* Input type          */
                    0,                                  /* Demap input         */
                    0,                                  /* Natural binary      */
                    (int_T *)stateStr[stateCount].data, /* Output vector       */
                    M,                                  /* Output base         */
                    L-1,                                /* Output ELEMENT size */
                    INT_T_VEC,                          /* Output type         */
                    1);                                 /* Map to symbol values*/
                
                
                /* --- The modulator expects its prehistory as a vector of */
                /*     reals, so copy the integer vector                   */
                for (sampleIdx=0;sampleIdx<L-1; sampleIdx++) {
                    tempInitialData[sampleIdx] = (real_T)(((int_T *)stateStr[stateCount].data)[sampleIdx]);
                }
            }
            
            /* --- Create the transition details */

            /* set the phase for each node in the trellis using phase offset from createPhaseOffsets() */
            initialPhase = stateStr[stateCount].phase + phaseOffsets->phase[dataIdx];
            
            /* --- Update the block parameter structures */
            blockParams->numOffsets        = 1;
            
            blockParams->phaseOffset       = &initialPhase; 
            blockParams->initialFilterData = (L>1 ? tempInitialData : NULL);
            
            /* --- Create all of the transition details */
           /* This is memory pointed to by tempTransition is be returned with the structure */
            tempTransition = NULL;   
            
            tempTransition = (transition_T*)calloc(M,sizeof(transition_T));
			if(NULL == tempTransition){
               if(L>1) {
				    int_T freeIdx;
				    for (freeIdx=0; freeIdx<numStates; freeIdx++) {
					    free(stateStr[freeIdx].data);
				    }
    				free(tempInitialData);
                }
				free(blockDims->phaseVector);
				free(blockDims->phaseState);
				free(blockDims->outBuf);
				free(blockDims->tapDelayLineBuff);
				free(blockDims->wrIdx);
				free(blockDims->rdIdx);
				free(blockDims->tapIdx);
				free(blockDims);
				free(blockParams);
				free(stateStr);
				free(stateObj);
				return NULL;
			}
            
            /* initialize the pointers in tempTransition[currentIdx] to NULL */
            for (currentIdx=0; currentIdx<M; currentIdx++) {
                tempTransition[currentIdx].output = NULL;
                tempTransition[currentIdx].dataState = NULL;
            }


            /* Allocate a block of memory for all of the 
             * tempTransition[currentIdx].output pointers */
            tempTransition[0].output = (void *)calloc(samplesPerSymbol*M,sizeof(creal_T));
            if(NULL == tempTransition[0].output){
                /* free( the transition struct */
                free(tempTransition);
                if(L>1) {
				    int_T freeIdx;
				    for (freeIdx=0; freeIdx<numStates; freeIdx++) {
					    free(stateStr[freeIdx].data);
				    }
    				free(tempInitialData);
                }
				free(blockDims->phaseVector);
				free(blockDims->phaseState);
				free(blockDims->outBuf);
				free(blockDims->tapDelayLineBuff);
				free(blockDims->wrIdx);
				free(blockDims->rdIdx);
				free(blockDims->tapIdx);
				free(blockDims);
				free(blockParams);
				free(stateStr);
				free(stateObj);
                return NULL;
			}
            /* assign the other output pointers to locations in the allocated block */
            for (currentIdx=1; currentIdx<M; currentIdx++) {
                tempTransition[currentIdx].output = (void *)
                     ((creal_T*)(tempTransition[0].output) + currentIdx*samplesPerSymbol);
            }

            /* This is memory that will be returned with the structure */
            tempDataInt = NULL;
            if(L>1){
                tempDataInt = (int_T *)calloc((L-1)*M,sizeof(int_T)); 
                if(NULL == tempDataInt){
				    int_T freeIdx;
                    /* free( the previously allocated block pointed to by the output pointers (0) */
                    free(tempTransition[0].output);
                    tempTransition[0].output = NULL;
                    /* free( the transition struct */
                    free(tempTransition);
				    for (freeIdx=0; freeIdx<numStates; freeIdx++) {
					    free(stateStr[freeIdx].data);
				    }
    				free(tempInitialData);
				    free(blockDims->phaseVector);
				    free(blockDims->phaseState);
				    free(blockDims->outBuf);
				    free(blockDims->tapDelayLineBuff);
				    free(blockDims->wrIdx);
				    free(blockDims->rdIdx);
				    free(blockDims->tapIdx);
				    free(blockDims);
				    free(blockParams);
				    free(stateStr);
				    free(stateObj);
				    return NULL;
			    }
                /* assign the other data state pointers to locations in the allocated block */
                for (currentIdx=0; currentIdx<M; currentIdx++) {
                    tempTransition[currentIdx].dataState = 
                        tempDataInt + currentIdx*(L-1);
                }
            }
            
            for (currentIdx=0; currentIdx<M; currentIdx++) {
                real_T h;
                
                const int_T currentSym   = 2*currentIdx-(M-1);
                real_T      tempInput    = (real_T)currentSym;
                
                h = (real_T)m/(real_T)p;
                
                tempTransition[currentIdx].input  = currentSym;
                initFilter(blockDims,blockParams);
                initCPMMod(blockDims,blockParams);
                
                /* --- Produce the waveform */
                modulate(blockDims,  blockParams, true, true, &tempInput);
                integrate(blockDims, (creal_T*)(tempTransition[currentIdx].output));
                
                /* --- Update the dataState - data is shifted in from the left. */
                /*     The dataState field is an integer vector                 */
                if(L>1) {
                    int_T  sampleIdx, dataStateValue;
                    real_T phaseState;

                    /* --- Determine the phase and phase index */
                    phaseState = stateStr[stateCount].phase + (h * DSP_PI * (real_T)(stateStr[stateCount].data[L-2]));

                    while(phaseState < 0.0){
						phaseState += (real_T) DSP_TWO_PI;
					}
                    
                    /* --- The data will be copied into an integer vector used to compute the destination state */
                    for (sampleIdx=L-2;sampleIdx > 0; sampleIdx--) {
                        tempDataInt[sampleIdx] = ((int_T *)stateStr[stateCount].data)[sampleIdx-1];
                    }
                    tempDataInt[0] = currentSym;
                    
                    /* --- Determine the destination state */
                    base2dec(  tempDataInt,      /* Base M data         */
                        M,                /* Output base         */
                        L-1,              /* Input ELEMENT size  */
                        1,                /* Input length        */
                        INT_T_VEC,        /* Input type          */
                        &dataStateValue,  /* Output data         */
                        INT_T_VEC,        /* Output type         */
                        1);               /* Map to symbol values*/
                    tempTransition[currentIdx].nextPhase = 
                        fmod(floor(0.5 + phaseState/phaseStateDelta)*pow(M,L-1) 
                            + (real_T)dataStateValue, (real_T)numStates);
                    
                    tempTransition[currentIdx].dataState = (int_T *)tempDataInt;
                    
                } else {
                    real_T phaseState;
                    
                    phaseState = stateStr[stateCount].phase + (h * DSP_PI * (real_T)currentSym);
                    while(phaseState < 0.0){
						phaseState += (real_T) DSP_TWO_PI;
					}
                    
                    tempTransition[currentIdx].nextPhase = fmod(floor(0.5 + phaseState/phaseStateDelta), (real_T)numStates);
                }
                    
            } /* End of currentIdx loop */
                   
            /* pass the transition struct (and associated memory) to the state structure */ 
            stateStr[stateCount].transitions = tempTransition;
            tempTransition = NULL; /* not used anymore */

            stateCount++;
            
        }   /* End of dataIdx loop */
        
    }   /* End of phaseIdx loop*/
    
    /* --- Assign the state array to the state object */
    stateObj->states = stateStr;
    
    /* --- Free memory that is not part of the returned structure */
	if(NULL != tempInitialData) {
		free(tempInitialData);
	}
    if(NULL != blockDims->tapIdx) {
		free(blockDims->tapIdx);
	}
    if(NULL != blockDims->rdIdx) {
		free(blockDims->rdIdx);
	}
    if(NULL != blockDims->wrIdx) {
		free(blockDims->wrIdx);
	}
    if(NULL != blockDims->tapDelayLineBuff) {
		free(blockDims->tapDelayLineBuff);
	}
    if(NULL != blockDims->outBuf) {
		free(blockDims->outBuf);
	}
    if(NULL != blockDims->phaseState) {
		free(blockDims->phaseState);
	}
    if(NULL != blockDims->phaseVector) {
		free(blockDims->phaseVector);
	}
    if(NULL != blockDims) {
		free(blockDims);
	}
    if(NULL != blockParams) {
		free(blockParams);
	}

    return(stateObj);    
} /* end of createPhaseTrellis */


/* ******************************************************************** */
/* Function: freePhaseTrellis                                           */
/* Purpose:  Free all of the memory used by a state structure.          */
/*                                                                      */
/* Passed in: state_T stateStr                                          */
/*                                                                      */
/* Passed out: void                                                     */
/* ******************************************************************** */
void freePhaseTrellis(stateStruct_T *stateObj)
{
    int_T stateIdx;
    state_T *stateStr = stateObj->states;
    
    for (stateIdx=0; stateIdx<stateObj->numStates; stateIdx++)
    {        
        /* --- dataState */
        if(NULL != stateStr[stateIdx].transitions[0].dataState) {
            free(stateStr[stateIdx].transitions[0].dataState);
        }
        
        /* --- Output waveform */
        if(NULL != stateStr[stateIdx].transitions[0].output) {
            free(stateStr[stateIdx].transitions[0].output);
        }
        
        /* --- State prehistory associated with the state */
        if(NULL != stateStr[stateIdx].data) {
            free(stateStr[stateIdx].data);
        }
        
        /* --- Transition associated with the state */
        if(NULL != stateStr[stateIdx].transitions) {
            free(stateStr[stateIdx].transitions);
        }
    }
    
    if(NULL != stateStr) {
        free(stateStr);
    }
    if(NULL != stateObj) {
        free(stateObj);
    }
}


/* ********************************************************************** */
/* Function: dec2base                                                     */
/* Purpose:  Perform decimal to arbitrary base conversion.                */
/*                                                                        */
/* Desc:     If the input is mapped to 2v-(M-1), then the inMapped input  */
/*           must be set to ensure that the input is demapped before      */
/*           conversion to the required base.                             */
/*           Gray decoding occurs after any *bipolar* demapping.          */
/*                                                                        */
/*           The input will be converted to the required output base      */
/*           before any output mapping is performed.                      */
/*                                                                        */
/* Passed in: const void  *decVal   -> Pointer to the decimal vector      */
/*            const int_T  inBase   -> Input base used for demapping      */
/*            const int_T  inLen    -> Number of decimal values to convert*/
/*            const int_T  inType   -> Input type                         */
/*            const int_T  inMapped -> is input mapped to 2v-(M-1)        */
/*            const int_T  inGrayMapped -> is the input Gray mapped       */ 
/*            void        *outVec   -> Pointer to output vector           */
/*            const int_T  outBase  -> Base used for output mapping       */
/*            const int_T  outSize  -> Number of elements in each output  */
/*            const int_T  outType  -> Output type                        */
/*            const int_T  outMapped-> Perform output mapping             */
/*                                                                        */
/* Passed out: char * (error message - NULL if OK)                        */
/*                                                                        */
/* Comments: 1) Input vector is inLen elements long                       */
/*           2) Output vector is inlen*outSize elements long              */
/*           3) inType and outType may be INT_T_VEC or REAL_T_VEC         */
/* ********************************************************************** */
char* dec2base(const void  *decVal, 
               const int_T  inBase,   
               const int_T  inLen,  
               const int_T  inType, 
               const int_T  inMapped,
               const int_T  inGrayMapped,
               void        *outVec,
               const int_T  outBase,
               const int_T  outSize,
               const int_T  outType,
               const int_T  outMapped)
               
{
    int_T MSBFlag = 1;
    int_T inputIdx;
      
    char* emsg = NULL;
  
    /* --- Commented out checking as it is not used by the calling functions. */
    /*      Can be used if this function is seperated. */
    /*   if (inBase < 2) { */
    /*       emsg = "The input base must be an integer greater than 1."; */
    /*       return(emsg); */
    /*   } */
    /*   */
    /*   if (outBase < 2) { */
    /*       emsg = "The output base must be an integer greater than 1."; */
    /*       return(emsg); */
    /*   } */
    /* End commented out checking */
    
    for (inputIdx=0; inputIdx<inLen; inputIdx++)
    {
        int_T i, inc, Count, inNum;
        
        switch (inType) {
        case INT_T_VEC:
            inNum = ((int_T *)decVal)[inputIdx];
            break;
        case REAL_T_VEC:
            inNum = (int_T)((real_T *)decVal)[inputIdx];
            break;
        default:
            /* Unknown conversion input type */
            return NULL;
        }
        
        if(inMapped) {
            inNum = (inNum + inBase - 1)/2;
        }
        
        if(inGrayMapped) {
            inNum = inNum ^ (inNum/2);
        }
        
        if (MSBFlag) {
            Count = (inputIdx*outSize)+outSize - 1;
            inc   = -1;
        } else {
            Count = inputIdx*outSize;
            inc   = 1; 
        }
        
        if (inNum >= 0) {
            for (i=0; i < outSize; i++) 
            {
                switch (outType) {
                case INT_T_VEC:
                    ((int_T *)outVec)[Count]  = inNum % outBase;
                    if(outMapped) {
                        ((int_T *)outVec)[Count] = 2*((int_T *)outVec)[Count]-(outBase-1);
                    }
                    
                    break;
                case REAL_T_VEC:
                    ((real_T *)outVec)[Count] = (real_T)(inNum % outBase);
                    if(outMapped) {
                        ((real_T *)outVec)[Count] = 2*((real_T *)outVec)[Count]-(outBase-1);
                    }
                    
                    break;
                default:
                    /* Unknown conversion output type */
                    return NULL;
                }
                
                inNum /= outBase;
                
                Count += inc;
            }
        } else {
            /* --- The input to convert must be positive. If not, throw error. */
            /* --- Commented out for now as the calling functions dont use this */
            /* --- case. */
            /* emsg = "The input to convert must be positive."; */
			/* return(emsg); */
        }
    } /* for (inputIdx=0; inputIdx<inLen; inputIdx++) */

    return(emsg);
}
               
/* ********************************************************************** */
/* Function: base2dec                                                     */
/* Purpose:  Perform base p to decimal conversion.                        */
/*                                                                        */
/* Passed in: const void  *baseVal   -> Pointer to the input vector       */
/*            const int_T  base      -> Output base                       */
/*            const int_T  inSize    -> Number of elements in each output */
/*            const int_T  inLen     -> Number of values to convert       */
/*            const int_T  inType    -> Input type                        */
/*            void        *outVec    -> Pointer to output vector          */
/*            const int_T  outType   -> Output type                       */
/*            const int_T  outMapped -> Perform output mapping            */
/*                                                                        */
/* Passed out: char * (error message - NULL if OK)                        */
/*                                                                        */
/* Comments: 1) Input vector is inLen elements long                       */
/*           2) Output vector is inlen*outSize elements long              */
/*           3) inType and outType may be INT_T_VEC or REAL_T_VEC         */
/*                                                                        */
/* ********************************************************************** */
char* base2dec(const void  *baseVal,
               const int_T  base,   
               const int_T  inSize, 
               const int_T  inLen,  
               const int_T  inType, 
               void        *outVec, 
               const int_T  outType,
               const int_T  outMapped)    
               
{
    int_T inputIdx;
    
    char* emsg = NULL;
    
    /* --- Commented out checking as it is not used by the calling functions. */
    /*       Can be used if this function is separated. */
    /*   if (base < 2) { */
    /*       emsg = "The conversion base must be an integer greater than 1."; */
    /*		return(emsg); */
    /*   } */
    
    for (inputIdx=0; inputIdx<inLen; inputIdx++) 
    {
        int_T i, pOw, inc, Count;
        int_T MSBFlag = 1;
        int_T outNum;
        
        outNum = 0;
        pOw    = 1;
        
        if (MSBFlag) {
            Count = (inputIdx*inSize)+inSize - 1;
            inc   = -1;
        } else {
            Count = inputIdx*inSize;
            inc   = 1; 
        }
        
        /* --- Convert the input */    
        for (i=0; i <inSize; i++)
        {
            int_T sym;
            /* --- Apply the mapping if required */
            switch (inType) {
            case INT_T_VEC:
                if(outMapped) {
                    sym = (((int_T *)baseVal)[Count]+(base-1))/2;
                } else {
                    sym = ((int_T *)baseVal)[Count];
                }
                break;
            case REAL_T_VEC:
                if(outMapped) {
                    sym = (int_T)((((real_T *)baseVal)[Count]+(base-1))/2);
                } else {
                    sym = (int_T)(((real_T *)baseVal)[Count]);
                }
                break;
            default:
                /* --- Unknown conversion input type */
                return NULL;
            }
            outNum += (int_T)(abs(sym) % base * pOw);
            pOw    *= base;
            Count  += inc;
        }
        
        /* --- Assign the output */
        switch (outType) {
        case INT_T_VEC:
            ((int_T *)outVec)[inputIdx]  = outNum;
            break;
        case REAL_T_VEC:
            ((real_T *)outVec)[inputIdx] = (real_T)outNum;
            break;
        default:
            /* --- Unknown conversion output type */
            return NULL;
        }
    }

    return(emsg);
}

/* --- EOF --- */
