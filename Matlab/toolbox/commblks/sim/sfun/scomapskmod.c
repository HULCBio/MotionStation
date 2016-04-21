/*
 *  SCOMAPSKMOD Communications Blockset S-Function for modulating
 *  the input signal to a M-PSK, M-DPSK, M-PAM, OQPSK, Rectangular QAM
 *  or General QAM constellation.
 *
 *  Copyright 1996-2003 The MathWorks, Inc.
 *  $Revision: 1.19.4.2 $  $Date: 2004/04/12 23:03:17 $
 */

#define S_FUNCTION_NAME scomapskmod
#define S_FUNCTION_LEVEL 2

#include "comm_defs.h"


/* List input & output ports*/
enum {INPORT=0, NUM_INPORTS};
enum {OUTPORT=0, NUM_OUTPORTS};

/* List Work Vectors */
enum {MODMAP = 0, INPUTHIT, LOOKUP, LOOKUP1, PREV_PHASE, OQPSK_COUNT, SYMBOLCOUNT, NUM_DDWORK};

/* List the mask parameters */
enum {
    M_ARYC = 0,
    IN_TYPEC,
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
#define M_ARY               (ssGetSFcnParam(S,M_ARYC))
#define IN_TYPE             (ssGetSFcnParam(S,IN_TYPEC))
#define MAPPING             (ssGetSFcnParam(S,MAPPINGC))
#define NORMALIZATION       (ssGetSFcnParam(S,NORMALIZATIONC))
#define MIN_DISTANCE        (ssGetSFcnParam(S,MIN_DISTANCEC))
#define AVERAGE_POW         (ssGetSFcnParam(S,AVERAGE_POWC))
#define PEAK_POW            (ssGetSFcnParam(S,PEAK_POWC))
#define PH_OFFSET           (ssGetSFcnParam(S,PH_OFFSETC))
#define NUM_SAMP            (ssGetSFcnParam(S,NUM_SAMPC))
#define SIGRE_CONSTELL      (ssGetSFcnParam(S,SIGRE_CONSTELLC))
#define SIGIM_CONSTELL      (ssGetSFcnParam(S,SIGIM_CONSTELLC))
#define MOD_SCHEME          (ssGetSFcnParam(S,MOD_SCHEMEC))

/*Define variables representing parameter values*/
enum {BIT_INPUT=1, INTEGER_INPUT};
enum {BINARY_MAP=1, GRAY_MAP};
enum {MIN_DIST=1,AVERAGE_POWER,PEAK_POWER};
enum {M_PSK=1, M_DPSK, M_PAM, M_QAM, M_PAMPSK, OQPSK};

#define IS_INTEGER_INPUT    ((int_T)mxGetPr(IN_TYPE)[0] == INTEGER_INPUT)
#define IS_BIT_INPUT        ((int_T)mxGetPr(IN_TYPE)[0] == BIT_INPUT)
#define IS_BINARY_MAP       ((int_T)mxGetPr(MAPPING)[0] == BINARY_MAP)
#define IS_GRAY_MAP         ((int_T)mxGetPr(MAPPING)[0] == GRAY_MAP)

/* Defines the modulation scheme*/
#define MODULATION          (int_T)mxGetPr(MOD_SCHEME)[0] 
#define OPERATION_MODE      (int_T)mxGetPr(FRAMING)[0]
#define INPUT_TYPE          (int_T)mxGetPr(IN_TYPE)[0]
#define NORM_TYPE           (int_T)mxGetPr(NORMALIZATION)[0]

#define BLOCK_BASED_SAMPLE_TIME        1

/* --- Function prototypes --- 
 * Function to compute the symbol mapping
 * table for various modulation schemes
 */
static void setModMap(SimStruct *S);

/* Function to compute the index for the symbol mapping table */
static void setIndex(SimStruct *S)
{
    const real_T  *uin         = ssGetInputPortRealSignal(S, INPORT);
          real_T  *PrevPhase   = (real_T *)ssGetDWork(S, PREV_PHASE);
          creal_T *lookup      = (creal_T *)ssGetDWork(S, LOOKUP);
          creal_T *lookup1     = (creal_T *)ssGetDWork(S, LOOKUP1);
    const int_T   inFramebased = ssGetInputPortFrameData(S, INPORT);
    const int_T   nSamp        = (inFramebased) ? (int_T)mxGetPr(NUM_SAMP)[0] : 1;
    const int_T   SampPerSym   = (int_T)mxGetPr(NUM_SAMP)[0];
    const int_T   InPortWidth  = ssGetInputPortWidth(S, INPORT);
    const int_T   M            = (MODULATION != M_PAMPSK) ? (int_T)mxGetPr(M_ARY)[0] : mxGetNumberOfElements(SIGRE_CONSTELL);

    real_T u = 0.0, phase = 0.0;
    int_T  i = 0, j = 0, nbits = 0, SamplesPerInputFrame = 0, SymbolIndex = 0;
    int_T uconv = 0, y1 = 0, y0 = 0;
    frexp((real_T)M, &nbits);
    nbits = nbits - 1;    /* nbits now has a value of no. of bits per symbol */

    SamplesPerInputFrame = (IS_INTEGER_INPUT) ? InPortWidth : InPortWidth/nbits;

    /* For each input sample, compute the index for the symbol mapping table
     * For Bit input convert a vector of bits into an integer taking into
     * account Gray mapping.
     * For Integer input the index equals the input values.
     */
    for (i = 0; i < SamplesPerInputFrame; i++)
    {
        SymbolIndex = 0;
        switch (INPUT_TYPE)
        {
        case BIT_INPUT:
        {
            /* In case of Bit input, convert the bits
               to a binary mapped integer. */
            if (MODULATION == OQPSK) {
                int32_T *symbolCount = (int32_T *) ssGetDWork(S, SYMBOLCOUNT);
                (*symbolCount)++;

                /* For OQPSK, generate the index using offset Q. 
                   The output symbol rate is twice the bit rate. */
                u = *uin++;
#ifdef MATLAB_MEX_FILE
                if((u != 0) && (u != 1)) {
                    THROW_ERROR(S, "Input must be binary.");
                }
#endif
                SymbolIndex += (int32_T) u;
                SymbolIndex <<= 1;
                u = *uin++;
#ifdef MATLAB_MEX_FILE
                if ((u != 0) && (u != 1)) {
                    THROW_ERROR(S,"Input must be binary.");
                }
#endif
                SymbolIndex += (int32_T) u; /* present Q value */
            } else /* For all other modulation schemes */
            {
                int_T m;
                for (m = 0; m < nbits; m++)
                {
                    SymbolIndex<<=1;
                    u = *uin++;
#ifdef MATLAB_MEX_FILE
                if((u != 0) && (u != 1))
                {
                    THROW_ERROR(S,"Input must be binary.");
                }
#endif
                SymbolIndex+= (int32_T)u;
            }

            /* Gray mapping is not applicable to OQPSK modulation */
            if (IS_GRAY_MAP)
            {
                if (MODULATION == M_QAM)
                {
                    if (nbits%2 == 0)
                    {
                        int32_T SymbolI = SymbolIndex >> (nbits/2);
                        int32_T SymbolQ = SymbolIndex & ((M - 1) >> (nbits/2));
                        int_T g;
                        for (g = 1; g < (nbits/2); g+=g)
                        {
                            SymbolI^=SymbolI>>g;
                            SymbolQ^=SymbolQ>>g;
                        }
                        SymbolIndex = (SymbolI << (nbits/2)) + SymbolQ;
                    }
                    else /* nbits is odd */
                    {
                        int_T nIbits = (nbits+1)/2;
                        int_T nQbits = (nbits-1)/2;
                        int32_T SymbolI = SymbolIndex >> nQbits;
                        int32_T SymbolQ = SymbolIndex & ((M - 1) >> nIbits);
                        int_T g, k;
                        for (g = 1; g < nIbits; g+=g)
                        {
                            SymbolI^=SymbolI>>g;
                        }
                        for (k = 1; k < nQbits; k+=k)
                        {
                            SymbolQ^=SymbolQ>>k;
                        }
                        SymbolIndex = (SymbolI << nQbits) + SymbolQ;
                    }
                }
                else  /* For all other modulation schemes */
                {
                    int_T g;
                    for (g = 1; g < nbits; g+=g)
                    {
                        SymbolIndex^=SymbolIndex>>g;
                    }
                }
            }
        } /* End of else */
    }
    break;
    case INTEGER_INPUT: /* Integer Input */
    {
        if (MODULATION == OQPSK) 
        {
            int_T *symbolCount = (int_T *) ssGetDWork(S, SYMBOLCOUNT);
            (*symbolCount)++;

            u = *uin++;
#ifdef MATLAB_MEX_FILE
            if ((u != floor(u)) || (u > 3.0) || (u < 0.0)) {
                THROW_ERROR(S, "Input must be an integer in the range of 0 to 3.");
            }
#endif
            SymbolIndex = (int_T) u;       /* the current symbol index */
        }
        else    /* For all other modulation schemes */
        {
            u = *uin++;
#ifdef MATLAB_MEX_FILE
            if ((u != floor(u)) || (u > (M-1)) || (u < 0.0))
            {
                THROW_ERROR(S,"Input must be an integer in the range of 0 to M-1.");
            }
#endif
            SymbolIndex = (int32_T)u;
        }
    }
    break;
    default:
        THROW_ERROR(S,"Invalid input type.");
    }

    /* For each modulation scheme determine the complex output values by
     * looking up the symbol mapping table with the indices generated in
     * the SetIndex function */
    switch (MODULATION)
    {
        case OQPSK:
        {
            int_T *symbolCount = (int_T *) ssGetDWork(S, SYMBOLCOUNT);
            creal_T *modmap = (creal_T *) ssGetDWork(S, MODMAP);

            int_T  numSymbols  = ssGetInputPortWidth(S, INPORT);
            if (INPUT_TYPE == BIT_INPUT) {
                numSymbols /= 2;
            }

            /* lookup: for 1st half of output symbol in mdlOutput();
               lookup->re is the current I value;
               lookup->im is the previous Q value */
            if (inFramebased && (numSymbols > 1)) {
                *symbolCount = *symbolCount % numSymbols;
                if (*symbolCount == 1) {
                    /* For 1st symbol of a frame, adjust the lookup1 pointer 
                       to account for input of new frame which resets the 
                       pointers. */
                    lookup->im = (lookup1 + numSymbols - 1)->im;
                } else {
                    lookup->im = (lookup1 - 1)->im;
                }
            } else {
                lookup->im = lookup1->im;
            }
            (lookup++)->re = modmap[SymbolIndex].re;
 
            /* lookup1: for 2nd half of output symbol in mdlOutput();
               lookup1 contains the current I & Q values for output*/
            *(lookup1++) = modmap[SymbolIndex];
        }
        break;
        case M_PAMPSK:
        case M_QAM:
        case M_PSK:
        {
            creal_T  *modmap  = (creal_T *)ssGetDWork(S, MODMAP);
            lookup->re = modmap[SymbolIndex].re;
            (lookup++)->im = modmap[SymbolIndex].im;
        }
        break;
        case M_DPSK:
        {
            real_T   *modmap  = (real_T *)ssGetDWork(S, MODMAP);
            phase = fmod(*PrevPhase + modmap[SymbolIndex], (real_T)(DSP_TWO_PI));
            (lookup)->re = cos(phase);
            (lookup++)->im = sin(phase);
            *PrevPhase = phase;
        }
        break;
        case M_PAM:
        {
            real_T   *modmap  = (real_T *)ssGetDWork(S, MODMAP);
            (lookup)->re = modmap[SymbolIndex];
            (lookup++)->im = 0.0;
        }
        break;
        default:
            THROW_ERROR(S,"Invalid modulation scheme.");
    } /* End of switch statement*/
    }
}


/* Function: mdlCheckParameters =============================================*/
#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S)
{
    /*---Check to see if the Input type parameter is either 1 or 2 ------*/
    if (!IS_FLINT_IN_RANGE(IN_TYPE, 1, 2))
    {
        THROW_ERROR(S, "Input type parameter is outside of expected range.");
    }

    /* Check to see if the Constellation ordering parameter is either 1 or 2 */
    if (!IS_FLINT_IN_RANGE(MAPPING, 1, 2))
    {
        THROW_ERROR(S, "Constellation ordering parameter is outside of expected range.");
    }

    /*---Check to see if the Power type parameter is either 1 to 3 ----*/
    if (!IS_FLINT_IN_RANGE(NORMALIZATION,1,3))
    {
        THROW_ERROR(S,"Power type parameter is outside of expected range.");
    }

    /* Check to see if the Modulation scheme parameter is in the range of 1 to 6 */
    if (!IS_FLINT_IN_RANGE(MOD_SCHEME, 1, 6))
    {
        THROW_ERROR(S, "Modulation scheme parameter is outside of expected range.");
    }

    /*---Check the M-ARY number parameter-----------*/
    /* For bit input check if M is a scalar which is an integer power of 2 */

    if (OK_TO_CHECK_VAR(S, M_ARY))
    {
        if (!mxIsEmpty(M_ARY))
    {
        int_T nbits = 0;
        const int_T M = (int_T)mxGetPr(M_ARY)[0];

        switch (INPUT_TYPE)
        {
            case BIT_INPUT: /*For bit input check if M is a scalar which is an integer power of 2*/
        {
            if ((!IS_FLINT_GE(M_ARY, 2)) || (frexp((real_T)M, &nbits) != 0.5) || (mxIsEmpty(M_ARY)))
            {
                THROW_ERROR(S, "In case of Bit type input M-ary number parameter must be a scalar positive real integer value which is a non-zero power of two.");
            }
        }
        break;
            case INTEGER_INPUT:    /*For integer input check if M is a positive scalar integer*/
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
            THROW_ERROR(S,"Invalid input type.");
        }
    }
    else
    {
        switch (INPUT_TYPE)
        {
            case BIT_INPUT:
        {
            THROW_ERROR(S, "In case of Bit type input M-ary number parameter must be a scalar positive real integer value which is a non-zero power of two.");
        }
        break;
            case INTEGER_INPUT:
        {
            THROW_ERROR(S," M-ary number parameter must be a scalar positive integer value.");
        }
        break;
            default:
            THROW_ERROR(S,"Invalid input type.");
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
                if ((mxIsComplex(MIN_DISTANCE)) || (!IS_SCALAR(MIN_DISTANCE)) || (mxIsInf(mxGetPr(MIN_DISTANCE)[0])) || ((mxGetPr(MIN_DISTANCE)[0]) <= 0.0))
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
                if ((mxIsComplex(AVERAGE_POW)) || (!IS_SCALAR(AVERAGE_POW)) || (mxIsInf(mxGetPr(AVERAGE_POW)[0])) || ((mxGetPr(AVERAGE_POW)[0]) <= 0.0))
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
                if ((mxIsComplex(PEAK_POW)) || (!IS_SCALAR(PEAK_POW)) || (mxIsInf(mxGetPr(PEAK_POW)[0])) || ((mxGetPr(PEAK_POW)[0]) <= 0.0))
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
        || (mxIsInf(mxGetPr(PH_OFFSET)[0])))
        {
            THROW_ERROR(S," Phase offset parameter must be a real valued scalar.");
        }
    }
    else
    {
        THROW_ERROR(S," Phase offset parameter must be a real valued scalar.");
    }
    }

    /* Check to see if the Samples per symbol parameter is a positive integer value*/
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
            THROW_ERROR(S," Signal Constellation parameter must be defined.");
        }
    }

    if (OK_TO_CHECK_VAR(S, SIGIM_CONSTELL))
    {
        if (mxIsEmpty(SIGIM_CONSTELL))
        {
            THROW_ERROR(S," Signal Constellation parameter must be defined.");
        }
    }
    }

} /* end mdlCheckParameters */
#endif


