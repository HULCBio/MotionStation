/* File MWDSP_CIC_INT_ZER_TPLT.C
 *
 * CIC Interpolation Zero-Latency Filter algorithm template
 *
 * Copyright 1995-2003 The MathWorks, Inc.
 * $Revision: 1.1.6.2 $ $Date: 2003/07/10 19:50:29 $
 */

    int chanCount, frameCount, sampCount;

    /* loop over channels */
    for (chanCount = 0; chanCount < nChans; chanCount++) {
        /* loop over number of full frames */
        for (frameCount = 0; frameCount < nFrames; frameCount++) {
            /* -------------------------------- */
            /* AT START OF NEXT FULL FRAME HERE */
            /* -------------------------------- */

            /* Re-start arrays at beginning for this channel */
            const int32_T *stgInpWLsTmp = stgInpWLs;
            int32_T       *statesTmp    = states + statesPerChanSize * chanCount;
            int            stageCount;

            int32_T accCombs = *inp;
            inp             += ioStride;

            /* ------------------------------------------- */
            /* Compute comb states/outputs for this frame. */
            /* This code runs at slow sample rate, fs/R.   */
            /* ------------------------------------------- */
            for (stageCount = 0; stageCount < N; stageCount++)
            {
                int32_T stageStateDelayedByM;

                /* Get value of state delayed by M in the circular buffer */
                MWDSP_CICCIRCBUFF_READ_VAL((MWDSP_CIC_CircBuff *)statesTmp, &stageStateDelayedByM);

                /* Update circ buff by writing new comb state value
                 * Thise replaces previous oldest (delayed by M) value
                 * and updates indices internal to the circ buff handler.
                 */
                MWDSP_CICCIRCBUFF_WRITE_VAL((MWDSP_CIC_CircBuff *)statesTmp, &accCombs);

                /* Subtract present (delayed-by-M) state */
                accCombs -= stageStateDelayedByM;

                /* Perform sign extension for < 32-bit emulation code) */
                {
                    const int sumWordLength = *stgInpWLsTmp++;
                    MWDSP_SignExtendInt32(&accCombs, sumWordLength);
                }

                /* Increment states pointer for the NEXT stage */
                statesTmp += NUM_INT32_PER_CICCIRCBUFF;
            }

            /* ------------------------------------------------ */
            /* Compute integrator states/outputs for this frame */
            /* (this loop runs at the fast sample rate, fs)     */
            /* ------------------------------------------------ */
            
            for (sampCount = 0; sampCount < R; sampCount++) {
                int32_T accIntegrators;

                /* Upsample prior to first integrator stage */
                if (sampCount == phase) {
                    accIntegrators = accCombs;
                } else {
                    accIntegrators = 0;
                }

                /* Loop through N integrator stages */
                for (stageCount = 0; stageCount < N; stageCount++)
                {
                    /* Add previous (unit-delayed) state for this stage */
                    accIntegrators += *statesTmp;

                    /* Perform sign extension for < 32-bit emulation code) */
                    {
                        const int sumWordLength = *stgInpWLsTmp++;
                        MWDSP_SignExtendInt32(&accIntegrators, sumWordLength);
                    }

                    /* Update the stage state value */
                    *statesTmp++ = accIntegrators;
                }

                /* Compute interpolated output value for this frame */
                *out = (MWDSP_CIC_OUTTYPE)(accIntegrators >> finalOutShiftVal);
                out += ioStride;

                /* Reset ptrs for next time through integrator stages loop */
                statesTmp    -= N;
                stgInpWLsTmp -= N;

            } /* end inner sample loop (at fast sample rate, fs) */

        } /* end multiple frame loop (at slow sample rate, fs/R) */

    } /* end channel loop */

/* [EOF] */
