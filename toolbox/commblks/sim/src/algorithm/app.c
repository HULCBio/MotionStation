/*    
 *    This file is the Soft input soft output APP algorithm.
 *    The algorithm is implemented based on the following paper:
 *       'A Soft-Input Soft-Output Maximum A Posterior (MAP) Module to 
 *        Decode Parallel and Serial Concatenated Codes',  by S. Benedetto, 
 *        G. Montorsi, D.Divsalar and F. Pollara, JPL TMO Progress Report,
 *        November 15, 1996. 
 *         (http://tmo.jpl.nasa.gov/tmo/progress_report/index.html)
 *         (http://www331.jpl.nasa.gov/public/JPLtcodes.html)
 *    Copyright 1996-2003 The MathWorks, Inc.
 *    $Revision: 1.1.6.2 $
 *    $Date: 2004/04/12 23:03:43 $
 *    Author: Mojdeh Shakeri
 */

#include <memory.h>
#include <string.h>
#include <math.h>
#include <stdio.h>

#include "trellis.h"
#include "app.h"
#include "tmwtypes.h"

#define  NDEBUG_APP 
#define  NDEBUG_APP_PRINT 

#ifdef DEBUG_APP_PRINT 
#define app_Printf mexPrintf
/* #define app_Printf printf */

/* Function: app_PrintDoubleData =============================================
 * Abstract: This function is used for debugging. If DEBUG_APP is defined
 *           this function dumps alpha, beta, branch metrics, input and 
 *           output bits.
 */           
static void app_PrintDoubleData(char *info,  char *name, double *ptr, 
                                int num, int ib) 
{
    int i;
    app_Printf("--- %s --- (block: %d)\n", info, ib);
    for(i = 0; i < num; ++ i){
        app_Printf("%s[%d] = %f\n",name,i,ptr[i]);
    }
    app_Printf("\n");
}
#else
#define app_PrintDoubleData(info,name,ptr,num,ib) 
#endif

#undef  MAX
#define MAX(a,b) (((a) >= (b)) ? (a) : (b)) 

/* Function: MAX_STAR  =========================================================
 * Abstract: This function approximate log(exp(a) + exp(b)) using a look up
 *           table. For simplicity, we assume that the reliability of input and
 *           code bits are multiplied by 8. (In fixed point representation,
 *           this crossponds to shifting the data by 3 bits).
 *           Let us assume that a > b, therefore, 
 *           log(exp(a)+exp(b)) = a + log(1+exp(-(a-b))).
 *
 *           If numScaleBits is 3, then the table is generated based on
 *                         round(8 * log(1+exp(-(a-b)/8)))
 *           Therefore, 
 *                if a - b = 0, table[0] = 6 
 *                if a - b = 1, table[1] = 5,  ...
 *
 *           in this case,table ={6,5,5,4,4,3,3,3,3,2,2,2,2,1,1,1,1,1,1,1,1,1}; 
 *           Table length is 22.
 */  
#ifdef DEBUG_APP
static double MAX_STAR(app_T *app, double a, double b, double delta)
{
    int     tableLen = (int) app->maxStarTableLength;
    double  *table   = app->maxStarTable;

    double val = (((delta) < tableLen)? (MAX(a,b) + table[(int)delta]): 
                  MAX(a,b));
    return val;    
}
#else
#define MAX_STAR(app, a, b, delta)                       \
       (((delta) < (app)->maxStarTableLength) ?          \
        (MAX(a, b) + (app)->maxStarTable[(int)delta]) :  \
        MAX(a, b))
#endif


/* Function: app_exp_sum ======================================================
 * Abstract: true app, return a1 + exp(a2).
 *           max,      return MAX(a1, a2).
 *           max*,     return MAX_STAR(a1, a2).
 */
#ifdef DEBUG_APP
static double app_exp_sum(algorithm_T alg, app_T *app, double a1, double a2)
{
    if(alg == MAX_STAR_ALG){
        return MAX_STAR(app, a1, a2, 
                       MAX(((a1) - (a2)), ((a2) - (a1))));


    }else if(alg == MAX_ALG){
        return MAX(a1, a2);

    }else{ /* (alg == MAX_TRUE_APP_ALG)*/
        /* To overcome over or under flow: a1 + exp(a2). */

        if(a2 > APP_INT_MAX(alg)){

             return (a1+exp(APP_INT_MAX(alg)));

        }else if (a2 < -APP_INT_MAX(alg)){

            return (a1+exp(-APP_INT_MAX(alg)));

        }else{
            return (a1+exp(a2));
        }
    }

}


