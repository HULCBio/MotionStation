/*
 * SDSPSINE DSP Blockset S-Function to generate a frame-based
 *          sine wave using one of the following methods:
 *           - trig evaluations with absolute time
 *           - trig evaluations with "periodically reset" time
 *           - discrete differential (non-trig) evaluation
 *           - discrete table lookup
 *  May 5, 1999
 *  Copyright 1995-2002 The MathWorks, Inc.
 *  $Revision: 1.29 $  $Date: 2002/04/14 20:42:43 $
 */
#define S_FUNCTION_NAME sdspsine
#define S_FUNCTION_LEVEL 2

#include "dsp_sim.h"

enum {NUM_INPORTS=0};
enum {OUTPORT=0, NUM_OUTPORTS};

/*
 * Various dworks are needed depending on the mode
 */
enum {LAST_IDX, DD_DWORKS};                             /* For discrete differential mode */
enum {COUNT_IDX, DT_DWORKS};                            /* For discrete trigonometric mode */
enum {TABLE_IDX, TABLE_VALUES, TABLE_SPP, DL_DWORKS};   /* For discrete table-lookup mode */
enum {CT_DWORKS};                                       /* Continuous trig-fcn mode */

enum {CONTINUOUS_MODE=1, DISCRETE_MODE};
enum {TRIGFCN_METHOD=1, TABLE_LOOKUP_METHOD, DIFFERENTIAL_METHOD};
enum {REAL_OUTPUT=1, COMPLEX_OUTPUT};  /* sin, cos + jsin */
enum {RESET_WHEN_REENABLED=1};
enum {AMP_ARGC=0, FREQ_ARGC, PHASE_ARGC, MODE_ARGC, OUTPUT_TYPE_ARGC,
      METHOD_ARGC, SAMP_TIME_ARGC, FRAME_ARGC, REENABLE_ARGC, NUM_ARGS};

#define AMP_ARG(S)        (ssGetSFcnParam(S,AMP_ARGC))
#define FREQ_ARG(S)       (ssGetSFcnParam(S,FREQ_ARGC))
#define PHASE_ARG(S)      (ssGetSFcnParam(S,PHASE_ARGC))
#define MODE_ARG(S)       (ssGetSFcnParam(S,MODE_ARGC))         /* continuous vs. discrete */
#define METHOD_ARG(S)     (ssGetSFcnParam(S,METHOD_ARGC))

#define OUTPUT_TYPE_ARG(S) (ssGetSFcnParam(S,OUTPUT_TYPE_ARGC)) /* Real or Complex (Sin or Cos + j*sin) */
#define SAMP_TIME_ARG(S)   (ssGetSFcnParam(S,SAMP_TIME_ARGC))
#define FRAME_ARG(S)       (ssGetSFcnParam(S,FRAME_ARGC))
#define REENABLE_ARG(S)    (ssGetSFcnParam(S,REENABLE_ARGC))

#define IS_DISCRETE       (mxGetPr(MODE_ARG(S))[0] == DISCRETE_MODE)
#define IS_COMPLEX        (mxGetPr(OUTPUT_TYPE_ARG(S))[0] == COMPLEX_OUTPUT)
#define IS_TRIGFCN        (IS_DISCRETE && (mxGetPr(METHOD_ARG(S))[0] == TRIGFCN_METHOD))
#define IS_TABLE_LOOKUP   (IS_DISCRETE && (mxGetPr(METHOD_ARG(S))[0] == TABLE_LOOKUP_METHOD))
#define IS_DIFFERENTIAL   (IS_DISCRETE && (mxGetPr(METHOD_ARG(S))[0] == DIFFERENTIAL_METHOD))
#define RESET_ON_REENABLE (mxGetPr(REENABLE_ARG(S))[0] == RESET_WHEN_REENABLED)

typedef struct {
    real_T  Pi2;

    /* For discrete trig */
    boolean_T isPeriodic;

    /* For discrete differential: */
    creal_T *h;
    creal_T *phi;

} SFcnCache;


static uint16_T calculateTableSize(SimStruct *S)
{
        real_T      *freq      = mxGetPr(FREQ_ARG(S));
        const int_T  freqEle   = mxGetNumberOfElements(FREQ_ARG(S));
        const int_T  freqInc   = (freqEle > 1) ? 1 : 0;
        const int_T  phaseEle  = mxGetNumberOfElements(PHASE_ARG(S));
        int_T        numCombos = MAX(phaseEle, freqEle); /* # combinations of frequency and phase */
        const real_T Ts        = ssGetSampleTime(S,0) / mxGetPr(FRAME_ARG(S))[0];
        uint16_T     tableSize = 0;
        int_T        i;

        /* Determine total table size */
        for (i=0; i<numCombos; i++) {
            /* Samples/period = 1/(Ts * freq) */
            tableSize += (uint16_T)floor(1.0 / (Ts * (*freq)) + 0.5);
            freq      += freqInc;
        }

        return(tableSize);
} /* calculateTableSize */


/*
 * Function: is_periodic_sampled_sine
 */
static boolean_T is_periodic_sampled_sine(SimStruct *S)
{
    /* To be periodic, there must be an integer number of 
     * samples per period, and that number must be 2 or greater. 
     */
    const real_T  maxEntriesPerChan = ldexp(1.0, 16) - 1.0;

    real_T  Ts      = mxGetPr(SAMP_TIME_ARG(S))[0];
    int_T   freqEle = mxGetNumberOfElements(FREQ_ARG(S));
    real_T *freq    = mxGetPr(FREQ_ARG(S));
    int_T   i;

    /*
     * Check that total table length is addressable
     *   with a 16 bit integer offset:
     */
    real_T tableSize  = 0;

    for (i=0; i<freqEle; i++) {
        /*
         * Determine samples per period (SpP)
         *   = (samples/sec) * (sec/period)
         *   = Fs * Tp = (1/Ts) * (1/freq[i]) = 1/(Ts * freq)
         *
         * Check that SpP is an integer
         */
        real_T    SpP        = 1.0 / (Ts * freq[i]);
        real_T    iSpP       = floor(SpP+0.5);
        boolean_T isMultiple = fabs(SpP - iSpP) < (2*iSpP*mxGetEps());

        tableSize += iSpP;  /* Running sum of total table size */

        if (IS_TABLE_LOOKUP) {
            /* Generate error message if appropriate */
            if (!isMultiple) {
                ssSetErrorStatus(S, "When using discrete table-lookup, the period of each "
                     "sinusoid must be an integer multiple of the block "
                     "sample time (Ts), i.e., all frequencies must be "
                     "1/(k*Ts), where k is an integer > 1.");
            }
            if (tableSize > maxEntriesPerChan) {
                ssSetErrorStatus(S, "The specified parameters require too many samples per period; "
                             "(max entries=x, required entries=y);"
                             "increase the block sample time or sinusoid frequency.");
            }
            if (iSpP < 2) {
                ssSetErrorStatus(S, "There must be at least 2 samples per sinusoid for proper "
                             "discrete-time operation; decrease the block sample "
                             "time or sinusoid frequency.");
            }
            if (ssGetErrorStatus(S) != NULL ) {
                return(false);  /* Not periodic */
            }
        } else {
            /* Discrete trig mode: */
#if 0
            if (!isMultiple) {
                return(false);
            }
#else
            /* Disallow periodic trig mode until tunability problem is resolved. */
            return(false);
#endif
        }
    }
    return(true);
} /* is_periodic_sampled_sine */



