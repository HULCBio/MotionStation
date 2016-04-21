/*
 * SCOMAPSKDEMOD Communications Blockset S-Function for demodulating
 * the input signal to a M-PSK, M-DPSK, M-PAM, OQPSK, Rectangular QAM or
 * Genaral QAM constellation.
 *
 *  Copyright 1996-2003 The MathWorks, Inc.
 *  $Revision: 1.18.4.2 $  $Date: 2004/04/12 23:03:16 $
 */

#define S_FUNCTION_NAME scomapskdemod
#define S_FUNCTION_LEVEL 2

#include "comm_defs.h"


/* List input & output ports*/
enum {INPORT = 0, NUM_INPORTS};
enum {OUTPORT = 0, NUM_OUTPORTS};
 /* Define Work Vectors*/
enum {MOD_DEMAP = 0, SYMBOLOUT, PHDIFF, PREV_SYMBOL,
      OQPSK_I, OQPSK_Q, OQPSK_DELAY,
      U_MEAN, COUNT, SYM_COUNT, INPUTVALID, NUM_DDWORK};

/* List the mask parameters*/
enum {
        M_ARYC = 0,
        OUT_TYPEC,
        MAPPINGC,
        NORMALIZATIONC,
        MIN_DISTANCEC,
        AVERAGE_POWC,
        PEAK_POWC,
        PH_OFFSETC,
        NUM_SAMPC,
        SIGRE_CONSTELLC,
        SIGIM_CONSTELLC,
        MOD_SCHEMEC,
        NUM_ARGS
};
#define M_ARY                   (ssGetSFcnParam(S,M_ARYC))
#define OUT_TYPE                (ssGetSFcnParam(S,OUT_TYPEC))
#define MAPPING                 (ssGetSFcnParam(S,MAPPINGC))
#define NORMALIZATION           (ssGetSFcnParam(S,NORMALIZATIONC))
#define MIN_DISTANCE            (ssGetSFcnParam(S,MIN_DISTANCEC))
#define AVERAGE_POW             (ssGetSFcnParam(S,AVERAGE_POWC))
#define PEAK_POW                (ssGetSFcnParam(S,PEAK_POWC))
#define PH_OFFSET               (ssGetSFcnParam(S,PH_OFFSETC))
#define NUM_SAMP                (ssGetSFcnParam(S,NUM_SAMPC))
#define SIGRE_CONSTELL          (ssGetSFcnParam(S,SIGRE_CONSTELLC))
#define SIGIM_CONSTELL          (ssGetSFcnParam(S,SIGIM_CONSTELLC))
#define MOD_SCHEME              (ssGetSFcnParam(S,MOD_SCHEMEC))

/*Define variables representing parameter values*/
enum {BIT_OUTPUT = 1, INTEGER_OUTPUT};
enum {CONTINUOUS_IN = 1, DISCRETE_IN};
enum {BINARY_DEMAP = 1, GRAY_DEMAP};
enum {MIN_DIST = 1,AVERAGE_POWER,PEAK_POWER};
enum {M_PSK = 1, M_DPSK, M_PAM, M_QAM, M_PAMPSK, OQPSK};

#define IS_INTEGER_OUTPUT       ((int_T)mxGetPr(OUT_TYPE)[0] == INTEGER_OUTPUT)
#define IS_BIT_OUTPUT           ((int_T)mxGetPr(OUT_TYPE)[0] == BIT_OUTPUT)
#define IS_BINARY_DEMAP         ((int_T)mxGetPr(MAPPING)[0] == BINARY_DEMAP)
#define IS_GRAY_DEMAP           ((int_T)mxGetPr(MAPPING)[0] == GRAY_DEMAP)

/* Defines the modulation scheme*/
#define MODULATION              (int_T)mxGetPr(MOD_SCHEME)[0]
#define OPERATION_MODE          (int_T)mxGetPr(FRAMING)[0]
#define OUTPUT_TYPE             (int_T)mxGetPr(OUT_TYPE)[0]
#define NORM_TYPE               (int_T)mxGetPr(NORMALIZATION)[0]

#define BLOCK_BASED_SAMPLE_TIME 1

/* --- Function prototypes --- 
 * Function to compute the symbol demapping table
 * for various modulation schemes
 */
static void setModDemap(SimStruct *S);

