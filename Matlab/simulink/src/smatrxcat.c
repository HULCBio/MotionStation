/*
 * SMATRXCAT: Matrix concatenation
 *
 *  Author: S. Conahan
 *  Copyright 1990-2004 The MathWorks, Inc.
 *  $Revision: 1.8.4.4 $  $Date: 2004/04/14 23:50:16 $
 */
#define S_FUNCTION_LEVEL 2
#define S_FUNCTION_NAME  smatrxcat

#include "simstruc.h" /* simulation-only code */
#include <math.h>

#define OUTPORT 0

/* Enumerated constants for passed-in parameters */
enum {
    NUM_INPT_ARGC=0,
    CAT_METH_ARGC,
    NUM_ARGS
};

enum {DIM_UNUSED=-2, DIM_UNINITIALIZED=-1};

/* Macros to obtain params easily */
#define NUM_INPORTS_ARG(S) ( ssGetSFcnParam( S, NUM_INPT_ARGC ) )
#define CONCAT_MTHD_ARG(S) ( ssGetSFcnParam( S, CAT_METH_ARGC ) )

/* Enumerated constants for possible concatenation methods */
enum { HORIZONTAL = 1, VERTICAL };

#define IS_HORIZONTAL(S) (((int_T)*mxGetPr(CONCAT_MTHD_ARG(S)) ) == HORIZONTAL)


#define IS_DOUBLE(X) (!mxIsComplex(X) && !mxIsSparse(X) && mxIsDouble(X))

#define IS_IDX_FLINT(X,IDX) (IS_DOUBLE(X) && \
                    (IDX < mxGetNumberOfElements(X)) && \
                    (IDX >= 0) && \
                    !mxIsInf(mxGetPr(X)[IDX]) && \
                    !mxIsNaN(mxGetPr(X)[IDX]) && \
                    (mxGetPr(X)[IDX] == floor(mxGetPr(X)[IDX])))

#define IS_IDX_FLINT_GE(X,IDX,V) (IS_IDX_FLINT(X,IDX) && \
                                    (mxGetPr(X)[IDX] >= (real_T)V))

#define IS_IDX_FLINT_IN_RANGE(X,IDX,A,B) (IS_IDX_FLINT(X,IDX) && \
                           (mxGetPr(X)[IDX] >= (real_T)A) && \
                           (mxGetPr(X)[IDX] <= (real_T)B) )

#define IS_SCALAR(X)      (mxGetNumberOfElements(X) == 1)
#define IS_FLINT_GE(X,V)  (IS_SCALAR(X) && IS_IDX_FLINT_GE(X,0,V)) 
#define IS_FLINT_IN_RANGE(X,A,B) \
                           (IS_SCALAR(X) && IS_IDX_FLINT_IN_RANGE(X,0,A,B))


#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters( SimStruct *S ) {

    /* Check number of inports: NOT tunable and must be defined integer > 0 */
    if ( !IS_FLINT_GE( NUM_INPORTS_ARG(S), 1 ) ) { 
        ssSetErrorStatus(S, "Number of inputs must be an integer greater "
                         "than zero.");
        goto EXIT_POINT;
    }

    /* Check concatenation method: NOT tunable and must be either 1 or 2 */
    if ( !IS_FLINT_IN_RANGE( CONCAT_MTHD_ARG(S), HORIZONTAL, VERTICAL ) ) {
        ssSetErrorStatus(S, "The valid choices for concatenation method are 1 "
                         "(Horizontal) and 2 (Vertical).");
        goto EXIT_POINT;
    }
 EXIT_POINT:
    return;
}
#endif


static void mdlInitializeSizes( SimStruct *S )
{
    ssSetNumSFcnParams( S, NUM_ARGS );
    
#if defined(MATLAB_MEX_FILE)
    if ( ssGetNumSFcnParams( S ) != ssGetSFcnParamsCount( S ) ) return;
    mdlCheckParameters(S);
    if(ssGetErrorStatus(S) != NULL) return;
#endif

    /* Constrain non-tunable parameters. NO tunable params in this blk. */
    ssSetSFcnParamNotTunable( S, NUM_INPT_ARGC );
    ssSetSFcnParamNotTunable( S, CAT_METH_ARGC );

    /* Input ports */
    {
        const int_T numInports     = (int_T) *mxGetPr(NUM_INPORTS_ARG(S));
        const int_T isOverwritable = (numInports == 1); /* DEGENERATE CASE */
        int_T       ip;
        
        if ( !ssSetNumInputPorts( S, numInports ) ) return;
        
        for ( ip = 0; ip < numInports; ip++ ) {
            if (!ssSetInputPortDimensionInfo(S,ip,DYNAMIC_DIMENSION)) return;
            ssSetInputPortFrameData(         S, ip, FRAME_INHERITED );
            ssSetInputPortDataType(          S, ip, DYNAMICALLY_TYPED );
            ssSetInputPortComplexSignal(     S, ip, COMPLEX_INHERITED );
            ssSetInputPortRequiredContiguous(S, ip, 1 );
            ssSetInputPortDirectFeedThrough( S, ip, 1 );
            ssSetInputPortOptimOpts(         S, ip, SS_REUSABLE_AND_LOCAL );
            ssSetInputPortOverWritable(      S, ip, isOverwritable );
        }
    }

    /* Output port */
    if (!ssSetNumOutputPorts( S, 1 )) return;
    if (!ssSetOutputPortDimensionInfo( S, OUTPORT, DYNAMIC_DIMENSION )) return;
    ssSetOutputPortFrameData(          S, OUTPORT, FRAME_INHERITED );
    ssSetOutputPortDataType(           S, OUTPORT, DYNAMICALLY_TYPED );
    ssSetOutputPortComplexSignal(      S, OUTPORT, COMPLEX_INHERITED );
    ssSetOutputPortOptimOpts(          S, OUTPORT, SS_REUSABLE_AND_LOCAL);

    /* Set other general block port defaults */
    ssSetNumSampleTimes( S, 1 );
    ssSetOptions(S,
                 SS_OPTION_WORKS_WITH_CODE_REUSE |
                 SS_OPTION_EXCEPTION_FREE_CODE |
                 SS_OPTION_USE_TLC_WITH_ACCELERATOR |
                 SS_OPTION_CAN_BE_CALLED_CONDITIONALLY |
                 SS_OPTION_NONVOLATILE);
}