#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S) 
{
    if (OK_TO_CHECK_VAR(S, AMP_ARG(S))) {
        if (!IS_VECTOR_DOUBLE(AMP_ARG(S))) {
            THROW_ERROR(S, "Amplitude must be a real vector.");
        }
    }

    if (OK_TO_CHECK_VAR(S, FREQ_ARG(S))) {
        if (!IS_VECTOR_DOUBLE(FREQ_ARG(S))) {
            THROW_ERROR(S, "Frequency must be a real vector.");
        }

        /* Check that all frequencies are > 0: */
        {
            real_T *freq    = mxGetPr(FREQ_ARG(S));
            int_T   freqEle = mxGetNumberOfElements(FREQ_ARG(S));
            int_T   i;
            for (i=0; i<freqEle; i++) {
                if (freq[i] <= 0.0) {
                    THROW_ERROR(S, "Frequencies must be > 0.");
                }
            }
        }
    }

    if (OK_TO_CHECK_VAR(S, PHASE_ARG(S))) {
        if (!IS_VECTOR_DOUBLE(PHASE_ARG(S))) {
            THROW_ERROR(S, "Phase must be a real vector.");
        }
    }

    /* We've checked that the amplitude, frequency
     *   and phase parameters are scalars or vectors
     *
     * Now check that the vector lengths are all commensurate:
     */
    {
        const int_T ampEle   = mxGetNumberOfElements(AMP_ARG(S));
        const int_T freqEle  = mxGetNumberOfElements(FREQ_ARG(S));
        const int_T phaseEle = mxGetNumberOfElements(PHASE_ARG(S));

        if (OK_TO_CHECK_VAR(S, AMP_ARG(S))   &&
            OK_TO_CHECK_VAR(S, FREQ_ARG(S))  &&
            OK_TO_CHECK_VAR(S, PHASE_ARG(S)) &&
            (   ((ampEle != 1) && ( (freqEle  != 1) && (ampEle != freqEle)  ||
                                   (phaseEle != 1) && (ampEle != phaseEle)  ))
               ||
               (ampEle == 1) && (freqEle != 1) && (phaseEle != 1) && (freqEle != phaseEle)
            )) {
            THROW_ERROR(S, "Amplitude, frequency and phase vectors must be the same length.");
        }
    }

    if (!IS_FLINT_IN_RANGE(MODE_ARG(S), 1, 2)) {
        THROW_ERROR(S, "Mode must be continuous (1) or discrete (2).");
    }

    if (!IS_FLINT_IN_RANGE(OUTPUT_TYPE_ARG(S), 1, 2)) {
        THROW_ERROR(S, "Mode must be Real (1) or Complex (2).");
    }

    if (!IS_FLINT_IN_RANGE(METHOD_ARG(S), 1, 3)) {
        THROW_ERROR(S, "Method must be trig-fcn (1), table lookup (2) or differential (3).");
    }

    if (!IS_FLINT_IN_RANGE(REENABLE_ARG(S), 1, 2)) {
        THROW_ERROR(S, "Re-enable method must be reset (1) or current (2).");
    }

    if (IS_DISCRETE) {
        /* Sample time: */
        if (!IS_SCALAR(SAMP_TIME_ARG(S)) || mxIsComplex(SAMP_TIME_ARG(S)) ||
            (mxGetPr(SAMP_TIME_ARG(S)) [0] <= 0.0)) {
            THROW_ERROR(S, "The sample time must be a positive scalar > 0.");
        }
    }

    /* Samples per Frame
     *
     * NOTE: output port width relies on this parameter in discrete mode, so
     *       verify even at apply  time that the param is valid (non-empty)
     *       [only in discrete mode!]
     */ 
    if (IS_DISCRETE && !IS_FLINT_GE(FRAME_ARG(S),1) ) {
        THROW_ERROR(S, "Samples per frame must be an integer value > 0.");
    }

    /*
     * If block is set to discrete table-lookup mode, then
     * we need to verify that all specified frequencies are
     * multiples of the block sample time.
     *
     * This is because "table lookup" implies a fixed table of sinusoid values,
     * one entry per possible output value.  A frequency which is not a multiple
     * of Ts would "wander" in phase on each successive period, requiring more
     * than Tp/Ts number of entries in the table (where Ts=sample time, and
     * Tp=period corresponding to sinusoid frequency).
     */
     (void)is_periodic_sampled_sine(S);
}
#endif


static void mdlInitializeSizes(SimStruct *S)
{
   ssSetNumSFcnParams(S, NUM_ARGS);

#if defined(MATLAB_MEX_FILE)
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) return;
    mdlCheckParameters(S);
    if (ssGetErrorStatus(S) != NULL) return;
#endif

    ssSetSFcnParamNotTunable(S, MODE_ARGC);
    ssSetSFcnParamNotTunable(S, OUTPUT_TYPE_ARGC);
    ssSetSFcnParamNotTunable(S, METHOD_ARGC);
    ssSetSFcnParamNotTunable(S, SAMP_TIME_ARGC);
    ssSetSFcnParamNotTunable(S, FRAME_ARGC);
    ssSetSFcnParamNotTunable(S, REENABLE_ARGC);

    /*
     * In discrete table-lookup mode, the freq & amp arguments cannot be tuned.
     * This is because the prestored table length is directly based on the
     * chosen frequencies and amplitudes (in all but one case). 
     *
     * They are nontunable in the mask but, keep them as tunable to write out 
     * to RTW.
     */
#if 0
     if (IS_TABLE_LOOKUP) {
        ssSetSFcnParamNotTunable(S, AMP_ARGC);
        ssSetSFcnParamNotTunable(S, FREQ_ARGC);
        ssSetSFcnParamNotTunable(S, PHASE_ARGC);
        }
