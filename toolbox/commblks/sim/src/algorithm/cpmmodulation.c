/*
 * Copyright 1996-2004 The MathWorks, Inc.
 * $Revision: 1.1.6.3 $ $Date: 2004/02/09 06:38:03 $
 */

#include "comm_defs.h"
#include "cpmmodulation.h"

/* ******************************************************************** */
/* Function: initCPMMod                                                 */
/* Purpose:  Initialize the CPM modulator.                              */
/*           This requires that the modulator is called with the        */
/*           required inputs sufficient times to fill its internal      */
/*           buffer.                                                    */
/*           The integration stage of the CPM modulation will not be    */
/*           called to ensure that the initial phase is that selected   */
/*           by the user.                                               */
/*                                                                      */
/* Passed in: block_dims_T   *BD                                        */
/*            block_params_T *BP                                        */
/*                                                                      */
/* Passed out: char* (error message. NULL if no error)                  */
/* ******************************************************************** */

char* initCPMMod(block_dims_T *BD, block_params_T *BP)
{
    /* --- Frame info */
    const int_T inFramebased = BD->inFramebased;
    const int_T inFrameSize  = BD->inFrameSize;
    const int_T numChans     = BD->numChans;

    /* --- Parameter info */
    const int_T   pulseLength        = BP->pulseLength;
    const int_T   samplesPerSymbol   = BP->samplesPerSymbol;
    const real_T *initialFilterData  = BP->initialFilterData;
    const int_T   initialPhaseSwitch = BP->initialPhaseSwitch;

    /* --- Info required for initial conditions */
    const int_T numInitData  = BP->numInitData;

    const int_T numOffsets   = BP->numOffsets;

    real_T  *phaseState      = BD->phaseState; /* NOTE: phase state comes from the block dimension structure */
    real_T  *phaseOffset     = BP->phaseOffset;

    int_T k, inputCount;
    real_T  *tempInVec;     /* Used to hold the prehistory data */

    /* --- Frame info */
    const int_T outFrameSize = BD->outFrameSize;

    creal_T *tempOutVec;

    char* emsg = NULL;

    /* --- Allocate the memory for the temporary output buffer                 */
    /*     This is used during the integration when the state of the modulator */
    /*     at the end of a pulse is required.                                  */
    /*     The memory will be freed at the end of the function.                */
    tempOutVec = (creal_T *)calloc(outFrameSize, sizeof(creal_T));

    /* --- Unable to allocate temporary output buffer */
    if(tempOutVec == NULL) {       
        return NULL; /* --- caught in the initialization */
    }

    /* --- Zero the phase vector and state */
    {
        int_T k2;
        real_T *y = BD->phaseVector;

        for (k2=0; k2 < numChans; k2++) 
        {
            int_T i, frameOffset;

            frameOffset = k2*outFrameSize;
            for (i=0; i<outFrameSize;i++) {
                y[frameOffset+i] = 0.0;
            }

            /* --- Zero the state */
            phaseState[k2] = 0.0;
        }
    }

    /* --- Set the initial phase if required */
    if (initialPhaseSwitch == INITIAL_PHASE_BEFORE_PREHISTORY) {
        /* --- Initialize the phase offset for each channel */
        for (k=0; k < numChans; k++) {
            phaseState[k] = ((numOffsets == 1) ? phaseOffset[0] : phaseOffset[k]);
        }
    }

    /* If the pulse length is > 1, then initialize the prehistory */
    if(pulseLength > 1) {

        /* --- Determine how many times the modulate function needs to be called */
        /*     to initialize the filter.                                         */
        if(inFrameSize > (pulseLength - 1) ) {
            inputCount = 1;
        } else {
            if((pulseLength - 1) % inFrameSize == 0) {
                inputCount = (pulseLength - 1)/inFrameSize;
            } else {
                inputCount = ((pulseLength - 1)/inFrameSize) + 1;    /* This is intended to be integer division */
            }
        }

        /* --- Allocate the memory for the temporary input buffer              */
        tempInVec = (real_T *)calloc(inputCount*inFrameSize*numChans, sizeof(real_T));

        /* Unable to allocate temporary input buffer */
        if(tempInVec == NULL) {
            return NULL;  /* --- caught in the initialization */
        }

        /* --- Fill the temp buffer  */
        {
            const int_T D = inFrameSize - (pulseLength - 1);
            int_T i    = 0;
            int_T MSBFlag = 1;
            int_T sIdx, inc;

            if (MSBFlag) {
                sIdx = numInitData - 1;
                inc  = -1;
            } else {
                sIdx = 0;
                inc  = 1;
            }

            for (i=0; i < inputCount*inFrameSize*numChans; i++)
            {
                int_T k3;

                k3 = i % inFrameSize;

                tempInVec[i] = (real_T)initialFilterData[sIdx];

                if ((k3 >= D) && (numInitData > 1)) {
                    sIdx += inc;
                }
            }
        }

        /* --- Modulate the data */
        /*     NOTE: The access of tempInVec is not suiable for multichannel operation. */
        for (k=0; k<inputCount; k++)
        {
            if(inFramebased) {
                modulate(BD, BP, true, true, tempInVec+(k*inFrameSize));
                integrate(BD, tempOutVec);
            } else {
                /* --- For non frame-based inputs, the input is only updated every */
                /*     samplesPerSymbol outputs */
                int_T i;

                for (i=0; i < samplesPerSymbol; i++) {
                    modulate(BD, BP,  (const boolean_T)(((i % samplesPerSymbol) == 0) ? true : false), true, tempInVec+(k*inFrameSize));
                    integrate(BD, tempOutVec);
                }
            }
        }

        /* --- Free the temporary vector */
        if(NULL != tempInVec) {
            free(tempInVec);
        }

    } /* End of if(pulseLength > 1) {} */

    /* --- Set the initial phase if required */
    if (initialPhaseSwitch == INITIAL_PHASE_AFTER_PREHISTORY) {
        /* --- Initialize the phase offset for each channel */
        for (k=0; k < numChans; k++) {
            phaseState[k] = ((numOffsets == 1) ? phaseOffset[0] : phaseOffset[k]);
        }
    }

    /* --- Free the vector used by the integrator output */
    if(NULL != tempOutVec) {
        free(tempOutVec);
    }

    return(emsg);
}

