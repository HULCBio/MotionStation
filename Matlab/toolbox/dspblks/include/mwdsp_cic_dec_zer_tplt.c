/* File MWDSP_CIC_DEC_ZER_TPLT.C
 *
 * CIC Decimation Zero-Latency Filter algorithm template
 *
 * Copyright 1995-2003 The MathWorks, Inc.
 * $Revision: 1.1.6.2 $ $Date: 2003/07/10 19:50:27 $
 */

    int chanCount, frameCount, sampCount;

    /* loop over channels */
    for (chanCount = 0; chanCount < nChans; chanCount++) {
        /* loop over number of full frames */
        for (frameCount = 0; frameCount < nFrames; frameCount++) {
            const int32_T *stgInpWLsTmp   = stgInpWLs; /* initialize removes strict compiler warning */
            const int32_T *stgShiftsTmp   = stgShifts; /* initialize removes strict compiler warning */
            int32_T       *statesTmp      = states;    /* initialize removes strict compiler warning */
            int32_T        accIntegrators = 0;         /* initialize removes strict compiler warning */
            int            stageCount;

            /* -------------------------------- */
            /* AT START OF NEXT FULL FRAME HERE */
            /* -------------------------------- */

            /* ------------------------------------------------ */
            /* Compute integrator states/outputs for this frame */
            /* (this loop runs at the fast sample rate, fs)     */
            /* ------------------------------------------------ */
            for (sampCount = 0; sampCount < R; sampCount++) {
                /* Initialize first accumulated sum in first stage */
                accIntegrators = *inp; /* Note that input is already assumed
                                        * to be in equivalent sum type format
                                        */
                inp += ioStride;

                /* Re-start arrays at beginning for this channel */
                stgInpWLsTmp = stgInpWLs;
                stgShiftsTmp = stgShifts;
                statesTmp    = states + statesPerChanSize * chanCount;

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

                    /* Update the stage state value for return to caller */
                    *statesTmp++ = accIntegrators;

                    /* Convert this stage sum I/O word length
                     * to next stage sum I/O word length.
                     */
                    accIntegrators >>= (*stgShiftsTmp++);
                }

                if (sampCount == phase) {
                    /* ------------------------------------------- */
                    /* Compute comb states/outputs for this frame. */
                    /* This code runs at slow sample rate, fs/R.   */
                    /* ------------------------------------------- */
                    MWDSP_CIC_CircBuff *combStatesCircBuff = (MWDSP_CIC_CircBuff *)statesTmp;
                    int32_T             accCombs           = accIntegrators;

                    for (stageCount = 0; stageCount < N; stageCount++)
                    {
                        int32_T stageStateDelayedByM;

                        /* Get value of state delayed by M in the circular buffer */
                        MWDSP_CICCIRCBUFF_READ_VAL(combStatesCircBuff, &stageStateDelayedByM);

                        /* Update circ buff by writing new comb state value
                         * Thise replaces previous oldest (delayed by M) value
                         * and updates indices internal to the circ buff handler.
                         */
                        MWDSP_CICCIRCBUFF_WRITE_VAL(combStatesCircBuff, &accCombs);

                        /* Subtract present (delayed-by-M) state */
                        accCombs -= stageStateDelayedByM;

                        /* Perform sign extension for < 32-bit emulation code) */
                        {
                            const int sumWordLength = *stgInpWLsTmp++;
                            MWDSP_SignExtendInt32(&accCombs, sumWordLength);
                        }

                        /* Convert this stage sum I/O word length
                         * to next stage sum I/O word length (or,
                         * for last time, final output word length).
                         */
                        accCombs >>= (*stgShiftsTmp++);

                        /* Increment circular buffer pointer for next stage */
                        combStatesCircBuff++;
                    }

                    /* Compute final output value for this frame */
                    *out = (MWDSP_CIC_OUTTYPE)accCombs;
                    out += ioStride;

                } /* end comb filter stages code (sampCount == phase) */

            } /* end inner sample loop (at fast sample rate, fs) */

        } /* end multiple frame loop (at slow sample rate, fs/R) */

    } /* end channel loop */

/* [EOF] */
