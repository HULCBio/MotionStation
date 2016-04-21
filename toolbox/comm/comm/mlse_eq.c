/* 
 * C-mex function. 
 * Calling format: [sigout, storeMetric, storeState, storeInput] 
 *                = mlse_eq(sigin,  
 *                          chcffs, 
 *                          const,	
 *                          tbLen,   
 *                          opmode,   
 *                          nsamp,
 *                          preamble,
 *                          postamble,
 *                          lastProvided,  ("1" : initial TB memory is provided)
 *                          initialStateMetrics,     (length = numStates)
 *                          initialTracebackStates,  (length = tbLen*numStates) 
 *                          initialTracebackInputs)  (length = tbLen*numStates)
 *
 * Copyright 1996-2003 The MathWorks, Inc.
 * $Revision: 1.1.6.1 $  
 * $Date: 2003/07/30 02:47:37 $
 */

#include "mex.h"
#include "math.h"
#include "viterbi_acs_tbdec.h"

enum {SIGIN_ARGC  =  0,         /* input signal                               */
      CHAN_COEFF_ARGC,          /* channel estimates                          */
      CONSTPTS_ARGC,            /* constellation points                       */
      TB_ARGC,                  /* traceback length                           */
      OPMODE_ARGC,              /* operation mode                             */
      SAMP_PER_SYM_ARGC,        /* samples per input symbol                   */
      PREAMBLE_ARGC,            /* preamble                                   */
      POSTAMBLE_ARGC,           /* postamle                                   */
      LAST_PROVIDED_ARGC,       /* indicator for provided traceback memory    */
      LAST_METRIC_ARGC,         /* initial state metrics                      */
      LAST_STATE_ARGC,          /* initial traceback states                   */
      LAST_INPUT_ARGC,          /* initial traceback inputs                   */
      NUM_ARGS};

enum {SIGOUT_ARGC  = 0,     /* equalized signal                               */
      STORE_METRIC_ARGC,    /* final state metrics                            */
      STORE_STATE_ARGC,     /* final TB states of last tbLen trellis branches */
      STORE_INPUT_ARGC};    /* final TB inputs of last tbLen trellis branches */

enum {CONT=1, RST};

#define SIGIN_ARG               (prhs[SIGIN_ARGC])
#define CHAN_COEFF_ARG          (prhs[CHAN_COEFF_ARGC])
#define CONSTPTS_ARG            (prhs[CONSTPTS_ARGC])
#define TB_ARG                  (prhs[TB_ARGC])
#define OPMODE_ARG              (prhs[OPMODE_ARGC])
#define SAMP_PER_SYM_ARG        (prhs[SAMP_PER_SYM_ARGC])
#define PREAMBLE_ARG            (prhs[PREAMBLE_ARGC])
#define POSTAMBLE_ARG           (prhs[POSTAMBLE_ARGC])
#define LAST_PROVIDED_ARG       (prhs[LAST_PROVIDED_ARGC])
#define LAST_METRIC_ARG         (prhs[LAST_METRIC_ARGC])
#define LAST_STATE_ARG          (prhs[LAST_STATE_ARGC])
#define LAST_INPUT_ARG          (prhs[LAST_INPUT_ARGC])

#define SIGOUT_ARG              (plhs[SIGOUT_ARGC])
#define STORE_METRIC_ARG        (plhs[STORE_METRIC_ARGC])
#define STORE_STATE_ARG         (plhs[STORE_STATE_ARGC])
#define STORE_INPUT_ARG         (plhs[STORE_INPUT_ARGC])

/* Real and Imaginary part defined for Complex multiplication */
#define CPLX_MULT_REAL(reA,imA,reB,imB) ((reA*reB)-(imA*imB))
#define CPLX_MULT_IMAG(reA,imA,reB,imB) ((reA*imB)+(imA*reB))

static const char MEM_ALLOCATION_ERROR[]  = "Memory allocation error.";

static void checkParameters(int nlhs,       mxArray *plhs[],
                            int nrhs, const mxArray *prhs[])
{    
     /* checkParameters checks for the number of input and output
      * arguments
      */

    const char  *msg   = NULL;

    /* Check number of parameters */
    if (nrhs != 12)  {
        msg = "Invalid number of input arguments. mlse_eq expects 12 "
              "input arguments.";
        mexErrMsgIdAndTxt("comm:mlse_eq:numInArg",msg);
    }
    if(nlhs > 4){
        msg = "Invalid number of output arguments. mlse_eq expects at "
              "most 4 output argument.";
        mexErrMsgIdAndTxt("comm:mlse_eq:numInArg",msg);
    }


}/* checkParameters */

