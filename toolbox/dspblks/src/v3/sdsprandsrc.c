/*
 * SDSPRANDSRC DSP Blockset S-Function to generate uniform and gaussian random numbers.
 *
 *   
 *  Copyright 1995-2002 The MathWorks, Inc.
 *  $Revision: 1.16 $  $Date: 2002/04/14 20:42:45 $
 */

#define S_FUNCTION_LEVEL 2 
#define S_FUNCTION_NAME  sdsprandsrc

#include "dsp_sim.h"

enum {NUM_INPORTS=0};
enum {OUTPORT=0, NUM_OUTPORTS};

enum {RAND_SEED=0, NUM_DWORK};
enum {SRC_TYPE_ARGC=0, MIN_ARGC, MAX_ARGC, MEAN_ARGC, VARIANCE_ARGC, SEED_ARGC, 
         INHERIT_ARGC, MODE_ARGC,  SAMP_TIME_ARGC, FRAME_ARGC, OUTPUT_TYPE_ARGC,NUM_PARAMS};

enum {UNIFORM_MODE=1, GAUSSIAN_MODE};
enum {CONTINUOUS_MODE=1, DISCRETE_MODE};
enum {REAL_OUT=1, COMPLEX_OUT};

#define SRC_TYPE_ARG    (ssGetSFcnParam(S, SRC_TYPE_ARGC))
#define MIN_ARG         (ssGetSFcnParam(S, MIN_ARGC))
#define MAX_ARG         (ssGetSFcnParam(S, MAX_ARGC))
#define MEAN_ARG        (ssGetSFcnParam(S, MEAN_ARGC))
#define VARIANCE_ARG    (ssGetSFcnParam(S, VARIANCE_ARGC))
#define SEED_ARG        (ssGetSFcnParam(S, SEED_ARGC))
#define INHERIT_ARG     (ssGetSFcnParam(S, INHERIT_ARGC))
#define MODE_ARG        (ssGetSFcnParam(S, MODE_ARGC))
#define SAMP_TIME_ARG   (ssGetSFcnParam(S, SAMP_TIME_ARGC))
#define FRAME_ARG       (ssGetSFcnParam(S, FRAME_ARGC))
#define OUTPUT_TYPE_ARG (ssGetSFcnParam(S, OUTPUT_TYPE_ARGC))

#define IS_DISCRETE     (mxGetPr(MODE_ARG)[0] == DISCRETE_MODE)
#define IS_UNIFORM      (mxGetPr(SRC_TYPE_ARG)[0] == UNIFORM_MODE)
#define IS_GAUSSIAN     (mxGetPr(SRC_TYPE_ARG)[0] == GAUSSIAN_MODE)
#define INHERIT_OFF     (mxGetPr(INHERIT_ARG)[0] == 0.0)

/* Function: InitializeSeed
 *  Bit-shift the given initial seed
 */
void InitializeSeed(uint32_T *urandSeed, real_T initSeed)
{
    const uint32_T MAXSEED = 2147483646;   /* 2^31-2 */
    const uint32_T SEED0   = 1144108930;   /* Seed #6, starting from seed = 1 */
    const uint32_T BIT16   = 32768;        /* 2^15   */
    int_T r, t;

    *urandSeed = (uint32_T)initSeed;

    /* Interchange bits 1-15 and 17-31 */
    r = *urandSeed >> 16;
    t = *urandSeed & BIT16;
    *urandSeed = ((*urandSeed - (r << 16) - t) << 16) + t + r;

    if (*urandSeed < 1) {
        *urandSeed = SEED0;
    } else if (*urandSeed > MAXSEED) {
        *urandSeed = MAXSEED;
    }
}


/* Function: Urand
 *  Uniform random number generator (random number between 0 and 1)
 */
double Urand(uint32_T *seed) 	/* pointer to a running seed */
{
const uint32_T IA = 16807;                 /* magic multiplier = 7^5 */
const uint32_T IM = 2147483647;		   /* modulus = 2^31-1	     */  
const uint32_T IQ = 127773;		   /* IM div IA	             */
const uint32_T IR = 2836;		   /* IM modulo IA	     */
const real_T   S  = 4.656612875245797e-10; /* reciprocal of 2^31-1   */

    uint32_T hi   = *seed / IQ;
    uint32_T lo   = *seed % IQ;
    int32_T  test = IA * lo - IR * hi;	/* never overflows */

    *seed = ((test < 0) ? (unsigned int)(test + IM) : (unsigned int)test);

    return ((double) ((*seed) * S));

} /* end Urand */


