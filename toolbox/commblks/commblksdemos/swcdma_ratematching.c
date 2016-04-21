/*************************************************************
 *   WCDMA RATE MATCHING performs rate matching algorithm
 *   as specified by 3GPP TS 25.212
 *
 *   Copyright 1996-2002 The MathWorks, Inc.
 *   $Revision: 1.2 $  $Date: 2002/04/11 00:48:54 $
 *************************************************************/

#define S_FUNCTION_NAME swcdma_ratematching
#define S_FUNCTION_LEVEL 2

#include <comm_defs.h>

/* List input & output ports */
enum {INPORT=0, NUM_INPORTS}; 
enum {OUTPORT=0, NUM_OUTPORTS};

/* List the mask parameters */
enum {DELNIMAX_ARGC=0, NUMBITS_ARGC, ERRORCORR_ARGC, CHECKRM_ARGC, NUM_ARGS}; 

#define DELNIMAX_ARG    ssGetSFcnParam(S, DELNIMAX_ARGC)
#define NUMBITS_ARG     ssGetSFcnParam(S, NUMBITS_ARGC)
#define ERRORCORR_ARG   ssGetSFcnParam(S, ERRORCORR_ARGC)
#define CHECKRM_ARG     ssGetSFcnParam(S, CHECKRM_ARGC)

/* Define pWork Structure */
typedef struct{

    /* Pattern index vector indicating the i/p bits to be punctured or repeated*/  
    int_T   *pPattern; 
    
    /* Used to indicate either parity bit stream of Turbo coded bits or otherwise*/ 
    int_T   b;         
    
    /* Length the i/p vector on which rate matching is done(numbits or numbits/3)*/
    int_T   *X;
    
    /* Parameters used during rate matching process */             
    int_T   *pEIni;     /*eini*/    
    int_T   *pEPlus;    /*eplus*/
    int_T   *pEMinus;   /*eminus*/
    
    /*Parameter indicating number of bits to be punctured(<0) or repeated (>0)
    Here 'deltaNi' refers to 'deltaNimax' referred in 3GPP specifications */
    int_T   deltaNi;       
    
    /*Indicates if Rate Matching or Rate De-matching*/     
    int_T   checkRM;       
    
    /*Number of bits entering the block for rate matching*/    
    int_T   numBitsIn;     

}TRmPar;

#define parPattern       rmPar->pPattern
#define parB             rmPar->b
#define parX             rmPar->X
#define parEini          rmPar->pEIni
#define parEplus         rmPar->pEPlus
#define parEminus        rmPar->pEMinus
#define parDeltaNi       rmPar->deltaNi
#define parCheckRM       rmPar->checkRM
#define parNumBitsIn	 rmPar->numBitsIn

#define RMATCHING       0
#define RDEMATCHING     1
  
/*Function to determine the Rate Matching Parameters
          X, eini, eplus and eminus*/
static void getRMParameters(TRmPar *rmPar)
{
   int_T a,k;
   if(parB == 1) /*Convolutional Encoding or Turbo coding with repetition*/
   {
       a = 2;
       parX[0]         = parNumBitsIn;
       parEini[0]      = 1;
       parEplus[0]     = a * parNumBitsIn;
       parEminus[0]    = a * abs(parDeltaNi);
   }                    
   else        /* Turbo coding with puncturing */
   {       
       for(k=1;k<3;k++)
           {   /*k=0 not required as that corresponds to the first case
               of no/convolutional coding or Turbo coding with repetition*/
               a = 3-k;            /* a=2 for b=2 and a=1 for b=3 */
               parX[k]         = (int_T) parNumBitsIn/3;
               parEini[k]      = (int_T) parNumBitsIn/3;
               parEplus[k]     = a*(int_T) (parNumBitsIn/3);
           }
       parEminus[1] = 2 * abs((int_T) floor(parDeltaNi/2.0));
       parEminus[2] = abs((int_T) ceil(parDeltaNi/2.0));
   }
} /* End of Function rmParams */    