/* Function: initStateMetric ============================================ */
static void initStateMetric(uint32_T numStates, real_T value, real_T *pStateMet)
{
    /* initStateMetric initializes all the statemetrics to the given input value */
    
    uint32_T indx;

    for(indx = 0 ; indx < numStates ; indx++)
       pStateMet[indx] = value;

}/* end of initStateMetric */


/* Function: rstInitCond ================================================= */
static void rstInitCond(const int_T alpha, 
						int_T chMem,
                        const real_T *preamble,
						int_T lenPreamble, 
						real_T *pStateMet,
                        const int_T tbLen, 
						uint32_T *pTbState,
                        uint32_T *pTbInput,
						uint32_T numStates)
{
    /* rstInitCond resets the statemetrics to the initial value,
     * initializes trecaback input and states to zero. This is
     * required to the decoding starts with the initial values.
     */
    
    int_T     i, limit1;
    uint32_T  j, k, limit2, initState = 0;
    uint32_T  offset    = (uint32_T) pow(alpha,chMem - 1);

    if(lenPreamble <= 0)
    /* Set all state metrics to 0 */
    {
       initStateMetric(numStates, 0.0 , pStateMet);
    }
    else
    /* Map the preamble to state(s) and assign those state
     * metrics to 0. When the length of the preamble is
     * shorter than the channel length, the preamble would
     * map to more than one state and all those states
     * would receive a state metric of 0.
     */
    {
        initStateMetric(numStates, (real_T) MAX_int16_T, pStateMet);

        if(chMem > lenPreamble)
        {
            limit1 = lenPreamble;
            limit2 = (uint32_T) pow(alpha, chMem - lenPreamble);
        }
        else
        {
            limit1 = chMem;
            limit2 = (uint32_T)((chMem>0)?1:0);
            
        }

        /* Computing the starting state(s) from the preamble */
        for(i=0; i < limit1; i++)
        {
            initState+=(uint32_T) preamble[lenPreamble -1 -i] * offset;
            offset   /= alpha;
        }

        for(k=0; k < limit2 +1; k++)
        {
            pStateMet[k + initState] = 0.0;
        }


    } /* end if(pLenPreamble[0]<=0) */

    /* Set traceback memory to zero */
    for(j = 0; j < (numStates*(tbLen + 1)); j++)
    {
        pTbInput[j] = 0;
        pTbState[j] = 0;
    }
} /* end of rstInitCond */


/* Function: expOutputComp ================================== */
static void expOutputComp(const int_T     alpha,
                                int_T     chMem,
                                uint32_T  numStates,
                          const int_T     numSamp,
                          const real_T   *pConstRe,
                          const real_T   *pConstIm,
                          const real_T   *pCtapsRe,
                          const real_T   *pCtapsIm,
                                creal_T  *pExpOutput)
{
    /* expOutputComp computes the expected output when a set of possible
     * signal constellation points are passed through a dispersive channel
     */
    
    /* Expected output is effectively complex multiplication of signal input
     * and channel coefficients.     */
    uint32_T  i, indx1, outIdx;
    int_T     indx2, indx3, sigIdx, chIdx, temp;

    /* Initialize the expected output vectors.*/
    for(i = 0; i < (numStates * alpha * numSamp); i++)
    {
        pExpOutput[i].re = 0.0;
        pExpOutput[i].im = 0.0;
    }

    /* Loop over the sampled channel length */
    for(indx1 = 0; indx1 < numStates*alpha; indx1++)
    {
        temp = indx1;

        /* Loop over the symbol spaced channel memory */
        for(indx2 = 0; indx2 < chMem+1; indx2++)
        {
            sigIdx = temp%alpha;


            /* Loop over all possible(numSamp) symbol spaced channels
             */
            for(indx3 = 0; indx3 < numSamp; indx3++)
            {
                /* Account for oversampling */

                outIdx = indx1 + (numSamp-1 -indx3) * numStates * alpha;
                chIdx  = (chMem+1)*numSamp-1 -indx3 - numSamp*indx2;

               pExpOutput[outIdx].re += CPLX_MULT_REAL(pConstRe[sigIdx], \
                     pConstIm[sigIdx], pCtapsRe[chIdx], pCtapsIm[chIdx]) ;

               pExpOutput[outIdx].im += CPLX_MULT_IMAG(pConstRe[sigIdx], \
                     pConstIm[sigIdx], pCtapsRe[chIdx], pCtapsIm[chIdx]) ;

            } /* end of for(indx3=0; indx3 < numSamp; indx3++) */

            temp /= alpha;

        } /* end of for(indx2=0; indx2<chMem+1; indx2++) */
    } /* end of for(indx1=0; indx1<numStates*alpha; indx1++) */
}  /* end of expOutputComp */