#endif
    /* If we are using Discrete Differential and are in Simulink External mode
     * then frequency and phase are not tunable.  We compute 'h' and 'phi' 
     * based on these parameters and there is not an easy way to dynamically 
     * update 'h' and 'phi' with external mode because they are not 
     * S-function parameters.
     */
    if ( IS_DIFFERENTIAL &&
            ( (ssGetSimMode(S) == SS_SIMMODE_EXTERNAL) ||
              (ssGetSimMode(S) == SS_SIMMODE_RTWGEN) )
       ) {
        ssSetSFcnParamNotTunable(S, FREQ_ARGC);
        ssSetSFcnParamNotTunable(S, PHASE_ARGC);
    }

    /* Inputs: */
    if (!ssSetNumInputPorts(S, NUM_INPORTS)) return;

    /* Outputs: */
    if (!ssSetNumOutputPorts(S,NUM_OUTPORTS)) return;

    {
	/* Continuous mode does not support frame-based operation: 
         *
         * NOTE: FRAME_ARG *must* be valid (non-empty) since the output port width
         *       relies on this parameter.
         */
        const int_T mode     = (int_T)(mxGetPr(MODE_ARG(S))[0]);
        const int_T nSamps   = (mode == CONTINUOUS_MODE) ? 1 : (int_T)mxGetPr(FRAME_ARG(S))[0];
        const int_T ampEle   = mxGetNumberOfElements(AMP_ARG(S));
        const int_T freqEle  = mxGetNumberOfElements(FREQ_ARG(S));
        const int_T phaseEle = mxGetNumberOfElements(PHASE_ARG(S));
        int_T       nChans;

        if      (ampEle   > 1) nChans = ampEle;
        else if (freqEle  > 1) nChans = freqEle;
        else if (phaseEle > 1) nChans = phaseEle;
        else                   nChans = 1;

        ssSetOutputPortWidth(        S, OUTPORT, nChans*nSamps);
        ssSetOutputPortComplexSignal(S, OUTPORT, IS_COMPLEX ? COMPLEX_YES : COMPLEX_NO);
        ssSetOutputPortReusable(     S, OUTPORT, 1);
    }

    if (!ssSetNumDWork(S, DYNAMICALLY_SIZED)) return;

    ssSetNumSampleTimes(S, 1);
    ssSetOptions(       S, SS_OPTION_EXCEPTION_FREE_CODE | 
                        SS_OPTION_USE_TLC_WITH_ACCELERATOR);
}


static void mdlInitializeSampleTimes(SimStruct *S)
{
    const real_T Ts     = mxGetPr(SAMP_TIME_ARG(S))[0];
    const real_T nSamps = mxGetPr(FRAME_ARG(S))[0];

    ssSetSampleTime(S, 0, IS_DISCRETE ? Ts*nSamps : 0.0);
    ssSetOffsetTime(S, 0, IS_DISCRETE ? 0.0 : FIXED_IN_MINOR_STEP_OFFSET);
    ssSetOffsetTime(S, 0, 0.0);
}


#define MDL_PROCESS_PARAMETERS
static void mdlProcessParameters(SimStruct *S)
{
    if (IS_DIFFERENTIAL) {
        SFcnCache *cache = (SFcnCache *)ssGetUserData(S);
        
        const int_T  width    = ssGetOutputPortWidth(S,OUTPORT);
        const int_T  nSamps   = (int_T)mxGetPr(FRAME_ARG(S))[0];
        const real_T deltaT   = ssGetSampleTime(S,0) / nSamps * cache->Pi2;
        const int_T  nChans   = width/nSamps;
        creal_T     *h        = cache->h;
        creal_T     *phi      = cache->phi;

        real_T      *freq     = mxGetPr(FREQ_ARG(S));
        const int_T  freqInc  = (mxGetNumberOfElements(FREQ_ARG(S)) > 1);
        real_T      *phase    = mxGetPr(PHASE_ARG(S));
        const int_T  phaseInc = (mxGetNumberOfElements(PHASE_ARG(S)) > 1);

        int_T        i;

        for (i = 0; i++ < nChans; ) {
            h->re       = cos( deltaT * (*freq));
            (h++)->im   = sin( deltaT * (*freq));
            phi->re     = cos(-deltaT * (*freq) + (*phase));
            (phi++)->im = sin(-deltaT * (*freq) + (*phase));

            freq  += freqInc;
            phase += phaseInc;
        }
    }
}


#define MDL_START
static void mdlStart(SimStruct *S)
{
#ifdef MATLAB_MEX_FILE
    static char errmsg[] = "Memory allocation failure.";

    SFcnCache *cache;
    CallocSFcnCache(S, SFcnCache);
    cache = ssGetUserData(S);

    /* Cache value of 2*PI */
    cache->Pi2 = 8.0 * atan(1.0);

    if (IS_DIFFERENTIAL) {

        const int_T width = ssGetOutputPortWidth(S,OUTPORT);

        /* Allocate "width" number of entries for h and for phi.
         * We perform one malloc for a double-width allocation,
         * and point h and phi into that allocation.
         */
        cache->h   = (creal_T *)mxMalloc(width * 2 * sizeof(creal_T));
        cache->phi = (cache->h == NULL) ? NULL : cache->h + width;

        if (cache->h == NULL) {
            THROW_ERROR(S, errmsg);
        }

    } else if (IS_TRIGFCN) {
      /* Discrete trig mode */
        cache->isPeriodic = is_periodic_sampled_sine(S); 

    } else if (IS_TABLE_LOOKUP) {
       
        /* Determine # table entries for each freq
         * We currently need a separate table for each unique pair of freq/phase combinations.
         * In the future, if we determine that a given phase falls exactly on a table element,
         * then we can potentially save memory by indexing into another table.
         */
        const int_T  freqEle   = mxGetNumberOfElements(FREQ_ARG(S));
        const int_T  phaseEle  = mxGetNumberOfElements(PHASE_ARG(S));
        const int_T  ampEle    = mxGetNumberOfElements(AMP_ARG(S));
        int_T        numCombos = MAX(phaseEle, freqEle);
        int_T        i;

        /*
         * numCombos: # combinations of frequency and phase, as the tables
         *            are constructed based on these 2 parameters, only.
         *
         * NOTE: We should use Simulink's value of Ts, as it may vary
         * from the "Requested" value of Ts by a small but significant amount
         * (on the order of eps).
         */
        const real_T Ts = ssGetSampleTime(S,0) / mxGetPr(FRAME_ARG(S))[0];

        /*
         * Determine total table size
         *
         * Must run through all combinations of frequency and phase
         * since table holds freq/phase data.  Disregard amplitudes.
         *
         * Also, even if there is only 1 frequency, run through
         * this possibly multiple times, one for each phase, so that
         * we get numCombos number of table lengths computed and summed:
         */
        {
            real_T      *freq     = mxGetPr(FREQ_ARG(S));
            const int_T  freqInc  = (freqEle > 1) ? 1 : 0;
            uint16_T     *tableSpP = (uint16_T *)ssGetDWork(S,TABLE_SPP);

            for (i=0; i<numCombos; i++) {
                /*
                 * Determine samples/period
                 *   = samples/sec * sec/period
                 *   = Fs * Tp = (1/Ts) * (1/freq[i])
                 *   = 1/(Ts * freq)
                 */
                *tableSpP++ = (uint16_T)floor(1.0 / (Ts * (*freq)) + 0.5);
                freq       += freqInc;
            }
        }

        /* Fill sample tables: */
        {
            const int_T  width  = ssGetOutputPortWidth(S,OUTPORT);
            const int_T  nSamps = (int_T)mxGetPr(FRAME_ARG(S))[0];
	    const int_T  nChans = width / nSamps;

            real_T *freq     = mxGetPr(FREQ_ARG(S));
            int_T   freqInc  = (mxGetNumberOfElements(FREQ_ARG(S))  > 1);
            real_T *phase    = mxGetPr(PHASE_ARG(S));
            int_T   phaseInc = (mxGetNumberOfElements(PHASE_ARG(S)) > 1);
            real_T *amp      = mxGetPr(AMP_ARG(S));
            int_T   ampInc   = (ampEle > 1);

            /* assert: */
            if ((ampInc == 0) && (nChans != numCombos)) {
                THROW_ERROR(S, "Invalid sine wave arguments.");
            }
            /*
             * We specify the amplitude in the table value calculation UNLESS
             * the number of amplitude elements is greater than the number of freq/phase
             * pairs. This happens only when there are multiple amplitudes and one freq/phase pair.
             */

            if (IS_COMPLEX) {
                creal_T *cmplxtable = (creal_T *)ssGetDWork(S,TABLE_VALUES);
          
                for (i=0; i<numCombos; i++) {
                    const real_T   ampVal   = ((ampEle==1) || (ampEle==numCombos)) ? *amp : 1.0;
                    const real_T   Ts_pi2_f = cache->Pi2 * (*freq) * Ts;
                    const int16_T  iSpP     = ((uint16_T *)ssGetDWork(S, TABLE_SPP))[i]; 
                    uint16_T       j;

                    for (j=0; j < iSpP; j++) {
                        cmplxtable->re = ampVal * cos(j * Ts_pi2_f + (*phase));
                        (cmplxtable++)->im = ampVal * sin(j * Ts_pi2_f + (*phase));
                    } 
                    amp   += ampInc;
                    freq  += freqInc;
                    phase += phaseInc;
               }

            } else {
                real_T *table = (real_T *)ssGetDWork(S,TABLE_VALUES);
                int_T   idx   = 0;

                for (i=0; i<numCombos; i++) {
                    const real_T   ampVal   = ((ampEle==1) || (ampEle==numCombos)) ? *amp : 1.0;
                    const real_T   Ts_pi2_f = cache->Pi2 * (*freq) * Ts;
                    const int16_T  iSpP     = ((uint16_T *)ssGetDWork(S, TABLE_SPP))[i]; 
                    uint16_T       j;

                    for (j=0; j < iSpP; j++) {
                        table[idx++] = ampVal * sin(j * Ts_pi2_f + (*phase));
                    }
                    amp   += ampInc;
                    freq  += freqInc;
                    phase += phaseInc;
                }
            }
        }
    }
    /* Update tunable parameter-dependent data:  */
    mdlProcessParameters(S);
#endif
}