/* Function to compute the index for the symbol demapping table */
static void setIndex(SimStruct *S, creal_T *u_mean)
{
    creal_T     *PrevSym     = (creal_T *)ssGetDWork( S, PREV_SYMBOL);
    real_T      *phdiff      = (real_T *)ssGetDWork(S, PHDIFF);
    int32_T     *SymbolOut   = (int32_T *)ssGetDWork(S, SYMBOLOUT);
    int32_T     *minIndxI    = (int32_T *)ssGetDWork(S, OQPSK_I);
    int32_T     *minIndxQ    = (int32_T *)ssGetDWork(S, OQPSK_Q);
    const int_T inFramebased = ssGetInputPortFrameData(S,INPORT);
    const int_T InPortWidth  = ssGetInputPortWidth(S, INPORT);
    const int_T M            = (MODULATION != M_PAMPSK) ? (int_T)mxGetPr(M_ARY)[0] : (int_T)mxGetNumberOfElements(SIGRE_CONSTELL);
    const int_T nSamp        = (inFramebased) ? (int_T)mxGetPr(NUM_SAMP)[0] : 1;
    real_T      Initialphase = fmod(mxGetPr(PH_OFFSET)[0], (real_T)(DSP_TWO_PI));

    creal_T cplx_SymIn, cplx_Diff;
    real_T  minDiff = 0.0, SymIn, SymInI, SymInQ, x = 0.0, y = 0.0;
    int_T  i = 0, j = 0, m = 0, nbits = 0, minIndx = 0;
    int_T  inc = -1, bit_count, y0 = 0, y1 = 0;
    frexp((real_T)M, &nbits);
    nbits = nbits - 1;

    *SymbolOut = (int32_T)0;
    *minIndxI  = (int32_T)0;
    *minIndxQ  = (int32_T)0;

    switch (MODULATION) {
    case M_DPSK:
    {
        /* Present symbol multiplied with it's conjugate results in a
           complex signal whose phase is same as the phase difference
         */
        x = CMULT_YCONJ_RE(*u_mean, *PrevSym);
        y = CMULT_YCONJ_IM(*u_mean, *PrevSym);

        (PrevSym)->re = (u_mean)->re;
        (PrevSym)->im = (u_mean)->im;
        SymIn = atan2(y, x);

        /* Map phase between values of 0 & 2pi */
        if (SymIn < Initialphase) {SymIn = DSP_TWO_PI + SymIn;}
    }
    break;
    case OQPSK:
    {
        /* phase compensation: rotate the input symbol by -Initialphase */
        real_T c = cos(-Initialphase);
        real_T s = sin(-Initialphase);
        SymInI = (u_mean->re) * c - (u_mean->im) * s;
        SymInQ = (u_mean->re) * s + (u_mean->im) * c;
    }
    break;
    case M_PSK:
    {
        SymIn   = atan2((u_mean)->im,(u_mean)->re);
        /* Map phase between values of 0 & 2pi */
        if (SymIn < Initialphase) {SymIn = DSP_TWO_PI + SymIn;}
    }
    break;
    case M_PAM:
    {
        SymIn   = (u_mean)->re;
    }
    break;
    case M_QAM:
    {
        cplx_SymIn.re = (u_mean)->re;
        cplx_SymIn.im = (u_mean)->im;
    }
    break;
    case M_PAMPSK:
    {
        cplx_SymIn.re = (u_mean)->re;
        cplx_SymIn.im = (u_mean)->im;
    }
    break;
    default:
        THROW_ERROR(S,"Invalid demodulation scheme.");
    }

    switch (MODULATION) {
    case OQPSK:
    {
        *minIndxI = 0;
        *minIndxQ = 0;
        if (SymInI < 0) {*minIndxI = 1; }
        if (SymInQ < 0) {*minIndxQ = 1; }
    }
    break;
    case M_PSK:
    case M_DPSK:
    {
        real_T *moddemap = (real_T *)ssGetDWork(S, MOD_DEMAP);
        minDiff = fabs(SymIn - moddemap[0]);
        if (minDiff > DSP_PI) {minDiff = DSP_TWO_PI - minDiff;}

        for (j = 1; j < M; j++)
        {
            phdiff[j] = fabs(SymIn - moddemap[j]);
            if (phdiff[j] > DSP_PI) {phdiff[j] = DSP_TWO_PI - phdiff[j];}
            if (phdiff[j] <  minDiff)
            {
                minDiff = phdiff[j];
                minIndx = j;
            }
        }
    }
    break;
    case M_PAM:
    {
        real_T *moddemap = (real_T *)ssGetDWork(S, MOD_DEMAP);
        minDiff = fabs(SymIn - moddemap[0]);

        for (j = 1; j < M; j++)
        {
            phdiff[j] = fabs(SymIn - moddemap[j]);
            if (phdiff[j] <  minDiff)
            {
                minDiff = phdiff[j];
                minIndx = j;
            }
        }
    }
    break;
    case M_QAM:
    case M_PAMPSK:
    {
        creal_T *moddemap = (creal_T *)ssGetDWork(S, MOD_DEMAP);
        cplx_Diff.re = (cplx_SymIn.re - moddemap[0].re);
        cplx_Diff.im = (cplx_SymIn.im - moddemap[0].im);
        minDiff = CQABS(cplx_Diff);
        for (j = 1; j < M; j++)
        {
            cplx_Diff.re = (cplx_SymIn.re - moddemap[j].re);
            cplx_Diff.im = (cplx_SymIn.im - moddemap[j].im);
            phdiff[j] = CQABS(cplx_Diff);
            if (phdiff[j] <  minDiff)
            {
                minDiff = phdiff[j];
                minIndx = j;
            }
        }
    }
    break;
    default:
        THROW_ERROR(S,"Invalid demodulation scheme.");
    }

    switch (OUTPUT_TYPE) {
    case BIT_OUTPUT: /* Bit input */
    {
        bit_count = nbits - 1;

        if (IS_GRAY_DEMAP)
        {
            if (MODULATION == M_QAM)
            {
                if (nbits%2 == 0)
                {
                    int_T minPhI = minIndx >> (nbits/2);
                    int_T minPhQ = minIndx & ((M - 1) >> (nbits/2));
                    minPhI^= (int_T)floor(minPhI/2);
                    minPhQ^= (int_T)floor(minPhQ/2);
                    minIndx = (minPhI << (nbits/2)) + minPhQ;
                } else /* nbits is odd */
                {
                    int_T nIbits = (nbits+1)/2;
                    int_T nQbits = (nbits-1)/2;
                    int_T minPhI = minIndx >> nQbits;
                    int_T minPhQ = minIndx & ((M - 1) >> nIbits);
                    minPhI^= (int_T)floor(minPhI/2);
                    minPhQ^= (int_T)floor(minPhQ/2);
                    minIndx = (minPhI << nQbits) + minPhQ;
                }
            } else { /* For all other modulation schemes */
                minIndx^= (int_T)floor(minIndx/2);
            }
        }

        for (m = 0; m < nbits; m++)
        {
            SymbolOut[bit_count] = (int32_T)minIndx%2;
            minIndx = minIndx/2;
            bit_count += inc; /* inc = -1*/
        }
    }
    break;
    case INTEGER_OUTPUT: { /* Integer Output */
        if (MODULATION == OQPSK) {
            *SymbolOut++ = ((*minIndxI)<<1) + *minIndxQ;
        } else {
            *SymbolOut = (int32_T)minIndx;
        }
    }
    break;
    default:
        THROW_ERROR(S,"Invalid output type.");
    }
}

