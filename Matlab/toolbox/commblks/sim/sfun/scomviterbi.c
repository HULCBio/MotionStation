/*
 *   SCOMVITERBI Communications Toolbox S-Function for Viterbi decoder 
 *
 *    Copyright 1996-2004 The MathWorks, Inc.
 *    $Revision: 1.26.4.5 $  $Date: 2004/04/12 23:03:41 $
 */

#define S_FUNCTION_NAME scomviterbi
#define S_FUNCTION_LEVEL 2

#include "simstruc.h"
#include <math.h>       /* for pow */
#include "comm_defs.h"
#include "comm_mtrx.h"

enum {INPORT_DATA=0, INPORT_RESET};
enum {OUTPORT_DATA=0};
enum {BMETRIC=0, STATE_METRIC, TEMP_METRIC, TBSTATE, TBINPUT, TBPTR, NUM_DWORK};
enum {FFWD=1, FBACK};
enum {UNQUANT=1, HARD_DEC, SOFT_DEC};
enum {CONT=1, TRUNC, TERM};

enum {TRELLIS_U_NUMBITS_ARGC = 0,   /* number of input bits, k      */
      TRELLIS_C_NUMBITS_ARGC,       /* number of output bits, n     */
      TRELLIS_NUM_STATES_ARGC,      /* number of states             */
      TRELLIS_OUTPUT_ARGC,          /* output matrix (decimal)      */
      TRELLIS_NEXT_STATE_ARGC,      /* next state matrix            */
      DECTYPE_ARGC,                 /* decision type                */
      SDEC_ARGC,                    /* number of soft decision bits */
      TB_ARGC,                      /* traceback depth              */
      OPMODE_ARGC,                  /* operation mode               */
      RESET_ARGC,                   /* reset port                   */ 
      NUM_ARGS}; 

#define TRELLIS_U_NUMBITS_ARG   (ssGetSFcnParam(S, TRELLIS_U_NUMBITS_ARGC))
#define TRELLIS_C_NUMBITS_ARG   (ssGetSFcnParam(S, TRELLIS_C_NUMBITS_ARGC))
#define TRELLIS_NUM_STATES_ARG  (ssGetSFcnParam(S, TRELLIS_NUM_STATES_ARGC))
#define TRELLIS_OUTPUT_ARG      (ssGetSFcnParam(S, TRELLIS_OUTPUT_ARGC))
#define TRELLIS_NEXT_STATE_ARG  (ssGetSFcnParam(S, TRELLIS_NEXT_STATE_ARGC))
#define DECTYPE_ARG             (ssGetSFcnParam(S, DECTYPE_ARGC))
#define SDEC_ARG                (ssGetSFcnParam(S, SDEC_ARGC))
#define TB_ARG                  (ssGetSFcnParam(S, TB_ARGC))
#define OPMODE_ARG              (ssGetSFcnParam(S, OPMODE_ARGC))
#define RESET_ARG               (ssGetSFcnParam(S, RESET_ARGC))


#define EDIT_OK(S, ARG) ((ssGetSimMode(S) != SS_SIMMODE_SIZES_CALL_ONLY) || !mxIsEmpty(ARG))