/* Function to calculate the Rate Matching Pattern vector ==================*/
static void rmPatternDetermination(TRmPar *rmPar, int_T *tempPat, int_T B)
{
/*  This function returns a vector of the same size as 
    that of numBitsIn with -1s in place of bits that needs to be 
    punctured and numbers in place of bits that needs to 
    be repeated indicating how many times they need to 
    be repeated */

   int_T e, m, n;
   
   /* Initial error between current and desired puncturing ratio */   
   e = parEini[B]; 
   
   if (parDeltaNi<0) /* Puncturing */
   {   
      for (m=0; m<parX[B]; m++)
      {
         e = e - parEminus[B]; /* Update error */
         if(e<=0) 
         {
             tempPat[m] = -1; /* Mark puncturing */
             e = e + parEplus[B];  /* Update error */
         } 
         else
            tempPat[m] = 0; /* Mark bit as no puncturing */
      }
   }
   else if (parDeltaNi>0) /* Repetition */
   {
      for (m=0; m<parX[B]; m++)
      {
          e = e - parEminus[B]; /* Update error */
          n = 0;
          while(e<=0)
          {   
              e = e + parEplus[B];  /* Update error */
              n++;
          }
          tempPat[m] = n; /* Mark repetition */
      }  
   }
   /*Else Do nothing as CALLOC initializes all the values to zero*/           
   
} /* End of Function rmPatternDetermination */    
  

/* Function to find the final output vector 
   given the RM puncturing or repetition pattern */
static void rmComputeOutputVec(real_T *outData, real_T *inData, TRmPar *rmPar)
{
   int_T k,i,outCount, inCount;
   real_T aver;

   /* Rate Matching Case */
   if (parCheckRM == RMATCHING)
   {
      for (k=0, outCount=0; k<parNumBitsIn; k++)
      {   
          if (parPattern[k] == -1) 
          {   /* Puncture */
              /* Increment input counter (k) */
          }       
          else if(parPattern[k]>0) /* Repetition */
          {
              for(i=0;i<parPattern[k]+1;i++)
              {
                 outData[outCount] = inData[k];
                 outCount ++;
              }
          }
          else /*Pass Input as Output without any change*/
          {
              outData[outCount] = inData[k];
              outCount ++;
          }
      }
    }
    else /* Rate Dematching case */
    {
       for (k=0, inCount=0; k<parNumBitsIn; k++)
       {
           if (parPattern[k] == -1) /* Pad with zeros */ 
           outData[k] = 0; 

           else if(parPattern[k]>0) /*Derepetition */
           {
                /* Compute average of repeated symbols */
               for(i=0, aver=0; i<parPattern[k]+1; i++)
               {
                   aver += inData[inCount];
                   inCount++;
               }
                   outData[k] = aver/(parPattern[k]+1);  
           }
           else /* Pass Input as Output */
           {
               outData[k] = inData[inCount];
               inCount ++;
           }
       }
     }
}/* End of Function rmComputeOutputVec */    


/* Function: mdlCheckParameters */
#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S) 
{
    int_T numDelnimax, numNumbits, numErrorcorr, numCheckrm;
    real_T valDelnimax, valNumbits, valErrorcorr, valCheckrm;

    numDelnimax     = (int_T) mxGetNumberOfElements(DELNIMAX_ARG);
    numNumbits      = (int_T) mxGetNumberOfElements(NUMBITS_ARG);
    numErrorcorr    = (int_T) mxGetNumberOfElements(ERRORCORR_ARG);
    numCheckrm      = (int_T) mxGetNumberOfElements(CHECKRM_ARG);
    
    valDelnimax     = (real_T)(mxGetPr(DELNIMAX_ARG))[0];
    valNumbits      = (real_T)(mxGetPr(NUMBITS_ARG))[0];
    valErrorcorr    = (real_T)(mxGetPr(ERRORCORR_ARG))[0];
    valCheckrm      = (real_T)(mxGetPr(CHECKRM_ARG))[0];
   
    if ( (numDelnimax != 1) ) 
    {
    	THROW_ERROR(S,"Parameter DELNIMAX must be a scalar");
    }
    else if((numNumbits != 1)||(valNumbits < 0) || (floor(valNumbits)!=valNumbits) )
    {
        THROW_ERROR(S,"Value for the number of bits entering the block must be a scalar non-negative integer");
    }
    else if ((numErrorcorr != 1)||(valErrorcorr < 0)|| (floor(valErrorcorr)!=valErrorcorr))
    {
        THROW_ERROR(S,"Parameter indicating the error correction mode must be a scalar non-zero, non-negative integer less than or equal to 3.");
    }
    else if((numCheckrm != 1)||(valCheckrm < 0)|| (floor(valCheckrm)!=valCheckrm))
    {
        THROW_ERROR(S,"Parameter indicating the rate matching/de-matching mode must be a scalar non-negative integer");
    }
}
#endif