/* Function: mdlCheckParameters =============================================*/
#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S)
{
        /*---Check to see if the Output type parameter is either 1 or 2 -----*/
        if (!IS_FLINT_IN_RANGE(OUT_TYPE,1,2))
        {
                THROW_ERROR(S,"Output type parameter is outside of expected range.");
        }

        /*---Check to see if the Symbol to bit demapping parameter is either 1 or 2 ----*/
        if (!IS_FLINT_IN_RANGE(MAPPING,1,2))
        {
                THROW_ERROR(S,"Symbol to bit demapping parameter is outside of expected range.");
        }

        /*---Check to see if the Modulation scheme parameter is in the range of 1 to 6 ----*/
        if (!IS_FLINT_IN_RANGE(MOD_SCHEME,1,6))
        {
                THROW_ERROR(S,"Modulation scheme parameter is outside of expected range.");
        }

        /*---Check to see if the Power type parameter is in the range of 1 to 3 ----*/
        if (!IS_FLINT_IN_RANGE(NORMALIZATION,1,3))
        {
                THROW_ERROR(S,"Power type parameter is outside of expected range.");
        }

        /*---Check the M-ARY number parameter-----------*/
        /*---For bit input check if M is a scalar which is an integer power of 2---*/

        if (OK_TO_CHECK_VAR(S, M_ARY))
        {
                if (!mxIsEmpty(M_ARY))
                {
                        int_T nbits    = 0;
                        const int_T M  = (int_T) mxGetPr(M_ARY)[0];

                        switch (OUTPUT_TYPE)
                        {
                        case BIT_OUTPUT: /*For bit output check if M is a scalar which is an integer power of 2*/
                                {
                                        if ((!IS_FLINT_GE(M_ARY, 2)) || (frexp((real_T)M, &nbits) != 0.5)
                                                || (mxIsEmpty(M_ARY)))
                                        {
                                                THROW_ERROR(S, "In case of Bit type output M-ary number parameter must be a scalar positive real integer value which is a non-zero power of two.");
                                        }
                                }
                                break;
                        case INTEGER_OUTPUT: /*For integer output check if M is a positive scalar integer*/
                                {
                                        if ((!IS_FLINT_GE(M_ARY,2)) || (mxIsEmpty(M_ARY)))
                                        {
                                                THROW_ERROR(S," M-ary number parameter must be a scalar positive integer value.");
                                        }

                                        /* For M-PAM modulation, M must be even */
                                        if ((MODULATION == M_PAM) && (M%2 !=0))
                                        {
                                                THROW_ERROR(S,"M must be an even number.");
                                        }
                                        /* For M-QAM modulation, M must be a power of two */
                                        if ((MODULATION == M_QAM) && (frexp((real_T)M, &nbits) != 0.5))
                                        {
                                                THROW_ERROR(S,"M must be an integer power of two.");
                                        }
                                }
                                break;
                        default:
                                        THROW_ERROR(S,"Invalid output type.");
                        }
                }
                else
                {
                        switch (OUTPUT_TYPE)
                        {
                                case BIT_OUTPUT:
                                        {
                                                THROW_ERROR(S, "In case of Bit type output M-ary number parameter must be a scalar positive real integer value which is a non-zero power of two.");
                                        }
                                        break;
                                case INTEGER_OUTPUT:
                                        {
                                                THROW_ERROR(S," M-ary number parameter must be a scalar positive integer value.");
                                        }
                                        break;
                                default:
                                                THROW_ERROR(S,"Invalid output type.");
                        }
                }
        }

        if ((MODULATION == M_QAM) || (MODULATION == M_PAM))
        {
                switch (NORM_TYPE)
                {
                case MIN_DIST:
                        {
                                /* Check to see if the Minimum distance parameter is a positive real valued scalar */
                                if (OK_TO_CHECK_VAR(S, MIN_DISTANCE))
                                {
                                        if (!mxIsEmpty(MIN_DISTANCE))
                                        {
                                                if ((mxIsComplex(MIN_DISTANCE)) || (!IS_SCALAR(MIN_DISTANCE))
                                                        || (mxIsEmpty(MIN_DISTANCE)) || (mxIsInf(mxGetPr(MIN_DISTANCE)[0]))
                                                        || ((mxGetPr(MIN_DISTANCE)[0]) <= 0.0))
                                                {
                                                        THROW_ERROR(S," Minimum distance parameter must be a positive real valued scalar.");
                                                }
                                        }
                                        else
                                        {
                                                THROW_ERROR(S," Minimum distance parameter must be a positive real valued scalar.");
                                        }
                                }
                        }
                        break;
                case AVERAGE_POWER:
                        {
                                /* Check to see if the Average power parameter is a positive real valued scalar */
                                if (OK_TO_CHECK_VAR(S, AVERAGE_POW))
                                {
                                        if (!mxIsEmpty(AVERAGE_POW))
                                        {
                                                if ((mxIsComplex(AVERAGE_POW)) || (!IS_SCALAR(AVERAGE_POW))
                                                        || (mxIsEmpty(AVERAGE_POW)) || (mxIsInf(mxGetPr(AVERAGE_POW)[0]))
                                                        || ((mxGetPr(AVERAGE_POW)[0]) <= 0.0))
                                                {
                                                        THROW_ERROR(S," Average power parameter must be a positive real valued scalar.");
                                                }
                                        }
                                        else
                                        {
                                                THROW_ERROR(S," Average power parameter must be a positive real valued scalar.");
                                        }
                                }
                        }
                        break;
                case PEAK_POWER:
                        {
                                /* Check to see if the Peak power parameter is a positive real valued scalar */
                                if (OK_TO_CHECK_VAR(S, PEAK_POW))
                                {
                                        if (!mxIsEmpty(PEAK_POW))
                                        {
                                                if ((mxIsComplex(PEAK_POW)) || (!IS_SCALAR(PEAK_POW))
                                                        || (mxIsEmpty(PEAK_POW)) || (mxIsInf(mxGetPr(PEAK_POW)[0]))
                                                        || ((mxGetPr(PEAK_POW)[0]) <= 0.0))
                                                {
                                                        THROW_ERROR(S," Peak power parameter must be a positive real valued scalar.");
                                                }
                                        }
                                        else
                                        {
                                                THROW_ERROR(S," Peak power parameter must be a positive real valued scalar.");
                                        }
                                }
                        }
                        break;
                default:
                        THROW_ERROR(S,"Invalid Power type.");
                }
        }


        /*--- Check to see if the PH_OFFSET parameter has a real value ---*/
        if (OK_TO_CHECK_VAR(S, PH_OFFSET))
        {
                if (!mxIsEmpty(PH_OFFSET))
                {
                        if ((mxIsComplex(PH_OFFSET)) || (!IS_SCALAR(PH_OFFSET))
                                || (mxIsInf(mxGetPr(PH_OFFSET)[0])) || (mxIsEmpty(PH_OFFSET)))
                        {
                                THROW_ERROR(S," Phase offset parameter must be a real valued scalar.");
                        }
                }
                else
                {
                        THROW_ERROR(S," Phase offset parameter must be a real valued scalar.");
                }
        }

        /* Check to see if the Number of samples per symbol parameter is a positive integer value*/
        if (OK_TO_CHECK_VAR(S, NUM_SAMP))
        {
                if (!mxIsEmpty(NUM_SAMP))
                {
                        if ((!IS_FLINT_GE(NUM_SAMP, 1)) || (mxIsEmpty(NUM_SAMP)))
                        {
                                THROW_ERROR(S, "Samples per symbol parameter must be a scalar positive real integer value");
                        }
                }
                else
                {
                        THROW_ERROR(S, "Samples per symbol parameter must be a scalar positive real integer value");
                }
        }


        if ((MODULATION == M_PAMPSK))
        {
                /* Check to see Signal Constellation parameters are not empty */
                if (OK_TO_CHECK_VAR(S, SIGRE_CONSTELL))
                {
                        if (mxIsEmpty(SIGRE_CONSTELL))
                        {
                                THROW_ERROR(S," Signal Constellation parameter needs to be defined.");
                        }
                }

                if (OK_TO_CHECK_VAR(S, SIGIM_CONSTELL))
                {
                        if (mxIsEmpty(SIGIM_CONSTELL))
                        {
                                THROW_ERROR(S," Signal Constellation parameter needs to be defined.");
                        }
                }
        }

/* end mdlCheckParameters */
}
#endif