#define MDL_INITIALIZE_CONDITIONS
static void mdlInitializeConditions(SimStruct *S)
{
    /*
     *  NOTES ON BLOCK BEHAVIOR IN AN ENABLED SUBSYSTEM:
     *
     *  This block differs from the built-in Simulink block in how it
     *  behaves when re-enabled.
     *
     *  The block may reset its state to what it was at "time 0", e.g.,
     *  the initial phase values as entered in the block's mask, depending
     *  on the REENABLE_MODE flag.
     *
     *  The Simulink Sine Wave block attempts to set the state to what it
     *  would have been at the "running simulation time" when the system
     *  re-enabled itself.
     */
    SFcnCache   *cache = (SFcnCache *)ssGetUserData(S);
    const int_T  mode  = (int_T)(mxGetPr(MODE_ARG(S))[0]);

    if (mode == DISCRETE_MODE) {
        const int_T method = (int_T)(mxGetPr(METHOD_ARG(S))[0]);
        const int_T nSamps = (int_T)mxGetPr(FRAME_ARG(S))[0];
	const int_T nChans = ssGetOutputPortWidth(S, OUTPORT)/nSamps;

        if (method == DIFFERENTIAL_METHOD) {

            /* Get # frequency/amplitude/phase elements: */
            creal_T *last = (creal_T *)ssGetDWork(S, LAST_IDX);
            int_T    i;

            if (RESET_ON_REENABLE) {
                /* Reset time to zero: */
                for (i = 0; i < nChans; i++) {
                    last->re     = 1.0;
                    (last++)->im = 0.0;
                }

            } else {
                /* Catch up to simulation time: */
                const real_T  Pi2t    = cache->Pi2 * ssGetTaskTime(S,0);
                real_T       *freq    = mxGetPr(FREQ_ARG(S));
                const int_T   freqInc = (mxGetNumberOfElements(FREQ_ARG(S)) > 1) ? 1 : 0;

                for (i = 0; i < nChans; i++) {
                    real_T arg   = *freq * Pi2t;
                    last->re     = cos(arg);
                    (last++)->im = sin(arg);
                    freq += freqInc;
                }
            }

        } else if (method == TRIGFCN_METHOD) {
	    /* Preset sample counter(s) to zero: */

            if (cache->isPeriodic) {
                /*
                 * Trig mode, sample time is multiple of sine period:
                 *
                 * Here we have nChans number of 16-bit counters:
                 */
                uint16_T *count = (uint16_T *)ssGetDWork(S, COUNT_IDX);

                if (RESET_ON_REENABLE) {
                    /* Preset sample counters to zero: */
                    memset(count,0,nChans*sizeof(uint16_T));

                } else {
                    /* Catch up to simulation time: */
                    const real_T  Ts      = ssGetSampleTime(S,0) / nSamps;
                    const real_T  t       = ssGetTaskTime(S,0);
                    real_T       *freq    = mxGetPr(FREQ_ARG(S));
                    const int_T   freqInc = (mxGetNumberOfElements(FREQ_ARG(S)) > 1) ? 1 : 0;
                    int_T         i;

                    /* Round the answer in case Simulink "twiddles" the value
                     * of Ts slightly.  It does this to within a few eps, so that
                     * "slightly different" sample times become identical.
                     */
                    for (i=0; i<nChans; i++) {
                        const uint16_T iSpP = (uint16_T)((1.0 / (Ts * *freq)) + .5);

                        *count++ = (uint16_T)((uint32_T)(t / Ts + 0.5) % iSpP);
                        freq    += freqInc;
                    }
                }

            } else {
                /*
                 * Trig mode, non-periodic:
                 */
                if (RESET_ON_REENABLE) {
                    /* Preset sample counter to zero: */
                    *((uint32_T *)ssGetDWork(S, COUNT_IDX)) = (uint32_T)0;

                } else {
                    /* Catch up to simulation time: */
                    const real_T   Ts = ssGetSampleTime(S,0) / nSamps;
                    const real_T   t  = ssGetTaskTime(S,0);

                    /* Round the answer in case Simulink "twiddles" the value
                     * of Ts slightly.  It does this to within a few eps, so that
                     * "slightly different" sample times become identical.
                     */
                    *((uint32_T *)ssGetDWork(S, COUNT_IDX)) = (uint32_T)(t / Ts + 0.5);
                }
            }

        } else {
            /*
             * Table lookup
             * Initialize table pointers, one per channel(numCombos):
             */
            const int_T freqEle      = mxGetNumberOfElements(FREQ_ARG(S));
            const int_T phaseEle     = mxGetNumberOfElements(PHASE_ARG(S));
            int_T       numCombos    = MAX(phaseEle,freqEle);
            uint16_T   *tableOffsets = (uint16_T *)ssGetDWork(S,TABLE_IDX);

            if (RESET_ON_REENABLE) {
                memset(tableOffsets,0,numCombos*sizeof(uint16_T));
            } else {
                /* Catch up to simulation time: */
                const real_T Ts = ssGetSampleTime(S,0) / nSamps;
                const real_T t  = ssGetTaskTime(S,0);
                int_T        i;

                for (i=0; i<numCombos; i++) {
                    const uint16_T iSpP = ((uint16_T *)ssGetDWork(S, TABLE_SPP))[i];
                    
                    *tableOffsets++ = (uint16_T)((uint32_T)(t / Ts + 0.5) % iSpP);
                }
            }
        }
    }
}


