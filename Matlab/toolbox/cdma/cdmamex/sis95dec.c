/*
 *  Module Name: sis95dec.c
 *
 *  Description:
 *      This Block generates the Decoded bits from the encoded outputs and
 *      if available from a Realiability Metric too.   
 *
 *  Parameters:      
 *      0: Rate Set
 *      1: Channel Type
 *      2: TraceBackLength Ratio
 *      3: Decoded Length Ratio
 *
 *  Inputs:
 *      0: (Output) Frame rate
 *      1: This is the vector (number of elements = number of forward generators)
 *       Coded Data 
 *    
 *  Outputs:
 *      0: Hard Decision 
 *      1: Path Metric
 *
 *  Copyright 1999-2002 The MathWorks, Inc. and ALGOREX, Inc.
 *  $Revision: 1.16.2.1 $  $Date: 2004/04/12 22:59:43 $                    
 */
#define S_FUNCTION_NAME sis95dec
#define S_FUNCTION_LEVEL 2

#include "cdma_frm.h"
#include <math.h>


#define NUM_ARGS            4
#define RATE_SET_ARG        ssGetSFcnParam(S,0)
#define CHANNEL_TYPE_ARG    ssGetSFcnParam(S,1)
#define TRACEBACKLEN_ARG    ssGetSFcnParam(S,2)
#define DECODELEN_ARG       ssGetSFcnParam(S,3)

#define NUM_OUTPUT_PORTS    2
#define NUM_INPUT_PORTS	    2
#define TOTAL_PORTS         4

#define NUM_BRANCH          2
#define CTESOVA             2
#define INIT_PATH_METRIC    8192.0

enum {SYNC=0, PAGING, TRAFFIC};
enum {RATESET1=0, RATESET2};

enum {RATE_96=0,RATE_48, RATE_24, RATE_12};
enum {RATE_144=0, RATE_72, RATE_36, RATE_18};

#define P_GENBACK               params->genback
#define P_GENFORW               params->genforw
#define P_TRACEBACKLEN          params->tracBackLen
#define P_DECODELEN             params->DecLen
#define P_NUMSTATE              params->numState
#define P_NUMDELAY              params->NumDelay
#define P_NUMFORWGEN            params->numforgen
#define P_NUMINPUTS             params->numinputs  
#define P_FRAME                 params->frame
#define P_PACKLEN               params->packlen
#define P_FINAL_STATE           params->finalState
#define P_HARD_DEC_OUT_INDEX    params->hardDecOutIdx
#define P_RELTRACEBACKLEN       params->reltracebacklen
#define P_INITIAL_STATE         params->initialState
#define P_OLD_RATE              params->oldRate

#define S_pCSTBL                states->pCSTbl
#define S_CURRSTPTRS            states->currStPtrs
#define S_pPATHMETRIC           states->pPathMetric
#define S_pINTRIMPATHMET        states->pIntrimPathMet
#define S_pDECODEDTPATH         states->pDecodeDtPath
#define S_ppDECPATH             states->ppDecPath
#define S_TBLWRITE              states->tblwrite
#define S_FRAMEREAD             states->frameread
#define S_OUTWRITE              states->outwrite
#define S_OUTREAD               states->outread
#define S_OUT_WRITE_COUNTER     states->outCounter
#define S_OUTBUFF               states->outBuff

#define S_NUMBITSINFRAMETOPROCESS   states->numincomp
#define S_NUMBITSINFRAMEREMAINING   states->numbitsrem
#define S_NUMBITSINPKTREMAINING     states->numpackrem
#define S_PKT_BITS_OUTPUT           states->pktBitsOutput
#define S_OUTDATA                   states->outdata

/*Struct to handle with the three kind of outputs: Hard Decision, Reliability
update and Path metric*/
typedef struct Outstrtc{
    real_T hardDec;
    real_T relUpdate;
    real_T pathMetric;
    
} vectorOut;


/*This struct is used to build a table of all the states and the two branches
it could to come from */
typedef struct currState {
    int codeWord;
    int prevState;
    int input;
} typeConvDecCurrState, *pTypeConvDecCurrState;


typedef struct convOut{
    double brMet;
    int prevState;
    short int decData;  /* Used to get the decode data for each path */  
    
} typeConvOut, *pTypeConvOut;

/* For each state and at each time (TraceBackLength) we need to calculate the
metric of the choosen BranchThe Realiability and the transition bit as well
as the previous state*/

typedef struct StatePath {
    
    double    RelMetric;
    short int TransitionBit;
    int       PreviousState;
    double    PathMetric;
} typePathOut, *pTypePathOut;

typedef struct ConvEnc_p{
    
    real_T  *genforw;
    int      genback;
    int          tracBackLen;  
    int      DecLen;
    int      numState;
    int      NumDelay;
    int      numforgen;
    int      numinputs;
    int      frame;
    int      packlen;
    int      finalState;
    int      initialState;
    int      hardDecOutIdx;
    int      reltracebacklen;
    int      oldRate;
} tPar;