/* Function: mdlInitializeSizes ===============================================*/
static void mdlInitializeSizes(SimStruct *S)
{
        ssSetNumSFcnParams(S, NUM_ARGS);

#if defined(MATLAB_MEX_FILE)
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) return;
    mdlCheckParameters(S);
    if (ssGetErrorStatus(S) != NULL) return;
#endif

        ssSetNumSampleTimes(S, PORT_BASED_SAMPLE_TIMES);

        /* Input: */
        if (!ssSetNumInputPorts(         S, NUM_INPORTS)) return;
    if (!ssSetInputPortDimensionInfo(S, INPORT, DYNAMIC_DIMENSION)) return;
        ssSetInputPortFrameData(                 S, INPORT, FRAME_INHERITED);
    ssSetInputPortDirectFeedThrough( S, INPORT, 1);
    ssSetInputPortComplexSignal(     S, INPORT, COMPLEX_YES);
        ssSetInputPortReusable(                     S, INPORT, 0);
        ssSetInputPortRequiredContiguous(S, INPORT, 0);
        ssSetInputPortSampleTime(        S, INPORT,  INHERITED_SAMPLE_TIME);

    /* Output: */
        if (!ssSetNumOutputPorts(         S, NUM_OUTPORTS)) return;
        if (!ssSetOutputPortDimensionInfo(S, OUTPORT, DYNAMIC_DIMENSION)) return;
    ssSetOutputPortFrameData(              S, OUTPORT, FRAME_INHERITED);
    ssSetOutputPortComplexSignal(     S, OUTPORT, COMPLEX_NO);
        ssSetOutputPortReusable(              S, OUTPORT, 0);
        ssSetOutputPortSampleTime(        S, OUTPORT, INHERITED_SAMPLE_TIME);

        if (!ssSetNumDWork(S, DYNAMICALLY_SIZED)) return;

        ssSetOptions( S, SS_OPTION_EXCEPTION_FREE_CODE);

        ssSetSFcnParamNotTunable(S, OUT_TYPEC);
        ssSetSFcnParamNotTunable(S, M_ARYC);
        ssSetSFcnParamNotTunable(S, MAPPINGC);
        ssSetSFcnParamNotTunable(S, NORMALIZATIONC);
        ssSetSFcnParamNotTunable(S, MIN_DISTANCEC);
        ssSetSFcnParamNotTunable(S, AVERAGE_POWC);
        ssSetSFcnParamNotTunable(S, PEAK_POWC);
        ssSetSFcnParamNotTunable(S, PH_OFFSETC);
        ssSetSFcnParamNotTunable(S, NUM_SAMPC);
        ssSetSFcnParamNotTunable(S, SIGRE_CONSTELLC);
        ssSetSFcnParamNotTunable(S, SIGIM_CONSTELLC);
        ssSetSFcnParamNotTunable(S, MOD_SCHEMEC);
}
 /* End of mdlInitializeSizes(SimStruct *S) */


/* Function: mdlInitializeSampleTimes =========================================*/
static void mdlInitializeSampleTimes(SimStruct *S)
{
#if defined(MATLAB_MEX_FILE)
        const real_T Tsi = ssGetInputPortSampleTime(S, INPORT);
        const real_T Tso = ssGetOutputPortSampleTime(S, OUTPORT);

        if ((Tsi == INHERITED_SAMPLE_TIME)  ||
                (Tso == INHERITED_SAMPLE_TIME)   )
        {
                THROW_ERROR(S,"Sample time propagation failed.");
        }
        ssSetModelReferenceSampleTimeInheritanceRule(S, USE_DEFAULT_FOR_DISCRETE_INHERITANCE);
#endif
}
/* End of mdlInitializeSampleTimes(SimStruct *S) */


/* Function: mdlInitializeConditions ========================================*/
#define MDL_INITIALIZE_CONDITIONS
static void mdlInitializeConditions(SimStruct *S)
{
        creal_T                *PrevSym                  = (creal_T *)ssGetDWork( S, PREV_SYMBOL);
        (PrevSym)->re = 0.0;
        (PrevSym)->im = 0.0;

        /* --- Evaluate the symbol demapping table --- */
        setModDemap(S);
}


/* Function: mdlProcessParameters ===========================================*/
#define MDL_PROCESS_PARAMETERS
static void mdlProcessParameters(SimStruct *S)
{
        /* Recompute symbol demapping table to account for changes in parameter value*/
        setModDemap(S);
}