#ifdef MATLAB_MEX_FILE 
#define MDL_CHECK_PARAMETERS 
static void mdlCheckParameters(SimStruct *S) 
{ 
    const int_T  dectype   = (int_T) mxGetPr(DECTYPE_ARG)[0];

    if(dectype == SOFT_DEC && EDIT_OK(S, SDEC_ARG)){
        boolean_T isOk = (mxIsNumeric(SDEC_ARG)  &&   
                          mxIsDouble(SDEC_ARG)   &&
                          !mxIsComplex(SDEC_ARG) &&  
                          !mxIsSparse(SDEC_ARG)  && 
                          !mxIsEmpty(SDEC_ARG)   &&   
                          mxGetNumberOfElements(SDEC_ARG) == 1);
        if(isOk){
            real_T nsdec = mxGetPr(SDEC_ARG)[0];
            isOk = (nsdec > 0) &&((real_T)((int8_T)nsdec)== nsdec);
        }
        if (!isOk){
            ssSetErrorStatus(S, "Invalid number of soft decision bits "
                             "specified. Number of decision bits must "
                             "be a positive integer value.");
            goto FCN_EXIT;
        }
    }
        
        
    if(EDIT_OK(S, TB_ARG)){
        boolean_T isOk = (mxIsNumeric(TB_ARG)   &&   
                          mxIsDouble(TB_ARG)    &&
                          !mxIsComplex(TB_ARG)  &&  
                          !mxIsSparse(TB_ARG)   && 
                          !mxIsEmpty(TB_ARG)    &&   
                          mxGetNumberOfElements(TB_ARG) == 1);
        if(isOk){
            real_T tblen  = mxGetPr(TB_ARG)[0];
            isOk = (tblen > 0) && ((real_T)((int_T)tblen) == tblen);
        }
        
        if (!isOk){
            ssSetErrorStatus(S, "Invalid Traceback depth specified. "
                             "The Traceback depth must be "
                             "a positive integer value.");
            goto FCN_EXIT;
        }
    }
FCN_EXIT: 
    return;
}
#endif 


static void mdlInitializeSizes(SimStruct *S) 
{ 
    int_T i;

    /* Parameters: */ 
    ssSetNumSFcnParams(S, NUM_ARGS); 

    #if defined(MATLAB_MEX_FILE) 
        if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) return; 
        mdlCheckParameters(S); 
        if (ssGetErrorStatus(S) != NULL) return; 
    #endif 

    /* Cannot change params while running: */
    for( i = 0; i < NUM_ARGS; ++i){
        ssSetSFcnParamNotTunable(S, i);
    }
    
    ssSetNumSampleTimes(S, PORT_BASED_SAMPLE_TIMES); 

    /* Inputs and Outputs */ 
    {
        /* Inputs: */ 
        const boolean_T rstPort = (boolean_T)((int_T)(mxGetPr(RESET_ARG)[0]) != 0);
        int8_T numInports = rstPort ? 2 : 1;

        if (!ssSetNumInputPorts(S, numInports)) return;

        if(!ssSetInputPortDimensionInfo(S, INPORT_DATA, DYNAMIC_DIMENSION)) return;
        ssSetInputPortFrameData(        S, INPORT_DATA, FRAME_INHERITED);
        ssSetInputPortDirectFeedThrough(S, INPORT_DATA, 1);
        ssSetInputPortReusable(         S, INPORT_DATA, 1);
        ssSetInputPortComplexSignal(    S, INPORT_DATA, COMPLEX_NO);
        ssSetInputPortSampleTime(       S, INPORT_DATA, INHERITED_SAMPLE_TIME);
        ssSetInputPortRequiredContiguous(S, INPORT_DATA, 1);

        if (rstPort) {
            ssSetInputPortKnownWidthUnknownDims(S, INPORT_RESET, 1);
            ssSetInputPortFrameData(         S, INPORT_RESET, FRAME_INHERITED);
            ssSetInputPortDirectFeedThrough( S, INPORT_RESET, 1);
            ssSetInputPortReusable(          S, INPORT_RESET, 1);
            ssSetInputPortComplexSignal(     S, INPORT_RESET, COMPLEX_NO);
            ssSetInputPortSampleTime(        S, INPORT_RESET, INHERITED_SAMPLE_TIME);
            ssSetInputPortRequiredContiguous(S, INPORT_RESET, 1);
        }

        /* Outputs: */ 
        if (!ssSetNumOutputPorts(S,1)) return; 
        if(!ssSetOutputPortDimensionInfo(S, OUTPORT_DATA, DYNAMIC_DIMENSION)) return;
        ssSetOutputPortFrameData(        S, OUTPORT_DATA, FRAME_INHERITED);
        ssSetOutputPortComplexSignal(    S, OUTPORT_DATA, COMPLEX_NO);
        ssSetOutputPortReusable(         S, OUTPORT_DATA, 1);
        ssSetOutputPortSampleTime(       S, OUTPORT_DATA, INHERITED_SAMPLE_TIME);

        if (!ssSetNumDWork(S, DYNAMICALLY_SIZED)) return;
        
        ssSetOptions(       S, SS_OPTION_EXCEPTION_FREE_CODE);
    }
}