/* Function: mdlInitializeSizes =============================================*/

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
    if (!ssSetNumInputPorts(S, NUM_INPORTS)) return;
    if (!ssSetInputPortDimensionInfo(S, INPORT, DYNAMIC_DIMENSION)) return;
    ssSetInputPortFrameData(         S, INPORT, FRAME_INHERITED);
    ssSetInputPortDirectFeedThrough( S, INPORT, 1);
    ssSetInputPortComplexSignal(     S, INPORT, COMPLEX_NO);
    ssSetInputPortReusable(             S, INPORT, 0);
    ssSetInputPortRequiredContiguous(S, INPORT, 1);
    ssSetInputPortSampleTime(        S, INPORT,  INHERITED_SAMPLE_TIME);

    /* Output: */
    if (!ssSetNumOutputPorts(S,NUM_OUTPORTS)) return;
    if (!ssSetOutputPortDimensionInfo(S, OUTPORT, DYNAMIC_DIMENSION)) return;
    ssSetOutputPortFrameData(          S, OUTPORT, FRAME_INHERITED);
    ssSetOutputPortComplexSignal(     S, OUTPORT, COMPLEX_YES);
    ssSetOutputPortReusable(          S, OUTPORT, 0);
    ssSetOutputPortSampleTime(        S, OUTPORT, INHERITED_SAMPLE_TIME);

    if (!ssSetNumDWork(S, DYNAMICALLY_SIZED)) return;

    ssSetOptions( S, SS_OPTION_EXCEPTION_FREE_CODE);

    ssSetSFcnParamNotTunable(S, IN_TYPEC);
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