/* Function: NormalRand 
 *  Normal (Gaussian) random number generator also known as mlUrandn in 
 *  MATLAB V4.
 */
double NormalRand(unsigned int *seed)
{
    double sr, si, t;
    
    do {
	sr = 2.0 * Urand(seed) - 1.0;
	si = 2.0 * Urand(seed) - 1.0;
	t  = sr * sr + si * si;
    } while (t > 1.0);

    return(sr * sqrt((-2.0 * log(t)) / t));
} /* end NormalRand */


/* Function: DetermineChannels
 *  Determine the number of channels .
 */
static int_T DetermineChannels(SimStruct *S,int_T seedLen)
{
    int_T nchans;

    if (IS_UNIFORM) {
        const int_T minLen    = mxGetNumberOfElements(MIN_ARG);
        const int_T maxLen    = mxGetNumberOfElements(MAX_ARG);
        /* Number of channels == the longest parameter length */
        nchans = MAX(MAX(minLen,maxLen),seedLen); 
    }else {
        const int_T meanLen = mxGetNumberOfElements(MEAN_ARG);
        const int_T varLen  = mxGetNumberOfElements(VARIANCE_ARG);
        /* Number of channels == the longest parameter length */
        nchans = MAX(MAX(meanLen,varLen),seedLen); 
    }

    return(nchans);
}