static void mdlInitializeSampleTimes( SimStruct *S )
{
    ssSetSampleTime( S, 0, INHERITED_SAMPLE_TIME );
    ssSetOffsetTime( S, 0, 0.0 );
    ssSetModelReferenceSampleTimeDefaultInheritance(S);
}


static void outputFcn_Horizontal_Real_Output( SimStruct *S)
{
    /* Output is real -> ALL inputs are real */
    const int_T dataType         = ssGetOutputPortDataType( S, OUTPORT);
    const int_T bytesPerRealElmt = ssGetDataTypeSize( S, dataType);
    const int_T numInports       = ssGetNumInputPorts(S);
    byte_T      *y               = ssGetOutputPortSignal( S, OUTPORT );
    int_T       portNum;
    
    for ( portNum = 0; portNum < numInports; portNum++ ) {
        const int_T inputWidth    = ssGetInputPortWidth(S,portNum);
        const int_T numInputBytes = inputWidth * bytesPerRealElmt;
        const void  *u            =  ssGetInputPortSignal(S, portNum);

        /* Can copy each port individually (SL is column-major) */
        (void)memcpy(y, u, numInputBytes);
        
        /* Increment output pointer by the number of  bytes just filled */
        y += numInputBytes;
    } /* end portNum loop */
}

static void outputFcn_Horizontal_Cmplx_Output(SimStruct *S)
{
    /* 
     * Output is complex. However, only SOME inputs may be complex,
     * so we need to check each input.
     */
    const int_T dataType         = ssGetOutputPortDataType( S, OUTPORT);
    const int_T bytesPerRealElmt = ssGetDataTypeSize( S, dataType);
    const int_T numInports       = ssGetNumInputPorts(S);
    byte_T      *y               = ssGetOutputPortSignal( S, OUTPORT );
    int_T       portNum;
    
    for ( portNum = 0; portNum < numInports; portNum++ ) {
        if ( ssGetInputPortComplexSignal(S, portNum) == COMPLEX_YES ) {
            
            /* Complex elements have twice as many bytes as real elements */
            const int_T inputWidth    = ssGetInputPortWidth(S, portNum);
            const int_T numInputBytes = inputWidth * 2 * bytesPerRealElmt;
            const void  *u            =  ssGetInputPortSignal(S, portNum);   

            /* Can copy each port individually since SL is column-major */
            (void)memcpy( y, u, numInputBytes );
            
            /* Increment output pointer by the number of  bytes just filled */
            y += numInputBytes;
        } else {
            const byte_T *u       = ssGetInputPortSignal( S, portNum );
            const int_T  inpWidth = ssGetInputPortWidth(S, portNum);
            const void   *zero    = ssGetDataTypeZero(S, dataType);            
            int_T        cnt;
            
            /* Can copy each value individually since SL is column-major */
            for ( cnt = 0; cnt < inpWidth; cnt++ ) {

                /* y->re = (*u) */
                (void)memcpy( y, u, bytesPerRealElmt);
                
                /*
                 * We're going to do "y->im = zero(datatype)" below
                 *
                 * NOTE: For generated code, we cannot simply use all-zero 
                 * bytes due to non-IEEE floating point data types that we 
                 * might encounter.
                 */
                (void)memcpy( y+bytesPerRealElmt, zero, bytesPerRealElmt);
                        
                u +=   bytesPerRealElmt;  /* consumed one real input value  */
                y += (2*bytesPerRealElmt);/* wrote one complex output value */
            } /* end cnt loop */
        } /* end input complex vs. real */
    } /* end portNum loop */
}


static void outputFcn_Vertical_Real_Output(SimStruct *S)
{
    const int_T dataType         = ssGetOutputPortDataType( S, OUTPORT);
    const int_T bytesPerRealElmt = ssGetDataTypeSize( S, dataType);
    const int_T numInports       = ssGetNumInputPorts(S);
    const int_T nCols            = (ssGetOutputPortNumDimensions(S,OUTPORT) < 2) 
                                   ? 1 : (ssGetOutputPortDimensions(S, OUTPORT)[1]);
    byte_T      *y               = ssGetOutputPortSignal( S, OUTPORT );
    int_T       inpColIndex;
    
    /*
     * Output is real -> ALL inputs are real
     *
     * Loop over output COLUMNS first, since SL is column-major.  
     * This matches the order of the matrix output signal samples 
     * to the current SL implementation for matrix signals.       
     */
    for ( inpColIndex = 0; inpColIndex < nCols; inpColIndex++ ) {
        int_T portNum;
        
        /* 
         * The middle loop is over the current input port number    
         * to source the data from and which "mRows" number to use, 
         * since this is variable for each input (unfortunately).   
         */
        for ( portNum = 0; portNum < numInports; portNum++ ) {
            const int_T *inpDimsPtr  = ssGetInputPortDimensions( S, portNum );
            const int_T  numColBytes = inpDimsPtr[0] * bytesPerRealElmt;
            const int_T  inpOffset   = inpColIndex * numColBytes;
            const byte_T *u          = ssGetInputPortSignal( S, portNum );
            
            /* 
             * Inner loop is over current input col length
             * (in bytes). Output is filled contiguously.  
             */
            (void)memcpy( y, u + inpOffset, numColBytes );
            
            /* 
             * Increment the output sample pointer by the number of 
             * bytes just filled using the MEMCPY library function. 
             */
            y += numColBytes;
            
        } /* end inputCount loop */
    } /* end inpColIndex loop */
}