/* Function: setModDemap ===========================================*/
static void setModDemap(SimStruct *S)
{
    const int_T  InPortWidth = ssGetInputPortWidth(S, INPORT);
    const int_T  M           = (MODULATION != M_PAMPSK) ? (int_T)mxGetPr(M_ARY)[0] : (int_T)mxGetNumberOfElements(SIGRE_CONSTELL);
    real_T Initialphase      = fmod(mxGetPr(PH_OFFSET)[0], (real_T)(DSP_TWO_PI));
    int_T i = 0, nbits = 0, I_data = 0, Q_data = 0, scale = 0;
    real_T phase = 0.0, Min_Dist = 0.0;

    frexp((real_T)M, &nbits);  /*---Compute log2(M) for bit input---*/
    nbits = nbits - 1;         /* value of number of bits per symbol */

    /* Generate the symbol demapping table for the various modulation schemes.
     * The table stores output values corresponding to inputs varying
     * from 1 to M-1.
     */
    switch (MODULATION) {
    case OQPSK: {
    }
    break;
    case M_PSK:
    case M_DPSK: {
        real_T *moddemap = (real_T *)ssGetDWork(S, MOD_DEMAP);
        for (i = 0; i < M; i++) {
            *moddemap++ = Initialphase + (DSP_TWO_PI * i)/M;
        }
    }
    break;
    case M_PAM: {
        real_T *moddemap = (real_T *)ssGetDWork(S, MOD_DEMAP);

        /* Compute the minimum distance between symbols */
        switch (NORM_TYPE) {
        case MIN_DIST: {
                Min_Dist = mxGetPr(MIN_DISTANCE)[0];
            }
            break;
        case AVERAGE_POWER: {
            Min_Dist = sqrt(2 * (6.0/((real_T)M*(real_T)M - 1.0)) * (mxGetPr(AVERAGE_POW)[0]));
                                        }
        break;
        case PEAK_POWER: {
            Min_Dist = (2.0/((real_T)M - 1.0)) * (sqrt(mxGetPr(PEAK_POW)[0]));
        }
        break;
        default:
            THROW_ERROR(S,"Invalid Power type.");
        }

        for (i = 0; i < M; i++) {
            *moddemap++ = (real_T)(((2 * i + 1 - M) * Min_Dist)/2);
        }
    }
    break;
    case M_QAM: {
        creal_T *moddemap = (creal_T *)ssGetDWork(S, MOD_DEMAP);
        creal_T cplx_phase, cplx_data;
        cplx_phase.re = cos(Initialphase);
        cplx_phase.im = sin(Initialphase);
        scale = (int_T)pow(2,nbits/2);

        /* Compute the minimum distance between symbols */
        switch (NORM_TYPE) {
        case MIN_DIST: {
            Min_Dist = mxGetPr(MIN_DISTANCE)[0];
        }
        break;
        case AVERAGE_POWER:
        {
            real_T scaleFactor;
            real_T rM;
            rM = (real_T) M;

            if (nbits%2 == 0)  /* Square Constellations (M = 4, 16, 64, ...) */
            {
                scaleFactor = (rM - 1.0) / 6.0;
            }
            else
            {       
                if (nbits > 4)   /* Cross Constellations (M = 32, 128, 512, ...) */
                {
                    scaleFactor = (31.0*(rM/32.0) - 1.0) / 6.0;
                }
                else  /* M = 2 and 8 */
                {
                    scaleFactor = (5.0*(rM/4.0) - 1.0) / 6.0;
                }
            }
            Min_Dist = sqrt(mxGetPr(AVERAGE_POW)[0] / scaleFactor);
        }
        break;
        case PEAK_POWER:
        {
            real_T scaleFactor;
            real_T rM;
            rM = (real_T) M;
            if (nbits%2 == 0)  /* Square Constellations (M = 4, 16, 64, ...) */
            {
                scaleFactor = 0.5*rM - sqrt(rM) + 0.5;
            }
            else
            {       
                if (nbits > 4)   /* Cross Constellations (M = 32, 128, 512, ...) */
                {
                    scaleFactor = 13.0*(rM/32.0) - 5.0*sqrt(rM/32.0) + 0.5;
                }
                else  /* M = 2 and 8 */
                {
                    scaleFactor = 20.0*(rM/32.0) - 6.0*sqrt(rM/32.0) + 0.5;
                }
            }
            Min_Dist = sqrt(mxGetPr(PEAK_POW)[0] / scaleFactor);
        }
        break;
        default:
            THROW_ERROR(S,"Invalid Power type.");
        }

        if (nbits%2 == 0) { /* Square Constellation QAM */
            for (i = 0; i < M; i++) {
                I_data = i >> (nbits/2);
                Q_data = i & ((M - 1) >> (nbits/2));
                cplx_data.re = ((2 * I_data + 1 - (M/scale)) * Min_Dist)/2;
                cplx_data.im = (-1) * ((2 * Q_data + 1 - (M/scale)) * Min_Dist)/2;
                (moddemap)->re = CMULT_RE(cplx_data,cplx_phase);
                (moddemap)->im = CMULT_IM(cplx_data,cplx_phase);
                *moddemap++;
            }
        } else { /* Cross Constellation QAM */
            int_T nIbits = (nbits+1)/2;
            int_T nQbits = (nbits-1)/2;
            int_T mI = (int_T)pow(2,nIbits);
            int_T mQ = (int_T)pow(2,nQbits);
            for (i = 0; i < M; i++) {
                I_data = i >> nQbits;
                Q_data = i & ((M - 1) >> nIbits);
                cplx_data.re =      (2 * I_data + 1 - mI);
                cplx_data.im = -1 * (2 * Q_data + 1 - mQ);
                if (M>8) {
                    int_T I_mag = abs((int_T)cplx_data.re);
                    if(I_mag > 3*(mI/4)) {
                        int_T Q_mag = abs((int_T)cplx_data.im);
                        int_T I_sgn = cplx_data.re < 0 ? -1 : 1;
                        int_T Q_sgn = cplx_data.im < 0 ? -1 : 1;
                        if(Q_mag > mQ/2) {
                            cplx_data.re = I_sgn*(I_mag - mI/2);
                            cplx_data.im = Q_sgn*(2*mQ - Q_mag);
                        } else {
                            cplx_data.re = I_sgn*(mI - I_mag);
                            cplx_data.im = Q_sgn*(mQ + Q_mag);
                        }
                    }
                }

                cplx_data.re *= Min_Dist/2;
                cplx_data.im *= Min_Dist/2;

                (moddemap)->re = CMULT_RE(cplx_data,cplx_phase);
                (moddemap)->im = CMULT_IM(cplx_data,cplx_phase);
                *moddemap++;
            }
        }
    }
    break;
    case M_PAMPSK: {
        creal_T  *moddemap  = (creal_T *)ssGetDWork(S, MOD_DEMAP);
        for (i = 0; i < M; i++) {
            (moddemap)->re = mxGetPr(SIGRE_CONSTELL)[i];
            (moddemap)->im = mxGetPr(SIGIM_CONSTELL)[i];
            *moddemap++;
        }
    }
    break;
    default:
        THROW_ERROR(S,"Invalid operation mode.");
    }
}

/* Function: mdlStart =======================================================*/
#define MDL_START
static void mdlStart (SimStruct *S)
{
}
/* End of mdlStart (SimStruct *S) */


