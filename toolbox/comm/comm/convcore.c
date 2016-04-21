/*
 * C-mex function.
 * Calling format: 
 *  code = convcore(msg,               (length = k * num of msg symbols)
 *                  k, 
 *                  n,   
 *                  number of states, 
 *                  output matrix,     (num_states * 2^k elements)
 *                  next state matrix, (num_states * 2^k elements)
 *                  Initialstate       
 * 
 * Copyright 1996-2002 The MathWorks, Inc.
 * $Revision: 1.5 $  
 * $Date: 2002/03/27 00:06:40 $
 */
 
#include "mex.h"

enum {U_ARGC                   = 0, /* input code */
      TRELLIS_U_NUMBITS_ARGC,       /* number of input bits    */
      TRELLIS_C_NUMBITS_ARGC,       /* number of output bits   */
      TRELLIS_NUM_STATES_ARGC,      /* number of states        */
      TRELLIS_OUTPUT_ARGC,          /* output matrix (decimal) */
      TRELLIS_NEXT_STATE_ARGC,      /* next state matrix       */
      INITSTATE_ARGC,
      NUM_ARGS};

#define U_ARG                   (prhs[U_ARGC])
#define TRELLIS_U_NUMBITS_ARG   (prhs[TRELLIS_U_NUMBITS_ARGC])
#define TRELLIS_C_NUMBITS_ARG   (prhs[TRELLIS_C_NUMBITS_ARGC])
#define TRELLIS_NUM_STATES_ARG  (prhs[TRELLIS_NUM_STATES_ARGC])
#define TRELLIS_OUTPUT_ARG      (prhs[TRELLIS_OUTPUT_ARGC])
#define TRELLIS_NEXT_STATE_ARG  (prhs[TRELLIS_NEXT_STATE_ARGC])
#define INITSTATE_ARG           (prhs[INITSTATE_ARGC])

#define CODE_ARG                (plhs[0])
#define FINALSTATE_ARG          (plhs[1])

static const char MEM_ALLOCATION_ERROR[]  = "Memory allocation error.";

static void CheckParameters(int nlhs,       mxArray *plhs[],
                            int nrhs, const mxArray *prhs[])
{
    int_T   uNumBits   = (int_T)mxGetScalar(TRELLIS_U_NUMBITS_ARG);
    const char  *msg   = NULL;

    /* Check number of parameters */
    if (!(nrhs == 7)) {
        msg = "Invalid number of input arguments. convcore expects 7 "
              "input arguments.";
        goto EXIT_POINT;
    }
    if(nlhs > 2){
        msg = "Invalid number of output arguments. convcore expects at "
              "most two output arguments.";
        goto EXIT_POINT;
    }


EXIT_POINT:
    if(msg != NULL){
        mexErrMsgTxt(msg);
    }

}/* CheckParameters */


static void SetInitialState(int nlhs,       mxArray *plhs[],
                            int nrhs, const mxArray *prhs[], 
                            real_T *currState, 
                            real_T thisState)
{
    currState[0] = thisState;
}

static void ConvEncode(int nlhs,       mxArray *plhs[],
                       int nrhs, const mxArray *prhs[])
{
    int_T      uNumBits   = (int_T)mxGetScalar(TRELLIS_U_NUMBITS_ARG);
    int_T      cNumBits   = (int_T)mxGetScalar(TRELLIS_C_NUMBITS_ARG);
    int_T      numStates  = (int_T)mxGetScalar(TRELLIS_NUM_STATES_ARG);
    real_T     *output    = mxGetPr(TRELLIS_OUTPUT_ARG);
    real_T     *nextState = mxGetPr(TRELLIS_NEXT_STATE_ARG);
    
    int_T      blockSize  = (int_T)(mxGetN(U_ARG)/uNumBits);

    real_T     *in        = mxGetPr(U_ARG);
    real_T     initState  = (real_T)mxGetScalar(INITSTATE_ARG);
    
    real_T     *out       = mxGetPr(CODE_ARG 
                             = mxCreateDoubleMatrix(1,blockSize*cNumBits,mxREAL));
    real_T     *currState = mxGetPr(FINALSTATE_ARG 
                             = mxCreateDoubleMatrix(1,1,mxREAL));

    real_T     *thisBlockIn ;
    real_T     *thisBlockOut;
    int_T      ib;

    const char *msg         = NULL;

    /* Verify memory allocation */
    if(currState == NULL){
        msg = MEM_ALLOCATION_ERROR;
        goto EXIT_POINT;
    }

    if(CODE_ARG == NULL){
        msg = MEM_ALLOCATION_ERROR;
        goto EXIT_POINT;
    }


    /* Set up initial state */
    SetInitialState(nlhs, plhs, nrhs, prhs, currState, initState);

    /* Loop through each input symbol word */
    for(ib = 0; ib < blockSize; ++ib){
        int_T    uOffset       = ib  * uNumBits;
        int_T    cOffset       = ib  * cNumBits;
        int_T    inIdx = 0;
        int_T    tmp;
        int_T    ub,cb;

        thisBlockIn  = in  + uOffset;
        thisBlockOut = out + cOffset;

        /* Convert groups of binary input bits to decimal */
        for(ub = 0; ub < uNumBits ; ++ub){  /* ub-th input(u) bits */
            inIdx += ((int_T)(thisBlockIn[ub]) << (uNumBits-ub-1));
        }

        tmp = (int_T)(output[(int_T)currState[0]+(numStates*inIdx)]);
        currState[0] = nextState[(int_T)currState[0]+(numStates*inIdx)];
        
        for(cb = 0; cb < cNumBits ; ++cb){  /* ub-th input(c) bits */
            thisBlockOut[cNumBits - cb - 1] = (tmp & 01);
            tmp >>= 1;
        }
    }

EXIT_POINT:
    if(msg != NULL){
        mexErrMsgTxt(msg);
    }
}

/* Function: mexFunction =======================================================
 * Abstract: Check the parameters, if there is any problem, report an error.
 *           Otherwise, convolutionally encode the input message,
 *           with an initial state and a reset signal if provided.
 *
 */
 
void mexFunction(int nlhs,       mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{
    CheckParameters(nlhs, plhs, nrhs, prhs);
    ConvEncode     (nlhs, plhs, nrhs, prhs);
}