/* Function: mdlInitializeSizes */
static void mdlInitializeSizes(SimStruct *S)
{
    int i;
    ssSetNumSFcnParams(S, NUM_ARGS);

    #if defined(MATLAB_MEX_FILE)
        if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) return;
            mdlCheckParameters(S);
        if (ssGetErrorStatus(S) != NULL) return;
    #endif

    ssSetNumSampleTimes(S, 1);

    /* Input: */
    if (!ssSetNumInputPorts(S, NUM_INPORTS)) return;
    if (!ssSetInputPortDimensionInfo(S, INPORT, DYNAMIC_DIMENSION)) return;
    ssSetInputPortFrameData(         S, INPORT, FRAME_YES);
    ssSetInputPortComplexSignal(     S, INPORT, COMPLEX_NO);
    ssSetInputPortDirectFeedThrough( S, INPORT, 1);
    ssSetInputPortRequiredContiguous(S, INPORT, 1);
    ssSetInputPortReusable(          S, INPORT, 0);

    /* Output: */
    if (!ssSetNumOutputPorts(S, NUM_OUTPORTS)) return;
    if (!ssSetOutputPortDimensionInfo(S, OUTPORT, DYNAMIC_DIMENSION)) return;
    ssSetOutputPortFrameData(         S, OUTPORT, FRAME_YES);
    ssSetOutputPortComplexSignal(     S, OUTPORT, COMPLEX_NO);
    ssSetOutputPortReusable(          S, OUTPORT, 0);
    
    for (i=0; i<NUM_ARGS; i++)
        ssSetSFcnParamNotTunable(S, i);

    /* Initialize the Work Vector to be used for the index vector*/
    ssSetNumPWork(S, 1);

}

/* Function: mdlInitializeSampleTimes */
static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);

    if (ssGetSampleTime(S,0) == CONTINUOUS_SAMPLE_TIME) 
    {
        THROW_ERROR(S, "Input sample time must be discrete.");
    }
}