/* ******************************************************************** */
/* Function: initFilter                                                 */
/* Purpose:  Initialize the filter and its internal buffers.            */
/*                                                                      */
/* Passed in: block_dims_T   *BD                                        */
/*            block_params_T *BP                                        */
/*                                                                      */
/* Passed out: void                                                     */
/* ******************************************************************** */
void initFilter(block_dims_T *BD, block_params_T *BP)
{
    /* --- Matrix info */
    const int_T     inElem         = BD->inElem;
    const int_T     outElem        = BD->outElem;

    /* --- Frame info */
    const int_T     numChans       = BD->numChans;
    const uint_T    outBufWidth    = BD->outBufWidth;

    const int_T     iFactor        = BP->samplesPerSymbol;

    const boolean_T isMultiRateBlk = BD->isMultiRateBlk;
    const boolean_T isMultiTasking = BD->isMultiTasking;

    int_T *tapIdx = BD->tapIdx;
    int_T *rdIdx  = BD->rdIdx;
    int_T *wrIdx  = BD->wrIdx;

    /* **************************************** */
    /* Initialize indices into internal buffers */
    /* **************************************** */

    *wrIdx  = 0;
    *tapIdx = 0;

    if ( !(isMultiRateBlk && isMultiTasking) ) {
        /*
         * SingleRate && SingleTasking
         * SingleRate && MultiTasking
         * MultiRate  && SingleTasking
         *
         * We will only output one frame of IC's at startup in MULTI-RATE, MULTI-TASKING
         * mode. In all other modes, this block has a guaranteed full set of inputs at
         * the initial sample time, so there is NO need for any additional latency.
         *
         * NO latency is necessary since inputs are guaranteed to be there
         * at the first sample time -> initialize all indices to zero. and
         * just skip filling in any ICs in the output buffer since not used.
         */
        *rdIdx  = 0;
    }
    else  {
        /*
         * MultiRate && MultiTasking
         *
         * When latency IS necessary (i.e. only in multi-rate, multi-tasking mode):
         *
         *     Initial output sample number = (2 * "phases"), due to double buffer
         */

        *rdIdx  = ( (2*iFactor*inElem) - (outElem) ) / numChans;


    } /* Multirate AND Multitasking */

    /* ********************************************************************** */
    /* Initialize output buffer with appropriate ICs. The output initial      */
    /* conditions are passed into the S-fcn and must be either length zero,   */
    /* one, or length equal to the output buffer size (ICs are used ONLY for  */
    /* output buffer latency in certain situations where outputs are required */
    /* by Simulink before enough input sample processing has occured).        */
    /*                                                                        */
    /* For the FIR filter, leave states set to zero until we decide that this */
    /* is a useful extra feature. It gets a little more difficult since the   */
    /* input could be real but the coeffs can be complex, making the FIR ICs  */
    /* not matching the input complexity...this is not worth the extra code   */
    /* at this point in time (wait until someone asks for this!).             */
    /* ********************************************************************** */

    /* Real input signal and real filter -> real output buffer ICs */
    {
        real_T *outBuf = BD->outBuf;
        uint_T i;

        for(i = 0; i < outBufWidth; i++) {
            *outBuf++ = (real_T)0.0;
        }
    }
    /* --- Clear the tap delay line */
    {
        uint_T i;
        uint_T tapDelayLineWidth = BD->tapDelayLineWidth;
        real_T *tapDelayLineBuff = BD->tapDelayLineBuff;

        for(i = 0; i < tapDelayLineWidth; i++) {
            *tapDelayLineBuff++ = (real_T)0.0;
        }

    }

}