#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S) 
{
    if (IS_UNIFORM) {

        if (!IS_VECTOR_DOUBLE(MIN_ARG)) {
            THROW_ERROR(S, "Minimum must be a real vector.");
        }

        if (!IS_VECTOR_DOUBLE(MAX_ARG)) {
            THROW_ERROR(S, "Maximum must be a real vector.");
        }
    } else {
        /* Gaussian Case:  Mean can be complex */
        if ( ( !IS_VECTOR(MEAN_ARG) ) || mxIsSparse(MEAN_ARG) || ( !mxIsDouble(MEAN_ARG) ) ) {
            THROW_ERROR(S, "Mean must be a real vector.");
        }

        if (!IS_VECTOR_DOUBLE(VARIANCE_ARG)) {
            THROW_ERROR(S, "Variance must be a real vector.");
        }
    }

    if (OK_TO_CHECK_VAR(S, SEED_ARG)) {
        if (!IS_VECTOR_DOUBLE(SEED_ARG)) {
            THROW_ERROR(S, "Initial Seed must be a real vector.");
        }
    }

    /* We've checked that the Min, Max, Mean, Variance, and Initial Seed
     * are scalars or vectors.  Now check that all lengths are commensurate:
     */
    if (IS_UNIFORM) {
        const int_T  minLen    = mxGetNumberOfElements(MIN_ARG);
        const int_T  maxLen    = mxGetNumberOfElements(MAX_ARG);
        const int_T  seedLen   = mxGetNumberOfElements(SEED_ARG);
        real_T      *pMin      = mxGetPr(MIN_ARG);
        real_T      *pMax      = mxGetPr(MAX_ARG);
        int_T        MinMaxLen = MAX(minLen,maxLen);
        int_T        i;

        if (OK_TO_CHECK_VAR(S, SEED_ARG)     &&
            ( ((minLen != 1)  && ((maxLen  != 1) && (minLen != maxLen ) ||
                                  (seedLen != 1) && (minLen != seedLen)))
              ||
            ( (minLen == 1) && ((maxLen !=1) && (seedLen != 1) && (maxLen != seedLen)) ) 
            )) {
            THROW_ERROR(S, "Minimum, Maximum, and Initial Seed vectors must be the same length if non-scalar.");
        }

        /* Check that the minimum value is always less than the maximum */
        if (IS_UNIFORM) {
            for(i=0;i<MinMaxLen;i++) {
                if(*pMin >= *pMax) {
                     THROW_ERROR(S,"Minimum value must be less than the maximum.");
                } else {
                    if(minLen > 1) pMin++;
                    if(maxLen > 1) pMax++;
                }
            }
        }   
    } else {
        const int_T  meanLen    = mxGetNumberOfElements(MEAN_ARG);
        const int_T  varLen     = mxGetNumberOfElements(VARIANCE_ARG);
        const int_T  seedLen    = mxGetNumberOfElements(SEED_ARG);
        real_T      *pMean      = mxGetPr(MEAN_ARG);
        real_T      *pVar       = mxGetPr(VARIANCE_ARG);

        if (OK_TO_CHECK_VAR(S, SEED_ARG)     &&
            ( ((meanLen != 1)  && ((meanLen  != 1) && (meanLen != meanLen ) ||
                                  (seedLen != 1) && (meanLen != seedLen)))
              ||
            ( (meanLen == 1) && ((meanLen !=1) && (seedLen != 1) && (meanLen != seedLen)) ) 
            )) {
            THROW_ERROR(S, "Mean, Variance, and Initial Seed vectors must be the same length if non-scalar.");
        }
    }

    /* Source type */
    if (!IS_FLINT_IN_RANGE(SRC_TYPE_ARG,1,2)) {
        THROW_ERROR(S,"Source type must be a Uniform (1) or Gaussian (2).");
    }

    /* Sample Mode */
    if (!IS_FLINT_IN_RANGE(MODE_ARG,1,2)) {
        THROW_ERROR(S,"Sample mode must be Continuous (1) or Discrete (2).");
    }
    
    /* Inherit Mode */
    if (!IS_FLINT_IN_RANGE(INHERIT_ARG, 0, 1)) {
        THROW_ERROR(S, "Inherit mode can be only 0 (specify) or 1 (inherit).");
    }

    if (INHERIT_OFF) {
        /* Make sure Mean is real if Real output complexity */
        if (IS_GAUSSIAN && mxIsComplex(MEAN_ARG) &&
            (int_T)mxGetPr(OUTPUT_TYPE_ARG)[0] == REAL_OUT) {
                    THROW_ERROR(S, "Mean must be real when output complexity is real.");
        }

        /* Sample time: */
        if (OK_TO_CHECK_VAR(S, SAMP_TIME_ARG)) {
            if (!IS_SCALAR(SAMP_TIME_ARG) || mxIsComplex(SAMP_TIME_ARG) ||
                (mxGetPr(SAMP_TIME_ARG) [0] <= 0.0)) {
                THROW_ERROR(S, "The sample time must be a positive scalar > 0.");
            }
        }

        /* Samples per frame: */
        if (IS_DISCRETE && !IS_FLINT_GE(FRAME_ARG,1)) {
           THROW_ERROR(S, "The number of samples per frame must be an integer value > 0.");
        }  

        /* Output complexity */
        if (!IS_FLINT_IN_RANGE(OUTPUT_TYPE_ARG,1,2)) {
            THROW_ERROR(S,"Output complexity must be Real (1) or Complex (2).");
        } 
    }
}
#endif

static void mdlInitializeSizes(SimStruct *S) 
{ 
    int_T seedLen;

    ssSetNumSFcnParams(S,  NUM_PARAMS); 
#if defined(MATLAB_MEX_FILE) 
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) return;
    mdlCheckParameters(S);
    if (ssGetErrorStatus(S) != NULL) return; 