static void outputFcn_Vertical_Cmplx_Output(SimStruct *S)
{
    const int_T dataType         = ssGetOutputPortDataType( S, OUTPORT);
    const int_T bytesPerRealElmt = ssGetDataTypeSize( S, dataType);
    const int_T numInports       = ssGetNumInputPorts(S);
    const int_T nCols            = (ssGetOutputPortNumDimensions(S,OUTPORT) < 2) 
                                   ? 1 : (ssGetOutputPortDimensions(S, OUTPORT)[1]);
    
    /* Output is complex. SOME inputs may be complex, so check each input */
    byte_T *y = ssGetOutputPortSignal( S, OUTPORT );
    int_T   inpColIndex;

    /* 
     * Loop over output COLUMNS first, since SL is column-major.  
     * This matches the order of the matrix output signal samples 
     * to the current SL implementation for matrix signals.       
     */
    for ( inpColIndex = 0; inpColIndex < nCols; inpColIndex++ ) {
        int_T portNum;
        
        /* 
         * The middle loop is over the current input port number    
         * to source the data from and which "mRows" number to use, 
         * since this is variable for each input (unfortunately).   
         */
        for ( portNum = 0; portNum < numInports; portNum++ ) {
            
            const int_T *inpDimsPtr  = ssGetInputPortDimensions( S, portNum );
            
            if (ssGetInputPortComplexSignal(S, portNum) == COMPLEX_YES) {
                /* Complex elements have twice as many bytes as real elements*/
                const int_T  numColBytes = inpDimsPtr[0] * 2*bytesPerRealElmt;
                const int_T  inpOffset   = inpColIndex * numColBytes;
                const byte_T *u          = ssGetInputPortSignal(S, portNum);
                
                /* 
                 * Inner loop is over current input col length (in bytes). 
                 * Output is filled contiguously.  
                 */
                (void)memcpy( y, u + inpOffset, numColBytes );
                
                /* 
                 * Bump the output sample pointer by number of bytes just 
                 * filled using the MEMCPY library function.    
                 */
                y += numColBytes;
            }else {
                const void   *zero    = ssGetDataTypeZero(S, dataType);
                const byte_T *u       = ssGetInputPortSignal(S, portNum);
                const int_T inpOffset = inpColIndex * inpDimsPtr[0] * 
                                        bytesPerRealElmt;
                int_T       inpRowIndex;
                
                /* 
                 * The inner loop is over the current inp col length given 
                 * by "mRows". Output is filled contiguously.  
                 */
                for (inpRowIndex=0; inpRowIndex<inpDimsPtr[0];inpRowIndex++) {
                    /* 
                     * Get the next input signal value from the proper   
                     * input port number and send it out to the OUTPORT. 
                     * NOTE: Input is real, output is complex...         
                     */
                    
                    /* y->re = (*u) */
                    (void)memcpy( y, 
                                  u+inpOffset + (inpRowIndex*bytesPerRealElmt),
                                  bytesPerRealElmt);
                    /*
                     * We're going to do "y->im = 0" below
                     * NOTE: For generated code, we cannot simply use 
                     * all-zero bytes due to non-IEEE floating point data 
                     * types that we might encounter.
                     */
                    (void)memcpy(y+bytesPerRealElmt, zero, bytesPerRealElmt);
                    
                    /* Increment out ptr by num bytes copied */
                    y += 2*bytesPerRealElmt;
                } /* end inpRowIndex loop */
            } /* end input complex vs. real */
        } /* end portNum loop */
    } /* end inpColIndex loop */
} 

