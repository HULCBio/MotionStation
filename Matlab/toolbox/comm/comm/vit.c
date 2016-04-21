/* 
 * C-mex function. 
 * Calling format: [decoded, storemetric, storestate, storeinput] 
 *                = vit(Code,  (length = n * number of codewords)
 *                  Trellis : k,
 *                  Trellis : n,
 *                  Trellis : number of states,	
 *                  Trellis : output matrix, 
 *                  Trellis : next state matrix,
 *                  Decision type,	
 *                  Number of soft decision bits, 
 *                  Traceback depth,   
 *                  Operation mode,   
 *                  Last provided,  ("1" : initial TB memory is provided)
 *                  Initial state metrics     (length = num_states)
 *                  Initial traceback states  (length = tblen*num_states) 
 *                  Initial traceback inputs  (length = tblen*num_states) 
 *
 * Copyright 1996-2002 The MathWorks, Inc.
 * Author : Katherine Kwong
 * $Revision: 1.7 $  
 * $Date: 2002/03/27 00:04:24 $
 */

#include "mex.h"
#include "math.h"

enum {CODE_ARGC  =  0,          /* input code                                 */
      TRELLIS_U_NUMBITS_ARGC,   /* number of input bits, k                    */
      TRELLIS_C_NUMBITS_ARGC,   /* number of output bits, n                   */
      TRELLIS_NUM_STATES_ARGC,  /* number of states                           */
      TRELLIS_OUTPUT_ARGC,      /* output matrix (decimal)                    */
      TRELLIS_NEXT_STATE_ARGC,  /* next state matrix                          */
      TB_ARGC,                  /* traceback depth                            */
      OPMODE_ARGC,              /* operation mode                             */
      DECTYPE_ARGC,             /* decision type                              */
      SDEC_ARGC,                /* number of soft decision bits               */
      LAST_PROVIDED_ARGC,       /* indicator for provided traceback memory    */
      LAST_METRIC_ARGC,         /* initial state metrics                      */
      LAST_STATE_ARGC,          /* initial traceback states                   */
      LAST_INPUT_ARGC,          /* initial traceback inputs                   */
      NUM_ARGS};

enum {DECODED_ARGC  = 0,    /* decoded message                                */
      STORE_METRIC_ARGC,    /* final state metrics                            */
      STORE_STATE_ARGC,     /* final TB states of last tblen trellis branches */
      STORE_INPUT_ARGC};    /* final TB inputs of last tblen trellis branches */

enum {UNQUANT=1, HARD_DEC, SOFT_DEC};
enum {CONT=1, TRUNC, TERM};

#define CODE_ARG                (prhs[CODE_ARGC])
#define TRELLIS_U_NUMBITS_ARG   (prhs[TRELLIS_U_NUMBITS_ARGC])
#define TRELLIS_C_NUMBITS_ARG   (prhs[TRELLIS_C_NUMBITS_ARGC])
#define TRELLIS_NUM_STATES_ARG  (prhs[TRELLIS_NUM_STATES_ARGC])
#define TRELLIS_OUTPUT_ARG      (prhs[TRELLIS_OUTPUT_ARGC])
#define TRELLIS_NEXT_STATE_ARG  (prhs[TRELLIS_NEXT_STATE_ARGC])
#define TB_ARG                  (prhs[TB_ARGC])
#define OPMODE_ARG              (prhs[OPMODE_ARGC])
#define DECTYPE_ARG             (prhs[DECTYPE_ARGC])
#define SDEC_ARG                (prhs[SDEC_ARGC])
#define LAST_PROVIDED_ARG       (prhs[LAST_PROVIDED_ARGC])
#define LAST_METRIC_ARG         (prhs[LAST_METRIC_ARGC])
#define LAST_STATE_ARG          (prhs[LAST_STATE_ARGC])
#define LAST_INPUT_ARG          (prhs[LAST_INPUT_ARGC])

#define DECODED_ARG             (plhs[DECODED_ARGC])
#define STORE_METRIC_ARG        (plhs[STORE_METRIC_ARGC])
#define STORE_STATE_ARG         (plhs[STORE_STATE_ARGC])
#define STORE_INPUT_ARG         (plhs[STORE_INPUT_ARGC])


static const char MEM_ALLOCATION_ERROR[]  = "Memory allocation error.";

