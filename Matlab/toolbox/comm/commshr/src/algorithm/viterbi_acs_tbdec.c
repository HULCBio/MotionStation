/*    
 *    Helper file required for Add, Compare, Select  
 *    and Traceback Decoding operations in the 
 *    Communications Blockset. This file is required
 *    to implement Viterbi algorithm.
 *
 *    Copyright 1996-2003 The MathWorks, Inc.
 *    $Revision: 1.1.6.1 $ $Date: 2003/07/30 02:48:09 $
 */

#include "viterbi_acs_tbdec.h"

int_T addCompareSelect(uint32_T numStates, real_T *pTempMet,
                       const int_T alpha, real_T *pBMet, 
                       real_T *pStateMet, uint32_T *pTbState,
                       uint32_T *pTbInput, int_T *pTbPtr,
                       uint32_T *pNxtStates, uint32_T *pOutputs)
{
    /* Add Compare and Select */
    uint32_T indx1, currstate;
    real_T   renorm    = (real_T) MAX_int16_T;
    uint32_T minState  = 0;
    
    for(indx1=0; indx1 < numStates; indx1++) {
            /* 
             * Set the temporary state metrics for each of
             * ending states equal to the maximum value 
             */
            pTempMet[indx1] = (real_T) MAX_int16_T;
        }

        for(currstate=0; currstate < numStates; currstate++) 
        {
            int_T currinput;

            for(currinput=0; currinput < alpha; currinput++) 
            {
                /*
                 * For each state and for every possible input:
                 *
                 *    look up the next state, 
                 *    look up the associated output,
                 *    look up the current branch metric for that
                 *    output
                 *    look up the starting state metric 
                 *    (currmetric)
                 */
                uint32_T offset       = currinput * numStates + \
                                        currstate;
                uint32_T nextstate    = pNxtStates[offset];
                int32_T  curroutput   = pOutputs[offset];
                real_T   branchmetric = pBMet[curroutput];
                real_T   currmetric   = pStateMet[currstate];

                /*
                 * Now, perform the Add-Compare-Select procedure:
                 *   Add the branch metric to the starting state 
                 *   metric. Compare the sum with the best 
                 *   (so far) temporary metric for the ending 
                 *   state. If the sum is less, the following steps
                 *   consitute the select procedure:
                 *       - replace the temporary metric with the sum
                 *       - set the current state as the traceback 
                 *         path from the ending state at this level
                 *       - set the current input as the decoder output
                 *         associated with this traceback path
                 * For speed, we also update the renorm value (the 
                 * minimum ending state metric) in this loop
                 */
            
                if(currmetric+branchmetric < pTempMet[nextstate]) 
                {
                    pTempMet[nextstate]  = currmetric + branchmetric;
                    pTbState[nextstate + (pTbPtr[0] * numStates)] \
                                         = currstate;
                    pTbInput[nextstate + (pTbPtr[0] * numStates)] \
                                         = currinput;

                    if(pTempMet[nextstate] < renorm) 
                    {
                        renorm = pTempMet[nextstate];
                    }
                } /* end of if(currmetric+branchmetric<pTempMet[nextstate]) */
            
            } /* end of for(currinput=0; currinput<alpha; currinput++)*/

        } /* end of for(currstate=0; currstate < pNumStates[0]; currstate++) */

        /*
         * Update (and renormalize) state metrics, then find 
         * minimum metric state for start of traceback
         */

        for(currstate=0; currstate < numStates; currstate++) {
            
            pStateMet[currstate] = pTempMet[currstate] - renorm;

            if(pStateMet[currstate] == 0) {
                minState = currstate;
            }
        }
          
        return minState;

} /* EOF addCompareSelect */

int_T tracebackDecoding(int_T *pTbPtr, uint32_T minState, 
                        const int_T tbLen, uint32_T *pTbInput, 
                        uint32_T *pTbState, uint32_T numStates)
{         
        int_T indx1;
        int_T tbwork = pTbPtr[0];
        int_T input  = 0;
       
        /*
         * Starting at the minimum metric state at the current
         * time in the traceback array:
         *     - determine the input leading to that state
         *     - follow the most likely path back to the previous
         *       state by updating the value of minState
         *     - adjust the traceback index value mod tbLen
         * Repeat this tbLen+1 (for current level) times to complete
         * the traceback
         */        
        
        for(indx1=0; indx1 < tbLen +1; indx1++) 
        {                                
            input    = (int_T) pTbInput[minState+(tbwork*numStates)];
            minState = (uint32_T) pTbState[minState+(tbwork*numStates)];
            tbwork   = (tbwork > 0) ? tbwork-1 : tbLen ;
        }
         
        /* Increment the traceback index and store */
         pTbPtr[0] = (pTbPtr[0] < tbLen) ? pTbPtr[0]+1 : 0;

         return input;    
}

/* EOF viterbi_acs_tbd.c */
