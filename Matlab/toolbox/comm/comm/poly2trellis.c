/* 
 * C-mex function. 
 * Calling format: trellis = poly2trellis(Constraint length,
 *                                        Code generators,
 *                                        Feedback connections(not required))
 * 
 * Copyright 1996-2003 The MathWorks, Inc.
 * $Revision: 1.5.4.2 $  
 * $Date: 2004/04/12 23:00:55 $
 */

#include "mex.h"
#include "comoctal.h"

enum {MEM_ARGC=0, GEN_ARGC, FPOL_ARGC, NUM_ARGS};
enum {FFWD=1, FBACK};

#define MEM_ARG     (prhs[0])
#define GEN_ARG     (prhs[1])
#define FPOL_ARG    (prhs[2])

static const char MEM_ALLOCATION_ERROR[]  = "Memory allocation error.";

/* Function: CheckParameters ===================================================
 * Abstract: This functions checks the input and output parameters.
 *  - Number of inputs : nrhs = 2 or 3
 *  - Number ot outputs: nlhs = 1
 * See comments for more information.
 */
static void CheckParameters(int nlhs,       mxArray *plhs[],
                            int nrhs, const mxArray *prhs[])
{
    const char  *msg   = NULL;
    const int_T fbflag = (nrhs == 2) ? FFWD : FBACK;
    
    /* Check number of parameters */
    if (!(nrhs == 2 || nrhs == 3)) {
        msg = "Invalid number of input arguments. poly2trellis expects two or "
              "three input arguments.";
        goto EXIT_POINT;
    }
    
    if(nlhs > 1){
        msg = "Invalid number of output arguments. poly2trellis expects at "
              "most one output argument.";
        goto EXIT_POINT;
    }

    /* Check the input parameters */
    {
        int num = (fbflag == FFWD) ? 2 : 3;
        int i;

        for(i = 0; i < num; ++i){
            if (!mxIsNumeric(prhs[i]) ||  mxIsComplex(prhs[i]) || 
                mxIsSparse(prhs[i])   || !mxIsDouble(prhs[i])  ||
                mxIsStruct(prhs[i])   ||  mxIsCell(prhs[i])    || 
                mxIsEmpty(prhs[i])) {
                msg = "Input arguments must be nonempty real matrices.";
                goto EXIT_POINT;
            }
        }
    }
    {
        /*  Check the parameters to make sure that they are ok. */
        
        int8_T  k       = mxGetM(GEN_ARG);
        int8_T  n       = mxGetN(GEN_ARG);
        real_T  *mlen   = mxGetPr(MEM_ARG);
        real_T  *gparm  = mxGetPr(GEN_ARG);
        
        int16_T  indx1, indx2; 
        int32_T work1;
        

        /* Check to make sure that constraint length vector has k elements */
        if(k != mxGetNumberOfElements(MEM_ARG)) {
            msg = "Size of constraint length vector does not "
                  "match generator matrix."; 
            goto EXIT_POINT; 
        }
        
        /* Check that all generator elements are valid octal numbers */
        for (indx1 = 0; indx1 < mxGetNumberOfElements(GEN_ARG); indx1++) {
            if(!IsValidOctalNumber(gparm[indx1])) {
                msg = "Generator matrix contains a non-octal number.";
                goto EXIT_POINT;
            }
        }
        if (fbflag == FBACK) {
            real_T *fparm = mxGetPr(FPOL_ARG);

            /* Check to make sure that feedback vector has k elements */
            if(k != mxGetNumberOfElements(FPOL_ARG)) {
                msg = "Size of feedback vector does not match "
                    "generator matrix."; 
                goto EXIT_POINT; 
            } 

            /* Check that all feedback elements are valid octal numbers */
            for (indx1 = 0; indx1 < k; indx1++) { 
                if(!IsValidOctalNumber(fparm[indx1])) {
                    msg = "Feedback vector contains a non-octal number.";
                    goto EXIT_POINT;
                }
            }
        }

        /*
         * Check to make sure that generator specifies a code
         * of the proper constraint length.
         *
         * For each of the k constraint length values there is a 
         * corresponding row of the generator matrix.  For each row of
         * the generator matrix we need to check that:
         *
         * FEEDFORWARD:
         * - a1. at least one entry has a one in the LSB position
         * - a2. at least one entry has a one in the MSB position, where the
         *       MSB position is defined by the corresponding constraint length
         * - a3. no entry has a one in a bit position greater than the MSB
         *
         * To check this we simply "or" all of the entries in each row of
         * the generator matrix together and then test the value of the result
         * for each of the above conditions.  In order, we test the result of
         * the "or" operation to see if it is:
         *
         * - odd
         * - equal to or greater than 2^(constraint length - 1)
         * - less than 2^constraint length
         * - check that each octal word has a maximum of "constraint length"
         *
         * FEEDBACK:
         * - b1. check above rules, i.e., a1-a3, by applying the rules to 
         *       generator matrix and feedback connection polynomials.
         * - b2. Feedback polynomial check: a one in MSB and at least a one 
         *       in a non-MSB position
         *
         */
        
        /* Check feeback */
        if (fbflag == FBACK) {
            real_T *fparm = mxGetPr(FPOL_ARG);

            for (indx1 = 0; indx1 < k; indx1++) { 
                work1 = ConvertOctaltoDecimal((int32_T) fparm[indx1]);
                
                if (work1 < 1<<(int32_T) (mlen[indx1]-1) ) { 
                    msg = "Feedback vector must have MSB = 1 for each element."; 
                    goto EXIT_POINT; 
                } 
                
                if (work1 >= 1<<(int32_T) mlen[indx1]) {
                    msg = "An element of the feedback vector is too "
                          "large for specified constraint length.";
                    goto EXIT_POINT;
                }
            }
        }
        
        /* Chech feedback and generator polynomials */
        for (indx1 = 0; indx1 < k; indx1++) { 
            work1 = 0;
            for (indx2 = 0; indx2 < n; indx2++) {
                work1 |= ConvertOctaltoDecimal((int32_T) 
                                               gparm[indx1+indx2*k]);
            }
            
            if (fbflag == FBACK) {
                real_T *fparm = mxGetPr(FPOL_ARG);
                work1 |= ConvertOctaltoDecimal((int32_T) fparm[indx1]);
            }
            
            if ( work1%2 != 1) {
                msg = "Generator describes code of less than specified "
                    "constraint length.";
                goto EXIT_POINT;
            }
            
            if (work1 < 1<<(int32_T) (mlen[indx1]-1) ) { 
                msg = "Generator describes code of less than specified "
                    "constraint length."; 
                goto EXIT_POINT; 
            } 
            
            if (work1 >= 1<<(int32_T) mlen[indx1]) {
                msg = "Generator describes code of more than specified "
                    "constraint length.";
                goto EXIT_POINT;
            }
        }
    }
 EXIT_POINT:
    if(msg != NULL){
        mexErrMsgTxt(msg);
    }
}/* CheckParameters */