/* Function: mdlInitializeSampleTimes =======================================*/
static void mdlInitializeSampleTimes(SimStruct *S)
{
#ifdef MATLAB_MEX_FILE
    /* see geck: 83856 */
    const real_T Tsi = ssGetInputPortSampleTime(S, INPORT);
    const real_T Tso = ssGetOutputPortSampleTime(S, OUTPORT);

    if ((Tsi == INHERITED_SAMPLE_TIME)  ||
        (Tso == INHERITED_SAMPLE_TIME)   )
    {
        THROW_ERROR(S,"Sample time propagation failed.");
    }

    if ((ssGetOutputPortWidth(S,OUTPORT) == DYNAMICALLY_SIZED)  ||
        (ssGetInputPortWidth( S,INPORT ) == DYNAMICALLY_SIZED)   )
    {
        THROW_ERROR(S,"Port width propagation failed.");
    }
    
    ssSetModelReferenceSampleTimeInheritanceRule(S, USE_DEFAULT_FOR_DISCRETE_INHERITANCE);
    
#endif
}
/* End of mdlInitializeSampleTimes(SimStruct *S) */


/* Function: mdlInitializeConditions ========================================*/

#define MDL_INITIALIZE_CONDITIONS
static void mdlInitializeConditions(SimStruct *S)
{
    /* Initialize the phase of the previous symbol to zero*/
    real_T            *PrevPhase      =  (real_T *)ssGetDWork(S, PREV_PHASE);
    *PrevPhase = 0.0;

    /* --- Evaluate the symbol mapping table --- */
    setModMap(S);
}