/* Function: mdlOutputs =====================================================*/
static void mdlOutputs(SimStruct *S, int_T tid)
{
    int32_T     *SymbolOut      = (int32_T *)ssGetDWork(S, SYMBOLOUT);
    int32_T     *minIndxI       = (int32_T *)ssGetDWork(S, OQPSK_I);
    int32_T     *minIndxQ       = (int32_T *)ssGetDWork(S, OQPSK_Q);
    int32_T     *sym_count      = (int32_T *)ssGetDWork(S, SYM_COUNT);
    const int_T inFramebased    = ssGetInputPortFrameData(S,INPORT);
    const int_T InPortWidth     = ssGetInputPortWidth(S, INPORT);
    const int_T M               = (MODULATION != M_PAMPSK) ? (int_T)mxGetPr(M_ARY)[0] : (int_T)mxGetNumberOfElements(SIGRE_CONSTELL);
    const int_T nSamp           = (inFramebased) ? (int_T)mxGetPr(NUM_SAMP)[0] : 1;
    const int_T SampPerSym      = (int_T)mxGetPr(NUM_SAMP)[0];

    const int_T OutportTid      = ssGetOutputPortSampleTimeIndex(S, OUTPORT);
    const int_T InportTid       = ssGetInputPortSampleTimeIndex(S, INPORT);

    int_T SamplesPerInputFrame  = InPortWidth;
    int_T i = 0, j = 0, nbits = 0, temp = 0, bit_zero = 0;
    int_T delay_count = 0;
    frexp((real_T)M, &nbits);
    nbits -= 1;

    if (!inFramebased) { /*---Sample-based discrete inputs---*/
        /* Generate index to look up the demapping table
         *  This is done by accumulating and then averaging
         *  the samples for every symbol at every input sample
         *  time hit and calling the setIndex function at every
         *  output sample time hit
         */
        if (ssIsSampleHit(S, InportTid, tid)) {
            creal_T       *u_mean = (creal_T *)ssGetDWork(S, U_MEAN);
            InputPtrsType uptr    = ssGetInputPortSignalPtrs(S, INPORT);

            if (MODULATION == OQPSK) {
                const creal_T *u = (creal_T *) (*uptr++);
                real_T  *delay = (real_T *) ssGetDWork(S, OQPSK_DELAY);
                int32_T *count = ssGetDWork(S, COUNT);
                boolean_T* inputValid = ssGetDWork(S, INPUTVALID);
                if ((ssGetSolverMode(S) != SOLVER_MODE_MULTITASKING)
                    && !(*inputValid)) {
                    *inputValid = (boolean_T) true;
                }
                if (*inputValid) {
                    u_mean->re += ((*sym_count == 0) ? 0.0 : delay[*count]);
                    u_mean->im += ((*sym_count == 0) ? 0.0 : u->im);
                    delay[(*count)++] = u->re;
                    if (*count == SampPerSym) {
                        *count = 0;
                        (*sym_count)++;

                        if (*sym_count == 3) {
                            u_mean->re /= (2 * SampPerSym);
                            u_mean->im /= (2 * SampPerSym);
                            setIndex(S, u_mean);
                            u_mean->re = 0.0;
                            u_mean->im = 0.0;
                            *sym_count = 1;
                        }
                    }
                } else {
                    *inputValid = (boolean_T) true;
                }
            } else { /* For all other modulation schemes */
                int32_T              *count = ssGetDWork(S, COUNT);
                const creal_T *u     = (creal_T *) (*uptr++);
                u_mean->re = u_mean->re + u->re;
                u_mean->im = u_mean->im + u->im;
                (*count)++;
                if (*count == SampPerSym) {
                    u_mean->re /= SampPerSym;
                    u_mean->im /= SampPerSym;
                    setIndex(S, u_mean);
                    u_mean->re = 0.0;
                    u_mean->im = 0.0;
                    *count = 0;
                }
            }
        }

        /* Look up the demapping table at output sample-time hit */
        if (ssIsSampleHit(S, OutportTid, tid)) {
            real_T *y = (real_T *)ssGetOutputPortRealSignal(S, OUTPORT);
            if (MODULATION == OQPSK) {
                switch (OUTPUT_TYPE) {
                case BIT_OUTPUT: {
                    *y++   = *minIndxI;
                    *y++   = *minIndxQ;
                }
                break;
                case INTEGER_OUTPUT: {
                    *y++   = 2 * (*minIndxI) + *minIndxQ;
                }
                break;
                default:
                    THROW_ERROR(S,"Invalid output type.");
                }
            } else { /* For all other mod. schemes */
                switch (OUTPUT_TYPE) {
                case BIT_OUTPUT: {
                    for (j = 0; j < nbits; j++) {
                        *y++   = *SymbolOut++;
                    }
                }
                break;
                case INTEGER_OUTPUT: {
                    *y++   = *SymbolOut;
                }
                break;
                default:
                    THROW_ERROR(S,"Invalid output type.");
                }
            }
        }
    } else { /*---Frame-based inputs---*/
        /* Generate index to look up the demapping table
         * This is done by accumulating and then averaging
         * the samples for every symbol and then calling the
         * setIndex function
         */
        real_T        *y        = (real_T *)ssGetOutputPortRealSignal(S, OUTPORT);
        creal_T        *u_mean        = (creal_T *)ssGetDWork(S, U_MEAN);
        InputPtrsType uptr = ssGetInputPortSignalPtrs(S,INPORT);
        for (i = 0; i < SamplesPerInputFrame; i++) {
            if (MODULATION == OQPSK) {
                const creal_T *u     = (creal_T *)(*uptr++);
                real_T        *delay = (real_T *)ssGetDWork( S, OQPSK_DELAY);
                u_mean->re += (((i < SampPerSym) && (*sym_count == 0)) ? 0.0 : delay[delay_count]);
                u_mean->im += (((i < SampPerSym) && (*sym_count == 0)) ? 0.0 : u->im);
                delay[delay_count++] = u->re;
                if (delay_count == SampPerSym) {
                    delay_count = 0;
                    (*sym_count)++;

                    if (*sym_count == 3) {
                        u_mean->re /= (2 * SampPerSym);
                        u_mean->im /= (2 * SampPerSym);
                        setIndex(S, u_mean);
                        u_mean->re = 0.0;
                        u_mean->im = 0.0;
                        *sym_count = 1;

                        switch (OUTPUT_TYPE) {
                        case BIT_OUTPUT: { /* Bit input */
                            *y++ = *minIndxI;
                            *y++ = *minIndxQ;
                        }
                        break;
                        case INTEGER_OUTPUT: {
                            *y++ = 2 * (*minIndxI) + *minIndxQ;
                        }
                        break;
                        default:
                            THROW_ERROR(S,"Invalid output type.");
                        }
                    }
                }
            } else { /* For all other modulation schemes */
                const creal_T *u = (creal_T *)(*uptr++);
                u_mean->re = u_mean->re + u->re;
                u_mean->im = u_mean->im + u->im;

                if ((i + 1) % (nSamp) == 0) {
                    u_mean->re /= SampPerSym;
                    u_mean->im /= SampPerSym;
                    setIndex(S, u_mean);
                    u_mean->re = 0.0;
                    u_mean->im = 0.0;
                    switch (OUTPUT_TYPE) {
                    case BIT_OUTPUT: { /* Bit input */
                        for (j = 0; j < nbits; j++) {
                            *y++ = SymbolOut[j];
                        }
                    }
                    break;
                    case INTEGER_OUTPUT: {
                        *y++ = *SymbolOut;
                    }
                    break;
                    default:
                        THROW_ERROR(S,"Invalid output type.");
                    }
                }
            }
        }
    }
}
/* End of mdlOutputs (SimStruct *S, int_T tid) */