/* Function: mdlInitializeConditions */
#define MDL_INITIALIZE_CONDITIONS
static void mdlInitializeConditions(SimStruct *S)
{
    int_T     numBitsIn     = (int_T) mxGetPr(NUMBITS_ARG)[0];
    int_T     errorCorr     = (int_T) mxGetPr(ERRORCORR_ARG)[0];
    int_T     checkRM       = (int_T) mxGetPr(CHECKRM_ARG)[0];
    int_T     deltaNi       = (int_T) mxGetPr(DELNIMAX_ARG)[0];
    TRmPar    *rmPar        = NULL;  
    int_T     b,i;

    /* Allocate memory for pWork Structure */
    rmPar = (TRmPar *) calloc(1,sizeof(TRmPar));
    if (rmPar==NULL)
    {   
        THROW_ERROR(S, "Insufficient Memory");
    }
        
    /* Store input parameters in struct */
    parDeltaNi   = deltaNi;
    parCheckRM   = checkRM;
    parNumBitsIn = numBitsIn;
    
    parPattern = (int_T *) calloc(parNumBitsIn, sizeof(int_T));
    if (parPattern==NULL)
    {   
        free(rmPar);
        THROW_ERROR(S, "Insufficient Memory");
    }
    
    
    /*Assign the parameter b in the structure to indicate the bit stream
     (turbo parity or otherwise) to be processed */
     
    /* Convolutional Encoding or Turbo coding when repetition */ 
    if ((errorCorr<3) || ((errorCorr==3) && (parDeltaNi>0)) ) 
        parB = 1;
    /* Turbo encoding when puncturing */    
    else 
        parB = 3;               

       
    /* Allocate memory for Work vectors */
    
    parX = (int_T *) calloc(parB, sizeof(int_T));
    if (parX==NULL)
    {   
        free(parPattern);
        free(rmPar);
        THROW_ERROR(S, "Insufficient Memory");
    }
    
    parEini     = (int_T *) calloc(parB, sizeof(int_T));
    if (parEini==NULL)
    {   
        free(parX);
        free(parPattern);
        free(rmPar);
        THROW_ERROR(S, "Insufficient Memory");
    }
       
    parEminus = (int_T *) calloc(parB, sizeof(int_T));
    if (parEminus==NULL)
    {   
        free(parEini);
        free(parX);
        free(parPattern);
        free(rmPar);
        THROW_ERROR(S, "Insufficient Memory");
        
    }
        
    parEplus = (int_T *) calloc(parB, sizeof(int_T));
    if (parEplus==NULL)
    {   
        free(parEminus);
        free(parEini);
        free(parX);
        free(parPattern);
        free(rmPar);
        THROW_ERROR(S, "Insufficient Memory");
    }
    
    /* Call the rmParams function to compute Rate Matching Paramters */
    getRMParameters(rmPar);

    /* Get Rate Matching puncturing or repetition pattern */
    if(parB == 1)
        rmPatternDetermination(rmPar,parPattern, 0);
    else
    {
        int_T *tempPat;
        tempPat = (int_T *) calloc(parNumBitsIn/3, sizeof(int_T));
        if (tempPat==NULL)
        {   
           free(parEplus); 
           free(parEminus);
           free(parEini);
           free(parX);
           free(parPattern);
           free(rmPar);
           THROW_ERROR(S, "Insufficient Memory");
        }
            
        for(b=1;b<3;b++)
        {
           rmPatternDetermination(rmPar, tempPat, b);
           for (i=0; i<parNumBitsIn/3; i++)
           {
              /* "parPattern[i*3] = 0;" is already performed during memory 
              allocation by CALLOC. Systematic bits are not rate matched */
              parPattern[i*3+b] = tempPat[i];
           }
        }
        free(tempPat);
    }
    /* Store struct's pointer in Simulink's PWork */
    ssGetPWork(S)[0] = rmPar;
}


/* Function: mdlOutputs */
static void mdlOutputs(SimStruct *S, int_T tid)
{
    TRmPar  *rmPar = (TRmPar *) ssGetPWorkValue(S,0);

    real_T   *u   = (real_T *) ssGetInputPortRealSignal(S, INPORT);
    real_T   *y   = (real_T *) ssGetOutputPortRealSignal(S, OUTPORT);

    rmComputeOutputVec(y, u, rmPar);
}

/* End of mdlOutputs */

static void mdlTerminate(SimStruct *S)
{
    TRmPar  *rmPar = (TRmPar *) ssGetPWorkValue(S,0);
    
    /* Free memory for Work vetors */
    free(parPattern);
    free(parX);
    free(parEini);
    free(parEminus);
    free(parEplus);
    free(rmPar);
}

#ifdef MATLAB_MEX_FILE
#define MDL_SET_INPUT_PORT_DIMENSION_INFO
static void mdlSetInputPortDimensionInfo(SimStruct *S, int_T port, const DimsInfo_T *dimsInfo)
{
    int_T  outCols, outRows;
    int_T  numBits      = (int_T)mxGetPr(NUMBITS_ARG)[0];
    int_T  delNimax     = (int_T)mxGetPr(DELNIMAX_ARG)[0]; 
    int_T  checkRM      = (int_T)mxGetPr(CHECKRM_ARG)[0];
    int_T  errorCorr    = (int_T) mxGetPr(ERRORCORR_ARG)[0];

    int_T  numDims  = ssGetInputPortNumDimensions(S, INPORT);
    int_T  inRows   = (numDims >= 1) ? dimsInfo->dims[0] : 0;
    int_T  inCols   = (numDims >= 2) ? dimsInfo->dims[1] : 0;

    int_T divisibilityCheck;
     
    if (!ssSetInputPortDimensionInfo(S, port, dimsInfo)) return;    
    
    if (inCols != 1)
       THROW_ERROR(S,"This block does not support multi-channel frame signals.Use multiple blocks to process multiple frames");
    
        
    if ((checkRM == RMATCHING) && (inRows != numBits))
       THROW_ERROR(S, "The input frame length must be same as the specified number of input bits .");
    
    if ((checkRM == RDEMATCHING) && (inRows != numBits + delNimax))
       THROW_ERROR(S, "The input frame length of rate de-matching block must be equal to the output frame length of the rate matching block.");
         
    /*Check for divisibility by 3 for Turbo coding case*/
    divisibilityCheck = inRows%3 ;
    if ((errorCorr == 3) && (divisibilityCheck!=0))
       THROW_ERROR(S, "The input frame length must be divisible by 3 for the case of turbo coding.");     


    outCols = inCols;

    if (checkRM == RMATCHING)     
       outRows = inRows + delNimax;
    else 
       outRows = inRows - delNimax;

    if (ssGetOutputPortWidth(S,OUTPORT) == DYNAMICALLY_SIZED) 
    {
       if(!ssSetOutputPortMatrixDimensions(S,OUTPORT, outRows, outCols)) 
       return;
    }
    else
    {   
       if (ssGetOutputPortWidth(S, OUTPORT) != outRows) 
          THROW_ERROR(S, "Input port dimension propagation failed.");
                       
    }
}