/* Function: CreateTrellisStructure ============================================
 * Abstract: This function creates a structure with the following fields:
 *
 *           numInputSymbols          (2^k)
 *           numOutputSymbols         (2^n)
 *           numStates
 *           nextStates
 *           outputs
 */
static void CreateTrellisStructure(mxArray *plhs[],
                                   int     k, 
                                   int     n, 
                                   int     numStates,
                                   mxArray *trellisNextState, 
                                   mxArray *trellisOutput)
{
    const char *fieldNames[] = {"numInputSymbols",
                                "numOutputSymbols",
                                "numStates",
                                "nextStates",
                                "outputs"};

    typedef  enum {NUM_INPUT_SYMBOLS, 
                   NUM_OUTPUT_SYMBOLS, 
                   NUM_STATES, 
                   NEXT_STATES, 
                   OUTPUTS,
                   NUM_FIELDS
    } fieldNameIdx;
        
    mxArray    *trellis = mxCreateStructMatrix(1, 1, NUM_FIELDS, fieldNames);
    const char *msg = NULL;
    double     val;
    mxArray    *pa;

    
    /* Fill numInputSymbols field */
    val = (1 << k);
    pa  = mxCreateScalarDouble(val);
    if (pa == NULL) {
        msg = MEM_ALLOCATION_ERROR;
        goto EXIT_POINT;
    }
    mxSetFieldByNumber(trellis, 0, NUM_INPUT_SYMBOLS, pa);
    
    /* Fill numOutputSymbols field */
    val = (1 << n);
    pa  = mxCreateScalarDouble(val);
    if (pa == NULL) {
        msg = MEM_ALLOCATION_ERROR;
        goto EXIT_POINT;
    }
    mxSetFieldByNumber(trellis, 0, NUM_OUTPUT_SYMBOLS, pa);
        
    /* Fill numStates field */
    val = numStates;
    pa  = mxCreateScalarDouble(val);
    if (pa == NULL) {
        msg = MEM_ALLOCATION_ERROR;
        goto EXIT_POINT;
    }
    mxSetFieldByNumber(trellis, 0, NUM_STATES, pa);

    /* Fill nextStates field */
    mxSetFieldByNumber(trellis, 0, NEXT_STATES, trellisNextState);

    /* Fill outputs field */
    mxSetFieldByNumber(trellis, 0, OUTPUTS, trellisOutput);
    
    plhs[0] = trellis;

 EXIT_POINT:
    if(msg != NULL){
        mexErrMsgTxt(msg);
    }
} /* CreateTrellisStructure */