static void CheckParameters(int nlhs,       mxArray *plhs[],
                            int nrhs, const mxArray *prhs[])
{
    int_T   cNumBits   = (int_T)mxGetScalar(TRELLIS_C_NUMBITS_ARG);
    const char  *msg   = NULL;

    /* Check number of parameters */
    if (!(nrhs == 14))  {
        msg = "Invalid number of input arguments. vit expects 14 "
              "input arguments.";
        goto EXIT_POINT;
    }
    if(nlhs > 4){
        msg = "Invalid number of output arguments. vit expects at "
              "most 4 output argument.";
        goto EXIT_POINT;
    }

EXIT_POINT:
    if(msg != NULL){
        mexErrMsgTxt(msg);
    }

}/* CheckParameters */


static void MetricReset(int nlhs,       mxArray *plhs[],
                        int nrhs, const mxArray *prhs[],
                        real_T *pstatemet,
                        real_T *ptbinput,   real_T *ptbstate)
{
    int_T   num_states   = (int_T)mxGetScalar(TRELLIS_NUM_STATES_ARG);
    int_T   tblen        = (int_T)(mxGetScalar(TB_ARG));
    int_T   i;

    /*
     * Set state metric for all-zero state equal to zero
     * and all other state metrics equal to MAX_int16_T
     */
	{
        pstatemet[0] = 0;
        for(i = 1; i <num_states ; i++) {
            pstatemet[i] = (real_T) MAX_int16_T;
        }
    }

    /* Set traceback memory to zero */
	{
		for(i = 0; i < num_states*((int_T) tblen + 1); i++) {
            ptbinput[i] = 0;
            ptbstate[i] = 0;
        }
    }
}

static void MetricSetup(int nlhs,       mxArray *plhs[],
                        int nrhs, const mxArray *prhs[],
                        real_T *pstatemet,
                        real_T *ptbinput,   real_T *ptbstate,
                        real_T *lastMetric,
                        real_T *lastInput,  real_T *lastState)
{
    int_T   num_states   = (int_T)mxGetScalar(TRELLIS_NUM_STATES_ARG);
    int_T   tblen        = (int_T)(mxGetScalar(TB_ARG));
    int_T   i;

    /*
     * Copy lastMetric over to pstatemet for each state
     */
	{
        for(i = 0; i <num_states ; i++) {
            pstatemet[i] = lastMetric[i];
        }
    }

    /* Set up traceback memory with info from the passed in memory */
    {
        for(i = num_states; i < num_states*((int_T) tblen + 1); i++) {
            /* We use the info from a previous call 
             * to start filling from the _2nd_ column because :
             * during the 1st-time filling in mdlOutputs below, 
             * ptbptr[0] = 0 and hence it will fill these 2 arrays
             * starting from first column.
             * Total columns filled here = tblen columns.
             */

            ptbinput[i] = lastInput[i-num_states];
            ptbstate[i] = lastState[i-num_states];
        }
    }
}