/* Function: MetricReset ================================== */
static void MetricReset(int nlhs,       mxArray *plhs[],
                        int nrhs, const mxArray *prhs[],
                        real_T   *pStateMet,
                        uint32_T *pTbInput,
						uint32_T *pTbState,
						creal_T  *pExpOutput, 
						uint32_T *pNxtStates,
						uint32_T *pOutputs)
{

  /* Resets all metrics */
  
          int_T     chMem, lenPreamble;
		  uint32_T  k, numStates;
	const int_T     alpha    = (int_T)mxGetNumberOfElements(CONSTPTS_ARG);
    const int_T     tbLen    = (int_T)mxGetScalar(TB_ARG);
    const int_T     numSamp  = (int_T)mxGetScalar(SAMP_PER_SYM_ARG);
	const real_T   *pConstRe = mxGetPr(CONSTPTS_ARG);
    const real_T   *pConstIm = mxGetPi(CONSTPTS_ARG);
	const real_T   *pCtapsRe = mxGetPr(CHAN_COEFF_ARG);
    const real_T   *pCtapsIm = mxGetPi(CHAN_COEFF_ARG);
	const real_T   *preamble = mxGetPr(PREAMBLE_ARG);

	chMem = ((int_T)(mxGetNumberOfElements(CHAN_COEFF_ARG)/numSamp) -1);
	numStates = (uint32_T)pow(alpha,chMem);
	lenPreamble = (preamble[0] == -1) ? 0 : mxGetNumberOfElements(PREAMBLE_ARG);


	expOutputComp(alpha, chMem, numStates, numSamp, pConstRe,
                      pConstIm, pCtapsRe, pCtapsIm, pExpOutput);
    

    /* Compute next states and expected outputs for the equalizer trellis */
    for(k=0; k < numStates*alpha; k++)
    {
        pNxtStates[k] = (uint32_T) floor(k/alpha) ;
        pOutputs[k]   = k ;

    }

    rstInitCond(alpha, chMem, preamble, lenPreamble,
                pStateMet, tbLen, pTbState, pTbInput, numStates);
	
	
} /* end of MetricReset */


/* Function: MetricSetup ================================== */
static void MetricSetup(int nlhs,       mxArray *plhs[],
                        int nrhs, const mxArray *prhs[],
                        real_T   *pStateMet,
                        uint32_T *pTbInput,
                        uint32_T *pTbState,
                        real_T   *lastMetric,
                        real_T   *lastInput,
                        real_T   *lastState,
                        creal_T  *pExpOutput,
                        uint32_T *pNxtStates,
						uint32_T *pOutputs)
{

    /* Resets metric with the values provided as input arguments */
    
              int_T chMem, lenPreamble;
		  uint32_T  i, k, numStates;
	const int_T     alpha    = (int_T)mxGetNumberOfElements(CONSTPTS_ARG);
    const int_T     tbLen    = (int_T)mxGetScalar(TB_ARG);
    const int_T     numSamp  = (int_T)mxGetScalar(SAMP_PER_SYM_ARG);
	const real_T   *pConstRe = mxGetPr(CONSTPTS_ARG);
    const real_T   *pConstIm = mxGetPi(CONSTPTS_ARG);
	const real_T   *pCtapsRe = mxGetPr(CHAN_COEFF_ARG);
    const real_T   *pCtapsIm = mxGetPi(CHAN_COEFF_ARG);
	const real_T   *preamble = mxGetPr(PREAMBLE_ARG);

	chMem = ((int_T)(mxGetNumberOfElements(CHAN_COEFF_ARG)/numSamp) -1);
	numStates = (uint32_T)pow(alpha,chMem);
	lenPreamble = (preamble[0] == -1) ? 0 : mxGetNumberOfElements(PREAMBLE_ARG);


	expOutputComp(alpha, chMem, numStates, numSamp, pConstRe,
                      pConstIm, pCtapsRe, pCtapsIm, pExpOutput);
    

    /* Compute next states and expected outputs for the equalizer trellis */
    for(k=0; k < numStates*alpha; k++)
    {
        pNxtStates[k] = (uint32_T) floor(k/alpha) ;
        pOutputs[k]   = k ;

    }


    /*
     * Copy lastMetric over to pStateMet for each state
     */
	{
        for(i = 0; i < numStates ; i++) {
            pStateMet[i] = lastMetric[i];
        }
    }

    /* Set up traceback memory with info from the passed in memory */
    {
        for(i = numStates; i < numStates*((uint32_T) tbLen + 1); i++) {
            
            pTbInput[i] = (uint32_T)lastInput[i-numStates];
            pTbState[i] = (uint32_T)lastState[i-numStates];
        }
    }
} /* end of MetricSetup */