typedef struct TurbDec_s{
    
    typeConvDecCurrState   *pCSTbl;
    typeConvDecCurrState   **currStPtrs;
    double                 *pPathMetric;
    double                 *pIntrimPathMet;
    typePathOut            *pDecodeDtPath;
    typePathOut            **ppDecPath; /*Index to the different buffers*/ 
    int                    tblwrite;    /*Index for writting into ppDECPATH during forward competition*/
    int                    frameread;   /*Index that points to the input ports which each increment is done
                                        in terms of the code rate*/
    int                    outwrite;    /*index for writing into the Output Buffer*/  
    int                    outread;     /*index  for reading into the Output Buffer*/
    int                    numincomp;   /*number of inputs (each input is coderate inputs of the Input Port) 
                                        that must be calculated during forward competition*/
    int                    numbitsrem;  /*number of frame bits remaining*/  
    int                    numpackrem;  /*number of total bits remaining for reset*/
    int                    outCounter;
    int                    pktBitsOutput;
    vectorOut              *outBuff;
    real_T                 **outdata;   /*It is a pointer of addresses to the output Ports*/          
    
} tState;

int getNxtStAndCdWd2 (int state, int input,int *pGenForw, int *pCodeWd,
                      tPar *params)
{
    
    int i, ns, newinput;
    int numdelay = (int) P_NUMDELAY;
    
    /*pCodeWd follows this structure: 0 0 0 0 0 0 0 0 0 0 X Y1...Yn  Being
    X, Y1..Yn the outputs of the Turbo Encoder Where Y can be 1 or 0 (-1,1) as
    well as X   
    Note that if the system is Non-Systematic there is no X so this position
    is set to zero */
    *pCodeWd = 0;
    newinput=input&0x1;    /*Let's define A as the new Input of the Forward generators*/
    /* generate the code word */
    for (i=0; i<P_NUMFORWGEN; i++){
        int j, codeCharDelay, codeCharInput;
        int codeBit=0; 
        
        /* Code characteristic due to delay elements */
        codeCharDelay = *(pGenForw + i) & state;
        
        /* Code characteristic due to input */
        codeCharInput = *(pGenForw + P_NUMFORWGEN + i) & newinput;
        
        /* compute bit i of code word */
        for (j=0; j<numdelay; j++){
            codeBit ^= (codeCharDelay & 0x1);
            codeCharDelay >>= 1;
        }  
        codeBit ^= (codeCharInput & 0x1);
        codeCharInput >>= 1;
        /* Stuff the code bit into the code word */
        /* The LSB corr. to LSB of code word */
        *pCodeWd |= codeBit<<i;       
    }
    
    
    /* Generating the next State */
    
    {
        int psMask;
        
        /* Get each branch PS. Shift left. Insert input bit per branch. 
        Insert modified branch ps into word ns. */
        {
            int i, mask=0;
            for (i=0; i<numdelay; i++)
                mask = mask << 1 | 0x1;
            
            mask <<=0;
            psMask = mask;
        }

        ns = state;
        ns <<= 1;
        ns &= psMask;
        ns |= (newinput & 0x1);
        
    }          
    return (ns);
}

/**Function to compute Trace Back**/
void ComputeTraceBack(tPar *params, tState *states, int loop,int outputBits,
                      int lastFrameFlag)
{
    
    vectorOut *LocalBuff;
    int *pBestState,firstBitOutIndex;
    int i,j,index=0,readPath,bestState=0;
    typePathOut **ppDecPath   = (typePathOut **) S_ppDECPATH;
    
    /*allocate number of bits to be output*/
    
    
    LocalBuff = (vectorOut *) calloc(outputBits, sizeof(vectorOut ));
    pBestState=	(int *) calloc(P_TRACEBACKLEN, sizeof(int));
    
    /*Index to the Path Metric Buffer for reading*/
    readPath = S_TBLWRITE-1; 
    if(readPath<0) readPath+=P_TRACEBACKLEN;
    firstBitOutIndex=readPath+P_TRACEBACKLEN-loop+1;
    firstBitOutIndex%=P_TRACEBACKLEN;
    
    
    /*Compute Best State*/
    
    if( (P_PACKLEN!=-1) && (S_PKT_BITS_OUTPUT<= P_TRACEBACKLEN) &&
        (P_FINAL_STATE!=-1))
        
    {
        bestState=P_FINAL_STATE;
        
    }
    else
    {
        for(i=0;i<P_NUMSTATE; i++)
        {
            if((ppDecPath[i] + readPath)->PathMetric > (ppDecPath[bestState] +
                readPath )->PathMetric)
                bestState=i;
            
        } 
    }
    
    /*Compute trace back and write into BuffLocalOut from Best State*/
    for(i=0;i<loop;i++)
    {
        if(i>= loop-outputBits){
            (LocalBuff[outputBits-index-1]).hardDec= (real_T)(ppDecPath[bestState] +
                readPath)->TransitionBit;
            (LocalBuff[outputBits-index-1]).pathMetric = 
                (real_T)(ppDecPath[bestState] +  readPath)->PathMetric;
            
            index++;
        }
        /*Vector of States in survivor Path*/
        pBestState[readPath]=bestState;
        
        bestState=(ppDecPath[bestState] +  readPath)->PreviousState;
        readPath--;
        if(readPath<0) readPath+=P_TRACEBACKLEN;
    }
    
    /* UpdateOutputBuffer */
    for(j=0;j<outputBits;j++)
    {
        (S_OUTBUFF[S_OUTWRITE]).hardDec=(LocalBuff[j]).hardDec;
        (S_OUTBUFF[S_OUTWRITE]).pathMetric=(LocalBuff[j]).pathMetric;
        
        
        S_OUTWRITE++;
        S_OUTWRITE%=2*P_FRAME;
        
    }
    
    S_OUT_WRITE_COUNTER+=outputBits;
    
    /*Free Memory allocation*/
    free(LocalBuff);
    free(pBestState);
    
}