/*
 * --------------------------------------------------------------
 * Horizontal concatenation -> given only row information from 
 * param (rows are constant for all input ports, column size must 
 * be found separately for each input port). Note that input port 
 * complexity may be non-homogeneous (and each is indepedent).
 * --------------------------------------------------------------
 * Vertical concatenation -> given only column information from 
 * param (cols are constant for all input ports, row size must be 
 * found separately for each input port). Note that input port 
 * complexity may be non-homogeneous (and each is indepedent). 
 * ALGORITHM DETAILS:
 * Since SL is column-major in its current implementation for 
 * passing matrix signals between blocks, we must consider the 
 * output signal as just a linear stream of samples of the 
 * vertically-concatenated matrices at the multiple input ports. 
 * The output port samples must thus be arranged as follows:
 *
 * OUTPUT STREAM (start to finish) =   
 *          InpCol * Offset    InpRow                                
 *   {  In1[ (0    * mRows1) +    0  ],                              
 *      In1[ (0    * mRows1) +    1  ],                              
 *      In1[ (0    * mRows1) +    2  ],                              
 *      ...,                                                         
 *      In1[ (0    * mRows1) + (mRows1-1) ],                         
 *                                                                   
 *      In2[ (0    * mRows2) +    0  ],                              
 *      In2[ (0    * mRows2) +    1  ],                              
 *      In2[ (0    * mRows2) +    2  ],                              
 *      ...,                                                         
 *      In2[ (0    * mRows2) + (mRows2-1) ],                         
 *                                                                   
 *      In3[ (0    * mRows3) +    0  ],                              
 *      ...,                                                         
 *      ...,                                                         
 *      InN[ (0    * mRowsN) + (mRowsN-1) ],                         
 *                                                                   
 *      In1[ (1    * mRows1) +    0  ],                              
 *      In1[ (1    * mRows1) +    1  ],                              
 *      In1[ (1    * mRows1) +    2  ],                              
 *      ...,                                                         
 *      In1[ (1    * mRows1) + (mRows1-1) ],                         
 *                                                                   
 *      In2[ (1    * mRows2) +    0  ],                              
 *      In2[ (1    * mRows2) +    1  ],                              
 *      In2[ (1    * mRows2) +    2  ],                              
 *      ...,                                                         
 *      In2[ (1    * mRows2) + (mRows2-1) ],                         
 *                                                                   
 *      In3[ (1    * mRows3) +    0  ],                              
 *      ...,                                                         
 *      ...,                                                         
 *      InN[ (1    * mRowsN) + (mRowsN-1) ],                         
 *                                                                   
 *      In1[ (2    * mRows1) +    0  ],                              
 *      In1[ (2    * mRows1) +    1  ],                              
 *      In1[ (2    * mRows1) +    2  ],                              
 *      ...,                                                         
 *      In1[ (2    * mRows1) + (mRows1-1) ],                         
 *                                                                   
 *      In2[ (2    * mRows2) +    0  ],                              
 *      In2[ (2    * mRows2) +    1  ],                              
 *      In2[ (2    * mRows2) +    2  ],                              
 *      ...,                                                         
 *      In2[ (2    * mRows2) + (mRows2-1) ],                         
 *                                                                   
 *      In3[ (2    * mRows3) +    0  ],                              
 *      ...,                                                         
 *      ...,                                                         
 *      InN[ (2    * mRowsN) + (mRowsN-1) ],                         
 *                                                                   
 *      In1[ (3    * mRows1) +    0  ],                              
 *      ...,                                                         
 *      ...,                                                         
 *      ...,                                                         
 *      ...,                                                         
 *      In1[ ((nCols-1) * mRowsN) + 0 ],                             
 *      ...,                                                         
 *      ...,                                                         
 *      InN[ ((nCols-1) * mRowsN) + (mRowsN-1) ],                    
 *   }                                                               
 *                                                                   
 * The overall length of this output signal stream should equal the  
 * total length of each of the input matrix signals. That is:        
 *                                                                   
 * LENGTH = ( mRows1 + mRows2 + mRows3 + ... + mRowsN ) * nCols;     
 *                                                                   
 * In order for this entire mess to be implemented,                  
 * we must have three (3) loops:                                     
 *                                                                   
 *    Outer loop  -> input/output column (minus one)                 
 *    Middle loop -> input port number (minus one)                   
 *    Inner loop  -> contiguous MEMCPY  using current column pointers
 * ------------------------------------------------------------------ 
 */
static void mdlOutputs(SimStruct *S, int_T tid )
{

    /* 
     * If there is one port, and Simulink allowed the output port
     * to share the input port space, then we don't need to copy data.
     */
    const boolean_T in_place = 
        (boolean_T)(ssGetInputPortBufferDstPort(S, 0) == OUTPORT);

    if (!in_place) {
        /* 
         * ----------------- GENERIC DATA TYPE SUPPORT ----------------------
         * NOTE: It is assumed that all input and output ports are the same   
         * type. Since we are always guaranteed an output port, get info from 
         * there. Get number of bytes per element to be concatenated.  Use 
         * byte_T ptrs for generic data type handling below (to do the 
         * "byte-shuffling" ops). Note that complex signals have elt size 
         * equal to (2*bytesPerRealElmt).
         * ----------------- GENERIC DATA TYPE SUPPORT ----------------------
         */
        if ( IS_HORIZONTAL(S) ) {
            if (ssGetOutputPortComplexSignal(S, OUTPORT) == COMPLEX_NO) {
                outputFcn_Horizontal_Real_Output(S);
            } else {
                outputFcn_Horizontal_Cmplx_Output(S);
            }
        } else {
            if (ssGetOutputPortComplexSignal(S, OUTPORT) == COMPLEX_NO) {
                outputFcn_Vertical_Real_Output(S);
            }else{
                outputFcn_Vertical_Cmplx_Output(S);
            }
        }
    }
} /* end function mdlOutputs */


static void mdlTerminate( SimStruct *S )
{
}

#ifdef MATLAB_MEX_FILE

/*
 * ===================================================
 * BEGIN - PropCache functions
 * ===================================================
 */

/*
 * Propagation cache
 * Holds all data necessary for:
 *  - checking port dimensions
 *
 * ASSUMPTION: One output port, N input ports.
 */
typedef struct {

    int numInports;
    int *inputRowSize;
    int *inputColSize;

    int outputRowSize;
    int outputColSize;

} PropCache;


/*
 * Free the propagation data cache
 */
static void freePropCache(PropCache *prop_cache)
{
    if (prop_cache != NULL) {
        /* inputRowSize and inputColSize are
         * all one contiguous allocation:
         */
        if (prop_cache->inputRowSize != NULL) {
            free(prop_cache->inputRowSize);
        }
        free(prop_cache);
    }
}


/* Function: allocPropCache ===================================================
 * Allocate the propagation data cache
 * Returns 0 on failure, 1 if successful.
 * If failure occurs, pushes an error onto the Simulink error stack.
 */