#endif 

    seedLen = (int_T)mxGetNumberOfElements(SEED_ARG);

    ssSetSFcnParamNotTunable(S, SRC_TYPE_ARGC);
    ssSetSFcnParamNotTunable(S, INHERIT_ARGC);
    if (seedLen == 1) ssSetSFcnParamNotTunable(S, SEED_ARGC); 
    ssSetSFcnParamNotTunable(S, MODE_ARGC);
    ssSetSFcnParamNotTunable(S, SAMP_TIME_ARGC);
    ssSetSFcnParamNotTunable(S, FRAME_ARGC);
    ssSetSFcnParamNotTunable(S, OUTPUT_TYPE_ARGC);

    if(IS_UNIFORM) {
        ssSetSFcnParamNotTunable(S, MEAN_ARGC);
        ssSetSFcnParamNotTunable(S, VARIANCE_ARGC);
    } else {
        ssSetSFcnParamNotTunable(S, MIN_ARGC);
        ssSetSFcnParamNotTunable(S, MAX_ARGC);
    }

    /* Inputs: */
    if (!ssSetNumInputPorts(S, NUM_INPORTS)) return;

     /* Output: */
    if (!ssSetNumOutputPorts(S,NUM_OUTPORTS)) return;
    {
        int_T owdith = DYNAMICALLY_SIZED;
        int_T osig = COMPLEX_INHERITED;

        if (INHERIT_OFF) {
            const int_T frameSize     = (IS_DISCRETE) ? (int_T)mxGetPr(FRAME_ARG)[0] : 1;
            boolean_T   isOutputCmplx = (boolean_T)(mxGetPr(OUTPUT_TYPE_ARG)[0] == COMPLEX_OUT);
            int_T       nchans        = DetermineChannels(S,seedLen);

            owdith = nchans*frameSize;
            osig = (isOutputCmplx) ? COMPLEX_YES : COMPLEX_NO;
    
        }
        ssSetOutputPortWidth(        S, OUTPORT, owdith);
        ssSetOutputPortComplexSignal(S, OUTPORT, osig);
    }
    ssSetOutputPortReusable(S, OUTPORT, 1);
    
    if(!ssSetNumDWork(      S, DYNAMICALLY_SIZED)) return;

    ssSetNumSampleTimes(S, 1);
    ssSetOptions(       S, SS_OPTION_EXCEPTION_FREE_CODE |
                        SS_OPTION_USE_TLC_WITH_ACCELERATOR);
}


static void mdlInitializeSampleTimes(SimStruct *S) 
{ 
    if (INHERIT_OFF) {
        const real_T Ts        = mxGetPr(SAMP_TIME_ARG)[0];
        const int_T  frameSize = (IS_DISCRETE) ? (int_T)mxGetPr(FRAME_ARG)[0] : 1;
        const int_T  seedLen   = mxGetNumberOfElements(SEED_ARG);
        const int_T  nchans    = DetermineChannels(S,seedLen);

        ssSetSampleTime(S, 0, IS_DISCRETE ? Ts*frameSize : 0.0);
        ssSetOffsetTime(S, 0, IS_DISCRETE ? 0.0 : FIXED_IN_MINOR_STEP_OFFSET);
    } else {
     
        ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
        ssSetOffsetTime(S, 0, 0.0);
    }
} 