void computeFwdTrellis(InputRealPtrsType Inx,tPar *params, tState *states)
{
    
    int i;
    
    for(i=0; i<S_NUMBITSINFRAMETOPROCESS;i++)
    {
        
        pTypeConvDecCurrState *currStatePtrs = (pTypeConvDecCurrState *)
            S_CURRSTPTRS;
        double *pPathMetric     = (double *) S_pPATHMETRIC;
        double *pIntrimPathMet  = (double *) S_pINTRIMPATHMET;
        typePathOut **ppDecPath   = (typePathOut **) S_ppDECPATH;
        int state,k;
        
        /* For each received code word in the received vector
        1) Get the best branch metric for each state and update the path metric
        2) Get the index of best path metric.
        3) Get the transmitted information and insert it in the circular buffer 
        per path (state).  */
        for (state=0; state<P_NUMSTATE ; state++)
        {
            
            pTypeConvDecCurrState *currStatePtrs =
                (pTypeConvDecCurrState *) S_CURRSTPTRS;
            double *pPathMetric     = (double *) S_pPATHMETRIC;
            double *pIntrimPathMet  = (double *) S_pINTRIMPATHMET;
            typePathOut **ppDecPath = (typePathOut **) S_ppDECPATH;
            int m,l, tempPrevState;
            double tempBrMetric[2],codeBit;
            real_T InpX;
            
            for (l=0; l<NUM_BRANCH; l++)
            {
                tempPrevState = (currStatePtrs[state] + l)->prevState;
                tempBrMetric[l] = pIntrimPathMet[tempPrevState];
                
                for(m=0;m<P_NUMFORWGEN;m++)
                {
                    codeBit = (double) (((currStatePtrs[state] + l)->
                        codeWord & 0x1<<m)>>m);
                    tempBrMetric[l] +=(double) *Inx[ S_FRAMEREAD*P_NUMFORWGEN +m] * (-2 * codeBit + 1);
                    
                }  
            } 
            
            if(tempBrMetric[0]>tempBrMetric[1])
            {
                (ppDecPath[state] + S_TBLWRITE )->TransitionBit =
                    (currStatePtrs[state] + 0)->input;
                (ppDecPath[state] + S_TBLWRITE )->PreviousState =
                    (currStatePtrs[state] + 0)->prevState;
                (ppDecPath[state] + S_TBLWRITE )->PathMetric = tempBrMetric[0];
                pPathMetric[state]=tempBrMetric[0];
                
            }
            else
            {
                (ppDecPath[state] + S_TBLWRITE )->TransitionBit = 
                    (currStatePtrs[state] + 1)->input;
                (ppDecPath[state] + S_TBLWRITE )->PreviousState = 
                    (currStatePtrs[state] + 1)->prevState;
                (ppDecPath[state] + S_TBLWRITE )->PathMetric = tempBrMetric[1];
                pPathMetric[state]=tempBrMetric[1];
            }
            
            
            (ppDecPath[state] + S_TBLWRITE )->RelMetric = (double)fabs(tempBrMetric[0]-tempBrMetric[1]);
            
            /*Convert to Soft Decision*/
            (ppDecPath[state] + S_TBLWRITE )->RelMetric*=(1-2*((ppDecPath[state] +
                S_TBLWRITE )->TransitionBit));
            
            
        }
        
        /* Update the intermediate buffers */
        for (k = 0; k<P_NUMSTATE ; k++)
            pIntrimPathMet[k] = pPathMetric[k];
        
        /***Modifie Read Pointer for next State in Trellis***/
        S_TBLWRITE++;   
        S_TBLWRITE%=P_TRACEBACKLEN;
        S_FRAMEREAD++;  
        /*At the end of the function must be set to zero for the next Frame*/
    }
    
}

/*====================================================================*
* Parameter handling methods. These methods are not supported by RTW *
*====================================================================*/