/* Function: mdlSetWorkWidths ===============================================*/
#ifdef MATLAB_MEX_FILE
#define MDL_SET_WORK_WIDTHS
static void mdlSetWorkWidths(SimStruct *S)
{
        const int_T     inFramebased    = ssGetInputPortFrameData(S,INPORT);
        const int_T                nSamp           = (inFramebased) ? (int_T)mxGetPr(NUM_SAMP)[0] : 1;
        const int_T                SampPerSym      = (int_T)mxGetPr(NUM_SAMP)[0];
        const int_T     M               = (MODULATION != M_PAMPSK) ? (int_T) mxGetPr(M_ARY)[0] : (int_T)mxGetNumberOfElements(SIGRE_CONSTELL);
        const int_T                InPortWidth     = ssGetInputPortWidth(S, INPORT);
        int_T  nbits = 0, LEN = 0, COMPLEXITY;
        frexp((real_T)M, &nbits);  /*---Compute log2(M) for bit input---*/
        nbits = nbits - 1;
        LEN = (IS_INTEGER_OUTPUT) ? InPortWidth/nSamp : (InPortWidth*nbits)/nSamp;

        switch (MODULATION)
        {
                case M_PSK:
                case M_PAM:
                case M_DPSK:
                case OQPSK:
                        COMPLEXITY = COMPLEX_NO;
                        break;
                case M_QAM:
                case M_PAMPSK:
                        COMPLEXITY = COMPLEX_YES;
                        break;
                default:
                        THROW_ERROR(S,"Invalid modulation scheme.");
        }

        ssSetNumDWork(          S, NUM_DDWORK);

        ssSetDWorkWidth(        S, MOD_DEMAP, M);
        ssSetDWorkDataType(     S, MOD_DEMAP, SS_DOUBLE);
        ssSetDWorkComplexSignal(S, MOD_DEMAP, COMPLEXITY);

        ssSetDWorkWidth(        S, SYMBOLOUT, LEN);
        ssSetDWorkDataType(     S, SYMBOLOUT, SS_INT32);
        ssSetDWorkComplexSignal(S, SYMBOLOUT, COMPLEX_NO);

        ssSetDWorkWidth(        S, PHDIFF, (M+1));
        ssSetDWorkDataType(     S, PHDIFF, SS_DOUBLE);
        ssSetDWorkComplexSignal(S, PHDIFF, COMPLEX_NO);

        ssSetDWorkWidth(        S, PREV_SYMBOL, 1);
        ssSetDWorkDataType(     S, PREV_SYMBOL, SS_DOUBLE);
        ssSetDWorkComplexSignal(S, PREV_SYMBOL, COMPLEX_YES);

        ssSetDWorkWidth(        S, U_MEAN, 1);
        ssSetDWorkDataType(     S, U_MEAN, SS_DOUBLE);
        ssSetDWorkComplexSignal(S, U_MEAN, COMPLEX_YES);

        ssSetDWorkWidth(        S, COUNT, 1);
        ssSetDWorkDataType(     S, COUNT, SS_INT32);
        ssSetDWorkComplexSignal(S, COUNT, COMPLEX_NO);

        ssSetDWorkWidth(        S, SYM_COUNT, 1);
        ssSetDWorkDataType(     S, SYM_COUNT, SS_INT32);
        ssSetDWorkComplexSignal(S, SYM_COUNT, COMPLEX_NO);

        ssSetDWorkWidth(        S, INPUTVALID, 1);
        ssSetDWorkDataType(     S, INPUTVALID, SS_BOOLEAN);
        ssSetDWorkComplexSignal(S, INPUTVALID, COMPLEX_NO);

        ssSetDWorkWidth(        S, OQPSK_I, 1);
        ssSetDWorkDataType(     S, OQPSK_I, SS_INT32);
        ssSetDWorkComplexSignal(S, OQPSK_I, COMPLEX_NO);

        ssSetDWorkWidth(        S, OQPSK_DELAY, SampPerSym);
        ssSetDWorkDataType(     S, OQPSK_DELAY, SS_DOUBLE);
        ssSetDWorkComplexSignal(S, OQPSK_DELAY, COMPLEX_NO);

        ssSetDWorkWidth(        S, OQPSK_Q, 1);
        ssSetDWorkDataType(     S, OQPSK_Q, SS_INT32);
        ssSetDWorkComplexSignal(S, OQPSK_Q, COMPLEX_NO);

}
#endif


static void mdlTerminate(SimStruct *S)
{
}


#ifdef  MATLAB_MEX_FILE
#define MDL_SET_INPUT_PORT_DIMENSION_INFO
static void mdlSetInputPortDimensionInfo(SimStruct *S, int_T port,
                                      const DimsInfo_T *dimsInfo)
{
        const int_T    M    = (MODULATION != M_PAMPSK) ? (int_T) mxGetPr(M_ARY)[0] : (int_T) mxGetNumberOfElements(SIGRE_CONSTELL);
        int_T outRows, nbits;
        frexp((real_T)M, &nbits);  /*---Compute log2(M) for bit input---*/
        nbits = nbits - 1;/* This is the value of the no. of bits per symbol*/

        nbits = (IS_BIT_OUTPUT) ? nbits : 1;

    if(!ssSetInputPortDimensionInfo(S, port, dimsInfo)) return;

    if(ssGetInputPortConnected(S,INPORT))
        {

        /* Port info */
        const boolean_T framebased = (boolean_T)ssGetInputPortFrameData(S,INPORT);
        const int_T     inCols     = dimsInfo->dims[1];
        const int_T     inRows     = dimsInfo->dims[0];
                const int_T     dataPortWidth  = ssGetInputPortWidth(S, INPORT);
                const int_T     numDims        = ssGetInputPortNumDimensions(S, INPORT);
                const int_T                nSamp           = (framebased) ? (int_T)mxGetPr(NUM_SAMP)[0] : 1;

                if ((numDims != 1) && (numDims != 2))
                {
                        THROW_ERROR(S, "Input must be 1-D or 2-D.");
                }

                if (!framebased)
                {
                        if (dataPortWidth != 1)
                        {
                        THROW_ERROR(S,"In sample-based mode, the input must be a scalar.");
                        }
                        /* [1 x 1] -> [1 x 1], integer case */
                        /* [1 x 1] -> [nbits] */
                        /* [1] -> [nbits] */
                        outRows = inRows * nbits;
                }
                else /* Frame-based */
                {
                        if (inCols != 1)
                        {
                                THROW_ERROR(S,"In frame-based mode, inputs must be scalars or column vectors.");
                        }
                        if (inRows % nSamp != 0)
                        {
                                THROW_ERROR(S,"The input length must be a multiple of the number of samples per symbol.");
                        }

                        outRows = (MODULATION == OQPSK) ? (inRows/nSamp * nbits)/2 : (inRows/nSamp * nbits);
                }

        /* Determine if Outport need setting */
        if (ssGetOutputPortWidth(S,OUTPORT) == DYNAMICALLY_SIZED)
                {
            if ((numDims == 1) || ((!framebased) && (numDims == 2) && (IS_BIT_OUTPUT)))
                        {
                if(!ssSetOutputPortVectorDimension(S,OUTPORT,outRows)) return;
            }
                        else
                        {
                if(!ssSetOutputPortMatrixDimensions(S, OUTPORT, outRows, 1)) return;
            }
        }
                else /* Output has been set, so do error checking. */
                {
            const int_T *outDims    = ssGetOutputPortDimensions(S, OUTPORT);
            const int_T  outRowsSet = outDims[0];

            if(outRowsSet != outRows )
                        {
                THROW_ERROR(S, "Port width propagation failed.");
            }
        }
    }
}