#define MDL_START
static void mdlStart(SimStruct *S)
{
    boolean_T isOutputCmplx = (boolean_T)(ssGetOutputPortComplexSignal(S, OUTPORT)==COMPLEX_YES);
    real_T   *pSeed         = mxGetPr(SEED_ARG);
    int_T     seedLen       = mxGetNumberOfElements(SEED_ARG);
    int_T     nchans        = DetermineChannels(S,seedLen);
    int_T     i;

    if (isOutputCmplx) {
        
        cuint32_T *urandSeed = (cuint32_T *)ssGetDWork(S,RAND_SEED);
        real_T     seedVal   = pSeed[0];  /* Get first value in case of scalar seed */

        for (i = 0; i < nchans; i++) {
            /* For the complex part of the signal, take the seed for the 
             * real part and increase it by one.  The real seed is determined
             * as defined in large comment below 
             */
            if (seedLen>1) seedVal = pSeed[i];  /* Get next value in case of vector seed */

            InitializeSeed(&(urandSeed->re), seedVal);
            InitializeSeed(&(urandSeed->im), seedVal+1);

            urandSeed++;   

            /* The user given seed is for the Real part of the output signal.
             * If there are multiple channels and only one seed is given, 
             * increase the given seed by 2 for each successive channel.  
             * If multiple seeds are given, use them respectively for the 
             * real part of each channel 
             */
            if (seedLen==1) seedVal+=2;  /* incr value in case of scalar seed */
        }
    } else {
        
        uint32_T *urandSeed = (uint32_T *)ssGetDWork(S,RAND_SEED);
        real_T    seedVal   = pSeed[0];  /* Get first value in case of scalar seed */
        
        for (i=0;i<nchans;i++) {
            if (seedLen>1) seedVal = pSeed[i];  /* Get next value in case of vector seed */

            InitializeSeed(urandSeed++,seedVal); 
            
            /* The user given seed is for the Real part of the output signal.
             * If there are multiple channels and only one seed is given, 
             * increase the given seed by 2 for each successive channel.  
             * If multiple seeds are given, use them respectively for the 
             * real part of each channel 
             */
            if (seedLen==1) seedVal+=2;
        }
    }
} 

 
static void mdlOutputs(SimStruct *S, int_T tid) 
{ 
    int_T         seedLen       = mxGetNumberOfElements(SEED_ARG);
    const int_T   nchans        = DetermineChannels(S,seedLen);
    const int_T   minLen        = mxGetNumberOfElements(MIN_ARG);
    const int_T   maxLen        = mxGetNumberOfElements(MAX_ARG);
    const int_T   meanLen       = mxGetNumberOfElements(MEAN_ARG);
    const int_T   varLen        = mxGetNumberOfElements(VARIANCE_ARG);
    boolean_T     isOutputCmplx = (boolean_T)(ssGetOutputPortComplexSignal(S, OUTPORT)==COMPLEX_YES);
    real_T       *pMin          = mxGetPr(MIN_ARG);
    real_T       *pMax          = mxGetPr(MAX_ARG);
    real_T       *pMean_re      = mxGetPr(MEAN_ARG);
    real_T       *pMean_im      = mxGetPi(MEAN_ARG);
    real_T       *pVar          = mxGetPr(VARIANCE_ARG);
    int_T         frameSize;
    int_T         i,j;

    if (INHERIT_OFF) {
        frameSize = (IS_DISCRETE) ? (int_T)mxGetPr(FRAME_ARG)[0] : 1;
    } else {
        frameSize = ssGetOutputPortWidth(S, OUTPORT)/nchans;
    }

    if (isOutputCmplx) {
        cuint32_T  *urandSeed     = (cuint32_T *)ssGetDWork(S,RAND_SEED);
        creal_T    *y             = (creal_T *)ssGetOutputPortSignal(S,OUTPORT);
        boolean_T   isComplexMean = mxIsComplex(MEAN_ARG);

        for (i=0;i<nchans;i++) { 
            real_T scale = (IS_UNIFORM) ? (*pMax - *pMin) : sqrt(*pVar/2);

            if (IS_UNIFORM) {
                if (IS_DISCRETE) {
                    for (j=0;j<frameSize;j++) {
                         y->re    = Urand(&(urandSeed->re)) * scale + *pMin;
                        (y++)->im = Urand(&(urandSeed->im)) * scale + *pMin;
                    }
                } else {
                    y->re    = Urand(&(urandSeed->re)) * scale + *pMin;
                    (y++)->im = Urand(&(urandSeed->im)) * scale + *pMin;
                }
                if (maxLen > 1) pMax++;
                if (minLen > 1) pMin++;

            } else {
                const real_T Mean_Complex = (isComplexMean) ? *pMean_im : 0.0;
                
                if (IS_DISCRETE) {
                    for (j=0;j<frameSize;j++) {
                        /* Real and Imag variance are sqrt of half of given value */
                        y->re     = NormalRand(&(urandSeed->re)) * scale + *pMean_re;
                        (y++)->im = NormalRand(&(urandSeed->im)) * scale + Mean_Complex;
                    }
                } else {
                    y->re     = NormalRand(&(urandSeed->re)) * scale + *pMean_re;
                    (y++)->im = NormalRand(&(urandSeed->im)) * scale + Mean_Complex;
                }
                if (varLen  > 1) pVar++;
                if (meanLen > 1) {
                    pMean_re++;
                    if (isComplexMean) pMean_im++;
                }
            }
            urandSeed++;    /* Update seed for each channel */
        }

    } else {   /* Real Output */    
        uint32_T *urandSeed = (uint32_T *)ssGetDWork(S,RAND_SEED);
        real_T   *y         = (real_T *)ssGetOutputPortSignal(S,OUTPORT);

        for (i=0;i<nchans;i++) { 
            real_T scale = (IS_UNIFORM) ? (*pMax - *pMin) : sqrt(*pVar);

            if (IS_UNIFORM) { 
                if (IS_DISCRETE) {
                    for (j=0;j<frameSize;j++) {              
                        *y++ = Urand(urandSeed) * scale + *pMin;
                    }
                } else {
                    *y++ = Urand(urandSeed) * scale + *pMin;
                }
                if (maxLen > 1) pMax++;
                if (minLen > 1) pMin++;
                
            } else {
                if (IS_DISCRETE) {
                    for (j=0;j<frameSize;j++) { 
                        *y++ = NormalRand(urandSeed) * scale + *pMean_re;
                    }
                } else {
                    *y++ = NormalRand(urandSeed) * scale + *pMean_re;
                }
                if (varLen  > 1) pVar++;
                if (meanLen > 1) pMean_re++;
            }        
            urandSeed++;  /* Update seed for each channel */
        }
    }
} 
  