#define MDL_CHECK_PARAMETERS   /* Change to #undef to remove function */
#if defined(MDL_CHECK_PARAMETERS) && defined(MATLAB_MEX_FILE)
static void mdlCheckParameters(SimStruct *S) {
    int chType, rateSet;
    const char *msg = NULL;
    
    if ((mxGetM(CHANNEL_TYPE_ARG)*mxGetN(CHANNEL_TYPE_ARG) != 1) ||
        ((mxGetPr(CHANNEL_TYPE_ARG)[0] != (real_T) 1.0) &&
        (mxGetPr(CHANNEL_TYPE_ARG)[0] != (real_T) 2.0) &&
        (mxGetPr(CHANNEL_TYPE_ARG)[0] != (real_T) 3.0))) {
        msg = "Channel type must be 1, 2 or 3";
        goto ERROR_EXIT;
    }
    
    
    if ((mxGetM(RATE_SET_ARG)*mxGetN(RATE_SET_ARG) != 1) ||
        ((mxGetPr(RATE_SET_ARG)[0] != (real_T) 1.0) &&
        (mxGetPr(RATE_SET_ARG)[0] != (real_T) 2.0))) {
        msg = "Rate set must be 1 or 2";
        goto ERROR_EXIT;
    }
    
    chType  = (int) mxGetScalar(CHANNEL_TYPE_ARG) - 1;
    rateSet = (int) mxGetScalar(RATE_SET_ARG) - 1;
    if ((chType != TRAFFIC) && (rateSet != RATESET1)){
        msg = "Rate set for Paging and Sync channel must be Rate Set I";
        goto ERROR_EXIT;
        
    }
    
    if ( (mxGetM(TRACEBACKLEN_ARG)*mxGetN(TRACEBACKLEN_ARG)) != 1 || 
        (mxGetPr(TRACEBACKLEN_ARG)[0]>1.0) || (mxGetPr(TRACEBACKLEN_ARG)[0]<=0) ){
        msg = "Ratio of trace-back length to frame length must be a positive scalar less than or equal to 1.0";
        goto ERROR_EXIT;
    }
    
    if (((mxGetPr(DECODELEN_ARG)[0])/(mxGetPr(TRACEBACKLEN_ARG)[0])) >1.0){
        msg = "Trace-back length must be larger than the decode length";
        goto ERROR_EXIT;
    }
    
    if ( (mxGetM(DECODELEN_ARG)*mxGetN(DECODELEN_ARG)) != 1 || 
        (mxGetPr(DECODELEN_ARG)[0]>1.0) || (mxGetPr(DECODELEN_ARG)[0]<=0) ){
        msg = "Ratio of decoding length to frame length must be a positive scalar less than or equal to 1.0";
        goto ERROR_EXIT;
    }
    
    
ERROR_EXIT:
    
    if (msg != NULL) {
        ssSetErrorStatus(S,msg);
        return;
    }
    
}
#endif /* MDL_CHECK_PARAMETERS */
#undef MDL_PROCESS_PARAMETERS   /* Change to #undef to remove function */


/*====================*
* S-function methods *
*====================*/

/* Function: mdlInitializeSizes ===============================================
* Abstract:
*    The sizes information is used by Simulink to determine the S-function
*    block's characteristics (number of inputs, outputs, states, etc.).
*/
static void mdlInitializeSizes(SimStruct *S)
{
     int i;

    ssSetNumSFcnParams(S, NUM_ARGS);
#if defined(MATLAB_MEX_FILE)
    if (ssGetNumSFcnParams(S) == ssGetSFcnParamsCount(S)) {
        mdlCheckParameters(S);
        if (ssGetErrorStatus(S) != NULL) {
            return;
        }
    } else {
        return; /* Simulink will report a parameter mismatch error */
    }
#endif
    
    for (i=0; i< NUM_ARGS; i++){
        ssSetSFcnParamNotTunable(S, i);
    }
    
    ssSetNumContStates(    S, 0);               /* number of continuous states           */
    ssSetNumDiscStates(    S, 0);               /* number of discrete states             */
    ssSetNumSampleTimes(   S, 1);               /* number of sample times                */
    ssSetNumRWork(         S, 0);               /* number of real work vector elements   */
    ssSetNumIWork(         S, 1);               /* number of integer work vector elements*/
    ssSetNumPWork(         S, 2);               /* number of pointer work vector elements*/
    
    if (!ssSetNumInputPorts(S, 2)) return;
    /* Rate input */
    ssSetInputPortVectorDimension(   S, 0, 1);
    ssSetInputPortFrameData(         S, 0, FRAME_NO);
	ssSetInputPortDirectFeedThrough( S, 0, 1);

    /* Data input */
    if (!ssSetInputPortDimensionInfo(S, 1, DYNAMIC_DIMENSION)) return;
    ssSetInputPortFrameData(         S, 1, FRAME_INHERITED);
	ssSetInputPortDirectFeedThrough( S, 1, 1);

    /* Output */
    if (!ssSetNumOutputPorts(S, 2)) return;
    if (!ssSetOutputPortDimensionInfo(S, 0, DYNAMIC_DIMENSION)) return;
    ssSetOutputPortFrameData(         S, 0, FRAME_INHERITED);

    ssSetOutputPortVectorDimension(   S, 1, 1);
    ssSetOutputPortFrameData(         S, 1, FRAME_NO);
    
    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE);   /* general options (SS_OPTION_xx)        */
}