/* Function: mdlProcessParameters ===========================================*/
#define MDL_PROCESS_PARAMETERS
static void mdlProcessParameters(SimStruct *S)
{
    /* Recompute symbol mapping table to account for changes in parameter value*/
    setModMap(S);
}

/* Function: setModMap ===========================================*/
static void setModMap(SimStruct *S)
{
    const int_T  InPortWidth = ssGetInputPortWidth(S, INPORT);
    const int_T  M           = (MODULATION != M_PAMPSK) ? (int_T)mxGetPr(M_ARY)[0] : (int_T)mxGetNumberOfElements(SIGRE_CONSTELL);
    real_T Initialphase      = fmod(mxGetPr(PH_OFFSET)[0], (real_T)(DSP_TWO_PI));
    int_T i = 0, nbits = 0, I_data = 0, Q_data = 0, scale = 0;
    real_T phase = 0.0, Min_Dist = 0.0;

    frexp((real_T)M, &nbits);  /* Compute log2(M) for bit input */
    nbits = nbits - 1; /* This is the value of the no. of bits per symbol */

    /* Generate the symbol mapping table for the various modulation schemes.
     * The table stores output values corresponding to inputs from 1 to M-1*/
    switch (MODULATION)
    {
    case OQPSK:
    {
        creal_T  *modmap = (creal_T *)ssGetDWork(S, MODMAP);
        (modmap)->re     = cos(Initialphase + DSP_PI/4.0);
        (modmap++)->im   = sin(Initialphase + DSP_PI/4.0);
        (modmap)->re     = cos(Initialphase + (7*DSP_PI)/4.0);
        (modmap++)->im   = sin(Initialphase + (7*DSP_PI)/4.0);
        (modmap)->re     = cos(Initialphase + (3*DSP_PI)/4.0);
        (modmap++)->im   = sin(Initialphase + (3*DSP_PI)/4.0);
        (modmap)->re     = cos(Initialphase + (5*DSP_PI)/4.0);
        (modmap)->im     = sin(Initialphase + (5*DSP_PI)/4.0);

    }
    break;
    case M_PSK:
    {
        creal_T  *modmap  = (creal_T *)ssGetDWork(S, MODMAP);
        for (i = 0; i < M; i++)
        {
            phase = Initialphase + (DSP_TWO_PI * i)/M;
        (modmap)->re =   cos(phase);
        (modmap++)->im = sin(phase);
        }
    }
    break;
    case M_DPSK:
    {
        real_T  *modmap  = (real_T *)ssGetDWork(S, MODMAP);
        for (i = 0; i < M; i++)
        {
            *modmap++ = Initialphase + (DSP_TWO_PI * i)/M;
        }
    }
    break;
    case M_PAM:
    {
        real_T     *modmap  = (real_T *)ssGetDWork(S, MODMAP);

        /* Compute the minimum distance between symbols */
        switch (NORM_TYPE)
        {
            case MIN_DIST:
        {
            Min_Dist = mxGetPr(MIN_DISTANCE)[0];
        }
        break;
            case AVERAGE_POWER:
        {
            Min_Dist = sqrt(2 * (6.0/((real_T)M*(real_T)M - 1.0)) * (mxGetPr(AVERAGE_POW)[0]));
        }
        break;
            case PEAK_POWER:
        {
            Min_Dist = (2.0/((real_T)M - 1.0)) * (sqrt(mxGetPr(PEAK_POW)[0]));
        }
        break;
            default:
            THROW_ERROR(S,"Invalid Power type.");
        }

        for (i = 0; i < M; i++)
        {
            *modmap++ = (real_T)((2 * i + 1 - M) * Min_Dist)/2;
        }
    }
    break;
    case M_QAM:
    {
        creal_T cplx_phase, cplx_data;
        creal_T  *modmap  = (creal_T *)ssGetDWork(S, MODMAP);
        cplx_phase.re = cos(Initialphase);
        cplx_phase.im = sin(Initialphase);
        scale = (int_T)pow(2,nbits/2);

        /* Compute the minimum distance between symbols */
        switch (NORM_TYPE)
        {
            case MIN_DIST:
        {
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

        if (nbits%2 == 0)
        {
        /* Square Constellation QAM */
            for (i = 0; i < M; i++)
        {
            I_data = i >> (nbits/2);
            Q_data = i & ((M - 1) >> (nbits/2));
            cplx_data.re = ((2 * I_data + 1 - (M/scale)) * Min_Dist)/2;
            cplx_data.im = (-1) * ((2 * Q_data + 1 - (M/scale)) * Min_Dist)/2;
            (modmap)->re = CMULT_RE(cplx_data,cplx_phase);
            (modmap)->im = CMULT_IM(cplx_data,cplx_phase);
            *modmap++;
        }
        }
        else
        {
            /* Cross Constellation QAM */
            int_T nIbits = (nbits + 1) / 2;
        int_T nQbits = (nbits - 1) / 2;
        int_T mI = (int_T)pow(2, nIbits);
        int_T mQ = (int_T)pow(2, nQbits);
        for (i = 0; i < M; i++)
        {
            I_data = i >> nQbits;
            Q_data = i & ((M - 1) >> nIbits);
            cplx_data.re = (2 * I_data + 1 - mI);
            cplx_data.im = -1 * (2 * Q_data + 1 - mQ);
            if(M>8)
            {
                int_T I_mag = abs((int_T)cplx_data.re);
            if(I_mag > 3 * (mI / 4))
            {
                int_T Q_mag = abs((int_T)cplx_data.im);
                int_T I_sgn = cplx_data.re < 0 ? -1 : 1;
                int_T Q_sgn = cplx_data.im < 0 ? -1 : 1;
                if(Q_mag > mQ/2)
                {
                    cplx_data.re = I_sgn*(I_mag - mI/2);
                cplx_data.im = Q_sgn*(2*mQ - Q_mag);
                } else {
                    cplx_data.re = I_sgn*(mI - I_mag);
                cplx_data.im = Q_sgn*(mQ + Q_mag);
                }
            }

            }

            cplx_data.re *= Min_Dist / 2;
            cplx_data.im *= Min_Dist / 2;

            (modmap)->re = CMULT_RE(cplx_data, cplx_phase);
            (modmap)->im = CMULT_IM(cplx_data, cplx_phase);
            *modmap++;
        }
        }
    }
    break;
    case M_PAMPSK:
    {
        creal_T  *modmap  = (creal_T *)ssGetDWork(S, MODMAP);
        for (i = 0; i < M; i++)
        {
            (modmap)->re = mxGetPr(SIGRE_CONSTELL)[i];
        (modmap)->im = mxGetPr(SIGIM_CONSTELL)[i];
        *modmap++;
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
    const int_T    inFramebased = ssGetInputPortFrameData(S,INPORT);
    const int_T    nSamp        = (inFramebased) ? (int_T)mxGetPr(NUM_SAMP)[0] : 1;
    const int_T    SampPerSym   = (int_T)mxGetPr(NUM_SAMP)[0];
    const int_T    InPortWidth  = ssGetInputPortWidth(S, INPORT);
    const int_T    M            = (int_T)mxGetPr(M_ARY)[0];
    int_T i = 0, nbits = 0, SamplesPerInputFrame = 0;

    frexp((real_T)M, &nbits);  /*---Compute log2(M) for bit input---*/
    nbits = nbits - 1; /* number of bits per symbol */

    SamplesPerInputFrame = (IS_INTEGER_INPUT) ? InPortWidth : InPortWidth/nbits;

    if (!inFramebased)   /*---Sample based inputs---*/
    {
    const int_T OutportTid = ssGetOutputPortSampleTimeIndex(S, OUTPORT);
    const int_T InportTid  = ssGetInputPortSampleTimeIndex(S, INPORT);
    int32_T *oqpsk_count = (int32_T *) ssGetDWork(S, OQPSK_COUNT);
    boolean_T *inputHit = (boolean_T *) ssGetDWork(S, INPUTHIT);

    /* At Input sample-time hit,
     * generate index to look up the symbol mapping table */
    if(ssIsSampleHit(S, InportTid, tid)) {
        setIndex(S);
        *inputHit = (boolean_T) true; /* for fixing multitasking mode */
    }

    /* Assign output value at output sample-time hit by looking up
     *  the output values from the symbol mapping table */
    if (MODULATION == OQPSK) {
        if(ssIsSampleHit(S, OutportTid, tid) && *inputHit) {
            creal_T *y       = (creal_T *)ssGetOutputPortSignal(S, OUTPORT);
            creal_T *lookup  = (creal_T *)ssGetDWork(S, LOOKUP);
            creal_T *lookup1 = (creal_T *)ssGetDWork(S, LOOKUP1);

            if ((*oqpsk_count)++ < SampPerSym) {
                y->re = lookup->re;
                y->im = lookup->im;
            } else {
                y->re = lookup1->re;
                y->im = lookup1->im;
                if ((*oqpsk_count) % (2*SampPerSym) == 0) {
                    *oqpsk_count = 0;
                }
            }
        }
    } else {
        if(ssIsSampleHit(S, OutportTid, tid)) {
        creal_T    *y      = (creal_T *)ssGetOutputPortSignal(S, OUTPORT);
        creal_T *lookup = (creal_T *)ssGetDWork(S, LOOKUP);
        y->re = lookup->re;
        y->im = lookup->im;
        }
    }
    } else { /*---Frame based inputs---*/
    const int_T OutportTid = ssGetOutputPortSampleTimeIndex(S, OUTPORT);
    const int_T InportTid  = ssGetInputPortSampleTimeIndex(S, INPORT);
    int32_T  *oqpsk_count  = (int32_T *)ssGetDWork(S, OQPSK_COUNT);

    /* At Input sample-time hit,
     *  generate index to look up the symbol mapping table */
    setIndex(S);

    /* Look up the symbol mapping table */
    if (MODULATION == OQPSK) {
        creal_T *y       = (creal_T *)ssGetOutputPortSignal(S, OUTPORT);
        creal_T *lookup  = (creal_T *)ssGetDWork(S, LOOKUP);
        creal_T *lookup1 = (creal_T *)ssGetDWork(S, LOOKUP1);
        for (i = 0; i < (SamplesPerInputFrame * 2 * nSamp); i++) {
        if (*oqpsk_count == 0) {
            y->re     = lookup->re;
            (y++)->im = lookup->im;
            if ((i + 1) % nSamp == 0) { /* Update for next symbol */
            *oqpsk_count = 1;
            lookup++;
            }
        } else { /* oqpsk_count == 1 */
            y->re = lookup1->re;
            (y++)->im = lookup1->im;
            if ((i + 1) % nSamp == 0) { /* Update for next symbol */
            *oqpsk_count = 0;
            lookup1++;
            }
        }
        }
    } else { /* For all other modulation schemes */
        creal_T *y      = (creal_T *)ssGetOutputPortSignal(S, OUTPORT);
        creal_T *lookup = (creal_T *)ssGetDWork(S, LOOKUP);
        for (i = 0; i < (SamplesPerInputFrame * nSamp); i++) {
        y->re = lookup->re;
        (y++)->im = lookup->im;
        if ((i + 1) % nSamp == 0) {
            lookup++; /* Update for next symbol */
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
    const int_T    M    = (MODULATION != M_PAMPSK) ? (int_T)mxGetPr(M_ARY)[0]
                                                   : mxGetNumberOfElements(SIGRE_CONSTELL);
    const int_T        InPortWidth     = ssGetInputPortWidth(S, INPORT);
    int_T  nbits = 0, LEN = 0, COMPLEXITY;
    frexp((real_T)M, &nbits);  /*---Compute log2(M) for bit input---*/
    nbits = nbits - 1;
    LEN = (IS_INTEGER_INPUT) ? InPortWidth : InPortWidth/nbits;

    switch (MODULATION) /* determine whether symbol mapping table
                        stores complex or real values*/
    {
        case OQPSK:
        case M_QAM:
        case M_PSK:
        case M_PAMPSK:
            COMPLEXITY = COMPLEX_YES;
            break;
        case M_PAM:
        case M_DPSK:
            COMPLEXITY = COMPLEX_NO;
            break;
        default:
            THROW_ERROR(S,"Invalid modulation scheme.");
    }

    ssSetNumDWork(          S, NUM_DDWORK);

    ssSetDWorkWidth(        S, MODMAP, M);
    ssSetDWorkDataType(     S, MODMAP, SS_DOUBLE);
    ssSetDWorkComplexSignal(S, MODMAP, COMPLEXITY);

    ssSetDWorkWidth(        S, INPUTHIT, 1);
    ssSetDWorkDataType(     S, INPUTHIT, SS_BOOLEAN);
    ssSetDWorkComplexSignal(S, INPUTHIT, COMPLEX_NO);

    ssSetDWorkWidth(        S, LOOKUP, LEN);
    ssSetDWorkDataType(     S, LOOKUP, SS_DOUBLE);
    ssSetDWorkComplexSignal(S, LOOKUP, COMPLEX_YES);

    ssSetDWorkWidth(        S, LOOKUP1, LEN);
    ssSetDWorkDataType(     S, LOOKUP1, SS_DOUBLE);
    ssSetDWorkComplexSignal(S, LOOKUP1, COMPLEX_YES);

    ssSetDWorkWidth(        S, PREV_PHASE, 1);
    ssSetDWorkDataType(     S, PREV_PHASE, SS_DOUBLE);
    ssSetDWorkComplexSignal(S, PREV_PHASE, COMPLEX_NO);

    ssSetDWorkWidth(        S, SYMBOLCOUNT, 1);
    ssSetDWorkDataType(     S, SYMBOLCOUNT, SS_INT32);
    ssSetDWorkComplexSignal(S, SYMBOLCOUNT, COMPLEX_NO);

    ssSetDWorkWidth(        S, OQPSK_COUNT, 1);
    ssSetDWorkDataType(     S, OQPSK_COUNT, SS_INT32);
    ssSetDWorkComplexSignal(S, OQPSK_COUNT, COMPLEX_NO);
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
    const int_T    M    = (MODULATION != M_PAMPSK) ? (int_T)mxGetPr(M_ARY)[0]
                                                   : mxGetNumberOfElements(SIGRE_CONSTELL);

    int_T outCols, outRows, nbits;
    frexp((real_T)M, &nbits);  /*---Compute log2(M) for bit input---*/
    nbits = nbits - 1;/* This is the value of the no. of bits per symbol*/

    nbits = (IS_BIT_INPUT) ? nbits : 1;

    if(!ssSetInputPortDimensionInfo(S, port, dimsInfo)) return;

    if(ssGetInputPortConnected(S,INPORT))
    {

        /* Port info */
        const boolean_T framebased = (boolean_T)ssGetInputPortFrameData(S,INPORT);
        const int_T     inCols     = dimsInfo->dims[1];
        const int_T     inRows     = dimsInfo->dims[0];
        const int_T     dataPortWidth  = ssGetInputPortWidth(S, INPORT);
        const int_T     numDims        = ssGetInputPortNumDimensions(S, INPORT);
        const int_T        nSamp          = (framebased) ? (int_T)mxGetPr(NUM_SAMP)[0] : 1;


        if ((numDims != 1) && (numDims != 2))
        {
            THROW_ERROR(S, "Input must be 1-D or 2-D.");
        }

        if (!framebased)
        {
            if (IS_INTEGER_INPUT)
            {
                if (dataPortWidth != 1)
                {
                    THROW_ERROR(S,"In sample-based integer input mode, the input must be a scalar.");
                }
                else { outRows = inRows; }
            }
            else /* BIT_INPUT */
            {
                if((dataPortWidth != nbits) || ((numDims == 2) && (inCols!=1) && (inRows!=1)))
                {
                    THROW_ERROR(S,"In sample-based bit input mode, the input must be a vector whose width equals the number of bits per symbol.");
                }

                if ((numDims == 2) && (inCols > 1)) /* [1 x N_BIT] -> [1 x 1] */
                {
                    outCols = inCols/nbits;
                }
                    /* [N_BIT x 1], [N_BIT]  -> [1 x 1], [1]*/
                else  {outRows = inRows/nbits;}
            }
        }
        else /* Frame-based */
        {
            if (inCols != 1)
            {
                THROW_ERROR(S,"In frame-based mode, inputs must be scalars or column vectors.");
            }
            else if ((inRows % nbits) != 0)
            {
                THROW_ERROR(S,"In frame-based bit input mode, the width of the input vector must be an integer multiple of the number of bits per symbol.");
            }
            else
            {
                outRows = (MODULATION == OQPSK) ? 2*(inRows/nbits * nSamp) : (inRows/nbits * nSamp);
            }
        }

        /* Determine if Outport need setting */
        if (ssGetOutputPortWidth(S,OUTPORT) == DYNAMICALLY_SIZED)
        {

            if (numDims == 1)
            {
                if(!ssSetOutputPortVectorDimension(S,OUTPORT,outRows)) return;
            }
            else if ((framebased) || ((!framebased) && (inCols == 1)))
            {
                if(!ssSetOutputPortMatrixDimensions(S, OUTPORT, outRows, 1)) return;
            }
            else
            {
                if(!ssSetOutputPortMatrixDimensions(S, OUTPORT, 1, outCols)) return;
            }
        }
        else /* Output has been set, so do error checking. */
        {
            const int_T *outDims    = ssGetOutputPortDimensions(S, OUTPORT);
            const int_T  outRowsSet = outDims[0];
            const int_T  outColsSet = outDims[1];

            if((!framebased) && (inCols > 1)  /* [1 x N_BIT] -> [1 x 1] */
                && (outColsSet != outCols))
            {
                THROW_ERROR(S, "Port width propagation failed.");
            }
            else if (outRowsSet != outRows)
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
    const int_T    M    = (MODULATION != M_PAMPSK) ? (int_T)mxGetPr(M_ARY)[0]
                                                   : mxGetNumberOfElements(SIGRE_CONSTELL);
    int_T inRows, nbits;
    frexp((real_T)M, &nbits);  /*---Compute log2(M) for bit input---*/
    nbits = nbits - 1;/* This is the value of the no. of bits per symbol*/

    nbits = (IS_BIT_INPUT) ? nbits : 1;

    if(!ssSetOutputPortDimensionInfo(S, port, dimsInfo)) return;

    if(ssGetOutputPortConnected(S,OUTPORT))
    {
        /* Port info */
        const boolean_T framebased = (boolean_T)(ssGetInputPortFrameData(S,INPORT) == FRAME_YES);
        const int_T     outCols = dimsInfo->dims[1];
        const int_T     outRows = dimsInfo->dims[0];
        const int_T     dataPortWidth  = ssGetOutputPortWidth(S, OUTPORT);
        const int_T     numDims        = ssGetOutputPortNumDimensions(S, OUTPORT);
        const int_T        nSamp          = (framebased) ? (int_T)mxGetPr(NUM_SAMP)[0] : 1;

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

            if (outRows % nSamp !=0)
            {
                THROW_ERROR(S,"The output length must be a multiple of the number of samples per symbol.");
            }

            inRows = (MODULATION == OQPSK) ? (outRows/nSamp * nbits)/2 : (outRows/nSamp * nbits);
        }
        else /* Sample-based */
        {
            if (dataPortWidth != 1)
            {
                THROW_ERROR(S,"In sample-based mode, the output must be a scalar.");
            }

            if ((IS_INTEGER_INPUT) || ((IS_BIT_INPUT) && (numDims == 1)))
            {
                inRows = outRows * nbits;
            }
        }

        /* Determine if inport need setting. */
        if (ssGetInputPortWidth(S,INPORT) == DYNAMICALLY_SIZED)
        {
            if (numDims == 1)
            {
                if(!ssSetInputPortVectorDimension(S, INPORT, inRows)) return;
            }
            else if ((framebased) || ((!framebased) && (IS_INTEGER_INPUT)))
            {
                /* Oriented sample-based Integer inputs and frame-based signals */
                if(!ssSetInputPortMatrixDimensions(S, INPORT, inRows, 1)) return;
            }
            else if ((!framebased) && (IS_BIT_INPUT))
            {
                /* Sample-based bit inputs */
                if(!ssSetInputPortVectorDimension(S, INPORT, (outRows * nbits))) return;
            }
        }
        else /* Input has been set, so do error checking. */
        {
            const int_T *inDims = ssGetInputPortDimensions(S, INPORT);
            const int_T  inRowsSet = inDims[0];

            if (((framebased) || ((!framebased)
                  && ((IS_INTEGER_INPUT) || ((IS_BIT_INPUT) && (numDims == 1)))))
                  && (inRowsSet != inRows))
            {
                THROW_ERROR(S, "Port width propagation failed.");
            }
        }
    }
}
#endif



#if defined(MATLAB_MEX_FILE)
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

    ssSetInputPortSampleTime(S, portIdx, sampleTime);
    ssSetInputPortOffsetTime(S, portIdx, offsetTime);

    if (sampleTime == CONTINUOUS_SAMPLE_TIME)
    {
        THROW_ERROR(S,"Input signal must be discrete.");
    }
    if (offsetTime != 0.0)
    {
        THROW_ERROR(S,"Non-zero sample time offsets not allowed.");
    }

    if (inFramebased)
    {
        outSampleTime = sampleTime;
    }
    else /* Sample-based*/
    {
        outSampleTime = (MODULATION == OQPSK) ? (sampleTime/(2*numSamp)) : (sampleTime/numSamp);
    }

    ssSetOutputPortSampleTime(S, OUTPORT, outSampleTime);
    ssSetOutputPortOffsetTime(S, OUTPORT, 0.0);
}

#define MDL_SET_OUTPUT_PORT_SAMPLE_TIME
static void mdlSetOutputPortSampleTime(SimStruct *S,
                                      int_T     portIdx,
                                      real_T    sampleTime,
                                      real_T    offsetTime)
{
    /* This function is executed only in the case of Sample-based inputs*/
    const int_T  numSamp =      (int_T)mxGetPr(NUM_SAMP)[0];
    const int_T  inFramebased = ssGetInputPortFrameData(S,INPORT);
    real_T inSampleTime = 0.0;

    ssSetOutputPortSampleTime(S, portIdx, sampleTime);
    ssSetOutputPortOffsetTime(S, portIdx, offsetTime);

    if (sampleTime == CONTINUOUS_SAMPLE_TIME)
    {
        THROW_ERROR(S,"Output signal must be discrete.");
    }
    if (offsetTime != 0.0)
    {
        THROW_ERROR(S,"Non-zero sample time offsets not allowed.");
    }

    if (inFramebased)
    {
        inSampleTime = sampleTime;
    }
    else /* Sample-based*/
    {
        inSampleTime = (MODULATION == OQPSK) ? (2*sampleTime*numSamp) : (sampleTime*numSamp);
    }

    ssSetInputPortSampleTime(S, INPORT, inSampleTime);
    ssSetInputPortOffsetTime(S, INPORT, 0.0);
}
#endif



#ifdef  MATLAB_MEX_FILE
#include "simulink.c"
#else
#include "cg_sfun.h"
#endif