static void ViterbiDecode(int nlhs,       mxArray *plhs[],
                          int nrhs, const mxArray *prhs[])
{
    /* Get inputs */
    int_T      k             = (int_T)mxGetScalar(TRELLIS_U_NUMBITS_ARG);
    int_T      n             = (int_T)mxGetScalar(TRELLIS_C_NUMBITS_ARG);
    int_T      num_states    = (int_T)mxGetScalar(TRELLIS_NUM_STATES_ARG);
    real_T     *pencout      = mxGetPr(TRELLIS_OUTPUT_ARG);
    real_T     *pnxtst       = mxGetPr(TRELLIS_NEXT_STATE_ARG);
    
    real_T     *in           = mxGetPr(CODE_ARG);
    int_T      dectype       = (int_T)(mxGetScalar(DECTYPE_ARG));
    int8_T     nsdec         = (int8_T)(mxGetScalar(SDEC_ARG));
    int_T      tblen         = (int_T)(mxGetScalar(TB_ARG));
    int_T      opmode        = (int_T)(mxGetScalar(OPMODE_ARG));

    boolean_T  lastprovided  = (boolean_T)(mxGetScalar(LAST_PROVIDED_ARG));

    /* Compute number of symbols in input stream */
    int_T      blockSize     = (int_T)(mxGetN(CODE_ARG)/n);

    /* Memory allocation of outputs */
    real_T     *out          = mxGetPr(DECODED_ARG = mxCreateDoubleMatrix(1,blockSize*k,mxREAL));
    real_T     *pstoremetric = mxGetPr(STORE_METRIC_ARG = mxCreateDoubleMatrix(1,num_states,mxREAL));
    real_T     *pstorestate  = (real_T*)(mxGetPr(STORE_STATE_ARG = mxCreateDoubleMatrix(num_states,tblen,mxREAL)));
    real_T     *pstoreinput  = (real_T*)(mxGetPr(STORE_INPUT_ARG = mxCreateDoubleMatrix(num_states,tblen,mxREAL)));

    /* 
     * Memory allocation : arrays for storing branch metrics, most-update state metrics,
     * and traceback memory.
     */
    real_T      *pbmet      = (real_T*)(mxCalloc(1<<n,sizeof(real_T)));
    real_T      *ptempmet   = (real_T*)(mxCalloc(num_states,sizeof(real_T)));   /* temp metric for pstatemet */
    real_T      *pstatemet  = (real_T*)(mxCalloc(num_states,sizeof(real_T)));
    real_T      *ptbinput   = (real_T*)(mxCalloc(num_states*(tblen+1),sizeof(real_T)));
    real_T      *ptbstate   = (real_T*)(mxCalloc(num_states*(tblen+1),sizeof(real_T)));

    int_T       *ptbptr     = (int_T *)(mxCalloc(1,sizeof(int_T)));

    /* Pointers for current input and output symbols */
    real_T     *thisBlockIn ;
    real_T     *thisBlockOut;
    int_T      ib;

    int_T      indx1; 
    int_T      currstate;
    int_T      minstate;
    int_T      minstateLastTB;
    int_T      tbworkStore,tbworkLastTB;

    const char *msg         = NULL;

    
    /* Verify memory allocation for output arrays */
    if(DECODED_ARG == NULL){
        msg = MEM_ALLOCATION_ERROR;
        goto EXIT_POINT;
    }

    if(STORE_METRIC_ARG == NULL){
        msg = MEM_ALLOCATION_ERROR;
        goto EXIT_POINT;
    }

    if(STORE_STATE_ARG == NULL){
        msg = MEM_ALLOCATION_ERROR;
        goto EXIT_POINT;
    }

    if(STORE_INPUT_ARG == NULL){
        msg = MEM_ALLOCATION_ERROR;
        goto EXIT_POINT;
    }

    /* Verify memory allocation for local arrays*/
    if(pbmet == NULL){
        msg = MEM_ALLOCATION_ERROR;
        goto EXIT_POINT;
    }

    if(ptempmet == NULL){
        msg = MEM_ALLOCATION_ERROR;
        goto EXIT_POINT;
    }

    if(pstatemet == NULL){
        msg = MEM_ALLOCATION_ERROR;
        goto EXIT_POINT;
    }

    if(ptbinput == NULL){
        msg = MEM_ALLOCATION_ERROR;
        goto EXIT_POINT;
    }

    if(ptbstate == NULL){
        msg = MEM_ALLOCATION_ERROR;
        goto EXIT_POINT;
    }


    /* 
     * INITIAL state metrics and traceback results set-up
     */

    if(opmode == CONT){     
        if(lastprovided){
            /* CONT mode with initial memory provided */
            real_T     *lastMetric  = mxGetPr(LAST_METRIC_ARG);
            real_T     *lastState   = mxGetPr(LAST_STATE_ARG);
            real_T     *lastInput   = mxGetPr(LAST_INPUT_ARG);

            MetricSetup(nlhs,plhs,nrhs,prhs,
                        pstatemet,ptbinput,ptbstate,lastMetric,lastInput,lastState);

        }else{  /* CONT mode with initial memory provided */
            MetricReset(nlhs,plhs,nrhs,prhs,pstatemet,ptbinput,ptbstate);
        }

    }else{  
        /* TRUNC or TERM modes */
        MetricReset(nlhs,plhs,nrhs,prhs,pstatemet,ptbinput,ptbstate);
    }

    /*
     * Branch metric computation 
     */

    /* Set number of soft decision bits */
    if(dectype == 3){
        nsdec = (int8_T) mxGetScalar(SDEC_ARG);
    } else if(dectype == 2) {
        /*  Set number of soft decisions = 1 for hard decision decoding */
        nsdec = 1; 
    } /* else, nsdec is unused */

    /*
     * Loop through all codewords
     */
    for(ib = 0; ib < blockSize; ++ib){
        int    cOffset       = ib  * n;
        int    uOffset;
        real_T renorm        = (real_T) MAX_int16_T;

        if(opmode == CONT){   /* CONTINUOUS mode */
            uOffset   = ib  * k;
        }else{  /* TRUNCATED or TERMINATED modes */
            /* 
             * Skip the first (blockSize - tblen) blocks.
             * Fill up to the end and come back to the first block.
             */
            uOffset   = ((ib - tblen)%blockSize)*k;
        }

        thisBlockIn  = in  + cOffset;
        thisBlockOut = out + uOffset;

        for(indx1=0; indx1<(1<<n); indx1++) {

            int32_T temp = indx1;
            int32_T indx2;

            pbmet[indx1] = 0.0;

            if(dectype == UNQUANT) {       /* Unquantized inputs */
                for(indx2=0; indx2<n; indx2++) {
                    if(temp&01 == 1) {
                        /* logical 1 maps to -1.0 */
                        pbmet[indx1] += pow((thisBlockIn[n-1-indx2] + 1.0),2); 
                    }else {
                        /* logical 0 maps to +1.0 */
                        pbmet[indx1] += pow((thisBlockIn[n-1-indx2] - 1.0),2); 
                    }
                    temp >>= 1;
                }

            }else{                /* Quantized inputs : hard or soft decision */

                for(indx2=0; indx2<n; indx2++) {
                    if(temp&01 == 1) {
                        pbmet[indx1] += ((1<<nsdec)-1) - thisBlockIn[n-1-indx2];
                    } else {
                        pbmet[indx1] += thisBlockIn[n-1-indx2];
                    }
                    temp >>= 1;
                }
            }
        }

        /*
         * State metric update (ACS)
         */

        for(indx1=0; indx1<num_states; indx1++) {
            /* 
             * Set the temporary state metrics for each of
             * ending states equal to the maximum value 
             */
            ptempmet[indx1] = (real_T) MAX_int16_T;
        }


        for(currstate=0; currstate<num_states; currstate++) {
            int_T currinput;

            for(currinput=0; currinput<(1<<k); currinput++) {
                /*
                 * For each state and for every possible input:
                 *
                 *    look up the next state, 
                 *    look up the associated output,
                 *    look up the current branch metric for that output
                 *    look up the starting state metric (currmetric)
                 */

                int     offset       = currinput*num_states+currstate;
                int32_T nextstate    = (int32_T)pnxtst[offset];
                int32_T curroutput   = (int32_T)pencout[offset];
                real_T  branchmetric = pbmet[curroutput];
                real_T  currmetric   = pstatemet[currstate];

                /*
                 * Now, perform the Add-Compare-Select procedure:
                 *   Add the branch metric to the starting state metric
                 *   Compare the sum with the best (so far) temporary metric 
                 *   for the ending state.
                 *   If the sum is less, the following steps consitute 
                 *   the select procedure:
                 *       - replace the temporary metric with the sum
                 *       - set the current state as the traceback path 
                 *         from the ending state at this level
                 *       - set the current input as the decoder output
                 *         associated with this traceback path
                 * For speed, we also update the renorm value (the minimum ending
                 * state metric) in this loop
                 */
            
                if(currmetric+branchmetric < ptempmet[nextstate]) {
                    ptempmet[nextstate]                        = currmetric+branchmetric;
                    ptbstate[nextstate+(ptbptr[0]*num_states)] = currstate;
                    ptbinput[nextstate+(ptbptr[0]*num_states)] = currinput;
                    if(ptempmet[nextstate] < renorm) {
                        renorm = ptempmet[nextstate];
                    }
                }
            }
        }

        /*
         * Update (and renormalize) state metrics, then find 
         * minimum metric state for start of traceback
         */

        for(currstate=0; currstate<num_states; currstate++) {
            pstatemet[currstate] = ptempmet[currstate] - renorm;
            if(pstatemet[currstate] == 0) {
                minstate = currstate;
            }
        }

        /* 
         * Get pstoremetric
         */
        if(ib == blockSize-1){
            for(currstate=0; currstate<num_states; currstate++) {
                pstoremetric[currstate] = pstatemet[currstate];
            }
        }


        /* 
         * TERMINATED mode :
         * Start the final traceback path at the zero state for teminated mode 
         */
        if (opmode == TERM && ib == blockSize - 1){		
            minstate = 0;					
        }

        /*
         * Traceback decoding
         */
        {    
            int_T tbwork = ptbptr[0];
            int_T input;
            /*
             * Starting at the minimum metric state at the current
             * time in the traceback array:
             *     - determine the input leading to that state
             *     - follow the most likely path back to the previous
             *       state by updating the value of minstate
             *     - adjust the traceback index value mod tblen
             * Repeat this tblen+1 (for current level) times to complete
             * the traceback
             */

            minstateLastTB = minstate;	/* capture starting minstate */
            tbworkStore = tbwork;		/* capture starting tbwork */
            tbworkLastTB = tbwork;

            /* 
             * For TRUNC or TERM mode, don't do traceback for first tblen times
             */
            if(opmode == CONT || ib >= tblen) {

                for(indx1=0; indx1<tblen+1; indx1++) {
                    input    = (int_T)(ptbinput[minstate+(tbwork*num_states)]);
                    minstate = (int_T)(ptbstate[minstate+(tbwork*num_states)]);
                    tbwork = (tbwork > 0) ? tbwork-1 : tblen;
                }

                /*
                 * Set the output decoded value bit by bit from the 
                 * input associated with the most likely path through
                 * the trellis at time tblen prior to the current time
                 */

                for(indx1=0; indx1<k; indx1++) {
                    thisBlockOut[k-1-indx1] = input&01;
                    input >>= 1;
                }
            }

            /*
             * Increment (mod tblen) the traceback index and store
             */

            ptbptr[0] = (ptbptr[0] < tblen) ? ptbptr[0]+1 : 0;

        }   /* end of Traceback decoding section  */
    }   /* end of blockSize loop */


    /* 
     * Truncated or Teminated mode :
     *
     * Fill the last (blockSize - tblen) output blocks using the same TB path :
     *   Work our way back from the very last block.
     */
    if(opmode == TRUNC || opmode == TERM){

        int_T input;
        int_T indx2;

        for (indx1 = 0; indx1 < tblen; indx1 ++)
        {
            thisBlockOut = out + (blockSize-1-indx1)*k;
            input = (int_T)(ptbinput[minstateLastTB+(tbworkLastTB*num_states)]);

            for (indx2=0; indx2<k; indx2++) {
                thisBlockOut[k-1-indx2] = input&01;		
                input >>= 1;
            }
            minstateLastTB 
                = (int_T)(ptbstate[minstateLastTB+(tbworkLastTB*num_states)]);
            tbworkLastTB 
                = (tbworkLastTB > 0) ? tbworkLastTB-1 : tblen;
        }
    }  

    /* 
     * Get pstoreinput and pstorestate
     */  

    /* walking horizontally, i.e. through branches */
    for(indx1=0; indx1<tblen; indx1++) { 
        /* walking vertically */
        for(currstate=0; currstate<num_states; currstate++){  
            
            pstoreinput[currstate+(tblen-1-indx1)*num_states] 
             = ptbinput[currstate+(tbworkStore*num_states)];

            pstorestate[currstate+(tblen-1-indx1)*num_states] 
             = ptbstate[currstate+(tbworkStore*num_states)];
        }
        tbworkStore = (tbworkStore > 0) ? tbworkStore-1 : tblen;
    }


EXIT_POINT:

mxFree(pbmet);
mxFree(ptempmet);
mxFree(pstatemet);
mxFree(ptbinput);
mxFree(ptbstate);
mxFree(ptbptr);

    if(msg != NULL){
        mexErrMsgTxt(msg);
    }
}

/* Function: mexFunction =======================================================
 * Abstract: Check the parameters, if there is any problem, report an error.
 *           Otherwise, Decode the input code.
 * 
 */
void mexFunction(int nlhs,       mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{
    CheckParameters(nlhs, plhs, nrhs, prhs);
    ViterbiDecode  (nlhs, plhs, nrhs, prhs);
}