/* Function: detAllPortWidths
 * Purpose: Determine the widths for the input and output ports based 
 *          on the parameters passed in. The widths are stored in an int
 *          array with first the input widths and then the outputs.
 */
void detAllPortWidths(SimStruct *S, int *widths)
{
    /* Inputs */
    widths[0] = 1;
    widths[1] = 576;

    /* Outputs */
    widths[2] = 288;
}

#if defined(MATLAB_MEX_FILE)
#define MDL_SET_INPUT_PORT_FRAME_DATA
static void mdlSetInputPortFrameData(SimStruct *S, int_T portIdx,
                                         Frame_T frameData)
{
    if (portIdx == 1){
        ssSetInputPortFrameData(S, 1, frameData);
	    ssSetOutputPortFrameData(S, 0, frameData);
    }
}
#endif

/* For dimension propagation and frame support */
#define NUM_INPORTS_TO_SET  2
#define FIRST_INPORTIDX_TO_SET 1  /* Start from second port */
#define NUM_OUTPORTS_TO_SET 1
#define TOTAL_PORTS_TO_SET  3  

#include "cdma_dim_hs.c"


/* Function: mdlInitializeSampleTimes =========================================
* Abstract:
*    This function is used to specify the sample time(s) for your
*    S-function. You must register the same number of sample times as
*    specified in ssSetNumSampleTimes.
*/

static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);
}