static PropCache *allocPropCache(SimStruct *S)
{
    /* Allocate optimization input cache: */
    const int numInports  = ssGetNumInputPorts(S);
    PropCache *prop_cache = (PropCache *)calloc(1, sizeof(PropCache));

    if (prop_cache == NULL) {
        ssSetErrorStatus(S, "Failed to allocate propagation cache.");
        return(prop_cache);
    }
    prop_cache->numInports = numInports;

    /*
     * Make one DOUBLE-LENGTH allocation for inputRowSize and inputColSize,
     * and set the pointers INTO the allocation buffer appropriately.
     *
     * Allocation: [ inputRowSize[N] inputColSize[N] ] in that order.
     *
     * NOTE: Using calloc to guarantee that zeros are filled in.
     *       0x0 is not a valid dimension in Simulink, and thus
     *       these dims are readily identifiable as uninitialized.
     */
    prop_cache->inputRowSize = calloc(2*numInports, sizeof(int));
    if (prop_cache->inputRowSize == NULL) {
        freePropCache(prop_cache);
        ssSetErrorStatus(S, "Failed to allocate propagation cache.");
        return(NULL);
    }
    prop_cache->inputColSize = prop_cache->inputRowSize + numInports;

    return(prop_cache);
}


/* Function: initPropCacheDimInfo =============================================
 * Copy all port size info into the propagation cache.
 * Any ports without dim info are flagged as uninitialized.
 *
 * Assumes that the OptimCache allocation function already
 * filled in the number of ports (it needed it for allocation
 * purposes).
 */
static void initPropCacheDimInfo(SimStruct *S, PropCache *prop_cache)
{
    int_T  portIdx, numDims, r, c;
    int_T *dims;

    /* Initialize input port dim info: */
    for (portIdx=0; portIdx < prop_cache->numInports; portIdx++) {
        numDims = ssGetInputPortNumDimensions(S, portIdx);
        dims    = ssGetInputPortDimensions(   S, portIdx);

        if (numDims>2) {
            static char msg[128];
            (void)sprintf(msg, "Input port %d cannot have dimensionality "
                          "greater than 2.", portIdx+1);
            ssSetErrorStatus(S, msg);
            goto EXIT_POINT;
        } else if (numDims==2) {
            r = dims[0];
            c = dims[1];
        } else if (numDims==1) {
            r = dims[0];
            c = DIM_UNUSED;
        } else {
            r = DIM_UNINITIALIZED;
            c = DIM_UNINITIALIZED;
        }
        prop_cache->inputRowSize[portIdx] = r;
        prop_cache->inputColSize[portIdx] = c;
    }

    /* Initialize output port dim info: */
    numDims = ssGetOutputPortNumDimensions(S, 0);
    dims    = ssGetOutputPortDimensions(S, 0);
    if (numDims>2) {
        ssSetErrorStatus(S, "Output port cannot have dimensionality greater "
                    "than 2.");
        goto EXIT_POINT;
    } else if (numDims==2) {
        r = dims[0];
        c = dims[1];
    } else if (numDims==1) {
        r = dims[0];
        c = DIM_UNUSED;
    } else {
        r = DIM_UNINITIALIZED;
        c = DIM_UNINITIALIZED;
    }
    prop_cache->outputRowSize = r;
    prop_cache->outputColSize = c;
 EXIT_POINT:
    return;
}


/* Function: fixupPropCacheDimInfo ============================================
 * Find all non-2D inputs, and generate either an error
 * if the input is invalid, or create an equivalent 2-D
 * input size for each such entry.
 *
 * Returns 1 if successful; 0 if an error occurred.
 */
static void fixupPropCacheDimInfo(PropCache *prop_cache)
{
    int i, r, c;

    /* fixup inport dim info */
    for (i=0; i < prop_cache->numInports; i++) {
        r = prop_cache->inputRowSize[i];
        c = prop_cache->inputColSize[i];

        if ((r != DIM_UNINITIALIZED) && (c == DIM_UNUSED)) {
            /*
             * Assume the unoriented (1-D) input is a column vector:
             */
            prop_cache->inputColSize[i] = 1;
        }
    }

    /* fixup outport dim info */
    r = prop_cache->outputRowSize;
    c = prop_cache->outputColSize;
    if ((r != DIM_UNINITIALIZED) && (c == DIM_UNUSED)) {
        /*
         * Assume the unoriented (1-D) output is a column vector:
         */
        prop_cache->outputColSize = 1;
    }
}


static boolean_T allInputPortDimensionsDefined( SimStruct *S )
{
    int_T portNum = ssGetNumInputPorts(S);

    while (--portNum >= 0) {
        if ( ssGetInputPortWidth( S, portNum ) == DYNAMICALLY_SIZED ) {
            return false;  /* NOTE: Early return! */
        }
    }
    return true;
}


static boolean_T allButOneInputPortDimensionDefined(SimStruct *S, 
                                                    int       *unsetPortIdx)
{
    const int numInports = ssGetNumInputPorts(S);
    int       portNum    = numInports;
    int       cnt        = 0;

    while (--portNum >= 0) {
        if ( ssGetInputPortWidth( S, portNum ) != DYNAMICALLY_SIZED ) {
            cnt++;
        } else {
            *unsetPortIdx = portNum;
        }
    }
    return( (boolean_T)(cnt == (numInports-1)) );
}


/* Function: setUninitPropCacheDimInfo ========================================
 * Set uninitialized port dimension info and update
 * the prop cache appropriately.  Here are the two
 * situations that allow us to fill in missing info:
 *
 * 1) If all inputs are known, then we can fill in
 *    the output (we force the output to be 2-D no matter what)
 *
 * 2) If the output is known, AND all but one of the inputs
 *    are known, then we can fill in the missing input port.
 *    CAVEAT: If the missing port turns out to be a vector,
 *    we CANNOT fill in the info since we accept EITHER 
 *    oriented and unoriented vectors.
 *
 */