#define MDL_SET_OUTPUT_PORT_DIMENSION_INFO
static void mdlSetOutputPortDimensionInfo(SimStruct *S, int_T port,const DimsInfo_T *dimsInfo)
{
    int_T  inCols, inRows;
    int_T  numBits            = (int_T)mxGetPr(NUMBITS_ARG)[0];
    int_T  delNimax           = (int_T)mxGetPr(DELNIMAX_ARG)[0]; 
    int_T  checkRM            = (int_T)mxGetPr(CHECKRM_ARG)[0];

    int_T  numDims  = ssGetInputPortNumDimensions(S, INPORT);
    int_T  outRows   = (numDims >= 1) ? dimsInfo->dims[0] : 0;
    int_T  outCols   = (numDims >= 2) ? dimsInfo->dims[1] : 0;
 
    if (!ssSetOutputPortDimensionInfo(S, port, dimsInfo)) return;    
    
    if (outCols != 1)
    {
            THROW_ERROR(S, "This block does not support multi-channel frame signals.Use multiple blocks to process multiple frames");
    }
        
    if ((checkRM == RMATCHING) && (outRows != numBits+delNimax ))
            THROW_ERROR(S, "Invalid dimensions for output port.");

    if ((checkRM == RDEMATCHING) && (outRows != numBits))
            THROW_ERROR(S, "Invalid dimensions for output port.");

    
    inCols = outCols;
    if (checkRM == RMATCHING)     
            inRows = outRows - delNimax;
    else 
            inRows = outRows + delNimax;

    
    if (ssGetInputPortWidth(S,INPORT) == DYNAMICALLY_SIZED) 
    {
        if(!ssSetInputPortMatrixDimensions(S,OUTPORT, inRows, inCols)) 
        return;
    }
    else
    {   
        if (ssGetInputPortWidth(S, INPORT) != inRows) 
           THROW_ERROR(S, "Output port dimension propagation failed.");
    }
}

#define MDL_SET_DEFAULT_PORT_DIMENSION_INFO
static void mdlSetDefaultPortDimensionInfo(SimStruct *S)
{
    /* initialize a dynamically-dimensioned DimsInfo_T */
    DECL_AND_INIT_DIMSINFO(dInfo); 
    int_T dims[2] = {1, 1};

    /* select valid port dimensions */
    dInfo.width     = 1;
    dInfo.numDims   = 2;
    dInfo.dims      = dims;

    /* call the output functions */
    if (ssGetOutputPortWidth(S,OUTPORT) == DYNAMICALLY_SIZED) 
    { 
        mdlSetOutputPortDimensionInfo(S, OUTPORT, &dInfo);
    }

    /* call the input functions */
    if (ssGetInputPortWidth(S,INPORT) == DYNAMICALLY_SIZED) 
    { 
        mdlSetInputPortDimensionInfo(S, INPORT, &dInfo);
    }
}
#endif
 
#ifdef  MATLAB_MEX_FILE    
#include "simulink.c"      
#else
#include "cg_sfun.h"       
#endif