static void mdlOutputs(SimStruct *S, int_T tid)
{
    const int_T  mode   = (int_T)(mxGetPr(MODE_ARG(S))[0]);
    const int_T  width  = ssGetOutputPortWidth(S,OUTPORT);
    const int_T  ampInc = (mxGetNumberOfElements(AMP_ARG(S)) > 1) ? 1 : 0;
    real_T      *amp    = mxGetPr(AMP_ARG(S));
    SFcnCache   *cache  = (SFcnCache *)ssGetUserData(S);

    if (mode == DISCRETE_MODE) {
        const int_T method = (int_T)(mxGetPr(METHOD_ARG(S))[0]);
        const int_T nSamps = (int_T)(mxGetPr(FRAME_ARG(S))[0]);
        const int_T nChans = width/nSamps;
        
        if (method == DIFFERENTIAL_METHOD) {
            creal_T *h    = cache->h;
            creal_T *phi  = cache->phi;
            creal_T *last = (creal_T *)ssGetDWork(S, LAST_IDX);
            int_T    i;
            
            if (IS_COMPLEX) {
                creal_T *y = (creal_T *)ssGetOutputPortSignal(S,OUTPORT);

                for (i = 0; i++ < nChans; ) {
                    const creal_T hval   = *h++;
                    const creal_T phival = *phi++;
                    int_T j;
            
                    for (j=0; j++ < nSamps; ) {
                        /* Output */
                        creal_T lastval = *last;

                        /* cos */
                        y->re     = *amp * (hval.re * CMULT_RE(lastval, phival) -
                                            hval.im * CMULT_IM(lastval, phival) );
                        /* sin */
                        (y++)->im = *amp * (hval.re * CMULT_IM(lastval, phival) +
                                            hval.im * CMULT_RE(lastval, phival) );

                        /* Update */
                        last->re = CMULT_RE(lastval, hval);
                        last->im = CMULT_IM(lastval, hval);
                    }
                    last++;
                    amp += ampInc;
                }
            } else {

                real_T *y = ssGetOutputPortRealSignal(S,OUTPORT);

                for (i = 0; i++ < nChans; ) {
                    const creal_T hval   = *h++;
                    const creal_T phival = *phi++;
                    int_T j;
            
                    for (j=0; j++ < nSamps; ) {
                        /* Output */
                        creal_T lastval = *last;

                        /* sin */
                        *y++ = *amp * (hval.re * CMULT_IM(lastval, phival) +
                                       hval.im * CMULT_RE(lastval, phival) );

                        /* Update */
                        last->re = CMULT_RE(lastval, hval);
                        last->im = CMULT_IM(lastval, hval);
                    }
                    last++;
                    amp += ampInc;
                }
            }
        } else if (method == TRIGFCN_METHOD) {
            /*
             * Discrete trigonometric modes:
             */
            const real_T Ts       = ssGetSampleTime(S,0) / nSamps;
            real_T      *freq     = mxGetPr(FREQ_ARG(S));
            const int_T  freqInc  = (mxGetNumberOfElements(FREQ_ARG(S)) > 1) ? 1 : 0;
            real_T      *phase    = mxGetPr(PHASE_ARG(S));
            const int_T  phaseInc = (mxGetNumberOfElements(PHASE_ARG(S)) > 1) ? 1 : 0;
            int_T        i;

            if (!cache->isPeriodic) {
                /* Discrete trigonometric, no periodic reset: */
	        uint32_T  *count = (uint32_T *)ssGetDWork(S, COUNT_IDX);
	        uint32_T   cnt= 0;

                if (IS_COMPLEX) {
                    creal_T *y = (creal_T *)ssGetOutputPortSignal(S,OUTPORT);
                
	            /* Loop over each channel: */
                    for (i = 0; i< nChans; i++) {
                        const real_T Ts_pi2_f = Ts * cache->Pi2 * (*freq);
                        int_T    j;

	                cnt = *count;

	                /* Loop over frame: */
                        for (j=0; j++ < nSamps; ) {
		            y->re     = *amp * cos(  cnt    * Ts_pi2_f + (*phase) );
	                    (y++)->im = *amp * sin( (cnt++) * Ts_pi2_f + (*phase) );
                        }

#ifdef MATLAB_MEX_FILE
	                /* Warn on counter wrap: */
	                if (cnt <= *count) {
		            mexWarnMsgTxt("Sine wave generator overflowed its internal counter "
			                  "while operating in discrete trig-fcn mode.");
	                }
#endif
	                /* Next channel parameters: */
	                amp   += ampInc;
	                freq  += freqInc;
	                phase += phaseInc;
	            }

	            /* Record new count: */
                    *count = cnt;
            
                } else {
                    real_T *y = ssGetOutputPortRealSignal(S,OUTPORT);
                
	            /* Loop over each channel: */
                    for (i = 0; i < nChans; i++) {
                        const real_T Ts_pi2_f = Ts * cache->Pi2 * (*freq);
                        int_T    j;

	                cnt = *count;

	                /* Loop over frame: */
                        for (j=0; j++ < nSamps; ) {
		            *y++ = *amp * sin( (cnt++) * Ts_pi2_f + (*phase) );
	                }

#ifdef MATLAB_MEX_FILE
	                /* Warn on counter wrap: */
	                if (cnt <= *count) {
		            mexWarnMsgTxt("Sine wave generator overflowed its internal counter "
			                  "while operating in discrete trig-fcn mode.");
	                }
#endif
	                /* Next channel parameters: */
	                amp   += ampInc;
	                freq  += freqInc;
	                phase += phaseInc;


	            }

	            /* Record new count: */
                    *count = cnt;
                }
            } else {

                /* Discrete trigonometric, periodic:
                 *
                 * NOTE: For trig periodic mode, we use a separate counter
                 *       for each frequency to be generated, resetting it
                 *       after each period.
                 */
	        uint16_T *count = (uint16_T *)ssGetDWork(S, COUNT_IDX);

                if (IS_COMPLEX) {
                    creal_T *y = (creal_T *)ssGetOutputPortSignal(S,OUTPORT);

	            /* Loop over each channel: */
                    for (i = 0; i++ < nChans; ) {
                        const real_T Ts_pi2_f = cache->Pi2 * (*freq) * Ts;
                        const int16_T  iSpP     = (int16_T)(1.0 / ((*freq) * Ts) + 0.5);
                        int_T        j;

	                /* Loop over frame: */
                        for (j=0; j++ < nSamps; ) {
                            /*
                             *  Ideally, this computation should match identically to the
                             *  values filled in by table lookup.  However, a direct comparison
                             *  reveals approximately 3.5 eps difference due to compiler optimizations.
                             *  Compiling with -g leads to zero difference (table lookup vs. periodic trig).
                             */
		            y->re     = *amp * cos((*count)   * Ts_pi2_f + (*phase));
		            (y++)->im = *amp * sin((*count)++ * Ts_pi2_f + (*phase));

    	                    /* Update new count: */
                            if (*count >= iSpP) *count = 0;
	                }

	                /* Next channel parameters: */
                        count++;
	                amp   += ampInc;
	                freq  += freqInc;
	                phase += phaseInc;
	            }
                } else {
                    /* Loop over each channel: */
                    real_T *y = ssGetOutputPortRealSignal(S,OUTPORT);

                    for (i = 0; i++ < nChans; ) {
                        const real_T Ts_pi2_f = cache->Pi2 * (*freq) * Ts;
                        const int16_T  iSpP     = (int16_T)(1.0 / ((*freq) * Ts) + 0.5);
                        int_T j;

	                /* Loop over frame: */
                        for (j=0; j++ < nSamps; ) {
                            /*
                             *  Ideally, this computation should match identically to the
                             *  values filled in by table lookup.  However, a direct comparison
                             *  reveals approximately 3.5 eps difference due to compiler optimizations.
                             *  Compiling with -g leads to zero difference (table lookup vs. periodic trig).
                             */
		            *y++ = *amp * sin((*count)++ * Ts_pi2_f + (*phase));

    	                    /* Update new count: */
                            if (*count >= iSpP) *count = 0;
	                }

	                /* Next channel parameters: */
                        count++;
	                amp   += ampInc;
	                freq  += freqInc;
	                phase += phaseInc;
	            }
                }
            } 
            /* end of discrete trig modes */
        } else {
            /* Table lookup: */

            const int_T  ampEle    = mxGetNumberOfElements(AMP_ARG(S));
            const int_T  freqEle   = mxGetNumberOfElements(FREQ_ARG(S));
            const int_T  phaseEle  = mxGetNumberOfElements(PHASE_ARG(S));
            const int_T  numCombos = MAX(phaseEle, freqEle);

            uint16_T  *tableSamplesPerPeriod = (uint16_T *)ssGetDWork(S, TABLE_SPP);
            uint16_T  *tableOffsets          = (uint16_T *)ssGetDWork(S, TABLE_IDX);
            int_T      i;
            if ( (ampEle!=1 || ampEle!=numCombos) && numCombos==1) {
                /* Multiple amplitudes, Single freq/phase pair; therefore only one row in table
                 * Amplitude is NOT encoded in the table.
                 */
                const uint16_T  SpP         = *tableSamplesPerPeriod;
                const uint16_T  orig_offset = *tableOffsets;

                if (IS_COMPLEX) {
                    creal_T *cmplxtable = (creal_T *)ssGetDWork(S,TABLE_VALUES);
                    creal_T *y          = (creal_T *)ssGetOutputPortSignal(S,OUTPORT);

                    for (i=0; i++ < nChans;) {
                        /*
                         * Loop over each amplitude
                         *
                         * Determine when to wrap in each channel of table,
                         * and save position in each channel of table
                         */
                        int_T j;
                        for (j=0; j++ < nSamps;) {
                            y->re     = (*amp) * (cmplxtable[(*tableOffsets)]).re;
                            (y++)->im = (*amp) * (cmplxtable[(*tableOffsets)++]).im;
                            if (*tableOffsets >= SpP) *tableOffsets=0;
                        }
                        amp++;

                        /* Need to reset to original position in row for 
                         * all but the last amplitude
                         */
                        if (i<nChans) *tableOffsets=orig_offset;
                    }
                } else {
                    real_T *y     = ssGetOutputPortRealSignal(S,OUTPORT);
                    real_T *table = (real_T *)ssGetDWork(S,TABLE_VALUES);                    
                    
                    for (i=0; i++ < nChans;) {
                    /*
                    * Loop over each amplitude
                    *
                    * Determine when to wrap in each channel of table,
                    * and save position in each channel of table
                        */
                        int_T j;
                        for (j=0; j++ < nSamps;) {
                            *y++ = (*amp) * table[(*tableOffsets)++];
                            if (*tableOffsets >= SpP) *tableOffsets=0;
                        }
                        amp++;
                        
                        /* need to reset to original position in row for all but the last amplitude
                        */
                        if (i<nChans) *tableOffsets=orig_offset;
                    }
                }
            
            } else {
                /*
                 * Multiple freq/phase pairs and Single/Multiple amplitude(s):
                 */
                
                if (IS_COMPLEX) {
                    creal_T *y          = (creal_T *)ssGetOutputPortSignal(S,OUTPORT);
                    creal_T *cmplxtable = (creal_T *)ssGetDWork(S,TABLE_VALUES);                

                    for (i=0; i < nChans; i++) {
                        const uint16_T SpP = ((uint16_T *)ssGetDWork(S, TABLE_SPP))[i];
                        int_T    j;
                        for (j=0; j++ < nSamps;) {
                            y->re     = cmplxtable[(*tableOffsets)].re;
                            (y++)->im = cmplxtable[(*tableOffsets)++].im;
                            if (*tableOffsets >= SpP) *tableOffsets=0;
                        }
                        tableOffsets++;
                        cmplxtable += SpP;
                    }

                } else {
                    real_T *y     = ssGetOutputPortRealSignal(S,OUTPORT);
                    real_T *table = (real_T *)ssGetDWork(S,TABLE_VALUES);
                    
                    for (i=0; i < nChans; i++) {
                        const uint16_T SpP = ((uint16_T *)ssGetDWork(S, TABLE_SPP))[i];
                        int_T    j;

                        for (j=0; j++ < nSamps;) {
                            *y++ = table[(*tableOffsets)++];
                            if (*tableOffsets >= SpP) *tableOffsets=0;
                        }
                        tableOffsets++;
                        table += SpP;
                    }
                }
            }
        }
   
    } else {
	/* Continuous mode: */
        
        const real_T Pi2_t    = ssGetT(S) * cache->Pi2;
        real_T      *freq     = mxGetPr(FREQ_ARG(S));
        const int_T  freqInc  = (mxGetNumberOfElements(FREQ_ARG(S) ) > 1) ? 1 : 0;
        real_T      *phase    = mxGetPr(PHASE_ARG(S));
        const int_T  phaseInc = (mxGetNumberOfElements(PHASE_ARG(S)) > 1) ? 1 : 0;
        int_T        i;

        if (IS_COMPLEX) {
            creal_T *y = (creal_T *)ssGetOutputPortSignal(S,OUTPORT);
    
            for (i = 0; i++ < width;) {
                y->re     = *amp * cos(*freq * Pi2_t + *phase);
                (y++)->im = *amp * sin(*freq * Pi2_t + *phase);
                amp   += ampInc;
                freq  += freqInc;
                phase += phaseInc;
            } 
        } else {

            real_T *y = ssGetOutputPortRealSignal(S,OUTPORT);
    
            for (i = 0; i++ < width;) {
                *y++ = *amp * sin(*freq * Pi2_t + *phase);
                amp   += ampInc;
                freq  += freqInc;
                phase += phaseInc;
            }         
        }
    }
}