static void setUninitPropCacheDimInfo(SimStruct *S, PropCache *prop_cache)
{
    int numInports = prop_cache->numInports;
    int outportSet = (prop_cache->outputRowSize != DIM_UNINITIALIZED);

    if (!outportSet) {
        if ( allInputPortDimensionsDefined(S) ) {
            /* **************************************************** */
            /* Case 1 - all inputs are known, output not set (yet!) */
            /* **************************************************** */
            int r, c, portNum;

            if (IS_HORIZONTAL(S)) {
                /*
                 * # rows are constant ... grab this from the first input
                 * # cols = sum of all input col dims
                 */
                r = prop_cache->inputRowSize[0];
                c = 0;  /* Preset to zero before summing dims */

                for (portNum=0; portNum<numInports; portNum++) {
                    c += prop_cache->inputColSize[portNum];
                }
            } else { /* VERTICAL */
                /*
                 * # cols are constant ... grab this from the first input
                 * # rows = sum of all input row dims
                 */
                c = prop_cache->inputColSize[0];
                r = 0;  /* Preset to zero before summing dims */

                for (portNum=0; portNum<numInports; portNum++) {
                    r += prop_cache->inputRowSize[portNum];
                }
            }

            /* 
             * Set the matrix dimensions into the cache AND into the 
             * output port itself
             */
            prop_cache->outputRowSize = r;
            prop_cache->outputColSize = c;
            if(!ssSetOutputPortMatrixDimensions(S, OUTPORT, r, c)) return;
        }

    } else {
        int unsetPortIdx = -1;

        if (allButOneInputPortDimensionDefined(S, &unsetPortIdx)) {
            /* ************************************************************ */
            /* Case 2 - output port is known, all but one input port is set */
            /* ************************************************************ */
            int r, c, portNum;
            
            if ( IS_HORIZONTAL(S) ) {
                /*
                 * # rows are constant ... grab this from the output port
                 * # cols of unknown port = (output cols) - 
                 *                   (sum of all known input col dims)
                 */
                r = prop_cache->outputRowSize;
                c = 0;  /* Preset to zero before summing dims */

                for (portNum=0; portNum<numInports; portNum++) {
                    if (portNum != unsetPortIdx) {
                        c += prop_cache->inputColSize[portNum];
                    }
                }
                
                c = prop_cache->outputColSize - c;
            }
            else { /* VERTICAL */
                /*
                 * # cols are constant ... grab this from the output
                 * # rows of unknown port = (output rows) - 
                 *                    (sum of all known input row dims)
                 */
                c = prop_cache->outputColSize;
                r = 0;  /* Preset to zero before summing dims */
                
                for (portNum=0; portNum<numInports; portNum++) {
                    if (portNum != unsetPortIdx) {
                        r += prop_cache->inputRowSize[portNum];
                    }
                }
                
                r = prop_cache->outputRowSize - r;
            }
            
            /* 
             * Now that we know the desired dims of the previously-unknown 
             * input port, we must verify that it is not a vector.  If it is, 
             * bail out.
             */

            if ( (r > 1) && (c > 1) ) {
                /* 
                 * Input is 2-D and a matrix -> we can set it definitively 
                 * here. Set matrix dimensions into the cache AND into the 
                 * input port itself:
                 */
                prop_cache->inputRowSize[unsetPortIdx] = r;
                prop_cache->inputColSize[unsetPortIdx] = c;
                if(!ssSetInputPortMatrixDimensions(S,unsetPortIdx,r,c)) return;
            }
        }
    }
}


/* Function: checkPropCacheDimInfo ============================================
 * Verify that all port sizes are valid.
 * Port size info may not have been set for all ports.
 */
static void checkPropCacheDimInfo(SimStruct *S, PropCache *prop_cache)
{
    /*
     * PropCache contains either uninitialized ports, or
     * it has complete 2-D info for each port.
     *
     * Rules for checking concatenation:
     * 1) Horizontal:
     *     - # rows are constant across all ports (in and out)
     *     - # cols in output must equal the sum of # cols of inputs
     * 2) Vertical:
     *     - # cols are constant across all ports (in and out)
     *     - # rows in output must equal the sum of # rows of inputs
     */
    const int numInports = prop_cache->numInports;
    int       portNum;

    if ( IS_HORIZONTAL(S) ) {
        const int desiredRows       = prop_cache->outputRowSize;
        boolean_T anyUninitOutports = (boolean_T)
                                          (desiredRows == DIM_UNINITIALIZED);
        if (!anyUninitOutports) {
            boolean_T anyUninitInports  = false;
            int       inputColSum       = 0;

            for(portNum=0; portNum<numInports; portNum++) {
                boolean_T thisPortUninit = (boolean_T)
                    (prop_cache->inputRowSize[portNum] == DIM_UNINITIALIZED);
                if (thisPortUninit) {
                    anyUninitInports = true;
                } else {
                    inputColSum += prop_cache->inputColSize[portNum];
                }
                
                if (!thisPortUninit && 
                    (prop_cache->inputRowSize[portNum] != desiredRows)) {
                    static char msg[128];
                    (void)sprintf(msg, "Number of rows in input port %d and "
                                  "output port must agree.", portNum+1);
                    ssSetErrorStatus(S, msg);
                    goto EXIT_POINT;
                }
            }
            if (anyUninitInports) {
                /* 
                 * Simply check that the total sum of all known input ports 
                 * does not exceed the output port size. BTW, keep 
                 * the ">=" ... any "as yet unknown" input ports MUST have 
                 * dimensionality >=1, so adding them in to the sum will 
                 * definitely cause us to exceed the output port size!
                 */
                if (inputColSum >= prop_cache->outputColSize) {
                    ssSetErrorStatus(S, "Sum of defined input port column "
                                     "sizes exceeds output port column size.");
                    goto EXIT_POINT;
                }
            } else {
                /* 
                 * Check that the total sum of the inputs is EXACTLY equal 
                 * to the output port size 
                 */
                if (inputColSum != prop_cache->outputColSize) {
                    ssSetErrorStatus(S, "Sum of input port column sizes does "
                                     "not match output port column size.");
                    goto EXIT_POINT;
                }
            }
        }

    } else { /* Vertical */
        const int desiredCols       = prop_cache->outputColSize;
        boolean_T anyUninitOutports = (boolean_T)
                                         (desiredCols == DIM_UNINITIALIZED);
        if (!anyUninitOutports) {
            boolean_T anyUninitInports  = false;
            int       inputRowSum       = 0;
            
            for(portNum=0; portNum<numInports; portNum++) {
                boolean_T thisPortUninit = (boolean_T)
                    (prop_cache->inputRowSize[portNum] == DIM_UNINITIALIZED);
                if (thisPortUninit) {
                    anyUninitInports = true;
                } else {
                    inputRowSum += prop_cache->inputRowSize[portNum];
                }
                
                if (!thisPortUninit && 
                    (prop_cache->inputColSize[portNum] != desiredCols)) {
                    static char msg[128];
                    (void)sprintf(msg, "Number of columns in input port %d and "
                                  "output port must agree.", portNum+1);
                    ssSetErrorStatus(S, msg);
                    goto EXIT_POINT;
                }
            }

            if (anyUninitInports) {
                /* 
                 * Simply check that the total sum of all known input ports 
                 * does not exceed the output port size. BTW, keep 
                 * the ">=" ... any "as yet unknown" input ports MUST have 
                 * dimensionality >=1, so adding them in to the sum will 
                 * definitely cause us to exceed the output port size!
                 */
                if (inputRowSum >= prop_cache->outputRowSize) {
                    ssSetErrorStatus(S, "Sum of defined input port row sizes "
                                     "exceeds output port row size.");
                    goto EXIT_POINT;
                }
            } else {
                /* 
                 * Check that the total sum of the inputs is EXACTLY equal 
                 * to the output port size 
                 */
                if (inputRowSum != prop_cache->outputRowSize) {
                    ssSetErrorStatus(S, "Sum of input port row sizes does not "
                                     "match output port row size.");
                    goto EXIT_POINT;
                }
            }
        }
    }
 EXIT_POINT:
    return;
}