static void mdlTerminate(SimStruct *S) 
{ 
} 


#if defined(MATLAB_MEX_FILE)
# define MDL_SET_INPUT_PORT_WIDTH
static void mdlSetInputPortWidth(SimStruct *S, int_T port,
                                 int_T inputPortWidth)
{
    THROW_ERROR(S, "Port width propagation failed.  No input port widths for source blocks.");
}


# define MDL_SET_OUTPUT_PORT_WIDTH
static void mdlSetOutputPortWidth(SimStruct *S, int_T port,
                                  int_T outputPortWidth)
{
    if (INHERIT_OFF) {
        THROW_ERROR(S, "Invalid call to output port width propagation.");
    }

    {
        int_T seedLen = (int_T)mxGetNumberOfElements(SEED_ARG);
        int_T nchans  = DetermineChannels(S,seedLen);

        if (outputPortWidth%nchans != 0) {
            THROW_ERROR(S, "Output port width must divide evenly by the number of channels.");
        }

        if (!IS_DISCRETE && outputPortWidth/nchans != 1) {
            THROW_ERROR(S, "Output port width divided by the number of channels must equal 1 in Continuous Sample mode.");
        }

        ssSetOutputPortWidth(S, OUTPORT, outputPortWidth);  
    }
}

#endif


#define MDL_SET_INPUT_PORT_COMPLEX_SIGNAL
static void mdlSetInputPortComplexSignal(SimStruct *S, int_T portIdx,
                                         CSignal_T      iPortComplexSignal)
{
    THROW_ERROR(S, "No input signals for source blocks.");
}


#define MDL_SET_OUTPUT_PORT_COMPLEX_SIGNAL
static void mdlSetOutputPortComplexSignal(SimStruct *S, int_T portIdx, 
                                          CSignal_T oPortComplexSignal)
{
    if (INHERIT_OFF) {
        THROW_ERROR(S, "Invalid call to output port complex signal propagation.");
    }

    if (portIdx != OUTPORT) {
        THROW_ERROR(S, "Invalid port index for data complexity propagation.");
    }

    /* oPortComplexSignal == 0 is true when the signal is Real */
    if (IS_GAUSSIAN && mxIsComplex(MEAN_ARG) && oPortComplexSignal == 0) {
        THROW_ERROR(S, "Mean must be real when output complexity is real.");
    }
    ssSetOutputPortComplexSignal(S,portIdx,oPortComplexSignal);
}

#if defined(MATLAB_MEX_FILE)
#define MDL_SET_WORK_WIDTHS
static void mdlSetWorkWidths(SimStruct *S)
{
    /* Defer setting DWork until now so that output port complexity is known */
    int_T seedLen = (int_T)mxGetNumberOfElements(SEED_ARG);
    int_T nchans  = DetermineChannels(S,seedLen);
    
    ssSetNumDWork(          S, NUM_DWORK);
    ssSetDWorkWidth(        S, RAND_SEED, nchans); 
    ssSetDWorkName(         S, RAND_SEED, "RAND_SEED");
    ssSetDWorkDataType(     S, RAND_SEED, SS_UINT32);
    ssSetDWorkComplexSignal(S, RAND_SEED, ssGetOutputPortComplexSignal(S,OUTPORT));
}
#endif