#else
#define  app_exp_sum(alg, app, a1, a2) \
  (((alg) == MAX_STAR_ALG) ?                                                 \
   MAX_STAR(app, (a1),(a2),MAX(((a1) - (a2)), ((a2) - (a1)))):               \
   (((alg) == MAX_ALG) ? MAX(a1,a2) :                                        \
    (((a2) > APP_INT_MAX(alg))   ? ((a1)+exp( APP_INT_MAX(alg))) :           \
     (((a2) < -APP_INT_MAX(alg)) ? ((a1)+exp(-APP_INT_MAX(alg))) :           \
      ((a1)+exp(a2))))))
#endif

/* Function: app_log ==========================================================
 * Abstract: true app, return log(a).
 *           max,max*, return a.
 */
static double app_log(algorithm_T alg, double  a)
{
    if(alg == TRUE_APP_ALG){
        /* To overcome over or under flow: log(a)*/
        if (a<=exp(-740))
        {
            return -740;
        }else
        {
            return log(a);
        }
    }else{
        return (a);
    } 
}

/* Function: app_normalize ====================================================
 * Abstract: vec - max(vec).
 *           Call this function to normalize alpha and beta.
 */
static void app_normalize(double *vec, int num)
{
  
    double max = MIN_int16_T;

    int    i;
   
    for(i = 0; i < num; ++i){
        max = MAX(max, vec[i]);
    }

    for(i = 0; i < num; ++i){
        vec[i] -= max;
    }

}


/* Function: app_UpdateBranchMetric ===========================================
 * Abstract: This function updates branch metrics for block ib.
 *           We only store branch metrics for one block of data.
 *           branchMetric(s, u) = sum (u_i * L_i) + sum (c_j * Lj)
 */
static void app_UpdateBranchMetric(
 Trellis_T *trellis, 
 app_T     *app, 
 int       ib /* block index */)
{
    int    is, iu, ub, cb;
    int    numStates         = trellis->numStates;
    int    uNumBits          = trellis->uNumBits;
    int    cNumBits          = trellis->cNumBits;
    int    uNumAlphabet      = trellis->uNumAlphabets;
    int    numBranches       = trellis->numBranches;
    int    *trellisOutput    = trellis->output;
    double *branchMetrics    = app->branchMetrics;
    double *uI               = app->inputs.uI;
    double *cI               = app->inputs.cI;
    int    uOffset           = ib * uNumBits;
    int    cOffset           = ib * cNumBits;

    (void)memset(branchMetrics, 0, sizeof(double) * numBranches);
    for(iu = 0; iu < uNumAlphabet ; iu++) { /* iu-th input */
        int    bOffset = numStates * iu;
        for(is = 0; is < numStates; is++) { /* is-th state */
            int temp = iu;
            for(ub = 0; ub < uNumBits ; ++ub){  /* ub-th input(u) bits */
                if((temp&01) == 1) {
                    branchMetrics[is+bOffset] +=  uI[uOffset+(uNumBits-ub-1)];
                }
                temp >>= 1;
            }
        
            temp = trellisOutput[is+bOffset];
            for(cb = 0; cb < cNumBits ; ++cb){  /* cb-th input(c) bits */
                if((temp&01) == 1) {
                    branchMetrics[is+bOffset] += cI[cOffset+(cNumBits-cb-1)];
                }
                temp >>= 1;
            }
        }
    }
}


/* Function: app_UpdateAlpha ==================================================
 * Abstract: This function updates alpha based on forward recursion.
 * Assumption: branch metrics are valid for this step.
 */