/* Function: checkAndSetPortDimensions ========================================
 * Called directly from input and output port-size handshake functions.
 * Assumes size info for the current port has already been set by caller.
 */
static void checkAndSetPortDimensions(SimStruct *S)
{
    PropCache *prop_cache = allocPropCache(S);
    if (ssGetErrorStatus(S) != NULL) goto CASPS_EXIT;

    initPropCacheDimInfo(S, prop_cache);
    if (ssGetErrorStatus(S) != NULL) goto CASPS_EXIT;

    fixupPropCacheDimInfo(prop_cache);

    setUninitPropCacheDimInfo(S, prop_cache);

    checkPropCacheDimInfo(S, prop_cache);
    if (ssGetErrorStatus(S) != NULL) goto CASPS_EXIT;

CASPS_EXIT:
    freePropCache(prop_cache);
}

#define MDL_SET_INPUT_PORT_DIMENSION_INFO
static void mdlSetInputPortDimensionInfo(SimStruct     *S,
                                         int_T             portIdx,
                                         const DimsInfo_T *dimsInfo)
{
    if( !ssSetInputPortDimensionInfo(S, portIdx, dimsInfo) ) return;
    checkAndSetPortDimensions(S);
}


#define MDL_SET_OUTPUT_PORT_DIMENSION_INFO
static void mdlSetOutputPortDimensionInfo(SimStruct     *S, 
                                          int_T             portIdx,
                                          const DimsInfo_T *dimsInfo)
{
    if( !ssSetOutputPortDimensionInfo(S, portIdx, dimsInfo) ) return;
    checkAndSetPortDimensions(S);
}


static void SetPortDataTypes(SimStruct *S,
                            DTypeId   dataType)
{
    const int_T numInports  = ssGetNumInputPorts(  S );
    const int_T numOutports = ssGetNumOutputPorts( S );
    int_T i;

    /* 
     * Set (force) all input and output ports to same data type   
     * NOTE: No explicit check for types not set, since the first 
     * data type set gets forced onto all of the i/o ports.       
     */
    for (i=0; i<numInports; i++) {
        ssSetInputPortDataType( S, i, dataType );
    }

    for (i=0; i<numOutports; i++) {
        ssSetOutputPortDataType(S, i, dataType);
    }
}

#define MDL_SET_INPUT_PORT_DATA_TYPE
static void mdlSetInputPortDataType(SimStruct *S,
                                    int_T     portIdx,
                                    DTypeId   inputPortDataType)
{
    SetPortDataTypes(S, inputPortDataType);
}


#define MDL_SET_OUTPUT_PORT_DATA_TYPE
static void mdlSetOutputPortDataType(SimStruct *S,
                                     int_T     portIdx,
                                     DTypeId   outputPortDataType)
{
    SetPortDataTypes(S, outputPortDataType);
}

static void checkAndSetInportComplexity( SimStruct *S,
                                         int_T      portIdx,
                                         CSignal_T  complexity )
{
    CSignal_T inCplx = ssGetInputPortComplexSignal(S, portIdx);

    if ( inCplx == COMPLEX_INHERITED ) {
        ssSetInputPortComplexSignal(S, portIdx, complexity);
    }
    else if ( inCplx != complexity ) {
        static char msg[128];
        (void)sprintf(msg, "Attempted to set input port %d complexity after it "
                      "was already set to opposite sense.", portIdx+1);
        ssSetErrorStatus(S, msg);
        goto EXIT_POINT;
    }
 EXIT_POINT:
    return;
}