static void mdlInitializeSampleTimes(SimStruct * S)
{
	ssSetModelReferenceSampleTimeInheritanceRule(S, USE_DEFAULT_FOR_DISCRETE_INHERITANCE);
}

/* Set all ports to the identical, discrete rates: */
#define MDL_SET_INPUT_PORT_SAMPLE_TIME
static void mdlSetInputPortSampleTime(SimStruct *S,
                                      int_T     portIdx,
                                      real_T    sampleTime,
                                      real_T    offsetTime)
{
    if (sampleTime == CONTINUOUS_SAMPLE_TIME) {
        ssSetErrorStatus(S, "Continuous sample times not allowed.");
		return;
    }

    if (offsetTime != 0.0) {
        ssSetErrorStatus(S, "Non-zero sample time offsets not allowed.");
		return;
    }

	ssSetInputPortSampleTime(S, portIdx, sampleTime);
	ssSetInputPortOffsetTime(S, portIdx, 0.0);

    if (portIdx==0) {

		int_T i, num;

		if (ssGetOutputPortSampleTime(S, 0) == INHERITED_SAMPLE_TIME) {
			ssSetOutputPortSampleTime(S, 0, sampleTime);
			ssSetOutputPortOffsetTime(S, 0, 0.0);
		}

		num = ssGetNumInputPorts(S);
		for (i=0; i<num; i++) {
			if (ssGetInputPortSampleTime(S, i) != INHERITED_SAMPLE_TIME &&
				ssGetInputPortSampleTime(S, i) != sampleTime) {
				ssSetErrorStatus(S, "All input port sample times must match.");
				return;
			}
		}
		
		num = ssGetNumOutputPorts(S);
		for (i=0; i<num; i++) {
			if (ssGetOutputPortSampleTime(S, i) != INHERITED_SAMPLE_TIME &&
				ssGetOutputPortSampleTime(S, i) != sampleTime) {
				ssSetErrorStatus(S, "All output port sample times must match.");
				return;
			}
		}

	} else {
		if (ssGetInputPortSampleTime(S, 0) != INHERITED_SAMPLE_TIME &&
			ssGetInputPortSampleTime(S, 0) != sampleTime) {
			ssSetErrorStatus(S, "All input port sample times must match.");
			return;
		}
	}
}

#define MDL_SET_OUTPUT_PORT_SAMPLE_TIME
static void mdlSetOutputPortSampleTime(SimStruct *S,
                                       int_T     portIdx,
                                       real_T    sampleTime,
                                       real_T    offsetTime)
{
    if (sampleTime == CONTINUOUS_SAMPLE_TIME) {
        ssSetErrorStatus(S, "Continuous sample times not allowed.");
		return;
    }

    if (offsetTime != 0.0) {
        ssSetErrorStatus(S, "Non-zero sample time offsets not allowed.");
		return;
    }

	ssSetOutputPortSampleTime(S, portIdx, sampleTime);
	ssSetOutputPortOffsetTime(S, portIdx, 0.0);

    if (portIdx==0) {

		int_T i, num;

		if (ssGetInputPortSampleTime(S, 0) == INHERITED_SAMPLE_TIME) {
			ssSetInputPortSampleTime(S, 0, sampleTime);
			ssSetInputPortOffsetTime(S, 0, 0.0);
		}
			
		num = ssGetNumInputPorts(S);
		for (i=0; i<num; i++) {
			if (ssGetInputPortSampleTime(S, i) != INHERITED_SAMPLE_TIME &&
				ssGetInputPortSampleTime(S, i) != sampleTime) {
				ssSetErrorStatus(S, "All input port sample times must match.");
				return;
			}
		}
		
		num = ssGetNumOutputPorts(S);
		for (i=0; i<num; i++) {
			if (ssGetOutputPortSampleTime(S, i) != INHERITED_SAMPLE_TIME &&
				ssGetOutputPortSampleTime(S, i) != sampleTime) {
				ssSetErrorStatus(S, "All output port sample times must match.");
				return;
			}
		}

    } else {
		if (ssGetOutputPortSampleTime(S, 0) != INHERITED_SAMPLE_TIME &&
			ssGetOutputPortSampleTime(S, 0) != sampleTime) {
			ssSetErrorStatus(S, "All output port sample times must match.");
			return;
		}
	}
}
  