#define MDL_INITIALIZE_CONDITIONS   /* Change to #undef to remove function */
#if defined(MDL_INITIALIZE_CONDITIONS)
/* Function: mdlInitializeConditions ========================================
* Abstract:
*    In this function, you should initialize the continuous and discrete
*    states for your S-function block.  The initial states are placed
*    in the state vector, ssGetContStates(S) or ssGetRealDiscStates(S).
*    You can also perform any other initialization activities that your
*    S-function may require. Note, this routine will be called at the
*    start of simulation and if it is present in an enabled subsystem
*    configured to reset states, it will be call when the enabled subsystem
*    restarts execution to reset the states.
*/
/* mdlInitializeConditions - initialize the states */
static void mdlInitializeConditions( SimStruct *S)
{
    int index;     
    
    int rateSet = (int) mxGetPr(RATE_SET_ARG)[0] - 1;
    int chType =  (int) mxGetPr(CHANNEL_TYPE_ARG)[0] -1;
    tPar   *params  = (tPar *)   calloc(1,sizeof(tPar));
    tState *states  = (tState *) calloc(1,sizeof(tState));
    
    P_GENFORW       =  (real_T *) calloc(2 * 2,sizeof(real_T));
    P_NUMFORWGEN    =  2;
    P_GENFORW[0]    = 431.0;	P_GENFORW[1] = 285.0;
    P_GENBACK       = 1; /* Also currently non-SOVA and Non-SYSTEMATIC */
       
    /* Get Initial Frame Char */
    switch(chType){
    case SYNC: P_FRAME = 32; break;
    case PAGING:P_FRAME = 192;break;
    case TRAFFIC: if (rateSet) P_FRAME = 288;
        else P_FRAME = 192;
        break;
    default: P_FRAME = -1;
    }
    if ((chType == SYNC) || (chType==PAGING)){
        P_PACKLEN = -1; 
        P_INITIAL_STATE = -1;
        P_FINAL_STATE = -1;
    }
    else{
        P_PACKLEN =  P_FRAME;
        P_INITIAL_STATE = 0;
        P_FINAL_STATE = 0;
    }

    if (P_FRAME==-1){
        ssSetErrorStatus(S, "Incorrect Maximum Frame Size");
        return;
    }
    
    P_OLD_RATE = -1; /* Allows inital setting of parameters for actual rate */
    
    P_NUMDELAY =  0; 
    for (index=0; index<P_NUMFORWGEN; index++){
        int x = (int) floor(log10((double) P_GENFORW[index]) / log10(2.0));
        
        if (x > P_NUMDELAY)
            P_NUMDELAY = x;
    }
    
    if (P_NUMDELAY == 0){
        ssSetErrorStatus(S, "Coding Constraint Length must be a strictly positive number");
        return;
    }
    P_NUMSTATE     =  (int) pow(2.0, (double) P_NUMDELAY);
    
    P_TRACEBACKLEN    = (int) (mxGetScalar(TRACEBACKLEN_ARG) * P_FRAME); 
    P_DECODELEN       = (int) (mxGetScalar(DECODELEN_ARG)    * P_FRAME);
    P_RELTRACEBACKLEN = (int) 0; 
    
    
    /*We need to allocate space for the BUFFERS we use to store the information*/
    S_pCSTBL         = (typeConvDecCurrState *)  calloc(P_NUMSTATE * NUM_BRANCH,
        sizeof(typeConvDecCurrState));
    S_CURRSTPTRS     = (pTypeConvDecCurrState *) calloc(P_NUMSTATE,
        sizeof(pTypeConvDecCurrState));
    S_pPATHMETRIC    = (double *)      calloc(P_NUMSTATE, sizeof(double));
    S_pINTRIMPATHMET = (double *)      calloc(P_NUMSTATE, sizeof(double));
    
    /*For S_pDECODEDTPATH we need to allocate enogh memory to create a circular Buffer*/
    S_pDECODEDTPATH  = (typePathOut *)  calloc(P_NUMSTATE * P_TRACEBACKLEN, sizeof(typePathOut)); 
    S_ppDECPATH      = (pTypePathOut *) calloc(P_NUMSTATE, sizeof(pTypePathOut)); 
    
    /*The Decoded Data (Hard Decision) is first output to this buffer and after it output in blocks of 
    Frame Length to the output Port. That introduces a maximum delay of one frame if within the first Frame
    the number of outputs in the Buffer is less than Frame Length. VectOut is a Struct of three values:
    Hard Decision, Reliability Update and Path Metric which are the three possible outputs
    */
    
    S_OUTBUFF        = (vectorOut *) calloc(2*P_FRAME, sizeof(vectorOut ));
    
    /*********Just to handle with different number of output Ports*******/
    S_OUTDATA        = (real_T **)           calloc(NUM_OUTPUT_PORTS, sizeof(real_T *));
    
    /*Initilize Index to the Buffers: Input Port, OutBuff and ppDecpath for forwrd competition*/
    
    S_FRAMEREAD = 0;
    S_TBLWRITE  = 0;
    S_OUTWRITE  = 0;
    S_OUTREAD   = 0;
    S_OUT_WRITE_COUNTER = 0;
    
    S_NUMBITSINFRAMEREMAINING = P_FRAME;        /*Number of bits remaining from the Frame that are not yet 
    used for Forward computation*/
    S_NUMBITSINFRAMETOPROCESS = P_TRACEBACKLEN; /*Bits to process Forward computation in next step*/
    S_NUMBITSINPKTREMAINING   = P_PACKLEN;      /*Bits from Packet still remainig to compute Forward computation */
    S_PKT_BITS_OUTPUT = P_PACKLEN;              /*Number of packet bits still to be output*/
    
    /* Initial State is increased to cause its election during trace back */
    if (P_INITIAL_STATE != -1)
        *(S_pINTRIMPATHMET + P_INITIAL_STATE) = INIT_PATH_METRIC;  
    
#ifdef MATLAB_MEX_FILE
    if ((params==NULL) || (states==NULL) || (S_pCSTBL==NULL) || (S_CURRSTPTRS==NULL) || (S_pPATHMETRIC==NULL) ||
        (S_pINTRIMPATHMET==NULL) || (S_pDECODEDTPATH==NULL) ||  (S_ppDECPATH==NULL) ||  (S_OUTDATA==NULL)||(S_OUTBUFF==NULL)){
        ssSetErrorStatus(S,"Not enough memory to allocate for work vectors");
        return;
    }
#endif
    
    /* Initialize the array of pointers to beginning of the memory sections for each pointer */
    for (index=0; index<P_NUMSTATE; index++){
        S_CURRSTPTRS[index] = S_pCSTBL         + index *  NUM_BRANCH;
        S_ppDECPATH[index]  = S_pDECODEDTPATH  + index * P_TRACEBACKLEN;
        
    }
    /* compute the cSTable enteries. That is for each current state, the following informations are stored:
    /        a) The codeword,
    /        b) previous state that it came from,
    /        c) the input pattern associated with the transition.
    */
    
    /* get Current State Table */
    {
        pTypeConvDecCurrState *currStatePtrs = (pTypeConvDecCurrState *) S_CURRSTPTRS;
        int  i, ps, ns, codeWd;  
        int *pGenForw=(int *) calloc(2*P_NUMFORWGEN, sizeof(int));
        
        /* Declare an array of state segment pointers */
        /* Present, next state and pointer to packed generator variables */
        /* The last P_NUMFORWGEN positions in pGenForw have the last bit of 
        P_GENFORW that means the one that allows to compute the code characteristic
        due to the Input-> Order:  Gn....G0*/  
        
        for (i=0; i<P_NUMFORWGEN; i++){
            int temp;
            
            temp = (int) *(P_GENFORW + i);
            pGenForw[i + P_NUMFORWGEN] = (temp & 0x1);
            temp >>= 1;      /* Eliminate the g0 bit */
            pGenForw[i] = temp;
        }
        /* Now
        a: for each possible input and present state, it generates the codeword
        (the two last bits are two (X,Y) of the three outputs in the Turboencoder
        for the ps state and the input) and next state.
        b: update the currState table
        */
        for (ps=0; ps<P_NUMSTATE; ps++)
        {
            for (i=0; i<NUM_BRANCH; i++)
            {
                ns = getNxtStAndCdWd2(ps, i,pGenForw , &codeWd,params);
                /* Updating the currState table */
                currStatePtrs[ns]->codeWord = codeWd;
                currStatePtrs[ns]->prevState = ps;
                currStatePtrs[ns]->input = i;
                currStatePtrs[ns]++;
                
            }
        }
        
        free(pGenForw);
    }

    for (index=0; index<P_NUMSTATE; index++){
        S_CURRSTPTRS[index] = S_pCSTBL + index * NUM_BRANCH;
    }      
    ssSetPWorkValue(S, 0, params);
    ssSetPWorkValue(S, 1, states);
    ssSetIWorkValue(S, 0, 0);
}