/* ******************************************************************** */
/* Function: convertAndCheck                                            */
/* Purpose:  Perform binary to integer conversion with optional Gray    */
/*           mapping and do not check the range of the inputs.          */
/*                                                                      */
/* Passed in: const int_T *binPtr                                       */
/*            int_T *symPtr                                             */
/*            const int_T symVecLen                                     */
/*            const int_T M                                             */
/*            const int_T inputType                                     */
/*            const int_T mappingType                                   */
/*                                                                      */
/* Passed out: char * (error message - NULL if OK)                      */
/* ******************************************************************** */
char* convertAndCheck(const real_T *binPtr, real_T *symPtr, const int_T symVecLen,
                             const int_T M,
                             const int_T inputType, const int_T mappingType)
{
    int_T i;
    char* emsg = NULL;

    for (i = 0; i < symVecLen; i++)
    {
        switch (inputType) {

            case BINARY_INPUT:
            {
                int_T       numBits = 0;
                int_T       bitIdx;
                real_T      bitVal;
                int32_T     symVal = 0;

                frexp((real_T)M, &numBits); /* Determine the no. of bits per symbol */
                numBits -= 1;               /* Actual no. of bits per symbol */

                for(bitIdx=0; bitIdx < numBits ; bitIdx++) {
                    bitVal = (real_T)binPtr[numBits*i+bitIdx];  /* Index from MSB first */
                    symVal <<= 1;
                    symVal += (int32_T)bitVal;
                }

                /* --- Map this symbol to Gray code if required */
                if(mappingType == GRAY_CODE) {
                    for(bitIdx=1; bitIdx < numBits ; bitIdx+=bitIdx) {
                        symVal^=symVal>>bitIdx;
                    }
                }

                /* --- Apply the mapping of the input symbol to the CPM symbol */
                /*     0 -> -(M-1), 1 -> -(M-2), etc                           */
                symVal = 2*symVal+1-M;

                /* --- Write the integer symbol to the integer vector  */
                symPtr[i] = (real_T)symVal;
            }
            break;

            case INTEGER_INPUT:
                /* --- Integer inputs must be +/- (M-2i-1), i=0,1, ..., M/2 -1 */
                /*     So, i = (M-x-1)/2 must be an integer                    */
                /*     So, (M-x-1) must be even                                */
            /*  if( ((M - (int_T)symPtr[i] - 1) % 2 != 0) || (abs((int_T)symPtr[i]) > M-1) ) { */
            /*       emsg = "For integer inputs, the input values must be in the range +/- (M-2i-1), i=0,1, ..., (M/2)-1."; */
            /*       return(emsg); */
            /*  } */
            break;

            default:
                /* Unknown input mode */
                return NULL;
        }

    } /* End of for (i = 0; i < symVecLen; i++) */
    return(emsg);
}