static void checkAndSetOutportComplexity( SimStruct *S, CSignal_T complexity )
{
    if ( ssGetOutputPortComplexSignal(S, OUTPORT) == COMPLEX_INHERITED ) {
        ssSetOutputPortComplexSignal(S, OUTPORT, complexity);
    }
    else if ( ssGetOutputPortComplexSignal(S, OUTPORT) != complexity ) {
        ssSetErrorStatus(S, "Attempted to set output port complexity after it "
                         "was already set to opposite sense.");
        goto EXIT_POINT;
    }
 EXIT_POINT:
    return;
}

#define MDL_SET_INPUT_PORT_COMPLEX_SIGNAL
static void mdlSetInputPortComplexSignal( SimStruct *S,
                                          int_T      portIdx,
                                          CSignal_T  iPortComplexSignal )
{
    const int_T numInports = ssGetNumInputPorts(S);

    int_T numInportsSetToReal = 0;
    int_T numInportsSetToCplx = 0;
    int_T portNum;

    /* First do what Simulink told us to do... */
    ssSetInputPortComplexSignal( S, portIdx, iPortComplexSignal );

    /* Calculate number of real inputs and number of complex inputs defined */
    for ( portNum = 0; portNum < numInports; portNum++ ) {
        if ( ssGetInputPortComplexSignal( S, portNum ) == COMPLEX_NO ) {
            numInportsSetToReal++; /* increment num real inputs counter */
        }
        else if ( ssGetInputPortComplexSignal( S, portNum ) == COMPLEX_YES ) {
            numInportsSetToCplx++; /* increment num cplx inputs counter */
        }
    }

    /* 
     * -------------------------------------------------------------------- 
     * If ALL of the input ports are real, then the output port must be real. 
     * ---------------------------------------------------------------------- 
     */
     
    if ( numInportsSetToReal == numInports ) {
        checkAndSetOutportComplexity( S, COMPLEX_NO );
    }

    /*
     * --------------------------------------------------------------------- 
     * If ONE of the input ports is complex, then the output port is complex. 
     * ---------------------------------------------------------------------- 
     */
    else if ( numInportsSetToCplx > 0 ) {
        checkAndSetOutportComplexity( S, COMPLEX_YES );
    }

    /* 
     * ----------------------------------------------------------------------
     * Otherwise, all bets are off for the output port complexity.           
     * ----------------------------------------------------------------------
     */
}

#define MDL_SET_OUTPUT_PORT_COMPLEX_SIGNAL
static void mdlSetOutputPortComplexSignal( SimStruct *S,
                                           int_T      portIdx,
                                           CSignal_T  oPortComplexSignal )
{
    const int_T numInports = ssGetNumInputPorts(S);

    /* First do what Simulink told us to do... */
    ssSetOutputPortComplexSignal( S, portIdx, oPortComplexSignal );

    /* 
     * --------------------------------------------------------------------- 
     * If the output port is real, then ALL of the input port(s) must be real
     * ----------------------------------------------------------------------
     */
    if (oPortComplexSignal == COMPLEX_NO) {
        int_T portNum;

        for ( portNum = 0; portNum < numInports; portNum++ ) {
            checkAndSetInportComplexity( S, portNum, COMPLEX_NO );
        }
    }
    
    else {
        /* 
         * ---------------------------------------------------------------- 
         * Output was set to COMPLEX, which means at least one input should 
         * be complex. We can't tell which one(s) to set complex unless we  
         * already know that all except one is NOT complex. Otherwise, all  
         * bets are off since all of the input ports are independent!       
         * ---------------------------------------------------------------- 
         */
        {
            int_T numInportsSetToReal = 0;
            int_T portNum;

            /* 
             * If we know that all except one input port already set to real, 
             * then we know that this remaining input port must be complex.  
             * Since such a case is so rare, first just count how many real, 
            * and deal with the special case for backpropagation afterward.  
            */
            for ( portNum = 0; portNum < numInports; portNum++ ) {
                if (ssGetInputPortComplexSignal( S, portNum ) == COMPLEX_NO) {
                    numInportsSetToReal++; /* num real inputs counter */
                }
            }
            
            if ( numInportsSetToReal == (numInports - 1) ) {
                int_T inpIdxToSetCplx = -1; /* invalid index == NONE */
                
                /* Find the port to set to COMPLEX */
                for ( portNum = 0; portNum < numInports; portNum++ ) {
                    if (ssGetInputPortComplexSignal(S, portNum)!= COMPLEX_NO) {
                        inpIdxToSetCplx = portNum;
                        break;
                    }
                }

                if ( inpIdxToSetCplx > -1 ) {
                    checkAndSetInportComplexity(S,inpIdxToSetCplx,COMPLEX_YES);
                }
                else {
                    ssSetErrorStatus( S, "Error backpropagating output "
                                      "complexity to input ports.");
                    goto EXIT_POINT;
                }
            }
            
            /* ELSE all bets are off...not enough information. */
        }
    }
 EXIT_POINT:
    return;
}
#endif


#define MDL_RTW
#if defined(MATLAB_MEX_FILE) || defined(NRT)
static void mdlRTW( SimStruct *S )
{
    const int_T concatMthd = (int_T) *mxGetPr(CONCAT_MTHD_ARG(S));

    /* Write out parameters for RTW (currently all non-tunable) */
    if (!ssWriteRTWParamSettings(S, 1,
        SSWRITE_VALUE_DTYPE_NUM, "CatMethod", &concatMthd,
        DTINFO(SS_INT32,COMPLEX_NO)
        ))  {
        return; /* An error occurred which will be reported by Simulink */
    }
}
#endif

#ifdef  MATLAB_MEX_FILE    
#include "simulink.c"      
#else
#include "cg_sfun.h"       
#endif

/* [EOF] smatrxcat.c */