#endif /* MDL_INITIALIZE_CONDITIONS */

#undef MDL_START  /*Change to #undef to remove function*/


/* Function: mdlOutputs =======================================================
* Abstract:
*    In this function, you compute the outputs of your S-function
*    block. Generally outputs are placed in the output vector, ssGetY(S).
*/
static void mdlOutputs( SimStruct *S, int tid)
{
    int insize,outsize,j, rate, error=0;
    real_T **OutData;
    const char *msg = NULL;
    InputRealPtrsType  pRate  = ssGetInputPortRealSignalPtrs(S,0);
    InputRealPtrsType  InData = ssGetInputPortRealSignalPtrs(S,1);
    tPar   *params = (tPar  *)  ssGetPWorkValue(S,0);
    tState *states = (tState *) ssGetPWorkValue(S,1);
    
    int rateSet = (int) mxGetPr(RATE_SET_ARG)[0]-1;
    int chType =  (int) mxGetPr(CHANNEL_TYPE_ARG)[0]-1;
    real_T traceBackLenRatio = mxGetPr(TRACEBACKLEN_ARG)[0];
    real_T decodeLenRatio    = mxGetPr(DECODELEN_ARG)[0];
    
    rate = (int)(*pRate[0]);
    
#ifdef MATLAB_MEX_FILE
    
    switch(chType){
    case SYNC: 
        if (rate != RATE_12){
            msg = "Data rate for Sync channel must be eighth rate";
            goto ERROR_EXIT;
        }
        break;
    case PAGING:
        if ((rate!=RATE_96) && (rate!=RATE_48)){
            msg = "Data rate for Paging channel must be full or half rate";
            goto ERROR_EXIT;
        }
        
        break;
    case TRAFFIC:
        if ((rate!=RATE_96) && (rate!=RATE_48) && (rate!=RATE_24) && (rate!=RATE_12)){
            msg = "Data rate for Traffic channel is incorrect";
            goto ERROR_EXIT;
        }
        break;	
ERROR_EXIT:	
        if (msg != NULL) {
            ssSetErrorStatus(S,msg);
            return;
        }
    }
#endif
    if (P_OLD_RATE != (int)(**pRate)) {
        switch(chType){
        case SYNC: P_FRAME = 32; break;
        case PAGING:
            if (rate)
                P_FRAME = 96;
            else
                P_FRAME = 192;
            break;
        case TRAFFIC:
            if (rateSet) /* Case Rate Set II */
                switch (rate){
                case 0:P_FRAME = 288;break;
                case 1:P_FRAME = 144;break;
                case 2:P_FRAME = 72;break;
                case 3:P_FRAME = 36;break;
            }
            else		/* Case Rate Set I */
                switch (rate){
                case 0:P_FRAME = 192;break;
                case 1:P_FRAME = 96;break;
                case 2:P_FRAME = 48;break;
                case 3:P_FRAME = 24;break;
            }
            break;
        default: error = -1;P_FRAME = 192;  
        }
        if ((chType == SYNC) || (chType==PAGING))
            P_PACKLEN = -1;
        else
            P_PACKLEN =  (int) P_FRAME; 
        
        P_TRACEBACKLEN  = traceBackLenRatio * P_FRAME; 
        P_DECODELEN     =  decodeLenRatio * P_FRAME;
        
        S_NUMBITSINFRAMEREMAINING = P_FRAME;        /*Number of bits remaining from the Frame that are not yet 
        used for Forward computation*/
        S_NUMBITSINFRAMETOPROCESS = P_TRACEBACKLEN; /*Bits to process Forward computation in next step*/
        S_NUMBITSINPKTREMAINING   = P_PACKLEN;      /*Bits from Packet still remainig to compute Forward computation*/
        S_PKT_BITS_OUTPUT = P_PACKLEN;              /*Number of packet bits still to be output*/
        P_OLD_RATE = rate;
        error = 0;
    }
    if (error) {
        ssSetErrorStatus(S,"Incorrect parameter setings");
        return;
    }
    
    
    OutData = S_OUTDATA;
    
    InData= ssGetInputPortRealSignalPtrs(S,1);  
    for(j=0;j<NUM_OUTPUT_PORTS;j++){
    OutData[j]=ssGetOutputPortRealSignal(S,j); /* The order of the output ports is the following:
                                               0: Decoded Data
                                               1: PathMetric
    */
    }
    
    /* core function */
    {
        int lastFrameFlag=0,numOfTracebacks=0;
        typePathOut **ppDecPath   = (typePathOut **) S_ppDECPATH;
        double *pPathMetric     = (double *) S_pPATHMETRIC;
        double *pIntrimPathMet  = (double *) S_pINTRIMPATHMET;
        int okayFlag=1;
        
        /*Some LOGIC*/
        
        if(S_NUMBITSINPKTREMAINING!=-1)
        {
            if(S_NUMBITSINPKTREMAINING<=P_FRAME)
            {
                lastFrameFlag=1;
                S_NUMBITSINFRAMEREMAINING=S_NUMBITSINPKTREMAINING;
                if(S_NUMBITSINPKTREMAINING<S_NUMBITSINFRAMETOPROCESS)
                    S_NUMBITSINFRAMETOPROCESS=S_NUMBITSINPKTREMAINING;
            }
        }
        
        /*************/
        
        while(okayFlag)
        {
            /******************Compute trace Forward***********************************/
            computeFwdTrellis(InData,params,states);
            
            /*********************Compute TraceBack************************************/
            ComputeTraceBack(params, states, P_TRACEBACKLEN,P_DECODELEN,lastFrameFlag);
            S_PKT_BITS_OUTPUT-= P_DECODELEN;
            numOfTracebacks++;
            
            S_NUMBITSINFRAMEREMAINING-=S_NUMBITSINFRAMETOPROCESS;
            
            /*Check if it is continuous or discontinuous decoder*/
            
            if(P_PACKLEN!=-1)
                S_NUMBITSINPKTREMAINING-=S_NUMBITSINFRAMETOPROCESS;
            
            /*Update number of Input Bits to process in this frame*/
            
            if(S_NUMBITSINFRAMEREMAINING>=P_DECODELEN)
                S_NUMBITSINFRAMETOPROCESS=P_DECODELEN;
            else
            {
                S_NUMBITSINFRAMETOPROCESS=S_NUMBITSINFRAMEREMAINING;
                okayFlag=0;
            }
            
        } /* while */
        
        
        if(S_NUMBITSINFRAMETOPROCESS>0)
        {
            computeFwdTrellis(InData,params,states);
            if(P_PACKLEN!=-1)
                S_NUMBITSINPKTREMAINING-=S_NUMBITSINFRAMETOPROCESS;
        }
        
        
        S_NUMBITSINFRAMEREMAINING=P_FRAME;
        if(lastFrameFlag==0)
        {
            
            S_NUMBITSINFRAMETOPROCESS=P_DECODELEN -S_NUMBITSINFRAMETOPROCESS;
        }
        
        else
        {
            /*This is the last Frame of Packet- So perform trace Back of remaining bits*/
            if(S_PKT_BITS_OUTPUT>0)
                ComputeTraceBack(params, states, S_PKT_BITS_OUTPUT,
                S_PKT_BITS_OUTPUT,lastFrameFlag);
            
            S_NUMBITSINPKTREMAINING=P_PACKLEN;
            S_NUMBITSINFRAMETOPROCESS=P_TRACEBACKLEN;
            S_PKT_BITS_OUTPUT=P_PACKLEN;
            
            /* reset decoder */
            {
                int i;
                
                /*Re-initialize traceback write pointerto zero*/
                
                S_TBLWRITE=0;
                S_NUMBITSINFRAMETOPROCESS=P_TRACEBACKLEN;
                
                for (i=0; i< P_NUMSTATE; i++)           
                    *(S_pPATHMETRIC + i) = *(S_pINTRIMPATHMET + i) = 0.0; 
                
                /*First State is P_INITIAL STATE*/
                
                if(P_INITIAL_STATE!=-1)
                    *(S_pINTRIMPATHMET + P_INITIAL_STATE)=10000;
            }
            
        }
        
        /* writeOutputPort */
        {
            
            real_T *DecOut,*PathMetric,*ReliabiltyUpdate, Temp=0.0;
            
            int i;
            
            DecOut=OutData[P_HARD_DEC_OUT_INDEX];
            PathMetric=OutData[P_HARD_DEC_OUT_INDEX+1];
            
            if(S_OUT_WRITE_COUNTER>=P_FRAME)
            {
                for(i=0;i<P_FRAME;i++)
                {
                    DecOut[i]=(S_OUTBUFF[S_OUTREAD]).hardDec;
                    if ((S_OUTBUFF[S_OUTREAD]).pathMetric > Temp )
                        Temp = (S_OUTBUFF[S_OUTREAD]).pathMetric;
                    
                    
                    S_OUTREAD++;
                    S_OUTREAD%=2*P_FRAME;
                    
                }
                S_OUT_WRITE_COUNTER-=P_FRAME;
                PathMetric[0] = (Temp - INIT_PATH_METRIC) / P_FRAME;
                
                
            }
        }
        
        S_FRAMEREAD=0;
        
    }

}

static void mdlUpdate(SimStruct *S, int tid)
{
}

static void mdlDerivatives( SimStruct *S)
{
}

static void mdlTerminate(SimStruct *S)
{
    tPar *params   = ssGetPWorkValue(S, 0);
    tState *states = ssGetPWorkValue(S, 1);
    
    /*We need to free all the space*/
    free(S_pCSTBL);     
    free(S_CURRSTPTRS);    
    free(S_pPATHMETRIC);   
    free(S_pINTRIMPATHMET); 
    free(S_pDECODEDTPATH);
    free(S_ppDECPATH); 
    free(S_OUTDATA);
    free(S_OUTBUFF);
    free(P_GENFORW);
    free(states);
    free(params);
}

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