/* Function: outputPreamble =============================== */
static void outputPreamble(const real_T *preamble,
                           int_T        lenPreamble,
                           const real_T *pConstRe,
                           const real_T *pConstIm,
                           real_T      *thisBlockOutRe,
                           real_T      *thisBlockOutIm)
{
    /* Store the preamble in the output vector */
    int_T i, temp;

    /* Save preamble data into the output vector */
    for(i = 0; i < lenPreamble; i++)
    {
        temp = (int_T) preamble[i];
        thisBlockOutRe[i] = pConstRe[temp];
        thisBlockOutIm[i] = pConstIm[temp];
    }
} /* end of outputPreamble */


/* Function: branchMetricComputation ==================================== */
static void branchMetricComp(const int_T  alpha,
                             uint32_T     numStates,
                             const int_T  numSamp,
                             creal_T     *pExpOutput,
                             real_T      *pBMet,
                             real_T     *thisBlockInRe,
                             real_T     *thisBlockInIm)
{
    /* Branch Metric Computation computes the Euclidean distance
     * between the received signal and expected output.
     */
    uint32_T indx1, outIdx;
    int_T    indx2, inIdx;

    /* Loop over all branches */
    for(indx1 = 0; indx1 < numStates*alpha; indx1++)
    {
        pBMet[indx1] = 0.0;     /* Initialize the branch metrics */

        /* Account for Oversampling */
        for(indx2 = 0; indx2 < numSamp; indx2++)
        {
            inIdx = numSamp -1 -indx2;
            outIdx = indx1 + (inIdx)*numStates*alpha;

            pBMet[indx1] +=  \
                pow((thisBlockInRe[inIdx] - pExpOutput[outIdx].re),2) +
                pow((thisBlockInIm[inIdx] - pExpOutput[outIdx].im),2);
        }
    }
}   /* end of branchMetricComputation */

static uint32_T getPostambleState(int_T lenPostamble, int_T ib,
                                  int_T blockSize, int_T alpha,
                                  int_T chMem, const real_T *postamble,
                                  uint32_T minState)
{
    /* getPostambleState computes the state represented by the postamble */

    if (lenPostamble > 0 && ib == blockSize - 1)
    {
        int_T    i, limit1;
        uint32_T finState = 0;
        uint32_T offset   = (uint32_T) pow(alpha, chMem-1) ;

        if (chMem > lenPostamble)
        {
            limit1 = lenPostamble;
        }
        else
        {
            limit1 = chMem;
        }

        /* Computing the ending state from the postamble */
        for(i=0; i< limit1; i++)
        {
            finState += (uint32_T) postamble[lenPostamble -1 -i]\
                         *offset;
            offset   /= alpha;
        }

        minState = finState;

    }

    return minState;

} /* end of getPostambleState */