#define MDL_INITIALIZE_CONDITIONS
static void mdlInitializeConditions(SimStruct *S)
{ 

    int_T   num_states  = (int32_T)(mxGetPr(TRELLIS_NUM_STATES_ARG)[0]);
    int_T   tblen       = (int_T) mxGetPr(TB_ARG)[0];
    int_T   i;

    /*
     * Set state metric for all zeros state equal to zero
     * and all other state metrics equal to MAX_int16_T
     */
	{
        real_T  *pstatemet  = (real_T *)  ssGetDWork(S, STATE_METRIC);
        pstatemet[0] = 0;
       
        for(i = 1; i <num_states ; i++) {
            pstatemet[i] = (real_T) MAX_int16_T;
        }
    }

    /* Set traceback memory to zero */
    {
        int_T *ptbstate = (int_T *) ssGetDWork(S, TBSTATE);
        int_T *ptbinput = (int_T *) ssGetDWork(S, TBINPUT);

        for(i = 0; i < num_states*((int_T) tblen + 1); i++) {
            ptbinput[i] = 0;
            ptbstate[i] = 0;
        }
    }
}


static void mdlOutputs(SimStruct *S, int_T tid)
{
/*  This is the main body of the Viterbi Decoder
 *  
 *  The algorithm has three main steps:
 *      1.  Branch metric computation
 *      2.  State metric update (ACS)
 *      3.  Traceback decoding
 *
 */
    const boolean_T rstPort    = (boolean_T)((int_T)(mxGetPr(RESET_ARG)[0]) != 0);
    const int32_T   num_states = (int32_T)(mxGetPr(TRELLIS_NUM_STATES_ARG)[0]);
    const int32_T   k          = (int32_T)(mxGetPr(TRELLIS_U_NUMBITS_ARG)[0]);
    const int32_T   n          = (int32_T)(mxGetPr(TRELLIS_C_NUMBITS_ARG)[0]);
    const int_T     dectype    = (int_T) mxGetPr(DECTYPE_ARG)[0];
    const int_T     tblen      = (int_T) mxGetPr(TB_ARG)[0];
    const int_T     opmode     = (int_T) mxGetPr(OPMODE_ARG)[0];

    const real_T    *pnxtst    = mxGetPr(TRELLIS_NEXT_STATE_ARG);
    const real_T    *pencout   = mxGetPr(TRELLIS_OUTPUT_ARG);

    real_T          *y         = (real_T *) ssGetOutputPortSignal(S,0); 
    real_T          *pbmet     = (real_T *) ssGetDWork(S, BMETRIC);
    real_T          *ptempmet  = (real_T *) ssGetDWork(S, TEMP_METRIC);
    real_T          *pstatemet = (real_T *) ssGetDWork(S, STATE_METRIC);
    int_T           *ptbstate  = (int_T *) ssGetDWork(S, TBSTATE);
    int_T           *ptbinput  = (int_T *) ssGetDWork(S, TBINPUT);
    int16_T         *ptbptr    = (int16_T *) ssGetDWork(S, TBPTR);
    int8_T          nsdec      = -1;

    real_T          *codein    = (real_T *) ssGetInputPortSignal(S,0); 
	
    /* Number of symbols in each input frame */
    int_T           blockSize  = ssGetInputPortWidth(S, INPORT_DATA)/n; 

    /* Get reset value if reset port is present */
    real_T          *pRstIn    = (!rstPort) ? NULL :
                                 (real_T *) ssGetInputPortSignal(S,INPORT_RESET);

    int_T           minstatetLastTB;
    int_T           tbworkLastTB;
    int_T           ib;


    /* 
     * TRUNC and TERM modes : Reset such that every frame is independent 
     * CONT mode :            Reset if requested
     */
    if (opmode != CONT || (rstPort && pRstIn[0] != 0.0)){ 
        mdlInitializeConditions(S);
    }

    /*
     * Branch metric computation 
     */

    /* Set number of soft decision bits */
    if(dectype == SOFT_DEC ){
        nsdec = (int8_T) mxGetPr(SDEC_ARG)[0];
    }else if(dectype == HARD_DEC) {
        /*  Set number of soft decisions = 1 for hard decision decoding */
        nsdec = 1; 
    } /* else, nsdec is unused */

    for(ib = 0; ib < blockSize; ++ib){
        int_T   indx1; 
        real_T  *thisBlockOut;
        real_T  *thisBlockIn;
        int_T   currstate;
        int_T   minstate;
        int_T   cOffset       = ib  * n;
        int_T   uOffset;
        real_T  renorm        = (real_T) MAX_int16_T;
        
        if(opmode == CONT){   /* CONTINUOUS mode */
            uOffset   = ib  * k;
        }else{  /* TRUNCATED or TERMINATED modes */
            /* 
             * Skip output indexing by (blockSize - tblen) blocks.
             * Compute metrics and TB tables but do no decoding for 
             * the blocks until the end of output buffer
             */
            uOffset   = ((ib - tblen)%blockSize)*k;
        }

        thisBlockIn  = codein  + cOffset;
        thisBlockOut = y + uOffset;

        for(indx1=0; indx1<(1<<n); indx1++) {

            int32_T temp = indx1;
            int32_T indx2;

            pbmet[indx1] = 0.0;

            if(dectype == UNQUANT) {       /* Unquantized inputs */
                for(indx2=0; indx2<n; indx2++) {
                    if((temp&01) == 1) {
                        /* logical 1 maps to -1.0 */
                        pbmet[indx1] += pow((thisBlockIn[n-1-indx2] + 1.0),2); 

                    }else {
                        /* logical 0 maps to +1.0 */
                        pbmet[indx1] += pow((thisBlockIn[n-1-indx2] - 1.0),2); 
                    }
                    temp >>= 1;
                }

            }else{                /* Quantized inputs */

                for(indx2=0; indx2<n; indx2++){

                    if ((thisBlockIn[indx2] >= pow(2,nsdec)) || (thisBlockIn[indx2] < 0)){
                        /* Error out when input is invalid */
                        THROW_ERROR(S, "Invalid input for chosen decision-type. "
                                       "Allowed input values for hard-decision "
                                       "decoding are 0 and 1. Allowed input values "
                                       "for soft-decision decoding are in the range "
                                       "0 to (2^N)-1, where N is the number "
                                       "of soft decision bits.");
                    }

                }/* end of for(indx2=0; indx2<n; indx2++) */

                for(indx2=0; indx2<n; indx2++) {
                    int_T indx3 = n-1-indx2;

                    if((temp&01) == 1) {
                        pbmet[indx1] += ((1<<nsdec)-1) - thisBlockIn[indx3];
                    } else {
                        pbmet[indx1] += thisBlockIn[indx3];
                    }
                    temp >>= 1;

                }/* end of for(indx2=0; indx2<n; indx2++) */

            } /* end of if(dectype == UNQUANT) */

        } /* end of for(indx1=0; indx1<(1<<n); indx1++) */

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
                 *   Compare the sum with the best (so far) temporary metric for the ending state
                 *   If the sum is less, the following steps consitute the select procedure:
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

        /* TERMINATED mode : */
        /* Start the final traceback path at the zero state for teminated mode */
        if (opmode == TERM && ib == blockSize - 1){		
            minstate = 0;					
        }

        /*
         * Traceback decoding
         */
        {    
            int_T tbwork = ptbptr[0];
            int_T input;
            int_T indx1;
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

            /* 
             * Capture starting minstate and starting tbwork of the last loop
             */
            if((opmode == TRUNC || opmode == TERM) && ib == blockSize-1){
                minstatetLastTB = minstate;
                tbworkLastTB   = tbwork;
            }

      
            /* 
             * For TRUNC or TERM mode, don't do traceback for first tblen times
             */
            if(opmode == CONT || ib >= tblen) {
                for(indx1=0; indx1<tblen+1; indx1++) {
                    input    = ptbinput[minstate+(tbwork*num_states)];
                    minstate = ptbstate[minstate+(tbwork*num_states)];
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
    }   /* end of ib loop */


    /* 
     * Truncated or Teminated mode :
     * 
     * Fill the last tblen output blocks using the same traceback path,
     *   working our way back from the very last block.
     */
    if(opmode == TRUNC || opmode == TERM){
        int_T indx1;

        for (indx1 = 0; indx1 < tblen; indx1 ++){
            real_T   *thisBlockOut = y + (blockSize-1-indx1)*k;
            int_T    input         = ptbinput[minstatetLastTB+(tbworkLastTB*num_states)];
            int_T    indx2;            

            for (indx2=0; indx2<k; indx2++) {
                thisBlockOut[k-1-indx2] = input&01;		
                input >>= 1;
            }
            minstatetLastTB = ptbstate[minstatetLastTB+(tbworkLastTB*num_states)];
            tbworkLastTB = (tbworkLastTB > 0) ? tbworkLastTB-1 : tblen;
        }
    }  

}  /*  end of mdlOutputs  */


static void mdlTerminate(SimStruct *S)
{
}

#ifdef MATLAB_MEX_FILE
#define MDL_SET_INPUT_PORT_DIMENSION_INFO
static void mdlSetInputPortDimensionInfo(SimStruct        *S, 
                                         int_T            port,
                                         const DimsInfo_T *thisInfo)
{
    if(port == INPORT_RESET){
        if(!ssSetInputPortDimensionInfo( S, port, thisInfo))  return;
        goto EXIT_POINT;
    }else{
        const int32_T thisFactor  = (int)(mxGetPr(TRELLIS_C_NUMBITS_ARG)[0]);
        const int32_T otherFactor = (int)(mxGetPr(TRELLIS_U_NUMBITS_ARG)[0]);

        /* Check input port dimensions */
        CommCheckConvCodPortDimensions(S, port, IS_INPORT, thisFactor, thisInfo);
        if(ssGetErrorStatus(S) != NULL) goto EXIT_POINT;

        /* Set input and output port dimensions */
        CommSetInputAndOutputPortDimsInfo(S,port,IS_INPORT,thisFactor,thisInfo,otherFactor);
    }

 EXIT_POINT:
    return;
}

#define MDL_SET_OUTPUT_PORT_DIMENSION_INFO
static void mdlSetOutputPortDimensionInfo(SimStruct        *S, 
                                          int_T            port,
                                          const DimsInfo_T *thisInfo)
{
    const int32_T thisFactor  = (int)(mxGetPr(TRELLIS_U_NUMBITS_ARG)[0]);
    const int32_T otherFactor = (int)(mxGetPr(TRELLIS_C_NUMBITS_ARG)[0]);
    
    /* Check input port dimensions */
    CommCheckConvCodPortDimensions(S, port, IS_OUTPORT, thisFactor, thisInfo);
    if(ssGetErrorStatus(S) != NULL) goto EXIT_POINT;
    
    /* Set input and output port dimensions */
    CommSetInputAndOutputPortDimsInfo(S,port,IS_OUTPORT,thisFactor,thisInfo,otherFactor);
 EXIT_POINT:
    return;
}

#define MDL_SET_DEFAULT_PORT_DIMENSION_INFO
static void mdlSetDefaultPortDimensionInfo(SimStruct *S)
{
    const boolean_T hasRstPort = (boolean_T)((int_T)(mxGetPr(RESET_ARG)[0]) != 0);
    if(hasRstPort){
        SetDefaultInputPortDimsWithKnownWidth(S, INPORT_RESET);
    }

    /* Set default input and output port dimensions */
    {
        boolean_T portDimsKnown = true;
        const int32_T cNumBits = (int)(mxGetPr(TRELLIS_C_NUMBITS_ARG)[0]);
        DECL_AND_INIT_DIMSINFO(dInfo);
        int_T           dims[2] = {1, 1};

        dInfo.dims = dims;
        portDimsKnown = GetDefaultInputDimsIfPortDimsUnknown(S,INPORT_DATA,
                                                             cNumBits, &dInfo);
        
        if(!portDimsKnown){
            mdlSetInputPortDimensionInfo(S, INPORT_DATA, &dInfo);
        }
    }
}

#define MDL_SET_INPUT_PORT_FRAME_DATA
static void mdlSetInputPortFrameData(SimStruct *S, 
                                     int_T     port,
                                     Frame_T   frameData)
{
    ssSetInputPortFrameData( S, port, frameData);
    if( port == INPORT_DATA){
        ssSetOutputPortFrameData(S,OUTPORT_DATA, frameData);
    }
}

#define MDL_SET_WORK_WIDTHS
static void mdlSetWorkWidths(SimStruct *S)
{        
	/*  
	 *  This is where we allocate work variables
	 *  Storage requirements:
	 *
	 *      branch metrics:  2**n, where n is the number of encoder output bits
	 *      state metrics:   # of states * 2
	 *                       (current metrics & work area to compute next metrics)
	 *      trellis:         # of states * # of branches per state * 2
	 *                       (next state & encoder output info)
	 *      traceback:       # of states * (tblen + 1 ) * 2
	 *                       (traceback state and traceback input)
	 *      misc values:     # of states (used many times in mdlOutputs)
	 *                       current trellis level (for starting traceback)
	 *                       
	 */
    const int32_T  num_states = (int32_T)(mxGetPr(TRELLIS_NUM_STATES_ARG)[0]);
    const int32_T  n          = (int32_T)(mxGetPr(TRELLIS_C_NUMBITS_ARG)[0]);
    const int_T    tblen      = (int_T)(mxGetPr(TB_ARG)[0]);
    const int_T    opmode     = (int_T)(mxGetPr(OPMODE_ARG)[0]);
    int_T          blockSize  = ssGetInputPortWidth(S, INPORT_DATA)/n;

    /* Error checking for traceback depth -- not to exceed number of symbols */  
    if(opmode != CONT && tblen > blockSize){   /* if trunc or term modes */
        if(blockSize == 1){	  /* 1 symbol, i.e. sample-based */		
            ssSetErrorStatus(S, "Use the Continuous mode "
                                "in order to use a traceback length "
                                "larger than 1 "
                                "for sample-based inputs.");
            goto EXIT_POINT;       
        }else{ /* more than 1 symbol, i.e. frame-based */
            ssSetErrorStatus(S, "The Traceback depth "
                                "cannot exceed the number "
                                "of symbols in the input frame.");
            goto EXIT_POINT;
        }
    }

    
    ssSetNumDWork(S, NUM_DWORK);
    
    ssSetDWorkWidth(        S, BMETRIC, 1<<n);
    ssSetDWorkDataType(     S, BMETRIC, SS_DOUBLE);
    ssSetDWorkComplexSignal(S, BMETRIC, COMPLEX_NO);

    ssSetDWorkWidth(        S, STATE_METRIC, num_states);
    ssSetDWorkDataType(     S, STATE_METRIC, SS_DOUBLE);
    ssSetDWorkComplexSignal(S, STATE_METRIC, COMPLEX_NO);

    ssSetDWorkWidth(        S, TEMP_METRIC, num_states);
    ssSetDWorkDataType(     S, TEMP_METRIC, SS_DOUBLE);
    ssSetDWorkComplexSignal(S, TEMP_METRIC, COMPLEX_NO);

    ssSetDWorkWidth(        S, TBSTATE, num_states*(tblen + 1));
    ssSetDWorkDataType(     S, TBSTATE, SS_INT32);
    ssSetDWorkComplexSignal(S, TBSTATE, COMPLEX_NO);

    ssSetDWorkWidth(        S, TBINPUT, num_states*(tblen + 1));
    ssSetDWorkDataType(     S, TBINPUT, SS_INT32);
    ssSetDWorkComplexSignal(S, TBINPUT, COMPLEX_NO);

    ssSetDWorkWidth(        S, TBPTR, 1);
    ssSetDWorkDataType(     S, TBPTR, SS_INT32);
    ssSetDWorkComplexSignal(S, TBPTR, COMPLEX_NO);
EXIT_POINT:
    return;
}
#endif

#ifdef  MATLAB_MEX_FILE    
#include "simulink.c"      
#else
#include "cg_sfun.h"       
#endif