static void app_UpdateAlpha(
 Trellis_T  *trellis, 
 app_T      *app, 
 int        isCurrAlphaFlag) /* true if currAlpha == Alpha */
{
    int    is, iu;
    int    numStates         = trellis->numStates;
    int    uNumAlphabet      = trellis->uNumAlphabets;
    int    *trellisNextState = trellis->nextState;
    double *branchMetrics    = app->branchMetrics;
    double *currAlphaPtr     = (app->alpha) + ((isCurrAlphaFlag)? 0: numStates);
    double *prevAlphaPtr     = (app->alpha) + ((isCurrAlphaFlag)? numStates:0);
    algorithm_T alg          = app->alg;

    /* Reset currAlpha */
    for(is = 0; is < numStates; is++) { /* is-th state */
        currAlphaPtr[is] = APP_INIT_VALUE(alg);
    } 
    
    /* alpha[k] = log(sum(exp(alpha[k-1]+branchMetrics)) */
    for(iu = 0; iu < uNumAlphabet ; iu++) { /* iu-th input */ 
        int bOffset = numStates * iu;
        for(is = 0; is < numStates; is++) { /* is-th state */
            int     nextState  =  trellisNextState[is+bOffset];
            double  thisMetric =  prevAlphaPtr[is]+ branchMetrics[is+bOffset];
            currAlphaPtr[nextState] = app_exp_sum(alg, app, 
                                      currAlphaPtr[nextState],
                                      thisMetric);
        }
    }  

    if(alg == TRUE_APP_ALG){
        for(is = 0; is < numStates; is++) { /* is-th state */
            currAlphaPtr[is] = app_log(alg, currAlphaPtr[is]);
        } 
    }

    app_normalize(currAlphaPtr, numStates);
    
} /* app_UpdateAlpha */


/* Function: app_SoftInputSoftOutput ==========================================
 * Abstract: This is the soft input soft output algorithms, i.e.,
 *           true app, max, and max*.
 */