/* ******************************************************************** */
/* Function: modulate                                                   */
/* Purpose:  Modulate the input data based upon the required pulse      */
/*           shape. The function checks the data limit violations.      */
/*                                                                      */
/* Passed in: block_dims_T   *BD                                        */
/*            block_params_T *BP                                        */
/*            const boolean_T inportHit                                 */
/*            const boolean_T outportHit                                */
/*            real_T *inputPtr                                          */
/*                                                                      */
/* Passed out: void                                                     */
/* ******************************************************************** */
void modulate(block_dims_T *BD, block_params_T *BP, const boolean_T inportHit, const boolean_T outportHit, real_T *inputPtr)
{

    /* ******************************************************************** */
    /* If new input sample is currently available, first perform upsampling */
    /* and update the polyphase (multirate) filter at the upsampled rate.   */
    /* ******************************************************************** */
    if (inportHit) {

        /* --- Matrix info */
        const int_T inElem       = BD->inElem;

        /* --- Frame info */
        const int_T inFrameSize  = BD->inFrameSize;
        const int_T numChans     = BD->numChans;

        const int_T length       = BP->filterLength;
        const int_T iFactor      = BP->samplesPerSymbol;
        const int_T subOrder     = length / iFactor - 1; /* Compute the order of the subfilters */

        int_T      *tapIdx       = BD->tapIdx;
        int_T      *wrIdx        = BD->wrIdx;

        int_T curTapIdx=0, curPhaseIdx;

        real_T *u0 = inputPtr;  /* This is always a vector of integers in the correct range */

        /* Real data, real filter */
        int_T   k;
        real_T *tap0 = BD->tapDelayLineBuff;
        real_T *out  = BD->outBuf;

        for (k = 0; k < numChans; k++) {
            /* Each channel starts with the same filter phase but accesses
             * its own state memory and input.
             */
            int_T i;

            curTapIdx   = *tapIdx;
            curPhaseIdx =  0;

            for (i = 0; i < inFrameSize; i++) {
                /* The filter coefficients have (hopefully) been re-ordered into phase order */
                real_T	    *cff = BP->filterArg;
                const real_T  u   = *u0++;
                int_T         m;

                /* Generate the output samples */
                for (m = 0; m < iFactor; m++) {
                    int_T   j;
                    real_T *mem	= tap0 + curTapIdx;  /* Most recently saved input */
                    real_T  sum	= u * (*cff++);

                    for (j = 0; j <= curTapIdx; j++) {
                        sum += (*mem--) * (*cff++);
                    }

                    /* mem was pointing at the -1th element.  Move to end. */
                    mem += subOrder;

                    while(j++ < subOrder) {
                        sum += (*mem--) * (*cff++);
                    }

                    *(out + (*wrIdx)++) = sum;
                    ++curPhaseIdx;
                }

                /* Update the counters modulo their buffer size */
                if (curPhaseIdx >= iFactor) curPhaseIdx = 0;

                if (curPhaseIdx == 0) {
                    if ( (++curTapIdx) >= subOrder ) curTapIdx = 0;

                    /* Save the current input value */
                    tap0[curTapIdx] = u;
                }
            } /* inFrameSize */

            tap0 += subOrder;

        } /* channel */

        /* Update stored indices */
        *tapIdx = curTapIdx;

        if (*wrIdx >= 2*inElem*iFactor) *wrIdx = 0;

    }

    /* *********************************************** */
    /* Output the next processed sample when requested */
    /* *********************************************** */
    if (outportHit) {

        /* --- Matrix info */
        const int_T inElem       = BD->inElem;

        /* --- Frame info */
        const int_T inFrameSize  = BD->inFrameSize;
        const int_T outFrameSize = BD->outFrameSize;
        const int_T numChans     = BD->numChans;

        const int_T      iFactor           = BP->samplesPerSymbol;
        const real_T     outSigNormScaling = 1.0 / ( (real_T) iFactor );
        int_T           *rdIdx             = BD->rdIdx;
        int_T            sizeOfFrame;

        /* Real output */
        real_T *out               = BD->outBuf;
        real_T *y                 = BD->phaseVector;

        int_T   halfFrmBufWidth   = inFrameSize*iFactor;
        int_T   interpBufferWidth = inElem*iFactor;
        int_T   k;

        /* Move to the second half of the buffer */
        if ( *rdIdx >= halfFrmBufWidth ) {
            out += interpBufferWidth - halfFrmBufWidth;
        }

        sizeOfFrame = interpBufferWidth / numChans;

        for (k=0; k < numChans; k++) {
            int_T rIdx = k*sizeOfFrame;
            int_T i;

            for (i=0; i < outFrameSize; i++) {
                /* Output the current samples, NORMALIZED by the Interpolation */
                /* Factor in order to preserve input signal scaling. Note that */
                /* this is done here once at the end of the computation (i.e.  */
                /* just before the output gets sent out) in order to preserve  */
                /* as much signal numerical precision as possible.             */
                *y++ = ( *(out + (*rdIdx) + (rIdx++)) ) * outSigNormScaling;
            }
        }

        if ( (*rdIdx += outFrameSize) >= 2*inFrameSize*iFactor ) *rdIdx = 0;

    }

}