#if defined(MATLAB_MEX_FILE) || defined(NRT)
#define MDL_RTW
static void mdlRTW(SimStruct *S)
{  
    const int_T seedLen       = mxGetNumberOfElements(SEED_ARG);
    boolean_T   isOutputCmplx = (boolean_T)(ssGetOutputPortComplexSignal(S, OUTPORT)==COMPLEX_YES);
    real_T     *initSeed      = mxGetPr(SEED_ARG);
    int_T       nchans        = DetermineChannels(S,seedLen); 
    real_T      FrameSize;

    char *SrcTypeStr        = IS_UNIFORM     ? "Uniform" : "Gaussian";
    char *OutputTypeStr     = isOutputCmplx  ? "Complex" : "Real";
    char *SeedIsTuneStr     = (seedLen == 1) ? "No"      : "Yes";
    char *isDiscreteStr     = IS_DISCRETE    ? "Yes"     : "No";

    if (INHERIT_OFF) {
        FrameSize = (IS_DISCRETE) ? mxGetPr(FRAME_ARG)[0] : 1;
    } else {
        FrameSize = ssGetOutputPortWidth(S, OUTPORT)/nchans;
    }

    /* Non-tunable parameters */
    if (seedLen == 1) {
        if (!ssWriteRTWParamSettings(S, 6,
            SSWRITE_VALUE_VECT, "InitSeed",   initSeed, seedLen,
            SSWRITE_VALUE_NUM,  "FrameSize",  FrameSize,
            SSWRITE_VALUE_QSTR, "SrcType",    SrcTypeStr,
            SSWRITE_VALUE_QSTR, "OutputType", OutputTypeStr,
            SSWRITE_VALUE_QSTR, "SeedIsTune", SeedIsTuneStr,
            SSWRITE_VALUE_QSTR, "IsDiscrete", isDiscreteStr
            )) {
            return;
        }
    } else {
        if (!ssWriteRTWParamSettings(S, 5,
            SSWRITE_VALUE_NUM,  "FrameSize",  FrameSize,
            SSWRITE_VALUE_QSTR, "SrcType",    SrcTypeStr,
            SSWRITE_VALUE_QSTR, "OutputType", OutputTypeStr,
            SSWRITE_VALUE_QSTR, "SeedIsTune", SeedIsTuneStr,
            SSWRITE_VALUE_QSTR, "IsDiscrete", isDiscreteStr
            )) {
            return;
        }
    }
    /* Tunable parameters. */
    if (IS_UNIFORM) {
        const int_T  minLen = mxGetNumberOfElements(MIN_ARG);
        const int_T  maxLen = mxGetNumberOfElements(MAX_ARG);
        real_T      *pMin   = mxGetPr(MIN_ARG);
        real_T      *pMax   = mxGetPr(MAX_ARG);
        
        if (seedLen == 1) {
            if (!ssWriteRTWParameters(S,2,
                SSWRITE_VALUE_VECT, "Min", "", pMin, minLen,
                SSWRITE_VALUE_VECT, "Max", "", pMax, maxLen
                )) {
                return; 
            }
        } else {
            if (!ssWriteRTWParameters(S,3,
                SSWRITE_VALUE_VECT, "Min", "", pMin, minLen,
                SSWRITE_VALUE_VECT, "Max", "", pMax, maxLen,
                SSWRITE_VALUE_VECT, "InitSeed", "", initSeed, seedLen
                )) {
                return; 
            }
        }

    } else {
        const int_T meanLen  = mxGetNumberOfElements(MEAN_ARG);
        const int_T varLen   = mxGetNumberOfElements(VARIANCE_ARG);
        real_T     *pMean_re = mxGetPr(MEAN_ARG);
        real_T     *pMean_im = mxGetPi(MEAN_ARG);   /* If MEAN_ARG is real, returns a NULL */
        real_T     *pVar     = mxGetPr(VARIANCE_ARG);

        if (seedLen == 1) {
            if (!ssWriteRTWParameters(S,2,
                SSWRITE_VALUE_DTYPE_ML_VECT, "Mean", "", 
                                     pMean_re, pMean_im,
                                     meanLen,
                                     DTINFO(SS_DOUBLE, mxIsComplex(MEAN_ARG)),
                SSWRITE_VALUE_VECT, "Variance", "", pVar, varLen
                )) {
                return; 
            } 
        } else {
            if (!ssWriteRTWParameters(S,3,
                SSWRITE_VALUE_DTYPE_ML_VECT, "Mean", "", 
                                     pMean_re, pMean_im,
                                     meanLen,
                                     DTINFO(SS_DOUBLE, mxIsComplex(MEAN_ARG)),
                SSWRITE_VALUE_VECT, "Variance", "", pVar, varLen,
                SSWRITE_VALUE_VECT, "InitSeed", "", initSeed, seedLen
                )) {
                return; 
            } 
        }
    }
}
#endif


#ifdef	MATLAB_MEX_FILE
#include "simulink.c"
#else
#include "cg_sfun.h"
#endif

/* [EOF] sdsprandsrc.c */