static void mdlTerminate(SimStruct *S)
{
#ifdef MATLAB_MEX_FILE
    SFcnCache *cache = (SFcnCache *)ssGetUserData(S);

    if (cache != NULL) {
        if (IS_DIFFERENTIAL) {
            /*  Only one allocation was made for both "h" and "phi"
             *  arrays; "h" points to the start of that allocation. */
            if (cache->h != NULL) mxFree(cache->h);
        }
        mxFree(cache);
    }
#endif
}


#if defined(MATLAB_MEX_FILE)
#define MDL_SET_WORK_WIDTHS
static void mdlSetWorkWidths(SimStruct *S)
{
    const int_T  mode  = (int_T)(mxGetPr(MODE_ARG(S))[0]);

    if (mode == DISCRETE_MODE) {
        const int_T method = (int_T)(mxGetPr(METHOD_ARG(S))[0]);
        const int_T width  = ssGetOutputPortWidth(S,OUTPORT);
        const int_T nSamps = (int_T)mxGetPr(FRAME_ARG(S))[0];
	const int_T nChans = width/nSamps;

        if (method == DIFFERENTIAL_METHOD) {
	    ssSetNumDWork(	    S, DD_DWORKS);
            ssSetDWorkWidth(        S, LAST_IDX, width);
            ssSetDWorkDataType(     S, LAST_IDX, SS_DOUBLE);
            ssSetDWorkComplexSignal(S, LAST_IDX, COMPLEX_YES);
            ssSetDWorkUsedAsDState( S, LAST_IDX, 1);
            ssSetDWorkName(         S, LAST_IDX, "LastIdx");

        } else if (method == TRIGFCN_METHOD) {

            if (is_periodic_sampled_sine(S)) {
                /* Periodic discrete trig mode: */

	        ssSetNumDWork(          S, DT_DWORKS);
	        ssSetDWorkWidth(        S, COUNT_IDX, nChans);
	        ssSetDWorkDataType(     S, COUNT_IDX, SS_UINT16);
                ssSetDWorkUsedAsDState( S, COUNT_IDX, 1);
                ssSetDWorkName(         S, COUNT_IDX, "CountIdx");

            } else {
                /* Aperiodic discrete trig mode: */

	        ssSetNumDWork(          S, DT_DWORKS);
	        ssSetDWorkWidth(        S, COUNT_IDX, 1);
	        ssSetDWorkDataType(     S, COUNT_IDX, SS_UINT32);
                ssSetDWorkUsedAsDState( S, COUNT_IDX, 1);
                ssSetDWorkName(         S, COUNT_IDX, "CountIdx");
            }

        } else if (method == TABLE_LOOKUP_METHOD) {
            /* Table lookup method */

            const int_T freqEle   = mxGetNumberOfElements(FREQ_ARG(S));
            const int_T phaseEle  = mxGetNumberOfElements(PHASE_ARG(S));
            int_T       numCombos = (phaseEle>1) ? phaseEle : freqEle;

	    ssSetNumDWork(          S, DL_DWORKS);
	    ssSetDWorkWidth(        S, TABLE_IDX, numCombos);
	    ssSetDWorkDataType(     S, TABLE_IDX, SS_UINT16);
            ssSetDWorkUsedAsDState( S, TABLE_IDX, 1);
            ssSetDWorkName(         S, TABLE_IDX, "TableIdx");

        /*
         * Allocate one integer to store the # of samples in each table
         * There is one table for each freq/phase combination
         */

       	    ssSetDWorkWidth(        S, TABLE_VALUES, (int_T)calculateTableSize(S));
	    ssSetDWorkDataType(     S, TABLE_VALUES, SS_DOUBLE );
            ssSetDWorkComplexSignal(S, TABLE_VALUES, (IS_COMPLEX) ? COMPLEX_YES : COMPLEX_NO);
            ssSetDWorkUsedAsDState( S, TABLE_VALUES, 1);
            ssSetDWorkName(         S, TABLE_VALUES, "TableValues");

            ssSetDWorkWidth(        S, TABLE_SPP, numCombos);
	    ssSetDWorkDataType(     S, TABLE_SPP, SS_UINT16 );
            ssSetDWorkComplexSignal(S, TABLE_SPP, COMPLEX_NO);
            ssSetDWorkUsedAsDState( S, TABLE_SPP, 1);
            ssSetDWorkName(         S, TABLE_SPP, "TableSpP");
        }

    } else {
        /* CONTINUOUS MODE */
	ssSetNumDWork(S, CT_DWORKS);
    }
}
#endif