void app_SoftInputSoftOutput(Trellis_T *trellis, app_T *app)
{
    int         ib, is, iu, ub, cb;
    int         numStates         = trellis->numStates;
    int         uNumBits          = trellis->uNumBits;
    int         cNumBits          = trellis->cNumBits;
    int         uNumAlphabet      = trellis->uNumAlphabets;
    int         *trellisNextState = trellis->nextState;
    int         *trellisOutput    = trellis->output;
    int         blockSize         = app->blockSize;
    double      *branchMetrics    = app->branchMetrics;
    double      *uI               = app->inputs.uI;
    double      *cI               = app->inputs.cI;
    double      *uO               = app->outputs.uO;
    double      *cO               = app->outputs.cO;
    double      *alpha            = app->alpha;
    double      *beta             = app->beta;
    int         *currAlphaFlag    = app->currAlphaFlag;
    algorithm_T alg               = app->alg;

    /*******************************
     *       Update Beta           *
     *******************************/
    /* Update Beta */

    if (app->terminationMethod == TERMINATED){
        /* Backward recursion starts from state 0 */
        for(is = 0; is < numStates; is++) { /* is-th state */
            beta[(blockSize - 1) * numStates +is] = -APP_INT_MAX(alg);
        }  
        beta[(blockSize - 1) * numStates] = 0;

    }else{/* CONTINUOUS or TRUNCATED */
        /* Backward recursion can start from any state */
        for(is = 0; is < numStates; is++) { /* is-th state */
            beta[(blockSize - 1) * numStates +is] = 0;
        }  
    }
    

    /*
     * ib for block, alpha and beta.
     * Alpha      0            1            2
     *            o ---------- o ---------- o -----------o
     *
     * Block:           0            1            2
     * 
     *            o ---------- o ---------- o -----------o
     * Beta:                   0            1            2
     */
    for(ib = blockSize-2 ; ib >= 0; ib--) { /* ib-th block */

        double *currBetaPtr = beta + (ib*numStates);
        double *nextBetaPtr = currBetaPtr + numStates;

        /* Compute branch metrics for beta calculations */
        app_UpdateBranchMetric(trellis,app,ib+1);
        app_normalize(branchMetrics, numStates*uNumAlphabet);

        /* Normalize the first set of nextBeta */
        if (ib == blockSize-2)
        {
            app_normalize(nextBetaPtr, numStates);
        }

        for(is = 0; is < numStates; is++) { /* is-th state */
            currBetaPtr[is] = APP_INIT_VALUE(alg);
        }

        /* beta[k-1] = log(sum(exp(beta[k]+branchMetric)) */
        for(iu = 0; iu < uNumAlphabet ; iu++) { /* iu-th input */  
            int bOffset = numStates * iu;
            for(is = 0; is < numStates; is++) { /* is-th state */
            /* is = starting state of current edge */
                int    nextState  =  trellisNextState[is + bOffset];
                double thisMetric =  nextBetaPtr[nextState]+
                                     branchMetrics[is+bOffset];
                currBetaPtr[is]   = app_exp_sum(alg,app,
                                                currBetaPtr[is],thisMetric);
            }
        }  

        if(alg == TRUE_APP_ALG){
            for(is = 0; is < numStates; is++) { /* is-th state */
                currBetaPtr[is] = app_log( alg, currBetaPtr[is]);
            } 
        }
        app_normalize(currBetaPtr, numStates);

        /* For debugging */
        app_PrintDoubleData("Beta (backward)", 
                             "beta", currBetaPtr, numStates, ib); 
    }


    /************************************************
     *       Evaluate Output and Update Alpha       *
     ************************************************/
    (void)memset(uO, 0, sizeof(double) * blockSize * uNumBits);
    (void)memset(cO, 0, sizeof(double) * blockSize * cNumBits);

    for(ib = 0; ib < blockSize; ib++) { /* ib-th block */
    
        double *currAlphaPtr = alpha + (currAlphaFlag[0]? 0: numStates);
        double *nextBetaPtr  = beta  + (ib * numStates);
        int    uOffset       = ib * uNumBits;
        int    cOffset       = ib * cNumBits;
        
        if(ib==0)
        {
            app_normalize(currAlphaPtr, numStates);
        }
        
        /* Compute branch metrics for alpha calculations */
        app_UpdateBranchMetric(trellis,app,ib);
        app_normalize(branchMetrics, numStates*uNumAlphabet);

        /* For debugging */
        app_PrintDoubleData("BranchMetrics (forward)", 
                             "branch", branchMetrics, trellis->numBranches, ib);


        /* Evaluate uO */
        for(ub = 0; ub < uNumBits ; ++ub){ /* ub-th input bit */
            double temp0 = APP_INIT_VALUE(alg);
            double temp1 = APP_INIT_VALUE(alg);

            for(iu = 0; iu < uNumAlphabet ; iu++) { /* iu-th input */  
                int bOffset = numStates*iu;
                for(is = 0; is < numStates; is++) { /* is-th state */
            
                    int    nextState = trellisNextState[is + bOffset];
                    double tmpVal    = currAlphaPtr[is]+nextBetaPtr[nextState] +
                                       branchMetrics[is+ bOffset];

                    if(((iu >> ub ) & 01) == 1){
                        temp1 = app_exp_sum(alg, app, temp1, 
                                            tmpVal-uI[uOffset+(uNumBits-ub-1)]);

                    }else{
                        temp0 = app_exp_sum(alg, app, temp0, tmpVal);

                    }
                }
            }

            temp1 = app_log(alg, temp1);
            temp0 = app_log(alg, temp0);
            uO[uOffset+(uNumBits-ub-1)] = temp1 - temp0;

        }  


        /* Evaluate cO */
        for(cb = 0; cb < cNumBits ; ++cb){ /* cb-th input bit */
            double temp0 = APP_INIT_VALUE(alg);
            double temp1 = APP_INIT_VALUE(alg);

            for(iu = 0; iu < uNumAlphabet ; iu++) { /* iu-th input */  
                int bOffset = numStates*iu;
                for(is = 0; is < numStates; is++) { /* is-th state */
                    int    output    = trellisOutput[is+bOffset];
                    int    nextState = trellisNextState[is+bOffset];

                    double tmpVal  = currAlphaPtr[is] + nextBetaPtr[nextState] +
                                     branchMetrics[is+bOffset];
            
                    if(((output >> cb ) & 01) == 1){
                        temp1 = app_exp_sum(alg, app, temp1,
                                            tmpVal-cI[cOffset+(cNumBits-cb-1)]);
       
                    }else{
                        temp0 = app_exp_sum(alg, app, temp0,tmpVal);    

                    }
                }
            }

            temp1 = app_log(alg, temp1);
            temp0 = app_log(alg, temp0);
            cO[cOffset+(cNumBits-cb-1)] = temp1 - temp0;
        }  
    
        /* 
         * Update alpha for the next iteration. Usually we do not need to 
         * update it for the last block size. However, in the continuous mode,
         * we need the last set of alpha's to initialize the forward recursion.
         */
        if ((ib < (blockSize - 1))                   ||
            (app->terminationMethod == CONTINUOUS) ) {
            /* For debugging */
            app_PrintDoubleData("Alpha (forward)","alpha",
                                     currAlphaPtr,numStates,ib);

            currAlphaFlag[0] = currAlphaFlag[0]? 0 : 1;

            app_UpdateAlpha(trellis, app, currAlphaFlag[0]);
        }
    }

    return;
}