/* ******************************************************************** */
/* Function: integrate                                                  */
/* Purpose:  Integrate the shaped inputs to form the CPM phase.         */
/*                                                                      */
/* Passed in: block_dims_T *BD                                          */
/*            block_params_T *BP                                        */
/*            creal_T *outputPtr                                        */
/*                                                                      */
/* Passed out: void                                                     */
/* ******************************************************************** */
void integrate(block_dims_T *BD, creal_T *outputPtr)
{
    /* --- Frame info */
    const int_T outFrameSize = BD->outFrameSize;
    const int_T numChans     = BD->numChans;

    /* --- Integrate the output */
    {
        int_T k;
        real_T *y = BD->phaseVector;

        for (k=0; k < numChans; k++) {
            int_T i, frameOffset;
            real_T T;
            real_T ST = (BD->phaseState)[k];

            frameOffset = k*outFrameSize;

            for(i=0; i<outFrameSize;i++) {

                T = y[frameOffset+i];
                y[frameOffset+i] = ST;
                ST = y[frameOffset+i] + T;

                /* --- Ensure that phase is modulo 2*pi */
                y[frameOffset+i] = fmod(y[frameOffset+i],(real_T)(DSP_TWO_PI));

                /* --- Assign complex output argument */
                outputPtr[frameOffset+i].re = cos(y[frameOffset+i]);
                outputPtr[frameOffset+i].im = sin(y[frameOffset+i]);
            }
            /* --- Update the state */
            (BD->phaseState)[k] = ST;
        }
    }
}

/* ---EOF--- */