#if defined(MATLAB_MEX_FILE) || defined(NRT)
#define MDL_RTW
static void mdlRTW(SimStruct *S)
{
    /*
     * Write cache parameters:
     *   Pi,
     *   h, phi (for discrete differential only)
     *
     * Write non-tunable parameters:
     *   mode, method, sample time, frame, reenable
     */
    SFcnCache   *cache  = (SFcnCache *)ssGetUserData(S);
    const int_T  width  = ssGetOutputPortWidth(S,OUTPORT);
    const int_T  nSamps = (int_T)mxGetPr(FRAME_ARG(S))[0];
    int_T        nChans  = width / nSamps;
    /*
     * The cache holds two vectors, h and phi, which are
     *   used only in discrete differential mode.
     * Do not write out these elements otherwise.
     */
    int_T   cacheVecWidth = IS_DIFFERENTIAL ? nChans: 0;
    int32_T frameLen      = (int32_T)((IS_DISCRETE) ? mxGetPr(FRAME_ARG(S))[0] : 1);

    creal_T     *h         = (creal_T *)cache->h;
    creal_T     *phi       = (creal_T *)cache->phi;

    real_T      *ampData   = mxGetPr(AMP_ARG(S));
    int_T        ampLen    = mxGetNumberOfElements(AMP_ARG(S));
    real_T      *phaseData = mxGetPr(PHASE_ARG(S));
    int_T        phaseLen  = mxGetNumberOfElements(PHASE_ARG(S));
    real_T      *freqData  = mxGetPr(FREQ_ARG(S));
    int_T        freqLen   = mxGetNumberOfElements(FREQ_ARG(S));

    char *modeStr       = IS_DISCRETE       ? "Discrete" : "Continuous";
    char *isPeriodicStr = (IS_TRIGFCN && cache->isPeriodic) ? "Yes" : "No";
    char *reenableStr   = RESET_ON_REENABLE ? "Reset"    : "Catchup";
    char *OutputTypeStr = IS_COMPLEX        ? "Complex"  : "Real";
    char *methodStr;

    if      (IS_DIFFERENTIAL)   methodStr = "Differential";
    else if (IS_TRIGFCN)        methodStr = "TrigFcn";
    else                           methodStr = "TableLookup";

    if (IS_DIFFERENTIAL) {

        /* Non-tunable parameters. */
        if (!ssWriteRTWParamSettings(S, 11,

            SSWRITE_VALUE_DTYPE_VECT, "H", h, cacheVecWidth,
            DTINFO(SS_DOUBLE,COMPLEX_YES),     

            SSWRITE_VALUE_DTYPE_VECT, "Phi", phi, cacheVecWidth,
            DTINFO(SS_DOUBLE,COMPLEX_YES),
            
            SSWRITE_VALUE_DTYPE_NUM, "Pi2", &(cache->Pi2),
            DTINFO(SS_DOUBLE,COMPLEX_NO),
            
            SSWRITE_VALUE_DTYPE_NUM, "FrameLength", &frameLen,
            DTINFO(SS_INT32,COMPLEX_NO),
                        
            SSWRITE_VALUE_QSTR, "SampleMode", modeStr,
            SSWRITE_VALUE_QSTR, "OutputType", OutputTypeStr,
            SSWRITE_VALUE_QSTR, "isPeriodic", isPeriodicStr,
            SSWRITE_VALUE_QSTR, "CompMethod", methodStr,
            SSWRITE_VALUE_QSTR, "ResetState", reenableStr,
            
            SSWRITE_VALUE_DTYPE_VECT, "Phase", phaseData, phaseLen,
            DTINFO(SS_DOUBLE,COMPLEX_NO),     

            SSWRITE_VALUE_DTYPE_VECT, "Frequency", freqData, freqLen,
            DTINFO(SS_INT32,COMPLEX_NO)     
            )) {
            return;
        }
        
        /* Only amplitude is tunable. */
        if (!ssWriteRTWParameters(S,1,
            SSWRITE_VALUE_VECT,"Amplitude","",ampData,ampLen
            )) {
            return; 
        }
    } else if (IS_TRIGFCN || IS_TABLE_LOOKUP) {

        /* Non-tunable paramters. */
        if (!ssWriteRTWParamSettings(S, 9,                

            SSWRITE_VALUE_DTYPE_VECT, "H", h, cacheVecWidth,
            DTINFO(SS_DOUBLE,COMPLEX_YES),    

            SSWRITE_VALUE_DTYPE_VECT, "Phi", phi, cacheVecWidth,
            DTINFO(SS_DOUBLE,COMPLEX_YES),   

            SSWRITE_VALUE_DTYPE_NUM, "Pi2", &(cache->Pi2),
            DTINFO(SS_DOUBLE,COMPLEX_NO),
            
            SSWRITE_VALUE_DTYPE_NUM, "FrameLength", &frameLen,
            DTINFO(SS_INT32,COMPLEX_NO),
                       
            SSWRITE_VALUE_QSTR, "SampleMode", modeStr,
            SSWRITE_VALUE_QSTR, "OutputType", OutputTypeStr,
            SSWRITE_VALUE_QSTR, "isPeriodic", isPeriodicStr,
            SSWRITE_VALUE_QSTR, "CompMethod", methodStr,
            SSWRITE_VALUE_QSTR, "ResetState", reenableStr
            )) {
            return;
        }
        
        /* Tunable parameters. */
        if (!ssWriteRTWParameters(S,3,
            SSWRITE_VALUE_VECT, "Amplitude", "", ampData  , ampLen,
            SSWRITE_VALUE_VECT, "Frequency", "", freqData , freqLen,
            SSWRITE_VALUE_VECT, "Phase"    , "", phaseData, phaseLen
            )) {
            return;
        } 
     } else {
        
        /* CONTINUOUS */
        /* Non-tunable paramters. */
        if (!ssWriteRTWParamSettings(S, 9,                

            SSWRITE_VALUE_DTYPE_VECT, "H", h, cacheVecWidth,
            DTINFO(SS_DOUBLE,COMPLEX_YES),     

            SSWRITE_VALUE_DTYPE_VECT, "Phi", phi, cacheVecWidth,
            DTINFO(SS_DOUBLE,COMPLEX_YES),   

            SSWRITE_VALUE_DTYPE_NUM, "Pi2", &(cache->Pi2),
            DTINFO(SS_DOUBLE,COMPLEX_NO),

            SSWRITE_VALUE_QSTR, "SampleMode", modeStr,
            SSWRITE_VALUE_QSTR, "OutputType", OutputTypeStr,
            SSWRITE_VALUE_QSTR, "CompMethod", methodStr,

            SSWRITE_VALUE_DTYPE_NUM, "FrameLength", &frameLen,
            DTINFO(SS_INT32,COMPLEX_NO),            
            
            SSWRITE_VALUE_QSTR, "ResetState", reenableStr,
            SSWRITE_VALUE_QSTR, "isPeriodic", isPeriodicStr
            )) {
            return;
        }
        
        /* Three tunable parameters. */
        if (!ssWriteRTWParameters(S,3,
            SSWRITE_VALUE_VECT, "Amplitude", "", ampData  , ampLen,
            SSWRITE_VALUE_VECT, "Frequency", "", freqData , freqLen,
            SSWRITE_VALUE_VECT, "Phase"    , "", phaseData, phaseLen
            )) {
            return; /* An error occurred which will be reported by Simulink */
        }  
   }
}
#endif


#ifdef	MATLAB_MEX_FILE
#include "simulink.c"
#else
#include "cg_sfun.h"
#endif

/* [EOF] sdspsine.c */