#define MDL_SET_OUTPUT_PORT_DIMENSION_INFO
static void mdlSetOutputPortDimensionInfo(SimStruct *S, int_T port,
                                          const DimsInfo_T *dimsInfo)
{
        const int_T    M    = (MODULATION != M_PAMPSK) ? (int_T) mxGetPr(M_ARY)[0] : (int_T) mxGetNumberOfElements(SIGRE_CONSTELL);
        int_T inRows, nbits;
        frexp((real_T)M, &nbits);  /*---Compute log2(M) for bit input---*/
        nbits = nbits - 1;/* This is the value of the no. of bits per symbol*/

        nbits = (IS_BIT_OUTPUT) ? nbits : 1;

        if(!ssSetOutputPortDimensionInfo(S, port, dimsInfo)) return;

    if(ssGetOutputPortConnected(S,OUTPORT))
        {
        /* Port info */
        const boolean_T framebased = (boolean_T)(ssGetInputPortFrameData(S,INPORT) == FRAME_YES);
        const int_T     outCols = dimsInfo->dims[1];
        const int_T     outRows = dimsInfo->dims[0];
                const int_T     dataPortWidth  = ssGetOutputPortWidth(S, OUTPORT);
                const int_T     numDims        = ssGetOutputPortNumDimensions(S, OUTPORT);
                const int_T            nSamp          = (framebased) ? (int_T)mxGetPr(NUM_SAMP)[0] : 1;

                if ((numDims != 1) && (numDims != 2))
                {
                        THROW_ERROR(S, "Outputs must be 1-D or 2-D.");
                }

                if (framebased)
                {
                        if (outCols != 1)
                        {
                                THROW_ERROR(S,"In frame-based mode, outputs must be scalars or column vectors.");
                        }
                        if ( (IS_BIT_OUTPUT) && (outRows % nbits != 0) )
                        {
                                THROW_ERROR(S,"In frame-based bit output mode, the output width must be a multiple of the number of bits per symbol.");
                        }

                        inRows = (MODULATION == OQPSK) ? 2*(outRows * nSamp/nbits) : (outRows * nSamp/nbits);
                }
                else /* Sample-based */
                {
            if ( (numDims !=1) && (outRows*outCols !=1) )
            {
                THROW_ERROR(S,"In sample-based mode, outputs must be scalar or 1-D.");
                        }

                        if (dataPortWidth != nbits)
                        {
                                if (IS_INTEGER_OUTPUT)
                                {
                                        THROW_ERROR(S,"In sample-based integer output mode, the output must be a scalar.");
                                }
                                else /* BIT_OUTPUT */
                                {
                                        THROW_ERROR(S,"In sample-based bit output mode, the output must be a vector whose width equals the number of bits per symbol.");
                                }
                        }

                        inRows = outRows/nbits;
                }

                /* Determine if inport need setting */
        if (ssGetInputPortWidth(S,INPORT) == DYNAMICALLY_SIZED)
                {
                        if (numDims == 1)
                        {
                                if(!ssSetInputPortVectorDimension(S, INPORT, inRows)) return;
                        }
            else
                        {
                if(!ssSetInputPortMatrixDimensions(S, INPORT, inRows, 1)) return;
            }
        }
                else /* Input has been set, so do error checking. */
                {
            const int_T *inDims = ssGetInputPortDimensions(S, INPORT);
            const int_T  inRowsSet = inDims[0];

                        if (inRowsSet != inRows)
                        {
                                THROW_ERROR(S, "Port width propagation failed.");
                        }
        }
    }
}
#endif


#define MDL_SET_INPUT_PORT_SAMPLE_TIME
static void mdlSetInputPortSampleTime(SimStruct *S,
                                      int_T     portIdx,
                                      real_T    sampleTime,
                                      real_T    offsetTime)
{
        /* This function is executed only in the case of Sample-based inputs*/
        const int_T  numSamp = (int_T)mxGetPr(NUM_SAMP)[0];
        const int_T  inFramebased = ssGetInputPortFrameData(S,INPORT);
        real_T outSampleTime = 0.0;

#if defined(MATLAB_MEX_FILE)
        if (sampleTime == CONTINUOUS_SAMPLE_TIME)
        {
                THROW_ERROR(S,"Input signal must be discrete.");
        }
        if (offsetTime != 0.0)
        {
                THROW_ERROR(S,"Non-zero sample time offsets not allowed.");
        }
#endif

        ssSetInputPortSampleTime(S, portIdx, sampleTime);
        ssSetInputPortOffsetTime(S, portIdx, offsetTime);

        if (inFramebased)
        {
                outSampleTime = sampleTime;
        }
        else /* Sample-based*/
        {
                outSampleTime = (MODULATION == OQPSK) ? (2 * sampleTime * numSamp) : (sampleTime * numSamp);
        }

        ssSetOutputPortSampleTime(S, OUTPORT, outSampleTime);
        ssSetOutputPortOffsetTime(S, portIdx, 0.0);
}


#define MDL_SET_OUTPUT_PORT_SAMPLE_TIME
static void mdlSetOutputPortSampleTime(SimStruct *S,
                                      int_T     portIdx,
                                      real_T    sampleTime,
                                      real_T    offsetTime)
{
        /* This function is executed only in the case of Sample-based inputs*/
        const int_T  numSamp = (int_T)mxGetPr(NUM_SAMP)[0];
        const int_T  inFramebased = ssGetInputPortFrameData(S,INPORT);
        real_T inSampleTime = 0.0;

#if defined(MATLAB_MEX_FILE)
        if (sampleTime == CONTINUOUS_SAMPLE_TIME)
        {
                THROW_ERROR(S,"Output signal must be discrete.");
        }
        if (offsetTime != 0.0)
        {
                THROW_ERROR(S,"Non-zero sample time offsets not allowed.");
        }
#endif

        if (inFramebased)
        {
                inSampleTime = sampleTime;
        }
        else /* Sample-based*/
        {
                inSampleTime = (MODULATION == OQPSK) ? sampleTime/(2*numSamp) : sampleTime/numSamp;
        }

        ssSetOutputPortSampleTime(S, portIdx, sampleTime);
        ssSetOutputPortOffsetTime(S, portIdx, 0.0);

        ssSetInputPortSampleTime(S, INPORT, inSampleTime);
        ssSetInputPortOffsetTime(S, INPORT, 0.0);
}


#ifdef  MATLAB_MEX_FILE
#include "simulink.c"
#else
#include "cg_sfun.h"
#endif