/* Function: CreateTrellis =====================================================
 * Abstract: In this function, we use the generator and feedback polynomials
 *           to create a structure with the following fields:
 *           numInputSymbols          (2^k)
 *           numOutputSymbols         (2^n)
 *           numStates
 *           nextStates
 *           outputs
 *
 *   nextState and outputs are matrices with numStates rows and numInputSymbols
 *   columns. 
 *   Each element row=s and col=u in the nextStates matrix indicates 
 *   the next state when the starting state is s and the input symbol is u.
 *   Each element row=s and col=u in the output matrix indicates 
 *   the next state when the starting state is s and the input symbol is u.
 *   See istrellis.m for valid trellis structures.
 */
static void CreateTrellis(int nlhs,       mxArray *plhs[],
                          int nrhs, const mxArray *prhs[])
{
    const int8_T  k          = mxGetM(GEN_ARG);
    const int8_T  n          = mxGetN(GEN_ARG);
    const int_T   fbflag     = (nrhs == 2) ? FFWD : FBACK;
    const int_T   regSize    = k * sizeof(int_T);
    const int_T   genSize    = n * k * sizeof(int_T);
    const int_T   fbSize     = k * sizeof(int_T);
    
    real_T       *mlen       = mxGetPr(MEM_ARG);
    real_T       *fparm      = (fbflag == FBACK) ? mxGetPr(FPOL_ARG) : NULL;
    real_T       *gparm      = mxGetPr(GEN_ARG);
    
    mxArray      *mxpsreg;
    mxArray      *mxpgtap;
    mxArray      *mxpfbtap;
    
    int32_T      *psreg;
    int32_T      *pgtap;
    int32_T      *pfbtap;
    
    int_T        indx1; 
    int_T        temp, temp2, output, fbbit;
    int_T        numStates;
    const char   *msg = NULL;
    
    /* Allocate memory */
    {
        int          ndim = 2;
        int          dims[2] = {1 , 1};
        
        dims[0]  = regSize;
        mxpsreg  = mxCreateNumericArray(ndim,dims, mxINT32_CLASS, mxREAL);
        if(mxpsreg == NULL){
            msg = MEM_ALLOCATION_ERROR;
            goto EXIT_POINT;
        }
        psreg = (int32_T *)mxGetData(mxpsreg);
        
        dims[0]  = genSize;
        mxpgtap  = mxCreateNumericArray(ndim,dims, mxINT32_CLASS, mxREAL);
        if(mxpgtap == NULL){
            msg = MEM_ALLOCATION_ERROR;
            goto EXIT_POINT;
        }
        pgtap = (int32_T *)mxGetData(mxpgtap);
        
        dims[0]  = fbSize;
        mxpfbtap = mxCreateNumericArray(ndim,dims, mxINT32_CLASS, mxREAL);
        if(mxpfbtap == NULL){
            msg = MEM_ALLOCATION_ERROR;
            goto EXIT_POINT;
        }
        pfbtap = (int32_T *)mxGetData(mxpfbtap);
    }
    

    /* Calculate number of states */
    temp = 0;
    for (indx1 = 0; indx1 < k; indx1++) { 
       temp += (int_T) mlen[indx1];
    }
    temp -= k;
    numStates = 2 << (temp-1);
    
    
    /* Initialize contents of all k shift registers to zero 
     * (each s.r. is a 32-bit word) 
     */
    for (indx1 = 0; indx1 < k; indx1++) { 
        psreg[indx1] = 0;
    }
 
    /* 
     * Convert generator (feedforward and feedback) polynomials from octal 
     * to decimal 
     */
    for (indx1 = 0; indx1 < n*k; indx1++) { 
        pgtap[indx1]  = ConvertOctaltoDecimal((int_T) gparm[indx1]);
    }
    
    if (fbflag == FBACK) {
        for (indx1 = 0; indx1 < k; indx1++) { 
            pfbtap[indx1] = ConvertOctaltoDecimal((int_T) fparm[indx1]);
        }
    }
    
    /* Use encoder to set up trellis tables */
    {
        int      ndim  = 2;
        int      dims[2];
        mxArray  *trellisOutput;
        mxArray  *trellisNextState;
        real_T   *pnxtst;
        real_T   *pencout;
        int_T    currstate;
        
        dims[0] = numStates;
        dims[1] = (1 << k);
        trellisNextState =mxCreateNumericArray(ndim,dims,mxDOUBLE_CLASS,mxREAL);
        if(trellisNextState == NULL){
            msg = MEM_ALLOCATION_ERROR;
            goto EXIT_POINT;
        }
        trellisOutput    =mxCreateNumericArray(ndim,dims,mxDOUBLE_CLASS,mxREAL);
        if(trellisOutput == NULL){
            msg = MEM_ALLOCATION_ERROR;
            goto EXIT_POINT;
        }
        
        pnxtst  = mxGetPr(trellisNextState);
        pencout = mxGetPr(trellisOutput);
        
        /*  Outer loop on all possible encoder states */
        for(currstate = 0; currstate < numStates; currstate++) {
            
            /*  Inner loop on all possible input values */
            int_T currinput;
            
            for(currinput = 0; currinput < (1<<k); currinput++) {
                temp =  currstate;
                for(indx1 = 0; indx1 < k ; indx1++) {
                    psreg[indx1] = temp & ((1<<(int_T) mlen[indx1]-1)-1);
                    temp >>= (int_T) mlen[indx1] - 1;
                }
                
                /* Register encoder inputs */
                temp = currinput;
                if(fbflag == FFWD) {
                    /* feedforward implementation */
                    for(indx1 = k-1; indx1 > -1; indx1--) {
                        psreg[indx1] +=  ((temp&01) << ((int_T) mlen[indx1]-1));
                        temp >>= 1;
                    }
                } else {
                    /* feedback implementation */
                    for(indx1 = k-1; indx1 > -1; indx1--) {
                        int_T indx2;
                        
                        fbbit = 0;
                        temp2 = (pfbtap[indx1] & psreg[indx1]);
                        for (indx2 = 0; indx2++ < mlen[indx1]-1; ) { 
                            fbbit += temp2&01;
                            temp2 >>= 1;
                        }
                        fbbit &= 01;
                        psreg[indx1] +=  
                            (((temp&01)^fbbit) << ((int_T) mlen[indx1]-1));
                        temp >>= 1;
                    }
                }
                /* Compute the encoder outputs */
                {
                    int_T curroutput = 0;
                    for(indx1 = 0; indx1 < n; indx1++) {
                        int_T indx2;
                        
                        output = 0;
                        for (indx2 = k-1; indx2 > -1; indx2--) { 
                            int_T indx3;
                            
                            temp = (pgtap[indx1*k + indx2] & psreg[indx2]);
                            for (indx3 = 0; indx3 < mlen[indx2]; indx3++) { 
                                output += temp&01;
                                temp >>= 1;
                            }
                        }
                        output &= 01;
                        curroutput <<= 1;
                        curroutput += output;
                    }
                    /* Shift contents of register(s) to update encoder state*/
                    for(indx1 = 0; indx1 < k; indx1++) {
                        psreg[indx1] >>= 1;
                    }
                    temp =  0;
                    for(indx1 = k-1; indx1 > 0; indx1--) {
                        temp |= psreg[indx1];
                        temp <<= (int_T) mlen[indx1-1] - 1;
                    }
                    temp |= psreg[0];

                    pnxtst[currinput*numStates+currstate] = (real_T)temp; 
                    pencout[currinput*numStates+currstate] = 
                        (real_T)ConvertDecimaltoOctal((int32_T)curroutput);
                }
            }
        }

        CreateTrellisStructure(plhs, k, n, numStates, 
                               trellisNextState, trellisOutput);
    
    }
 EXIT_POINT:
    if(msg != NULL){
        mexErrMsgTxt(msg);
    }
} /* CreateTrellis */

/* Function: mexFunction =======================================================
 * Abstract: Check the parameters, if there is any problem, report an error.
 *           Otherwise, create a structure with the following fields:
 *
 *           numInputSymbols          (2^k)
 *           numOutputSymbols         (2^n)
 *           numStates
 *           nextStates
 *           outputs
 * 
 */
void mexFunction(int nlhs,       mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{
    CheckParameters(nlhs, plhs, nrhs, prhs);
    CreateTrellis(nlhs, plhs, nrhs, prhs);
}