/* Function: mlseEqualize =============================== */
static void mlseEqualize(int nlhs,       mxArray *plhs[],
                          int nrhs, const mxArray *prhs[])
{
    /* mlseEqualize performs Maximum Likelihood Sequence Estimation
     * on input signal dispersed by channel. This function initializes
     * the metrics, stores the preamble, performs branch metric computation,
     * ACS and traceback decoding
     */
     
    /* Get inputs */
    const int_T     alpha    = (int_T)mxGetNumberOfElements(CONSTPTS_ARG);
    const int_T     tbLen    = (int_T)mxGetScalar(TB_ARG);
	const int_T     opmode   = (int_T)mxGetScalar(OPMODE_ARG);
    const int_T     numSamp  = (int_T)mxGetScalar(SAMP_PER_SYM_ARG);

	const real_T   *pConstRe  = mxGetPr(CONSTPTS_ARG);
    const real_T   *pConstIm  = mxGetPi(CONSTPTS_ARG);
	const real_T   *pCtapsRe  = mxGetPr(CHAN_COEFF_ARG);
    const real_T   *pCtapsIm  = mxGetPi(CHAN_COEFF_ARG);
	const real_T   *preamble  = mxGetPr(PREAMBLE_ARG);

	/* Compute channel memory and number of states for the viterbi algorithm */
	int_T chMem = ((int_T)(mxGetNumberOfElements(CHAN_COEFF_ARG)/numSamp) -1);
	int_T lenPreamble = (preamble[0] == -1) ? 0 : mxGetNumberOfElements(PREAMBLE_ARG);
	uint32_T numStates = (uint32_T)pow(alpha,chMem);    

   	boolean_T  lastprovided  = (boolean_T)(mxGetScalar(LAST_PROVIDED_ARG));
	boolean_T  isContMode    = (boolean_T)(opmode == CONT);

    /* Compute number of symbols in input stream */
    int_T      blockSize     = (int_T)(mxGetN(SIGIN_ARG)/numSamp) - lenPreamble;

    /* 
     * Memory allocation : arrays for storing branch metrics, most-update state metrics,
     * and traceback memory.
     */
    real_T      *pBMet      = (real_T*)(mxCalloc(numStates*alpha,sizeof(real_T)));
    real_T      *pStateMet  = (real_T*)(mxCalloc(numStates,sizeof(real_T)));
	real_T      *pTempMet   = (real_T*)(mxCalloc(numStates,sizeof(real_T)));   /* temp metric for pStateMet */    
	uint32_T    *pTbState   = (uint32_T *)(mxCalloc(numStates*(tbLen+1),sizeof(uint32_T)));
	uint32_T    *pTbInput   = (uint32_T *)(mxCalloc(numStates*(tbLen+1),sizeof(uint32_T)));
    int_T       *pTbPtr     = (int32_T *)(mxCalloc(1,sizeof(int32_T)));
	creal_T     *pExpOutput = (creal_T *)(mxCalloc(numStates*alpha*numSamp,sizeof(creal_T)));
	uint32_T    *pNxtStates = (uint32_T *)(mxCalloc(numStates*alpha,sizeof(uint32_T)));
	uint32_T    *pOutputs   = (uint32_T *)(mxCalloc(numStates*alpha,sizeof(uint32_T)));

    /* Initialize variables */
    real_T     *thisBlockOutRe, *thisBlockOutIm, *outRe, *outIm, *pStoreMetric, *pStoreState, *pStoreInput;
    int_T      ib, indx1, tbWorkStore, tbWorkLastTb;
    uint32_T   currstate, minState, minStateLastTb;
    
    /* Memory limits for numStates */
    uint32_T        limit1      = (uint32_T)(pow(2, 16)-1);
    uint32_T        limit2      = (uint32_T)(pow(2, 20)-1);

    const char *msg         = NULL;
    
    /* Memory allocation of outputs */
	SIGOUT_ARG  = mxCreateDoubleMatrix(1,blockSize +lenPreamble,mxCOMPLEX);
  	outRe        = mxGetPr(SIGOUT_ARG);
    outIm        = mxGetPi(SIGOUT_ARG);
    pStoreMetric = mxGetPr(STORE_METRIC_ARG = mxCreateDoubleMatrix(1,numStates,mxREAL));
    pStoreState  = (real_T*)(mxGetPr(STORE_STATE_ARG = mxCreateDoubleMatrix(numStates,tbLen,mxREAL)));
    pStoreInput  = (real_T*)(mxGetPr(STORE_INPUT_ARG = mxCreateDoubleMatrix(numStates,tbLen,mxREAL)));
	
    /* Memory Limitation error / warnings when channel is specified via port */
    if(numStates > limit1) 
    {
        if( numStates > limit2 )
        {
            
            mexErrMsgIdAndTxt("comm:mlse_eq:outOfMemory",
                           "MLSE Equalizer block parameter "
                           "settings describe a trellis with more "
                           "than 2^20 states leading to memory "
                           "allocation failure.");
        }
        else
        {
            mexWarnMsgIdAndTxt("comm:mlse_eq:warnMemAllocation",
                            "MLSE Equalizer parameter settings "
                            "create a trellis with more than 2^16 "
                            "states." );
        }

    }
    
    /* Verify memory allocation for temporary and output arrays */
    if(SIGOUT_ARG == NULL)
	{
        msg = MEM_ALLOCATION_ERROR;
        goto EXIT_POINT;
    }

    if(STORE_METRIC_ARG == NULL)
	{
        msg = MEM_ALLOCATION_ERROR;
        goto EXIT_POINT;
    }

    if(STORE_STATE_ARG == NULL)
	{
        msg = MEM_ALLOCATION_ERROR;
        goto EXIT_POINT;
    }

    if(STORE_INPUT_ARG == NULL)
	{
        msg = MEM_ALLOCATION_ERROR;
        goto EXIT_POINT;
    }

    /* Verify memory allocation for local arrays*/
    if(pBMet == NULL)
	{
        msg = MEM_ALLOCATION_ERROR;
        goto EXIT_POINT;
    }

    if(pStateMet == NULL)
	{
        msg = MEM_ALLOCATION_ERROR;
        goto EXIT_POINT;
    }

	if(pTempMet == NULL)
	{
        msg = MEM_ALLOCATION_ERROR;
        goto EXIT_POINT;
    }

    if(pTbState == NULL)
	{
        msg = MEM_ALLOCATION_ERROR;
        goto EXIT_POINT;
    }

	if(pTbInput == NULL)
	{
        msg = MEM_ALLOCATION_ERROR;
        goto EXIT_POINT;
    }

	if(pTbPtr == NULL)
	{
        msg = MEM_ALLOCATION_ERROR;
        goto EXIT_POINT;
    }
    
	if(pExpOutput == NULL)
	{
        msg = MEM_ALLOCATION_ERROR;
        goto EXIT_POINT;
    }

	if(pNxtStates == NULL)
	{
        msg = MEM_ALLOCATION_ERROR;
        goto EXIT_POINT;
    }

	if(pOutputs == NULL)
	{
        msg = MEM_ALLOCATION_ERROR;
        goto EXIT_POINT;
    }

    /* 
     * INITIAL state metrics and traceback results set-up
     */
    
    if(lastprovided)
	{
        /* CONT mode with initial memory provided */
        real_T     *lastMetric  = mxGetPr(LAST_METRIC_ARG);
        real_T     *lastState   = mxGetPr(LAST_STATE_ARG);
        real_T     *lastInput   = mxGetPr(LAST_INPUT_ARG);

        MetricSetup(nlhs,plhs,nrhs,prhs,
                    pStateMet,pTbInput,pTbState,lastMetric,lastInput,lastState,pExpOutput,pNxtStates,pOutputs);

    }
	else
	{  /* CONT mode with initial memory not provided
		* OR RST mode
		*/
        MetricReset(nlhs,plhs,nrhs,prhs,pStateMet,pTbInput,pTbState,pExpOutput,pNxtStates,pOutputs);
    }
    
	/* Store the preamble for RST mode */
	thisBlockOutRe = outRe;
	thisBlockOutIm = outIm;
    outputPreamble(preamble, lenPreamble, pConstRe, pConstIm,
                   thisBlockOutRe,thisBlockOutIm);

    /*
     * Loop through input signal
     */
    for(ib = 0; ib < blockSize; ++ib)
	{

        int_T    input, outOffset;
        int_T    inOffset = ib*numSamp;

        const real_T *postamble    = mxGetPr(POSTAMBLE_ARG);
        int_T         lenPostamble = (postamble[0] == -1) ? 0 : mxGetNumberOfElements(POSTAMBLE_ARG);

        real_T  *sigInRe = mxGetPr(SIGIN_ARG);
        real_T  *sigInIm = mxGetPi(SIGIN_ARG);        
        real_T  *thisBlockInRe = sigInRe  + inOffset + lenPreamble*numSamp;
        real_T  *thisBlockInIm = sigInIm  + inOffset + lenPreamble*numSamp;

        if(isContMode)
        {
            /* CONTINUOUS mode */
            outOffset        = ib + lenPreamble;
        }
        else
        {   /* RESET EVERY FRAME mode
             *
             * Skip output indexing by (blockSize - tbLen) blocks.
             * Compute metrics and TB tables but do no decoding for
             * the blocks until the end of output buffer
             */
            outOffset         = ((ib - tbLen + lenPreamble)%blockSize);
         }

        /* Branch Metric Computation */
        branchMetricComp(alpha, numStates, numSamp, pExpOutput,
                         pBMet, thisBlockInRe, thisBlockInIm);


        /* Add, Compare and Select - State metric update */
        minState = addCompareSelect(numStates, pTempMet, alpha,
                                    pBMet, pStateMet, pTbState,
                                    pTbInput, pTbPtr, pNxtStates, pOutputs);

        /* Initialize postamble state */
        minState = getPostambleState(lenPostamble, ib, blockSize, alpha, chMem, postamble, minState);

		/* Traceback Decoding */
        input = tracebackDecoding(pTbPtr, minState, tbLen, pTbInput,
                                  pTbState, numStates);

		/* Index into the constellation points array
         * and output constellation points 
         */
        if((isContMode) || (ib >= tbLen ))
        {
            real_T *thisBlockOutRe = outRe + outOffset;
            real_T *thisBlockOutIm = outIm + outOffset;
            thisBlockOutRe[0] = pConstRe[input];
            thisBlockOutIm[0] = pConstIm[input];
        }

		/*  Save state metrics to pStoreMetric */
        if(ib == blockSize-1)
		{
            for(currstate=0; currstate<numStates; currstate++) 
			{
                pStoreMetric[currstate] = pStateMet[currstate];
            }
        }
   
       
    }   /* end of blockSize loop */

	/*
     * Capture starting minState and starting tbwork of the
     * last loop
     */
    minStateLastTb = minState;
    tbWorkLastTb   = (pTbPtr[0]!=0) ? pTbPtr[0]-1 : tbLen;
	tbWorkStore    = tbWorkLastTb;

    /*
     * RESET mode :
     *
     * Fill the last tbLen output blocks using the same traceback
     * path, working our way back from the very last block.
     */
	if(!isContMode)
    {
        int_T indx1, input;
		real_T *thisBlockOutRe, *thisBlockOutIm ;

        for (indx1 = 0 ; indx1 < tbLen; indx1 ++)
        {
            input = pTbInput[minStateLastTb+\
                                  (tbWorkLastTb*numStates)];

            /* Extract the outputs from the traceback and
             * minState information stored
             */
            thisBlockOutRe = outRe + lenPreamble + \
                               (blockSize -1 -indx1);
            thisBlockOutIm = outIm + lenPreamble + \
                               (blockSize -1 -indx1);
                               
            thisBlockOutRe[0] = pConstRe[input];
            thisBlockOutIm[0] = pConstIm[input];

            /* Get the minState and traceback information for
             * previous time instant
             */
            minStateLastTb = pTbState[minStateLastTb + \
                                     (tbWorkLastTb*numStates)];
            tbWorkLastTb    = (tbWorkLastTb > 0) ? tbWorkLastTb-1: tbLen;
         }
    }

	
    /* 
     * Get pStoreInput and pStoreState
     */  

    /* walking horizontally, i.e. through branches */
    for(indx1=0; indx1<tbLen; indx1++) 
	{ 
        /* walking vertically */
        for(currstate=0; currstate<numStates; currstate++)
		{  
            
            pStoreInput[currstate+(tbLen-1-indx1)*numStates] 
             = pTbInput[currstate+(tbWorkStore*numStates)];

            pStoreState[currstate+(tbLen-1-indx1)*numStates] 
             = pTbState[currstate+(tbWorkStore*numStates)];
        }

        tbWorkStore = (tbWorkStore > 0) ? tbWorkStore-1 : tbLen;
    }


EXIT_POINT:
/* Free memeory allocated to temporary arrays */
mxFree(pBMet);
mxFree(pTempMet);
mxFree(pStateMet);
mxFree(pTbInput);
mxFree(pTbState);
mxFree(pTbPtr);
mxFree(pExpOutput);
mxFree(pNxtStates);
mxFree(pOutputs);

    if(msg != NULL)
	{
        mexErrMsgIdAndTxt("comm:mlse_eq:outOfMemory",msg);
    }

} /* end of mlseEqualize */


/* Function: mexFunction =======================================================
 * Abstract: Check the parameters, if there is any problem, reports an error.
 *           Otherwise, equalize the input signal.
 * 
 */
void mexFunction(int nlhs,       mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{
    checkParameters(nlhs, plhs, nrhs, prhs);
    mlseEqualize  (nlhs, plhs, nrhs, prhs);

} /* end of mexFunction */